import router from '@ohos.router';

@Entry
@Component
struct DatePickerPage {
  @State currentDate: Date = new Date()
  @State selectedDate: string = '请选择供应日期'
  @State selectDate: Date = new Date()

  private getThisWeekDates(): Array<Date> {
    const start = new Date(this.currentDate)
    start.setDate(start.getDate() - start.getDay() + 1) // 周一

    const dates: Date[] = []
    for (let i = 0; i < 7; i++) {
      const d = new Date(start)
      d.setDate(start.getDate() + i)
      dates.push(d)
    }
    return dates
  }

  private showDateDialog() {
    DatePickerDialog.show({
      start: new Date('2000-1-1'),
      end: new Date('2100-1-1'),
      selected: this.selectDate,
      onAccept: (value: DatePickerResult) => {
        // 使用可选链和默认值保证安全性
        const year = value.year?? new Date().getFullYear()
        const month = value.month?? new Date().getMonth()
        const day = value.day?? new Date().getDate()

        // 不需要再减1
        this.selectDate = new Date(year, month, day)
        this.selectedDate = `${year}-${(month + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
      }
    })
  }

  build() {
    Column({ space: 20 }) {
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          })
        Text('陪餐记录')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF');

      // 日期横排选择
      Row({ space: 10 }) {
        Select([])
          .value(this.selectedDate)
          .onClick(() => {
            this.showDateDialog()
          })
          .margin(10)
          .width('90%')
          .height(70)
          .font({ size: 20 })
      }
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: 20 })

      // 数据展示区
      Column() {
        Text('~ 暂无相关数据 ~')
          .fontSize(16)
          .fontColor(Color.Gray)
          .padding(20)
      }
      .alignItems(HorizontalAlign.Center)
      .height('50%')

      // 上传按钮
      Button('上传陪餐记录')
        .fontSize(18)
        .backgroundColor('#2BB673')
        .fontColor(Color.White)
        .borderRadius(10)
        .width('80%')
        .onClick(() => {
          router.pushUrl({ url: 'pages/shangchuanpeican' })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}