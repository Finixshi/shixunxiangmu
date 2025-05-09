import router from '@ohos.router'
import { getSampleService } from '../common/services/SampleService'
import { SampleFormData } from '../common/types'
import promptAction from '@ohos.promptAction'
import common from '@ohos.app.ability.common'


@Entry
@Component
struct CalendarPage {
  @State private currentDate: Date = new Date()
  @State private selectedDate: Date = new Date()
  @State private samples: SampleFormData[] = []
  private weekDays: string[] = ['一', '二', '三', '四', '五', '六', '日']
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext
  private sampleService = getSampleService(this.context)

  aboutToAppear() {
    this.loadSamples()
  }

  async loadSamples() {
    const date = this.formatDate(this.selectedDate)
    this.samples = await this.sampleService.getSamplesByDate(date)
  }

  private formatDate(date: Date): string {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
  }

  private getDatesForWeek(): number[] {
    const firstDayOfMonth = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), 1)
    const lastDayOfMonth = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 0)
    const selectedWeek = Math.floor((this.selectedDate.getDate() - 1) / 7)
    const startDate = new Date(firstDayOfMonth)
    startDate.setDate(selectedWeek * 7 + 1)

    const dates: number[] = []
    for (let i = 0; i < 7; i++) {
      const currentDate = new Date(startDate)
      currentDate.setDate(startDate.getDate() + i)
      if (currentDate <= lastDayOfMonth) {
        dates.push(currentDate.getDate())
      } else {
        dates.push(i + 1)
      }
    }
    return dates
  }

  private changeWeek(increment: number) {
    const newDate = new Date(this.selectedDate)
    newDate.setDate(this.selectedDate.getDate() + (increment * 7))

    // 更新月份和年份
    this.currentDate = new Date(newDate)
    this.selectedDate = newDate
    this.loadSamples()
  }

  @Builder
  private HeaderBuilder() {
    Row() {
      Text('每日留样')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ left: 16 })
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  private CalendarHeaderBuilder() {
    Row() {
      Text(`${this.currentDate.getFullYear()}年${this.currentDate.getMonth() + 1}月`)
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
      Blank()
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .margin({ right: 20 })
          .onClick(() => this.changeWeek(-1))
        Text('>')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .onClick(() => this.changeWeek(1))
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#00C853')
  }

  @Builder
  private WeekDaysBuilder() {
    Row() {
      ForEach(this.weekDays, (day: string) => {
        Text(day)
          .fontSize(14)
          .width('14.28%')
          .textAlign(TextAlign.Center)
          .fontColor('#FFFFFF')
      })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  private SampleListBuilder() {
    Column() {
      if (this.samples.length === 0) {
        Text('暂无相关数据')
          .fontSize(14)
          .fontColor('#999999')
      } else {
        List() {
          ForEach(this.samples, (sample: SampleFormData, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text(sample.mealType)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Text(`${sample.foodName || '-'} · ${sample.weight}克`)
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Row() {
                  Button('编辑')
                    .fontSize(14)
                    .fontColor('#00C853')
                    .backgroundColor('#FFFFFF')
                    .borderRadius(16)
                    .borderWidth(1)
                    .borderColor('#00C853')
                    .margin({ right: 8 })
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/SampleForm',
                        params: {
                          selectedDate: this.formatDate(this.selectedDate),
                          editSample: sample,
                          editIndex: index
                        }
                      })
                    })
                  Button('删除')
                    .fontSize(14)
                    .fontColor('#FF0000')
                    .backgroundColor('#FFFFFF')
                    .borderRadius(16)
                    .borderWidth(1)
                    .borderColor('#FF0000')
                    .onClick(async () => {
                      AlertDialog.show({
                        title: '删除确认',
                        message: '确定要删除该留样记录吗？',
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
                              await this.sampleService.deleteSample(this.formatDate(this.selectedDate), index)
                              await promptAction.showToast({ message: '删除成功', duration: 2000 })
                              this.loadSamples()
                            } catch (error) {
                              await promptAction.showToast({ message: '删除失败，请重试', duration: 2000 })
                            }
                          }
                        }
                      })
                    })
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
            }
            .margin({ bottom: 8 })
          })
        }
        .width('100%')
        .padding(16)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#F5F5F5')
  }

  build() {
    Column() {
      this.HeaderBuilder()

      this.CalendarHeaderBuilder()

      Column() {
        this.WeekDaysBuilder()

        Row() {
          ForEach(this.getDatesForWeek(), (date: number) => {
            Column() {
              Stack() {
                if (date === this.selectedDate.getDate()) {
                  Circle()
                    .width(40)
                    .height(40)
                    .fill('#FFFFFF')
                }
                Text(`${date < 10 ? '0' : ''}${date}`)
                  .fontSize(18)
                  .fontColor(date === this.selectedDate.getDate() ? '#00C853' : '#FFFFFF')
              }
            }
            .width('14.28%')
            .height(50)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              const newDate = new Date(this.selectedDate)
              newDate.setDate(date)
              this.selectedDate = newDate
              this.loadSamples()
            })
          })
        }
        .width('100%')
        .padding({ bottom: 16 })
      }
      .width('100%')
      .backgroundColor('#00C853')

      this.SampleListBuilder()

      Button('新增留样')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#00C853')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SampleForm',
            params: {
              selectedDate: this.formatDate(this.selectedDate)
            }
          })
        })
    }
    .width('100%')
    .height('100%')
  }
} 