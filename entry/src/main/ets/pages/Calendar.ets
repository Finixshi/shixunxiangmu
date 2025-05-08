import router from '@ohos.router'

@Entry
@Component
struct CalendarPage {
  @State currentYear: number = 2025
  @State currentMonth: number = 5
  @State selectedDate: number = 7
  @State weekDays: string[] = ['一', '二', '三', '四', '五', '六', '日']
  @State dates: number[] = [5, 6, 7, 8, 9, 10, 11]

  build() {
    Column() {
      // 顶部年月显示
      Row() {
        Text(`${this.currentYear}年${this.currentMonth}月`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        Blank()
        Row() {
          Text('<')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .margin({ right: 20 })
            .onClick(() => {
              // 处理上个月
            })
          Text('>')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .onClick(() => {
              // 处理下个月
            })
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#00C853')

      // 星期栏
      Row() {
        ForEach(this.weekDays, (day: string) => {
          Text(day)
            .fontSize(16)
            .width('14.28%')
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .padding({ top: 10, bottom: 10 })
      .backgroundColor('#00C853')

      // 日期显示
      Row() {
        ForEach(this.dates, (date: number) => {
          Column() {
            Text(`${date}`)
              .fontSize(16)
              .width(40)
              .height(40)
              .textAlign(TextAlign.Center)
              .borderRadius(20)
              .backgroundColor(date === this.selectedDate ? '#FFFFFF' : 'transparent')
              .fontColor(date === this.selectedDate ? '#00C853' : '#FFFFFF')
          }
          .width('14.28%')
          .justifyContent(FlexAlign.Center)
        })
      }
      .width('100%')
      .backgroundColor('#00C853')

      // 空白区域显示
      Column() {
        Text('暂无相关数据')
          .fontSize(16)
          .fontColor('#999999')
      }
      .width('100%')
      .height('60%')
      .backgroundColor('#F5F5F5')
      .justifyContent(FlexAlign.Center)

      // 底部按钮
      Button('新增留样')
        .width('90%')
        .height(50)
        .backgroundColor('#00C853')
        .margin({ bottom: 20 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SampleForm'
          })
        })
    }
    .width('100%')
    .height('100%')
  }
} 