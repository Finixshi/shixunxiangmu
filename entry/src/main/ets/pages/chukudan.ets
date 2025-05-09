import router from '@ohos.router';

@Entry
@Component
struct NewOutboundOrder {
  @State totalAmount: number = 0; // 总计金额状态

  build() {
    Column() {
      // 顶部导航栏：仅保留文字标题
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      }) {
        Text('新建出库单')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold);
      }
      .height(56)
      .width('100%')
      .backgroundColor('#F5F5F5');

      // 表单项区域
      Column({ space: 1 }) {
        // 领用单位
        this.renderFormItem('领用单位 *', '请选择', $r('app.media.iunitName'));
        // 出库日期
        this.renderFormItem('出库日期 *', '请选择', $r('app.media.isupplyDate'));
        // 出库类型
        this.renderFormItem('出库类型 *', '请选择', $r('app.media.idemand'));
        // 餐别
        this.renderFormItem('餐别', '其他', $r('app.media.imealCategory'));
        // 摘要
        this.renderFormItem('摘    要：', '请输入摘要', $r('app.media.iremarks'));
      }
      .padding({ left: 16, right: 16 })
      .width('100%');

      // 添加食材按钮
      Button('+ 添加食材')
        .type(ButtonType.Capsule)
        .width('50%')
        .margin({ top: 24, bottom: 8 })
        .onClick(() => {
          // 跳转到 chukudan 页面
          router.pushUrl({
            url: 'pages/jiacaidan'
          });
        });

      // 已选食材提示
      Text('已选中0种食材')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 16 });

      // 总计金额
      Text(`总计：${this.totalAmount}元`)
        .fontSize(18)
        .fontColor('#FF4040')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16, right: 16 })
        .alignSelf(ItemAlign.End);

      // 底部按钮区域
      Row({ space: 16 }) {
        Button('保存')
          .type(ButtonType.Capsule)
          .width('45%')
          .onClick(() => {
            // TODO: 保存逻辑
          });

        Button('保存并审核')
          .type(ButtonType.Capsule)
          .width('45%')
          .onClick(() => {
            // TODO: 保存并审核逻辑
          });
      }
      .padding({ left: 16, right: 16 })
      .margin({ top: 24 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }

  // 封装通用表单项组件，支持图标传参
  @Builder
  renderFormItem(label: string, value: string, iconRes: Resource) {
    Row({ space: 8 }) {
      Image(iconRes)
        .width(16)
        .height(16);

      Text(label)
        .fontSize(16)
        .fontColor('#333333')
        .width('25%');

      Text(value)
        .fontSize(16)
        .fontColor('#999999')
        .width('55%')
        .textAlign(TextAlign.End);
    }
    .height(56)
    .border({
      width: { bottom: 1 },
      color: { bottom: '#EAEAEA' },
      radius: 0,
      style: { bottom: BorderStyle.Solid }
    })
    .alignItems(VerticalAlign.Center);
  }
}
