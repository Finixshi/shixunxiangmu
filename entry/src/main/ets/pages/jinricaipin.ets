import router from '@ohos.router';
import { getRecipeService } from '../common/services/RecipeService';
import { RecipeData, SelectOption } from '../common/types';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import http from '@ohos.net.http'

// 定义API响应中食谱记录的类型
interface ApiRecipeRecord {
  id: string;
  recipeDate: string;  // 食谱日期
  mealCategory: string; // 餐别代码
  sampleType: string;  // 用餐类型代码
  dishName: string;    // 食谱名称
  demandUnitName: string; // 餐厅名称
  recipeImg: string;   // 食谱图片
  recipeStatus: string; // 状态
  // 其他API可能返回的字段
}

// API分页响应类型
interface ApiPageResult {
  records: ApiRecipeRecord[];
  total: number;
  size: number;
  current: number;
  pages: number;
}

// 接口响应类型
interface ApiResponse {
  success: boolean;
  code: number;
  message: string;
  result: ApiPageResult | null;
  timestamp: number;
}

@Entry
@Component
struct JinRiCaiPin {
  @State private recipes: RecipeData[] = [];
  @State private selectedDate: string = '';
  @State private selectedMealType: string = '全部';
  @State private isLoading: boolean = false;
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private recipeService = getRecipeService(this.context);

  private mealTypes: SelectOption[] = [
    { value: '全部' },
    { value: '早餐' },
    { value: '午餐' },
    { value: '晚餐' }
  ];

  aboutToAppear() {
    // 设置默认日期为今天
    const now = new Date();
    this.selectedDate = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
    this.loadRecipes();
  }

  async loadRecipes() {
    this.isLoading = true;
    try {
      // 1. 先从本地获取食谱数据
      const localRecipes = await this.recipeService.getRecipesByDate(this.selectedDate);
      
      // 2. 从API获取最新食谱数据并同步
      await this.fetchRecipesFromApi(this.selectedDate);
      
      // 3. 再次从本地获取数据(已包含API同步的数据)
      let updatedRecipes = await this.recipeService.getRecipesByDate(this.selectedDate);
      
      // 4. 添加从recipeList中获取数据的逻辑
      try {
        const prefer = await preferences.getPreferences(this.context, 'myPreferences');
        const storageValue = await prefer.get('recipeList', '[]');
        const recipesStr: string = typeof storageValue === 'string' ? storageValue : String(storageValue);
        const allRecipes = JSON.parse(recipesStr) as RecipeData[];
        
        // 如果allRecipes是数组，则过滤出当前日期的食谱
        if (Array.isArray(allRecipes)) {
          const dateRecipes = allRecipes.filter(recipe => recipe.date === this.selectedDate);
          if (dateRecipes.length > 0) {
            console.info(`从recipeList中找到 ${dateRecipes.length} 条当日食谱`);
            // 合并数据，避免重复
            dateRecipes.forEach(recipeItem => {
              // 检查是否已存在相同食谱
              const existingIndex = updatedRecipes.findIndex(
                r => r.name === recipeItem.name && 
                     r.mealType === recipeItem.mealType &&
                     r.diningType === recipeItem.diningType
              );
              
              if (existingIndex === -1) {
                // 不存在则添加
                updatedRecipes.push(recipeItem);
              }
            });
          }
        }
      } catch (error) {
        console.error('获取recipeList数据失败:', error instanceof Error ? error.message : String(error));
        // 获取失败不影响主流程
      }
      
      // 5. 根据餐别筛选数据
      this.recipes = updatedRecipes.filter(recipe => {
        return this.selectedMealType === '全部' || recipe.mealType === this.selectedMealType;
      });
      
      // 6. 按日期倒序排列，最新的显示在前面
      this.recipes.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
      console.info('筛选后的列表:', JSON.stringify(this.recipes));
    } catch (error) {
      console.error('加载食谱失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({
        message: '加载失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 从API获取食谱数据
  private async fetchRecipesFromApi(date: string) {
    try {
      const httpRequest = http.createHttp();
      // API URL
      const url = `https://api.suoeryun.com/ifood/jeecg-school/school/xxRecipeReported/list?recipeDate=${date}`;
      
      // 添加日志调试
      console.info(`获取食谱API URL: ${url}`);
      
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
          }
        }
      );
      
      // 打印响应信息
      console.info(`获取食谱API响应状态码: ${response.responseCode}`);
      if (response.result) {
        console.info(`获取食谱API响应数据: ${response.result.toString().substring(0, 200)}...`);
      }
      
      if (response.responseCode === 200) {
        // 使用条件判断确认类型而不是直接断言
        const responseValue = response.result;
        const responseText: string = typeof responseValue === 'string' ? responseValue : String(responseValue);
        const apiResponse: ApiResponse = JSON.parse(responseText);
        
        // 打印API响应
        console.info(`API响应成功: ${apiResponse.success}, 代码: ${apiResponse.code}`);
        
        if (apiResponse.success && apiResponse.result && Array.isArray(apiResponse.result.records)) {
          // 打印获取到的记录数
          console.info(`获取到 ${apiResponse.result.records.length} 条食谱记录`);
          
          // 将API返回的数据转换为应用内的数据格式
          const apiRecipes = apiResponse.result.records.map(item => this.convertApiRecipeToLocal(item));
          
          // 保存到本地存储
          await this.saveApiRecipesToLocal(date, apiRecipes);
        } else {
          console.info('API返回成功，但没有找到食谱记录');
        }
      }
    } catch (error) {
      console.error('从API获取食谱数据失败:', error instanceof Error ? error.message : String(error));
    }
  }

