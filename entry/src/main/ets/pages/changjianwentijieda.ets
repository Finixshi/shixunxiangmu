import router from '@ohos.router';

@Entry
@Component
struct ChangJianWenTiJieJue {
  @State faqItems: string[] = [
    '电脑端需求上报',
    '手机端需求上报',
    '电脑端确认收货',
    '手机端确认收货',
    '收货时如何临时调整订单食材',
    '电脑端如何出库',
    '手机端如何出库'
  ]

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .margin({ right: 16 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/shouye',
              params: {
                currentIndex: 3  // 3对应"我的"界面
              }
            })
          })
        Text('常见问题解答')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // FAQ列表
      List() {
        ForEach(this.faqItems, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(`${index + 1}. ${item}`)
                .fontSize(16)
                .fontColor('#333333')
              Text('>')
                .fontSize(20)
                .fontColor('#999999')
            }
            .width('100%')
            .height(64)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Color.White)
          }
          .onClick(() => {
            // 处理点击事件
          })
        })
      }
      .width('100%')
      .margin({ top: 1 })
      .divider({ strokeWidth: 1, color: '#F5F5F5' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 