import { promptAction } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import router from '@ohos.router';
import http from '@ohos.net.http';

// 定义食材接口
interface FoodItem {
  id: string;
  name: string;
  code: string;
  categoryId: string;
  categoryName: string;
  unit: string;
  specType: number;
  price: number;
  quantity: number;
  batchNumber?: string;
  selectId?: string;
  weight?: number;
}

// 定义食物项接口（用于API请求）
interface FoodRequestItem {
  foodId: string;
  foodName: string;
  encoding: string;
  groupId: string;
  groupName: string;
  unit: string;
  specification: string;
  supplyPricing: number;
  totalNum: number;
  supplyWay: string;
  batch: string;
  requirementType: string;
  mealType: string;
  mealCategory: string;
  accountingDate: string;
  requirementType_dictText: string;
  mealType_dictText: string;
  mealCategory_dictText: string;
  num: string;
  selectId: string;
  marketWeight: number;
}

// 定义API请求数据结构
interface OutboundRequest {
  id?: string;
  accountingDate: string;
  demandUnit: string;
  demandUnitName: string;
  digest: string;
  mealType: string;
  requirementType: string;
  mealCategory: string;
  stockStatus: string;
  foods: FoodRequestItem[];
}

// 定义API响应数据结构
interface ApiResponse {
  code: number;
  message: string;
  result: string;
  success: boolean;
  timestamp: number;
}

// 定义路由参数接口
interface RouterParams {
  selectedFoods?: FoodItem[];
}

@Entry
@Component
struct DatePickerExample {
  @State selectedDate: string = '';
  @State selectDate: Date = new Date();
  @State showDialog: boolean = false;
  @State opacityValue: number = 0;
  @State scaleValue: number = 0.8;
  @State summary: string = ''; // 摘要内容
  @State selectedText: string[] = ['请选择', '请选择', '请选择', '请选择', '请选择', '请选择', '请输入摘要'];
  @State selectedValues: string[] = ['', '', '', '', '', '', '']; // 存储实际值
  @State selectedFoods: FoodItem[] = []; // 存储选中的食材
  @State totalPrice: number = 0; // 总计金额
  @State isLoading: boolean = false; // 加载状态

  private readonly unitOptions: string[] = ['实训第一学校（库房）', '实训第一学校餐厅'];
  private readonly unitValues: string[] = ['1910528462460329985', '1910528462460329986']; // 示例 unit IDs
  private readonly demandOptions: string[] = ['学生餐', '老师餐'];
  private readonly demandValues: string[] = ['1', '2']; // 对应字典值
  private readonly mealTypeOptions: string[] = ['其他', '营养餐'];
  private readonly mealTypeValues: string[] = ['2', '1']; // 对应字典值
  private readonly mealOptions: string[] = ['其他', '早餐', '午餐', '晚餐'];
  private readonly mealValues: string[] = ['0', '1', '2', '3']; // 对应字典值
  @State private showMealType: boolean = false; // 控制是否显示用餐类型

