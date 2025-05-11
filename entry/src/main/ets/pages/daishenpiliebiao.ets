import router from '@ohos.router';
// 定义记录类型接口
export interface peicanjilu {
  date: string
  unit: string
  meal: string
  position: string
  name: string
  evaluation: string
}
@Entry
@Component
struct QualificationStatusPage {
  @State selectedStatus: 'pending' | 'approved' |'rejected' = 'pending';

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          })
        Text('资质信息')
          .fontSize(25)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 20 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF');

      // 审批状态切换按钮，整体放在下一行
      Row() {
        Text('待审批')
          .fontSize(16)
          .fontColor(this.selectedStatus === 'pending'? '#2BB673' : '#333')
          .padding(10)
          .onClick(() => {
            this.selectedStatus = 'pending';
          })
        Text('已审批')
          .fontSize(16)
          .fontColor(this.selectedStatus === 'approved'? '#2BB673' : '#333')
          .padding(10)
          .onClick(() => {
            this.selectedStatus = 'approved';
          })
        Text('已驳回')
          .fontSize(16)
          .fontColor(this.selectedStatus ==='rejected'? '#2BB673' : '#333')
          .padding(10)
          .onClick(() => {
            this.selectedStatus ='rejected';
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF');

      // 数据展示区（当前简单显示无数据提示）
      Column() {
        Text('~ 暂无相关数据 ~')
          .fontSize(16)
          .fontColor(Color.Gray)
          .padding(20)
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('50%')

      // 上传资质按钮
      Button('上传资质')
        .fontSize(18)
        .backgroundColor('#2BB673')
        .fontColor(Color.White)
        .borderRadius(10)
        .width('80%')
        .onClick(() => {
          // 这里可以根据实际需求设置跳转逻辑
          router.pushUrl({ url: 'pages/zizhixinxiguanli' })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}