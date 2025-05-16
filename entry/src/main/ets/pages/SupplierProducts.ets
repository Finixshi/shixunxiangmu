import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import data_preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

// 定义产品接口
interface Product {
  name: string;
  brand: string;
  category: string;
  specification: string;
  price: number;
  unit: string;
  id?: string; // 添加可选ID字段，用于区分重复商品
}

// 定义路由参数接口
interface RouterParams {
  selectedProducts?: Product[];
}

@Entry
@Component
struct SupplierProducts {
  @State searchText: string = '';
  @State products: Product[] = [
    {
      name: '瘦肉',
      brand: '古徽',
      category: '畜禽肉类',
      specification: '',
      price: 35.6,
      unit: 'Kg',
      id: '1'
    },
    {
      name: '鲜精排',
      brand: '古徽',
      category: '畜禽肉类',
      specification: '',
      price: 43.6,
      unit: 'Kg',
      id: '2'
    },
    {
      name: '小肉',
      brand: '爱德华',
      category: '畜禽肉类',
      specification: '称重',
      price: 15,
      unit: 'Kg',
      id: '3'
    },
    {
      name: '大肉',
      brand: '古徽',
      category: '畜禽肉类',
      specification: '',
      price: 38.5,
      unit: 'Kg',
      id: '4'
    }
  ];
  private prefName: string = 'supplierProducts';
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    // 页面创建时就尝试加载本地数据
    this.loadLocalData();
    
