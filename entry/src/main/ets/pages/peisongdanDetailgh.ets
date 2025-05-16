import router from '@ohos.router'
import http from '@ohos.net.http'
import { promptAction } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'

// 按钮接口定义
interface ActionButton {
  text: string
  color: string
}

// 操作菜单结果接口
interface ActionMenuResult {
  index: number
}

// 路由参数接口
interface RouterParams {
  orderDetail: DeliveryOrderDetail
  selectedFoodItems?: FoodItem[]
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

// 日期选择结果接口
interface DatePickerResult {
  year?: number
  month?: number
  day?: number
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
  id?: string             // 可选ID
  specification?: string  // 可选规格
  unit?: string           // 可选单位
  price?: number          // 可选价格
  type?: string           // 可选类型
  isNew?: boolean         // 可选是否新品
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
  
  @State foodItems: FoodItem[] = []  // 存储所有食材
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
    
    // 尝试从全局变量恢复食材列表
    if (globalThis.savedFoodItems && Array.isArray(globalThis.savedFoodItems) && globalThis.savedFoodItems.length > 0) {
      console.info('从全局变量恢复食材列表:', JSON.stringify(globalThis.savedFoodItems))
      this.foodItems = globalThis.savedFoodItems
      
      // 设置当前显示的食材为第一个
      if (this.foodItems.length > 0) {
        this.currentFoodItem = this.foodItems[0]
      }
      
      // 计算总价
      this.calcTotalPrice()
      
      return // 如果已从全局变量恢复，就不再初始化默认数据
    }
    
    // 初始化食材列表，添加默认的绿豆
    if (this.foodItems.length === 0) {
      this.foodItems = [this.currentFoodItem]
    }
    
    // 检查是否有从添加食材页面返回的数据
    if (params && params.selectedFoodItems) {
      // 处理新添加的食材
      this.handleAddedFoodItems(params.selectedFoodItems)
    }
  }
  
  // 页面显示时也检查路由参数
  onPageShow() {
    const params = router.getParams() as RouterParams
    
    // 尝试从全局变量恢复食材列表
    if (globalThis.savedFoodItems && Array.isArray(globalThis.savedFoodItems) && globalThis.savedFoodItems.length > 0) {
      console.info('onPageShow: 从全局变量恢复食材列表:', JSON.stringify(globalThis.savedFoodItems))
      this.foodItems = globalThis.savedFoodItems
      
      // 设置当前显示的食材为第一个
      if (this.foodItems.length > 0) {
        this.currentFoodItem = this.foodItems[0]
      }
      
      // 计算总价
      this.calcTotalPrice()
    }
    
    // 检查是否有从添加食材页面返回的数据
    if (params && params.selectedFoodItems) {
      console.info('从添加食材页面返回，接收到食材数据:', JSON.stringify(params.selectedFoodItems))
      // 处理新添加的食材
      this.handleAddedFoodItems(params.selectedFoodItems)
    }
  }
  
  // 处理新添加的食材
  handleAddedFoodItems(newItems: FoodItem[]) {
    try {
      if (!Array.isArray(newItems) || newItems.length === 0) {
        console.info('没有需要添加的食材或食材数据格式不正确')
        return
      }
      
      console.info(`开始处理${newItems.length}种新食材...`)
      console.info('当前食材列表:', JSON.stringify(this.foodItems))
      
      // 将API返回的食材格式转换为应用内部使用的FoodItem格式
      for (const item of newItems) {
        console.info('处理食材:', JSON.stringify(item))
        
        const newFoodItem: FoodItem = {
          name: item.name || '未知食材',
          brand: item.brand || '未知品牌',
          planQuantity: item.specification || '1份',
          deliveryQuantity: 1,
          deliveryQuantityKg: 0.5, // 默认0.5kg
          unitPrice: item.price || 0,
          total: item.price ? item.price * 0.5 : 0,
          productionDate: '请选择日期',
          notes: '',
          inspectionReport: []
        }
        
        console.info('转换后的食材格式:', JSON.stringify(newFoodItem))
        
        // 检查是否已经添加过相同名称的食材
        const existingIndex = this.foodItems.findIndex(food => food.name === newFoodItem.name)
        if (existingIndex >= 0) {
          console.info(`食材"${newFoodItem.name}"已存在，更新数量`)
          // 如果已经添加过，则更新数量
          this.foodItems[existingIndex].deliveryQuantity += 1
          this.foodItems[existingIndex].deliveryQuantityKg += 0.5
          this.foodItems[existingIndex].total = this.foodItems[existingIndex].deliveryQuantityKg * this.foodItems[existingIndex].unitPrice
        } else {
          console.info(`添加新食材"${newFoodItem.name}"`)
          // 如果是新食材，则添加到列表
          this.foodItems.push(newFoodItem)
        }
      }
      
      // 强制UI更新
      this.foodItems = [...this.foodItems]
      
      console.info('处理后的食材列表:', JSON.stringify(this.foodItems))
      
      // 重新计算总价
      this.calcTotalPrice()
      
      // 设置当前显示的食材为第一个
      if (this.foodItems.length > 0) {
        this.currentFoodItem = this.foodItems[0]
      }
      
      promptAction.showToast({
        message: `成功添加${newItems.length}种食材`,
        duration: 2000
      })
    } catch (error) {
      console.error('处理添加的食材失败:', JSON.stringify(error))
      
      promptAction.showToast({
        message: '添加食材失败，请重试',
        duration: 2000
      })
    }
  }
  
