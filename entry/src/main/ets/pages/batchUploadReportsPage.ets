import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

// 食品项目接口
interface FoodItem {
  name: string            // 食品名称
  brand: string           // 品牌
  inspectionReport: string[] // 检验报告图片
}

// 路由参数接口
interface RouterParams {
  foodItems: FoodItem[]
}

@Entry
@Component
struct BatchUploadReportsPage {
  @State selectedCount: number = 0
  @State foodItems: FoodItem[] = []
  @State isUploading: boolean = false
  
  // 在页面显示前获取路由参数
  aboutToAppear() {
    const params = router.getParams() as RouterParams
    if (params && params.foodItems) {
      this.foodItems = params.foodItems
      // 更新选择的食材数量
      this.selectedCount = this.foodItems.length
    }
  }
  
  // 模拟上传文件
  simulateUploadFile() {
    this.isUploading = true
    
    // 模拟上传延迟
    setTimeout(() => {
      this.isUploading = false
      
      // 模拟上传成功
      promptAction.showToast({
        message: '检验报告上传成功',
        duration: 2000
      })
      
      // 为所有食材添加检验报告图片URL（模拟数据）
      this.foodItems.forEach(item => {
        item.inspectionReport = ['https://example.com/report1.jpg', 'https://example.com/report2.jpg']
      })
    }, 2000)
  }
  
  // 确认添加并返回
  confirmAndReturn() {
    const reportsCount = this.foodItems.filter(item => item.inspectionReport && item.inspectionReport.length > 0).length
    
    if (reportsCount === 0) {
      promptAction.showToast({
        message: '请先上传检验报告',
        duration: 2000
      })
      return
    }
    
    // 保存上传结果到全局变量，供配送单详情页面使用
    globalThis.uploadedFoodReports = this.foodItems
    
    promptAction.showToast({
      message: `已成功添加${reportsCount}个检验报告`,
      duration: 2000
    })
    
    // 返回上一页
    router.back()
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          })
        
        Text('上传检验报告')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor('#FFFFFF')
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
      
      // 已选择食材数量
      Row() {
        Text(`已选${this.selectedCount}种食材`)
          .fontSize(16)
          .fontColor('#333333')
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F5F5F5')
      
      // 食材列表
      List() {
        ForEach(this.foodItems, (item: FoodItem) => {
          ListItem() {
            Row() {
              Column() {
                Text(item.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 4 })
                
                Text(`品牌: ${item.brand}`)
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              // 检验报告状态
              Text(item.inspectionReport && item.inspectionReport.length > 0 ? '已上传' : '未上传')
                .fontSize(14)
                .fontColor(item.inspectionReport && item.inspectionReport.length > 0 ? '#00C853' : '#FF5722')
                .backgroundColor('#F5F5F5')
                .padding(4)
                .borderRadius(4)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ bottom: 8 })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })
      .backgroundColor('#FFFFFF')
      
      // 上传区域
      Column() {
        Text('⬆')  // 上传图标
          .fontSize(60)
          .fontColor('#1E88E5')
          .margin({ top: 30, bottom: 16 })
        
        Text('点击上传检验报告')
          .fontSize(18)
          .fontColor('#333333')
          .margin({ bottom: 8 })
        
        Text('支持jpg、png格式')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 30 })
        
        Button(this.isUploading ? '上传中...' : '上传检验报告')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#1E88E5')
          .width(200)
          .height(48)
          .borderRadius(24)
          .onClick(() => {
            this.simulateUploadFile()
          })
          .enabled(!this.isUploading)
      }
      .width('100%')
      .height(300)
      .backgroundColor('#F5F5F5')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 16, left: 16, right: 16 })
      .borderRadius(8)
      
      // 底部确认区域
      Row() {
        Button('确认添加')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#00C853')
          .width('100%')
          .height(48)
          .onClick(() => {
            this.confirmAndReturn()
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderWidth({ top: 1 })
      .borderColor('#EEEEEE')
    }
    .width('100%')
    .height('100%')
  }
} 