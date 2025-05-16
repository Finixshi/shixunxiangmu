import router from '@ohos.router'
import http from '@ohos.net.http'
import promptAction from '@ohos.promptAction'
import common from '@ohos.app.ability.common'

// 路由参数接口
interface RouterParams {
  orderDetail: DeliveryOrderDetail
}

// 路由返回参数接口
interface StatusUpdateParams {
  action: string
  orderId: string
  newStatus: number
  timestamp: number  // 添加时间戳以确保每次更新都是唯一的
}

// 配送单详情接口
interface DeliveryOrderDetail {
  orderId: string         // 单据号
  supplyTime: string      // 供应时间
  demandUnit: string      // 需求单位
  orderPerson: string     // 下单人
  orderPhone: string      // 下单电话
  summary: string         // 摘要
  schoolName: string      // 学校名称
  status: number          // 状态
}

// 食品项目接口
interface FoodItem {
  name: string            // 食品名称
  brand: string           // 品牌
  planQuantity: string    // 计划数量
  deliveryQuantity: number // 配送数量(斤)
  deliveryQuantityKg: number // 配送数量(千克)
  unitPrice: number       // 供应价
  total: number           // 合计
  productionDate: string  // 生产日期
  notes: string           // 备注
  inspectionReport: string[] // 检验报告图片
}

@Entry
@Component
struct PeisongdanDetailghPage {
  @State orderDetail: DeliveryOrderDetail = {
    orderId: 'PS20250514004',
    supplyTime: '2025-05-12',
    demandUnit: '实训第二学校(库房)',
    orderPerson: '人',
    orderPhone: '15502933673',
    summary: '',
    schoolName: '实训第二学校',
    status: 0
  }
  
  @State currentFoodItem: FoodItem = {
    name: '绿豆',
    brand: '农家',
    planQuantity: '2斤 (1Kg)',
    deliveryQuantity: 2,
    deliveryQuantityKg: 1,
    unitPrice: 12.96,
    total: 12.96,
    productionDate: '请选择日期',
    notes: '',
    inspectionReport: []
  }
  
