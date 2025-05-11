import router from '@ohos.router';
import { peicanjilu as ImportedRecordType } from './peicanjilu';

// 现在可以使用 ImportedRecordType 而不是 RecordType
const myRecord: ImportedRecordType = {
  date: '',
  unit: '',
  meal: '',
  position: '',
  name: '',
  evaluation: ''
};
interface RecordType {
  date: string;
  unit: string;
  meal: string;
  position: string;
  name: string;
  evaluation: string;
}
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
  @State name: string = '';        // 陪餐人姓名
  @State evaluation: string = '';
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
            console.info(`提交单位：${this.selectedPosition}`)
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

      Button('提交')
        .onClick(() => {
          const record: RecordType = {
            date: this.selectedDate,
            unit: this.selectedUnit,
            meal: this.selectedMeal,
            position: this.selectedPosition,
            name: this.name,
            evaluation: this.evaluation
          };
          console.log('即将传递的陪餐记录数据:', record);
          router.pushUrl({
            url: 'pages/DatePickerPage',
            params: record
          });
          // 如果有前往 'pages/peicanjilu' 的需求，也在此处处理
          // router.pushUrl({
          //   url: 'pages/peicanjilu',
          //   params: {
          //     mealDate: this.dates,
          //     submitUnit: this.selectedUnit,
          //     mealType: this.selectedMeal,
          //     attendantPosition: this.selectedPosition
          //   }
          // });
        })
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
        const month = value.month?? new Date().getMonth() ;
        const day = value.day?? new Date().getDate();
        this.selectDate = new Date(year, month , day);
        this.dates = `${year}-${(month + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
        this.selectedDate = this.dates; // 新增赋值逻辑
      }
    });
  }
}