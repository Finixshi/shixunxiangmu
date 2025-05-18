import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct CreateNewProduct {
  @State productName: string = '';
  @State productType: string = '';
  @State productUnit: string = '';
  @State productBrand: string = '';
  @State foodShortName: string = '';
  @State shelfLife: string = '';
  @State productCategory: string = '';
  @State purchasePrice: string = '';
  @State origin: string = '';
  @State remark: string = '';
  @State imageCount: number = 0;

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.zuo'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })
        
        Column() {
          Text('新品申购')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .fontColor('#FFFFFF')
            
          Text('phone.suoeryun.com')
            .fontSize(12)
            .fontColor('#CCCCCC')
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        
        // 菜单图标
        Text('...')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(80)
      .backgroundColor('#000000')
      .padding({ right: 16 })

      // 表单内容
      Scroll() {
        Column() {
          // 商品名称
          this.formTextItem('商品名称', true, '请输入商品名称', (value: string) => {
            this.productName = value;
          })

          // 类型
          this.formSelectItem('类型', true, this.productType || '请选择类型', () => {
            // 显示类型选择
            promptAction.showToast({ message: '选择类型', duration: 2000 });
          })

          // 单位
          this.formSelectItem('单位', true, this.productUnit || '请选择类型', () => {
            // 显示单位选择
            promptAction.showToast({ message: '选择单位', duration: 2000 });
          })

          // 品牌
          this.formTextItem('品牌', true, '请输入品牌', (value: string) => {
            this.productBrand = value;
          })

          // 食材简称
          this.formTextItem('食材简称', true, '请输入食材简称', (value: string) => {
            this.foodShortName = value;
          })

          // 保质期(天)
          this.formTextItem('保质期(天)', true, '请输入保质期(天)', (value: string) => {
            this.shelfLife = value;
          })

          // 商品类别
          this.formSelectItem('商品类别', true, this.productCategory || '请选择商品类别', () => {
            // 显示商品类别选择
            promptAction.showToast({ message: '选择商品类别', duration: 2000 });
          })

          // 采购价
          this.formTextItem('采购价', true, '请输入采购价', (value: string) => {
            this.purchasePrice = value;
          })

          // 产地
          this.formTextItem('产地', false, '请输入产地', (value: string) => {
            this.origin = value;
          })

          // 备注
          Column() {
            Text('备注')
              .fontSize(16)
              .fontColor('#000000')
              .width('100%')
              .textAlign(TextAlign.Start)
              .margin({ top: 16, bottom: 8 })
            
            TextArea({ placeholder: '请输入备注' })
              .height(100)
              .width('100%')
              .backgroundColor('#F5F5F5')
              .placeholderColor('#AAAAAA')
              .padding(10)
              .onChange((value: string) => {
                this.remark = value;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .margin({ top: 10 })

          // 上传商品图片
          Column() {
            Row() {
              Text('上传商品图片')
                .fontSize(16)
                .fontColor('#000000')
                .width('80%')
                .textAlign(TextAlign.Start)
              
              Text(`${this.imageCount}/1`)
                .fontSize(16)
                .fontColor('#999999')
                .width('20%')
                .textAlign(TextAlign.End)
            }
            .width('100%')
            .padding({ top: 16, bottom: 8 })
            
            Row() {
              Stack() {
                Image($r('app.media.zuo'))
                  .width(40)
                  .height(40)
                  .fillColor('#CCCCCC')
              }
              .backgroundColor('#FFFFFF')
              .border({ width: 1, color: '#EEEEEE' })
              .width(100)
              .height(100)
              .alignContent(Alignment.Center)
              .onClick(() => {
                promptAction.showToast({ message: '选择图片', duration: 2000 });
              })
            }
            .width('100%')
            .margin({ top: 10, bottom: 20 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .margin({ top: 10 })

          // 底部按钮
          Row() {
            Button('保存')
              .width('45%')
              .height(50)
              .backgroundColor('#0A86F6')
              .borderRadius(4)
              .fontSize(18)
              .fontColor('#FFFFFF')
              .onClick(() => {
                promptAction.showToast({ message: '保存成功', duration: 2000 });
              })
            
            Button('提交')
              .width('45%')
              .height(50)
              .backgroundColor('#10C469')
              .borderRadius(4)
              .fontSize(18)
              .fontColor('#FFFFFF')
              .onClick(() => {
                promptAction.showToast({ message: '提交成功', duration: 2000 });
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .padding({ left: 16, right: 16 })
          .margin({ top: 20, bottom: 30 })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  formTextItem(label: string, required: boolean, placeholder: string, onChange: (value: string) => void) {
    Column() {
      Row() {
        Text(label)
          .fontSize(16)
          .fontColor('#000000')
        
        if (required) {
          Text(' *')
            .fontSize(16)
            .fontColor('#FF0000')
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .padding({ top: 16 })
      
      TextInput({ placeholder: placeholder })
        .height(50)
        .width('100%')
        .backgroundColor(Color.Transparent)
        .placeholderColor('#AAAAAA')
        .onChange(onChange)
      
      Divider()
        .strokeWidth(1)
        .color('#EEEEEE')
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  formSelectItem(label: string, required: boolean, text: string, onClick: () => void) {
    Column() {
      Row() {
        Text(label)
          .fontSize(16)
          .fontColor('#000000')
        
        if (required) {
          Text(' *')
            .fontSize(16)
            .fontColor('#FF0000')
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .padding({ top: 16 })
      
      Row() {
        Text(text)
          .width('100%')
          .fontSize(16)
          .fontColor(text.includes('请选择') ? '#AAAAAA' : '#000000')
        
        Image($r('app.media.arrow_down'))
          .width(20)
          .height(20)
      }
      .width('100%')
      .height(50)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(onClick)
      
      Divider()
        .strokeWidth(1)
        .color('#EEEEEE')
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }
} 