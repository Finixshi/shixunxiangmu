import router from '@ohos.router';

@Entry
@Component
struct Page1 {
  @State selectedPosition: string = '';
  @State selectedUnit: string = '';
  @State selectedMeal: string = '';
  @State date: string = '选择日期';
  @State selectedDate: string = '请选择陪餐日期';
  @State selectDate: Date = new Date();
  @State dates: string = '请选择';
  private unitOptions = [
    '实训第一中学',
    '实训第二中学',
    '实训第三中学'
  ];
  private mealOptions = [
    '早餐',
    '午餐',
    '晚餐'
  ];

  build() {
    Column() {
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          })
        Text('上传陪餐记录')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF');
      Row() {
        Text("陪餐日期")
        Select([])
          .onClick(() => {
            this.showDateDialog()
          })
          .value(this.dates)
          .margin(10)
          .width('70%')
      }
      Row() {
        Text("提交单位")
        Select(this.unitOptions.map<SelectOption>((item: string) => ({ value: item })))
          .value('请选择')
          .value(this.selectedUnit)
          .onSelect((index: number) => {
            this.selectedUnit = this.unitOptions[index];
          })
          .margin(10)
          .width('70%')
      }
      Row() {
        Text("陪餐餐别")
        Select(this.mealOptions.map<SelectOption>((item: string) => ({ value: item })))
          .value('请选择')
          .value(this.selectedMeal)
          .onSelect((index: number) => {
            this.selectedMeal = this.mealOptions[index];
          })
          .margin(10)
          .width('70%')
      }
      Row() {
        Text("陪餐人职务")
        Select([
          { value: '教师' },
          { value: '家长' },
          { value: '中层领导' },
          { value: '校领导' },
        ] as SelectOption[])
          .value(this.selectedPosition)
          .onSelect((index: number) => {
            this.selectedPosition = index.toString();
          })
          .margin(10)
          .width('70%')
      }
      Button({ type: ButtonType.Normal })
      {
        Text("提交")
          .margin({ top: 1, bottom: 1 })
          .fontColor(Color.White)
          .width('90%')
          .height(40)
          .textAlign(TextAlign.Center)
      }
      .width('90%')
      .height(40)
      .margin({ top: 250 })
      .borderRadius(5)
      .backgroundColor(Color.Green)
      .onClick(() => {
        router.pushUrl({
          url: 'pages/peicanjilu',
          params: {
            mealDate: this.dates,
            submitUnit: this.selectedUnit,
            mealType: this.selectedMeal,
            attendantPosition: this.selectedPosition
          }
        });
      })
    }
    .width('100%')
    .height('100%')
  }

  private showDateDialog() {
    DatePickerDialog.show({
      start: new Date('2000-1-1'),
      end: new Date('2100-1-1'),
      selected: this.selectDate,
      onAccept: (value: DatePickerResult) => {
        const year = value.year?? new Date().getFullYear();
        const month = value.month?? new Date().getMonth() + 1;
        const day = value.day?? new Date().getDate();

      }
    });
  }
}