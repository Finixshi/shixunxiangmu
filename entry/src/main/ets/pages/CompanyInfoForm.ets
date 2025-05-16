import router from '@ohos.router';

@Entry
@Component
struct CompanyInfoForm {
  @State companyName: string = '彦红粮油有限公司';
  @State registrationNo: string = '';
  @State establishmentDate: string = '';
  @State legalRepresentative: string = '';
  @State landlinePhone: string = '';
  @State address: string = '';
  @State contactPerson: string = '彦红';
  @State operationArea: string = '渭南市';
  @State bank: string = '';
  @State bankAccountNo: string = '';
  @State remarks: string = '';

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.zuo'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })
        
        Text('基本信息')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor('#FFFFFF')
        
        Blank()
          .width(64)
      }
      .width('100%')
      .height(56)
      .backgroundColor('#000000')
      .padding({ right: 16 })

      // 表单内容
      Scroll() {
        Column() {
          this.formItem('公司名称 *', this.companyName, true)
          this.formItem('注册编号', this.registrationNo, false, '请输入注册编号')
          this.formItem('成立时间', this.establishmentDate, false, '请选择成立时间', true)
          this.formItem('法人', this.legalRepresentative, false, '请输入法人')
          this.formItem('固定电话', this.landlinePhone, false, '请输入固定电话')
          this.formItem('地址', this.address, false, '请输入地址')
          this.formItem('联系人', this.contactPerson, false)
          this.formItem('经营范围 *', this.operationArea, true)
          this.formItem('开户银行', this.bank, false, '请输入开户银行')
          this.formItem('银行账号', this.bankAccountNo, false, '请输入银行账号')
          
          // 备注
          Column() {
            Text('备注')
              .fontSize(16)
              .fontColor('#000000')
              .margin({ top: 16, bottom: 8 })
              .alignSelf(ItemAlign.Start)
            
            TextInput({ placeholder: '请输入备注', text: this.remarks })
              .height(100)
              .width('100%')
              .backgroundColor('#F5F5F5')
              .placeholderColor('#AAAAAA')
              .fontSize(16)
              .padding(16)
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          
          // 提交按钮
          Button('提交')
            .width('90%')
            .height(50)
            .backgroundColor('#10C469')
            .borderRadius(4)
            .fontSize(18)
            .fontColor('#FFFFFF')
            .margin({ top: 30, bottom: 50 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      
      // 底部导航栏背景
      Row()
        .width('100%')
        .height(50)
        .backgroundColor('#000000')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
  
  @Builder
  formItem(label: string, value: string, isRequired: boolean = false, placeholder: string = '', isDropdown: boolean = false) {
    Row() {
      Column() {
        Row() {
          Text(label)
            .fontSize(16)
            .fontColor('#000000')
          
          if (isRequired) {
            Text(' *')
              .fontSize(16)
              .fontColor('#FF0000')
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        
        if (value && value.length > 0) {
          Text(value)
            .width('100%')
            .fontSize(16)
            .padding({ top: 8, bottom: 8 })
            .fontColor('#000000')
        } else {
          if (isDropdown) {
            Row() {
              Text(placeholder)
                .fontSize(16)
                .fontColor('#AAAAAA')
              
              Image($r('app.media.arrow_down'))
                .width(20)
                .height(20)
                .margin({ left: 8 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 8, bottom: 8 })
          } else {
            Text(placeholder)
              .width('100%')
              .fontSize(16)
              .padding({ top: 8, bottom: 8 })
              .fontColor('#AAAAAA')
          }
        }
        
        Divider()
          .strokeWidth(1)
          .color('#EEEEEE')
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }
} 