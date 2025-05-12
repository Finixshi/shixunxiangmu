import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';
import http from '@ohos.net.http'

// 定义Select选项类
class SelectOption {
  value: string;

  constructor(value: string) {
    this.value = value;
  }
}

interface ApiResponse {
  success: boolean;
  message: string;
  code: number;
  result: Result|null;
  timestamp: number;
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
  @State private responseCode: number = 0;
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
    new SelectOption('实训第一学校餐厅'),
    new SelectOption('实训第二学校餐厅')
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
              } else {
                await this.recipeService.saveRecipe(this.formData);
              }
              router.back();
              const success = await this.Tv();
              if (success) {
                await promptAction.showToast({
                  message: this.isEditMode ? '修改成功' : '保存成功',
                  duration: 2000
                });
              }
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


  private async executeshipu(): Promise<ApiResponse> {
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        'https://api.suoeryun.com/ifood//jeecg-school/school/xxRecipeReported/add',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            'X-Access-Token':'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiIyZjg5NWM4NDI2MWFlNzJiYmUyMjVkMjllOWJhZjVjZCIsImV4cCI6MTc0NzUzOTM4NSwidXNlcm5hbWUiOiIxNTUwMjkzMzY3MyJ9.H3G_Um8fR4uMTNAYyD0tMZ2xwl-CDjkh4eNFgeS1BRo'
          },
          extraData: JSON.stringify({
            "recipeDate": this.formData,
            "startTime": this.formData,
            "endTime": this.formData,
            "mealCategory": "0",
            "dishName": "鱼香牛至",
            "sampleType": "0",
            "demandUnit": "1651892693627330561",
            "demandUnitName": "浐灞一小餐厅",
            "recipeImg": "https://admin.suoeryun.com/pcUpload/1917469119841849345_1745995237687.png",
            "recipeStatus": "1"
          })
        }
      );
      if (response.responseCode !== 200) {
        return {
          success: false,
          message: `HTTP Error: ${response.responseCode}`,
          code: 0,
          result: null,
          timestamp: 0
          // 添加其他错误处理逻辑
        };
      }

      const jsonData = JSON.parse(response.result as string) as ApiResponse;
      //console.log('',jsonData.result.userInfo.relTenantIds);
      return {
        success: jsonData.code === 200,
        code: jsonData.code,
        message: jsonData.message,
        result:jsonData.result,
        timestamp:jsonData.timestamp
      };
    } catch (error) {
      console.error('Login Error:', JSON.stringify(error));
      return {
        success: false,
        message: '出现异常·',
        code:-1,
        result:null,
        timestamp:0
      };
    }
  }//自己的接口请求逻辑



  // 私有方法：处理用户跳转


  // 在 Shipu 组件内添加以下方法
private async Tv(): Promise<boolean> {
  let httpRequest = http.createHttp();

  interface Data {
    recipeDate: string;
    startTime: string;
    endTime: string;
    mealCategory: string;
    dishName: string;
    sampleType: string;
    demandUnit: string;
    demandUnitName: string;
    recipeImg: string;
    recipeStatus: string;
  }

  interface TvResponse {
    success: boolean;
    message: string;
    code: number;
    result: null;
    timestamp: number;
  }

  let url = 'https://api.suoeryun.com/ifood/jeecg-school/school/xxRecipeReported/add';
  let data: Data = {
    recipeDate: this.formData.date,     // 使用表单日期
    startTime: this.formData.date,      // 开始时间同日期
    endTime: this.formData.date,        // 结束时间同日期
    mealCategory: "0",
    dishName: this.formData.name,       // 使用表单名称
    sampleType: "0",
    demandUnit: "1651892693627330561",
    demandUnitName: "实训第二学校餐厅",
    recipeImg: "https://admin.suoeryun.com/pcUpload/1917469119841849345_1745995237687.png",
    recipeStatus: "1"
  };

  try {
    let response = await httpRequest.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Tenant-Id': '10021011',
          'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiIyZjg5NWM4NDI2MWFlNzJiYmUyMjVkMjllOWJhZjVjZCIsImV4cCI6MTc0NzUzOTM4NSwidXNlcm5hbWUiOiIxNTUwMjkzMzY3MyJ9.H3G_Um8fR4uMTNAYyD0tMZ2xwl-CDjkh4eNFgeS1BRo'
        },
        extraData: JSON.stringify(data)
      }
    );

    if (response.responseCode === 200) {
      const jsonResponse = JSON.parse(response.result as string) as TvResponse;
      console.log('响应 code:', jsonResponse.code);
      return jsonResponse.code === 200;
    } else {
      console.log('请求失败，状态码:', response.responseCode);
      return false;
    }
  } catch (error) {
    console.error('请求异常:', error);
    return false;
  }
}



    }