    // 延迟处理路由参数，确保在UI渲染后处理
    setTimeout(() => {
      this.processRouteParams();
    }, 100);
  }

  onPageShow() {
    // 页面显示时处理路由参数
    // 延迟处理以确保路由参数已完全就绪
    setTimeout(() => {
      this.processRouteParams();
      console.info('onPageShow - 处理路由参数');
    }, 200);
  }

  // 保存数据到本地
  async saveLocalData() {
    try {
      // 创建首选项存储实例
      const preferences = await data_preferences.getPreferences(this.context, this.prefName);
      // 将产品数组转换为JSON字符串并保存
      await preferences.put('products', JSON.stringify(this.products));
      // 持久化保存
      await preferences.flush();
      console.info('数据保存成功');
    } catch (error) {
      console.error('保存数据失败:', error);
      promptAction.showToast({
        message: '保存数据失败',
        duration: 2000,
      });
    }
  }

  // 从本地加载数据
  async loadLocalData() {
    try {
      // 创建首选项存储实例
      const preferences = await data_preferences.getPreferences(this.context, this.prefName);
      // 获取保存的JSON字符串
      const value = await preferences.get('products', '') as string;
      if (value && typeof value === 'string') {
        // 解析JSON字符串为产品数组
        const loadedProducts = JSON.parse(value) as Product[];
        if (Array.isArray(loadedProducts) && loadedProducts.length > 0) {
          this.products = loadedProducts;
          console.info('成功加载本地数据:', loadedProducts.length);
        }
      }
    } catch (error) {
      console.error('加载本地数据失败:', error);
    }
  }

  processRouteParams() {
    try {
      // 修改从AppStorage获取数据的方式为使用路由参数
      // 尝试从路由参数获取数据
      const params = router.getParams() as Record<string, Object>;
      console.info('接收到的路由参数:', JSON.stringify(params));
      
      if (params && params.selectedProducts && Array.isArray(params.selectedProducts) && params.selectedProducts.length > 0) {
        const routerProducts = params.selectedProducts as Product[];
        console.info('从路由参数获取选中商品:', routerProducts.length);
        
        // 直接添加新商品，允许重复
        for (const newProduct of routerProducts) {
          // 为每个新商品生成唯一ID
          newProduct.id = Date.now().toString() + Math.floor(Math.random() * 1000).toString();
          // 添加新商品
          this.products.push(newProduct);
          // 显示添加成功提示
          promptAction.showToast({
            message: `已添加: ${newProduct.name}`,
            duration: 1000,
          });
        }
        
        // 保存到本地存储
        this.saveLocalData();
        
        // 打印日志查看接收到的商品
        console.info('接收到的商品:', JSON.stringify(routerProducts));
        console.info('更新后的商品列表:', JSON.stringify(this.products));
      } else {
        console.info('没有接收到有效的商品数据');
      }
    } catch (error) {
      console.error('处理路由参数时出错:', error);
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
        
        Text('供应商品')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor('#FFFFFF')
        
        // 使用三个点代替more图标
        Text('...')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(56)
      .backgroundColor('#000000')
      .padding({ right: 16 })

      // 搜索框和类别筛选
      Row() {
        Row() {
          Text('全部类别')
            .fontSize(16)
            .fontColor('#000000')
          
          Image($r('app.media.arrow_down'))
            .width(20)
            .height(20)
            .margin({ left: 8 })
        }
        .width('30%')
        .height(40)
        .padding({ left: 10 })
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        
        Search({ value: this.searchText, placeholder: '搜索商品名称' })
          .width('70%')
          .height(40)
          .backgroundColor('#FFFFFF')
          .placeholderColor('#999999')
          .placeholderFont({ size: 14 })
          .textFont({ size: 14 })
          .onChange((value: string) => {
            this.searchText = value;
          })
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#FFFFFF')

      // 商品列表
      Scroll() {
        Column() {
          ForEach(this.products, (item: Product, index: number) => {
            Column() {
              Stack({ alignContent: Alignment.TopStart }) {
                Column() {
                  // 商品信息行
                  Row() {
                    Text(item.name)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#000000')
                      .layoutWeight(1)
                    
                    Image($r('app.media.delete'))
                      .width(26)
                      .height(26)
                      .onClick(() => {
                        // 删除商品
                        this.products.splice(index, 1);
                        // 更新本地存储
                        this.saveLocalData();
                        // 显示删除成功提示
                        promptAction.showToast({
                          message: `已删除: ${item.name}`,
                          duration: 1000,
                        });
                      })
                  }
                  .width('100%')
                  .padding({ top: 10, bottom: 10 })
                  
                  // 分隔线
                  Divider()
                    .strokeWidth(1)
                    .color('#EEEEEE')
                    .margin({ top: 5, bottom: 5 })
                  
                  // 商品详细信息
                  Row() {
                    Text('品牌：')
                      .fontSize(14)
                      .fontColor('#333333')
                    
                    Text(item.brand)
                      .fontSize(14)
                      .fontColor('#333333')
                      .layoutWeight(1)
                    
                    Text('类别：')
                      .fontSize(14)
                      .fontColor('#333333')
                    
                    Text(item.category)
                      .fontSize(14)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .margin({ top: 5, bottom: 5 })
                  
                  Row() {
                    Text('规格：')
                      .fontSize(14)
                      .fontColor('#333333')
                    
                    Text(item.specification || '')
                      .fontSize(14)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .margin({ top: 5, bottom: 5 })
                  
                  Row() {
                    Column() {
                      Row() {
                        Text('供应价：')
                          .fontSize(14)
                          .fontColor('#333333')
                        
                        Text(`${item.price}`)
                          .fontSize(18)
                          .fontColor('#FF6B6B')
                        
                        Text(`元/${item.unit}`)
                          .fontSize(14)
                          .fontColor('#FF6B6B')
                      }
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    
                    Text('历史价格')
                      .fontSize(14)
                      .fontColor('#10C469')
                  }
                  .width('100%')
                  .margin({ top: 5, bottom: 5 })
                }
                .width('100%')
                .padding(15)
                .borderRadius(10)
                .backgroundColor('#FFFFFF')
                
                // 新鲜标签
                Stack() {
                  Text('新鲜')
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                    .padding(5)
                    .rotate({ x: 0, y: 0, z: 1, angle: -45 })
                }
                .width(60)
                .height(60)
                .position({ x: -30, y: -30 })
                .backgroundColor('#FF9F43')
                .borderRadius(60)
              }
            }
            .width('100%')
            .margin({ top: 10 })
          })
        }
        .width('100%')
        .padding({ left: 10, right: 10, bottom: 80 })
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .backgroundColor('#F5F5F5')
      
      // 底部添加按钮
      Button('添加商品')
        .width('90%')
        .height(50)
        .backgroundColor('#10C469')
        .borderRadius(4)
        .fontSize(18)
        .fontColor('#FFFFFF')
        .position({ x: '5%', y: '85%' })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/ProductList'
          });
        })
      
      // 返回顶部按钮
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.zuo'))
          .width(24)
          .height(24)
          .rotate({ z: 1, angle: 90 })
      }
      .width(60)
      .height(60)
      .backgroundColor('#CCCCCC')
      .opacity(0.8)
      .position({ x: '85%', y: '75%' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 