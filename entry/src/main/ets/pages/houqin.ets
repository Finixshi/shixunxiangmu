import router from '@ohos.router';

@Entry
@Component
struct houqin {
  aboutToAppear() {
    // 导航到人员列表页面
    router.pushUrl({
      url: 'pages/StaffList'
    });
  }

  build() {
    Column() {
      Text('加载中...')
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
} 