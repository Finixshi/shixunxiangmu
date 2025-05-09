import router from '@ohos.router';

// 定义食谱类型接口
interface RecipeItem {
  date: string;
  name: string;
  type: string;
  mealType: string;
  canteen: string;
}

@Entry
@Component
struct Shipu {
  @State recipeDate: string = '请选择食谱日期 ▼'
  private selectedDate: Date = new Date()
  @State recipeName: string = ''
  @State mealType: string = '请选择餐别'
  @State diningType: string = '请选择用餐类型'
  @State submitUnit: string = '实训第二学校餐厅'
  @State photoCount: number = 0

  private mealTypeOptions: SelectOption[] = [
    { value: '早餐' },
    { value: '午餐' },
    { value: '晚餐' }
  ]
  private diningTypeOptions: SelectOption[] = [
    { value: '堂食' },
    { value: '外卖' }
  ]
  private submitUnitOptions: SelectOption[] = [
    { value: '实训第二学校餐厅' },
    { value: '实训第一学校餐厅' }
  ]

  saveRecipe() {
    // 创建新的食谱对象
    const newRecipe: RecipeItem = {
      date: this.recipeDate,
      name: this.recipeName,
      type: this.mealType,
      mealType: this.diningType,
      canteen: this.submitUnit
    }

    try {
      // 从存储中获取现有列表
      let existingRecipes = AppStorage.Get<string>('recipeList')
      let recipeList: RecipeItem[] = existingRecipes ? JSON.parse(existingRecipes) : []

      // 添加新食谱
      recipeList.push(newRecipe)

      // 保存到存储
      AppStorage.Set<string>('recipeList', JSON.stringify(recipeList))

      // 显示保存成功提示
      AlertDialog.show({
        title: '提示',
        message: '保存成功',
        confirm: {
          value: '确定',
          action: () => {
            // 返回上一页
            router.back()
          }
        }
      })
    } catch (error) {
      console.error('保存失败:', error)
      AlertDialog.show({
        title: '错误',
        message: '保存失败，请重试',
        confirm: {
          value: '确定',
          action: () => {
            console.log('确定')
          }
        }
      })
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#000')
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          })

        Text('新建食谱')
          .fontWeight(FontWeight.Bold)
          .fontSize(22)
          .textAlign(TextAlign.Center)
          .margin({ top: 18, bottom: 8 })
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)

      // 表单内容
      Column() {
        // 食谱日期
        Row() {
          Text('食谱日期')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          Text(this.recipeDate)
            .fontColor('#666')
            .width('50%')
            .textAlign(TextAlign.End)
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-1-1"),
                end: new Date("2100-12-31"),
                selected: this.selectedDate,
                onAccept: (value: DatePickerResult) => {
                  if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                    this.selectedDate.setFullYear(value.year, value.month, value.day);
                    const formattedDate = `${value.year.toString().padStart(4, '0')}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`;
                    this.recipeDate = formattedDate;
                  }
                }
              });
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })

        // 食谱名称
        Row() {
          Text('食谱名称')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          TextInput({ placeholder: '请输入食谱名称', text: this.recipeName })
            .width('50%')
            .fontColor('#BBB')
            .onChange((value: string) => {
              this.recipeName = value
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })

        // 餐别
        Row() {
          Text('餐    别')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          Select(this.mealTypeOptions)
            .selected(0)
            .value(this.mealType)
            .onSelect((index: number, value: string) => {
              this.mealType = value
            })
            .width('50%')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })

        // 用餐类型
        Row() {
          Text('用餐类型')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          Select(this.diningTypeOptions)
            .selected(0)
            .value(this.diningType)
            .onSelect((index: number, value: string) => {
              this.diningType = value
            })
            .width('50%')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })

        // 提交单位
        Row() {
          Text('提交单位')
            .fontSize(16)
            .fontColor('#222')
          Text('*')
            .fontColor('#E53935')
            .margin({ left: 2, right: 8 })
          Blank()
          Select(this.submitUnitOptions)
            .selected(0)
            .value(this.submitUnit)
            .onSelect((index: number, value: string) => {
              this.submitUnit = value
            })
            .width('50%')
            .fontColor('#666')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .border({ width: 0, color: '#EEE' })

        // 上传食谱照片
        Column() {
          Row() {
            Text('上传食谱照片')
              .fontSize(16)
              .fontColor('#222')
            Text('*')
              .fontColor('#E53935')
              .margin({ left: 2, right: 8 })
            Blank()
            Text(this.photoCount + '/20')
              .fontColor('#999')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })

          // 上传按钮
          Row() {
            Text('+')
              .width(60)
              .height(60)
              .fontSize(30)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onClick(() => {
                // 上传图片逻辑
              })
          }
          .width('100%')
          .padding({ left: 16, top: 8 })
        }
        .width('100%')
      }
      .width('100%')
      .flexGrow(1)

      // 底部保存按钮
      Row() {
        Text('保存')
          .width('90%')
          .height(44)
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.Green)
          .fontColor('#FFF')
          .fontWeight(FontWeight.Bold)
          .borderRadius(8)
          .onClick(() => {
            // 表单验证
            if (this.recipeDate === '请选择食谱日期 ▼') {
              AlertDialog.show({
                title: '提示',
                message: '请选择食谱日期',
                confirm: {
                  value: '确定',
                  action: () => {
                    console.log('确定')
                  }
                }
              })
              return
            }
            if (!this.recipeName.trim()) {
              AlertDialog.show({
                title: '提示',
                message: '请输入食谱名称',
                confirm: {
                  value: '确定',
                  action: () => {
                    console.log('确定')
                  }
                }
              })
              return
            }
            if (this.mealType === '请选择餐别') {
              AlertDialog.show({
                title: '提示',
                message: '请选择餐别',
                confirm: {
                  value: '确定',
                  action: () => {
                    console.log('确定')
                  }
                }
              })
              return
            }
            if (this.diningType === '请选择用餐类型') {
              AlertDialog.show({
                title: '提示',
                message: '请选择用餐类型',
                confirm: {
                  value: '确定',
                  action: () => {
                    console.log('确定')
                  }
                }
              })
              return
            }

            // 所有验证通过，执行保存
            this.saveRecipe()
          })
          .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 24, top: 8 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}