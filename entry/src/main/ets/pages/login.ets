import router from '@ohos.router';
import http from '@ohos.net.http';
import { promptAction } from '@kit.ArkUI';
//账号18991274261密码lwjy123456
// 接口类型定义
interface UserInfo {
  id: string;
  username: string;
  clientType: string;
  realname: string;
  avatar: string | null;
  relTenantIds: number;
}

interface LoginResult {
  userInfo: UserInfo;
  token: string;
}

interface LoginResponse {
  code: number;
  message: string;
  result: LoginResult;
  timestamp: number;
}

interface LoginHandlerResult {
  success: boolean;
  code?: number;
  userInfo?: UserInfo;
  token?: string;
  message?: string;
  relTenantIds?: number;
}

interface RouterError {
  code: number;
  message: string;
}

@Entry
@Component
struct LoginPage {
  @State account: string = '';
  @State password: string = '';
  @State private authToken: string = '';
  @State private currentUser: UserInfo | null = null;

  build() {
    Stack() {
      // 背景图
      Row() {
        Image($r('app.media.login_bg'))
          .width('100%')
          .height('30%')
          .objectFit(ImageFit.Cover)
          .zIndex(1)
      }
      .position({ x: 0, y: 0 })

      // 欢迎文本
      Text('您好！')
        .fontColor(Color.White)
        .fontSize(50)
        .zIndex(100)
        .position({ x: 20, y: 50 })
      Text('欢迎使用')
        .fontSize(30)
        .zIndex(100)
        .fontColor(Color.White)
        .position({ x: 150, y: 70 })

      // 登录表单
      RelativeContainer() {
        Image("")
          .backgroundColor(Color.White)
          .width('100%')
          .height('100%')
          .position({ x: 0, y: -50 })
          .borderRadius({ topLeft: 20, topRight: 20 })

        TextInput({ text: this.account, placeholder: '用户账号' })
          .id('userAccount')
          .height(40)
          .width('80%')
          .margin({ top: 40 })
          .alignRules({
            top: { anchor: 'adminBtn', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onChange((value) => {
            this.account = value;
          })

        TextInput({ text: this.password, placeholder: '用户密码' })
          .id('userPwd')
          .type(InputType.Password)
          .height(40)
          .width('80%')
          .margin({ top: 10 })
          .alignRules({
            top: { anchor: 'userAccount', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onChange((value) => {
            this.password = value;
          })

        Button('登录')
          .id('loginBtn')
          .width('80%')
          .height(48)
          .margin({ top: 20 })
          .backgroundColor('#31B46A')
          .borderRadius(8)
          .onClick(async () => {
            const result = await this.executeLogin();
            
            if (result.success) {
              this.currentUser = result.userInfo!;
              this.authToken = result.token!;
              
              this.handleUserRedirection(result.userInfo?.clientType);
              
              promptAction.showToast({
                message: '登录成功',
                duration: 2000,
                bottom: 670
              });
            } else {
              promptAction.showToast({
                message: result.message || '登录失败',
                duration: 2000,
                bottom: 670
              });
            }
          })
          .alignRules({
            top: { anchor: 'userPwd', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
      }
      .height('100%')
      .width('100%')
      .margin({ top: 500 })
    }
    .backgroundColor(Color.Gray)
  }

  // 执行登录操作
  private async executeLogin(): Promise<LoginHandlerResult> {
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        'https://api.suoeryun.com/ifood/jeecg-system/sys/login',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({
            username: this.account,
            password: this.password
          })
        }
      );

      if (response.responseCode !== 200) {
        return {
          success: false,
          message: `HTTP Error: ${response.responseCode}`
        };
      }

      const jsonData = JSON.parse(response.result as string) as LoginResponse;
      return {
        success: jsonData.code === 200,
        code: jsonData.code,
        userInfo: jsonData.result.userInfo,
        token: jsonData.result.token,
        message: jsonData.message,
        relTenantIds: jsonData.result.userInfo.relTenantIds
      };
    } catch (error) {
      console.error('Login Error:', JSON.stringify(error));
      return {
        success: false,
        message: '账号或密码输入错误'
      };
    }
  }

  // 处理用户跳转
  private handleUserRedirection(clientType?: string) {
    // 所有用户类型都跳转到首页
    router.pushUrl({
      url: 'pages/shouye',
      params: {
        token: this.authToken,
        relTenantIds: this.currentUser?.relTenantIds
      }
    }).catch((error: RouterError) => {
      console.error("跳转失败:", error.message);
      promptAction.showToast({
        message: '跳转失败，请重试',
        duration: 2000
      });
    });
  }
}