import router from '@ohos.router';

@Entry
@Component
struct PurchaseInventory {
  @State activeTab: number = 0; // 跟踪当前选项卡索引
  private options: SelectOption[] = [
    { value: '全部分类' },
    { value: '谷薯类' },
    { value: '蔬菜水果类' },
    { value: '鱼禽肉蛋类' },
    { value: '牛奶类' },
    { value: '大豆坚果类' },
    { value: '干菜调料类' },
    { value: '糕点面包类' },
    { value: '主食半成品类' },
    { value: '其他类' }
  ]
  @State selectedValue: string = '全部分类'; // 当前选中分类
  @State currentTabContent: string = '未配送';
  @State selectedItemCount: number = 0; // 已选食材数
  @State isSelected1: boolean = false; // 跟踪第一张卡片是否选中
  @State isSelected2: boolean = false; // 跟踪第二张卡片是否选中


  build() {
    Column() {
      // 返回按钮和标题行
      Row() {
        Text('<')
          .alignSelf(ItemAlign.Start)
          .fontSize(20)
          .margin({ top: 0, bottom: 10, right: 130 })
          .onClick(() => {
            router.back()
          });

        Text('选择食材')
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Center)
          .margin({ top: 0, bottom: 10 });
      }
      .width('100%')

      // 分类下拉与搜索框
      Row() {
        Select(this.options)
          .selected(0)
          .value(this.selectedValue)
          .onSelect((index: number, value: string) => {
            this.selectedValue = value;
            this.navigateToCategory(value);
          })
          .alignSelf(ItemAlign.Start)
          .width("35%")
          .fontColor('#333')
          .backgroundColor('#FFF')
          .borderRadius(8)
          .border({ width: 0, color: '#DDD' });

        TextInput({ placeholder: '搜索商品名称' })
          .width('65%')
          .height(40)
          .borderRadius(20)
          .padding({ left: 10, right: 10 })
          .fontColor('#666')
          .backgroundColor('#F5F5F5')
          .type(InputType.Normal)
          .onChange((text: string) => {
            console.log(`Search text: ${text}`);
          });
      }
      .width('100%')
      .margin({ bottom: 20 });

      // 分类内容区域
      if (this.selectedValue === '全部分类') {
        this.renderAllCategories();
      } else {
        this.renderCategoryByValue(this.selectedValue);
      }

      // 底部信息栏
      // 底部信息栏
      Column() {
        Row() {
          Text(`已选中${this.selectedItemCount}种食材`)
            .fontSize(14)
            .fontColor('#666')
            .alignSelf(ItemAlign.Center)
            .margin({ left: 20 });

          Button('确定')
            .type(ButtonType.Capsule)
            .onClick(() => {
              router.pushUrl({ url: 'pages/chukudan' });
            })
            .margin({ right: 20 });
        }
        .width('100%')
        .height('10%')
        .backgroundColor(Color.White)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White);

    }
  }

  // 渲染“全部分类”内容（修改后）
  @Builder
  renderAllCategories() {
    Scroll() {
      Column() {
        Text('~这是全部分类的内容~')
          .fontSize(16)
          .fontWeight(FontWeight.Normal)
          .alignSelf(ItemAlign.Center)
          .margin({ top: 20, bottom: 20 });

        // 添加商品卡片到此 Column 中
        this.renderProductCard();
      }
      .backgroundColor('#EEEEEE')
      .width('100%')
      .height('80%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    }
  }

  // 根据分类名动态渲染不同内容
  @Builder
  renderCategoryByValue(category: string) {
    if (category === '谷薯类') {
      this.renderCategoryContent('谷薯类');
    } else if (category === '蔬菜水果类') {
      this.renderCategoryContent('蔬菜水果类');
    } else if (category === '鱼禽肉蛋类') {
      this.renderCategoryContent('鱼禽肉蛋类');
    } else if (category === '牛奶类') {
      this.renderCategoryContent('牛奶类');
    } else if (category === '大豆坚果类') {
      this.renderCategoryContent('大豆坚果类');
    } else if (category === '干菜调料类') {
      this.renderCategoryContent('干菜调料类');
    } else if (category === '糕点面包类') {
      this.renderCategoryContent('糕点面包类');
    } else if (category === '主食半成品类') {
      this.renderCategoryContent('主食半成品类');
    } else if (category === '其他类') {
      this.renderCategoryContent('其他类');
    } else {
      Column() {
        Text('~暂无相关内容~')
          .fontSize(16)
          .fontWeight(FontWeight.Normal)
          .alignSelf(ItemAlign.Center)
          .height('80%')
          .width('100%')
      }
      .width('100%')
      .height('10s0%');
    }
  }

  // 单个分类通用模板
  @Builder
  renderCategoryContent(category: string) {
    Scroll() {
      Column() {
        Text(`这里是【${category}】的具体内容`)
          .fontSize(16)
          .fontWeight(FontWeight.Normal)
          .alignSelf(ItemAlign.Start) // 修改为左对齐
          .margin({ top: 20, bottom: 20 });
      }
      .backgroundColor('#F8F8F8')
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    };
  }

  // 分类导航逻辑
  navigateToCategory(category: string) {
    console.log(`Navigating to category: ${category}`);
  }

  // 自定义商品卡片组件（替换原 Card）
  // 自定义商品卡片组件，并添加点击事件
  // 自定义商品卡片组件，并添加点击事件
  @Builder
  renderProductCard() {


    Column() {
      // 第一张卡片
      Row() {
        Image($r('app.media.food_default'))
          .width('30%')
          .height(100)
          .objectFit(ImageFit.Contain);

        Column() {
          Text('圆白菜')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('生产日期：2025-05-09')
            .fontSize(16)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('供应价：1.56元/Kg')
            .fontSize(16)
            .fontColor(Color.Red)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('库存量：2斤(1Kg)')
            .fontSize(16)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('保质期：3天')
            .fontSize(16)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('餐别：其他')
            .fontSize(16)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('未过期')
            .fontSize(16)
            .fontColor(Color.Green)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });
        }
        .width('70%')
        .padding({ left: 10 });
      }
      .width('100%')
      .padding({ left: 10, right: 10 })
      .border({
        width: { top: 2, bottom: 2, left: 2, right: 2 },
        color: this.isSelected1 ? '#007AFF' : '#FFA500', // 选中时变为蓝色
        radius: 10
      })
      .onClick(() => {
        if (this.isSelected1) {
          this.selectedItemCount -= 1;
        } else {
          this.selectedItemCount += 1;
        }
        this.isSelected1 = !this.isSelected1;
      })

      // 第二张卡片
      Row() {
        Image($r('app.media.food_default'))
          .width('30%')
          .height(100)
          .objectFit(ImageFit.Contain);

        Column() {
          Text('圆白菜')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('生产日期：2025-05-06')
            .fontSize(16)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('供应价：1.56元/Kg')
            .fontSize(16)
            .fontColor(Color.Red)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('库存量：2斤(1Kg)')
            .fontSize(16)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('保质期：3天')
            .fontSize(16)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('餐别：其他')
            .fontSize(16)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });

          Text('已过期')
            .fontSize(16)
            .fontColor(Color.Red)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 10 });
        }
        .width('70%')
        .padding({ left: 10 });
      }
      .width('100%')
      .padding({ left: 10, right: 10 })
      .border({
        width: { top: 2, bottom: 2, left: 2, right: 2 },
        color: this.isSelected2 ? '#007AFF' : '#FFA500',
        radius: 10
      })
      .onClick(() => {
        if (this.isSelected2) {
          this.selectedItemCount -= 1;
        } else {
          this.selectedItemCount += 1;
        }
        this.isSelected2 = !this.isSelected2;
      })

    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .margin({ top: 20, bottom: 20, left: 10, right: 10 });
  }
}

