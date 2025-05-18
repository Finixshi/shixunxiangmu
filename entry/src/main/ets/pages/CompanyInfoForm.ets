import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import data_preferences from '@ohos.data.preferences';

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
  
  // 日期选择器相关
  @State isDatePickerVisible: boolean = false;
  @State yearIndex: number = 50; // 默认2000年（1950+50）
  @State monthIndex: number = 0; // 默认1月
  @State dayIndex: number = 0; // 默认1日
  
  // 日期选择器数据
  private years: string[] = [];
  private months: string[] = [];
  private days: string[] = [];
  
  private context = getContext(this) as common.UIAbilityContext;
  private prefName: string = 'companyInfo';
  
  aboutToAppear() {
    // 初始化日期选择器数据
    this.initDatePickerData();
    
    // 在页面创建时加载保存的数据
    this.loadSavedData();
  }
  
  // 初始化日期选择器数据
  initDatePickerData() {
    // 生成年份数据（1950-2049）
    for (let i = 0; i < 100; i++) {
      this.years.push(`${1950 + i}年`);
    }
    
    // 生成月份数据
    for (let i = 0; i < 12; i++) {
      this.months.push(`${i + 1}月`);
    }
    
    // 生成日期数据
    for (let i = 0; i < 31; i++) {
      this.days.push(`${i + 1}日`);
    }
  }
  
  // 保存表单数据
  async saveFormData() {
    try {
      const preferences = await data_preferences.getPreferences(this.context, this.prefName);
      await preferences.put('companyName', this.companyName);
      await preferences.put('registrationNo', this.registrationNo);
      await preferences.put('establishmentDate', this.establishmentDate);
      await preferences.put('legalRepresentative', this.legalRepresentative);
      await preferences.put('landlinePhone', this.landlinePhone);
      await preferences.put('address', this.address);
      await preferences.put('contactPerson', this.contactPerson);
      await preferences.put('operationArea', this.operationArea);
      await preferences.put('bank', this.bank);
      await preferences.put('bankAccountNo', this.bankAccountNo);
      await preferences.put('remarks', this.remarks);
      await preferences.flush();
      console.info('表单数据保存成功');
    } catch (error) {
      console.error('保存表单数据失败:', error);
    }
  }
  
  // 加载保存的数据
  async loadSavedData() {
    try {
      const preferences = await data_preferences.getPreferences(this.context, this.prefName);
      this.companyName = await preferences.get('companyName', '彦红粮油有限公司') as string;
      this.registrationNo = await preferences.get('registrationNo', '') as string;
      this.establishmentDate = await preferences.get('establishmentDate', '') as string;
      this.legalRepresentative = await preferences.get('legalRepresentative', '') as string;
      this.landlinePhone = await preferences.get('landlinePhone', '') as string;
      this.address = await preferences.get('address', '') as string;
      this.contactPerson = await preferences.get('contactPerson', '彦红') as string;
      this.operationArea = await preferences.get('operationArea', '渭南市') as string;
      this.bank = await preferences.get('bank', '') as string;
      this.bankAccountNo = await preferences.get('bankAccountNo', '') as string;
      this.remarks = await preferences.get('remarks', '') as string;
      console.info('加载保存的表单数据成功');
    } catch (error) {
      console.error('加载表单数据失败:', error);
    }
  }
  
  // 提交表单
  submitForm() {
    // 表单验证
    if (!this.companyName) {
      promptAction.showToast({
        message: '请输入公司名称',
        duration: 2000
      });
      return;
    }
    
    if (!this.operationArea) {
      promptAction.showToast({
        message: '请输入经营范围',
        duration: 2000
      });
      return;
    }
    
    // 保存表单数据
    this.saveFormData();
    
    // 显示提交成功提示
    promptAction.showDialog({
      title: '提交成功',
      message: '公司信息已提交成功！',
      buttons: [
        {
          text: '确定',
          color: '#10C469'
        }
      ]
    });
  }
  
  // 确认日期选择
  confirmDateSelection() {
    // 从选择器索引获取年月日
    const year = 1950 + this.yearIndex;
    const month = this.monthIndex + 1;
    const day = this.dayIndex + 1;
    
    // 格式化日期字符串
    this.establishmentDate = `${year}-${month < 10 ? '0' + month : month}-${day < 10 ? '0' + day : day}`;
    this.isDatePickerVisible = false;
  }

  // 在Panel组件中使用的遮罩颜色
  get maskColor() {
    return '#80000000'; // 半透明黑色，前两位80表示50%透明度
  }

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
          this.inputFormItem('公司名称 *', this.companyName, true, (value: string) => {
            this.companyName = value;
          })
          this.inputFormItem('注册编号', this.registrationNo, false, (value: string) => {
            this.registrationNo = value;
          }, '请输入注册编号')
          this.textFormItem('成立时间', this.establishmentDate, '请选择成立时间', () => {
            this.isDatePickerVisible = true;
          })
          this.inputFormItem('法人', this.legalRepresentative, false, (value: string) => {
            this.legalRepresentative = value;
          }, '请输入法人')
          this.inputFormItem('固定电话', this.landlinePhone, false, (value: string) => {
            this.landlinePhone = value;
          }, '请输入固定电话')
          this.inputFormItem('地址', this.address, false, (value: string) => {
            this.address = value;
          }, '请输入地址')
          this.inputFormItem('联系人', this.contactPerson, false, (value: string) => {
            this.contactPerson = value;
          })
          this.inputFormItem('经营范围 *', this.operationArea, true, (value: string) => {
            this.operationArea = value;
          })
          this.inputFormItem('开户银行', this.bank, false, (value: string) => {
            this.bank = value;
          }, '请输入开户银行')
          this.inputFormItem('银行账号', this.bankAccountNo, false, (value: string) => {
            this.bankAccountNo = value;
          }, '请输入银行账号')
          
          // 备注
          Column() {
            Text('备注')
              .fontSize(16)
              .fontColor('#000000')
              .margin({ top: 16, bottom: 8 })
              .alignSelf(ItemAlign.Start)
            
            TextArea({ placeholder: '请输入备注', text: this.remarks })
              .height(100)
              .width('100%')
              .backgroundColor('#F5F5F5')
              .placeholderColor('#AAAAAA')
              .fontSize(16)
              .padding(16)
              .onChange((value: string) => {
                this.remarks = value;
              })
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
            .onClick(() => {
              this.submitForm();
            })
        }
        .width('100%')
      }
      .layoutWeight(1)
      
      // 底部导航栏背景
      Row()
        .width('100%')
        .height(50)
        .backgroundColor('#000000')
      
      // 日期选择弹窗
      if (this.isDatePickerVisible) {
        Panel(true) {
          Column() {
            Text('选择日期')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 20, bottom: 20 })
            
            Row() {
              // 年份选择器
              TextPicker({ range: this.years, selected: this.yearIndex })
                .onChange((value: string | string[], index: number | number[]) => {
                  if (typeof index === 'number') {
                    this.yearIndex = index;
                  }
                })
                .layoutWeight(1)
              
              // 月份选择器
              TextPicker({ range: this.months, selected: this.monthIndex })
                .onChange((value: string | string[], index: number | number[]) => {
                  if (typeof index === 'number') {
                    this.monthIndex = index;
                  }
                })
                .layoutWeight(1)
              
              // 日期选择器
              TextPicker({ range: this.days, selected: this.dayIndex })
                .onChange((value: string | string[], index: number | number[]) => {
                  if (typeof index === 'number') {
                    this.dayIndex = index;
                  }
                })
                .layoutWeight(1)
            }
            .width('100%')
            
            Row() {
              Button('取消')
                .width('45%')
                .height(40)
                .backgroundColor('#F0F0F0')
                .fontColor('#666666')
                .onClick(() => {
                  this.isDatePickerVisible = false;
                })
              
              Button('确定')
                .width('45%')
                .height(40)
                .backgroundColor('#10C469')
                .fontColor('#FFFFFF')
                .onClick(() => {
                  this.confirmDateSelection();
                })
            }
            .width('90%')
            .margin({ top: 20, bottom: 20 })
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .backgroundColor(Color.White)
        }
        .type(PanelType.Foldable)
        .mode(PanelMode.Full)
        .dragBar(false)
        .halfHeight(350)
        .backgroundMask(this.maskColor)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
  
  // 输入表单项
  @Builder
  inputFormItem(label: string, value: string, isRequired: boolean = false, onChange: (value: string) => void, placeholder: string = '') {
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
        
        TextInput({ placeholder: placeholder, text: value })
          .width('100%')
          .fontSize(16)
          .padding({ top: 8, bottom: 8 })
          .backgroundColor(Color.Transparent)
          .placeholderColor('#AAAAAA')
          .fontColor('#000000')
          .onChange(onChange)
        
        Divider()
          .strokeWidth(1)
          .color('#EEEEEE')
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }
  
  // 纯文本表单项（用于日期选择）
  @Builder
  textFormItem(label: string, value: string, placeholder: string = '', onClick: () => void = () => {}) {
    Row() {
      Column() {
        Row() {
          Text(label)
            .fontSize(16)
            .fontColor('#000000')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        
        Row() {
          if (value && value.length > 0) {
            Text(value)
              .fontSize(16)
              .fontColor('#000000')
              .width('100%')
              .padding({ top: 8, bottom: 8 })
          } else {
            Text(placeholder)
              .fontSize(16)
              .fontColor('#AAAAAA')
              .width('100%')
              .padding({ top: 8, bottom: 8 })
          }
          
          Image($r('app.media.arrow_down'))
            .width(20)
            .height(20)
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(onClick)
        
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