import router from '@ohos.router';
import { getQualificationService, QualificationInfo } from '../common/services/QualificationService';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct QualificationStatusPage {
  @State selectedStatus: 'pending' | 'approved' | 'rejected' = 'pending';
  @State qualifications: QualificationInfo[] = [];
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State totalItems: number = 0;
  @State isLoading: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;
  private qualificationService = getQualificationService(this.context);

  aboutToAppear() {
    this.loadQualifications();
  }

  async loadQualifications() {
    this.isLoading = true;
    try {
      const response = await this.qualificationService.getQualificationList(
        this.selectedStatus,
        this.currentPage,
        this.pageSize
      );

      if (response) {
        this.qualifications = response.records;
        this.totalItems = response.total;
      } else {
        this.qualifications = [];
        this.totalItems = 0;
      }
    } catch (error) {
      console.error('加载资质信息失败:', error);
      await promptAction.showToast({
        message: '加载失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
        Text('资质信息')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF');

      // 审批状态切换按钮
      Row() {
        Text('待审批')
          .fontSize(16)
          .fontColor(this.selectedStatus === 'pending' ? '#2BB673' : '#333')
          .padding(10)
          .onClick(() => {
            this.selectedStatus = 'pending';
            this.currentPage = 1;
            this.loadQualifications();
          })
        Text('已审批')
          .fontSize(16)
          .fontColor(this.selectedStatus === 'approved' ? '#2BB673' : '#333')
          .padding(10)
          .onClick(() => {
            this.selectedStatus = 'approved';
            this.currentPage = 1;
            this.loadQualifications();
          })
        Text('已驳回')
          .fontSize(16)
          .fontColor(this.selectedStatus === 'rejected' ? '#2BB673' : '#333')
          .padding(10)
          .onClick(() => {
            this.selectedStatus = 'rejected';
            this.currentPage = 1;
            this.loadQualifications();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
      .margin({ bottom: 8 });

      // 资质列表
      List() {
        ForEach(this.qualifications, (item: QualificationInfo) => {
          ListItem() {
            Column() {
              Row() {
                Text(item.qualificationName)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text(item.createTime?.split(' ')[0] || '')
                  .fontSize(14)
                  .fontColor('#999')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 8 })

              Row() {
                Column() {
                  Text('发证机构')
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ bottom: 4 })
                  Text(item.issuingAuthority)
                    .fontSize(14)
                }
                .layoutWeight(1)

                Column() {
                  Text('资质类型')
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ bottom: 4 })
                  Text(item.qualificationType)
                    .fontSize(14)
                }
                .layoutWeight(1)

                Column() {
                  Text('发证时间')
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ bottom: 4 })
                  Text(item.issueDate)
                    .fontSize(14)
                }
                .layoutWeight(1)
              }
              .width('100%')

              if (item.remarks) {
                Text(item.remarks)
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 8 })
                  .width('100%')
              }

              if (item.imagePath) {
                Image(item.imagePath)
                  .width(80)
                  .height(80)
                  .objectFit(ImageFit.Cover)
                  .margin({ top: 8 })
              }
            }
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/zizhixinxiguanli',
                params: { id: item.id }
              });
            })
          }
          .margin({ bottom: 8 })
        })
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 16, right: 16 })

      if (this.isLoading) {
        LoadingProgress()
          .color('#2BB673')
          .width(24)
          .height(24)
      }
      // 数据展示区
      Column() {
        Text('~ 暂无相关数据 ~')
          .fontSize(16)
          .fontColor(Color.Gray)
          .padding(20)
      }
      .alignItems(HorizontalAlign.Center)
      .height('50%')

      Button('提交')
        .fontSize(18)
        .backgroundColor('#2BB673')
        .fontColor(Color.White)
        .borderRadius(10)
        .width('80%')
        .onClick(() => {
          router.pushUrl({ url: 'pages/zizhixinxiguanli' })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}