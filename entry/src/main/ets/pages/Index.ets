@Entry
@Component
struct LoginPage {
  build() {
    Stack() {
      // 背景图
      Image($r('app.media.login_bg'))
        .width('100%')
        .height('100%')
        .padding({ top: 0, bottom: 400 })
      // 内容区域
      Column() {
        Text('您好！')
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .margin({ left: -180, top: 100 })
        Text('欢迎使用')
          .fontSize(20)
          .margin({ top: -30 })
          .fontWeight(FontWeight.Bold)
        // 输入框容器
        Column() {
          // 账号输入框
          Column() {
            Text('账号')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ left: -250, top: 24 })
            TextInput({placeholder:'请输入你的账号'})
              .padding({ left: 16, right: 16 })
              .border({ color: '#E0E0E0', width: 1 })
              .margin({ left: 12, right: 12, top: 8 })
          }

          // 密码输入框
          Column() {
            Text('密码')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ left: -250, top: 16 })
            TextInput({placeholder:'请输入你的密码'})
              .padding({ left: 16, right: 16 })
              .border({ color: '#E0E0E0', width: 1 })
              .margin({ left: 12, right: 12, top: 8 })
          }

          // 登录按钮
          Button('登录')
            .backgroundColor('#31B46A')
            .fontColor('#FFFFFF')
            .fontSize(18)
            .width('90%')
            .height(48)
            .margin({ top: 24, bottom: 24 })
            .borderRadius(8)
        }
        .margin(50)
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFFFF')

        .borderRadius(16)
      }
       .margin({ top: -20 })
    }
    .backgroundColor('#F5F5F5')
  }
}