import router from '@system.router';

const demandUnitName=AppStorage.get<string>('demandUnitName')

@Entry
@Component
struct kucunxiangqing1 {
  @State foodName: string = '';
  @State totalNum: string = '';
  @State documentNo: string = '';
  @State createTime: string = '';
  @State operateAmount: string = '';
  @State operator: string = '';
  @State supplierName: string = '';

  aboutToAppear() {
    // 获取参数
    let params = router.getParams() as Record<string, string>;
    this.foodName = params.productName || '未知商品';
    this.totalNum = params.stockAmount || '0';
    this.documentNo = params.orderNo || '无单据号';
    this.createTime = params.operateTime || '未知时间';
    this.operateAmount = params.operateAmount || '0';
    this.operator = params.operator || '未知操作人';
    this.supplierName = params.supplier || '未知供应商';
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Text('<')
          .fontSize(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          });
        Column() {
          Text('实时库存详情')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 2 });
        }
        .margin({ left: 16 })

        Blank()
      }
      .width('100%')
      .height(48)
      .alignItems(VerticalAlign.Center)
      .margin({
        top: 8,
        bottom: 8,
        left: 8,
        right: 8
      })

      // 商品信息卡片（保持不变）
      Column() {
        Row() {
          Text('商品信息')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
            .margin({ left: 16, top: 8, bottom: 8 });
        }
        .width('100%')
        .backgroundColor('#3ec97c')
        .borderRadius({ topLeft: 16, topRight: 16 });

        Column() {
          Text(this.foodName)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 12, left: 16, bottom: 8 });
          Text('库存量：' + this.totalNum)
            .fontSize(16)
            .margin({ left: 16, bottom: 16 });
        }
        .width('100%')
        .backgroundColor('#fff')
        .borderRadius({ bottomLeft: 16, bottomRight: 16 });
      }
      .width('92%')
      .margin({ left: '4%', right: '4%', bottom: 16 })

      Column() {
        Row() {
          Text('●')
            .fontSize(18)
            .fontColor('#3ec97c')
            .margin({ right: 4 })
            .alignSelf(ItemAlign.Start)
            .textAlign(TextAlign.Start);
          Text('单据号：' + this.documentNo)
            .alignSelf(ItemAlign.Start)
            .textAlign(TextAlign.Start)
            .fontSize(16)
            .fontColor('#3ec97c');
        }
        .margin({ left: 16, bottom: 12 });

        // 操作信息卡片（新增字段）
        Column() {
          Row() {
            Text('操作时间：' + this.createTime)
              .fontSize(15)
              .margin({ bottom: 4 });
          }

          Text('操作数量：' + this.totalNum)
            .fontSize(15)
            .margin({ bottom: 4 });
          Text('操作人：' + this.operator)
            .fontSize(15)
            .margin({ bottom: 4 });
          Text('采购入库,从【' + this.supplierName + '】处采购入库')
            .width('100%')
            .backgroundColor('#3ec97c')
            .fontColor('#fff')
            .fontSize(16)
            .margin({ top: 8, bottom: 8 });
        }
        .width('92%')
        .margin({ left: '4%', right: '4%', top: 0 })
        .backgroundColor('#fff')
        .borderRadius(12)
        .shadow({
          radius: 8,
          color: '#3ec97c22',
          offsetX: 0,
          offsetY: 4
        })
        .padding(12);
      }

      Column() {
        Row() {
          Text('●')
            .fontSize(18)
            .fontColor('#3ec97c')
            .margin({ right: 4 })
            .alignSelf(ItemAlign.Start)
            .textAlign(TextAlign.Start);
          Text('单据号：' + this.documentNo)
            .alignSelf(ItemAlign.Start)
            .textAlign(TextAlign.Start)
            .fontSize(16)
            .fontColor('#3ec97c');
        }
        .margin({ left: 16, bottom: 12 });

        // 操作信息卡片（新增字段）
        Column() {
          Row() {
            Text('操作时间：' + this.createTime)
              .fontSize(15)
              .margin({ bottom: 4 });
          }

          Text('操作数量：' + this.totalNum)
            .fontSize(15)
            .margin({ bottom: 4 });
          Text('操作人：' + this.operator)
            .fontSize(15)
            .margin({ bottom: 4 });
          Text(`供应出库,给【实训第一学校餐厅】供应出库`)
            .width('100%')
            .backgroundColor('#3ec97c')
            .fontColor('#fff')
            .fontSize(16)
            .margin({ top: 8, bottom: 8 });
        }
        .width('92%')
        .margin({ left: '4%', right: '4%', top: 0 })
        .backgroundColor('#fff')
        .borderRadius(12)
        .shadow({
          radius: 8,
          color: '#3ec97c22',
          offsetX: 0,
          offsetY: 4
        })
        .padding(12);
      }
    }
  }
}