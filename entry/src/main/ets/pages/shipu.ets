import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';
import http from '@ohos.net.http'
import { DatePickerResult, RecipeData as RecipeItem, RecipeRouteParams, SelectOption as TypesSelectOption, TimePickerResult } from '../common/types';
import { getRecipeService } from '../common/services/RecipeService';

// 定义Select选项类
class SelectOption {
  value: string;

  constructor(value: string) {
    this.value = value;
  }
}

// 定义用户信息接口
interface UserInfo {
  id?: string;
  username?: string;
  relTenantIds?: string;
}

// 为Result接口定义明确的结构，而不是使用索引签名
interface Result {
  // 定义具体字段，替代索引签名
  code?: number;
  data?: string | ApiData;
  userInfo?: UserInfo;
  // 其他可能的字段...
}

// 定义API数据类型
interface ApiData {
  id?: string;
  name?: string;
  code?: string | number;
  message?: string;
  values?: Array<string | number | boolean>;
  items?: Array<ApiDataItem>;
  // 其他可能的数据字段...
}

// 定义API数据项
interface ApiDataItem {
  id: string;
  name: string;
  type?: string;
  value?: string | number | boolean;
  status?: string | number;
  date?: string;
  description?: string;
}

interface ApiResponse {
  success: boolean;
  message: string;
  code: number;
  result: Result|null;
  timestamp: number;
}

// 定义食谱API请求数据接口
interface RecipeRequestData {
  id?: string;         // 添加可选的id字段用于编辑操作
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

// 定义食谱API响应接口
interface RecipeApiResponse {
  success: boolean;
  message: string;
  code: number;
  result: null;
  timestamp: number;
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
    new SelectOption('早餐'),
    new SelectOption('午餐'),
    new SelectOption('晚餐'),
    new SelectOption('其他')
  ]

  private diningTypes: SelectOption[] = [
    new SelectOption('堂食'),
    new SelectOption('外卖')
  ]

  private canteens: SelectOption[] = [
    new SelectOption('实训第一学校餐厅')
  ]

  // 服务对象 - 用于处理食谱数据
  private recipeService: RecipeService = new RecipeService(this.context);

  aboutToAppear() {
    const params = router.getParams() as RecipeRouteParams;

    // 判断是否是编辑模式
    if (params?.editRecipe) {
      this.isEditMode = true;
      this.editIndex = params.editIndex ?? -1;
      // 创建深拷贝而不使用JSON方法
      this.formData = {
        id: params.editRecipe.id,       // 保存API id用于编辑操作
        date: params.editRecipe.date || '',
        name: params.editRecipe.name || '',
        mealType: params.editRecipe.mealType || '',
        diningType: params.editRecipe.diningType || '',
        canteen: params.editRecipe.canteen || '',
        images: undefined
      };
      
      // 如果有图片数组，使用循环复制而不是扩展运算符
      if (params.editRecipe.images && Array.isArray(params.editRecipe.images)) {
        const newImages: string[] = [];
        for (let i = 0; i < params.editRecipe.images.length; i++) {
          newImages.push(params.editRecipe.images[i]);
        }
        this.formData.images = newImages;
      }
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
              // 1. 首先保存到本地存储
              if (this.isEditMode && this.editIndex >= 0) {
                // 从preferences中获取所有食谱数据
                const prefer = await preferences.getPreferences(this.context, 'myPreferences');
                const storageRecipes = await prefer.get('recipeList', '[]');
                const recipesStr: string = storageRecipes as string;
                let allRecipes: RecipeItem[] = [];
                
                // 添加类型检查，确保解析得到的是数组
                try {
                  const parsedData = JSON.parse(recipesStr) as Array<RecipeItem>;
                  if (Array.isArray(parsedData)) {
                    allRecipes = parsedData;
                  } else {
                    console.error('解析的数据不是数组:', parsedData);
                    allRecipes = [];
                  }
                } catch (error) {
                  console.error('解析食谱数据失败:', error instanceof Error ? error.message : String(error));
                  allRecipes = [];
                }
                
                // 更新指定的食谱数据
                if (this.editIndex < allRecipes.length) {
                  allRecipes[this.editIndex] = this.formData;
                  await prefer.put('recipeList', JSON.stringify(allRecipes));
                  await prefer.flush();
                  console.info('食谱更新成功(recipeList):', this.formData);
                  
                  // 关键修复：同时更新到RecipeService
                  try {
                    // 获取RecipeServiceClass的实例
                    const recipeServiceInstance = getRecipeService(this.context);
                    // 更新对应日期的食谱数据
                    await recipeServiceInstance.updateRecipe(this.formData, this.editIndex);
                    console.info('食谱更新成功(RecipeService):', this.formData);
                  } catch (serviceError) {
                    console.error('RecipeService更新失败:', serviceError instanceof Error ? serviceError.message : String(serviceError));
                    // RecipeService更新失败不影响主流程
                  }
                } else {
                  console.error('编辑索引超出范围:', this.editIndex, '总数:', allRecipes.length);
                  throw new Error('编辑索引超出范围');
                }
              } else {
                // 新建食谱
                const prefer = await preferences.getPreferences(this.context, 'myPreferences');
                const storageRecipes = await prefer.get('recipeList', '[]');
                const recipesStr: string = storageRecipes as string;
                let allRecipes: RecipeItem[] = [];
                
                // 添加类型检查，确保解析得到的是数组
                try {
                  const parsedData = JSON.parse(recipesStr) as Array<RecipeItem>;
                  if (Array.isArray(parsedData)) {
                    allRecipes = parsedData;
                  } else {
                    console.error('解析的数据不是数组:', parsedData);
                    allRecipes = [];
                  }
                } catch (error) {
                  console.error('解析食谱数据失败:', error instanceof Error ? error.message : String(error));
                  allRecipes = [];
                }
                
                allRecipes.push(this.formData);
                await prefer.put('recipeList', JSON.stringify(allRecipes));
                await prefer.flush();
                console.info('新食谱保存成功(recipeList):', this.formData);
                
                // 关键修复：同时保存到RecipeService
                try {
                  // 获取RecipeServiceClass的实例
                  const recipeServiceInstance = getRecipeService(this.context);
                  // 保存新食谱数据
                  await recipeServiceInstance.saveRecipe(this.formData);
                  console.info('新食谱保存成功(RecipeService):', this.formData);
                } catch (serviceError) {
                  console.error('RecipeService保存失败:', serviceError instanceof Error ? serviceError.message : String(serviceError));
                  // RecipeService保存失败不影响主流程
                }
              }
              
              // 2. 尝试同步到服务器（如果失败也不影响本地存储）
              try {
                const success = await this.Tv();
                console.info('服务器同步结果:', success ? '成功' : '失败');
              } catch (error) {
                console.error('服务器同步失败:', error instanceof Error ? error.message : String(error));
                // 服务器同步失败不影响本地保存结果
              }
              
              // 显示成功提示并返回
              await promptAction.showToast({
                message: this.isEditMode ? '修改成功' : '保存成功',
                duration: 2000
              });
              
              // 返回上一页
              router.back();
            } catch (error) {
              console.error('保存失败:', error instanceof Error ? error.message : String(error));
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

      const responseText: string = response.result as string;
      const jsonData: ApiResponse = JSON.parse(responseText) as ApiResponse;
      //console.log('',jsonData.result.userInfo.relTenantIds);
      return {
        success: jsonData.code === 200,
        code: jsonData.code,
        message: jsonData.message,
        result:jsonData.result,
        timestamp:jsonData.timestamp
      };
    } catch (error) {
      console.error('Login Error:', error instanceof Error ? error.message : String(error));
      return {
        success: false,
        message: '出现异常·',
        code:-1,
        result:null,
        timestamp:0
      };
    }
  }



