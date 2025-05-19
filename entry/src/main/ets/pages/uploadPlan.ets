
import { prompt, router } from '@kit.ArkUI';
import http from '@ohos.net.http';
interface SupplyOrderItem {
  id: number;
  schoolName: string;
  supplyTime: string;
  demandNumber: string;
  studentMeal: string;
  nutritionMeal: string;
  mealType: string;
  creator: string;
  createTime: string;
  approver: string;
  approveTime: string;
  summary: string;
}

interface GeneratedTypeLiteralInterface_1 {
  current: number;
  pages: number;
  records: DemandPlanningRecord[];
  size: number;
  total: number;
}

interface ApiResponse {
  code: number
  message: string
  result: GeneratedTypeLiteralInterface_1
  success: boolean
  timestamp: number
}

interface DemandPlanningRecord {
  auditTime: string
  createBy: string
  createTime: string
  distributionId: string
  documentNo: string
  id: string
  izPastDue: string
  izReplenishment: string
  mealCategory: string
  mealCategory_dictText: string
  mealType: string
  mealType_dictText: string
  planningStatus: string
  preparedBy: string
  rejectOpinion: string
  reportDate: string
  reportUserId: string
  reportUserName: string
  requirementType: string
  requirementType_dictText: string
  schoolId: string
  schoolName: string
  stockId: string
  summary: string
  supplierRemark: string
  supplyDate: string
  supplyTime: string
  supplyTime_dictText: string
  tenantId: string
  totalPrice: number
  unitId: string
  unitName: string
  unitType: string
  updateBy: string
  updateTime: string
}

interface test {
  name: string,
  mealType: string,
  approveTime: string,
  summary: '',
  bao: ''
  j: number
}

@Entry
@Component
struct ShangBao {
  @State unitNum: string = '0'
  @State zhidantime: string = ''
  @State private dataList: Array<SupplyOrderItem> = [];
  @State i: number = -1;
  @StorageLink('selectedStatus') selectedStatus: string = 'draft';
  @State maskzInedx: number = -1
  @State bzInedx: number = -1
  @State bopacity: number = 0
  @State masky: number = 741
  @State demandRecords: DemandPlanningRecord[] = []
  @State loading: boolean = false
  @State pageNo: number = 1
  @State pageSize: number = 10
  @State total: number = 0
  @State ids: string = ''
  scroller: Scroller = new Scroller()
  @State bao: string = ''
  @State message: string[] = []
  @State message2: string[] = []
  @State message3: string[] = []
  @State message4: string = ''
  @State vername: string = ''
  @State verjia: string = ''
  @State vergongying: string = ''
  @State verheji: string = ''
  @State verxiuqiu: string = ''
  @State private flag: number = 0
  @State currentTab: string = 'tab1'
  @State selectedValue: string = '选择需求单位'
  @State selectedId: string = '1'
  private selectedDate: Date = new Date('2021-08-08')
  @State timetext: string = '选择供应日期'
  @State maskDeleteIndex: number = -1  // 控制删除弹窗显示（类似 maskzInedx）
  @State deleteId: string = ''        // 存储要删除的 ID

  private options: SelectOption[] = [
    { value: '选择需求单位' },
    { value: '实训第二学校(库房)' },
    { value: '实训第二学校餐厅' }
  ]

  navigateToEditPage1() {
    try {
      router.pushUrl({
        url: 'pages/re_editPage' // 这里要确保 pages/edit 是你 edit 界面在路由配置里的正确路径
      });
      console.info('Navigated to edit page successfully');
    } catch (error) {
      console.error(`Failed to navigate to edit page: ${error}`);
    }
  }

