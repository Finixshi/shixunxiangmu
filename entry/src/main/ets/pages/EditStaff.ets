//最终版本,封装，请勿修改

import router from '@ohos.router';
import http from '@ohos.net.http';
import { promptAction } from '@kit.ArkUI';
//import filePicker from '@ohos.file.picker';


//永久存储token和租户id
AppStorage.setOrCreate('token', '');
AppStorage.setOrCreate('tenantId', 0);
AppStorage.setOrCreate('unitId', '');
AppStorage.setOrCreate('editId', '');
//小卡片里的东西
AppStorage.setOrCreate('Name', '');
AppStorage.setOrCreate('status', '');
AppStorage.setOrCreate('position', '');
AppStorage.setOrCreate('issueTime', '');
AppStorage.setOrCreate('expireTime', '');
AppStorage.setOrCreate('workplace', '');
AppStorage.setOrCreate('tel', '');
// 明确定义所有接口类型
interface Houchu_Edit_Request {
  success: boolean;
  code?: number;
  result: string;
  message?: string;
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
interface addResult {
  userInfo: UserInfo;
  token: string;
}
interface addResponse {
  code: number;
  message: string;
  result: addResult;
  timestamp: number;
}
interface addHandlerResult {
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
  editId:string;
  name: string;
  status: string;
  position: string
  issueTime: string
  expireTime: string
  workplace: string
  tel:string
}
interface SelectOption {
  value: string;
  label: string;
}

@Entry
@Component
struct AddStaff {
  @State private selectedUnitIndex:string = '实训第二学校餐厅'; // 默认选中第一个单位
  @State private name: string = '';
  @State private jobPosition: string = '';
  @State private phone: string = '';
  @State private status: string = '在职';
  @State private issueDate: string = '';
  @State private expiryDate: string = '';
  @State receivedToken: string = '';//参数传递
  @State tenantId: number = 0;//同上
  @State UnitId: string  ="";
  @State Edit_id:string = '';

  async onPageShow() {//这是一个接收传递参数的方法
    // 使用接口类型断言
    const params = router.getParams() as RouteParams;
    //console.log('houchu', params?.token);// 打印接收到的参数
    //console.log('houchu', params?.relTenantIds);//  打印接收到的参数

    // 安全取值如果返回值空，则使用appsetcreat中所预保存的token和id
    if (!AppStorage.get('token') && params?.token) {
      AppStorage.set('token', params.token);
      //this.receivedToken = params.token;
    }
    if (!AppStorage.get('tenantId') && params?.relTenantIds) {
      AppStorage.set('tenantId', params.relTenantIds);
    }

    if (!AppStorage.get('unitId') && params?.unitId) {
      AppStorage.set('unitId', params.unitId);
    }
    if (!AppStorage.get('editId') && params?.editId){
      AppStorage.set('editId', params.editId);
    }
    if (!AppStorage.get('Name') && params?.name){
      AppStorage.set('Name', params.name);
    }
    if (!AppStorage.get('status') && params?.status){
      AppStorage.set('status', params.status);
    }
    if (!AppStorage.get('position') && params?.position){
      AppStorage.set('position', params.position);
    }
    if (!AppStorage.get('issueTime') && params?.issueTime){
      AppStorage.set('issueTime', params.issueTime);
    }
    if (!AppStorage.get('expireTime') && params?.expireTime){
      AppStorage.set('expireTime', params.expireTime);
    }
    if (!AppStorage.get('workplace') && params?.workplace){
      AppStorage.set('workplace', params.workplace);
    }
    if (!AppStorage.get('tel') && params?.tel){
      AppStorage.set('tel', params.tel);
    }

    // 同步到组件状态
    this.receivedToken = AppStorage.get('token')??'';
    this.tenantId = AppStorage.get('tenantId')??0;
    this.UnitId = AppStorage.get('unitId') ?? '';
    this.Edit_id = AppStorage.get('editId')??'';
    this.name= AppStorage.get('Name')??'';
    this.status= AppStorage.get('status')??'';
    this.jobPosition= AppStorage.get('position')??'';
    //this.issueDate= AppStorage.get('issueTime')??'';
    //this.expiryDate= AppStorage.get('expireTime')??'';
    this.selectedUnitIndex= AppStorage.get('workplace')??'';
    this.phone= AppStorage.get('tel')??'';

    console.log('editId',this.Edit_id);
    console.log('rel',this.UnitId);
    console.log('UID', params?.unitId);
    console.log('Name1',params?.tel);
    console.log('Name2',this.phone);
    console.log('position',this.jobPosition);
    //const result = await this.Houchuchaxun();// 调用Houchuchaxun方法这个函数是用来查数据的
    //console.log('houchu1', result); // 打印返回结果
  }

