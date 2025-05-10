import router from '@ohos.router';


@Entry
@Component
struct TianJiaShiCai {
  @State searchText: string = ''
  @State selectedCount: number = 5

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
        Text('添加食材')
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

      // 分类和搜索
      Column() {
        Row() {
          Text('全部分类')
            .fontSize(16)
            .fontColor('#333')
          Text('▼')
            .fontSize(14)
            .fontColor('#333')
            .margin({ left: 4 })
        }
        .margin({ top: 12, bottom: 12 })

        TextInput({ text: this.searchText, placeholder: '搜索商品名称' })
          .width('90%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .placeholderColor('#999999')
          .onChange((value: string) => {
            this.searchText = value
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // 食材列表
      List() {
        ListItem() {
          Column() {
            Row() {
              Text('豆腐皮')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
              Blank()
              Text('✓')
                .fontSize(20)
                .fontColor('#1BBE6C')
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })

            Row() {
              Text('单位：Kg')
                .fontSize(14)
                .fontColor('#666')
              Blank()
              Text('品牌：农家')
                .fontSize(14)
                .fontColor('#666')
            }
            .width('100%')

            Text('采购价：')
              .fontSize(14)
              .fontColor('#666')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ bottom: 1 })
        }

        ListItem() {
          Column() {
            Row() {
              Text('广红萝卜')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
              Blank()
              Text('○')
                .fontSize(20)
                .fontColor('#999')
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })

            Row() {
              Text('单位：Kg')
                .fontSize(14)
                .fontColor('#666')
              Blank()
              Text('品牌：农家')
                .fontSize(14)
                .fontColor('#666')
            }
            .width('100%')

            Text('采购价：')
              .fontSize(14)
              .fontColor('#666')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ bottom: 1 })
        }
      }
      .layoutWeight(1)
      .margin({ top: 12 })

      // 底部
      Row() {
        Text(`已选中${this.selectedCount}种食材`)
          .fontSize(14)
          .fontColor('#666')
        Button('确定')
          .width(120)
          .height(40)
          .backgroundColor('#1BBE6C')
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.End)
    }
  }
}