  // 计算总价
  calcTotalPrice() {
    let total = 0
    for (const item of this.foodItems) {
      total += item.total
    }
    this.totalPrice = total
  }
  
  // 切换当前显示的食材
  switchCurrentFoodItem(index: number) {
    if (index >= 0 && index < this.foodItems.length) {
      this.currentFoodItem = this.foodItems[index]
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
                // 使用ActionMenu选择配送人
                promptAction.showActionMenu({
                  title: '选择配送人',
                  buttons: [
                    {
                      text: this.deliveryPersonOptions[0],
                      color: '#333333'
                    },
                    {
                      text: this.deliveryPersonOptions[1],
                      color: '#333333'
                    },
                    {
                      text: this.deliveryPersonOptions[2],
                      color: '#333333'
                    }
                  ]
                }).then((result: ActionMenuResult) => {
                  if (result.index >= 0 && result.index < this.deliveryPersonOptions.length) {
                    this.deliveryPerson = this.deliveryPersonOptions[result.index]
                  }
                }).catch((err: Error) => {
                  console.error(`选择配送人出错: ${err.message}`)
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
                // 跳转到添加食材页面
                router.pushUrl({
                  url: 'pages/addFoodItemsPage'
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
          
          // 食材卡片列表
          ForEach(this.foodItems, (item: FoodItem, index: number) => {
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
              Text(item.name)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 8, bottom: 16 })
              
              // 食品详情
              this.InfoRow('品    牌:', item.brand)
              this.InfoRow('计划数量:', item.planQuantity)
              
              // 配送数量(斤)
              Row() {
                Text('配送数量:')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80)
                
                TextInput({ text: item.deliveryQuantity.toString() })
                  .width('30%')
                  .height(40)
                  .backgroundColor('#F5F5F5')
                  .type(InputType.Number)
                  .onChange((value) => {
                    const qty = Number(value)
                    if (!isNaN(qty)) {
                      item.deliveryQuantity = qty
                      // 更新千克数量和总价
                      item.deliveryQuantityKg = qty / 2 // 假设1斤=0.5kg
                      item.total = item.deliveryQuantityKg * item.unitPrice
                      
                      // 如果正在显示的是当前项，也更新currentFoodItem
                      if (this.foodItems.indexOf(item) === this.foodItems.indexOf(this.currentFoodItem)) {
                        this.currentFoodItem.deliveryQuantity = item.deliveryQuantity
                        this.currentFoodItem.deliveryQuantityKg = item.deliveryQuantityKg
                        this.currentFoodItem.total = item.total
                      }
                      
                      // 重新计算总价
                      this.calcTotalPrice()
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
                
                TextInput({ text: item.deliveryQuantityKg.toString() })
                  .width('30%')
                  .height(40)
                  .backgroundColor('#F5F5F5')
                  .type(InputType.Number)
                  .onChange((value) => {
                    const qty = Number(value)
                    if (!isNaN(qty)) {
                      item.deliveryQuantityKg = qty
                      // 更新斤数量和总价
                      item.deliveryQuantity = qty * 2 // 假设1kg=2斤
                      item.total = item.deliveryQuantityKg * item.unitPrice
                      
                      // 如果正在显示的是当前项，也更新currentFoodItem
                      if (this.foodItems.indexOf(item) === this.foodItems.indexOf(this.currentFoodItem)) {
                        this.currentFoodItem.deliveryQuantity = item.deliveryQuantity
                        this.currentFoodItem.deliveryQuantityKg = item.deliveryQuantityKg
                        this.currentFoodItem.total = item.total
                      }
                      
                      // 重新计算总价
                      this.calcTotalPrice()
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
                
                TextInput({ text: item.unitPrice.toString() })
                  .width('30%')
                  .height(40)
                  .backgroundColor('#F5F5F5')
                  .type(InputType.Number)
                  .onChange((value) => {
                    const price = Number(value)
                    if (!isNaN(price)) {
                      item.unitPrice = price
                      // 更新总价
                      item.total = item.deliveryQuantityKg * item.unitPrice
                      
                      // 如果正在显示的是当前项，也更新currentFoodItem
                      if (this.foodItems.indexOf(item) === this.foodItems.indexOf(this.currentFoodItem)) {
                        this.currentFoodItem.deliveryQuantity = item.deliveryQuantity
                        this.currentFoodItem.deliveryQuantityKg = item.deliveryQuantityKg
                        this.currentFoodItem.total = item.total
                      }
                      
                      // 重新计算总价
                      this.calcTotalPrice()
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
                
                Text(item.total.toString() + '元')
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
                  Text(item.productionDate)
                    .fontSize(14)
                    .fontColor('#666666')
                  
                  Text('▼')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ left: 4 })
                }
                .onClick(() => {
                  // 使用ActionMenu选择生产日期
                  let dates = ['2022-01-01', '2022-01-02', '2022-01-03', '2022-01-04', '2022-01-05']
                  promptAction.showActionMenu({
                    title: '选择生产日期',
                    buttons: [
                      {
                        text: dates[0],
                        color: '#333333'
                      },
                      {
                        text: dates[1],
                        color: '#333333'
                      },
                      {
                        text: dates[2],
                        color: '#333333'
                      },
                      {
                        text: dates[3],
                        color: '#333333'
                      },
                      {
                        text: dates[4],
                        color: '#333333'
                      }
                    ]
                  }).then((result: ActionMenuResult) => {
                    if (result.index >= 0 && result.index < dates.length) {
                      item.productionDate = dates[result.index]
                      
                      // 如果正在显示的是当前项，也更新currentFoodItem
                      if (this.foodItems.indexOf(item) === this.foodItems.indexOf(this.currentFoodItem)) {
                        this.currentFoodItem.productionDate = item.productionDate
                      }
                      
                      // 重新计算总价（虽然日期不影响价格，但保持一致性）
                      this.calcTotalPrice()
                    }
                  }).catch((err: Error) => {
                    console.error(`选择生产日期出错: ${err.message}`)
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
                
                TextInput({ placeholder: '请输入备注', text: item.notes })
                  .width('70%')
                  .height(40)
                  .backgroundColor('#F5F5F5')
                  .onChange((value) => {
                    item.notes = value
                    
                    // 如果正在显示的是当前项，也更新currentFoodItem
                    if (this.foodItems.indexOf(item) === this.foodItems.indexOf(this.currentFoodItem)) {
                      this.currentFoodItem.deliveryQuantity = item.deliveryQuantity
                      this.currentFoodItem.deliveryQuantityKg = item.deliveryQuantityKg
                      this.currentFoodItem.total = item.total
                    }
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
          })
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
              // 保存食材列表到全局变量
              globalThis.savedFoodItems = this.foodItems
              console.info(`保存按钮：保存食材列表到全局变量: ${JSON.stringify(globalThis.savedFoodItems)}`)
              
              promptAction.showToast({
                message: '保存成功',
                duration: 2000
              })
              
              setTimeout(() => {
                try {
                  console.info('保存按钮：开始返回...')
                  router.back()
                  
                  // 确保食材列表已保存
                  console.info(`保存按钮：检查食材列表是否保存: ${globalThis.savedFoodItems ? 'yes' : 'no'}`)
                } catch (error) {
                  console.error(`保存按钮：返回页面时发生错误: ${JSON.stringify(error)}`)
                }
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
                
                // 保存食材列表到全局变量
                globalThis.savedFoodItems = this.foodItems
                console.info(`保存食材列表到全局变量: ${JSON.stringify(globalThis.savedFoodItems)}`)
                
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
                    console.info(`检查食材列表是否保存: ${globalThis.savedFoodItems ? 'yes' : 'no'}`)
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
                
                // 保存食材列表到全局变量
                globalThis.savedFoodItems = this.foodItems
                console.info(`保存食材列表到全局变量: ${JSON.stringify(globalThis.savedFoodItems)}`)
                
                promptAction.showToast({
                  message: '配送单已确认收货',
                  duration: 2000
                })
                
                // 使用延时确保全局变量设置完成后再返回
                setTimeout(() => {
                  try {
                    console.info('开始返回配送单列表页...')
                    router.back()
                    
                    // 确保食材列表已保存
                    console.info(`检查食材列表是否保存: ${globalThis.savedFoodItems ? 'yes' : 'no'}`)
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
    }
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