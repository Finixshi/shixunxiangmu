@Entry
@Component
struct ruku {
  @State activeTab: number = 0; // 用于跟踪当前激活的选项卡索引
  @State message: string = '~暂无相关数据~'; // 显示的消息
  @State showSupplierPopup: boolean = false; // 控制供应商选择框显示
  @State showDatePopup: boolean = false; // 控制日期选择框显示
  private options: SelectOption[] = [
    { value: '选择供应商' },
    { value: '小杨肉食店' },
    { value: '诚信蔬菜批发门市' },
    { value: '彦红粮油有限公司' }
  ]
  @State selectedValue: string = '选择需求单位'; // 存储选中值
  private selectedDate: Date = new Date('2025-05-06');
  @State timetext: string = '选择供应日期     ';
  @State currentTabContent: string = '待收货'; // 新增状态变量，用于控制显示的内容

  build() {
    Column() {
      // 第一块：标题，使其居中
      Text('采购入库')
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Center)
        .margin({ top: 10 })
        .margin({ bottom: 20 });

      // 第二块：选项卡
      Row() {
        Text('待收货')
          .fontSize(12)
          .fontWeight(this.activeTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .width('20%')
          .maxLines(1)
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentTabContent = '待收货';
            this.activeTab = 0;
          });

        Text('未配送')
          .fontSize(12)
          .fontWeight(this.activeTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .width('20%')
          .maxLines(1)
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentTabContent = '未配送';
            this.activeTab = 1;
          });

        Text('已收货')
          .fontSize(12)
          .fontWeight(this.activeTab === 2 ? FontWeight.Bold : FontWeight.Normal)
          .width('20%')
          .maxLines(1)
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentTabContent = '已收货';
            this.activeTab = 2;
          });

        Text('已拒收')
          .fontSize(12)
          .fontWeight(this.activeTab === 3 ? FontWeight.Bold : FontWeight.Normal)
          .width('20%')
          .maxLines(1)
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentTabContent = '已拒收';
            this.activeTab = 3;
          });

        Text('已取消')
          .fontSize(12)
          .fontWeight(this.activeTab === 4 ? FontWeight.Bold : FontWeight.Normal)
          .width('20%')
          .maxLines(1)
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentTabContent = '已取消';
            this.activeTab = 4;
          });
      }
      .width('100%')
      .margin({ left: 10, right: 10 })
      .margin({ bottom: 20 });

      // 第三块：选择供应商和供应日期
      Row() {
        Select(this.options)
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
          .border({ width: 0, color: '#DDD' });

        Row() {
          Text(this.timetext)
            .alignSelf(ItemAlign.End)
            .textAlign(TextAlign.End)
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-1-1"),
                end: new Date("2100-12-31"),
                selected: this.selectedDate,
                onAccept: (value: DatePickerResult) => {
                  if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                    this.selectedDate.setFullYear(value.year, value.month, value.day);
                    const formattedDate = `${value.year.toString().padStart(4, '0')}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`;
                    this.timetext = formattedDate;
                  } else {
                    console.error('DatePickerResult 中的年、月或日属性未定义');
                  }
                },
                onCancel: () => {
                  console.info("DatePickerDialog:onCancel()");
                },
                onChange: (value: DatePickerResult) => {
                  if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                    console.info("DatePickerDialog:onChange()" + JSON.stringify(value));
                  } else {
                    console.error('DatePickerResult 中的年、月或日属性未定义');
                  }
                }
              });
            })
            .width('50%')
            .fontWeight(1);
        }
      }
      .width('100%')
      .margin({ bottom: 20 });

      // 根据 currentTabContent 显示对应的 Column，并支持滚动
      if (this.currentTabContent === '待收货') {
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
      } else if (this.currentTabContent === '未配送') {
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
      } else if (this.currentTabContent === '已收货') {
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
      } else if (this.currentTabContent === '已拒收') {
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
      } else if (this.currentTabContent === '已取消') {
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
