import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct EditProfile {
  @State name: string = '人';
  @State gender: string = '女';
  @State email: string = '';
  @State phone: string = '';

  build() {
    Column() {
      // 顶部栏
      Row() {
        Text('×')
          .fontSize(28)
          .fontColor('#333')
          .onClick(() => {
            router.back();
          })
        Column() {
          Text('修改个人信息')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Text('···')
          .fontSize(24)
          .fontColor('#333')
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 0.5 }, color: '#E0E0E0' })

      // 表单区域
      Column() {
        // 姓名
        Row() {
          Text('姓名')
            .fontSize(16)
            .fontColor('#888')
          Blank()
          Text(this.name)
            .fontSize(16)
            .fontColor('#333')
          Text('>')
            .fontSize(16)
            .fontColor('#CCCCCC')
            .margin({ left: 4 })
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .border({ width: { bottom: 0.5 }, color: '#EEEEEE' })

        // 性别
        Row() {
          Text('性别')
            .fontSize(16)
            .fontColor('#888')
          Blank()
          Text(this.gender)
            .fontSize(16)
            .fontColor('#333')
          Text('>')
            .fontSize(16)
            .fontColor('#CCCCCC')
            .margin({ left: 4 })
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .border({ width: { bottom: 0.5 }, color: '#EEEEEE' })

        // 邮箱
        Row() {
          Text('邮箱')
            .fontSize(16)
            .fontColor('#888')
          Blank()
          Text(this.email ? this.email : '请输入邮箱')
            .fontSize(16)
            .fontColor(this.email ? '#333' : '#999')
          Text('>')
            .fontSize(16)
            .fontColor('#CCCCCC')
            .margin({ left: 4 })
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .border({ width: { bottom: 0.5 }, color: '#EEEEEE' })

        // 手机号
        Row() {
          Text('手机号')
            .fontSize(16)
            .fontColor('#888')
          Blank()
          Text(this.phone ? this.phone : '请输入手机号码')
            .fontSize(16)
            .fontColor(this.phone ? '#333' : '#999')
          Text('>')
            .fontSize(16)
            .fontColor('#CCCCCC')
            .margin({ left: 4 })
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
      }
      .margin({ top: 24 })

      // 确认修改按钮
      Button('确认修改')
        .width('90%')
        .height(48)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#1BBE6C')
        .borderRadius(4)
        .margin({ top: 48 })
        .onClick(() => {
          // 提交个人信息修改请求
          promptAction.showToast({ message: '个人信息修改成功' });
          setTimeout(() => {
            router.back();
          }, 1500);
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}