  @State totalPrice: number = 12.96
  @State deliveryPerson: string = '请选择配送人'
  @State showDeliveryPersonPicker: boolean = false
  @State deliveryPersonOptions: string[] = ['张三', '李四', '王五']
  
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as RouterParams
    if (params && params.orderDetail) {
      this.orderDetail = params.orderDetail
    }
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          })
        
        Text('配送单详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Text('⋯')
          .fontSize(24)
          .fontColor('#333333')
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      
      // 页面主体内容
      Scroll() {
        Column() {
          // 订单信息卡片
          Column() {
            Row() {
              // 学校名称
              Text(this.orderDetail.schoolName)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)
                .layoutWeight(1)
              
              // 状态标记，根据订单状态显示不同文本和颜色
              Stack({ alignContent: Alignment.TopStart }) {
                Text(this.getStatusText(this.orderDetail.status))
                  .fontSize(14)
                  .fontColor(this.getStatusColor(this.orderDetail.status))
                  .backgroundColor('#FFFFFF')
                  .padding(10)
                  .borderRadius(24)
                  .border({ 
                    width: 2, 
                    color: this.getStatusColor(this.orderDetail.status), 
                    style: BorderStyle.Solid 
                  })
              }
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            // 订单信息行
            this.InfoRow('单 据 号:', this.orderDetail.orderId)
            this.InfoRow('供应时间:', this.orderDetail.supplyTime)
            this.InfoRow('需求单位:', this.orderDetail.demandUnit)
            this.InfoRow('下 单 人:', this.orderDetail.orderPerson)
            this.InfoRow('下单电话:', this.orderDetail.orderPhone)
            
            // 配送人选择
            Row() {
              Text('配 送 人:')
                .fontSize(14)
                .fontColor('#666666')
                .width(80)
              
              Row() {
                Text(this.deliveryPerson)
                  .fontSize(14)
                  .fontColor('#666666')
                
                Text('▼')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ left: 4 })
              }
              .onClick(() => {
                // 显示配送人选择对话框
                promptAction.showDialog({
                  title: '选择配送人',
                  message: '请选择配送人',
                  buttons: [
                    {
                      text: '张三',
                      color: '#007DFF'
                    },
                    {
                      text: '李四',
                      color: '#007DFF'
                    },
                    {
                      text: '王五',
                      color: '#007DFF'
                    }
                  ]
                }, (err, data) => {
                  if (err) {
                    console.error(`选择配送人出错: ${JSON.stringify(err)}`)
                    return
                  }
                  if (data.index >= 0 && data.index < this.deliveryPersonOptions.length) {
                    this.deliveryPerson = this.deliveryPersonOptions[data.index]
                  }
                })
              })
            }
            .width('100%')
            .margin({ top: 6, bottom: 6 })
            .alignItems(VerticalAlign.Center)
            
            // 摘要信息
            this.InfoRow('摘    要:', this.orderDetail.summary || '-')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .borderWidth(1)
          .borderColor('#31B46A')
          .margin({ top: 16, bottom: 16, left: 16, right: 16 })
          
          // 操作按钮区
          Row() {
            Button('+ 添加食材')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#31B46A')
              .borderRadius(4)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .margin({ right: 8 })
              .onClick(() => {
                promptAction.showToast({
                  message: '添加食材功能暂未实现',
                  duration: 2000
                })
              })
            
            Button('+ 批量添加检验报告')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#1E88E5')
              .borderRadius(4)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .onClick(() => {
                promptAction.showToast({
                  message: '批量添加检验报告功能暂未实现',
                  duration: 2000
                })
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .justifyContent(FlexAlign.Start)
          
          // 食品项目卡片
          Column() {
            // 新鲜角标
            Stack({ alignContent: Alignment.TopStart }) {
              Text('新鲜')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF9800')
                .padding(4)
                .borderRadius({ topLeft: 8, bottomRight: 8 })
            }
            .width('100%')
            
            // 食品名称
            Text(this.currentFoodItem.name)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 8, bottom: 16 })
            
            // 食品详情
            this.InfoRow('品    牌:', this.currentFoodItem.brand)
            this.InfoRow('计划数量:', this.currentFoodItem.planQuantity)
            
            // 配送数量(斤)
            Row() {
              Text('配送数量:')
                .fontSize(14)
                .fontColor('#666666')
                .width(80)
              
              TextInput({ text: this.currentFoodItem.deliveryQuantity.toString() })
                .width('30%')
                .height(40)
                .backgroundColor('#F5F5F5')
                .type(InputType.Number)
                .onChange((value) => {
                  const qty = Number(value)
                  if (!isNaN(qty)) {
                    this.currentFoodItem.deliveryQuantity = qty
                    // 更新千克数量和总价
                    this.currentFoodItem.deliveryQuantityKg = qty / 2 // 假设1斤=0.5kg
                    this.currentFoodItem.total = this.currentFoodItem.deliveryQuantityKg * this.currentFoodItem.unitPrice
                    this.totalPrice = this.currentFoodItem.total
                  }
                })
              
              Text('斤')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 8 })
            }
            .width('100%')
            .margin({ top: 12, bottom: 12 })
            .alignItems(VerticalAlign.Center)
            
            // 配送数量(千克)
            Row() {
              Text('配送数量:')
                .fontSize(14)
                .fontColor('#666666')
                .width(80)
              
              TextInput({ text: this.currentFoodItem.deliveryQuantityKg.toString() })
                .width('30%')
                .height(40)
                .backgroundColor('#F5F5F5')
                .type(InputType.Number)
                .onChange((value) => {
                  const qty = Number(value)
                  if (!isNaN(qty)) {
                    this.currentFoodItem.deliveryQuantityKg = qty
                    // 更新斤数量和总价
                    this.currentFoodItem.deliveryQuantity = qty * 2 // 假设1kg=2斤
                    this.currentFoodItem.total = this.currentFoodItem.deliveryQuantityKg * this.currentFoodItem.unitPrice
                    this.totalPrice = this.currentFoodItem.total
                  }
                })
              
              Text('Kg')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 8 })
            }
            .width('100%')
            .margin({ top: 12, bottom: 12 })
            .alignItems(VerticalAlign.Center)
            
            // 供应价
            Row() {
              Text('供 应 价:')
                .fontSize(14)
                .fontColor('#666666')
                .width(80)
              
              TextInput({ text: this.currentFoodItem.unitPrice.toString() })
                .width('30%')
                .height(40)
                .backgroundColor('#F5F5F5')
                .type(InputType.Number)
                .onChange((value) => {
                  const price = Number(value)
                  if (!isNaN(price)) {
                    this.currentFoodItem.unitPrice = price
                    // 更新总价
                    this.currentFoodItem.total = this.currentFoodItem.deliveryQuantityKg * this.currentFoodItem.unitPrice
                    this.totalPrice = this.currentFoodItem.total
                  }
                })
              
              Text('元/Kg')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 8 })
            }
            .width('100%')
            .margin({ top: 12, bottom: 12 })
            .alignItems(VerticalAlign.Center)
            
            // 合计
            Row() {
              Text('合    计:')
                .fontSize(14)
                .fontColor('#666666')
                .width(80)
              
              Text(this.currentFoodItem.total.toString() + '元')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF5722')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ top: 12, bottom: 12 })
            .alignItems(VerticalAlign.Center)
            
            // 生产日期
            Row() {
              Text('生产日期:')
                .fontSize(14)
                .fontColor('#666666')
                .width(80)
              
              Row() {
                Text(this.currentFoodItem.productionDate)
                  .fontSize(14)
                  .fontColor('#666666')
                
                Text('▼')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ left: 4 })
              }
              .onClick(() => {
                DatePickerDialog.show({
                  start: new Date('2020-01-01'),
                  end: new Date(),
                  selected: new Date(),
                  onAccept: (value) => {
                    if (value && value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                      const year = value.year
                      const month = String(value.month + 1).padStart(2, '0')
                      const day = String(value.day).padStart(2, '0')
                      this.currentFoodItem.productionDate = `${year}-${month}-${day}`
                    }
                  }
                })
              })
            }
            .width('100%')
            .margin({ top: 12, bottom: 12 })
            .alignItems(VerticalAlign.Center)
            
            // 备注
            Row() {
              Text('备    注:')
                .fontSize(14)
                .fontColor('#666666')
                .width(80)
              
              TextInput({ placeholder: '请输入备注' })
                .width('70%')
                .height(40)
                .backgroundColor('#F5F5F5')
                .onChange((value) => {
                  this.currentFoodItem.notes = value
                })
            }
            .width('100%')
            .margin({ top: 12, bottom: 12 })
            .alignItems(VerticalAlign.Center)
            
            // 检验报告
            Row() {
              Text('检验报告 *')
                .fontSize(14)
                .fontColor('#666666')
                .width(80)
              
              Blank()
              
              Text('0/10')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .margin({ top: 12, bottom: 12 })
            .alignItems(VerticalAlign.Center)
            
            // 添加检验报告图片按钮
            Row() {
              Column() {
                Text('+')
                  .fontSize(40)
                  .fontColor('#999999')
              }
              .width(100)
              .height(100)
              .backgroundColor('#F5F5F5')
              .justifyContent(FlexAlign.Center)
              .alignSelf(ItemAlign.Center)
              .borderRadius(8)
              .onClick(() => {
                promptAction.showToast({
                  message: '上传检验报告功能暂未实现',
                  duration: 2000
                })
              })
            }
            .width('100%')
            .padding({ top: 8, bottom: 16 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .borderWidth(1)
          .borderColor('#31B46A')
          .margin({ bottom: 16, left: 16, right: 16 })
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      
      // 底部操作区
      Row() {
        Column() {
          Text('总计:')
            .fontSize(14)
            .fontColor('#333333')
          
          Text(this.totalPrice.toString() + '元')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF5722')
        }
        .alignSelf(ItemAlign.Start)
        .layoutWeight(1)
        
        Row() {
          // 保存按钮始终显示
          Button('保存')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#1E88E5')
            .borderRadius(4)
            .width(100)
            .height(40)
            .margin({ right: 8 })
            .onClick(() => {
              promptAction.showToast({
                message: '保存成功',
                duration: 2000
              })
              setTimeout(() => {
                router.back()
              }, 2000)
            })
          
          // 根据订单状态显示不同的操作按钮
          if (this.orderDetail.status === 0) { // 未配送
            Button('去配送')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#31B46A')
              .borderRadius(4)
              .width(100)
              .height(40)
              .onClick(() => {
                // 通知前一页面更新订单状态
                const eventData: StatusUpdateParams = {
                  action: 'updateOrderStatus',
                  orderId: this.orderDetail.orderId,
                  newStatus: 1, // 1 表示配送中状态
                  timestamp: Date.now() // 添加时间戳确保唯一性
                }
                
                // 打印日志便于调试
                console.info(`发送更新订单状态事件: ${JSON.stringify(eventData)}`)
                
                // 将数据存储在全局上下文中，以便在返回时获取
                globalThis.statusUpdateParams = eventData
                
                promptAction.showToast({
                  message: '配送单已进入配送中状态',
                  duration: 2000
                })
                
                // 使用延时确保全局变量设置完成后再返回
                setTimeout(() => {
                  try {
                    console.info('开始返回配送单列表页...')
                    
                    // 尝试使用返回参数，虽然router.back不支持传参，但记录尝试
                    router.back()
                    
                    // 确保状态更新参数存在
                    console.info(`检查全局参数是否存在: ${globalThis.statusUpdateParams ? '是' : '否'}`)
                  } catch (error) {
                    console.error(`返回页面时发生错误: ${JSON.stringify(error)}`)
                  }
                }, 500)
              })
          } else if (this.orderDetail.status === 1) { // 配送中
            Button('确认货已送达')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#31B46A')
              .borderRadius(4)
              .width(140)
              .height(40)
              .onClick(() => {
                // 通知前一页面更新订单状态
                const eventData: StatusUpdateParams = {
                  action: 'updateOrderStatus',
                  orderId: this.orderDetail.orderId,
                  newStatus: 2, // 2 表示已收货状态
                  timestamp: Date.now() // 添加时间戳确保唯一性
                }
                
                // 打印日志便于调试
                console.info(`发送更新订单状态事件: ${JSON.stringify(eventData)}`)
                
                // 将数据存储在全局上下文中，以便在返回时获取
                globalThis.statusUpdateParams = eventData
                
                promptAction.showToast({
                  message: '配送单已确认收货',
                  duration: 2000
                })
                
                // 使用延时确保全局变量设置完成后再返回
                setTimeout(() => {
                  try {
                    console.info('开始返回配送单列表页...')
                    router.back()
                  } catch (error) {
                    console.error(`返回页面时发生错误: ${JSON.stringify(error)}`)
                  }
                }, 500)
              })
          } else if (this.orderDetail.status === 2) { // 已收货
            Button('打印回执')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF9800')
              .borderRadius(4)
              .width(100)
              .height(40)
              .onClick(() => {
                promptAction.showToast({
                  message: '打印功能暂未实现',
                  duration: 2000
                })
              })
          }
        }
      }
      .width('100%')
      .height(70)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderWidth({ top: 1 })
      .borderColor('#EEEEEE')
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width(80)
      
      Text(value)
        .fontSize(14)
        .fontColor('#333333')
    }
    .width('100%')
    .margin({ top: 6, bottom: 6 })
    .alignItems(VerticalAlign.Center)
  }
  
  getStatusText(status: number): string {
    switch (status) {
      case 0:
        return '未配送'
      case 1:
        return '配送中'
      case 2:
        return '已收货'
      default:
        return '未知状态'
    }
  }
  
  getStatusColor(status: number): string {
    switch (status) {
      case 0:
        return '#009688'
      case 1:
        return '#FF9800'
      case 2:
        return '#31B46A'
      default:
        return '#999999'
    }
  }
} 