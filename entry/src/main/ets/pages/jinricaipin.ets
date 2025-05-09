import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

// 定义食谱类型接口
interface RecipeItem {
  date: string;
  name: string;
  type: string;
  mealType: string;
  canteen: string;
}

@Entry
@Component
struct JinriCaipin {
  @State selectedValue: string = '请选择餐别'
  @State timeText: string = '请选择筛选日期 ▼'
  private selectedDate: Date = new Date()
  @State recipeList: RecipeItem[] = []

  private options: SelectOption[] = [
    { value: '其他' },
    { value: '早餐' },
    { value: '午餐' },
    { value: '晚餐' }
  ]

  aboutToAppear() {
    this.getRecipeList()
  }

  onPageShow() {
    this.getRecipeList()
  }

  private getRecipeList() {
    try {
      let storageRecipes = AppStorage.Get<string>('recipeList')
      console.info('获取的原始数据:', storageRecipes)
      if (storageRecipes) {
        this.recipeList = JSON.parse(storageRecipes)
        // 按日期倒序排列，最新的显示在前面
        this.recipeList.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
        console.info('解析后的列表:', JSON.stringify(this.recipeList))
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
        Row(){
          Text('←')
            .fontSize(24)
            .fontColor('#000')
            .margin({ left: 16 })
            .onClick(() => {
              router.back()
            })
          Text('今日菜品')
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
            .textAlign(TextAlign.Center)
            .margin({ top: 18, bottom: 8 })
            .width('100%')
        }
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

        // 中间内容区域
        Column() {
          if (this.recipeList.length === 0) {
            Column() {
              Text('~ 暂无相关数据 ~')
                .fontSize(15)
                .fontColor('#BBBBBB')
            }
            .width('100%')
            .height('80%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#F5F5F5')
          } else {
            List() {
              ForEach(this.recipeList, (item: RecipeItem, index: number) => {
                ListItem() {
                  Column() {
                    Row() {
                      Text('食谱日期：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(item.date)
                        .fontSize(16)
                        .fontColor('#333')
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row() {
                      Text('食谱名称：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(item.name)
                        .fontSize(16)
                        .fontColor('#333')
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row() {
                      Text('餐    别：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(item.type)
                        .fontSize(16)
                        .fontColor('#333')
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row() {
                      Text('用餐类型：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(item.mealType)
                        .fontSize(16)
                        .fontColor('#333')
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row() {
                      Text('餐    厅：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(item.canteen)
                        .fontSize(16)
                        .fontColor('#333')
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row({ space: 20 }) {
                      Button('重新编辑')
                        .backgroundColor(Color.White)
                        .fontColor(Color.Green)
                        .border({
                          width: 1,
                          color: Color.Green
                        })
                        .onClick(() => {
                          router.pushUrl({
                            url: 'pages/shipu',
                            params: { recipe: item, index: index }
                          })
                        })

                      Button('删除单据')
                        .backgroundColor(Color.White)
                        .fontColor(Color.Green)
                        .border({
                          width: 1,
                          color: Color.Green
                        })
                        .onClick(() => this.deleteRecipe(index))
                    }
                    .margin({ top: 10 })
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFF')
                  .border({
                    width: 1,
                    color: '#4CAF50',
                    style: BorderStyle.Solid
                  })
                  .borderRadius(8)
                }
                .margin({ bottom: 10 })
              })
            }
            .width('100%')
            .padding(10)
          }
        }
        .width('100%')
        .backgroundColor('#F5F5F5')
        .flexGrow(1)
      }
      .width('100%')
      .height('100%')

      // 底部新建食谱按钮
      Column() {
        Button('新建食谱', { type: ButtonType.Normal })
          .width('90%')
          .height(44)
          .backgroundColor(Color.Green)
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(8)
          .margin({ bottom: 24 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/shipu'
            });
          })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding({ top: 8 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}