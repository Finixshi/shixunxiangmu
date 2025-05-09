import router from '@ohos.router';
import { getRecipeService } from '../common/services/RecipeService';
import { RecipeData, SelectOption, DatePickerResult, RecipeRouteParams } from '../common/types';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct ShiPu {
  @State private formData: RecipeData = {
    date: '',
    name: '',
    mealType: '',
    diningType: '',
    canteen: '',
    images: []
  };
  @State private isEditMode: boolean = false;
  private editIndex: number = -1;
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private recipeService = getRecipeService(this.context);

  private mealTypes: SelectOption[] = [
    { value: '早点' },
    { value: '午餐' },
    { value: '晚点' },
    { value: '其他' }
  ];

  private diningTypes: SelectOption[] = [
    { value: '不区分' },
    { value: '教工餐' },
    { value: '学生餐' }
  ];

  private canteens: SelectOption[] = [
    { value: '劳芙餐厅' },
    { value: '泷湖一小餐厅' }
  ];

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
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          })
        Text(this.isEditMode ? '编辑食谱' : '新建食谱')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 表单内容
      Scroll() {
        Column() {
          // 食谱日期
          Column() {
            this.FormHeader('食谱日期', true)
            Row() {
              Text(this.formData.date)
                .fontSize(16)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .margin({ top: 8 })
            .onClick(() => {
              DatePickerDialog.show({
                selected: new Date(this.formData.date),
                onAccept: (value: DatePickerResult) => {
                  if (value.year && value.month !== undefined && value.day) {
                    const date = `${value.year}-${String(value.month + 1).padStart(2, '0')}-${String(value.day).padStart(2, '0')}`
                    this.formData.date = date
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
            TextInput({ placeholder: '请输入食谱名称' })
              .fontSize(16)
              .backgroundColor('#F5F5F5')
              .width('100%')
              .height(48)
              .margin({ top: 8 })
              .onChange((value: string) => {
                this.formData.name = value
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
              .value(this.formData.mealType)
              .onSelect((index: number) => {
                this.formData.mealType = this.mealTypes[index].value
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
              .value(this.formData.diningType)
              .onSelect((index: number) => {
                this.formData.diningType = this.diningTypes[index].value
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
              .value(this.formData.canteen)
              .onSelect((index: number) => {
                this.formData.canteen = this.canteens[index].value
              })
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 图片上传区域
          Column() {
            this.FormHeader('上传图片')
            Row() {
              ForEach(new Array(3).fill(0), () => {
                Column() {
                  Text('+')
                    .fontSize(40)
                    .fontColor('#999999')
                }
                .width(100)
                .height(100)
                .margin(8)
                .backgroundColor('#F5F5F5')
                .justifyContent(FlexAlign.Center)
              })
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ top: 12 })
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
  }
}