  async fetchDemandPlannings() {
    try {
      this.loading = true
      let httpRequest = http.createHttp()
      let response = await httpRequest.request(
        'https://api.suoeryun.com/ifood//jeecg-school/school/xxDemandPlanning/list',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Tenant-Id': '10021011',
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiIyZjg5NWM4NDI2MWFlNzJiYmUyMjVkMjllOWJhZjVjZCIsImV4cCI6MTc0Nzc4OTIyNywidXNlcm5hbWUiOiIxNTUwMjkzMzY3MyJ9.mRr8FvABMetnL0ZLXbVm9DZdPmIWjMlV6M7FN42vr7Y'
          },
          extraData: {
            pageNo: this.pageNo,
            pageSize: this.pageSize,
            planningStatus: this.currentTab === 'tab1' ? '1' : '5',
            supplyDate: this.timetext === '选择供应日期' ? '' : this.timetext
          }
        }
      )

      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as ApiResponse
        if (result.success) {
          this.demandRecords = result.result.records
          this.total = result.result.total
          this.flag = this.demandRecords.length > 0 ? 1 : 0
        } else {
          console.error('API request failed:', result.message)
        }
      } else {
        console.error('HTTP request failed:', response.responseCode)
      }
    } catch (error) {
      console.error('Failed to fetch demand plannings:', error)
    } finally {
      this.loading = false
    }
  }

  async fetchDemandPlanningsdelete() {
    try {
      this.loading = true
      let httpRequest = http.createHttp()
      let response = await httpRequest.request(
        'https://api.suoeryun.com/ifood/jeecg-school/school/xxDemandPlanning/deleteBatch',
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Tenant-Id': '10021011',
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiIyZjg5NWM4NDI2MWFlNzJiYmUyMjVkMjllOWJhZjVjZCIsImV4cCI6MTc0Nzc5MjI0MCwidXNlcm5hbWUiOiIxNTUwMjkzMzY3MyJ9.VfENChkdu_1vYZzBZfLke0-Ta3KMUo53PN1WYXsWtKI'
          },
          extraData: `ids=${this.ids?.toString() ?? ''}`
        }
      )

      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as ApiResponse
        if (result.success) {
        } else {
          console.error('API request failed:', result.message)
        }
      } else {
        console.error('HTTP request failed:', response.responseCode)
      }
    } catch (error) {
      console.error('Failed to fetch demand plannings:', error)
    } finally {
      this.loading = false
    }
  }

  onPageShow() {
    const params = router.getParams() as string;
    if (params) {
      this.i = params['j']
      this.message[this.i] = params['name']
      this.message2[this.i] = params['mealType']
      this.message3[this.i] = params['approveTime']
      this.message4 = params['summary']
      this.bao = params['bao']
      this.vername = params['vername']
      this.verjia = params['verjia']
      this.vergongying = params['vergongying']
      this.verheji = params['verheji']
      this.verxiuqiu = params['verxiuqiu']
    }
    this.fetchDemandPlannings()
  }

  onTabChange(tab: string) {
    this.currentTab = tab
    this.selectedId = tab === 'tab1' ? '1' : '2'
    this.pageNo = 1
    this.fetchDemandPlannings()
  }

  onDateSelect(date: string) {
    this.timetext = date
    this.pageNo = 1
    this.fetchDemandPlannings()
  }

  ondemandSelect(text: string) {
    if (text == "实训第二学校(库房)") {
      this.unitNum = '1'
    } else if (text == "实训第二学校餐厅") {
      this.unitNum = '2'
    } else {
      this.unitNum = '0'
    }
  }

  build() {
    Column() {

      Column() {
        Row() {
          Text('上报计划')
            .fontSize(20)
            .fontColor('#000000')
            .margin({ top: 20, bottom: 15 })
            .textAlign(TextAlign.Center)
            .height(10)
        }
        Row() {
          Text('phone.suoeryun.com')
            .fontSize(14)
            .fontColor('#959D9D')
        }
      }
      .width('100%')
      .height(70)
      .backgroundColor('#EDEDED')

      Row() {
        Text('未上报')
          .fontSize(18)
          .fontColor(this.currentTab === 'tab1' ? '#007DFF' : '#666')
          .padding(15)
          .borderRadius(8)
          .backgroundColor(this.currentTab === 'tab1' ? '#F0F7FF' : '#FFFFFF')
          .onClick(() => {
            this.onTabChange('tab1')
          })

        Text('')
          .id('1')
          .height(6)
          .width(46)
          .backgroundColor(this.selectedId === '1' ? Color.Green : Color.White)
          .margin({ left: 33, right: 73 })
          .position({ x: 45, y: 40 })

        Text('已上报')
          .fontSize(18)
          .fontColor(this.currentTab === 'tab2' ? '#007DFF' : '#666')
          .padding(15)
          .borderRadius(8)
          .backgroundColor(this.currentTab === 'tab2' ? '#F0F7FF' : '#FFFFFF')
          .onClick(() => {
            this.onTabChange('tab2')
          })

        Text('')
          .id('2')
          .height(6)
          .width(46)
          .backgroundColor(this.selectedId === '2' ? Color.Green : Color.White)
          .margin({ left: 33, right: 73 })
          .position({ x: 185, y: 40 })
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
      .padding(10)

      Row() {
        Select(this.options)
          .selected(0)
          .value(this.selectedValue)
          .onSelect((index: number, value: string) => {
            this.selectedValue = value
            this.ondemandSelect(value)
          })
          .alignSelf(ItemAlign.Start)
          .width("50%")
          .fontColor('#333')
          .backgroundColor('#FFF')
          .borderRadius(8)
          .border({ width: 0, color: '#DDD' })

        Text(this.timetext)
          .onClick(() => {
            DatePickerDialog.show({
              start: new Date("2000-1-1"),
              end: new Date("2100-12-31"),
              selected: this.selectedDate,
              onAccept: (value: DatePickerResult) => {
                if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                  this.selectedDate.setFullYear(value.year, value.month, value.day)
                  const formattedDate = `${value.year.toString().padStart(4, '0')}-${(value.month + 1).toString()
                    .padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`
                  this.onDateSelect(formattedDate)
                }
              }
            })
          })
          .position({ x: 220, y: 9 })
          .width('50%')
          .fontWeight(1)

        Image($r('app.media.down'))
          .width(19)
          .position({ x: 315, y: 8 })
      }
      .width('100%')

      // if (this.loading) {
      //   LoadingProgress()
      //     .color(Color.Green)
      //     .width(50)
      //     .height(50)
      // }

      if (this.currentTab === 'tab1') {
        Scroll(this.scroller) {
          if (this.flag == 0) {
            Text('~ 暂无相关数据 ~')
              .fontSize(16)
              .fontColor('#999')
          } else {
            Column() {
              ForEach(this.demandRecords, (record: DemandPlanningRecord) => {
                if (record.unitType === this.unitNum || this.unitNum === '0') {
                  Column() {
                    Text(record.unitName)
                      .alignSelf(ItemAlign.Start)
                      .fontSize(20)
                      .margin({bottom:5})

                    Text(`供应时间：${record.supplyDate + record.supplyTime_dictText}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`单据号：${record.documentNo}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`需求类型：${record.mealType_dictText}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`用餐类型：${record.requirementType_dictText}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`餐别：${record.mealCategory_dictText}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`制单人：${record.reportUserName}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`制单时间：${record.createTime}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`摘要：${record.summary}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    // Image($r('app.media.notReported'))
                    //   .width(100)
                    //   .position({ x: 250 })

                    Row({ space: 15 }) {
                      Button('重新编辑')
                        .backgroundColor(Color.White)
                        .fontColor('#15B469')
                        .margin({bottom:6,top:10})
                        .border({
                          width: 1,
                          color: Color.Green
                        })
                        .onClick(() => {
                          this.navigateToEditPage1();
                        });
                      Button('单据日志')
                        .backgroundColor(Color.White)
                        .fontColor('#15B469')
                        .margin({bottom:6,top:10})
                        .border({
                          width: 1,
                          color: Color.Green
                        })
                        .onClick(() => {
                          this.zhidantime = record.auditTime
                          this.masky = 540
                          this.bopacity = 0.5
                          this.bzInedx = 50
                        })
                      Button('删除单据')
                        .backgroundColor(Color.White)
                        .fontColor('#15B469')
                        .margin({bottom:6,top:10})
                        .border({
                          width: 1,
                          color: Color.Green
                        })
                          // .onClick(() => {
                          //   this.ids = record.id
                          //   this.fetchDemandPlanningsdelete()
                          //   this.onPageShow()
                          // })
                        .onClick(() => {
                          this.deleteId = record.id       // 存储要删除的 ID
                          this.maskDeleteIndex = 99       // 显示弹窗
                          this.bopacity = 0.5            // 显示半透明遮罩
                          this.bzInedx = 50              // 确保弹窗在最上层
                        })
                    }
                  }
                  .padding(10)
                  .border({
                    width: 2,
                    radius: {
                      topLeft: 5,
                      topRight: 5,
                      bottomLeft: 5,
                      bottomRight: 5
                    },
                    color: '#15B469'
                  })
                  .backgroundColor(Color.White)
                  .width("95%")
                  .margin({ bottom: 10,left:5,right:5})
                }
              })
            }
            .width('100%')
            .height(1000)
            //.backgroundColor("#d3d3d3")
            .margin({ bottom: 60 ,top:10})
          }
        }
        .width('100%')
        .height(480)
        .backgroundColor('#d3d3d3')
        .edgeEffect(EdgeEffect.Spring)
      }

      if (this.currentTab === 'tab2') {
        Scroll(this.scroller) {
          if (this.flag == 0) {
            Text('~ 暂无相关数据 ~')
              .fontSize(16)
              .fontColor('#999')
          } else {
            Column() {
              ForEach(this.demandRecords, (record: DemandPlanningRecord) => {
                if (record.unitType === this.unitNum || this.unitNum === '0') {
                  Column() {
                    Text(record.unitName)
                      .alignSelf(ItemAlign.Start)
                      .fontSize(20)
                      .margin({bottom:5})

                    Text(`供应时间：${record.supplyTime_dictText}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`单据号：${record.documentNo}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`需求类型：${record.mealType_dictText}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`用餐类型：${record.requirementType_dictText}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`餐别：${record.mealCategory_dictText}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`制单人：${record.preparedBy}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`制单时间：${record.auditTime}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`摘要：${record.summary}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`审批人：${record.reportUserName}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    Text(`审批时间：${record.reportDate}`)
                      .alignSelf(ItemAlign.Start)
                      .margin({bottom:5})

                    // Image($r('app.media.approved'))
                    //   .width(100)
                    //   .position({ x: 250 })

                    Row({ space: 20 }) {
                      Button('复制订单')
                        .backgroundColor(Color.White)
                        .fontColor('#15B469')
                        .margin({bottom:6,top:10})
                        .border({
                          width: 1,
                          color: Color.Green
                        })
                        .onClick(() => {
                          this.maskzInedx = 99
                          this.bopacity = 0.5
                          this.bzInedx = 50
                        })
                      Button('单据日志')
                        .backgroundColor(Color.White)
                        .fontColor('#15B469')
                        .margin({bottom:6,top:10})
                        .border({
                          width: 1,
                          color: '#15B469'
                        })
                        .onClick(() => {
                          this.zhidantime = record.auditTime
                          this.masky = 540
                          this.bopacity = 0.5
                          this.bzInedx = 50
                        })
                    }
                    //.margin({ top: 16, bottom: 16 }) // 增加按钮与卡片顶部和底部的距离
                  }
                  .padding(10)
                  .border({
                    width: 2,
                    radius: {
                      topLeft: 5,
                      topRight: 5,
                      bottomLeft: 5,
                      bottomRight: 5
                    },
                    color: '#15B469'
                  })
                  .backgroundColor(Color.White)
                  .width("95%")
                  .margin({ bottom: 10,left:5,right:5})
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/shenpixiangqing',
                      params: {
                        id: record.id
                      }
                    })
                  })
                }
              })
            }
            .width('100%')
            .height(5000)
            .backgroundColor("#d3d3d3")
            .margin({ bottom: 60,top:10 })
          }
        }
        .width('100%')
        .height(480)
        .backgroundColor('#d3d3d3')
        .edgeEffect(EdgeEffect.Spring)
      }

      Text('新建上报计划')
        .width('70%')
        .height(40)
        .textAlign(TextAlign.Center)
        .backgroundColor('#15B469')
        .margin(20)
        .fontColor(Color.White)
        .borderRadius({
          topLeft: 20,
          topRight: 20,
          bottomLeft: 20,
          bottomRight: 20
        })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/uploadPlan_2',
            params: {
              i: this.i,
              sourcePage: 're'
            }
          })
        })

      // Image($r('app.media.fanhui_1'))
      //   .width(50)
      //   .position({ x: 300, y: 350 })
      //   .border({
      //     width: 0,
      //     radius: 100
      //   })
      //   .onClick(() => {
      //     router.pushUrl({
      //       url: "pages/FirstPage",
      //     })
      //   })

      // 单据日志弹窗
      Column() {
        Text('单据日志')
          .fontSize(20)
          .margin({top:10,bottom:10})
        Row() {
          Column() {
            Text('◉')
              .fontSize(23)
              .fontColor(Color.Green)
          }
          .width('10%')
          .alignSelf(ItemAlign.Start)

          Column() {
            Text('新建计划')
              .width('100%')
              .fontSize(20)
              .textAlign(TextAlign.Start)
            Row() {
              Column() {
                Text('操作时间:' + this.zhidantime)
                  .width('100%')
                  .fontSize(16)
                  .margin({top:7,left:7,bottom:7})
              }
            }
            .borderWidth(3)
            .borderColor('#15B469')
            .borderRadius(10)
            .margin({ top: 7, bottom: 7 ,right:7})

          }
          .width('90%')
          .backgroundColor(Color.White)
        }
      }
      .backgroundColor(Color.White)
      .zIndex(99)
      .width('100%')
      .height(200)
      .position({ y: this.masky })
      .animation({
        duration: 200
      })

      // 遮罩层
      Column() {
      }
      .width('100%')
      .height(10000)
      .backgroundColor('#000000')
      .opacity(this.bopacity)
      .zIndex(this.bzInedx)
      .position({ x: 0, y: 0 })

      // 复制订单弹窗
      Column() {
        Text('复制订单')
          .width('100%')
          .fontSize(20)
          .margin({ top: 15, bottom: 20 })
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.White)
        Text('确定要复制该订单吗？')
          .margin({ bottom: 15 })
          .width('100%')
          .textAlign(TextAlign.Center)
        Row() {
        }
        .width('100%')
        .height(1)
        .backgroundColor(Color.Black)
        .zIndex(this.bzInedx)

        Row() {
          Text('取消')
            .textAlign(TextAlign.Center)
            .fontColor(Color.Green)
            .width('50%')
            .height(40)
            .borderWidth({ right: 1 })
            .onClick(() => {
              this.maskzInedx = -1
              this.bopacity = 0
              this.bzInedx = -1
            })
          Text('确定')
            .textAlign(TextAlign.Center)
            .fontColor(Color.Green)
            .height(40)
            .width('50%')
            .onClick(() => {
              this.maskzInedx = -1
              this.bopacity = 0
              this.bzInedx = -1
            })
        }
        .width('100%')
      }
      .backgroundColor(Color.White)
      .width('70%')
      .zIndex(this.maskzInedx)
      .position({ x: 50, y: 270 })

      //删除单据
      // 删除单据弹窗
      Column() {
        Text('删除单据')
          .width('100%')
          .fontSize(20)
          .margin({ top: 15, bottom: 20 })
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.White)
        Text('确定要删除该单据吗？')
          .margin({ bottom: 15 })
          .width('100%')
          .textAlign(TextAlign.Center)
        Row() {
        }
        .width('100%')
        .height(1)
        .backgroundColor(Color.Black)

        Row() {
          Text('取消')
            .textAlign(TextAlign.Center)
            .fontColor(Color.Green)
            .width('50%')
            .height(40)
            .borderWidth({ right: 1 })
            .onClick(() => {
              this.maskDeleteIndex = -1   // 隐藏弹窗
              this.bopacity = 0           // 隐藏遮罩
              this.bzInedx = -1           // 恢复层级
            })
          Text('确定')
            .textAlign(TextAlign.Center)
            .fontColor(Color.Green)
            .height(40)
            .width('50%')
            .onClick(() => {
              this.maskDeleteIndex = -1   // 隐藏弹窗
              this.bopacity = 0           // 隐藏遮罩
              this.bzInedx = -1           // 恢复层级
              this.ids = this.deleteId    // 设置要删除的 ID
              this.fetchDemandPlanningsdelete() // 调用删除 API
              this.fetchDemandPlannings()      // 刷新列表
            })
        }
        .width('100%')
      }
      .backgroundColor(Color.White)
      .width('70%')
      .zIndex(this.maskDeleteIndex)  // 使用 maskDeleteIndex 控制显示
      .position({ x: 50, y: 270 })

      // 遮罩层
      Column() {
      }
      .width('100%')
      .height(10000)
      .backgroundColor('#000000')
      .opacity(this.bopacity)
      .zIndex(this.bzInedx)
      .position({ x: 0, y: 0 })
    }
    .onClick(() => {
      this.masky = 741
      this.bzInedx = -1
      this.bopacity = 0
    })
  }
}