  // 私有方法：处理用户跳转


  // 在 Shipu 组件内添加以下方法
private async Tv(): Promise<boolean> {
  let httpRequest = http.createHttp();
  
  // 根据编辑模式选择不同的API接口
  let url = this.isEditMode 
    ? 'https://api.suoeryun.com/ifood/jeecg-school/school/xxRecipeReported/edit'
    : 'https://api.suoeryun.com/ifood/jeecg-school/school/xxRecipeReported/add';
  
  console.info(`使用API接口: ${url}, 编辑模式: ${this.isEditMode}`);
  
  // 准备请求数据
  let data: RecipeRequestData = {
    id: this.isEditMode ? this.formData.id : undefined,
    recipeDate: this.formData.date,     // 使用表单日期
    startTime: this.formData.date,      // 开始时间同日期
    endTime: this.formData.date,        // 结束时间同日期
    mealCategory: this.getMealCategoryCode(this.formData.mealType), // 转换餐别代码
    dishName: this.formData.name,       // 使用表单名称
    sampleType: this.getDiningTypeCode(this.formData.diningType), // 转换用餐类型代码
    demandUnit: "1651892693627330561",
    demandUnitName: "实训第一学校餐厅",
    recipeImg: "https://admin.suoeryun.com/pcUpload/1917469119841849345_1745995237687.png",
    recipeStatus: "1"
  };
  
  console.info(`发送API数据: ${JSON.stringify(data)}`);

  try {
    let response = await httpRequest.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Tenant-Id': '10021011',
          'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
        },
        extraData: JSON.stringify(data)
      }
    );

    if (response.responseCode === 200) {
      const responseText: string = response.result as string;
      const jsonResponse: RecipeApiResponse = JSON.parse(responseText) as RecipeApiResponse;
      console.log(`API响应成功, code: ${jsonResponse.code}, message: ${jsonResponse.message}`);
      return jsonResponse.code === 200;
    } else {
      console.log('请求失败，状态码:', response.responseCode);
      return false;
    }
  } catch (error) {
    console.error('请求异常:', error instanceof Error ? error.message : String(error));
    return false;
  }
}

// 获取餐别代码
private getMealCategoryCode(mealType: string): string {
  const mealTypeMap: Record<string, string> = {
    '早餐': '0',
    '午餐': '1',
    '晚餐': '2',
    '早点': '3',
    '午点': '4', 
    '晚点': '5',
    '其他': '6'
  };
  return mealTypeMap[mealType] || '1'; // 默认为午餐
}

// 获取用餐类型代码
private getDiningTypeCode(diningType: string): string {
  const diningTypeMap: Record<string, string> = {
    '堂食': '0',
    '外卖': '1'
  };
  return diningTypeMap[diningType] || '0'; // 默认为堂食
}
}