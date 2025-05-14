import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';

// 商品分类接口定义
interface JyjFoodGroup {
  id: string;
  parentId: string;
  groupCode: string;
  groupName: string;
  sortNumber: number;
  forShort: string;
  createBy: null;
  createTime: null;
  updateBy: null;
  updateTime: null;
  tenantId: string;
  testType: null;
  childNodes: null;
  foodType: null;
  itemName: null;
}

// 库存项接口定义
interface StockItem {
  id?: string;
  createBy?: string;
  createTime?: string;
  updateBy?: string;
  updateTime?: string;
  schoolId?: string;
  demandUnit?: string;
  demandUnitName?: string;
  foodId?: string;
  foodName?: string;
  encoding?: string;
  groupId?: string;
  groupName?: string;
  unit?: string;
  specification?: string;
  brandLevel?: string;
  modifyPrice?: number;
  supplyPricing?: number;
  totalNum?: number;
  totalWeight?: number;
  storageLocation?: string;
  supplyWay?: string;
  supplierId?: string;
  supplierName?: string;
  producedDate?: string;
  batch?: string;
  izRemind?: string;
  images?: string;

  expirationDay?: number;
  izConvert?: string;
  failureTime?: string;
  tenantId?: string;
  requirementType?: string;
  realSpecification?: string;
  placeOrigin?: string;
  izExpired?: string;
  internationalCode?: string;
  residueDay?: string;
  expirationDate?: string;
  mealType?: string;
  mealCategory?: string;
  accountingDate?: string;
  requirementType_dictText?: string;
  mealType_dictText?: string;
  mealCategory_dictText?: string;
}

// 接口返回整体结构
interface ApiResponse<T> {
  code: number;
  message: string;
  result: T[];
  success: boolean;
  timestamp: number;
}

// 分页列表返回结构
interface PageResult<T> {
  total: number;
  size: number;
  current: number;
  pages: number;
  records: T[];
  optimizeCountSql?: boolean;
  searchCount?: boolean;
  countId?: string;
  maxLimit?: string;
}

// 修改后的 PageResponse 接口
interface PageResponse<T> {
  code: number;
  message: string;
  result: PageResult<T>;
  success: boolean;
  timestamp: number;
}

// 定义 SelectOption 类
class SelectOption {
  value: string;
  id?: string;

  constructor(value: string, id?: string) {
    this.value = value;
    this.id = id;
  }
}

// 定义请求参数接口
interface RequestParams {
  pageNo: number;
  pageSize: number;
  foodName?: string;
  groupId?: string;
  izZero?: string;
  mealCategory?: string;
  mealType?: string;
  requirementType?: string;
}

@Entry
@Component
struct Kucun {
  @State activeTab: number = 1;
  @State message: string = '~暂无相关数据~';
  @State showSupplierPopup: boolean = false;
  @State showDatePopup: boolean = false;
  @State loading: boolean = false;
  @State hasMore: boolean = true;

  // 商品分类选项
  @State categoryOptions: SelectOption[] = [
    new SelectOption('全部分类'),
    new SelectOption('谷薯类'),
    new SelectOption('蔬菜水果类'),
    new SelectOption('鱼禽肉蛋类'),
    new SelectOption('牛奶类'),
    new SelectOption('大豆坚果类'),
    new SelectOption('干菜调料类'),
    new SelectOption('糕点面包类'),
    new SelectOption('主食半成品类'),
    new SelectOption('其他')
  ];
  @State stockTypeOptions: SelectOption[] = [
    new SelectOption('全部类型'),
    new SelectOption('学生餐'),
    new SelectOption('教师餐')
  ];
  @State mealTypeOptions: SelectOption[] = [
    new SelectOption('全部用餐类型'),
    new SelectOption('其他'),
    new SelectOption('营养餐')
  ];
  @State mealCategoryOptions: SelectOption[] = [
    new SelectOption('全部餐别'),
    new SelectOption('其他'),
    new SelectOption('早餐'),
    new SelectOption('午餐'),
    new SelectOption('晚餐')
  ];

  @State selectedCategoryValue: string = '全部分类';
  @State selectedStockTypeValue: string = '全部类型';
  @State selectedMealTypeValue: string = '全部用餐类型';
  @State selectedMealCategoryValue: string = '全部餐别';
  @State currentTabContent: string = '非零库存';
  @State stockItems: StockItem[] = [];
  @State token: string = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiIyZjg5NWM4NDI2MWFlNzJiYmUyMjVkMjllOWJhZjVjZCIsImV4cCI6MTc0NzYxOTExNiwidXNlcm5hbWUiOiIxNTUwMjkzMzY3MyJ9.Zsc8fNnV0rlF17dLSv1RpO3ecWn96FOYQ7pH9Y0JJ7Q'; // 替换为你的实际 token
  @State tenantId: number = 10021011;