  build() {
    Stack() {
      Column() {
        Row() {
          Text('<')
            .alignSelf(ItemAlign.Start)
            .fontSize(20)
            .margin({ top: 0, bottom: 10, right: 125 })
            .onClick(() => {
              router.back();
            });

          Text('新建出库单')
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Center)
            .margin({ top: 0, bottom: 10 });
        }
        .width('100%');
        Column() {
          Column({ space: 10 }) {
            this.buildLabelRow($r("app.media.iunitName"), "领用单位", true, 0);
            this.buildLabelRow($r("app.media.isupplyDate"), "出库日期", true, 1);
            this.buildLabelRow($r("app.media.idemand"), "出库类型", true, 3);

            // 条件用餐类型行
            if (this.showMealType) {
              this.buildLabelRow($r("app.media.requirementType"), "用餐类型", true, 4);
            }

            this.buildLabelRow($r("app.media.imealCategory"), "餐别", true, 5);
            this.buildLabelRow($r("app.media.iremarks"), "摘要", false, 6);
          }
          .width('100%')
          .padding(10);

          // 添加食材按钮
          Row() {
            Button({ type: ButtonType.Normal }) {
              Text('+添加食材')
                .fontSize(16)
                .fontColor(Color.White)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .borderRadius(8)
                .onClick(() => {
                  if (this.selectedText[3] === '请选择') {
                    promptAction.showToast({
                      message: '请选择出库类型',
                      duration: 2000
                    });
                  } else {
                    router.pushUrl({
                      url: 'pages/jiacaidan'
                    });
                  }
                });
            }
            .width('80%')
            .height(35)
            .backgroundColor('#02BC65')
            .fontColor(Color.White)
            .borderRadius(8)
            .width('auto')
            .padding({ left: 15, right: 15 });

            Text(`已选中${this.selectedFoods.length}种食材`)
              .fontColor('#8A96A2')
              .position({ x: 137, y: 15 });
          }

          Column()//渐变框
            .linearGradient({
              angle: 180,
              colors: [['#93D0B1', 0.1], ['#FDFDFD', 1]],
            })
            .margin({ top: 10 })
            .width('100%')
            .height(20);
        }
        .layoutWeight(1);

        if (this.showDialog) {
          // 半透明背景层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#80000000')
            .position({ x: 0, y: 0 })
            .opacity(this.opacityValue)
            .onClick(() => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut
              }, () => {
                this.opacityValue = 0;
                this.scaleValue = 0.8;
              });
              setTimeout(() => {
                this.showDialog = false;
              }, 300);
            })
            .zIndex(2);

