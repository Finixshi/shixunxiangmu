import { router } from '@kit.ArkUI'

interface ImageCount {
  url: string
  count: number
  text: string
  route: string
}

@Entry
@Component
struct Chenjian1Page {
  @State image: ImageCount[] = [
    { url: 'app.media.zuo', count: 0, text: '返回', route: 'pages/chenjian' }
  ]

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r(this.image[0].url))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            try {
              router.pushUrl({
                url: 'pages/chenjian'
              })
            } catch (error) {
              console.error('路由跳转失败：', error)
            }
          })
        Text('未晨检人员')
          .fontSize(18)
          .fontColor('#ffffffff')
          .margin({ left: 85 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#00C853')

      // 主要内容区域
      Column() {
        Blank()
        Text('~暂无相关数据~')
          .fontSize(15)
          .fontColor('#BBBBBB')
        Blank()
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
