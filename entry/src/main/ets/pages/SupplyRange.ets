import router from '@ohos.router';

@Entry
@Component
struct SupplyRange {
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.zuo'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })
        
        Text('供应范围')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor('#FFFFFF')
        
        // 更多选项图标
        Text('...')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(56)
      .backgroundColor('#000000')
      
      // 网站地址
      Text('phone.suoeryun.com')
        .fontSize(14)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      
      // 学校列表
      Scroll() {
        Column() {
          // 第一个学校
          this.schoolItem('1.实训第二学校', '无', '无')
          
          // 第二个学校
          this.schoolItem('2.实训第一学校', '无', '无')
          
          // 可以继续添加更多学校
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .backgroundColor('#F2F2F2')
      
      // 底部返回按钮
      Stack() {
        Circle()
          .width(60)
          .height(60)
          .fill('#CCCCCC')
          .opacity(0.8)
          
        Image($r('app.media.zuo'))
          .width(24)
          .height(24)
      }
      .width(60)
      .height(60)
      .position({ x: '85%', y: '85%' })
      .onClick(() => {
        router.back();
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F2')
  }
  
  @Builder
  schoolItem(name: string, manager: string, contact: string) {
    Column() {
      Text(name)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 10 })
        .alignSelf(ItemAlign.Start)
      
      Row() {
        Text('库    管：')
          .fontSize(16)
          .fontColor('#666666')
          .width(100)
        
        Text(manager)
          .fontSize(16)
          .fontColor('#666666')
      }
      .width('100%')
      .margin({ bottom: 8 })
      .alignItems(VerticalAlign.Center)
      
      Row() {
        Text('联系方式：')
          .fontSize(16)
          .fontColor('#666666')
          .width(100)
        
        Text(contact)
          .fontSize(16)
          .fontColor('#666666')
      }
      .width('100%')
      .margin({ bottom: 16 })
      .alignItems(VerticalAlign.Center)
    }
    .width('95%')
    .padding({ left: 20, right: 20 })
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ top: 10 })
  }
} 