          // 对话框内容
          Column() {
            Text('摘要')
              .fontSize(18)
              .margin({ bottom: 16 });

            TextArea({ text: this.summary, placeholder: '输入摘要' })
              .onChange((value: string) => {
                this.summary = value;
                this.selectedText[6] = value || '请输入摘要';
              })
              .height(150)
              .width('100%')
              .border({
                width: 2,
                color: '#4CAF50',
                radius: 8,
              });

            Row({ space: 100 }) {
              Button('取消', { type: ButtonType.Normal })
                .onClick(() => { this.showDialog = false; })
                .backgroundColor('#ffffffff')
                .fontColor('#ff706f6f');
              Button('确定', { type: ButtonType.Normal })
                .backgroundColor('#ffffffff')
                .fontColor('#5BC043')
                .onClick(() => { this.showDialog = false; });
            }
          }
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .width('80%')
          .position({ x: '11%', y: '30%' })
          .opacity(this.opacityValue)
          .scale({ x: this.scaleValue, y: this.scaleValue })
          .animation({
            duration: 300,
            curve: Curve.EaseOut
          })
          .zIndex(2);
        }

        // 加载状态
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .color('#02BC65')
              .width(50)
              .height(50)
            Text('提交中...')
              .fontSize(16)
              .margin({ top: 10 })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('#80000000')
          .justifyContent(FlexAlign.Center)
          .zIndex(3);
        }

        // 底部按钮部分
        Column() {
          Row() {
            Text(`总计：${this.totalPrice.toFixed(2)}元`)
              .fontColor('#8A96A2')
              .fontSize(16)
              .margin({ right: 10 })
              .textAlign(TextAlign.End);
          }
          Row() {
            Button({ type: ButtonType.Normal }) {
              Text('保存')
                .textAlign(TextAlign.Center)
                .fontSize(16)
                .fontColor(Color.White)
                .width('40%')
                .onClick(() => {
                  this.saveOrAuditOrder(0); // 0表示保存
                });
            }
            .height(35)
            .backgroundColor('#02BC65')
            .fontColor(Color.White)
            .borderRadius(8)
            .width('auto')
            .padding({ left: 15, right: 15 })
            .enabled(!this.isLoading);

            Button({ type: ButtonType.Normal }) {
              Text('保存并审核')
                .textAlign(TextAlign.Center)
                .fontSize(16)
                .fontColor(Color.White)
                .width('40%')
                .onClick(() => {
                  this.saveOrAuditOrder(1); // 1表示保存并审核
                });
            }
            .height(35)
            .backgroundColor('#02BC65')
            .fontColor(Color.White)
            .borderRadius(8)
            .width('auto')
            .padding({ left: 15, right: 15 })
            .enabled(!this.isLoading);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: 20 });
        }
        .padding(10)
        .zIndex(1);
      }
    }
  }

  @Builder
  buildLabelRow(iconResource: Resource, label: string, showAsterisk: boolean, index: number) {
    Column() {
      Row() {
        // 左侧图标和标签
        Row() {
          Image(iconResource)
            .width(30)
            .height(30)
            .objectFit(ImageFit.Contain)
            .margin({ right: 10 });

          Text(label)
            .fontSize(16)
            .fontWeight(FontWeight.Bold);

          if (showAsterisk) {
            Text("*")
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Red)
              .margin({ left: 4 });
          }
        }
        .layoutWeight(1);

        // 右侧选择区域
        Row() {
          Text(this.selectedText[index])
            .fontSize(14)
            .fontColor('#000000')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('210px');
        }
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          switch (label) {
            case "领用单位":
              this.showTextDialog(this.unitOptions, this.unitValues, 0);
              break;
            case "出库日期":
              this.showDateDialog();
              break;
            case "出库类型":
              this.showTextDialog(this.demandOptions, this.demandValues, 3);
              break;
            case "用餐类型":
              this.showTextDialog(this.mealTypeOptions, this.mealTypeValues, 4);
              break;
            case "餐别":
              this.showTextDialog(this.mealOptions, this.mealValues, 5);
              break;
            case "摘要":
              this.showDialog = true;
              this.opacityValue = 1;
              this.scaleValue = 1;
              break;
          }
        });
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .height(40)
      .padding({ right: 10 });

      // 添加横线
      Divider()
        .strokeWidth(1)
        .color('#ffb1afaf')
        .margin({ top: 0, bottom: 7 });
    }
    .width('100%');
  }

  private showDateDialog(): void {
    DatePickerDialog.show({
      start: new Date('2000-1-1'),
      end: new Date('2100-1-1'),
      selected: new Date(this.selectedText[1]), // 使用字符串构造 Date
      onAccept: (value: DatePickerResult) => {
        const year = value.year?? new Date().getFullYear();
        const month = value.month?? new Date().getMonth(); // 1-based
        const day = value.day?? new Date().getDate();

        // 构造 Date 对象并保存文本格式
        this.selectDate = new Date(year, month, day); // 转换为 0-based
        this.selectedText[1] = `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;

        // 打印调试信息
        console.log("构造的 Date 对象:", this.selectDate);
        console.log("显示的文本:", this.selectedText[1]);
      }
    });
  }

  private showTextDialog(options: string[], values: string[], index: number): void {
    TextPickerDialog.show({
      range: options,
      selected: options.findIndex(item => item === this.selectedText[index]),
      canLoop: false,
      onAccept: (value: TextPickerResult) => {
        if (typeof value.index === 'number' && value.index < options.length) {
          this.selectedText[index] = options[value.index];
          this.selectedValues[index] = values[value.index];
        }
        switch (index) {
          case 3:
            if (this.selectedValues[index] === '1') // 学生餐
              this.showMealType = true;
            else {
              this.showMealType = false;
              this.selectedText[4] = '请选择';
              this.selectedValues[4] = '';
            }
            break;
          case 4:
            this.showMealType = true;
            break;
          default:
            if (!this.showMealType) {
              this.showMealType = false;
              this.selectedText[4] = '请选择';
              this.selectedValues[4] = '';
            }
            break;
        }
      }
    });
  }

  // 保存或审核出库单
  private saveOrAuditOrder(stockStatus: number): void {
    // 检查必填字段
    let requiredFields = [
      this.selectedText[0], // 领用单位
      this.selectedText[1], // 出库日期
      this.selectedText[3], // 出库类型
      this.selectedText[5]  // 餐别
    ];

    if (requiredFields.includes('请选择')) {
      promptAction.showToast({
        message: '请选择全部内容后重试',
        duration: 2000
      });
      return;
    }

    // 准备请求数据
    const requestData: OutboundRequest = {
      accountingDate: this.selectedText[1],
      demandUnit: this.selectedValues[0], // 领用单位ID
      demandUnitName: this.selectedText[0], // 领用单位名称
      digest: this.summary,
      mealType: this.selectedValues[3], // 出库类型
      requirementType: this.selectedValues[4] || '', // 用餐类型
      mealCategory: this.selectedValues[5], // 餐别
      stockStatus: stockStatus.toString(),
      foods: this.selectedFoods.map<FoodRequestItem>((food: FoodItem) => ({
        foodId: food.id,
        foodName: food.name,
        encoding: food.code,
        groupId: food.categoryId,
        groupName: food.categoryName,
        unit: food.unit,
        specification: food.specType === 1 ? '称重' : '计件',
        supplyPricing: food.price,
        totalNum: food.quantity,
        supplyWay: "1",
        batch: food.batchNumber || '',
        requirementType: this.selectedValues[4] || '',
        mealType: this.selectedValues[3],
        mealCategory: this.selectedValues[5],
        accountingDate: this.selectedText[1],
        requirementType_dictText: this.selectedText[4] || '',
        mealType_dictText: this.selectedText[3],
        mealCategory_dictText: this.selectedText[5],
        num: food.quantity.toString(),
        selectId: food.selectId || '',
        marketWeight: food.weight || 0
      }))
    };

    // 设置加载状态
    this.isLoading = true;

    // 发送HTTP请求
    let httpRequest = http.createHttp();
    httpRequest.request(
      "https://api.suoeryun.com/ifood//school/xxSupplyOutManagement/add",
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestData),
        readTimeout: 30000, // 设置超时时间为30秒
        connectTimeout: 30000
      },
      (err: Error, data: http.HttpResponse) => {
        // 无论请求结果如何，都关闭加载状态
        this.isLoading = false;

        if (err) {
          promptAction.showToast({
            message: '请求失败: ' + JSON.stringify(err),
            duration: 3000
          });
          return;
        }

        if (data.responseCode === 200) {
          try {
            const response: ApiResponse = JSON.parse(data.result.toString());
            if (response.success) {
              promptAction.showToast({
                message: stockStatus === 0 ? '保存成功' : '保存并审核成功',
                duration: 2000
              });

              // 延迟返回，确保用户能看到提示
              setTimeout(() => {
                router.back();
              }, 2000);
            } else {
              promptAction.showToast({
                message: '操作失败: ' + response.message,
                duration: 3000
              });
            }
          } catch (e) {
            promptAction.showToast({
              message: '解析响应失败',
              duration: 3000
            });
          }
        } else {
          promptAction.showToast({
            message: '请求错误: ' + data.responseCode,
            duration: 3000
          });
        }

        // 释放HTTP请求资源
        httpRequest.destroy();
      }
    );
  }

  onPageShow(): void {
    // 从路由获取选中的食材数据
    const params: RouterParams = router.getParams() as RouterParams;
    if (params && params.selectedFoods) {
      this.selectedFoods = params.selectedFoods;
      this.calculateTotalPrice();
    }
  }

  private calculateTotalPrice(): void {
    this.totalPrice = this.selectedFoods.reduce((sum: number, food: FoodItem) => {
      return sum + (food.price * food.quantity);
    }, 0);
  }
}