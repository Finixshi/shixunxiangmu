import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';

// 商品分类接口定义
interface JyjFoodGroup {
  childNodes?: JyjFoodGroup[];
  createBy?: string;
  createTime?: string;
  forShort?: string;
  groupCode?: string;
  groupName?: string;
  id?: string;
  parentId?: string;
  sortNumber?: number;
}

// 库存项接口定义
class StockItem {
  accountingDate: string = '';
  batch: string = '';
  brandLevel: string = '';
  createBy: string = '';
  createTime: string = '';
  demandUnit: string = '';
  demandUnitName: string = '';
  encoding: string = '';
  expirationDate: string = '';
  expirationDay: number = 0;
  failureTime: string = '';
  foodId: string = '';
  foodName: string = '';
  groupId: string = '';
  groupName: string = '';
  id: string = '';
  images: string = '';
  izExpired: string = '';
  modifyPrice: number = 0;
  placeOrigin: string = '';
  producedDate: string = '';
  realSpecification: string = '';
  residueDay: string = '';
  schoolId: string = '';
  specification: string = '';
  supplyPricing: number = 0;
  totalNum: number = 0;
  unit: string = '';
  requirementType: string = '';
  requirementType_dictText: string = '';
  mealCategory: string = '';
  mealCategory_dictText: string = '';
  mealType: string = '';
  mealType_dictText: string = '';
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
  current: number;
  pages: number;
  records: T[];
  size: number;
  total: number;
}

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
struct kucun {
  @State activeTab: number = 0;
  @State message: string = '~暂无相关数据~';
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
  @State token: string = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiIyZjg5NWM4NDI2MWFlNzJiYmUyMjVkMjllOWJhZjVjZCIsImV4cCI6MTc0NzYxOTExNiwidXNlcm5hbWUiOiIxNTUwMjkzMzY3MyJ9.Zsc8fNnV0rlF17dLSv1RpO3ecWn96FOYQ7pH9Y0JJ7Q';
  @State tenantId: number = 10021011;

  private pageNo: number = 1;
  private readonly pageSize: number = 10;

  build() {
    Column() {
      this.buildHeader()
      this.buildTabs()
      this.buildFilters()
      this.buildContent()
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
        .fontSize(30)
        .margin({ right: 130 })
        .onClick(() => {
          router.back();
        });

      Text('实时库存')
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .padding(10)
  }

  // 构建选项卡
  @Builder
  buildTabs() {
    Row() {
      Text('非零库存')
        .fontSize(15)
        .fontWeight(this.activeTab === 0 ? FontWeight.Bold : FontWeight.Normal)
        .onClick(() => this.switchTab(0, '非零库存'))
        .margin({ right: 20 });

      Text('零库存')
        .fontSize(15)
        .fontWeight(this.activeTab === 1 ? FontWeight.Bold : FontWeight.Normal)
        .onClick(() => this.switchTab(1, '零库存'))
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 20 })
  }

  // 构建筛选器
  @Builder
  buildFilters() {
    Row() {
      this.buildSelect(this.categoryOptions, this.selectedCategoryValue,
        (value) => this.selectedCategoryValue = value, "25%");

      this.buildSelect(this.stockTypeOptions, this.selectedStockTypeValue,
        (value) => this.selectedStockTypeValue = value, "25%", 10);

      this.buildSelect(this.mealTypeOptions, this.selectedMealTypeValue,
        (value) => this.selectedMealTypeValue = value, "25%", 10);

      this.buildSelect(this.mealCategoryOptions, this.selectedMealCategoryValue,
        (value) => this.selectedMealCategoryValue = value, "25%", 10);
    }
    .width('90%')
    .margin({ bottom: 20 })
    .justifyContent(FlexAlign.SpaceBetween)

  }

