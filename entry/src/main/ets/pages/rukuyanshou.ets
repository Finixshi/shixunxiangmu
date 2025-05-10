import router from '@ohos.router';

@Entry
@Component
struct RuKuYanShou {
  @State selectedDate: string = '2025-05-07'

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            router.back()
          })
        Text('入库验收')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
        Blank()
        Text('...')
          .fontSize(24)
          .fontColor('#333')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // 黑白斜纹装饰条
      Row()
        .width('100%')
        .height(8)
        .backgroundColor('#F5F5F5')

      Scroll() {
        Column() {
          // 订单信息
          Column() {
            Text('订单信息(RK20250507001)')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })
            Text('下单时间：2025-05-07 15:08:45')
              .fontSize(14)
              .margin({ top: 4 })
            Text('供应时间：2025-05-21 上午')
              .fontSize(14)
              .margin({ top: 4 })
            Text('供应商：诚信蔬菜批发门市')
              .fontSize(14)
              .margin({ top: 4 })
            Text('需求单位：实训第一学校(库房)')
              .fontSize(14)
              .margin({ top: 4 })
            Text('入库类型：学生餐')
              .fontSize(14)
              .margin({ top: 4 })
            Text('用餐类型：营养餐')
              .fontSize(14)
              .margin({ top: 4 })
            Text('餐别：其他')
              .fontSize(14)
              .margin({ top: 4 })
            Text('摘要：无')
              .fontSize(14)
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 12 })

          // 添加食材按钮
          Button('+ 添加食材')
            .width('90%')
            .height(40)
            .backgroundColor('#1BBE6C')
            .margin({ top: 8, bottom: 8 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/tianjiashicai' })
            })

          Text('已选中4种食材')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 8, bottom: 8 })

          // 食材卡片 - 南瓜
          Column() {
            Row() {
              Text('南瓜')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
              Blank()
              Text('🗑️')
                .fontSize(20)
                .fontColor('#999')
            }
            .width('100%')

            Row() {
              Text('生产日期：')
                .fontSize(14)
                .fontColor('#666')
              Select([{ value: this.selectedDate }])
                .selected(0)
                .value(this.selectedDate)
                .margin({ right: 8 })
            }
            .margin({ top: 8 })

            Row() {
              Column() {
                Text('收货数量：')
                  .fontSize(14)
                  .fontColor('#666')
                TextInput({ text: '2', placeholder: '请输入' })
                  .width(120)
                  .type(InputType.Number)
                Text('斤')
                  .fontSize(14)
                  .fontColor('#666')
              }

              Column() {
                Text('收货数量：')
                  .fontSize(14)
                  .fontColor('#666')
                TextInput({ text: '1', placeholder: '请输入' })
                  .width(120)
                  .type(InputType.Number)
                Text('Kg')
                  .fontSize(14)
                  .fontColor('#666')
              }
            }
            .margin({ top: 8 })
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('采购价：')
                .fontSize(14)
                .fontColor('#666')
              TextInput({ text: '5.96', placeholder: '请输入' })
                .width(120)
                .type(InputType.Number)
              Text('元/Kg')
                .fontSize(14)
                .fontColor('#666')
            }
            .margin({ top: 8 })

            Row() {
              Text('检验报告')
                .fontSize(14)
                .fontColor('#666')
              Blank()
              Text('0/6')
                .fontSize(14)
                .fontColor('#999')
            }
            .margin({ top: 8 })

            Row() {
              Text('📷')
                .fontSize(32)
                .margin({ right: 8 })
            }
            .margin({ top: 8 })

            Text('合计：5.96元')
              .fontSize(16)
              .fontColor('#333')
              .margin({ top: 12 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 12 })
        }
        .width('100%')
      }
      .layoutWeight(1)

      // 底部操作栏
      Row() {
        Column() {
          Text('总计：28.64元')
            .fontSize(16)
            .fontColor('#333')
            .margin({ bottom: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16 })

        Button('拒绝收货')
          .height(40)
          .backgroundColor('#FF4D4F')
          .margin({ right: 8 })

        Button('电子秤')
          .height(40)
          .backgroundColor('#1BBE6C')
          .margin({ right: 8 })

        Button('确认收货')
          .height(40)
          .backgroundColor('#1BBE6C')
      }
      .width('100%')
      .padding(12)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 