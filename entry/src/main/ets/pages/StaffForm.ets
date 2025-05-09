import router from '@ohos.router';
import picker from '@ohos.file.picker';
import { Staff } from '../common/StaffModel';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

interface RouterParams {
  isEdit?: boolean;
  staffId?: number;
}

// 定义对话框结果类型
interface DialogResult {
  index: number;
}

// 定义日期选择器结果类型
interface DatePickerResult {
  year?: number;
  month?: number;
  day?: number;
}

@Entry
@Component
struct StaffForm {
  @State isEdit: boolean = false;
  @State staffInfo: Staff = new Staff();
  @State healthCertImage: string = '';
  @State healthCertCount: number = 0;
  @State staffId: number = 0;
  @State departmentOptions: string[] = ['实训第一学校餐厅', '实训第二学校餐厅', '实训第三学校餐厅'];
  @State statusOptions: string[] = ['在职', '离职', '实习'];
  @State isShowDepartmentPicker: boolean = false;
  @State isShowStatusPicker: boolean = false;
  @State isDataChanged: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params) {
      if (params.isEdit !== undefined) {
        this.isEdit = params.isEdit;
      }
      if (params.staffId !== undefined) {
        this.staffId = params.staffId;
        // 在实际应用中，应该从数据服务获取人员信息
        // 此处简化处理，假设从全局数据或本地存储获取
      }
    }
  }

  onBackPress() {
    if (this.isDataChanged) {
      promptAction.showDialog({
        title: '提示',
        message: '您有未保存的更改，确定要离开吗？',
        buttons: [
          {
            text: '取消',
            color: '#666666'
          },
          {
            text: '确定',
            color: '#00C853'
          }
        ]
      }).then((result: DialogResult) => {
        if (result.index === 1) {
          router.back();
        }
      }).catch((err: Error) => {
        console.error(`对话框错误: ${err}`);
      });
      return true;
    }
    return false;
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Image($r('app.media.back'))
            .width(24)
            .height(24)
            .onClick(() => {
              if (this.isDataChanged) {
                this.onBackPress();
              } else {
                router.back();
              }
            })
          Text('后厨人员')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
          Blank()
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')

        Scroll(this.scroller) {
          Column() {
            // 所属单位
            Column() {
              Row() {
                Text('所属单位')
                  .fontSize(16)
                Text('*')
                  .fontSize(16)
                  .fontColor('#FF0000')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text(this.staffInfo.department)
                  .fontSize(16)
                Blank()
                Image($r('app.media.arrow_right'))
                  .width(20)
                  .height(20)
              }
              .width('100%')
              .height(48)
              .borderRadius(4)
              .backgroundColor('#F5F5F5')
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                this.isShowDepartmentPicker = true;
              })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 人员姓名
            Column() {
              Row() {
                Text('人员姓名')
                  .fontSize(16)
                Text('*')
                  .fontSize(16)
                  .fontColor('#FF0000')
              }
              .width('100%')
              .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入人员姓名', text: this.staffInfo.name })
                .width('100%')
                .height(48)
                .borderRadius(4)
                .backgroundColor('#F5F5F5')
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.staffInfo.name = value;
                  this.isDataChanged = true;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 人员岗位
            Column() {
              Row() {
                Text('人员岗位')
                  .fontSize(16)
                Text('*')
                  .fontSize(16)
                  .fontColor('#FF0000')
              }
              .width('100%')
              .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入人员岗位', text: this.staffInfo.position })
                .width('100%')
                .height(48)
                .borderRadius(4)
                .backgroundColor('#F5F5F5')
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.staffInfo.position = value;
                  this.isDataChanged = true;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 联系电话
            Column() {
              Row() {
                Text('联系电话')
                  .fontSize(16)
                Text('*')
                  .fontSize(16)
                  .fontColor('#FF0000')
              }
              .width('100%')
              .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入人员联系电话', text: this.staffInfo.phone })
                .width('100%')
                .height(48)
                .borderRadius(4)
                .backgroundColor('#F5F5F5')
                .padding({ left: 16, right: 16 })
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.staffInfo.phone = value;
                  this.isDataChanged = true;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 人员状态
            Column() {
              Row() {
                Text('人员状态')
                  .fontSize(16)
                Text('*')
                  .fontSize(16)
                  .fontColor('#FF0000')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text(this.staffInfo.status)
                  .fontSize(16)
                Blank()
                Image($r('app.media.arrow_right'))
                  .width(20)
                  .height(20)
              }
              .width('100%')
              .height(48)
              .borderRadius(4)
              .backgroundColor('#F5F5F5')
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                this.isShowStatusPicker = true;
              })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 发证日期
            Column() {
              Row() {
                Text('发证日期')
                  .fontSize(16)
                Text('*')
                  .fontSize(16)
                  .fontColor('#FF0000')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text(this.staffInfo.issueDate || '请选择发证日期')
                  .fontSize(16)
                  .fontColor(this.staffInfo.issueDate ? '#000000' : '#AAAAAA')
                Blank()
                Image($r('app.media.arrow_right'))
                  .width(20)
                  .height(20)
              }
              .width('100%')
              .height(48)
              .borderRadius(4)
              .backgroundColor('#F5F5F5')
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                this.openDatePicker('issue');
              })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 到期日期
            Column() {
              Row() {
                Text('到期日期')
                  .fontSize(16)
                Text('*')
                  .fontSize(16)
                  .fontColor('#FF0000')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text(this.staffInfo.expiryDate || '请选择到期日期')
                  .fontSize(16)
                  .fontColor(this.staffInfo.expiryDate ? '#000000' : '#AAAAAA')
                Blank()
                Image($r('app.media.arrow_right'))
                  .width(20)
                  .height(20)
              }
              .width('100%')
              .height(48)
              .borderRadius(4)
              .backgroundColor('#F5F5F5')
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                this.openDatePicker('expiry');
              })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 健康证照片
            Column() {
              Row() {
                Text('健康证照片')
                  .fontSize(16)
                Blank()
                Text(`${this.healthCertCount}/1`)
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                if (this.healthCertImage) {
                  Stack() {
                    Image(this.healthCertImage)
                      .width(120)
                      .height(120)
                      .borderRadius(4)
                    Image($r('app.media.delete'))
                      .width(24)
                      .height(24)
                      .position({ x: 96, y: 0 })
                      .onClick(() => {
                        this.healthCertImage = '';
                        this.healthCertCount = 0;
                        this.isDataChanged = true;
                      })
                  }
                  .width(120)
                  .height(120)
                } else {
                  Column() {
                    Image($r('app.media.upload'))
                      .width(40)
                      .height(40)
                      .margin({ bottom: 8 })
                    Text('上传照片')
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                  .width(120)
                  .height(120)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .border({ width: 1, color: '#DDDDDD', style: BorderStyle.Dashed })
                  .borderRadius(4)
                  .onClick(() => {
                    this.openImagePicker();
                  })
                }
              }
            }
            .width('100%')
            .margin({ bottom: 24 })

            Button('保存')
              .width('100%')
              .height(48)
              .backgroundColor('#00C853')
              .onClick(() => {
                if (this.validateForm()) {
                  // 保存后返回列表页
                  router.back();
                }
              })

            // 添加底部空间，确保内容可以滚动到顶部
            Column()
              .height(100)
          }
          .width('100%')
          .padding(16)
        }
        .scrollable(ScrollDirection.Vertical)  // 只允许垂直滚动
        .scrollBar(BarState.Auto)              // 自动显示/隐藏滚动条
        .edgeEffect(EdgeEffect.Spring)         // 设置滚动到边缘时的效果
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')

        // 部门选择弹窗
        if (this.isShowDepartmentPicker) {
          Column() {
            Row() {
              Text('选择单位')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
              Blank()
              Button('关闭')
                .backgroundColor('#FFFFFF')
                .fontColor('#333333')
                .onClick(() => {
                  this.isShowDepartmentPicker = false;
                })
            }
            .width('100%')
            .padding(16)

            List() {
              ForEach(this.departmentOptions, (item: string) => {
                ListItem() {
                  Row() {
                    Text(item)
                      .fontSize(16)
                    Blank()
                    if (this.staffInfo.department === item) {
                      Image($r('app.media.check'))
                        .width(20)
                        .height(20)
                    }
                  }
                  .width('100%')
                  .padding(16)
                  .onClick(() => {
                    this.staffInfo.department = item;
                    this.isShowDepartmentPicker = false;
                    this.isDataChanged = true;
                  })
                }
                .margin({ bottom: 1 })
              })
            }
            .width('100%')
            .layoutWeight(1)
          }
          .width('100%')
          .height('70%')
          .backgroundColor('#FFFFFF')
          .position({ x: 0, y: '30%' })
        }

        // 状态选择弹窗
        if (this.isShowStatusPicker) {
          Column() {
            Row() {
              Text('选择状态')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
              Blank()
              Button('关闭')
                .backgroundColor('#FFFFFF')
                .fontColor('#333333')
                .onClick(() => {
                  this.isShowStatusPicker = false;
                })
            }
            .width('100%')
            .padding(16)

            List() {
              ForEach(this.statusOptions, (item: string) => {
                ListItem() {
                  Row() {
                    Text(item)
                      .fontSize(16)
                    Blank()
                    if (this.staffInfo.status === item) {
                      Image($r('app.media.check'))
                        .width(20)
                        .height(20)
                    }
                  }
                  .width('100%')
                  .padding(16)
                  .onClick(() => {
                    this.staffInfo.status = item;
                    this.isShowStatusPicker = false;
                    this.isDataChanged = true;
                  })
                }
                .margin({ bottom: 1 })
              })
            }
            .width('100%')
            .layoutWeight(1)
          }
          .width('100%')
          .height('70%')
          .backgroundColor('#FFFFFF')
          .position({ x: 0, y: '30%' })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')

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
          if (this.isDataChanged) {
            this.onBackPress();
          } else {
            router.back();
          }
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
          this.scroller.scrollTo({ xOffset: 0, yOffset: 0 });
          promptAction.showToast({ message: '已滚动到顶部' });
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
          this.scroller.scrollTo({ xOffset: 0, yOffset: 10000 });
          promptAction.showToast({ message: '已滚动到底部' });
        })
      }
      .position({ x: '85%', y: '80%' })
      .padding(10)
      .backgroundColor('rgba(255, 255, 255, 0.7)')
      .borderRadius(25)
    }
  }

  openImagePicker() {
    try {
      // 简化处理，实际应调用系统相册
      this.healthCertImage = 'https://img.zcool.cn/community/01f1615e2a139ca80120a8952ba629.jpg';
      this.healthCertCount = 1;
      this.isDataChanged = true;
      promptAction.showToast({ message: '上传照片成功' });
    } catch (error) {
      promptAction.showToast({ message: '上传照片失败' });
    }
  }

  openDatePicker(type: string) {
    try {
      let date = new Date();
      
      DatePickerDialog.show({
        start: new Date('2020-01-01'),
        end: new Date('2030-12-31'),
        selected: date,
        onAccept: (value: DatePickerResult) => {
          // 确保month不是undefined
          if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
            const selectedDate = `${value.year}-${value.month + 1}-${value.day}`;
            if (type === 'issue') {
              this.staffInfo.issueDate = selectedDate;
              this.isDataChanged = true;
            } else if (type === 'expiry') {
              this.staffInfo.expiryDate = selectedDate;
              this.isDataChanged = true;
            }
          }
        },
        onCancel: () => {
          console.info('取消选择日期');
        }
      });
    } catch (error) {
      console.error(`显示日期选择器错误: ${error}`);
      promptAction.showToast({ message: '打开日期选择器失败' });
    }
  }

  validateForm(): boolean {
    if (!this.staffInfo.name) {
      promptAction.showToast({ message: '请输入人员姓名' });
      return false;
    }
    if (!this.staffInfo.position) {
      promptAction.showToast({ message: '请输入人员岗位' });
      return false;
    }
    if (!this.staffInfo.phone) {
      promptAction.showToast({ message: '请输入联系电话' });
      return false;
    }
    if (!this.staffInfo.issueDate) {
      promptAction.showToast({ message: '请选择发证日期' });
      return false;
    }
    if (!this.staffInfo.expiryDate) {
      promptAction.showToast({ message: '请选择到期日期' });
      return false;
    }
    // 健康证照片可选，不做校验
    return true;
  }
} 