  // 构建选择器组件
  @Builder
  buildSelect(options: SelectOption[], selectedValue: string,
    onSelect: (value: string) => void, width: string, marginLeft: number = 0) {
    Select(options)
      .selected(options.findIndex(opt => opt.value === selectedValue))
      .value(selectedValue)
      .onSelect((index) => onSelect(options[index].value))
      .width(width)
      .margin({ left: marginLeft })
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
        } else if (this.stockItems.length === 0) {
          Text(this.message)
            .fontSize(16)
        } else {
          ForEach(this.stockItems, (item: StockItem) => this.buildStockItem(item));


          if (this.hasMore) {
            LoadingProgress()
              .width(30)
              .height(30)
              .margin({ top: 10, bottom: 10 });
          } else {
            Text('没有更多数据了')
              .fontSize(14)
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
    .height('70%')
  }

  // 构建库存项卡片
  @Builder
  buildStockItem(item: StockItem) {
    Column() {
      Text(item.foodName || '未知商品')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 });

      Text(`供应价：${item.supplyPricing}`).fontSize(14);
      Text(`库存量：${item.totalNum}`).fontSize(14);
      Text(`状态：${item.izExpired === '1' ? '已过期' : '正常'}`).fontSize(14);
    }
    .padding(16)
    .width('95%')
    .margin({ top: 10, bottom: 10 })
    .borderRadius(10)
    .backgroundColor('#f5f5f5')
  }

  // 切换标签页
  private switchTab(tabIndex: number, tabContent: string) {
    this.currentTabContent = tabContent;
    this.activeTab = tabIndex;
    this.resetData();
    this.fetchStockItems();
  }

  aboutToAppear() {
    this.fetchStockItems();
  }

  resetData() {
    this.pageNo = 1;
    this.hasMore = true;
    this.stockItems = [];
    this.message = '~暂无相关数据~';
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
        izZero: this.activeTab === 0 ? '0' : '1'  // 修正参数值
      };

      // 添加筛选条件
      if (this.selectedCategoryValue !== '全部分类') {
        const selectedOption = this.categoryOptions.find(opt => opt.value === this.selectedCategoryValue);
        if (selectedOption?.id) {
          params.groupId = selectedOption.id;
        }
      }
      if (this.selectedStockTypeValue !== '全部类型') {
        params.requirementType = this.selectedStockTypeValue;
      }
      if (this.selectedMealTypeValue !== '全部用餐类型') {
        params.mealType = this.selectedMealTypeValue;
      }
      if (this.selectedMealCategoryValue !== '全部餐别') {
        params.mealCategory = this.selectedMealCategoryValue;
      }

      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'tenant-id': this.tenantId.toString(),
            'X-Access-Token': this.token
          },
          extraData: params
        }
      );

      if (response.responseCode === http.ResponseCode.OK) {
        const responseData: PageResponse<StockItem> = JSON.parse(response.result as string);

        if (responseData.code === 200 && responseData.result?.records) {
          const newItems = responseData.result.records.map(item => {
            const stockItem = new StockItem();
            stockItem.accountingDate = item.accountingDate;
            stockItem.batch = item.batch;
            stockItem.brandLevel = item.brandLevel;
            stockItem.createBy = item.createBy;
            stockItem.createTime = item.createTime;
            stockItem.demandUnit = item.demandUnit;
            stockItem.demandUnitName = item.demandUnitName;
            stockItem.encoding = item.encoding;
            stockItem.expirationDate = item.expirationDate;
            stockItem.expirationDay = item.expirationDay;
            stockItem.failureTime = item.failureTime;
            stockItem.foodId = item.foodId;
            stockItem.foodName = item.foodName;
            stockItem.groupId = item.groupId;
            stockItem.groupName = item.groupName;
            stockItem.id = item.id;
            stockItem.images = item.images;
            stockItem.izExpired = item.izExpired;
            stockItem.modifyPrice = item.modifyPrice;
            stockItem.placeOrigin = item.placeOrigin;
            stockItem.producedDate = item.producedDate;
            stockItem.realSpecification = item.realSpecification;
            stockItem.residueDay = item.residueDay;
            stockItem.schoolId = item.schoolId;
            stockItem.specification = item.specification;
            stockItem.supplyPricing = item.supplyPricing;
            stockItem.totalNum = item.totalNum;
            stockItem.unit = item.unit;
            stockItem.requirementType = item.requirementType;
            stockItem.requirementType_dictText = item.requirementType_dictText;
            stockItem.mealCategory = item.mealCategory;
            stockItem.mealCategory_dictText = item.mealCategory_dictText;
            stockItem.mealType = item.mealType;
            stockItem.mealType_dictText = item.mealType_dictText;

            return stockItem;
          });

          this.stockItems = this.pageNo === 1 ? newItems : [...this.stockItems, ...newItems];
          this.hasMore = responseData.result.records.length >= this.pageSize;
        } else {
          this.handleError(responseData.message || '请求失败');
        }
      } else {
        this.handleError(`网络错误: ${response.responseCode}`);
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error('Request failed:', err);
      this.handleError('网络请求失败，请检查连接');
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