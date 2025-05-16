import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

// 食品项接口
interface FoodItem {
  id: string
  name: string
  brand: string
  specification?: string
  unit: string
  price: number
  type: 'single' | 'package'  // 按件或按重量
  isNew: boolean // 是否是新品
}

@Entry
@Component
struct AddFoodItemsPage {
  @State searchText: string = ''
  @State selectedItems: Map<string, FoodItem> = new Map()
  
  private foodItems: FoodItem[] = [
    {
      id: '1',
      name: '大肉',
      brand: '古徽',
      unit: '元/Kg',
      price: 19.8,
      type: 'single',
      isNew: true
    },
    {
      id: '2',
      name: '赤小豆',
      brand: '农家',
      unit: '元/Kg',
      price: 15.6,
      type: 'single',
      isNew: true
    },
    {
      id: '3',
      name: '小肉',
      brand: '爱德华',
      specification: '称重',
      unit: '元/Kg',
      price: 15,
      type: 'single',
      isNew: true
    },
    {
      id: '4',
      name: '腐竹',
      brand: '海天',
      specification: '500g*1箱/件',
      unit: '元/件',
      price: 5,
      type: 'package',
      isNew: false
    }
  ]
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')  // 用箭头符号替代back_icon
          .width(24)
          .height(24)
          .fontSize(20)
          .fontColor('#FFFFFF')
          .margin({ left: 16 })
          .onClick(() => {
            promptAction.showToast({
              message: '请点击下方确定按钮选择并返回',
              duration: 2000
            })
          })
        
        Text('配送单添加食材')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor('#FFFFFF')
        
        Text('⋯')  // 用省略号符号替代more_icon
          .width(24)
          .height(24)
          .fontSize(24)
          .fontColor('#FFFFFF')
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#000000')
      
      // 网站标题
      Text('phone.suoeryun.com')
        .fontSize(14)
        .fontColor('#999999')
        .width('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor('#000000')
        .padding({ bottom: 8 })
      
      // 搜索和分类区域
      Row() {
        Text('全部分类')
          .fontSize(16)
          .fontColor('#333333')
          .margin({ left: 16 })
        
        Text('▼')  // 用下箭头符号替代arrow_down
          .width(16)
          .height(16)
          .fontSize(14)
          .fontColor('#333333')
          .margin({ left: 4 })
        
        // 搜索框
        Row() {
          Text('🔍')  // 用放大镜emoji替代search_icon
            .width(20)
            .height(20)
            .fontSize(16)
            .margin({ left: 8 })
          
          TextInput({ placeholder: '搜索商品名称', text: this.searchText })
            .width('80%')
            .height(40)
            .backgroundColor('transparent')
            .placeholderColor('#999999')
            .fontSize(14)
            .margin({ left: 8 })
            .onChange((value: string) => {
              this.searchText = value
            })
        }
        .width('70%')
        .height(46)
        .borderRadius(23)
        .backgroundColor('#FFFFFF')
        .margin({ left: 16, right: 16 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .backgroundColor('#F5F5F5')
      .padding({ top: 10, bottom: 10 })
      
      // 食材列表
      List() {
        ForEach(this.foodItems, (item: FoodItem) => {
          ListItem() {
            Column() {
              // 食材卡片
              Row() {
                // 新品标签
                if (item.isNew) {
                  Column() {
                    Text('新品')
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#FF9800')
                      .borderRadius({ topLeft: 8, bottomRight: 8 })
                      .padding(4)
                  }
                  .position({ x: 0, y: 0 })
                  .zIndex(1)
                } else {
                  Column() {
                    Text('促件')
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#2196F3')
                      .borderRadius({ topLeft: 8, bottomRight: 8 })
                      .padding(4)
                  }
                  .position({ x: 0, y: 0 })
                  .zIndex(1)
                }
                
                // 食材信息
                Column() {
                  Text(item.name)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .margin({ top: 28, bottom: 16 })
                    .alignSelf(ItemAlign.Start)
                    .width('100%')
                  
                  Row() {
                    Text('品    牌:')
                      .fontSize(14)
                      .fontColor('#666666')
                      .width(80)
                    
                    Text(item.brand)
                      .fontSize(14)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .margin({ top: 6, bottom: 6 })
                  .alignItems(VerticalAlign.Center)
                  
                  if (item.specification) {
                    Row() {
                      Text('规    格:')
                        .fontSize(14)
                        .fontColor('#666666')
                        .width(80)
                      
                      Text(item.specification)
                        .fontSize(14)
                        .fontColor('#333333')
                    }
                    .width('100%')
                    .margin({ top: 6, bottom: 6 })
                    .alignItems(VerticalAlign.Center)
                  }
                  
                  Row() {
                    Text('供 应 价:')
                      .fontSize(14)
                      .fontColor('#666666')
                      .width(80)
                    
                    Text(item.price.toString() + item.unit)
                      .fontSize(16)
                      .fontColor('#FF5722')
                      .fontWeight(FontWeight.Bold)
                  }
                  .width('100%')
                  .margin({ top: 6, bottom: 6 })
                  .alignItems(VerticalAlign.Center)
                }
                .padding(16)
                .layoutWeight(1)
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .margin({ bottom: 10 })
              .onClick(() => {
                if (this.selectedItems.has(item.id)) {
                  this.selectedItems.delete(item.id)
                } else {
                  this.selectedItems.set(item.id, item)
                }
              })
              
              // 选中标记
              if (this.selectedItems.has(item.id)) {
                Text('✓')  // 用勾选符号替代check_icon
                  .width(24)
                  .height(24)
                  .fontSize(20)
                  .fontColor('#31B46A')
                  .backgroundColor('#FFFFFF')
                  .textAlign(TextAlign.Center)
                  .borderRadius(12)
                  .position({ x: '95%', y: '85%' })
              }
            }
          }
          .padding({ left: 16, right: 16 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      
      // 底部确认区域
      Row() {
        Text(`已选中${this.selectedItems.size}种食材`)
          .fontSize(16)
          .fontColor('#333333')
          .margin({ left: 16 })
          .layoutWeight(1)
        
        Button('确定')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#00C853')
          .width(120)
          .height(48)
          .borderRadius(4)
          .onClick(() => {
            // 将选中的食材转换为数组
            const selectedArray = Array.from(this.selectedItems.values())
            
            if (selectedArray.length === 0) {
              promptAction.showToast({
                message: '请选择食材',
                duration: 2000
              })
              return
            }
            
            // 返回上一页并传递选中的食材
            router.replaceUrl({
              url: 'pages/peisongdanDetailgh',
              params: {
                selectedFoodItems: selectedArray
              }
            })
          })
      }
      .width('100%')
      .height(60)
      .padding({ right: 16 })
      .backgroundColor('#FFFFFF')
      .borderWidth({ top: 1 })
      .borderColor('#EEEEEE')
    }
    .width('100%')
    .height('100%')
  }
} 