import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';

// 定义后厨人员接口
interface KitchenStaff {
  id: string;          // 唯一标识
  name: string;        // 姓名
  position: string;    // 职位
  phone: string;       // 联系电话
  certificate: string; // 健康证号
  certExpiry: string;  // 健康证有效期
  joinDate: string;    // 入职日期
  status: string;      // 状态(在职/离职)
}

@Entry
@Component
struct StaffEditor {
  @State staff: KitchenStaff = {
    id: '',
    name: '',
    position: '',
    phone: '',
    certificate: '',
    certExpiry: '请选择有效期日期 ▼',
    joinDate: '请选择入职日期 ▼',
    status: '在职'
  }
  
  @State isEdit: boolean = false
  @State editIndex: number = -1
  private certExpiryDate: Date = new Date()
  private joinSelectedDate: Date = new Date()
  private context = getContext(this) as common.UIAbilityContext
  
  private positionOptions: SelectOption[] = [
    { value: '厨师长' },
    { value: '主厨' },
    { value: '副厨' },
    { value: '切配' },
    { value: '后勤' }
  ]
  
  private statusOptions: SelectOption[] = [
    { value: '在职' },
    { value: '离职' }
  ]
  
  aboutToAppear() {
    // 获取路由参数，判断是编辑还是新增
    const params = router.getParams() as Record<string, Object>
    if (params && params.staff) {
      this.isEdit = true
      this.editIndex = params.index as number
      this.staff = JSON.parse(JSON.stringify(params.staff))
      
      // 设置日期选择器初始值
      if (this.staff.certExpiry && this.staff.certExpiry !== '请选择有效期日期 ▼') {
        this.certExpiryDate = new Date(this.staff.certExpiry)
      }
      
      if (this.staff.joinDate && this.staff.joinDate !== '请选择入职日期 ▼') {
        this.joinSelectedDate = new Date(this.staff.joinDate)
      }
    } else {
      // 新增时生成唯一ID
      this.staff.id = this.generateUniqueId()
    }
  }
  
  private generateUniqueId(): string {
    return Date.now().toString() + Math.floor(Math.random() * 1000).toString()
  }
  
  private validateForm(): boolean {
    if (!this.staff.name.trim()) {
      promptAction.showToast({ message: '请输入姓名' })
      return false
    }
    
    if (!this.staff.position) {
      promptAction.showToast({ message: '请选择职位' })
      return false
    }
    
    if (!this.staff.phone.trim()) {
      promptAction.showToast({ message: '请输入联系电话' })
      return false
    } else if (!/^1[3-9]\d{9}$/.test(this.staff.phone)) {
      promptAction.showToast({ message: '请输入有效的手机号码' })
      return false
    }
    
    if (!this.staff.certificate.trim()) {
      promptAction.showToast({ message: '请输入健康证号' })
      return false
    }
    
    if (this.staff.certExpiry === '请选择有效期日期 ▼') {
      promptAction.showToast({ message: '请选择健康证有效期' })
      return false
    }
    
    if (this.staff.joinDate === '请选择入职日期 ▼') {
      promptAction.showToast({ message: '请选择入职日期' })
      return false
    }
    
    return true
  }
  
