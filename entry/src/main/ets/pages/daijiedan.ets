import router from '@ohos.router';
// 订单数据模型
interface Order {
  id: number;
  schoolName: string;
  orderNumber: string;
  supplyTime: string;
  demandUnit: string;
  orderer: string;
  orderPhone: string;
  summary: string;
  status: 'pending' | 'accepted'; // 订单状态：待接单或已接单
}

// 主页面组件
@Entry
@Component
struct Index {
  @State currentPage: string = 'pending'; // 当前显示的页面：pending(待接单)或accepted(已接单)
  @State orderList: Order[] = []; // 订单列表数据
  private selectedDate: Date = new Date('2021-08-08')
  @State timetext: string = '请选择供应日期' // 修改默认提示文本

  aboutToAppear() {
    // 模拟加载订单数据
    this.loadOrders();
  }

  // 模拟加载订单数据
  loadOrders() {
    // 实际应用中应从服务器或本地存储获取数据
    this.orderList = [
      {
        id: 1,
        schoolName: "实训第一中学",
        orderNumber: "ORD20250515001",
        supplyTime: "2025-05-16 08:30",
        demandUnit: "实训第一学校",
        orderer: "王老师",
        orderPhone: "13800138001",
        summary: "",
        status: 'pending'
      },
      {
        id: 2,
        schoolName: "实训第二中学",
        orderNumber: "ORD20250515002",
        supplyTime: "2025-05-16 09:00",
        demandUnit: "实训第二中学",
        orderer: "李老师",
        orderPhone: "13900139001",
        summary: "",
        status: 'pending'
      },
      {
        id: 3,
        schoolName: "实训第三中学",
        orderNumber: "ORD20250514003",
        supplyTime: "2025-05-15 10:00",
        demandUnit: "实训第三中学",
        orderer: "张老师",
        orderPhone: "13700137001",
        summary: "",
        status: 'accepted'
      }
    ];
  }

  // 接单操作
  acceptOrder(orderId: number) {
    // 更新订单状态
    const index = this.orderList.findIndex(order => order.id === orderId);
    if (index !== -1) {
      this.orderList[index].status = 'accepted';
      console.info(`订单 ${orderId} 已接单`);
    }
  }

  build() {
    Column() {
      // 顶部导
      // 航栏
      Row() {
        Text('<')
          .fontSize(28)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          })
        Text('待接单')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 120 })
        Blank()
      }
      .width('100%')
      .height(25)
      .padding({ left: 16, right: 16 })
      Row() {
        Text('待接单')
          .fontSize(18)
          .backgroundColor(this.currentPage === 'pending' ? '#007DFF' : '#E0E0E0')
          .fontColor(this.currentPage === 'pending' ? '#FFFFFF' : '#000000')
          .onClick(() => this.currentPage = 'pending')
        Text('已接单')
          .fontSize(18)
          .backgroundColor(this.currentPage === 'accepted' ? '#007DFF' : '#E0E0E0')
          .fontColor(this.currentPage === 'accepted' ? '#FFFFFF' : '#000000')
          .onClick(() => this.currentPage = 'accepted')
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
      .padding(10)


      // 日期选择器 - 使用 value 属性
      Row() {
        Column() {
          Row() {
            Text(this.timetext)
              .fontSize(16)
              .fontWeight(FontWeight.Normal)
              .margin({ left: 4, top: 12, right: 2 })
            Image($r('app.media.down')) // 替换为你的倒三角资源
              .width(16)
              .height(16)
              .margin({ top: 14 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start) // 确保内容左对齐
        }
        .width('100%')
        .padding({ left: 16 }) // 添加左侧内边距
        .onClick(() => {
          DatePickerDialog.show({
            start: new Date("2000-1-1"),
            end: new Date("2100-12-31"),
            selected: this.selectedDate,
            onAccept: (value: DatePickerResult) => {
              if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                this.selectedDate.setFullYear(value.year, value.month, value.day);
                const formattedDate =
                  `${value.year}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`;
                this.timetext = formattedDate;
              }
            }
          });
        })
      }
      .height(50)
      .width('100%')
      .border({
        width: 1,
        color: '#E0E0E0',
        radius: 5
      })
      .margin({ left: 16, right: 16, top: 10 })

      // 订单列表区域
      if (this.currentPage === 'pending') {
        // 待接单列表
        List() {
          ForEach(this.orderList.filter(order => order.status === 'pending'), (order: Order) => {
            ListItem() {
              Column() {
                Text(order.schoolName)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')

                Text(`供应时间: ${order.supplyTime}`)
                  .fontSize(14)
                  .width('100%')

                Text(`联系人: ${order.orderer} (${order.orderPhone})`)
                  .fontSize(14)
                  .width('100%')

                Text(`摘要: ${order.summary}`)
                  .fontSize(14)
                  .width('100%')

                Button('确认接单')
                  .width(120)
                  .height(35)
                  .backgroundColor('#00C48C')
                  .fontColor('#FFFFFF')
                  .onClick(() => this.acceptOrder(order.id))
              }
              .width('100%')
              .padding(15)
              .backgroundColor('#FFFFFF')
              .margin({ top: 10, left: 15, right: 15 })
              .borderRadius(10)
              .shadow({
                radius: 5,
                offsetX: 2,
                offsetY: 2,
                color: '#CCCCCC'
              })
            }
          })
        }
        .width('100%')
        .height('100%')
        .margin({ top: 10 })
      } else {
        // 已接单列表
        List() {
          ForEach(this.orderList.filter(order => order.status === 'accepted'), (order: Order) => {
            ListItem() {
              Column() {
                Text(order.schoolName)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')

                Text(`单据号: ${order.orderNumber}`)
                  .fontSize(14)
                  .width('100%')

                Text(`供应时间: ${order.supplyTime}`)
                  .fontSize(14)
                  .width('100%')

                Text(`需求单位: ${order.demandUnit}`)
                  .fontSize(14)
                  .width('100%')

                Text(`摘要: ${order.summary}`)
                  .fontSize(14)
                  .width('100%')
              }
              .width('100%')
              .padding(15)
              .backgroundColor('#FFFFFF')
              .margin({ top: 10, left: 15, right: 15 })
              .borderRadius(10)
              .shadow({
                radius: 5,
                offsetX: 2,
                offsetY: 2,
                color: '#CCCCCC'
              })
            }
          })
        }
        .width('100%')
        .height('100%')
        .margin({ top: 10 })
      }
    }
    .width('100%')
    .height('100%')
  }
}