import router from '@ohos.router';
import fileSelect from '@ohos.file.picker';
import image from '@ohos.multimedia.image';
import common from '@ohos.app.ability.common';

interface FormData {
  qualificationName: string;
  issueDate: string;
  qualificationType: string;
  issuingAuthority: string;
  isLongTermValid: boolean;
  remarks: string;
  imagePath: string;
}

@Entry
@Component
struct QualificationInfo {
  @State formData: FormData = {
    qualificationName: '',
    issueDate: '',
    qualificationType: '',
    issuingAuthority: '',
    isLongTermValid: true,
    remarks: '',
    imagePath: ''
  };
  @State showError: boolean = false;

  validateForm(): boolean {
    if (!this.formData.qualificationName ||
      !this.formData.issueDate ||
      !this.formData.qualificationType ||
      !this.formData.issuingAuthority) {
      this.showError = true;
      return false;
    }
    return true;
  }

  async selectImage(): Promise<void> {
    try {
      const photoSelectOptions: fileSelect.PhotoSelectOptions = {
        MIMEType: fileSelect.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      };
      const photoPicker = new fileSelect.PhotoViewPicker();
      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.formData.imagePath = photoSelectResult.photoUris[0];
      }
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : '选择图片失败';
      console.error(`Failed to pick image: ${errMsg}`);
    }
  }
  @State selectedUnit: string = '';
  @State currentDate: Date = new Date()
  @State selectedDate: string = '请选择发证时间'
  @State selectDate: Date = new Date()
  private getThisWeekDates(): Array<Date> {
    const start = new Date(this.currentDate)
    start.setDate(start.getDate() - start.getDay() + 1) // 周一

    const dates: Date[] = []
    for (let i = 0; i < 7; i++) {
      const d = new Date(start)
      d.setDate(start.getDate() + i)
      dates.push(d)
    }
    return dates
  }

  private showDateDialog() {
    DatePickerDialog.show({
      start: new Date('2000-1-1'),
      end: new Date('2100-1-1'),
      selected: this.selectDate,
      onAccept: (value: DatePickerResult) => {
        // 使用可选链和默认值保证安全性
        const year = value.year?? new Date().getFullYear()
        const month = value.month?? new Date().getMonth()
        const day = value.day?? new Date().getDate()

        // 不需要再减1
        this.selectDate = new Date(year, month, day)
        this.selectedDate = `${year}-${(month + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
      }
    })
  }
  private Qualification = [
    '营业执照',
    '食品经营许可证',
    '食品生产许可证',
    '质检报告',
    '其他'
  ];

  build() {
    Column() {
      // Header with back button
      Row() {
        Text('<')
          .width(24)
          .height(24)
          .fontSize(24)
          .margin({ left: 16 })
          .onClick((): void => {
            router.back();
          })
        Text('资质信息管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          // Form fields
          Column() {
            Text('资质名称 *')
              .width('100%')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })

            TextInput({ placeholder: '请输入资质名称' })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .onChange((value: string): void => {
                this.formData.qualificationName = value;
              })
            Text('发证时间 *')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 10, bottom: 8 })


            Row({ space: 10 }) {
              Select([])
                .value(this.selectedDate)
                .onClick(() => {
                  this.showDateDialog()
                })
                .margin(10)
                .width('90%')
                .height(70)
                .font({ size: 20 })
            }
            .justifyContent(FlexAlign.Center)
            .padding({ bottom: 20 })


            Text('资质类型 *')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })


            Row() {
              Text("请选择类型")
              Select(this.Qualification.map<SelectOption>((item: string) => ({ value: item })))
                .value('请选择')
                .value(this.selectedUnit)
                .onSelect((index: number) => {
                  this.selectedUnit = this.Qualification[index];
                })
                .margin(10)
                .width('70%')
            }

            Text('发证机构 *')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })

            TextInput({ placeholder: '请输入单位' })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .onChange((value: string): void => {
                this.formData.issuingAuthority = value;
              })

            Text('是否长期有效')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })

            Row() {
              Row({ space: 8 }) {
                Radio({ value: '是', group: 'validityGroup' })
                  .checked(this.formData.isLongTermValid)
                  .onChange((isChecked: boolean): void => {
                    if (isChecked) this.formData.isLongTermValid = true;
                  })
                Text('是').fontSize(16)
              }
              Row({ space: 8 }) {
                Radio({ value: '否', group: 'validityGroup' })
                  .checked(!this.formData.isLongTermValid)
                  .onChange((isChecked: boolean): void => {
                    if (isChecked) this.formData.isLongTermValid = false;
                  })
                Text('否').fontSize(16)
              }
            }
            .width('100%')
            .margin({ top: 8, bottom: 16 })
            .justifyContent(FlexAlign.SpaceBetween)

            Text('备注')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })

            TextArea({ placeholder: '请输入备注信息' })
              .width('100%')
              .height(50)
              .backgroundColor('#F5F5F5')
              .onChange((value: string): void => {
                this.formData.remarks = value;
              })




            Button('提交')
              .width('100%')
              .height(48)
              .backgroundColor('#4CAF50')
              .fontColor(Color.White)
              .onClick(()=> {
                if (this.validateForm()) {
                  router.back({
                    url: 'pages/daishenpiliebiao'
                  });
                }
              })
          }
          .padding(16)
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