  private async saveStaff() {
    if (!this.validateForm()) {
      return
    }
    
    try {
      // 从存储中获取员工列表
      let existingStaffList: KitchenStaff[] = []
      const prefer = await preferences.getPreferences(this.context, 'myPreferences')
      const storageStaff = await prefer.get('staffList', '[]')
      
      if (storageStaff) {
        existingStaffList = JSON.parse(storageStaff as string)
      }
      
      if (this.isEdit && this.editIndex >= 0) {
        // 更新现有员工
        existingStaffList[this.editIndex] = this.staff
      } else {
        // 添加新员工
        existingStaffList.push(this.staff)
      }
      
      // 保存到存储
      await prefer.put('staffList', JSON.stringify(existingStaffList))
      await prefer.flush()
      
      // 显示成功提示
      AlertDialog.show({
        title: '提示',
        message: this.isEdit ? '更新成功' : '添加成功',
        confirm: {
          value: '确定',
          action: () => {
            router.back()
          }
        }
      })
    } catch (error) {
      console.error('保存失败:', error)
      promptAction.showToast({ message: '保存失败，请重试' })
    }
  }
  
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#000')
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          })

        Text(this.isEdit ? '编辑人员信息' : '添加后厨人员')
          .fontWeight(FontWeight.Bold)
          .fontSize(22)
          .textAlign(TextAlign.Center)
          .margin({ top: 18, bottom: 8 })
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      
      // 表单内容
      Column() {
        // 姓名
        Row() {
          Text('姓名')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          TextInput({ placeholder: '请输入姓名', text: this.staff.name })
            .width('50%')
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .fontSize(16)
            .onChange((value: string) => {
              this.staff.name = value
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })
        
        // 职位
        Row() {
          Text('职位')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          Select(this.positionOptions)
            .selected(this.positionOptions.findIndex(item => item.value === this.staff.position) >= 0 ? 
              this.positionOptions.findIndex(item => item.value === this.staff.position) : 0)
            .value(this.staff.position || '请选择职位')
            .onSelect((index: number, value: string) => {
              this.staff.position = value
            })
            .width('50%')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })
        
        // 联系电话
        Row() {
          Text('联系电话')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          TextInput({ placeholder: '请输入手机号', text: this.staff.phone })
            .width('50%')
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .fontSize(16)
            .inputFilter('^[0-9]*$')
            .maxLength(11)
            .onChange((value: string) => {
              this.staff.phone = value
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })
        
        // 健康证号
        Row() {
          Text('健康证号')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          TextInput({ placeholder: '请输入健康证号', text: this.staff.certificate })
            .width('50%')
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .fontSize(16)
            .onChange((value: string) => {
              this.staff.certificate = value
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })
        
        // 健康证有效期
        Row() {
          Text('健康证有效期')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          Text(this.staff.certExpiry)
            .width('50%')
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .border({ width: 1, color: '#E5E5E5' })
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .padding({ left: 8, right: 8 })
            .fontColor(this.staff.certExpiry === '请选择有效期日期 ▼' ? '#999' : '#333')
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-1-1"),
                end: new Date("2100-12-31"),
                selected: this.certExpiryDate,
                onAccept: (value: DatePickerResult) => {
                  if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                    this.certExpiryDate = new Date(value.year, value.month, value.day)
                    const formattedDate = `${value.year}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`
                    this.staff.certExpiry = formattedDate
                  }
                }
              })
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })
        
        // 入职日期
        Row() {
          Text('入职日期')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          Text(this.staff.joinDate)
            .width('50%')
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .border({ width: 1, color: '#E5E5E5' })
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .padding({ left: 8, right: 8 })
            .fontColor(this.staff.joinDate === '请选择入职日期 ▼' ? '#999' : '#333')
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-1-1"),
                end: new Date("2100-12-31"),
                selected: this.joinSelectedDate,
                onAccept: (value: DatePickerResult) => {
                  if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                    this.joinSelectedDate = new Date(value.year, value.month, value.day)
                    const formattedDate = `${value.year}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`
                    this.staff.joinDate = formattedDate
                  }
                }
              })
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })
        
        // 状态
        Row() {
          Text('状态')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          Select(this.statusOptions)
            .selected(this.staff.status === '在职' ? 0 : 1)
            .value(this.staff.status)
            .onSelect((index: number, value: string) => {
              this.staff.status = value
            })
            .width('50%')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })
      }
      .width('100%')
      .flexGrow(1)
      
      // 底部保存按钮
      Row() {
        Button('保存', { type: ButtonType.Normal })
          .width('90%')
          .height(44)
          .backgroundColor(Color.Green)
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(8)
          .onClick(() => {
            this.saveStaff()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 24, top: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
} 