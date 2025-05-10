import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct XiuGaiGeRenXinXi {
  @State name: string = '';
  @State gender: string = '男';
  @State email: string = '';
  @State phone: string = '';

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .margin({ right: 16 })
          .onClick(() => {
            router.back();
          })
        Text('修改个人信息')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // 表单内容
      Column() {
        // 姓名
        Row() {
          Text('姓名')
            .fontSize(16)
            .fontColor('#333333')
            .width(80)
          TextInput({ text: this.name })
            .fontSize(16)
            .backgroundColor(Color.White)
            .onChange((value: string) => {
              this.name = value;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .margin({ top: 12 })

        // 性别
        Row() {
          Text('性别')
            .fontSize(16)
            .fontColor('#333333')
            .width(80)
          Row() {
            Radio({ value: '男', group: 'gender' })
              .checked(this.gender === '男')
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.gender = '男';
                }
              })
            Text('男')
              .fontSize(16)
              .margin({ right: 24 })
            Radio({ value: '女', group: 'gender' })
              .checked(this.gender === '女')
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.gender = '女';
                }
              })
            Text('女')
              .fontSize(16)
          }
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .margin({ top: 1 })

        // 邮箱
        Row() {
          Text('邮箱')
            .fontSize(16)
            .fontColor('#333333')
            .width(80)
          TextInput({ text: this.email, placeholder: '请输入邮箱' })
            .fontSize(16)
            .backgroundColor(Color.White)
            .onChange((value: string) => {
              this.email = value;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .margin({ top: 1 })

        // 手机号
        Row() {
          Text('手机号')
            .fontSize(16)
            .fontColor('#333333')
            .width(80)
          TextInput({ text: this.phone, placeholder: '请输入手机号' })
            .fontSize(16)
            .backgroundColor(Color.White)
            .onChange((value: string) => {
              this.phone = value;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .margin({ top: 1 })

        // 保存按钮
        Button('保存')
          .width('90%')
          .height(48)
          .margin({ top: 32 })
          .backgroundColor('#1BBE6C')
          .onClick(() => {
            // 处理保存逻辑
            promptAction.showToast({ message: '个人信息修改成功' });
            setTimeout(() => {
              router.back();
            }, 1500);
          })
      }
      .width('100%')
      .padding({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}