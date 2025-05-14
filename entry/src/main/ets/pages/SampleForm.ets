import router from '@ohos.router'
import { SampleFormData } from '../common/types'
import { getSampleService } from '../common/services/SampleService'
import promptAction from '@ohos.promptAction'
import common from '@ohos.app.ability.common'

interface SelectOption {
  value: string
}

interface RouterParams {
  selectedDate?: string
  editSample?: SampleFormData
  editIndex?: number
}

@Entry
@Component
struct SampleForm {
  @State formData: SampleFormData = {
    location: '实训第一学校餐厅',
    date: '',
    type: '不区分',
    mealType: '午餐',
    temperature: 5,
    foodName: '',
    weight: '',
    staff: '',
    disposalTime: '',
    images: ["https://admin.suoeryun.com/pcUpload/1917474932601933825_1745996623568.png"],
    cabinetImages: ["https://admin.suoeryun.com/pcUpload/1917474946438942721_1745996626850.png"],
    notes: ''
  }
  @State isSubmitting: boolean = false

  private isEditMode: boolean = false
  private editIndex: number = -1
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext
  private sampleService = getSampleService(this.context)

  // 定义选项数据
  private locations: SelectOption[] = [
    { value: '实训第一学校餐厅' },
    { value: '实训第二学校餐厅' }
  ]
  private types: SelectOption[] = [
    { value: '学生餐' },
    { value: '教师餐' },
    { value: '不区分' }
  ]
  private mealTypes: SelectOption[] = [
    { value: '早餐' },
    { value: '午餐' },
    { value: '晚餐' },
    { value: '早点' },
    { value: '午点' },
    { value: '晚点' },
    { value: '其他' },
    { value: '营养改善计划' }
  ]

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as RouterParams

