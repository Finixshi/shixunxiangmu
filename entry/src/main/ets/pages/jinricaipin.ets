import router from '@ohos.router';
import { getRecipeService } from '../common/services/RecipeService';
import { RecipeData, SelectOption } from '../common/types';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import http from '@ohos.net.http'
@Entry
@Component
struct JinRiCaiPin {
  @State private recipes: RecipeData[] = [];
  @State private selectedDate: string = '';
  @State private selectedMealType: string = '请选择餐别';
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private recipeService = getRecipeService(this.context);

  private mealTypes: SelectOption[] = [
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
    // 使用preferences代替PersistentStorage
    this.getRecipeList();
  }

  private async getRecipeList() {
    try {
      const prefer = await preferences.getPreferences(this.context, 'myPreferences')
      const storageRecipes = await prefer.get('recipeList', '[]')
      console.info('获取的原始数据:', storageRecipes)
      if (storageRecipes) {
        this.recipes = JSON.parse(storageRecipes as string)
        // 按日期倒序排列，最新的显示在前面
        this.recipes.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
        console.info('解析后的列表:', JSON.stringify(this.recipes))
      }
    } catch (error) {
      console.error('获取数据失败:', error)
    }
  }

  private deleteRecipe(index: number) {
    AlertDialog.show({
      title: '删除确认',
      message: '确定要删除该食谱吗？',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('取消删除')
        }
      },
      secondaryButton: {
        value: '删除',
        action: async () => {
          this.recipes.splice(index, 1)
          try {
            const prefer = await preferences.getPreferences(this.context, 'myPreferences')
            await prefer.put('recipeList', JSON.stringify(this.recipes))
            await prefer.flush()
            promptAction.showToast({ message: '删除成功' })
          } catch (error) {
            console.error('删除失败:', error)
            promptAction.showToast({ message: '删除失败' })
          }
        }
      }
    })
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
        if (this.recipes.length === 0) {
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
}
