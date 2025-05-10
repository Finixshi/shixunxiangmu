import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';

// 定义Select选项类
class SelectOption {
  value: string;
  
  constructor(value: string) {
    this.value = value;
  }
}

// 定义食谱类型接口
interface RecipeItem {
  date: string;
  name: string;
  mealType: string;
  diningType: string;
  canteen: string;
  images?: string[];
}

// 定义路由参数接口
interface RecipeRouteParams {
  editRecipe?: RecipeItem;
  editIndex?: number;
  selectedDate?: string;
}

// 定义食谱服务类
class RecipeService {
  private context: common.UIAbilityContext;
  
  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }
  
  async saveRecipe(recipe: RecipeItem): Promise<void> {
    const prefer = await preferences.getPreferences(this.context, 'myPreferences')
    const existingRecipes = await prefer.get('recipeList', '[]')
    let recipeList: RecipeItem[] = existingRecipes ? JSON.parse(existingRecipes as string) : []
    recipeList.push(recipe)
    await prefer.put('recipeList', JSON.stringify(recipeList))
    await prefer.flush()
  }
  
  async updateRecipe(recipe: RecipeItem, index: number): Promise<void> {
    const prefer = await preferences.getPreferences(this.context, 'myPreferences')
    const existingRecipes = await prefer.get('recipeList', '[]')
    let recipeList: RecipeItem[] = existingRecipes ? JSON.parse(existingRecipes as string) : []
    if (index >= 0 && index < recipeList.length) {
      recipeList[index] = recipe
      await prefer.put('recipeList', JSON.stringify(recipeList))
      await prefer.flush()
    }
  }
}

@Entry
@Component
struct Shipu {
  @State formData: RecipeItem = {
    date: '',
    name: '',
    mealType: '',
    diningType: '',
    canteen: ''
  }
  
  @State isEditMode: boolean = false
  @State editIndex: number = -1
  private context = getContext(this) as common.UIAbilityContext
  
  // 选项定义
  private mealTypes: SelectOption[] = [
    new SelectOption('早点'),
    new SelectOption('午餐'),
    new SelectOption('晚点'),
    new SelectOption('其他')
  ]
  
  private diningTypes: SelectOption[] = [
    new SelectOption('堂食'),
    new SelectOption('外卖')
  ]
  
  private canteens: SelectOption[] = [
    new SelectOption('劳芙餐厅'),
    new SelectOption('泷湖一小餐厅')
  ]
  
  // 服务对象 - 用于处理食谱数据
  private recipeService: RecipeService = new RecipeService(this.context);
  
  aboutToAppear() {
    const params = router.getParams() as RecipeRouteParams;
    
    // 判断是否是编辑模式
    if (params?.editRecipe) {
      this.isEditMode = true;
      this.editIndex = params.editIndex ?? -1;
      this.formData = JSON.parse(JSON.stringify(params.editRecipe));
    } else if (params?.selectedDate) {
      this.formData.date = params.selectedDate;
    } else {
      // 如果没有传入日期，使用当前日期
      const now = new Date();
      const year = now.getFullYear();
      const month = String(now.getMonth() + 1).padStart(2, '0');
      const day = String(now.getDate()).padStart(2, '0');
      this.formData.date = `${year}-${month}-${day}`;
    }
  }
  
  @Builder
  FormHeader(label: string, required: boolean = false) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#333333')
      if (required) {
        Text('*')
          .fontSize(16)
          .fontColor('#FF0000')
      }
    }
    .width('100%')
  }
  
  validateForm(): boolean {
    if (!this.formData.date || !this.formData.name || !this.formData.mealType || 
        !this.formData.diningType || !this.formData.canteen) {
      promptAction.showToast({
        message: '请填写必填项',
        duration: 2000
      });
      return false;
    }
    return true;
  }
  
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#000')
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          })

        Text(this.isEditMode ? '编辑食谱' : '新建食谱')
          .fontWeight(FontWeight.Bold)
          .fontSize(22)
          .textAlign(TextAlign.Center)
          .margin({ top: 18, bottom: 8 })
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')

      // 表单内容
      Scroll() {
        Column() {
          // 食谱日期
          Column() {
            this.FormHeader('食谱日期', true)
            Text(this.formData.date || '请选择日期')
              .width('100%')
              .height(40)
              .backgroundColor('#F5F5F5')
              .borderRadius(4)
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .padding({ left: 12 })
              .margin({ top: 8 })
              .onClick(() => {
                DatePickerDialog.show({
                  start: new Date("2000-1-1"),
                  end: new Date("2100-12-31"),
                  selected: this.formData.date ? new Date(this.formData.date) : new Date(),
                  onAccept: (value: DatePickerResult) => {
                    if (value.year && value.month !== undefined && value.day) {
                      const formattedDate = `${value.year}-${String(value.month + 1).padStart(2, '0')}-${String(value.day).padStart(2, '0')}`;
                      this.formData.date = formattedDate;
                    }
                  }
                });
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 食谱名称
          Column() {
            this.FormHeader('食谱名称', true)
            TextInput({ placeholder: '请输入食谱名称', text: this.formData.name })
              .width('100%')
              .height(40)
              .backgroundColor('#F5F5F5')
              .borderRadius(4)
              .fontSize(16)
              .margin({ top: 8 })
              .onChange((value: string) => {
                this.formData.name = value;
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 餐别
          Column() {
            this.FormHeader('餐别', true)
            Select(this.mealTypes)
              .value(this.formData.mealType || '请选择餐别')
              .onSelect((index: number) => {
                this.formData.mealType = this.mealTypes[index].value;
              })
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 用餐类型
          Column() {
            this.FormHeader('用餐类型', true)
            Select(this.diningTypes)
              .value(this.formData.diningType || '请选择用餐类型')
              .onSelect((index: number) => {
                this.formData.diningType = this.diningTypes[index].value;
              })
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 餐厅
          Column() {
            this.FormHeader('餐厅', true)
            Select(this.canteens)
              .value(this.formData.canteen || '请选择餐厅')
              .onSelect((index: number) => {
                this.formData.canteen = this.canteens[index].value;
              })
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')

      // 底部保存按钮
      Button(this.isEditMode ? '保存修改' : '保存')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#00C853')
        .onClick(async () => {
          if (this.validateForm()) {
            try {
              if (this.isEditMode) {
                await this.recipeService.updateRecipe(this.formData, this.editIndex);
                await promptAction.showToast({ message: '修改成功', duration: 2000 });
              } else {
                await this.recipeService.saveRecipe(this.formData);
                await promptAction.showToast({ message: '保存成功', duration: 2000 });
              }
              router.back();
            } catch (error) {
              await promptAction.showToast({ 
                message: this.isEditMode ? '修改失败，请重试' : '保存失败，请重试', 
                duration: 2000 
              });
            }
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}