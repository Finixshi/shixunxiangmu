import router from '@ohos.router';
import http from '@ohos.net.http';
import { promptAction } from '@kit.ArkUI';
import { PrintExtensionAbility } from '@kit.BasicServicesKit';

// 定义路由参数接口
interface RouteParams {
  token?: string;
  relTenantIds?: number;
}

// 定义订单管理项接口
interface OrderItem {
  url: string;
  count: number;
  text: string;
  route: string;
}

// 定义资料管理项接口
interface DataItem {
  url: string;
  text: string;
  route: string;
}

@Entry
@Component
struct Index1 {
  // 订单管理数据
  @State orderItems: OrderItem[] = [
    {
      url: 'app.media.education_1', // 待接单图标资源名，需替换为实际图标资源路径
      count: 6,
      text: '待接单',
      route: 'pages/daijiedan' // 待接单页面路由，需替换为实际页面路径
    },
    {
      url: 'app.media.education_2', // 配送单图标资源名，需替换为实际图标资源路径
      count: 4,
      text: '配送单',
      route: 'pages/peisongdangh' // 配送单页面路由，需替换为实际页面路径
    },
    {
      url: 'app.media.education_3',
      count: 0,
      text: '送货单',
      route: 'pages/songhuodan'
    },
    {
      url: 'app.media.home_11',
      count: 0,
      text: '退货单',
      route: 'pages/tuihuodan'
    },
    {
      url: 'app.media.home_4',
      count: 0,
      text: '新品申购',
      route: 'pages/NewProductApply'
    }
  ];
  // 资料管理数据
  @State dataItems: DataItem[] = [
    {
      url: 'app.media.education_4',
      text: '不良记录',
      route: 'pages/buliangjilu'
    },
    {
      url: 'app.media.education_6',
      text: '资质信息',
      route: 'pages/zizhi_page'
    }
  ];
  // 公司信息
  @State companyName: string = '彦红粮油有限公司';
  @State companyPhone: string = '18991274264';
  @State receivedToken: string = ''; // 参数传递
  @State tenantId: number = 0;
  @State currentTab: string = 'basic'; // 添加此行，用于管理当前选中的 tab
  onPageShow() { // 这是一个接收传递参数的方法
    // 使用接口类型断言
    const params = router.getParams() as RouteParams;
    console.log('eee', params?.token); // 打印接收到的参数
    console.log('gggg', params?.relTenantIds); //  打印接收到的参数

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

            // 订单管理标题
            Text('订单管理')
              .fontSize(20)
              .width('100%')
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
              .margin({ top: 10, left: 10 });

            // 订单管理功能项展示
            Grid() {
              ForEach(this.orderItems, (item: OrderItem, index: number) => {
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
                            url: item.route,
                            params: {
                              token: this.receivedToken,
                              relTenantIds: this.tenantId
                            }
                          });
                        });
                    }

                    Text(item.text)
                      .fontSize(14)
                      .margin({ top: 5 });
                  }
                  .width(90)
                  .height(100);
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .margin({ top: 10 })
            .width('100%')
            .height(300);

            // 资料管理标题
            Text('资料管理')
              .fontSize(20)
              .width('100%')
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
              .margin({ top: 10, left: 10 });

            // 资料管理功能项展示
            Grid() {
              ForEach(this.dataItems, (item: DataItem, index: number) => {
                GridItem() {
                  Column() {
                    Image($r(item.url))
                      .width(50)
                      .height(50)
                      .onClick(() => {
                        router.pushUrl({
                          url: item.route,
                          params: {
                            token: this.receivedToken,
                            relTenantIds: this.tenantId
                          }
                        });
                      });
                    Text(item.text)
                      .fontSize(14)
                      .margin({ top: 5 });
                  }
                  .width(90)
                  .height(100);
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .margin({ top: 10 })
            .width('100%')
            .height(200);
          }
          .width('100%')
          .padding({ bottom: 20 });
        }
        .width('100%')
        .height('100%')
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Fade);
      }
      .tabBar('首页');

      TabContent() {
        Column() {
          Row() {
            Image($r('app.media.avatar'))// 公司头像图标资源名，需替换为实际图标资源路径
              .width(100)
              .height(100)
              .layoutWeight(1)
              .borderRadius(50);
            Column() {
              Text(this.companyName)
                .fontSize(20);
              Text(this.companyPhone)
                .fontSize(14);
            }
            .layoutWeight(2.4);
          }
          .width('100%')
          .padding({
            left: 20
          });

          // 功能列表
          // 顶部选项卡容器
          Row() {
            // 基本信息选项卡
            Column() {
              Row() {
                Image($r('app.media.information1')) // 基本信息图标
                  .width(20)
                  .height(20)
                  .margin({ right: 5 })

                Text("基本信息")
                  .fontSize(16)
                  .fontWeight(FontWeight.Normal)
                  .fontColor('#000000')
              }
              .justifyContent(FlexAlign.Center)
              .padding(10)
            }
            .height(50)
            .width('33%')
            .onClick(() => {
              router.pushUrl({ url: 'pages/CompanyInfoForm' })
            })

            // 供应范围选项卡
            Column() {
              Row() {
                Image($r('app.media.information2')) // 供应范围图标
                  .width(20)
                  .height(20)
                  .margin({ right: 5 })

                Text("供应范围")
                  .fontSize(16)
                  .fontWeight(FontWeight.Normal)
                  .fontColor('#000000')
              }
              .justifyContent(FlexAlign.Center)
              .padding(10)
            }
            .height(50)
            .width('33%')
            .onClick(() => {
              router.pushUrl({ url: 'pages/SupplyRange' })
            })

            // 供应商品选项卡
            Column() {
              Row() {
                Image($r('app.media.information3')) // 供应商品图标
                  .width(20)
                  .height(20)
                  .margin({ right: 5 })

                Text("供应商品")
                  .fontSize(16)
                  .fontWeight(FontWeight.Normal)
                  .fontColor('#000000')
              }
              .justifyContent(FlexAlign.Center)
              .padding(10)
            }
            .height(50)
            .width('33%')
            .onClick(() => {
              router.pushUrl({ url: 'pages/SupplierProducts' })
            })
          }
          .width('100%')
          .border({ width: 1, color: '#EEEEEE' })
          .margin({ top: 10 })
          // 添加功能按钮
          List() {
            // 修改个人信息
            ListItem() {
              Row() {
                Stack() {
                  Text('修改个人信息')
                  Image($r('app.media.right_icon_black'))
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
                  Image($r('app.media.right_icon_black'))
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
                  Image($r('app.media.right_icon_black'))
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
                  Image($r('app.media.right_icon_black'))
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
                  Image($r('app.media.right_icon_black'))
                    .width(15)
                    .position({x:320})
                }
              }
              .onClick(() => {
                router.back({ url: 'pages/login', params: { token: this.receivedToken } })
              })
              .margin({left:10})
              .width('95%')
              .height(50)
              .backgroundColor(Color.White)
              .borderRadius({bottomLeft:10,bottomRight:10})
              .border({width:1,color:Color.Gray})
            }
          }
        }
      }
      .tabBar('我的')
      .backgroundColor('rgba(241,241,241,0.9)')
    }
    .barPosition(BarPosition.End)
  }
}