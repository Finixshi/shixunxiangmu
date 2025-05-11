import router from '@ohos.router';

@Entry
@Component
struct Page1 {
  @State selectedPosition: string = '';
  @State selectedUnit: string = '';
  @State selectedMeal: string = '';
  @State date: string = '选择日期';
  @State selectedDate: string = '请选择陪餐日期'; // 用于展示选择的日期
  @State selectDate: Date = new Date();
  @State dates: string = '请选择'; // 用于存储选择的日期，也用于传递
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
  // 新增：职务选项列表
  private positionOptions = [
    '教师',
    '家长',
    '中层领导',
    '校领导'
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
          .padding(16)
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
          .value(this.selectedDate) // 使用selectedDate展示
          .onClick(() => {
            this.showDateDialog()
          })
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
        // 修改：直接使用职务选项列表
        Select(this.positionOptions.map<SelectOption>((item: string) => ({ value: item })))
          .value(this.selectedPosition)
          .onSelect((index: number) => {
            // 修改：直接更新为选项的值
            this.selectedPosition = this.positionOptions[index];
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
        this.selectDate = new Date(year, month - 1, day);
        this.dates = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
        this.selectedDate = this.dates; // 新增赋值逻辑
      }
    });
  }
}