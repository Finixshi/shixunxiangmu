import router from '@ohos.router';
import http from '@ohos.net.http';


AppStorage.setOrCreate('token', '');
AppStorage.setOrCreate('tenantId', 0);

// 新增：定义 ReportFormData 接口
interface ReportFormData {
  unit: string;
  meal: string;
  position: string;
  name: string;
  evaluation: string;
  date: string;
  dutposition: string; // 新增
}

interface UserInfo {
  id: string;
  username: string;
  clientType: string;
  realname: string;
  avatar: string | null;
  relTenantIds:number;
  // 其他字段根据实际API响应补充...
}

interface MealRecordInfo {
  position: string;
  images: string;
}

interface reportResponse {
  code: number;
  message: string;
  result: reportResult;
  timestamp: number;
}

interface reportResult {
  userInfo: UserInfo;
  token: string;
}

interface reportHandlerResult{
  success: boolean;
  code?: number;
  userInfo?: UserInfo;
  token?: string;
  message?: string;
  relTenantIds?:number;
}

interface RouteParams {//接口传递参数定义
  token?: string;
  relTenantIds?: number;
  unitId?: string;
}

interface SelectOption{
  value: string;
  label: string;
}

// Page1.ets
interface GeneratedObjectLiteralInterface_1 {
  unit: string;
  meal: string;
  position: string;
  name: string;
  evaluation: string;
  date: string;
}
@Entry
@Component
struct Page1 {
  @State selectedPosition: string = ''
  @State private selectedUnitIndex:string = '实训第二学校餐厅';
  @State private selectedMealIndex:string = '0';
  @State private selectedMealValue:string = '其他'
  @State selectedUnit: string = ''
  @State selectedMeal: string = '' // 新增：选中的餐别
  @State name: string = ''
  @State evaluation: string = ''
  @State charCount: number = 0
  @State date: string = '选择日期'
  @State selectedDate: string = '请选择供应日期'
  @State selectDate: Date = new Date()
  @State dates: string = '请选择'
  @State receivedToken: string = '';//参数传递
  @State tenantId: number = 0;//同上
  @State UnitId: string  ="";
  @State dutposition: string = ''
  private unitOptions: Array<SelectOption> = [
    { value: '实训第二学校餐厅', label: '实训第二学校餐厅' },
  ];

  // 新增：餐别选项列表
  private mealOptions: Array<SelectOption> = [
    { value: '其他', label: '0' },
    { value: '早餐', label: '1' },
    { value: '午餐', label: '2' },
    { value: '晚餐', label: '3' }
  ];
  async onPageShow() {//这是一个接收传递参数的方法
    // 使用接口类型断言
    const params = router.getParams() as RouteParams;

    console.log('report1', params?.token);// 打印接收到的参数
    console.log('report1', params?.relTenantIds);//  打印接收到的参数

    // 安全取值如果返回值空，则使用appsetcreat中所预保存的token和id
    if (!AppStorage.get('token') && params?.token) {
      AppStorage.set('token', params.token);
      this.receivedToken = params.token;
    }

    if (!AppStorage.get('tenantId') && params?.relTenantIds) {
      AppStorage.set('tenantId', params.relTenantIds);
      this.tenantId = params.relTenantIds;
    }

    if (!AppStorage.get('unitId') && params?.unitId) {
      AppStorage.set('unitId', params.unitId);
      //this.UnitId = params.unitId;
    }

    // 同步到组件状态
    this.receivedToken = AppStorage.get('token')??'';
    this.tenantId = AppStorage.get('tenantId')??0;
    this.UnitId = AppStorage.get('unitId') ?? '';
    console.log('rel',this.UnitId);
    console.log('UID', params?.unitId);
    //const result = await this.Houchuchaxun();// 调用Houchuchaxun方法这个函数是用来查数据的
    //console.log('houchu1', result); // 打印返回结果
    const result=await this.report();
  }

