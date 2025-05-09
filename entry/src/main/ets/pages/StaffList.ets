import router from '@ohos.router';
import { Staff } from '../common/StaffModel';
import promptAction from '@ohos.promptAction';

// 定义对话框结果类型
interface DialogResult {
  index: number;
}

// 定义操作菜单结果类型
interface ActionMenuResult {
  index: number;
}

@Entry
@Component
struct StaffList {
  @State staffList: Staff[] = [
    new Staff('张三', '厨师', '实训第二学校餐厅', '', '在职', '', '', '', 1),
    new Staff('李四', '厨工', '实训第二学校餐厅', '', '在职', '', '', '', 2),
    new Staff('王五', '配菜员', '实训第二学校餐厅', '', '在职', '', '', '', 3)
  ];
  @State isRefreshing: boolean = false;
  private listScroller: Scroller = new Scroller();

  // 处理物理返回键
  onBackPress() {
    router.clear();
    return false;
  }

  // 向上滚动列表
  scrollToTop() {
    this.listScroller.scrollTo({ xOffset: 0, yOffset: 0 });
    promptAction.showToast({ message: '已滚动到顶部' });
  }

  // 向下滚动列表
  scrollToBottom() {
    // 计算列表内容的总高度并滚动到底部
    // 由于无法直接获取总高度，使用一个较大的估计值
    this.listScroller.scrollTo({ xOffset: 0, yOffset: 10000 });
    promptAction.showToast({ message: '已滚动到底部' });
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('后厨人员管理')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Blank()
          Button('添加人员')
            .type(ButtonType.Normal)
            .backgroundColor('#00C853')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/StaffForm',
                params: {
                  isEdit: false
                }
              });
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 10 })

        // 使用List组件，不使用复杂的嵌套结构
        List({ scroller: this.listScroller }) {
          ForEach(this.staffList, (item: Staff) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 4 })
                  Text(`${item.position} | ${item.department}`)
                    .fontSize(14)
                    .fontColor('#666666')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column() {
                  Text(item.status)
                    .fontSize(14)
                    .fontColor('#00C853')
                    .margin({ bottom: 4 })
                  Row() {
                    Button('编辑')
                      .type(ButtonType.Normal)
                      .backgroundColor('#EAEAEA')
                      .fontColor('#333333')
                      .height(30)
                      .fontSize(12)
                      .borderRadius(4)
                      .margin({ right: 8 })
                      .onClick(() => {
                        router.pushUrl({
                          url: 'pages/StaffForm',
                          params: {
                            isEdit: true,
                            staffId: item.id
                          }
                        });
                      })
                    Button('删除')
                      .type(ButtonType.Normal)
                      .backgroundColor('#EAEAEA')
                      .fontColor('#FF0000')
                      .height(30)
                      .fontSize(12)
                      .borderRadius(4)
                      .onClick(() => {
                        this.confirmDelete(item);
                      })
                  }
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .padding(16)
              .borderRadius(8)
              .backgroundColor(Color.White)
              .onClick(() => {
                // 点击项目可以查看详情
                this.showItemActionMenu(item);
              })
            }
            .margin({ bottom: 10 })
          })
          
          // 添加底部空间，确保内容可以滚动
          if (this.staffList.length > 0) {
            ListItem() {
              Row().height(100)
            }
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 添加箭头按钮组
      Column() {
        // 返回箭头按钮
        Button() {
          Image($r('app.media.back'))
            .width(20)
            .height(20)
        }
        .width(40)
        .height(40)
        .margin({ bottom: 10 })
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .onClick(() => {
          router.back();
        })

        // 向上箭头按钮
        Button() {
          Image($r('app.media.arrow_up'))
            .width(20)
            .height(20)
        }
        .width(40)
        .height(40)
        .margin({ bottom: 10 })
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .onClick(() => {
          this.scrollToTop();
        })

        // 向下箭头按钮
        Button() {
          Image($r('app.media.arrow_down'))
            .width(20)
            .height(20)
        }
        .width(40)
        .height(40)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .onClick(() => {
          this.scrollToBottom();
        })
      }
      .position({ x: '85%', y: '80%' })
      .padding(10)
      .backgroundColor('rgba(255, 255, 255, 0.7)')
      .borderRadius(25)
    }
  }

  confirmDelete(item: Staff) {
    promptAction.showDialog({
      title: '确认删除',
      message: `确定要删除"${item.name}"吗？`,
      buttons: [
        {
          text: '取消',
          color: '#666666'
        },
        {
          text: '确定',
          color: '#FF0000'
        }
      ]
    }).then((result: DialogResult) => {
      if (result.index === 1) {
        // 执行删除操作
        this.staffList = this.staffList.filter(staff => staff.id !== item.id);
        promptAction.showToast({ message: '删除成功' });
      }
    }).catch((err: Error) => {
      console.error(`删除操作错误: ${err}`);
    });
  }

  showItemActionMenu(item: Staff) {
    promptAction.showActionMenu({
      title: `${item.name}`,
      buttons: [
        {
          text: '查看详情',
          color: '#333333'
        },
        {
          text: '编辑',
          color: '#00C853'
        },
        {
          text: '删除',
          color: '#FF0000'
        }
      ]
    }).then((result: ActionMenuResult) => {
      switch (result.index) {
        case 0: // 查看详情
          router.pushUrl({
            url: 'pages/StaffForm',
            params: {
              isEdit: false,
              staffId: item.id
            }
          });
          break;
        case 1: // 编辑
          router.pushUrl({
            url: 'pages/StaffForm',
            params: {
              isEdit: true,
              staffId: item.id
            }
          });
          break;
        case 2: // 删除
          this.confirmDelete(item);
          break;
      }
    }).catch((err: Error) => {
      console.error(`操作菜单错误: ${err}`);
    });
  }
} 