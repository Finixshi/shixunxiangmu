import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct NewProductApply {
  @State currentTab: number = 0;
  private tabTitles: string[] = ['草稿', '待审批', '已审批', '已驳回'];

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
        
        Column() {
          Text('新品申购')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .fontColor('#000000')
            
          Text('phone.suoeryun.com')
            .fontSize(12)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        
        // 菜单图标
        Text('...')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .fontColor('#000000')
      }
      .width('100%')
      .height(80)
      .backgroundColor('#FFFFFF')
      .padding({ right: 16 })
      
      // 选项卡导航
      Row() {
        ForEach(this.tabTitles, (title: string, index: number) => {
          Column() {
            Text(title)
              .fontSize(16)
              .fontColor(this.currentTab === index ? '#10C469' : '#999999')
              .padding({ top: 12, bottom: 12 })
            
            // 下方绿色指示条
            if (this.currentTab === index) {
              Divider()
                .width('80%')
                .strokeWidth(3)
                .color('#10C469')
            }
          }
          .width('25%')
          .onClick(() => {
            this.currentTab = index;
          })
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      
      // 内容区域 - 暂无数据
      Stack() {
        Column() {
          Text('~ 暂无相关数据 ~')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 200 })
        }
        .width('100%')
        .height('100%')
        
        // 右下角返回按钮
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.zuo'))
            .width(24)
            .height(24)
        }
        .width(56)
        .height(56)
        .backgroundColor('#CCCCCC')
        .opacity(0.8)
        .position({ x: '85%', y: '85%' })
        .onClick(() => {
          router.back();
        })
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      
      // 底部按钮
      Button('新建新品申购')
        .width('90%')
        .height(50)
        .backgroundColor('#10C469')
        .borderRadius(4)
        .fontSize(18)
        .fontColor('#FFFFFF')
        .margin({ bottom: 20 })
        .onClick(() => {
          // 跳转到新建页面
          router.pushUrl({
            url: 'pages/CreateNewProduct'
          });
        })
      
      // 底部导航
      Row() {
        Image($r('app.media.zuo'))
          .width(24)
          .height(24)
          .rotate({ z: 1, angle: 180 })
          .margin({ right: 150 })
        
        Image($r('app.media.zuo'))
          .width(24)
          .height(24)
          .rotate({ z: 1, angle: 0 })
      }
      .width('100%')
      .height(50)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
} 