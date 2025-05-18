import router from '@ohos.router';

@Entry
@Component
struct SupplyRange {
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('供应范围')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor('#FFFFFF')
          .margin({ left: 40 })
        Text('...')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width(24)
          .height(30)
          .margin({ right: 16 })
          .fontColor('#FFFFFF')
        Image($r('app.media.zuo'))
          .width(24)
          .height(24)
          .position({ x: '8%', y: '30%' })
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#000000')

      // 学校列表
      Scroll() {
        Column() {
          // 第一个学校
          this.schoolItem('1.实训第二学校', '无', '无')
          
          // 第二个学校
          this.schoolItem('2.实训第一学校', '无', '无')
          
          // 留出底部空间
          Blank()
            .height(80)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .backgroundColor('#F5F7FA')
      
      // 底部返回按钮
      Stack() {
        Circle()
          .width(56)
          .height(56)
          .fill('#2D8CF0')

        Image($r('app.media.zuo'))
          .width(22)
          .height(22)
          .fillColor('#FFFFFF')
      }
      .width(56)
      .height(56)
      .position({ x: '85%', y: '85%' })
      .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.2)', offsetX: 2, offsetY: 4 })
      .onClick(() => {
        router.back();
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
  
  @Builder
  schoolItem(name: string, manager: string, contact: string) {
    Column() {
      Text(name)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 16 })
        .alignSelf(ItemAlign.Start)
        .fontColor('#333333')
      
      // 分隔线
      Divider()
        .strokeWidth(1)
        .color('#f2f2f2')
        .margin({ bottom: 16 })
      
      Row() {
        Row() {
          // 使用文本代替图标
          Text('📦')
            .fontSize(16)
            .margin({ right: 8 })
          
          Text('库    管：')
            .fontSize(16)
            .fontColor('#666666')
        }
        .width(100)
        
        Text(manager)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Normal)
      }
      .width('100%')
      .margin({ bottom: 16 })
      .alignItems(VerticalAlign.Center)
      
      Row() {
        Row() {
          // 使用文本代替图标
          Text('📱')
            .fontSize(16)
            .margin({ right: 8 })
          
          Text('联系方式：')
            .fontSize(16)
            .fontColor('#666666')
        }
        .width(100)
        
        Text(contact)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Normal)
      }
      .width('100%')
      .margin({ bottom: 16 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 5, bottom: 5 })
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ top: 16 })
    .shadow({ radius: 6, color: 'rgba(0, 0, 0, 0.06)', offsetX: 0, offsetY: 2 })
  }
} 