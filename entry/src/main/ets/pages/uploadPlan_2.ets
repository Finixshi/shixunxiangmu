import { prompt, router } from '@kit.ArkUI';
import http from '@ohos.net.http';
import { url } from '@kit.ArkTS';
import { data } from '@kit.TelephonyKit';
import { request } from '@kit.BasicServicesKit';

interface wpz {
  i: number
}
interface FoodItem {
  id: string; // 食材 ID
  storehouseId: string | null; // 仓库 ID，可能为 null
  foodAndSupplierId: string; // 食材与供应商关联 ID
  foodId: string; // 食材 ID
  supplyWay: string; // 供应方式
  superiorLimit: number | null; // 上限，可能为 null
  lowerLimit: number | null; // 下限，可能为 null
  storageLocation: string | null; // 存储位置，可能为 null
  stock: number; // 库存数量
  storehouseStatus: string | null; // 仓库状态，可能为 null
  izCollect: string; // 是否收藏
  encoding: string; // 编码
  groupId: string; // 分组 ID
  groupName: string; // 分组名称
  foodName: string; // 食材名称
  forShort: string; // 简称
  internationalCode: string | null; // 国际编码，可能为 null
  pinyinCode: string; // 拼音编码
  specification: string; // 规格
  expirationDay: number; // 保质期（天）
  brandLevel: string; // 品牌等级
  minDeclare: number | null; // 最小申报量，可能为 null
  unit: string; // 单位
  packageQuantity: number; // 包装数量
  procurementPricing: number; // 采购价格
  supplyPricing: number; // 供应价格
  marketPrice: number; // 市场价格
  modifyPrice: number; // 修改价格
  supplyNames: string; // 供应商名称
  supplyName: string; // 供应商名称
  supplierId: string; // 供应商 ID
  aggregatePurchasePrice: number; // 综合采购价格
  images: string; // 图片 URL
  izConvert: string | null; // 是否转换，可能为 null
  realSpecification: string; // 实际规格
  placeOrigin: string; // 产地
  remarks: string | null; // 备注，可能为 null
  remark: string | null; // 备注，可能为 null
  testReport: string | null; // 测试报告，可能为 null
  supplyWay_dictText: string; // 供应方式描述
  quantitySupplied: string; // 供应数量
  marketWeight: number; // 市场重量
}

interface GeneratedTypeLiteralInterface_1 {
  current: number;
  pages: number;
  records: DemandPlanningRecord[];
  size: number;
  total: number;
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

interface Result {
  id: string;
  unitName:string;
  unitType:string;
}
interface ApiResponse {
  code: number
  message: string
  result: GeneratedTypeLiteralInterface_1
  success: boolean
  timestamp: number
}

interface SupplyOrder {
  name: string;
  jiage: string;
  gongyingshang: string;
}
interface Form {
  foodname: string;
  createtime: string;
  id1: string;
  jiage: string;
  time: string;
  kuchun: string;
  type: string;
  canbie: string;
  gongyingshang: string;
  groupname: string;
  price: string;
}
@Entry
@Component
struct Report {
  @State demandRecords: DemandPlanningRecord[]=[]
  @State loading:boolean=false
  @State dol:string=''
  @State verxiuqiu:string=''
  scroller: Scroller = new Scroller()
  @State private flag: number = 0;
  @State NocollectionColor: string = '0'
  @State SelectYesOrNo: string = '0'
  @State meassage1: string[] = []
  @State meassage2: string[] = []
  @State meassage3: string[] = []
  @State result: Result[] = [];
  @State j: number = 0;
  @State x: number = -1;
  @State selectedCount: number = 0;
  @State totalAmount: number = 0;
  @State caitotal: number = 0;
  @State showUnitPicker: boolean = false;
  @State selectedUnit: string = '';
  @State showDatePicker: boolean = false;
  @State selectedDate: string = '';
  @State selectedTime: string = ''; // 存储选择的供应时间
  @State showTimePicker: boolean = false; // 控制弹窗的显示
  @State selectedDemandType: string = ''; // 存储选择的需求类型
  @State showDemandPicker: boolean = false; // 控制弹窗的显示
  @State selectedMealCategory: string = ''; // 存储选择的餐别
  @State showMealPicker: boolean = false; // 控制弹窗的显示
  @State remarks: string = ''; // 存储输入的摘要内容
  @State showRemarksInput: boolean = false; // 控制弹窗的显示
  @State private dataList: Array<SupplyOrder> = [];
  @State n :string =''
  private creatNew(): void {
    const newOrder: SupplyOrder = {
      name: '',
      jiage: '',
      gongyingshang: ''
    };
    this.dataList = [...this.dataList, newOrder];
    this.flag = this.dataList.length > 0 ? 1 : 0;
    this.selectedCount += 1;
  }

