import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';

// 定义后厨人员接口
interface KitchenStaff {
  id: string;          // 唯一标识
  name: string;        // 姓名
  position: string;    // 职位
  phone: string;       // 联系电话
  certificate: string; // 健康证号
  certExpiry: string;  // 健康证有效期
  joinDate: string;    // 入职日期
  status: string;      // 状态(在职/离职)
}

@Entry
@Component
struct KitchenStaffList {
  @State staffList: KitchenStaff[] = []
  @State searchText: string = ''
  @State statusFilter: string = '全部'
  @State filteredList: KitchenStaff[] = []
  private context = getContext(this) as common.UIAbilityContext

  private statusOptions: SelectOption[] = [
    { value: '全部' },
    { value: '在职' },
    { value: '离职' }
  ]

  aboutToAppear() {
    this.getStaffList()
  }

  onPageShow() {
    this.getStaffList()
  }

  private async getStaffList() {
    try {
      const prefer = await preferences.getPreferences(this.context, 'myPreferences')
      const storageStaff = await prefer.get('staffList', '[]')
      if (storageStaff) {
        this.staffList = JSON.parse(storageStaff as string)
        // 按入职日期倒序排列，最新的显示在前面
        this.staffList.sort((a, b) => new Date(b.joinDate).getTime() - new Date(a.joinDate).getTime())
        this.updateFilteredList()
      }
    } catch (error) {
      console.error('获取人员数据失败:', error)
    }
  }

  private async deleteStaff(index: number) {
    AlertDialog.show({
      title: '删除确认',
      message: '确定要删除该人员信息吗？',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('取消删除')
        }
      },
      secondaryButton: {
        value: '删除',
        action: async () => {
          this.staffList.splice(index, 1)
          try {
            const prefer = await preferences.getPreferences(this.context, 'myPreferences')
            await prefer.put('staffList', JSON.stringify(this.staffList))
            await prefer.flush()
            promptAction.showToast({ message: '删除成功' })
            this.updateFilteredList()
          } catch (error) {
            console.error('删除失败:', error)
            promptAction.showToast({ message: '删除失败' })
          }
        }
      }
    })
  }

  // 根据搜索文本和状态筛选员工列表并更新state
  private updateFilteredList() {
    this.filteredList = this.staffList.filter(staff => {
      const matchesSearch = this.searchText === '' || 
        staff.name.includes(this.searchText) || 
        staff.position.includes(this.searchText) ||
        staff.phone.includes(this.searchText)
      
      const matchesStatus = this.statusFilter === '全部' || staff.status === this.statusFilter
      
      return matchesSearch && matchesStatus
    })
  }

  // 检查健康证是否过期
  private isCertExpired(expiryDate: string): boolean {
    const today = new Date()
    const expiry = new Date(expiryDate)
    return today > expiry
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Stack({ alignContent: Alignment.Start }) {
          Text('后厨人员管理')
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: 18, bottom: 8 })
          
          Text('←')
            .fontSize(24)
            .fontColor('#000')
            .margin({ left: 16, top: 18 })
            .onClick(() => {
              router.back()
            })
        }
        .width('100%')
        
        // 搜索和筛选栏
        Row({ space: 10 }) {
          TextInput({ placeholder: '搜索姓名/职位/电话', text: this.searchText })
            .width('60%')
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .onChange((value: string) => {
              this.searchText = value
              this.updateFilteredList()
            })
          
          Select(this.statusOptions)
            .selected(0)
            .value(this.statusFilter)
            .onSelect((index: number, value: string) => {
              this.statusFilter = value
              this.updateFilteredList()
            })
            .width("35%")
            .fontColor('#333')
            .backgroundColor('#FFF')
            .borderRadius(8)
        }
        .width('100%')
        .padding({ left: 12, right: 12, bottom: 10, top: 8 })

        // 中间内容区域
        Column() {
          if (this.filteredList.length === 0) {
            Column() {
              Text('~ 暂无相关数据 ~')
                .fontSize(15)
                .fontColor('#BBBBBB')
            }
            .width('100%')
            .height('80%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#F5F5F5')
          } else {
            List() {
              ForEach(this.filteredList, (staff: KitchenStaff, index: number) => {
                ListItem() {
                  Column() {
                    Row() {
                      Text('姓    名：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(staff.name)
                        .fontSize(16)
                        .fontColor('#333')
                      Blank()
                      Text(staff.status)
                        .fontSize(14)
                        .fontColor(staff.status === '在职' ? '#4CAF50' : '#FF5722')
                        .backgroundColor(staff.status === '在职' ? '#E8F5E9' : '#FBE9E7')
                        .borderRadius(4)
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row() {
                      Text('职    位：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(staff.position)
                        .fontSize(16)
                        .fontColor('#333')
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row() {
                      Text('联系电话：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(staff.phone)
                        .fontSize(16)
                        .fontColor('#333')
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row() {
                      Text('健康证号：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(staff.certificate)
                        .fontSize(16)
                        .fontColor('#333')
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row() {
                      Text('有 效 期：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(staff.certExpiry)
                        .fontSize(16)
                        .fontColor(this.isCertExpired(staff.certExpiry) ? '#FF5722' : '#333')
                      if (this.isCertExpired(staff.certExpiry)) {
                        Text(' (已过期)')
                          .fontSize(14)
                          .fontColor('#FF5722')
                      }
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row() {
                      Text('入职日期：')
                        .fontSize(16)
                        .fontColor('#666')
                      Text(staff.joinDate)
                        .fontSize(16)
                        .fontColor('#333')
                    }
                    .width('100%')
                    .padding({ top: 5, bottom: 5 })

                    Row({ space: 20 }) {
                      Button('编辑信息')
                        .backgroundColor(Color.White)
                        .fontColor(Color.Green)
                        .border({
                          width: 1,
                          color: Color.Green
                        })
                        .onClick(() => {
                          router.pushUrl({
                            url: 'pages/StaffEditor',
                            params: { staff: staff, index: index }
                          })
                        })

                      Button('删除信息')
                        .backgroundColor(Color.White)
                        .fontColor(Color.Green)
                        .border({
                          width: 1,
                          color: Color.Green
                        })
                        .onClick(() => this.deleteStaff(index))
                    }
                    .margin({ top: 10 })
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFF')
                  .border({
                    width: 1,
                    color: '#4CAF50',
                    style: BorderStyle.Solid
                  })
                  .borderRadius(8)
                }
                .margin({ bottom: 10 })
              })
            }
            .width('100%')
            .padding(10)
          }
        }
        .width('100%')
        .backgroundColor('#F5F5F5')
        .flexGrow(1)
      }
      .width('100%')
      .height('100%')

      // 底部添加人员按钮
      Column() {
        Button('添加后厨人员', { type: ButtonType.Normal })
          .width('90%')
          .height(44)
          .backgroundColor(Color.Green)
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(8)
          .margin({ bottom: 24 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/StaffEditor'
            });
          })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding({ top: 8 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
} 