    // 判断是否是编辑模式
    if (params?.editSample) {
      this.isEditMode = true
      this.editIndex = params.editIndex ?? -1
      this.formData = JSON.parse(JSON.stringify(params.editSample))
      
      // 确保编辑模式下也有默认图片
      if (!this.formData.images || this.formData.images.length === 0) {
        this.formData.images = ["https://admin.suoeryun.com/pcUpload/1917474932601933825_1745996623568.png"]
      }
      if (!this.formData.cabinetImages || this.formData.cabinetImages.length === 0) {
        this.formData.cabinetImages = ["https://admin.suoeryun.com/pcUpload/1917474946438942721_1745996626850.png"]
      }
    } else if (params?.selectedDate) {
      this.formData.date = params.selectedDate
    } else {
      // 如果没有传入日期，使用当前日期
      const now = new Date()
      const year = now.getFullYear()
      const month = String(now.getMonth() + 1).padStart(2, '0')
      const day = String(now.getDate()).padStart(2, '0')
      this.formData.date = `${year}-${month}-${day}`
    }
  }

  // 计算销毁日期（当前日期+2天）
  getDisposalDate(): string {
    const currentDate = new Date(this.formData.date)
    const disposalDate = new Date(currentDate)
    disposalDate.setDate(currentDate.getDate() + 2)

    const year = disposalDate.getFullYear()
    const month = String(disposalDate.getMonth() + 1).padStart(2, '0')
    const day = String(disposalDate.getDate()).padStart(2, '0')

    return `${year}年${month}月${day}日`
  }

  @Builder
  FormHeader(label: string, required: boolean = false) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#333333')
      if (required) {
        Text('*')
          .fontSize(16)
          .fontColor('#FF0000')
      }
    }
  }

  validateForm(): boolean {
    if (!this.formData.location || !this.formData.date || !this.formData.type ||
      !this.formData.mealType || !this.formData.weight) {
      promptAction.showToast({
        message: '请填写必填项',
        duration: 2000
      })
      return false
    }

    // 验证重量是否小于125克
    const weight = Number(this.formData.weight)
    if (isNaN(weight) || weight < 125) {
      promptAction.showToast({
        message: '留样重量不能小于125克',
        duration: 2000
      })
      return false
    }

    return true
  }

  @Builder
  SubmitButton() {
    Button(this.isEditMode ? '保存' : '提交')
      .width('90%')
      .height(48)
      .fontSize(16)
      .fontColor('#FFFFFF')
      .backgroundColor('#00C853')
      .margin({ top: 16, bottom: 16 })
      .enabled(!this.isSubmitting)
      .onClick(async () => {
        if (this.validateForm()) {
          this.isSubmitting = true
          try {
            // 确保图片URL已设置
            if (this.formData.images.length === 0) {
              this.formData.images = ["https://admin.suoeryun.com/pcUpload/1917474932601933825_1745996623568.png"]
            }
            if (this.formData.cabinetImages.length === 0) {
              this.formData.cabinetImages = ["https://admin.suoeryun.com/pcUpload/1917474946438942721_1745996626850.png"]
            }

            let success = false
            if (this.isEditMode) {
              // 先调用API，然后更新本地存储
              await this.sampleService.updateSample(this.formData, this.editIndex)
              success = true
            } else {
              // 先调用API，然后保存到本地存储
              await this.sampleService.saveSample(this.formData)
              success = true
            }

            if (success) {
              await promptAction.showToast({
                message: this.isEditMode ? '保存成功' : '提交成功',
                duration: 2000
              })
              router.back()
            } else {
              await promptAction.showToast({
                message: this.isEditMode ? '保存失败，请检查网络连接' : '提交失败，请检查网络连接',
                duration: 2000
              })
            }
          } catch (error) {
            console.error('提交/保存留样失败:', error)
            await promptAction.showToast({
              message: this.isEditMode ? '保存失败，请重试' : '提交失败，请重试',
              duration: 2000
            })
          } finally {
            this.isSubmitting = false
          }
        }
      })
  }

  @Builder
  ImageDisplayArea(title: string, isForCabinet: boolean = false) {
    Column() {
      this.FormHeader(title)
      Row() {
        // 显示图片
        Image(isForCabinet ? 
          "https://admin.suoeryun.com/pcUpload/1917474946438942721_1745996626850.png" : 
          "https://admin.suoeryun.com/pcUpload/1917474932601933825_1745996623568.png")
          .width(200)
          .height(150)
          .objectFit(ImageFit.Cover)
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ top: 12 })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back()
          })
        Text(this.isEditMode ? '编辑留样' : '新增留样')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 政策提示文字
      Text(`根据政策要求，样本重量不少于125克，且该留样时间必须在48小时以上。预计该样本在${this.getDisposalDate()}后可以销毁。`)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 16, bottom: 16, left: 16, right: 16 })
        .lineHeight(20)

      // 表单内容
      Scroll() {
        Column() {
          // 提交单位
          Column() {
            this.FormHeader('提交单位', true)
            Select(this.locations)
              .value(this.formData.location)
              .onSelect((index: number) => {
                this.formData.location = this.locations[index].value
              })
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 留样日期
          Column() {
            this.FormHeader('留样日期', true)
            Row() {
              Text(this.formData.date)
                .fontSize(16)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .margin({ top: 8 })
            .onClick(() => {
              DatePickerDialog.show({
                selected: new Date(this.formData.date),
                onAccept: (value: DatePickerResult) => {
                  const date = value.year + '-' +
                  String(value.month).padStart(2, '0') + '-' +
                  String(value.day).padStart(2, '0')
                  this.formData.date = date
                }
              })
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 留样类型
          Column() {
            this.FormHeader('留样类型', true)
            Select(this.types)
              .value(this.formData.type)
              .onSelect((index: number) => {
                this.formData.type = this.types[index].value
              })
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 餐别
          Column() {
            this.FormHeader('餐别', true)
            Select(this.mealTypes)
              .value(this.formData.mealType)
              .onSelect((index: number) => {
                this.formData.mealType = this.mealTypes[index].value
              })
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 留样柜温度℃
          Column() {
            this.FormHeader('留样柜温度℃', true)
            TextInput({ text: this.formData.temperature.toString() })
              .type(InputType.Number)
              .fontSize(16)
              .backgroundColor('#F5F5F5')
              .width('100%')
              .height(48)
              .margin({ top: 8 })
              .onChange((value: string) => {
                // 确保输入的是有效数字
                const temp = Number(value)
                if (!isNaN(temp)) {
                  this.formData.temperature = temp
                }
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 菜品名称
          Column() {
            this.FormHeader('菜品名称')
            TextInput({ placeholder: '请输入菜品名称' })
              .fontSize(16)
              .backgroundColor('#F5F5F5')
              .width('100%')
              .height(48)
              .margin({ top: 8 })
              .onChange((value: string) => {
                this.formData.foodName = value
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 留样重量(克)
          Column() {
            this.FormHeader('留样重量(克)', true)
            TextInput({ placeholder: '请输入留样重量（不少于125克）' })
              .type(InputType.Number)
              .fontSize(16)
              .backgroundColor('#F5F5F5')
              .width('100%')
              .height(48)
              .margin({ top: 8 })
              .onChange((value: string) => {
                this.formData.weight = value
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 销毁人员
          Column() {
            this.FormHeader('销毁人员')
            TextInput({ placeholder: '请输入销毁人员' })
              .fontSize(16)
              .backgroundColor('#F5F5F5')
              .width('100%')
              .height(48)
              .margin({ top: 8 })
              .onChange((value: string) => {
                this.formData.staff = value
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 销毁时间
          Column() {
            this.FormHeader('销毁时间')
            Row() {
              Text(this.formData.disposalTime || '请选择销毁时间')
                .fontSize(16)
                .fontColor(this.formData.disposalTime ? '#333333' : '#999999')
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(48)
            .margin({ top: 8 })
            .backgroundColor('#F5F5F5')
            .onClick(() => {
              DatePickerDialog.show({
                selected: new Date(),
                onAccept: (value: DatePickerResult) => {
                  // 先选择日期，确保month不是undefined
                  if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                    const date = `${value.year}-${String(value.month + 1).padStart(2, '0')}-${String(value.day).padStart(2, '0')}`

                    // 然后显示时间选择器
                    TimePickerDialog.show({
                      selected: new Date(),
                      useMilitaryTime: true, // 使用24小时制
                      onAccept: (time: TimePickerResult) => {
                        const hours = String(time.hour).padStart(2, '0')
                        const minutes = String(time.minute).padStart(2, '0')
                        this.formData.disposalTime = `${date} ${hours}:${minutes}`
                      }
                    })
                  }
                }
              })
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 1 })

          // 使用简化的图片显示组件
          this.ImageDisplayArea('留样图片')
          this.ImageDisplayArea('留样柜图片', true)

          // 备注
          Column() {
            this.FormHeader('备注')
            TextArea({ placeholder: '请输入备注信息' })
              .width('100%')
              .height(100)
              .backgroundColor('#F5F5F5')
              .margin({ top: 8 })
              .onChange((value: string) => {
                this.formData.notes = value
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ top: 12 })
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')

      // 使用提交按钮组件
      this.SubmitButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 