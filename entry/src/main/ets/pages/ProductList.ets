import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

// 定义产品项接口
interface ProductItem {
  id: string;
  name: string;
  category: string;
  price: number;
  unit: string;
  isSelected: boolean;
}

// 定义要返回的产品接口
interface ReturnProduct {
  name: string;
  brand: string;
  category: string;
  specification: string;
  price: number;
  unit: string;
}

@Entry
@Component
struct ProductList {
  @State productList: ProductItem[] = [];
  @State searchText: string = '';
  
  aboutToAppear() {
    // 模拟数据
    const categories = ['蔬菜', '肉类', '水产', '调料', '干货', '豆制品'];
    const names = ['黄瓜', '西红柿', '土豆', '青椒', '豆角', '白菜', '韭菜', 
                  '猪肉', '牛肉', '羊肉', '鸡肉', '鸭肉', 
                  '带鱼', '草鱼', '鲫鱼', '虾仁', 
                  '盐', '糖', '醋', '酱油', '花椒', '八角',
                  '木耳', '香菇', '粉条', '粉丝',
                  '豆腐', '豆皮', '腐竹'];
    
    for (let i = 0; i < 50; i++) {
      const nameIndex = i % names.length;
      const catIndex = Math.floor(nameIndex / 5);
      this.productList.push({
        id: `${i}`,
        name: names[nameIndex],
        category: categories[catIndex % categories.length],
        price: Math.round(Math.random() * 40 + 5),
        unit: 'Kg',
        isSelected: false
      } as ProductItem);
    }
  }

  toggleSelectItem(index: number) {
    // 创建新数组以确保状态更新触发UI刷新
    let newList = [...this.productList];
    newList[index].isSelected = !newList[index].isSelected;
    this.productList = newList;
    
    // 添加提示反馈
    promptAction.showToast({
      message: newList[index].isSelected ? '已选择' + newList[index].name : '已取消选择' + newList[index].name,
      duration: 1000,
    });
  }
  
  confirmAndBack() {
    // 获取选中的商品
    const selectedItems = this.productList.filter(item => item.isSelected);
    
    if (selectedItems.length === 0) {
      promptAction.showToast({
        message: '请至少选择一个商品',
        duration: 2000,
      });
      return;
    }
    
    // 将选中的商品转换为ReturnProduct格式
    const returnProducts: ReturnProduct[] = selectedItems.map(item => {
      const product: ReturnProduct = {
        name: item.name,
        brand: '默认品牌',
        category: item.category,
        specification: '',
        price: item.price,
        unit: item.unit
      };
      return product;
    });
    
    // 打印所选商品，用于调试
    console.info('选中的商品:', JSON.stringify(returnProducts));
    
    // 使用replaceUrl替代back来确保数据传递
    try {
      router.replaceUrl({
        url: 'pages/SupplierProducts',
        params: {
          selectedProducts: returnProducts
        }
      });
    } catch (error) {
      console.error('路由传参失败:', error);
      promptAction.showToast({
        message: '返回失败，请重试',
        duration: 2000
      });
    }
  }
  
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.zuo'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })
        
        Text('商品列表')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor('#FFFFFF')
        
        Text('确定')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .margin({ right: 16 })
          .onClick(() => {
            this.confirmAndBack();
          })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#000000')
      .padding({ right: 16 })
      
      // 商品列表
      List() {
        ForEach(this.productList, (item: ProductItem, index: number) => {
          ListItem() {
            Row() {
              // 左侧信息区域
              Row() {
                // 食材图标（使用固定图标）
                Image($r('app.media.food_default'))
                  .width(30)
                  .height(30)
                  .margin({ right: 10 })
                
                // 商品名称
                Text(item.name)
                  .fontSize(16)
                  .fontColor('#000000')
              }
              .layoutWeight(1)
              .alignItems(VerticalAlign.Center)
              
              // 右侧勾选区域
              if (item.isSelected) {
                Text('已选')
                  .fontSize(14)
                  .fontColor('#10C469')
                  .padding(5)
                  .backgroundColor('#E8F7F0')
                  .borderRadius(5)
              } else {
                Text('选择')
                  .fontSize(14)
                  .fontColor('#666666')
                  .padding(5)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(5)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding(15)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .onClick(() => {
              this.toggleSelectItem(index);
            })
          }
          .margin({ top: 5, left: 10, right: 10 })
          .borderRadius(8)
        })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .margin({ bottom: 10 })
      
      // 底部添加按钮
      Row() {
        Button('添 加')
          .width('90%')
          .height(50)
          .backgroundColor('#10C469')
          .borderRadius(4)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.confirmAndBack();
          })
      }
      .width('100%')
      .height(70)
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: 10 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 