  // 将API返回的食谱数据转换为本地格式
  private convertApiRecipeToLocal(apiRecipe: ApiRecipeRecord): RecipeData {
    // 餐别映射
    const mealCategoryMap: Record<string, string> = {
      '0': '早餐',
      '1': '午餐',
      '2': '晚餐',
      '3': '早点',
      '4': '午点',
      '5': '晚点',
      '6': '其他'
    };
    
    // 用餐类型映射
    const sampleTypeMap: Record<string, string> = {
      '0': '堂食',
      '1': '外卖'
    };
    
    return {
      id: apiRecipe.id,     // 保存API返回的id值
      date: apiRecipe.recipeDate || this.selectedDate,
      name: apiRecipe.dishName || '',
      mealType: mealCategoryMap[apiRecipe.mealCategory || '1'] || '午餐',
      diningType: sampleTypeMap[apiRecipe.sampleType || '0'] || '堂食',
      canteen: apiRecipe.demandUnitName || '实训第一学校餐厅',
      images: apiRecipe.recipeImg ? [apiRecipe.recipeImg] : []
    };
  }

  // 保存API食谱数据到本地
  private async saveApiRecipesToLocal(date: string, apiRecipes: RecipeData[]) {
    if (apiRecipes.length === 0) {
      return;
    }
    
    try {
      // 使用RecipeService更新API数据
      await this.recipeService.updateRecipesFromApi(date, apiRecipes);
      console.info(`已同步 ${apiRecipes.length} 条食谱数据到本地`);
    } catch (error) {
      console.error('保存API食谱数据到本地失败:', error instanceof Error ? error.message : String(error));
    }
  }

