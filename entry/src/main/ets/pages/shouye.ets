//这里是接口参数传递以及，路由界面
import router from '@ohos.router';
import http from '@ohos.net.http';
import { promptAction } from '@kit.ArkUI';
import { PrintExtensionAbility } from '@kit.BasicServicesKit';

interface RouteParams {
  token?: string;
  relTenantIds?: number;
}


interface ImageCount{
  url:string
  count:number
  text:string
  route:string
}
interface cuku{
  url1:string
  count1:number
  text1:string
  route1:string
}
@Entry
@Component
struct Index1 {
  @State image: ImageCount[] = [
    { url: 'app.media.shangbaojihua', count: 0, text: '上报计划' ,route:'pages/uploadPlan'},
    { url: 'app.media.jinricaipin', count: 0, text: '今日菜品' ,route:'pages/jinricaipin'},
    { url: 'app.media.houchurenyuan', count: 0, text: '后厨人员',route:'pages/KitchenStaffList' },
    { url: 'app.media.meiriliuyang', count: 0, text: '每日留样' ,route:'pages/Calendar'},
    { url: 'app.media.chenjianjilu', count: 0, text: '晨检记录' ,route:'pages/chenjian'},
    { url: 'app.media.peicanjilu', count: 0, text: '陪餐记录' ,route:'pages/peicanjilu'},
  ];
  @State image1:cuku[]=[
    {url1:'app.media.gongyingchuku',count1:0,text1:'供应出库',route1:'pages/chuku' },
    {url1:'app.media.caigouruku',count1:0,text1:'采购入库',route1:'pages/ruku'},
  ]




  @State receivedToken: string = '';//参数传递
  @State tenantId: number = 0;//同上

  onPageShow() {//这是一个接收传递参数的方法
    // 使用接口类型断言
    const params = router.getParams() as RouteParams;
    console.log('eee', params?.token);// 打印接收到的参数
    console.log('gggg', params?.relTenantIds);//  打印接收到的参数

    // 安全取值
    if (params?.token) {
      this.receivedToken = params.token;
    }

    if (params?.relTenantIds) {
      this.tenantId = params.relTenantIds;
    }
  }


