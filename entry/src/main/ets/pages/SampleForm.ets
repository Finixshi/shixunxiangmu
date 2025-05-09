import router from '@ohos.router'
import { SampleFormData } from '../common/types'

@Entry
@Component
struct SampleForm {
  @State formData: SampleFormData = {
    location: '实训第一学校餐厅',
    date: '2025-05-07',
    type: '不区分',
    mealType: '午餐',
    temperature: 5,
    foodName: '',
    weight: '',
    staff: '',
    disposalTime: '',
    images: [],
    cabinetImages: [],
    notes: ''
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
        Text('上传每日留样')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 表单内容
      Scroll() {
        Column() {
          this.FormItem('提交单位', this.formData.location, true)
          this.FormItem('留样日期', this.formData.date, true)
          this.FormItem('留样类型', this.formData.type, true)
          this.FormItem('餐别', this.formData.mealType, true)
          this.FormItem('留样柜温度℃', this.formData.temperature.toString(), true)
          this.FormItem('菜品名称', this.formData.foodName)
          this.FormItem('留样重量(克)', this.formData.weight)
          this.FormItem('销毁人员', this.formData.staff)
          this.FormItem('销毁时间', this.formData.disposalTime)

          // 图片上传区域
          Column() {
            Text('上传留样图片')
              .fontSize(16)
              .fontColor('#333333')
            Row() {
              ForEach([1, 2, 3], () => {
                Column() {
                  Text('+')
                    .fontSize(40)
                    .fontColor('#999999')
                }
                .width(100)
                .height(100)
                .margin(8)
                .backgroundColor('#F5F5F5')
                .justifyContent(FlexAlign.Center)
              })
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ top: 12 })

          // 备注
          Column() {
            Text('备注')
              .fontSize(16)
              .fontColor('#333333')
            TextArea()
              .width('100%')
              .height(100)
              .margin({ top: 8 })
              .backgroundColor('#F5F5F5')
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

      // 提交按钮
      Button('提交')
        .width('90%')
        .height(50)
        .backgroundColor('#00C853')
        .margin({ top: 16, bottom: 16 })
        .onClick(() => {
          // 处理提交逻辑
          router.back()
        })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FormItem(label: string, value: string, required: boolean = false) {
    Row() {
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
      Text(value)
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ top: required ? 0 : 1 })
  }
} 