  private pageNo: number = 1;
  private readonly pageSize: number = 10;

  build() {
    Column() {
      this.buildHeader();
      this.buildTabs();
      this.buildFilters();
      this.buildContent();
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.White);
  }

  // 构建头部
  @Builder
  buildHeader() {
    Row() {
      Text('<')
        .alignSelf(ItemAlign.Start)
        .fontSize(30)
        .margin({ top: 0, bottom: 10, right: 130 })
        .onClick(() => {
          router.back();
        });

      Text('实时库存')
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Center)
        .margin({ top: 0, bottom: 10 });
    }
    .width('100%');
  }

  // 构建选项卡
  @Builder
  buildTabs() {
    Row() {
      Text('非零库存')
        .fontSize(15)
        .fontWeight(this.activeTab === 1 ? FontWeight.Bold : FontWeight.Normal)
        .width('50%')
        .maxLines(1)
        .alignSelf(ItemAlign.Center)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.switchTab(1, '非零库存');
        });

      Text('零库存')
        .fontSize(15)
        .fontWeight(this.activeTab === 0 ? FontWeight.Bold : FontWeight.Normal)
        .width('50%')
        .maxLines(1)
        .alignSelf(ItemAlign.Center)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.switchTab(0, '零库存');
        });
    }
    .width('100%')
    .margin({ left: 10, right: 10, bottom: 20 });
  }

  // 构建筛选器
  @Builder
  buildFilters() {
    Row() {
      this.buildSelect(this.categoryOptions, this.selectedCategoryValue, (value: string) => {
        this.selectedCategoryValue = value;
        this.resetData();
        this.fetchStockItems();
      }, "25%");

      this.buildSelect(this.stockTypeOptions, this.selectedStockTypeValue, (value: string) => {
        this.selectedStockTypeValue = value;
        this.resetData();
        this.fetchStockItems();
      }, "25%", 10);

      this.buildSelect(this.mealTypeOptions, this.selectedMealTypeValue, (value: string) => {
        this.selectedMealTypeValue = value;
        this.resetData();
        this.fetchStockItems();
      }, "25%", 10);

      this.buildSelect(this.mealCategoryOptions, this.selectedMealCategoryValue, (value: string) => {
        this.selectedMealCategoryValue = value;
        this.resetData();
        this.fetchStockItems();
      }, "25%", 10);
    }
    .width('90%')
    .margin({ bottom: 20 });
  }

  // 构建选择器组件
  @Builder
  buildSelect(options: SelectOption[], selectedValue: string, onSelect: (value: string) => void, width: string, marginLeft: number = 0) {
    Select(options)
      .selected(options.findIndex(opt => opt.value === selectedValue))
      .value(selectedValue)
      .onSelect((index: number) => {
        onSelect(options[index].value);
      })
      .alignSelf(ItemAlign.Start)
      .width(width)
      .fontColor('#333')
      .backgroundColor('#FFF')
      .borderRadius(8)
      .border({ width: 0, color: '#DDD' })
      .margin({ left: marginLeft })
      .font({ size: '20px' });
  }

  // 构建内容区域
  @Builder
  buildContent() {
    Scroll() {
      Column() {
        if (this.loading && this.pageNo === 1) {
          LoadingProgress()
            .width(50)
            .height(50)
            .margin(20);
        } else if (this.stockItems.length === 0) {
          Text(this.message)
            .fontSize(16)
            .fontWeight(FontWeight.Normal)
            .alignSelf(ItemAlign.Center);
        } else {
          ForEach(this.stockItems, (item: StockItem) => {
            this.buildStockItem(item);
          });

          if (this.hasMore) {
            LoadingProgress()
              .width(30)
              .height(30)
              .margin({ top: 10, bottom: 10 });
          } else {
            Text('没有更多数据了')
              .fontSize(14)
              .margin({ top: 10, bottom: 10 });
          }
        }
      }
      .width('100%')
      .onAppear(() => {
        if (!this.loading && this.hasMore) {
          this.pageNo += 1;
          this.fetchStockItems();
        }
      });
    }
  }

  // 构建库存项卡片
  @Builder
  buildStockItem(item: StockItem) {
    Column() {
      Text(item.foodName || '未知商品')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 });
      Text(`供应价：${item.modifyPrice || '未知'}`).fontSize(16).alignSelf(ItemAlign.Start).margin({ bottom: 2 });
      Text(`入库时间：${item.createTime || '未知'}`).fontSize(16).alignSelf(ItemAlign.Start).margin({ bottom: 2 });
      Text(`库存量：${item.totalNum || '未知'}`).fontSize(16).alignSelf(ItemAlign.Start).margin({ bottom: 2 });
      Text(`需求类型：${item.requirementType_dictText || '未知'}`).fontSize(16).alignSelf(ItemAlign.Start).margin({ bottom: 2 });
      Text(`用餐类型：${item.mealType_dictText || '未知'}`).fontSize(16).alignSelf(ItemAlign.Start).margin({ bottom: 2 });
      Text(`供应商：${item.supplierName || '未知'}`).fontSize(16).alignSelf(ItemAlign.Start).margin({ bottom: 2 });
      Text(`状态：${item.izExpired === '1' ? '已过期' : '正常'}`).fontSize(16).alignSelf(ItemAlign.Start).margin({ bottom: 2 });
    }
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(16)
    .border({ width: 2, color: '#07C160' })
    .width('95%')
    .margin({ top: 20, bottom: 20 })
    .shadow({ radius: 8, color: '#07C160', offsetX: 0, offsetY: 4 });
  }

  // 切换标签页
  private switchTab(tabIndex: number, tabContent: string) {
    this.currentTabContent = tabContent;
    this.activeTab = tabIndex;
    this.resetData();
    this.fetchStockItems();
  }

  aboutToAppear() {
    this.fetchCategoryOptions();
    this.fetchStockItems();
  }

  resetData() {
    this.pageNo = 1;
    this.hasMore = true;
    this.stockItems = [];
    this.message = '~暂无相关数据~';
  }

  // 查询商品分类
  async fetchCategoryOptions() {
    let httpRequest = http.createHttp();
    try {
      const url = 'https://api.suoeryun.com/ifood/education/jyjFoodGroup/queryFoodGroupByGroupId';
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Accept': 'application/json, text/plain, */*',
            'tenant-id': this.tenantId.toString(),
            'X-Access-Token': this.token
          }
        }
      );

      if (response.responseCode === http.ResponseCode.OK) {
        const responseData: ApiResponse<JyjFoodGroup> = JSON.parse(response.result as string);
        if (responseData.code === 200 && responseData.result) {
          // 动态更新分类选项
          this.categoryOptions = [
            new SelectOption('全部分类'), // 保留默认选项
            ...responseData.result.map((group: JyjFoodGroup) => new SelectOption(group.groupName, group.id))
          ];
          if (this.categoryOptions.length > 1) { // 如果有分类数据，设置第一个分类为默认值
            this.selectedCategoryValue = this.categoryOptions[1].value;
          }
        } else {
          this.handleError(responseData.message || '请求失败');
        }
      } else {
        this.handleError('网络请求失败');
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error('Request failed:', err.message);
      this.handleError('网络请求失败');
    } finally {
      httpRequest.destroy();
    }
  }

  // 查询库存列表
  async fetchStockItems() {
    this.loading = true;
    let httpRequest = http.createHttp();
    try {
      const url = 'https://api.suoeryun.com/ifood/school/xxRealTimeInventory/list';
      const params: RequestParams = {
        pageNo: this.pageNo,
        pageSize: this.pageSize,
        izZero: this.activeTab === 0 ? '1' : '0'
      };

      // 添加筛选条件
      if (this.selectedCategoryValue && this.selectedCategoryValue !== '全部分类') {
        const selectedOption = this.categoryOptions.find(opt => opt.value === this.selectedCategoryValue);
        if (selectedOption && selectedOption.id) {
          params.groupId = selectedOption.id;
        }
      }
      if (this.selectedStockTypeValue && this.selectedStockTypeValue !== '全部类型') {
        params.requirementType = this.selectedStockTypeValue;
      }
      if (this.selectedMealTypeValue && this.selectedMealTypeValue !== '全部用餐类型') {
        params.mealType = this.selectedMealTypeValue;
      }
      if (this.selectedMealCategoryValue && this.selectedMealCategoryValue !== '全部餐别') {
        params.mealCategory = this.selectedMealCategoryValue;
      }

      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Accept': 'application/json, text/plain, */*',
            'tenant-id': this.tenantId.toString(),
            'X-Access-Token': this.token
          },
          extraData: params
        }
      );

      if (response.responseCode === http.ResponseCode.OK) {
        const responseData: PageResponse<StockItem> = JSON.parse(response.result as string);
        if (responseData.code === 200 && responseData.result && Array.isArray(responseData.result.records)) {
          if (this.pageNo === 1) {
            this.stockItems = responseData.result.records;
          } else {
            this.stockItems = [...this.stockItems, ...responseData.result.records];
          }
          this.hasMore = responseData.result.pages > this.pageNo;
        } else {
          this.handleError(responseData.message || '请求失败');
        }
      } else {
        this.handleError('网络请求失败');
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error('Request failed:', err.message);
      this.handleError('网络请求失败');
    } finally {
      this.loading = false;
      httpRequest.destroy();
    }
  }

  // 处理错误
  private handleError(message: string) {
    this.message = message;
    promptAction.showToast({
      message: this.message,
      duration: 2000
    });
  }
}