  build() {
    Column() {

      Text('陪餐记录')
        .fontSize(24)
        .margin(20)
      Row(){
        Text("选择日期")
        //   .fontColor(Color.Black)
        //   .fontSize(16)
        //   Text(this.dates)
        Select([])
          .onClick(() => {
            this.showDateDialog()
          })
          .value(this.dates)
          .margin(10)
          .width('70%')
          .margin({left:20,right:0,bottom:10})
      }

      Row(){
        Text("提交单位")
          .fontColor(Color.Black)
          .fontSize(16)
        Select(this.unitOptions)
          .value('请选择')
            // .selected(this.unitOptions.findIndex(item => item.label === this.selectedUnitIndex))
          .onSelect((index: number) => {
            this.selectedUnitIndex = this.unitOptions[index].label;
            // this.selectedUnitIndex = this.unitOptions[index].value;
          })
          .margin(10)
          .width('70%')
          .margin({left:20,right:0,bottom:10})
      }

      Row(){
        Text("餐别选择")
          .fontColor(Color.Black)
          .fontSize(16)

        Select(this.mealOptions)
          .value('请选择')
            // .selected(this.mealOptions.findIndex(item => item.label === this.selectedMealIndex))
          .onSelect((index: number) => {
            this.selectedMealIndex = this.mealOptions[index].label;
            this.selectedMealValue  = this.mealOptions[index].value;
          })
          .margin(10)
          .width('70%')
          .margin({left:20,right:0,bottom:10})

      }
      // 陪餐人姓名
      Row() {
        Text("陪餐人职务")
          .fontSize(16)
          .margin({ left: 20, right: 10 })
        TextInput({ placeholder: '请输入陪餐人职务' })
          .onChange((value: string) => {
            this.dutposition = value;
          })
          .layoutWeight(1)
          .margin({ right: 20 })
      }

      // 陪餐评价
      // Row() {
      //   Text("陪餐评价")
      //     .fontSize(16)
      //     .margin({ left: 20, right: 10 })
      //   TextArea({ placeholder: '请输入评价（200字以内）' })
      //     .onChange((value: string) => {
      //       this.evaluation = value
      //       this.charCount = value.length
      //     })
      //     .height(50)
      //     .layoutWeight(1)
      //     .maxLength(200)
      //     .onChange((value: string) => {
      //       this.evaluation = value
      //       this.charCount = value.length
      //     })
      //     .height(38)
      //     .layoutWeight(1)
      //     .margin({ right: 20 })
      //
      //
      //
      // }


      Button({type: ButtonType.Normal})
      {
        Text("提交")
          .margin({top: 1,bottom: 1})
          .fontColor(Color.White)
          .width('90%')
          .height(40)
          .textAlign(TextAlign.Center)
      }
      .width('90%')
      .height(40)
      .margin({top: 250})
      .borderRadius(5)
      .backgroundColor(Color.Green)
      .onClick(async () => {
        // 构造要传递的数据
        // const formData: ReportFormData = {
        //   unit: this.selectedUnitIndex,
        //   meal: this.selectedMealValue,
        //   position: '教师', // 可以根据业务动态获取或固定值
        //   name: this.name,
        //   evaluation: this.evaluation,
        //   date: this.dates
        // };
        //
        // // 跳转页面并携带数据
        // router.back({
        //   url: 'pages/peicanjilu',
        //   params: {
        //     token: this.receivedToken,
        //     tenantId: this.tenantId,
        //     record: JSON.stringify(formData) // 关键：传递 record 数据
        //   }
        // });
        router.back()
        const formData: ReportFormData = {
          unit: this.selectedUnitIndex,
          meal: this.selectedMealValue,
          name: this.name,
          evaluation: this.evaluation,
          date: this.dates,
          position: '',
          dutposition: this.dutposition // ✅ 使用用户输入的职务信息
        };


        const result = await this.report();
      })


    }
    .width('100%')
    .height('100%')
  }
  private showDateDialog() {
    DatePickerDialog.show({
      start: new Date('2000-1-1'),
      end: new Date('2100-1-1'),
      selected: this.selectDate,
      onAccept: (value: DatePickerResult) => { // 使用系统内置类型
        if (value.year && value.month && value.day) {
          this.dates = `${value.year}-${value.month+1}-${value.day}`;
        }
      }
    })
  }
  // 添加接口
  private async report(): Promise<reportHandlerResult> {
    try {
      console.log(this.selectedUnitIndex)
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        'https://api.suoeryun.com/ifood/jeecg-school/school/xxMealRecord/add',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json',
            'Tenant-Id':this.tenantId,
            'X-Access-Token':this.receivedToken,
          },
          extraData: JSON.stringify({
            "mealDate": this.dates,
            "mealCategory": this.selectedMealIndex,
            "repastNum": "",
            "withNum": "",
            "xxMealRecordInfoList": [
              {
                "position": this.dutposition || this.name,
                "images": "https://admin.suoeryun.com/pcUpload/32-32-0430180520.png"
              }
            ] as Array<MealRecordInfo>,
            "demandUnit": "",
            "demandUnitName": '实训第二学校餐厅'
          }
          )
        }
      );
      console.log(response.result.toString())
      if (response.responseCode !== 200) {
        return {
          success: false,
          message: `HTTP Error: ${response.responseCode}`
          // 添加其他错误处理逻辑
        };
      }

      const jsonData = JSON.parse(response.result as string) as reportResponse;
      //console.log('', response.responseCode);
      //console.log('',jsonData.code);
      return {
        success: jsonData.code === 200,
        code: jsonData.code,
        //userInfo: jsonData.result.userInfo,
        // token: jsonData.result.token,
        message: jsonData.message,
        relTenantIds:jsonData.result.userInfo.relTenantIds
      };
    } catch (error) {
      //console.error('Login Error:', JSON.stringify(error));
      return {
        success: false,
        message: 'error!'
      };
    }
  }
}