  build() {
    Tabs() {
      TabContent() {
        Scroll() {
          Column() {
            Swiper() {
              Image($r('app.media.banner1'))
              Image($r('app.media.banner2'))
              Image($r('app.media.banner3'))
            }
            .aspectRatio(2.1)
            .borderRadius(10)
            .margin({
              left: 10,
              right: 10,
            })

            Row() {
              Image($r('app.media.notice'))
                .height(25)
                .layoutWeight(1)
              Text()
                .height(50)
                .layoutWeight(4.5)
                .animation({ duration: 3000 })
            }
            .width('100%')
            .height(60)
            .padding({
              left: 10,
            })

            Text('需求计划')
              .fontSize(20)
              .width('100%')
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
              .margin({ top: 10, left: 10 })

            Grid() {
              ForEach(this.image, (item: ImageCount, index: number) => {
                GridItem() {
                  Column() {
                    Badge({
                      count: item.count,
                      position: BadgePosition.RightTop,
                      style: {
                        fontSize: 14,
                        badgeSize: 20,
                        badgeColor: '#fa2a2d'
                      }
                    }) {
                      Image($r(item.url))
                        .width(50)
                        .height(50)
                        .onClick(() => {
                          router.pushUrl({
                            // 使用push入栈一个新页面
                            url: item.route // 通过url指定新打开的页面
                          ,
                            params: {
                              token: this.receivedToken,
                              relTenantIds: this.tenantId

                            }
                          })
                        })
                    }

                    Text(item.text)
                      .fontSize(14)
                      .margin({ top: 5 })
                  }
                  .width(90)
                  .height(100)
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .margin({ top: 10 })
            .width('100%')
            .height(300)

            Text('出入库')
              .fontSize(20)
              .width('100%')
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
              .margin({ top: 10, left: 10 })
            Grid() {
              ForEach(this.image1, (item1: cuku, index: number) => {
                GridItem() {
                  Column() {
                    Badge({
                      count: item1.count1,
                      position: BadgePosition.RightTop,
                      style: {
                        fontSize: 14,
                        badgeSize: 20,
                        badgeColor: '#fa2a2d'
                      }
                    }) {
                      Image($r(item1.url1))
                        .width(50)
                        .height(50)
                        .onClick(() => {
                          router.pushUrl({
                            // 使用push入栈一个新页面
                            url: item1.route1 // 通过url指定新打开的页面
                          ,
                            params: {
                              token: this.receivedToken,
                              relTenantIds: this.tenantId

                            }
                          })
                        })
                    }

                    Text(item1.text1)
                      .fontSize(14)
                      .margin({ top: 5 })
                  }
                  .width(90)
                  .height(100)
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .margin({ top: 10 })
            .width('100%')
            .height(200)

          }
          .width('100%')
          .padding({ bottom: 20 })
        }
        .width('100%')
        .height('100%')
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Fade)
      }
      .tabBar('首页')

      TabContent() {
        Column() {
          Row() {
            Image($r('app.media.avatar'))
              .width(100)
              .height(100)
              .layoutWeight(1)
              .borderRadius(50)
            Column() {
              Text('实训第二学校')
                .fontSize(20)
              Text('人15502933673')
            }
            .layoutWeight(2.4)
          }
          .width('100%')
          .padding({
            left: 20,
          })

          // 添加功能按钮
          List() {
            // 修改个人信息
            ListItem() {
              Row() {
                Stack() {
                  Text('修改个人信息')
                  Image($r('app.media.right_icon'))
                    .width(15)
                    .position({x:320})
                }
              }
              .onClick(() => {
                router.pushUrl({ url: 'pages/xiugaigerenxinxi', params: { token: this.receivedToken } })
              })
              .margin({left:10})
              .width('95%')
              .height(50)
              .backgroundColor(Color.White)
              .borderRadius({topLeft:10,topRight:10})
              .border({width:1,color:Color.Gray})
            }

            // 修改密码
            ListItem() {
              Row() {
                Stack() {
                  Text('修改密码')
                  Image($r('app.media.right_icon'))
                    .width(15)
                    .position({x:320})
                }
              }
              .onClick(() => {
                router.pushUrl({ url: 'pages/xiugaimima', params: { token: this.receivedToken } })
              })
              .margin({left:10})
              .width('95%')
              .height(50)
              .backgroundColor(Color.White)
              .border({width:1,color:Color.Gray})
            }

            // 解绑微信
            ListItem() {
              Row() {
                Stack() {
                  Text('解绑微信')
                  Image($r('app.media.right_icon'))
                    .width(15)
                    .position({x:320})
                }
              }
              .onClick(() => {
                router.pushUrl({ url: 'pages/editProfile', params: { token: this.receivedToken } })
              })
              .margin({left:10})
              .width('95%')
              .height(50)
              .backgroundColor(Color.White)
              .border({width:1,color:Color.Gray})
            }

            // 常见问题解答
            ListItem() {
              Row() {
                Stack() {
                  Text('常见问题解答')
                  Image($r('app.media.right_icon'))
                    .width(15)
                    .position({x:320})
                }
              }
              .onClick(() => {
                router.pushUrl({ url: 'pages/changjianwentijieda', params: { token: this.receivedToken } })
              })
              .margin({left:10})
              .width('95%')
              .height(50)
              .backgroundColor(Color.White)
              .border({width:1,color:Color.Gray})
            }

            // 退出登录
            ListItem() {
              Row() {
                Stack() {
                  Text('退出登录')
                  Image($r('app.media.right_icon'))
                    .width(15)
                    .position({x:320})
                }
              }
              .onClick(() => {
                router.pushUrl({ url: 'pages/page1', params: { token: this.receivedToken } })
              })
              .margin({left:10})
              .width('95%')
              .height(50)
              .backgroundColor(Color.White)
              .borderRadius({bottomLeft:10,bottomRight:10})
              .border({width:1,color:Color.Gray})
            }
          }
          .width('100%')
          .margin({ top: 20 })
        }
      }
      .tabBar('我的')
      .backgroundColor('rgba(241,241,241,0.9)')
    }
    .barPosition(BarPosition.End)
  }
}