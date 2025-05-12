import router from '@ohos.router';
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import promptAction from '@ohos.promptAction';

// 接口响应数据类型定义
interface OutboundOrder {
  accountingDate: string;
  approvalTime: string;
  approvalUser: string;
  approvalUserName: string;
  createTime: string;
  demandUnit: string;
  demandUnitName: string;
  digest: string;
  documentNo: string;
  mealCategory: string;
  mealCategory_dictText: string;
  mealType: string;
  mealType_dictText: string;
  requirementType: string;
  requirementType_dictText: string;
  schoolId: string;
  schoolName: string;
  stockStatus: string;
  stockStatus_dictText: string;
  totalPrice: number;
}

interface GeneratedTypeLiteralInterface_1 {
  current: number;
  pages: number;
  records: OutboundOrder[];
  size: number;
  total: number;
}

interface ApiResponse {
  code: number;
  message: string;
  result: GeneratedTypeLiteralInterface_1;
  success: boolean;
  timestamp: number;
}

interface RouterParams {
  token?: string;
  relTenantIds?: number;
}

@Entry
@Component
struct PurchaseInventory {
  @State activeTab: number = 0;
  @State message: string = '~暂无相关数据~';
  @State showSupplierPopup: boolean = false;
  @State showDatePopup: boolean = false;
  @State selectedValue: string = '领用单位';
  @State currentTabContent: string = '待审批';
  @State isPressed: boolean = false;

  // 分页相关状态
  @State pageNo: number = 1;
  @State pageSize: number = 10;
  @State total: number = 0;
  @State loading: boolean = false;
  @State orderList: OutboundOrder[] = [];

  // 存储路由参数
  @State token: string = '';
  @State tenantId: number = 0;

  private options: SelectOption[] = [
    { value: '领用单位' },
    { value: '实训第一学校餐厅' }
  ]

  aboutToAppear() {
    try {
      const params = router.getParams() as RouterParams;
      if (params) {
        this.token = params.token || '';
        this.tenantId = params.relTenantIds || 0;
      }
      this.loadData();
    } catch (error) {
      console.error('Router params error:', error.message);
    }
  }

  // 加载数据
  async loadData() {
    if (this.loading) return;
    this.loading = true;

    try {
      // 创建HTTP请求对象
      let httpRequest = http.createHttp();

      // 设置请求参数
      let url = 'https://api.suoeryun.com/ifood/school/xxSupplyOutManagement/list';

      let response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Accept': 'application/json, text/plain, */*',
            'tenant-id': this.tenantId.toString(),
            'X-Access-Token': this.token
          },
          extraData: {
            pageNo: this.pageNo,
            pageSize: this.pageSize,
            stockStatus: this.activeTab === 0 ? '0' : '1'
          }
        }
      );

      if (response.responseCode === http.ResponseCode.OK) {
        const responseData = JSON.parse(response.result as string) as ApiResponse;
        if (responseData.code === 200) {
          this.orderList = responseData.result.records;
          this.total = responseData.result.total;
          if (this.orderList.length === 0) {
            this.message = '暂无数据';
          }
        } else {
          this.message = responseData.message || '请求失败';
          promptAction.showToast({
            message: this.message,
            duration: 2000
          });
        }
      } else {
        this.message = '网络请求失败';
        promptAction.showToast({
          message: this.message,
          duration: 2000
        });
      }
    } catch (error) {
      const err = error as BusinessError;
      this.message = '网络请求失败';
      console.error('Request failed:', err.message);
      promptAction.showToast({
        message: this.message,
        duration: 2000
      });
    } finally {
      this.loading = false;
      let httpRequest: http.HttpRequest;

      // 释放HTTP客户端资源

    }
  }

  build() {
    Column() {
      Row() {
        Text('<')
          .alignSelf(ItemAlign.Start)
          .fontSize(30)
          .margin({ top: 0, bottom: 10, right: 125 })
          .onClick(() => {
            router.back()
          });
        Text('供应出库')
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Center)
          .margin({ top: 0, bottom: 10 });
      }
      .width('100%');


      // 选项卡
      Row() {
        Text('待审批')
          .fontSize(16)
          .fontWeight(this.activeTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .width('50%')
          .maxLines(1)
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentTabContent = '待审批';
            this.activeTab = 0;
            this.pageNo = 1;
            this.loadData();
          });

        Text('已审批')
          .fontSize(16)
          .fontWeight(this.activeTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .width('50%')
          .maxLines(1)
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentTabContent = '已审批';
            this.activeTab = 1;
            this.pageNo = 1;
            this.loadData();
          });
      }
      .width('100%')
      .margin({ left: 10, right: 10, bottom: 10 });

      // 选择框
      Row() {
        Select(this.options)
          .selected(0)
          .value(this.selectedValue)
          .onSelect((_: number, value: string) => {
            this.selectedValue = value;
            this.loadData();
          })
          .alignSelf(ItemAlign.Start)
          .width("100%")
          .fontColor('#333')
          .backgroundColor('#FFF')
          .borderRadius(8)
          .border({ width: 0, color: '#DDD' });
      }
      .margin({ bottom: 10 });

      // 内容展示区
      Scroll() {
        Column() {
          if (this.loading) {
            LoadingProgress()
              .width(50)
              .height(50)
              .margin(20);
          } else if (this.orderList.length === 0) {
            Text(this.message)
              .fontSize(16)
              .fontWeight(FontWeight.Normal)
              .alignSelf(ItemAlign.Center);
          } else {
            ForEach(this.orderList, (item: OutboundOrder) => {
              Column() {
                Text(item.demandUnitName || '实训第一学校餐厅')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 8 });
                Text(`单据号：${item.documentNo}`).fontSize(16).margin({ bottom: 2 });
                Text(`出库日期：${item.accountingDate}`).fontSize(16).margin({ bottom: 2 });
                Text(`出库类型：${item.mealType_dictText}`).fontSize(16).margin({ bottom: 2 });
                Text(`用餐类型：${item.requirementType_dictText}`).fontSize(16).margin({ bottom: 2 });
                Text(`餐    别：${item.mealCategory_dictText}`).fontSize(16).margin({ bottom: 2 });
                Text(`制单时间：${item.createTime}`).fontSize(16).margin({ bottom: 2 });
              }
              .padding(16)
              .backgroundColor('#fff')
              .borderRadius(16)
              .border({ width: 2, color: '#07C160' })
              .width('95%')
              .margin({ top: 20, bottom: 20 })
              .shadow({ radius: 8, color: '#07C160', offsetX: 0, offsetY: 4 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/yishenpi',
                  params: {
                    orderId: item.documentNo,
                    token: this.token,
                    relTenantIds: this.tenantId
                  }
                });
              });
            });

            // 加载更多
            if (this.orderList.length < this.total) {
              Text('加载更多')
                .fontSize(14)
                .fontColor('#666')
                .padding(10)
                .onClick(() => {
                  this.pageNo++;
                  this.loadData();
                });
            }
          }
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);

      // 底部按钮
      Text('新建出库单')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .padding(12)
        .backgroundColor(Color.Green)
        .width('90%')
        .alignSelf(ItemAlign.Center)
        .textAlign(TextAlign.Center)
        .margin({ top: 15, bottom: 20 })
        .borderRadius(8)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.isPressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.isPressed = false;
          }
        })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/chukudan',
            params: {
              token: this.token,
              relTenantIds: this.tenantId
            }
          });
        });
    }
    .height('100vh')
    .width('100vw')
    .padding({ top: 10, bottom: 20, left: 10, right: 10 })
    .backgroundColor(Color.White);
  }
}