  private async HouchuEdit(): Promise<Houchu_Edit_Request> {//这个请求是针对编辑后厨人员列表的

    try {
      const httpRequest = http.createHttp();

      const response = await httpRequest.request(
        'https://api.suoeryun.com/ifood/jeecg-school/school/xxUnitUser/edit',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json',
            'Tenant-Id':this.tenantId.toString(),
            'X-Access-Token':this.receivedToken
          },
          extraData: JSON.stringify({
            "unitName":this.selectedUnitIndex,
            "unitId":this.UnitId,
            "userName": this.name,
            "position": this.jobPosition,
            "tel": this.phone,
            "type": "1",
            "healthStartTime":this.issueDate,
            "healthEndTime": this.expiryDate,
            "portraitPhoto": null,
            "healthUrl": "https://admin.suoeryun.com/pcUpload/043015131332-32.png",
            "remark": "123",
            "inspectionType": 0,
            "version": 0,
            "canteenId": null,
            "id": this.Edit_id
          })

        }

      );

      if (response.responseCode !== 200) {
        //console.error('Login Error:'+response.responseCode);
        return {
          success: false,
          result: '删除失败', // 新增默认值
          message: `HTTP Error: ${response.responseCode}`
          // 添加其他错误处理逻辑
        };
      }
      console.log('slfj'+response.result.toString())
      const jsonData = JSON.parse(response.result as string) as Houchu_Edit_Request;
      console.log('11',jsonData.result);
      return {
        success: jsonData.code === 200,
        code: jsonData.code,
        result: jsonData.result,
        message: jsonData.message,
        //relTenantIds:jsonData.result.userInfo.relTenantIds
      };

    } catch (error) {
      console.error('Login Error:', JSON.stringify(error));
      return {
        success: false,
        result: '删除失败', // 新增默认值
        message: '服务器繁忙'
      };
    }
  }

  private async addStaff(): Promise<addHandlerResult> {
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        'https://api.suoeryun.com/ifood//jeecg-school/school/xxUnitUser/add',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json',
            'Tenant-Id':this.tenantId.toString(),
            'X-Access-Token':this.receivedToken

          },
          extraData: JSON.stringify({
            //username: this.userUsername,
            //password: this.userPassword
            "unitId":this.UnitId,
            "unitName":this.selectedUnitIndex,
            "userName":this.name,
            "idCard":null,
            "portraitPhoto":"",
            "position":this.jobPosition,
            "tel":this.phone,
            "type":"1",
            "type_dictText":this.status,
            "licenceIssuing":"",
            "healthNumber":"",
            "healthUrl":"",
            "healthStartTime":this.issueDate,
            "healthEndTime":this.expiryDate,
            "photoQualification":null,
            "remark":"",
            "inspectionType":0,
            "version":0,"canteenId":null,
            "wxopenId":null,
            "tenantId":"10021011",
            "demandUnitIds":null
          })
        }
      );

      if (response.responseCode !== 200) {
        return {
          success: false,
          message: `HTTP Error: ${response.responseCode}`
          // 添加其他错误处理逻辑
        };
      }

      const jsonData = JSON.parse(response.result as string) as addResponse;
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
      // console.error('Login Error:', JSON.stringify(error));
      return {
        success: false,
        message: 'fuck u!'
      };
    }
  }

  private units: Array<SelectOption> = [
    { value: '实训第二学校餐厅', label: '实训第二学校餐厅' },
    { value: '实训第二学校(库房)', label: '实训第二学校(库房)' },
    { value: '其他单位', label: '其他单位' }
  ];
  private statuses: Array<SelectOption> = [
    { value: '在职', label: '在职' },
    { value: '离职', label: '离职' }
  ];
  build() {
    Column({ space: 0 }) {
      Row({ space: 10}) {
        Text("所属单位 *")
          .fontSize(16)
          .width('30%')
        Select(this.units)
          .selected(this.units.findIndex(item => item.value === this.selectedUnitIndex))
          .onSelect((index: number) => {
            //this.selectedUnitIndex = index;
            this.selectedUnitIndex = this.units[index].value;


          })
          .backgroundColor(Color.White)
          .width('70%')
          .height(50)
          .padding({ left: 10 })
      }
      .margin({ bottom: 10 })

      // 人员姓名
      Row({ space: 10 }) {
        Text("人员姓名 *")
          .fontSize(16)
          .width('30%')
        TextInput({ text:this.name,placeholder: '请输入人员姓名' })
          .onChange((value: string) => {
            this.name = value
          })
          .backgroundColor(Color.White)
          .width('70%')
          .height(50)
          .padding({ left: 10 })
      }
      .margin({ bottom: 10 })

      // 人员岗位
      Row({ space: 10 }) {
        Text("人员岗位 *")
          .fontSize(16)
          .width('30%')
        TextInput({ text:this.jobPosition,placeholder: '请输入人员岗位' })
          .onChange((value: string) => {
            this.jobPosition = value
          })
          .backgroundColor(Color.White)
          .width('70%')
          .height(50)
          .padding({ left: 10 })
      }
      .margin({ bottom: 10 })

      // 联系电话
      Row({ space: 10 }) {
        Text("联系电话 *")
          .fontSize(16)
          .width('30%')
        TextInput({ text:this.phone,placeholder: '请输入员联系电话' })
          .onChange((value: string) => {
            this.phone = value
          })
          .backgroundColor(Color.White)
          .width('70%')
          .height(50)
          .padding({ left: 10 })
      }
      .margin({ bottom: 10 })

      // 人员状态F
      Row({ space: 10 }) {
        Text("人员状态 *")
          .fontSize(16)
          .width('30%')
        Select(this.statuses)
          .selected(this.statuses.findIndex(item => item.value === this.status))
          .onSelect((index: number) => {
            this.status = this.statuses[index].value;
          })
          .backgroundColor(Color.White)
          .width('70%')
          .height(50)
          .padding({ left: 10 })
      }
      .margin({ bottom: 10 })

      // 发证日期
      Row({ space: 10 }) {
        Text("发证日期 *")
          .fontSize(16)
          .width('30%')
        Text(this.issueDate)
        Button(){
          if (this.issueDate == ""){
            Text("请选择")
          }
        }
        .onClick(() => {
          this.showIssueDateDialog()
        })
        .margin({left:175})
        .backgroundColor(Color.White)
      }
      .width("100%")
      .margin({left:0, top: 20, bottom: 20 })


      // 到期日期
      Row({ space: 10 }) {
        Text("到期日期 *")
          .fontSize(16)
          .width('30%')
        Text(this.expiryDate)
        Button(){
          if (this.expiryDate == ""){
            Text("请选择")
          }
        }
        .onClick(() => {
          this.showExpireDateDialog()
        })
        .margin({left:175})
        .backgroundColor(Color.White)
      }
      .width("100%")
      .margin({left:0, top: 20, bottom: 20 })


      // 健康证照片
      Row({ space: 10 }) {
        Text('健康证照片')
          .fontSize(16)
          .width('40%')
        Button({type:ButtonType.Normal})
          .margin({left: 125})
          .backgroundColor(Color.White)
          .backgroundImage($r("app.media.evidence_add"))
          .backgroundImageSize(1)
          .width(50)
          .height(50)
      }
      .margin({top: 10, bottom: 10})
      .height(50)
      .width('100%')
      // 人脸照片
      Row({ space: 10 }) {
        Text("人脸照片")
          .fontSize(16)
          .width('40%')
        Button({type:ButtonType.Normal})
          .margin({left: 125})
          .backgroundColor(Color.White)
          .backgroundImage($r("app.media.evidence_add"))
          .backgroundImageSize(1)
          .width(50)
          .height(50)
      }
      .margin({top:10, bottom: 10 })
      .width('100%')
      // 提交按钮
      Button({type:ButtonType.Normal}){
        Text("提交")
          .fontColor(Color.White)
          .fontSize(18)
      }
      .width('90%')
      .height(45)
      .backgroundColor('#4CAF50')
      .borderRadius(10)
      .position({x:18, y:'95%'})
      .onClick(async() => {
        if(this.name.length!==0&&this.jobPosition.length!==0&&this.phone.length!==0&&this.status.length!==0&&this.issueDate.length!==0&&this.expiryDate.length!==0)
        {router.back({
          url: 'pages/kitchenStaff',
          params:{
            token:this.receivedToken,
            tenantId:this.tenantId,
          }
        })
          const result = await this.HouchuEdit();
          // this.unitId = result.token!;
        }
        else {
          promptAction.showToast({
            message: '求你了你改一些东西吧！',
            duration: 2000,
            bottom:670
          });
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .padding({ top: 0, left: 10, right: 10 })

  }

  private showIssueDateDialog() {
    let dialog: DatePickerDialogOptions = {
      selected: new Date(), // 默认当前日期
      lunar: false,         // 不需要农历
      onAccept: (value: DatePickerResult) => { // 使用系统内置类型
        if (value.year && value.month && value.day) {
          this.issueDate = `${value.year}-${value.month+1}-${value.day}`;
        }
      }
    };
    DatePickerDialog.show(dialog);
  }

  private showExpireDateDialog() {
    let dialog: DatePickerDialogOptions = {
      selected: new Date(), // 默认当前日期
      lunar: false,         // 不需要农历
      onAccept: (value: DatePickerResult) => { // 使用系统内置类型
        if (value.year && value.month && value.day) {
          this.expiryDate = `${value.year}-${value.month+1}-${value.day}`;
        }
      }
    };
    DatePickerDialog.show(dialog);
  }
}
