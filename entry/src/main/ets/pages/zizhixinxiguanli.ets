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

  build() {
    Column() {
      // Header with back button
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
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
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })
            
            TextInput({ placeholder: '请输入资质名称' })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .type(InputType.Normal)
              .inputFilter('^[\u4e00-\u9fa5a-zA-Z0-9_]+$')
              .onChange((value: string): void => {
                this.formData.qualificationName = value;
              })

            Text('发证时间 *')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })

            TextInput({ placeholder: '请选择发证时间' })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .type(InputType.Normal)
              .onChange((value: string): void => {
                this.formData.issueDate = value;
              })

            Text('资质类型 *')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })

            TextInput({ placeholder: '请选择资质类型' })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .type(InputType.Normal)
              .inputFilter('^[\u4e00-\u9fa5a-zA-Z0-9_]+$')
              .onChange((value: string): void => {
                this.formData.qualificationType = value;
              })

            Text('发证机构 *')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })

            TextInput({ placeholder: '请输入单位' })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .type(InputType.Normal)
              .inputFilter('^[\u4e00-\u9fa5a-zA-Z0-9_]+$')
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
              .inputFilter('^[\u4e00-\u9fa5a-zA-Z0-9_\n\r]+$')
              .onChange((value: string): void => {
                this.formData.remarks = value;
              })

            Text('上传资质图片 *')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })

            Column() {
              if (this.formData.imagePath) {
                Image(this.formData.imagePath)
                  .width(50)
                  .height(50)
                  .objectFit(ImageFit.Cover)
              } else {
                Button() {
                  Row() {
                    Image($r('app.media.upload'))
                      .width(10)
                      .height(10)
                    Text('上传资质图片')
                      .fontSize(16)
                      .margin({ left: 8 })
                  }
                }
                .type(ButtonType.Normal)
                .onClick(() => {
                  void this.selectImage();
                })
              }
            }
            .width('100%')
            .height(50)
            .backgroundColor('#F5F5F5')
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 24 })

            if (this.showError) {
              Text('请填写必填项')
                .fontSize(14)
                .fontColor(Color.Red)
                .margin({ bottom: 16 })
            }

            Button('提交')
              .width('100%')
              .height(48)
              .backgroundColor('#4CAF50')
              .fontColor(Color.White)
              .onClick((): void => {
                if (this.validateForm()) {
                  router.pushUrl({
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