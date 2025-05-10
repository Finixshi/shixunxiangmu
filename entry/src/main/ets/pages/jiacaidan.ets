import router from '@ohos.router';

@Entry
@Component
struct PurchaseInventory {
  @State activeTab: number = 0; // 用于跟踪当前激活的选项卡索引
  private options: SelectOption[] = [
    { value: '全部分类' },
    { value: '谷薯类' },
    { value: '蔬菜水果类' },
    { value: '鱼禽肉蛋类' },
    { value: '牛奶类'},
    { value: '大豆坚果类'},
    { value: '干菜调料类'},
    { value: '糕点面包类'},
    { value: '主食半成品类'},
    { value: '其他类'}
  ]
  @State selectedValue: string = '全部分类'; // 存储选中值
  @State currentTabContent: string = '未配送'; // 默认显示“未配送”内容
  @State selectedItemCount: number = 0; // 已选中食材数量

  build() {
    Column() {
      Row() {
        Text('<')
          .alignSelf(ItemAlign.Start) // 保持在行的最左侧
          .fontSize(20)
          .margin({ top: 0, bottom: 10, right: 130})
          .onClick(() => {
            router.back()
          });

        Text('选择食材')
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Center) // 居中显示
          .margin({ top: 0, bottom: 10 });
      }
      .width('100%') // 确保 Row 占据全部宽度
      // 第二块：选项卡（已移除“待收货”）
      Row() {
        // 全部分类下拉选择框
        Select(this.options)
          .selected(0)
          .value(this.selectedValue)
          .onSelect((index: number, value: string) => {
            this.selectedValue = value;
            this.navigateToCategory(value); // 根据选择的分类导航
          })
          .alignSelf(ItemAlign.Start)
          .width("35%")
          .fontColor('#333')
          .backgroundColor('#FFF')
          .borderRadius(8)
          .border({ width: 0, color: '#DDD' });

        TextInput({ placeholder: '搜索商品名称' })
          .width('65%') // 修正宽度为合理值
          .height(40)
          .borderRadius(20)
          .padding({ left: 10, right: 10 })
          .fontColor('#666')
          .backgroundColor('#F5F5F5')
          .type(InputType.Normal) // 替代 inputMethod
          .onChange((text: string) => {
            console.log(`Search text: ${text}`);
          });
      }
      .width('100%')
      .margin({ bottom: 20 });

      // 第三块：分类内容区域
      if (this.selectedValue === '全部分类') {
        this.renderAllCategories();
      } else {
        this.renderCategoryByValue(this.selectedValue);
      }

      // 第四块：底部信息栏（始终位于页面最底端）
      Row() {
        // 左侧：已选中食材数量
        Text(`已选中${this.selectedItemCount}种食材`)
          .fontSize(14)
          .fontColor('#666')
          .alignSelf(ItemAlign.Center)
          .margin({ left: 20 });

        // 右侧：确定按钮
        Button('确定')
          .type(ButtonType.Capsule)
          .onClick(() => {
            console.log('Confirm button clicked');
          })
          .margin({ right: 20 });
      }
      .width('100%')
      .height(60)
      .backgroundColor(Color.White) // 设置背景色
      .alignItems(VerticalAlign.Center) // 水平居中
      .justifyContent(FlexAlign.SpaceBetween); // 内容两端对齐
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White);
  }

  // 渲染所有分类通用内容
  @Builder
  renderAllCategories() {
    Scroll() {
      Column() {
        Text('~这是全部分类的内容~')
          .fontSize(16)
          .fontWeight(FontWeight.Normal)
          .alignSelf(ItemAlign.Center);
      }
      .backgroundColor('#EEEEEE')
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    }
  }

  // 根据分类名动态渲染不同 Column 内容
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
      Text('~暂无相关内容~')
        .fontSize(16)
        .fontWeight(FontWeight.Normal)
        .alignSelf(ItemAlign.Center);
    }
  }


  // 单个分类内容模板（改为普通方法 + 返回 UI 结构）
  @Builder
  renderCategoryContent(category: string) {
    Scroll() {
      Column() {
        Text(`这里是【${category}】的具体内容`)
          .fontSize(16)
          .fontWeight(FontWeight.Normal)
          .alignSelf(ItemAlign.Center);
      }
      .backgroundColor('#F8F8F8')
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    };
  }

  // 根据选择的分类导航
  navigateToCategory(category: string) {
    console.log(`Navigating to category: ${category}`);
    // 这里可以添加更多导航逻辑
  }
}
