import { router } from '@kit.ArkUI';
import prompt from '@ohos.prompt';

@Entry
@Component
struct LoginPage {
  @State name: string = '';
  @State phonenumber: string = '';
  @State email: string = '';
  @State gender: string = '男';
  @State sexGender: string = '男';
  @State nameError: string = '';
  @State phoneError: string = '';
  @State emailError: string = '';

  // 表单验证
  validateForm(): boolean {
    let isValid = true;
    // 验证昵称
    if (this.name.trim() === '') {
      this.nameError = '昵称不能为空';
      isValid = false;
    } else {
      this.nameError = '';
    }
    // 验证手机号
    const phoneRegex = /^1\d{10}$/;
    if (this.phonenumber.trim() === '') {
      this.phoneError = '手机号不能为空';
      isValid = false;
    } else if (!phoneRegex.test(this.phonenumber)) {
      this.phoneError = '请输入正确的手机号';
      isValid = false;
    } else {
      this.phoneError = '';
    }
    // 验证邮箱（可选，此处保留但不强制）
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (this.email.trim() === '') {
      this.emailError = '邮箱不能为空';
      isValid = false;
    } else if (!emailRegex.test(this.email)) {
      this.emailError = '请输入正确的邮箱格式';
      isValid = false;
    } else {
      this.emailError = '';
    }
    return isValid;
  }

  build() {
    Column() {
      // 返回按钮 - 新增组件
      Row() {
        Text("<")
          .width(24)
          .height(24)
          .fontSize(24)
          .margin({ left: 15, top: 25 })
          .onClick(() => router.back()) // 返回上一页
      }
      .width('100%')
      .height(70)
      .justifyContent(FlexAlign.Start)

      // 原有内容包裹在新的Column中
      Column({ space: 20 }) {
        // 头像
        Column() {
          Image($r('app.media.avatar'))
            .width(80)
            .height(80)
            .borderRadius(50)
            .margin({ top: 20 });
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);

        // 昵称输入
        Column() {
          Row() {
            Text('昵称:')
              .fontWeight(FontWeight.Medium)
              .width(100)
              .padding(10);
            TextInput({
              placeholder: '请输入昵称',
              text: this.name
            })
              .backgroundColor(Color.White)
              .onChange((value: string) => {
                this.name = value;
                if (value.trim() === '') {
                  this.nameError = '昵称不能为空';
                } else {
                  this.nameError = '';
                }
              })
              .width('100%')
              .padding(10)
              .borderRadius(20);
          }
          if (this.nameError) {
            Text(this.nameError)
              .fontSize(12)
              .fontColor(Color.Red)
              .margin({ left: 110 });
          }
        }
        .border({ width: { bottom: 1 }, color: { bottom: 0xe0e0e0 }, style: BorderStyle.Solid });

        // 性别选择
        Row() {
          Text('性别:')
            .fontFamily('Microsoft YaHei')
            .width(100)
            .padding(5)
            .fontWeight(FontWeight.Medium);
          Row() {
            Text('男')
              .fontWeight(FontWeight.Medium);
            Radio({ value: '男', group: "genderGroup" })
              .checked(this.sexGender === '男')
              .onChange((isChecked: boolean) => {
                if (isChecked) this.gender = '男';
              })
              .margin({ right: 20 });
            Text('女')
              .fontWeight(FontWeight.Medium);
            Radio({ value: '女', group: "genderGroup" })
              .checked(this.gender === '女')
              .onChange((isChecked: boolean) => {
                if (isChecked) this.gender = '女';
              });
          }
          .width(100)
          .padding(10)
          .borderRadius(20);
        }
        .width('100%')
        .margin(5);

        // 邮箱输入（可选）
        Column() {
          Row() {
            Text('邮箱:')
              .fontWeight(FontWeight.Medium)
              .width(100)
              .padding(10);
            TextInput({
              placeholder: '请输入邮箱',
              text: this.email
            })
              .backgroundColor(Color.White)
              .onChange((value: string) => {
                this.email = value;
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (value.trim() === '') {
                  this.emailError = '邮箱不能为空';
                } else if (!emailRegex.test(value)) {
                  this.emailError = '请输入正确的邮箱格式';
                } else {
                  this.emailError = '';
                }
              })
              .width('100%')
              .padding(10)
              .borderRadius(20);
          }
          if (this.emailError) {
            Text(this.emailError)
              .fontSize(12)
              .fontColor(Color.Red)
              .margin({ left: 110 });
          }
        }
        .border({ width: { bottom: 1 }, color: { bottom: 0xe0e0e0 }, style: BorderStyle.Solid });

        // 手机号输入
        Column() {
          Row() {
            Text('手机号:')
              .fontWeight(FontWeight.Medium)
              .width(100)
              .padding(10);
            TextInput({
              placeholder: '请输入手机号',
              text: this.phonenumber
            })
              .backgroundColor(Color.White)
              .onChange((value: string) => {
                this.phonenumber = value;
                const phoneRegex = /^1\d{10}$/;
                if (value.trim() === '') {
                  this.phoneError = '手机号不能为空';
                } else if (!phoneRegex.test(value)) {
                  this.phoneError = '请输入正确的手机号';
                } else {
                  this.phoneError = '';
                }
              })
              .width('100%')
              .padding(10)
              .borderRadius(20);
          }
          if (this.phoneError) {
            Text(this.phoneError)
              .fontSize(12)
              .fontColor(Color.Red)
              .margin({ left: 110 });
          }
        }
        .border({ width: { bottom: 1 }, color: { bottom: 0xe0e0e0 }, style: BorderStyle.Solid });

        // 完成按钮
        Button('完成')
          .width(200)
          .height(45)
          .backgroundColor('#ff91fac4')
          .fontSize(18)
          .margin(10)
          .fontWeight(FontWeight.Medium)
          .fontColor(0xffffff)
          .borderRadius(20)
          .onClick(() => {
            if (this.validateForm()) {
              // 跳转至主界面并传递姓名和手机号
              router.pushUrl({
                url: 'pages/Index1', // 主界面路由，需与项目配置一致
                params: {
                  name: this.name,
                  phone: this.phonenumber
                }
              });
            } else {
              prompt.showToast({
                message: '请正确填写所有信息',
                duration: 2000
              });
            }
          });
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%')
  }
}