  async fetchDemandPlannings() {
    try {
      this.loading = true
      let httpRequest = http.createHttp()
      let response = await httpRequest.request(
        'https://api.suoeryun.com/ifood/jeecg-school/school/xxDemandPlanning/addOrUpdate',
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiIyZjg5NWM4NDI2MWFlNzJiYmUyMjVkMjllOWJhZjVjZCIsImV4cCI6MTc0NzgxMzUyNywidXNlcm5hbWUiOiIxNTUwMjkzMzY3MyJ9.E7fWouQnZa4bFkflAFwU8BiZSr2ECxwKJ69OBD8blUY'
          },
          extraData: JSON.stringify({
            "unitId": "1917168448022519809",
            "supplyDate": this.selectedDate,
            "supplyTime":this.selectedTime,
            "requirementType": "1",
            "planningFoodList": [
              {
                "id": "",
                "storehouseId": null,
                "foodAndSupplierId": "1912742642345168897_1650750930200121346",
                "foodId": "1912742642345168897",
                "supplyWay": "1",
                "superiorLimit": null,
                "lowerLimit": null,
                "storageLocation": null,
                "stock": 13,
                "storehouseStatus": null,
                "izCollect": "0",
                "encoding": "600",
                "groupId": "1650034643157159951",
                "groupName": "干菜调料类",
                "foodName": "盐",
                "forShort": "盐",
                "internationalCode": null,
                "pinyinCode": "y",
                "specification": "计件",
                "expirationDay": 700,
                "brandLevel": "海天",
                "minDeclare": null,
                "unit": "袋",
                "packageQuantity": 0.4,
                "procurementPricing": 1,
                "supplyPricing": 1,
                "marketPrice": 0,
                "modifyPrice": 0,
                "supplyNames": "小韩食品批发",
                "supplyName": "小韩食品批发",
                "supplierId": "1650750930200121346",
                "aggregatePurchasePrice": 1,
                "images": "https://admin.suoeryun.com/pcUpload/1744868254748-0417133740.jpg",
                "izConvert": null,
                "realSpecification": "400g/袋",
                "placeOrigin": "得得",
                "remarks": null,
                "remark": null,
                "testReport": null,
                "supplyWay_dictText": "计划供应",
                "quantitySupplied": "11",
                "marketWeight": 22
              }
            ] as FoodItem[],
            "summary": "",
            "mealType": this.selectedDemandType,
            "mealCategory": this.selectedMealCategory,
            "unitName":this.selectedUnit ,
            "unitType": '1',
            "planningStatus": this.n
          }
          )
        }
      )
      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as ApiResponse
        if (result.success) {
          console.log('wpz666')
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
    //this.loadData();
    const params = router.getParams() as string;
    if (params) {
      const sourcePage = params['sourcePage'] as string;
      if(sourcePage=='re'){this.j = params['i']}
      this.x =0|| ++params['y']
      this.meassage1[this.x] = params['name']
      this.meassage2[this.x] = params['jiage']
      this.meassage3[this.x] = params['gongyingshang']
      this.fetchDemandPlannings()
    }
  }

