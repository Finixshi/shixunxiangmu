import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct ChangePassword {
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';

  validateInputs(): boolean {
    if (!this.oldPassword) {
      promptAction.showToast({ message: '请输入旧密码' });
      return false;
    }

    if (!this.newPassword) {
      promptAction.showToast({ message: '请输入新密码' });
      return false;
    }

    if (!this.confirmPassword) {
      promptAction.showToast({ message: '请再次输入新密码' });
      return false;
    }

    if (this.newPassword !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的新密码不一致' });
      return false;
    }

    return true;
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Text('<')
          .fontSize(28)
          .fontColor('#333')
          .onClick(() => {
            router.back();
          })
        Column() {
          Text('修改密码')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 12, bottom: 12 })
      .border({ width: { bottom: 0.5 }, color: '#E0E0E0' })

      // 表单区域
      Column() {
        // 旧密码输入框
        TextInput({ placeholder: '请输入旧密码', text: this.oldPassword })
          .placeholderColor('#999')
          .placeholderFont({ size: 16 })
          .fontSize(16)
          .padding(12)
          .backgroundColor(Color.White)
          .width('100%')
          .height(52)
          .margin({ top: 24 })
          .onChange((value: string) => {
            this.oldPassword = value;
          })
          .border({ width: 0 })

        // 新密码输入框
        TextInput({ placeholder: '请输入新密码', text: this.newPassword })
          .placeholderColor('#999')
          .placeholderFont({ size: 16 })
          .fontSize(16)
          .padding(12)
          .backgroundColor(Color.White)
          .width('100%')
          .height(52)
          .margin({ top: 24 })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.newPassword = value;
          })
          .border({ width: 0 })

        // 确认新密码输入框
        TextInput({ placeholder: '请再次输入新密码', text: this.confirmPassword })
          .placeholderColor('#999')
          .placeholderFont({ size: 16 })
          .fontSize(16)
          .padding(12)
          .backgroundColor(Color.White)
          .width('100%')
          .height(52)
          .margin({ top: 24 })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.confirmPassword = value;
          })
          .border({ width: 0 })

        // 确认修改按钮
        Button('确认修改')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#1BBE6C')
          .borderRadius(4)
          .margin({ top: 48 })
          .onClick(() => {
            if (this.validateInputs()) {
              // 提交修改密码请求
              promptAction.showToast({ message: '密码修改成功' });
              setTimeout(() => {
                router.back();
              }, 1500);
            }
          })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}