  async deleteRecipe(index: number) {
    AlertDialog.show({
      title: '删除确认',
      message: '确定要删除该食谱吗？',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('取消删除');
        }
      },
      secondaryButton: {
        value: '删除',
        action: async () => {
          try {
            // 获取当前要删除的食谱
            const recipe = this.recipes[index];
            console.info('尝试删除食谱:', JSON.stringify(recipe));
            
            // 从preferences中获取所有食谱
            const prefer = await preferences.getPreferences(this.context, 'myPreferences');
            const storageRecipes = await prefer.get('recipeList', '[]');
            // 使用条件判断确认类型而不是直接断言
            const storageValue = storageRecipes;
            const storageStr: string = typeof storageValue === 'string' ? storageValue : String(storageValue);
            console.info('获取到的食谱列表:', storageStr.substring(0, 100) + '...');
            
            let allRecipes: RecipeData[] = [];
            
            try {
              const parsedData = JSON.parse(storageStr) as Array<RecipeData>;
              if (Array.isArray(parsedData)) {
                allRecipes = parsedData;
                console.info(`解析到 ${allRecipes.length} 条食谱数据`);
              }
            } catch (error) {
              console.error('解析数据失败:', error instanceof Error ? error.message : String(error));
              promptAction.showToast({ message: '删除失败，数据格式错误' });
              return;
            }
            
            // 添加更宽松的比较方式，只比较关键字段
            const realIndex = allRecipes.findIndex(item => {
              const dateMatch = item.date === recipe.date;
              const nameMatch = item.name === recipe.name;
              const mealTypeMatch = item.mealType === recipe.mealType;
              
              console.info(`比较: ${item.date}/${recipe.date}, ${item.name}/${recipe.name}, ${item.mealType}/${recipe.mealType}`);
              
              // 只需要匹配日期、名称和餐别即可
              return dateMatch && nameMatch && mealTypeMatch;
            });
            
            console.info('找到食谱在列表中的索引:', realIndex);
            
            if (realIndex !== -1) {
              // 删除食谱
              allRecipes.splice(realIndex, 1);
              
              // 保存更新后的数组到recipeList
              await prefer.put('recipeList', JSON.stringify(allRecipes));
              await prefer.flush();
              console.info('从recipeList删除食谱成功');
              
              // 同时使用RecipeService删除
              try {
                // 首先尝试通过ID删除
                if (recipe.id) {
                  console.info(`尝试通过ID删除食谱，ID: ${recipe.id}`);
                  const success = await this.recipeService.deleteRecipeById(recipe.date, recipe.id);
                  if (success) {
                    console.info('通过ID删除食谱成功');
                  } else {
                    console.error('通过ID删除食谱失败，尝试其他方法');
                    
                    // 尝试通过名称删除
                    console.info(`尝试通过名称删除食谱，名称: ${recipe.name}`);
                    const nameSuccess = await this.recipeService.deleteRecipeByName(recipe.date, recipe.name);
                    if (nameSuccess) {
                      console.info('通过名称删除食谱成功');
                    } else {
                      // 最后尝试通过索引删除
                      // 首先获取RecipeService中该日期的所有食谱
                      const dateRecipes = await this.recipeService.getRecipesByDate(recipe.date);
                      console.info(`RecipeService中找到${dateRecipes.length}条当日食谱`);
                      
                      // 使用更宽松的比较方式
                      const serviceIndex = dateRecipes.findIndex(item => 
                        item.name === recipe.name && item.mealType === recipe.mealType
                      );
                      
                      console.info('RecipeService中找到的索引:', serviceIndex);
                      
                      if (serviceIndex !== -1) {
                        // 如果找到则删除
                        await this.recipeService.deleteRecipe(recipe.date, serviceIndex);
                        console.info('从RecipeService删除食谱成功');
                      } else {
                        console.info('在RecipeService中未找到对应食谱，跳过删除');
                      }
                    }
                  }
                } else {
                  // 没有ID，直接尝试通过名称删除
                  const nameSuccess = await this.recipeService.deleteRecipeByName(recipe.date, recipe.name);
                  if (nameSuccess) {
                    console.info('通过名称删除食谱成功');
                  } else {
                    // 首先获取RecipeService中该日期的所有食谱
                    const dateRecipes = await this.recipeService.getRecipesByDate(recipe.date);
                    console.info(`RecipeService中找到${dateRecipes.length}条当日食谱`);
                    
                    // 使用更宽松的比较方式
                    const serviceIndex = dateRecipes.findIndex(item => 
                      item.name === recipe.name && item.mealType === recipe.mealType
                    );
                    
                    console.info('RecipeService中找到的索引:', serviceIndex);
                    
                    if (serviceIndex !== -1) {
                      // 如果找到则删除
                      await this.recipeService.deleteRecipe(recipe.date, serviceIndex);
                      console.info('从RecipeService删除食谱成功');
                    } else {
                      console.info('在RecipeService中未找到对应食谱，跳过删除');
                    }
                  }
                }
              } catch (serviceError) {
                console.error('从RecipeService删除食谱失败:', serviceError instanceof Error ? serviceError.message : String(serviceError));
                // RecipeService删除失败不影响主流程
              }
              
              // 更新当前显示的食谱列表
              this.recipes.splice(index, 1);
              
              // 尝试同步删除到API
              await this.deleteRecipeFromApi(recipe);
              
              promptAction.showToast({ message: '删除成功' });
            } else {
              console.error('未找到要删除的食谱，尝试直接删除当前显示的食谱');
              
              // 直接更新当前显示的食谱列表
              this.recipes.splice(index, 1);
              
              // 尝试从RecipeService中删除
              try {
                const dateRecipes = await this.recipeService.getRecipesByDate(recipe.date);
                // 使用更宽松的比较方式
                const serviceIndex = dateRecipes.findIndex(item => 
                  item.name === recipe.name
                );
                
                if (serviceIndex !== -1) {
                  await this.recipeService.deleteRecipe(recipe.date, serviceIndex);
                  console.info('从RecipeService直接删除食谱成功');
                  promptAction.showToast({ message: '删除成功' });
                } else {
                  console.error('在RecipeService中也未找到对应食谱');
                  promptAction.showToast({ message: '删除可能不完全，请刷新列表' });
                }
              } catch (error) {
                console.error('直接删除失败:', error instanceof Error ? error.message : String(error));
                promptAction.showToast({ message: '删除不完全，请刷新列表' });
              }
            }
          } catch (error) {
            console.error('删除失败:', error instanceof Error ? error.message : String(error));
            promptAction.showToast({ message: '删除失败' });
          }
        }
      }
    });
  }

  // 调用API删除食谱记录
  private async deleteRecipeFromApi(recipe: RecipeData) {
    try {
      // 如果有id则调用API删除
      if (recipe.id) {
        console.info(`尝试从API删除食谱，ID: ${recipe.id}, 名称: ${recipe.name}`);
        
        const httpRequest = http.createHttp();
        const url = `https://api.suoeryun.com/ifood/jeecg-school/school/xxRecipeReported/delete?id=${recipe.id}`;
        
        const response = await httpRequest.request(
          url,
          {
            method: http.RequestMethod.DELETE,
            header: {
              'Content-Type': 'application/json',
              'Tenant-Id': '10021011',
              'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
            }
          }
        );
        
        console.info(`API删除响应: ${response.responseCode}`);
        if (response.responseCode === 200) {
          // 使用条件判断确认类型而不是直接断言
          const responseValue = response.result;
          const responseText: string = typeof responseValue === 'string' ? responseValue : String(responseValue);
          const result: ApiResponse = JSON.parse(responseText);
          console.info(`API删除结果: ${JSON.stringify(result)}`);
          return true;
        } else {
          console.error(`API删除失败，状态码: ${response.responseCode}`);
        }
      } else {
        console.info('食谱没有ID，跳过API删除');
      }
      return false;
    } catch (error) {
      console.error('从API删除食谱失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
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
        Blank()
        Text('今日菜品')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF');

      // 筛选条件
      Row() {
        Column() {
          Select(this.mealTypes)
            .value(this.selectedMealType)
            .selectedOptionFont({ size: 16, weight: FontWeight.Regular })
            .optionFont({ size: 16, weight: FontWeight.Regular })
            .fontColor('#333333')
            .onSelect((index: number) => {
              this.selectedMealType = this.mealTypes[index].value;
              this.loadRecipes();
            })
        }
        .layoutWeight(1)
        .padding(10)

        Column() {
          Text('请选择筛选日期 ▼')
            .fontSize(16)
            .fontColor('#333333')
            .onClick(() => {
              DatePickerDialog.show({
                selected: new Date(this.selectedDate),
                onAccept: (value) => {
                  if (value.year && value.month !== undefined && value.day) {
                    this.selectedDate = `${value.year}-${String(value.month + 1).padStart(2, '0')}-${String(value.day).padStart(2, '0')}`;
                    this.loadRecipes();
                  }
                }
              });
            })
        }
        .layoutWeight(1)
        .padding(10)
      }
      .width('100%')
      .backgroundColor('#FFFFFF');

      // 内容区域
      Column() {
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#00C853')
            Text('加载中...')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 16 })
          }
          .width('100%')
          .height('60%')
          .justifyContent(FlexAlign.Center)
        } else if (this.recipes.length === 0) {
          Column() {
            Text('暂无相关数据')
              .fontSize(16)
              .fontColor('#999999');
          }
          .width('100%')
          .height('60%')
          .justifyContent(FlexAlign.Center);
        } else {
          List() {
            ForEach(this.recipes, (recipe: RecipeData, index: number) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(`食谱日期：${recipe.date}`)
                      .fontSize(16)
                      .fontColor('#333333');
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 });

                  Row() {
                    Text(`食谱名称：${recipe.name}`)
                      .fontSize(16)
                      .fontColor('#333333');
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 });

                  Row() {
                    Text(`餐    别：${recipe.mealType}`)
                      .fontSize(16)
                      .fontColor('#333333');
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 });

                  Row() {
                    Text(`用餐类型：${recipe.diningType}`)
                      .fontSize(16)
                      .fontColor('#333333');
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 });

                  Row() {
                    Text(`餐    厅：${recipe.canteen}`)
                      .fontSize(16)
                      .fontColor('#333333');
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 });

                  if (recipe.images && recipe.images.length > 0) {
                    Row() {
                      ForEach(recipe.images, (image: string) => {
                        Image(image)
                          .width(80)
                          .height(80)
                          .margin(5)
                          .borderRadius(8);
                      });
                    }
                    .width('100%')
                    .padding({ top: 8, bottom: 8 });
                  }

                  Row() {
                    Button('重新编辑')
                      .fontSize(14)
                      .fontColor('#00C853')
                      .backgroundColor('#FFFFFF')
                      .borderRadius(16)
                      .borderWidth(1)
                      .borderColor('#00C853')
                      .margin({ right: 16 })
                      .onClick(() => {
                        router.pushUrl({
                          url: 'pages/shipu',
                          params: {
                            editRecipe: recipe,
                            editIndex: index
                          }
                        });
                      });

                    Button('删除单据')
                      .fontSize(14)
                      .fontColor('#FF0000')
                      .backgroundColor('#FFFFFF')
                      .borderRadius(16)
                      .borderWidth(1)
                      .borderColor('#FF0000')
                      .onClick(() => {
                        this.deleteRecipe(index);
                      });
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                  .padding({ top: 16, bottom: 8 });
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .margin({ bottom: 16 })
                .border({ width: 1, color: '#00C853' });
              }
            });
          }
          .width('100%')
          .padding(16);
        }
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5');

      // 底部按钮
      Button('新建食谱')
        .width('90%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#00C853')
        .margin({ bottom: 16 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/shipu',
            params: {
              selectedDate: this.selectedDate
            }
          });
        });
    }
    .width('100%')
    .height('100%');
  }
  
  // 页面显示时刷新数据
  onPageShow() {
    this.loadRecipes();
  }
}
