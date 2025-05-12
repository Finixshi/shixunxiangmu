import router from '@ohos.router';

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
      Row() {
        Text('<')
          .alignSelf(ItemAlign.Start) // 保持在行的最左侧
          .fontSize(30)
          .margin({ top: 0, bottom: 10, right: 130})
          .onClick(() => {
            router.back()
          });

        Text('实时库存')
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Center) // 居中显示
          .margin({ top: 0, bottom: 10 });
      }
      .width('100%') // 确保 Row 占据全部宽度

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
            Stack() {
              Column() {
                Row() {
                  Text('诚信蔬菜批发门市')
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')
                  Blank()
                  Text('订单信息二维码 >')
                    .fontSize(14)
                    .fontColor('#1BBE6C')
                }
                .width('100%')
                .padding({ bottom: 8 })

                Text('下单时间：2025-05-07 15:08:45')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })
                Text('供应时间：2025-05-21 上午')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })
                Text('需求单位：实训第一学校(库房)')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })
                Text('单据号：RK20250507001')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })
                Text('入库类型：学生餐')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })
                Text('用餐类型：营养餐')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })
                Text('餐别：其他')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })
                Text('供应商联系人：李诚信')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })
                Row() {
                  Text('供应商电话：18991274263')
                    .fontSize(14)
                    .fontColor('#666')
                  Text('📞')
                    .fontSize(16)
                    .fontColor('#1BBE6C')
                    .margin({ left: 4 })
                }
                .margin({ top: 4 })
                Text('摘要：无')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })

                Row() {
                  Text('→')
                    .fontSize(24)
                    .fontColor('#1BBE6C')
                    .backgroundColor('#E8F7F0')
                    .width(40)
                    .height(40)
                    .textAlign(TextAlign.Center)
                    .borderRadius(20)
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/rukuyanshou',
                        params: {
                          orderId: 'RK20250507001'
                        }
                      })
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.End)
                .margin({ top: 12 })
              }
              .padding(16)
              .backgroundColor('#F8FFFA')
              .borderRadius(12)
              .border({ width: 1, color: '#1BBE6C' })
              .margin({ left: 16, right: 16, top: 16, bottom: 16 })
            }
          }
          .width('100%')
          .height('100%')
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