  build() {
    Column() {

      Column() {
        Row() {
          Text('新建上报计划')
            .fontSize(20)
            .fontColor('#000000')
            .margin({ top: 20})
            .textAlign(TextAlign.Center)
        }
        Row() {
          Text('phone.suoeryun.com')
            .fontSize(14)
            .fontColor('#959D9D')
            .margin({bottom:20,top:3})
        }
      }
      .width('100%')
      .height(70)
      .backgroundColor('#EDEDED')

      Scroll(this.scroller) {
        Column() {
          Row() {
            Image($r('app.media.xuqiudanwei'))
              .width(20)
              .height(20)
              .margin({ right: 8 })

            Text('供应单位')
              .fontSize(15)
              .fontColor('#333333')
              .onClick(() => this.showUnitPicker = true)

            Text('*')
              .fontColor('#FF0000')
              .margin({ left: 4 })

            Text(this.selectedUnit || '请选择')
              .fontColor(this.selectedUnit ? '#333333' : '#999999')
              .layoutWeight(1)
              .margin({ left: 150 })


            Image($r('app.media.right_icon'))
              .width(16)
              .height(16)
              .margin({ left: 10 })
          }
          .padding(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 8 }) // 统一间距
          .onClick(() => {
            this.showUnitPicker = true;
          })


          // 供应日期
          Row() {
            Image($r('app.media.gongyingriqi'))
              .width(20)
              .height(20)
              .margin({ right: 8 })

            Text('供应日期')
              .fontSize(15)
              .fontColor('#333333')

            Text('*')
              .fontColor('#FF0000')
              .margin({ left: 4 })

            Text(this.selectedDate || '请选择')
              .fontColor(this.selectedDate ? '#333333' : '#999999')
              .margin({ left: 150 })
              .layoutWeight(1) // 占据剩余空间
            Image($r('app.media.right_icon'))
              .width(16)
              .height(16)
              .margin({ left: 10 })
          }
          .padding(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 8 }) // 统一间距
          .onClick(() => {
            this.showDatePicker = true;
          })

          // 供应时间
          Row() {
            Image($r('app.media.gongyingshijian'))
              .width(20)
              .height(20)
              .margin({ right: 8 })

            Text('供应时间')
              .fontSize(15)
              .fontColor('#333333')

            Text('*')
              .fontColor('#FF0000')
              .margin({ left: 4 })

            Text(this.selectedTime || '请选择')
              .fontColor(this.selectedTime ? '#333333' : '#999999')
              .margin({ left: 150 })
              .layoutWeight(1) // 占据剩余空间
            Image($r('app.media.right_icon'))
              .width(16)
              .height(16)
              .margin({ left: 10 })
          }
          .padding(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 8 })
          .margin({ bottom: 8 }) // 统一间距
          .onClick(() => {
            this.showTimePicker = true; // 点击后显示弹窗
          })

          // 需求类型
          Row() {
            Image($r('app.media.leixing'))
              .width(20)
              .height(20)
              .margin({ right: 8 })

            Text('需求类型')
              .fontSize(15)
              .fontColor('#333333')

            Text('*')
              .fontColor('#FF0000')
              .margin({ left: 4 })

            Text(this.selectedDemandType || '请选择')
              .fontColor(this.selectedDemandType ? '#333333' : '#999999')
              .margin({ left: 150 })
              .layoutWeight(1) // 占据剩余空间
            Image($r('app.media.right_icon'))
              .width(16)
              .height(16)
              .margin({ left: 10 })
          }
          .padding(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 8 }) // 统一间距
          .onClick(() => {
            this.showDemandPicker = true; // 点击后显示弹窗
          })

          // 餐别
          Row() {
            Image($r('app.media.canbie'))
              .width(20)
              .height(20)
              .margin({ right: 8 })

            Text('餐        别')
              .fontSize(15)
              .fontColor('#333333')

            Text('*')
              .fontColor('#FF0000')
              .margin({ left: 4 })

            Text(this.selectedMealCategory || '请选择')
              .fontColor(this.selectedMealCategory ? '#333333' : '#999999')
              .margin({ left: 150 })
              .layoutWeight(2) // 占据剩余空间
            Image($r('app.media.right_icon'))
              .width(16)
              .height(16)
              .margin({ left: 10 })
          }
          .padding(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 8 }) // 统一间距
          .onClick(() => {
            this.showMealPicker = true; // 点击后显示弹窗
          })

