import router from '@ohos.router';
import { getRecipeService } from '../common/services/RecipeService';
import { RecipeData } from '../common/types';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct JinRiCaiPin {
  @State private recipes: RecipeData[] = [];
  @State private selectedDate: Date = new Date();
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private recipeService = getRecipeService(this.context);

  aboutToAppear() {
    this.loadRecipes();
  }

  async loadRecipes() {
    const date = this.formatDate(this.selectedDate);
    this.recipes = await this.recipeService.getRecipesByDate(date);
  }

  private formatDate(date: Date): string {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
  }

  @Builder
  private HeaderBuilder() {
    Row() {
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          })
        Text('今日菜品')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF');
  }

  @Builder
  private DateSelector() {
    Row() {
      Text('请选择筛选日期')
        .fontSize(16)
        .fontColor('#333333')
      Blank()
      Text(this.formatDate(this.selectedDate))
        .fontSize(16)
        .fontColor('#666666')
        .onClick(() => {
          DatePickerDialog.show({
            selected: this.selectedDate,
            onAccept: (value) => {
              this.selectedDate = new Date(value.year, value.month, value.day);
              this.loadRecipes();
            }
          });
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 8 });
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
        action: () => {
          this.recipeList.splice(index, 1)
          AppStorage.Set<string>('recipeList', JSON.stringify(this.recipeList))
          promptAction.showToast({ message: '删除成功' })
        }
      }
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Stack({ alignContent: Alignment.Start }) {
          Text('今日菜品')
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: 18, bottom: 8 })

          Text('←')
            .fontSize(24)
            .fontColor('#000')
            .margin({ left: 16, top: 18 })
            .onClick(() => {
              router.back()
            })
        }
        .width('100%')
        // 筛选栏
        Row() {
          Select(this.options)
            .selected(0)
            .value(this.selectedValue)
            .onSelect((index: number, value: string) => {
              this.selectedValue = value
            })
            .width("48%")
            .fontColor('#333')
            .backgroundColor('#FFF')
            .borderRadius(8)
            .border({ width: 0, color: '#DDD' })

          Text(this.timeText)
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-1-1"),
                end: new Date("2100-12-31"),
                selected: this.selectedDate,
                onAccept: (value: DatePickerResult) => {
                  if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                    this.selectedDate.setFullYear(value.year, value.month, value.day);
                    const formattedDate = `${value.year.toString().padStart(4, '0')}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`;
                    this.timeText = formattedDate;
                  }
                }
              });
            })
            .width('48%')
            .fontWeight(1)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .padding({ left: 12, right: 12, bottom: 10 })

  @Builder
  private RecipeList() {
    Column() {
      if (this.recipes.length === 0) {
        Text('暂无相关数据')
          .fontSize(14)
          .fontColor('#999999');
      } else {
        List() {
          ForEach(this.recipes, (recipe: RecipeData, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  Text(`食谱日期：${recipe.date}`)
                    .fontSize(14)
                    .fontColor('#666666');
                }
                Row() {
                  Text(`食谱名称：${recipe.name}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold);
                }
                Row() {
                  Text(`餐别：${recipe.mealType}`)
                    .fontSize(14)
                    .fontColor('#666666');
                }
                Row() {
                  Text(`用餐类型：${recipe.diningType}`)
                    .fontSize(14)
                    .fontColor('#666666');
                }
                Row() {
                  Text(`餐厅：${recipe.canteen}`)
                    .fontSize(14)
                    .fontColor('#666666');
                }
                Row() {
                  Button('重新编辑')
                    .fontSize(14)
                    .fontColor('#00C853')
                    .backgroundColor('#FFFFFF')
                    .borderRadius(16)
                    .borderWidth(1)
                    .borderColor('#00C853')
                    .margin({ right: 8 })
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
                    .onClick(async () => {
                      AlertDialog.show({
                        title: '删除确认',
                        message: '确定要删除该食谱记录吗？',
                        primaryButton: {
                          value: '取消',
                          action: () => {
                            // 取消操作，不做任何事
                          }
                        },
                        secondaryButton: {
                          value: '确认',
                          action: async () => {
                            try {
                              await this.recipeService.deleteRecipe(recipe.date, index);
                              await promptAction.showToast({ message: '删除成功', duration: 2000 });
                              this.loadRecipes();
                            } catch (error) {
                              await promptAction.showToast({ message: '删除失败，请重试', duration: 2000 });
                            }
                          }
                        }
                      });
                    });
                }
                .margin({ top: 8 });
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(8);
            }
            .margin({ bottom: 8 });
          });
        }
        .width('100%');
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#F5F5F5')
    .padding(16);
  }

  build() {
    Column() {
      this.HeaderBuilder();
      this.DateSelector();
      this.RecipeList();

      Button('新建食谱')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#00C853')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/shipu',
            params: {
              selectedDate: this.formatDate(this.selectedDate)
            }
          });
        });
    }
    .width('100%')
    .height('100%');
  }
}