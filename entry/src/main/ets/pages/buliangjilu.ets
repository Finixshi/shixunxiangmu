import router from '@ohos.router';
@Entry
@Component
struct NoDataPage {
  onBack() {
    router.back();
  }

  build() {
    Column() {
      Row() {
        Text('~ 暂无相关数据 ~')
          .fontSize(18)
          .fontColor('#999999')
          .position({ x: 110, y: -150 })
        Button('返回')
          .width('80')
          .height('50')
          .backgroundColor('#ccc')
          .position({ x: 270, y: 200 })
          .onClick(() => {
            this.onBack();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