          // 摘要
          Row() {
            Image($r('app.media.zhaiyao'))
              .width(20)
              .height(20)
              .margin({ right: 8 })

            Text('摘        要')
              .fontSize(15)
              .fontColor('#333333')

            Text('*')
              .fontColor('#FF0000')
              .margin({ left: 4 })

            Text(this.remarks || '请输入摘要')
              .fontColor(this.remarks ? '#333333' : '#999999')
              .margin({ left: 120 })
              .layoutWeight(1) // 占据剩余空间
            Image($r('app.media.right_icon'))
              .width(16)
              .height(16)
              .margin({ left: 10 })
          }
          .padding(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 8 }) // 统一间距
          .onClick(() => {
            this.showRemarksInput = true; // 点击后显示弹窗
          })

          // 添加食材按钮
          Button('+添加食材', { type: ButtonType.Normal })
            .width('90%')
            .height(40)
            .backgroundColor('#4CAF50')
            .fontColor(Color.White)
            .margin({ top: 20 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/uploadPlan_3' ,params:{x:this.x}})
              this.creatNew()

            })

          //添加食材后的弹窗
          if (this.flag) {
            Column() {
              ForEach(this.dataList, (item: SupplyOrder, index) => {
                Stack() {
                  Column() {
                    Row({ space: 10 }) {
                      Text(this.meassage1[index])
                        .margin({ top: 40 })
                        .fontWeight(FontWeight.Bold)
                    }
                    .margin({ left: -190, top: 20 })

                    Row() {
                      Text('采 购 价:')
                        .width(80) // 设置固定宽度，确保对齐
                      Text(this.meassage2[index])
                        .fontWeight(FontWeight.Bold)
                        .fontColor(Color.Red)
                      Text(' 元/Kg')
                        .fontColor(Color.Red)
                    }
                    .margin({ left: -43, top: 5 }) // 调整左边距，确保左对齐

                    Row() {
                      Text('供 应 商:')
                        .width(80) // 设置固定宽度，确保对齐
                      Text(this.meassage3[index])
                    }
                    .margin({ left: 10, top: 5 }) // 调整左边距，确保左对齐

                    Row() {
                      Text('需 求 量:')
                        .width(80)
                      TextInput({
                        placeholder: ''
                      })
                        .onChange((value:string)=>{
                          this.dol = value
                          this.verxiuqiu = this.dol
                          this.caitotal = parseFloat(this.dol)*parseFloat(this.meassage2[1+index])
                        })
                        .height(30)
                        .width(80)

                      Text('  kg')
                    }
                    .margin({ left: -10, top: 1 })

                    Row() {
                      Text(' 合    计 ：')
                        .fontColor('#333333')
                      Text('    ' + `${this.caitotal.toFixed(2)}元`)
                        .fontColor('#FF5722')
                    }
                    //.margin({ left: -85, top: 1 })
                    .position({ x: 69, y: 163 })

                  }
                  .backgroundColor(Color.White)
                  .width('95%')
                  .height(200)
                  .borderRadius(5)
                  .border({
                    color: Color.Orange,
                    width: 2,
                    radius: 5
                  })

                  Row() {
                    Text('称重')
                      .fontSize(12)
                      .margin({ top: 50, left: 30 })
                      .fontColor(Color.White)
                  }
                  .width(80)
                  .height(80)
                  .backgroundColor(Color.Orange)
                  .position({ x: -60, y: 10 })
                  .rotate({ angle: -50, centerX: 0, centerY: 0 })
                  .clip(true)

                  Row() {

                  }
                  .width(80)
                  .height(80)
                  .backgroundColor(this.SelectYesOrNo === '0' ? Color.Gray : '#1a8b00')
                  .position({ x: 290, y: 200 })
                  .rotate({ angle: -50, centerX: 0, centerY: 0 })

                  if (this.SelectYesOrNo === '1') {
                    // Row() {
                    //   // Image($r('app.media.123'))
                    //   //   .borderRadius(100)
                    //
                    //     .width(25)
                    //     .margin({ left: 305, top: 125 })
                    // }
                  }
                }
                .height(200)
                .clip(true)
                .margin({ top: 10 })
              })
            }
            //.height(100)
          }



          // 已选计数
          Text(`已选中${this.selectedCount}种食材`)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })

          // 总计金额
          Row() {
            Text('总计：')
              .fontSize(18)
              .fontColor('#333333')
            Text(`${this.caitotal.toFixed(2)}元`)
              .fontSize(18)
              .fontColor('#FF5722')
          }
          .width('90%')
          .height(200)
          .margin({ top: 20 })
        }

        // 需求单位
      }
      .height(570)
      .backgroundColor(Color.White)
      .margin({ top: 20 })

      // 底部按钮
      Row({ space: 20 }) {
        Button('保存', { type: ButtonType.Normal })
          .width(160)
          .height(45)
          .backgroundColor('#E0E0E0')
          .fontColor('#333333')
          .onClick(() => {
            this.n='1'
            this.fetchDemandPlannings()
          })

        Button('保存上报', { type: ButtonType.Normal })
          .width(160)
          .height(45)
          .backgroundColor('#E0E0E0')
          .fontColor('#333333')
          .onClick(() => {
            AlertDialog.show({
              title: '确认提交',
              message: '确定要提交审核吗？',
              confirm: {
                value: '确定',
                action: () => {
                }
              }
            })
            this.n='5'
            this.fetchDemandPlannings()
          })
      }
      .width('100%')
      .height(100)
      .margin({ bottom: 20, left: 20 })

      // 需求单位弹窗
      if (this.showUnitPicker) {
        Column() {
          Blank()
            .height(10000)
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showUnitPicker = false;
            })

          Column() {
            Text('实训第一学校库房')
              .fontSize(20)
              .width('100%')
              .padding(10)
              .fontColor('#333333')
              .backgroundColor(Color.White)
              .onClick(() => {
                this.selectedUnit = '实训第一学校库房';
                this.showUnitPicker = false;
              })

            Divider().color('#EEEEEE')

            Text('实训第一学校餐厅')
              .fontSize(20)
              .width('100%')
              .padding(16)
              .fontColor('#333333')
              .backgroundColor(Color.White)
              .onClick(() => {
                this.selectedUnit = '实训第一学校餐厅';
                this.showUnitPicker = false;
              })
          }
          .width('80%')
          .backgroundColor(Color.White)
          .borderRadius(8)
          .position({ x: '10%', y: '40%' })
        }
        .position({ x: 0, y: 0 })
        .width('100%')
        .height('100%')
        .zIndex(999)
      }

      // 日期选择弹窗
      if (this.showDatePicker) {
        Column() {
          Blank()
            .height(10000)
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showDatePicker = false;
            })


          Column() {
            DatePicker({
              start: new Date('2020-01-01'),
              end: new Date('2030-12-31'),
              selected: this.selectedDate ? new Date(this.selectedDate) : new Date()
            })
              .onChange((value: DatePickerResult) => {
                if (value?.year && value?.month && value?.day) {
                  // 同时更新两个状态
                  this.selectedDate =
                    `${value.year}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString()
                      .padStart(2, '0')}`;
                }
              })

            Row() {
              Button('确定')
                .onClick(() => {
                  this.showDatePicker = false;

                })
            }
          }
          .width('90%')
          .backgroundColor(Color.White)
          .borderRadius(16)
          .padding(10)
          .position({ x: '5%', y: '30%' })
        }
        .position({ x: 0, y: 0 })
        .width('100%')
        .height('100%')
        .zIndex(999)
      }

      // 时间选择弹窗
      if (this.showTimePicker) {
        Column() {
          Blank()
            .height(10000)
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showTimePicker = false; // 点击空白区域关闭弹窗
            })

          Column() {
            Text('上午')
              .width('100%')
              .padding(16)
              .fontColor('#333333')
              .backgroundColor(Color.White)
              .onClick(() => {
                this.selectedTime = '上午'; // 选择上午
                this.showTimePicker = false; // 关闭弹窗
              })

            Divider().color('#EEEEEE')

            Text('下午')
              .width('100%')
              .padding(16)
              .fontColor('#333333')
              .backgroundColor(Color.White)
              .onClick(() => {
                this.selectedTime = '下午'; // 选择下午
                this.showTimePicker = false; // 关闭弹窗
              })
          }
          .width('80%')
          .backgroundColor(Color.White)
          .borderRadius(8)
          .position({ x: '10%', y: '40%' })
        }
        .position({ x: 0, y: 0 })
        .width('100%')
        .height('100%')
        .zIndex(999)
      }

      if (this.showDemandPicker) {
        Column() {
          Blank()
            .height(10000)
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showDemandPicker = false; // 点击空白区域关闭弹窗
            })

          Column() {
            Text('学生餐')
              .padding(16)
              .fontSize(20)
              .onClick(() => {
                this.selectedDemandType = '学生餐';
                this.showDemandPicker = false;
              })

            Divider()

            Text('教师餐')
              .padding(16)
              .fontSize(20)
              .onClick(() => {
                this.selectedDemandType = '教师餐';

                this.showDemandPicker = false;
              })
          }
          .width('80%')
          .backgroundColor(Color.White)
          .borderRadius(8)
          .position({ x: '10%', y: '40%' })
        }
        .position({ x: 0, y: 0 })
        .width('100%')
        .height('100%')
        .zIndex(999)
      }
      if (this.showMealPicker) {
        Column() {
          Blank()
            .height(10000)
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showMealPicker = false; // 点击空白区域关闭弹窗
            })

          Column() {
            Text('其他')
              .textAlign(TextAlign.Center)
              .width('100%')
              .padding(16)
              .fontColor('#333333')
              .backgroundColor(Color.White)
              .onClick(() => {
                this.selectedMealCategory = '其他'; // 选择其他
                this.showMealPicker = false; // 关闭弹窗
              })

            Divider().color('#EEEEEE')

            Text('早餐')
              .textAlign(TextAlign.Center)
              .width('100%')
              .padding(16)
              .fontColor('#333333')
              .backgroundColor(Color.White)
              .onClick(() => {
                this.selectedMealCategory = '早餐'; // 选择早餐
                this.showMealPicker = false; // 关闭弹窗
              })

            Divider().color('#EEEEEE')

            Text('午餐')
              .textAlign(TextAlign.Center)
              .width('100%')
              .padding(16)
              .fontColor('#333333')
              .backgroundColor(Color.White)
              .onClick(() => {
                this.selectedMealCategory = '午餐'; // 选择午餐
                this.showMealPicker = false; // 关闭弹窗
              })

            Divider().color('#EEEEEE')

            Text('晚餐')
              .textAlign(TextAlign.Center)
              .width('100%')
              .padding(16)
              .fontColor('#333333')
              .backgroundColor(Color.White)
              .onClick(() => {
                this.selectedMealCategory = '晚餐'; // 选择晚餐
                this.showMealPicker = false; // 关闭弹窗
              })
          }
          .width('80%')
          .backgroundColor(Color.White)
          .borderRadius(8)
          .position({ x: '10%', y: '30%' })
        }
        .position({ x: 0, y: 0 })
        .width('100%')
        .height('100%')
        .zIndex(999)
      }
      if (this.showRemarksInput) {
        Column() {
          Blank()
            .height(10000)
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showRemarksInput = false; // 点击空白区域关闭弹窗
            })

          Column() {
            TextInput({ placeholder: '请输入摘要内容', text: this.remarks })
              .onChange((value: string) => {
                this.remarks = value; // 更新摘要内容
              })
              .width('90%')
              .height(100)
              .padding(10)
              .backgroundColor(Color.White)

            Row({ space: 20 }) {
              Button('取消')
                .onClick(() => {
                  this.showRemarksInput = false; // 关闭弹窗
                })
                .width(100)
                .height(40)
                .backgroundColor('#E0E0E0')
                .fontColor('#333333')

              Button('确定')
                .onClick(() => {
                  this.showRemarksInput = false; // 关闭弹窗
                })
                .width(100)
                .height(40)
                .backgroundColor('#4CAF50')
                .fontColor(Color.White)
            }
            .margin({ top: 10 })
            .justifyContent(FlexAlign.Center)
          }
          .width('80%')
          .backgroundColor(Color.White)
          .borderRadius(8)
          .padding(16)
          .position({ x: '10%', y: '30%' })
        }
        .position({ x: 0, y: 0 })
        .width('100%')
        .height('100%')
        .zIndex(999)
      }
    }
    .width('100%')
    .height('100%')

    // .backgroundColor('#F8F8F8')
  }
}
