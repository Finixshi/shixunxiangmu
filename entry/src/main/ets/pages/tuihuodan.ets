import router from '@ohos.router';

@Entry
@Component
struct tuihuo {
  @State activeTab: number = 0; // 默认选择 "未知晓" 的索引
  @State message: string = '~暂无相关数据~'; // 显示的消息
  @State showSupplierPopup: boolean = false; // 控制供应商选择框显示
  @State showDatePopup: boolean = false; // 控制日期选择框显示
  private Options: SelectOption[] = [
    { value: '请选择学校' },
    { value: '' }
  ];

  @State selectedValue: string = '请选择学校'; // 存储选中值
  private selectedDate: Date = new Date('2021-08-08')
  @State timetext:string='选择供应日期'
  @State currentTabContent: string = '未知晓'; // 新增状态变量，用于控制显示的内容

  build() {
    Column() {
      Row() {
        Text('<')
          .alignSelf(ItemAlign.Start) // 保持在行的最左侧
          .fontSize(30)
          .margin({ top: 0, bottom: 10, right: 135})
          .onClick(() => {
            router.back()
          });

        Text('退货单')
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Center) // 居中显示
          .margin({ top: 0, bottom: 10 });
      }
      .width('100%') // 确保 Row 占据全部宽度

      // 第二块：选项卡
      Row() {
        Text('未知晓')
          .fontSize(15)
          .fontWeight(this.activeTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .width('50%')
          .maxLines(1)
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentTabContent = '未知晓';
            this.activeTab = 0;
          });

        Text('已知晓')
          .fontSize(15)
          .fontWeight(this.activeTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .width('50%')
          .maxLines(1)
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentTabContent = '已知晓';
            this.activeTab = 1;
          });

      }
      .width('100%')
      .margin({ left: 10, right: 10 })
      .margin({ bottom: 20 });

      // 第三块：选择供应商和供应日期
      Row() {
        Select(this.Options)
          .selected(0)
          .value(this.selectedValue)
          .onSelect((index: number, value: string) => {
            this.selectedValue = value;
          })
          .alignSelf(ItemAlign.Start)
          .width("50%")
          .fontColor('#333')
          .backgroundColor('#FFF')
          .borderRadius(8)
          .border({ width: 0, color: '#DDD'})

        Text(this.timetext)
          .onClick(() => {
            DatePickerDialog.show({
              start: new Date("2000-1-1"),
              end: new Date("2100-12-31"),
              selected: this.selectedDate,
              onAccept: (value: DatePickerResult) => {
                if (value.year!== undefined && value.month!== undefined && value.day!== undefined) {
                  // 通过Date的setFullYear方法设置按下确定按钮时的日期，这样当弹窗再次弹出时显示选中的是上一次确定的日期
                  this.selectedDate.setFullYear(value.year, value.month, value.day);
                  // 格式化日期为年-月-日格式
                  const formattedDate = `${value.year.toString().padStart(4, '0')}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`;
                  console.info("DatePickerDialog:onAccept()" + JSON.stringify(value));
                  // 这里假设你有一个变量来显示日期，例如 this.text
                  this.timetext = formattedDate;
                } else {
                  console.error('DatePickerResult 中的年、月或日属性未定义');
                }
              },
              onCancel: () => {
                console.info("DatePickerDialog:onCancel()");
              },
              onChange: (value: DatePickerResult) => {
                if (value.year!== undefined && value.month!== undefined && value.day!== undefined) {
                  console.info("DatePickerDialog:onChange()" + JSON.stringify(value));
                } else {
                  console.error('DatePickerResult 中的年、月或日属性未定义');
                }
              }
            });
          })
          .position({x:220,y:9})
          .width('50%')
          .fontWeight(1)
      }
      .width('90%')
      .margin({ bottom: 20 });

      // 根据 currentTabContent 显示对应的 Column，并支持滚动
      if (this.currentTabContent === '未知晓') {
        Scroll() {
          Column() {
            Text('~暂无相关数据~')
              .fontSize(16)
              .fontWeight(FontWeight.Normal)
              .alignSelf(ItemAlign.Center);
          }
          .backgroundColor(0xCCCCCC)
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);
        }
      } else if (this.currentTabContent === '已知晓') {
        Scroll() {
          Column() {
            Text('~暂无相关数据~')
              .fontSize(16)
              .fontWeight(FontWeight.Normal)
              .alignSelf(ItemAlign.Center);
          }
          .backgroundColor(0xCCCCCC)
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);
        }
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.White);
  }
}