import { router } from '@kit.ArkUI'
import preferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'
import http from '@ohos.net.http'
import { promptAction } from '@kit.ArkUI'
interface ApiResponse {
  code: number;
  message: string;
  result: PageResponse;
  success: boolean;
  timestamp: number;
}
interface PageResponse {
  records: CheckRecord[];
  total: number;
  size: number;
  current: number;
  pages: number;
}
interface CheckRecord {
  userName: string;//姓名
  type_dictText: string;//状态
  position: string;//人员岗位
  healthStartTime: string;//发证日期
  healthEndTime: string; //到期时间
  unitName: string;//单位name

}

// 定义后厨人员接口
interface KitchenStaff {
  id: string;
  name: string;
  position: string;
  phone: string;
  certificate: string;
  certExpiry: string;
  joinDate: string;
  status: string;
}

@Entry
@Component
struct Chenjian1Page {
  @State private loading: boolean = false
  @State private checkRecords: CheckRecord[] = []
  @State staffList: KitchenStaff[] = []
  private context = getContext(this) as common.UIAbilityContext
  private async fetchCheckRecords(): Promise<void> {
    if (this.loading) return
    this.loading = true

    try {
      const httpRequest = http.createHttp()
      const response = await httpRequest.request(
        'https://api.suoeryun.com/ifood//jeecg-school/school/xxUnitUser/list',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0ODE2NDg0NSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.R6N5Ij8O70nK2uQ2uiuMWjp5VemhndeHLvA8tixV6EA'
          },
          extraData: {
          }
        }
      )

      if (response.responseCode === 200 && typeof response.result === 'string') {
        const jsonData: ApiResponse = JSON.parse(response.result)
        if (jsonData.success) {
          this.checkRecords = jsonData.result.records
          console.log('666')
        } else {
          promptAction.showToast({ message: jsonData.message || '获取数据失败' })
        }
      }
    } catch (error) {
      console.error('获取晨检记录失败:', error)
      promptAction.showToast({ message: '获取晨检记录失败' })
    } finally {
      this.loading = false
    }
  }
  aboutToAppear() {
    this.getStaffList()
  }
  onPageShow() {
    this.fetchCheckRecords()
    this.getStaffList()
  }

  private async getStaffList() {
    try {
      const prefer = await preferences.getPreferences(this.context, 'myPreferences')
      const storageStaff = await prefer.get('staffList', '[]')
      if (storageStaff) {
        this.staffList = JSON.parse(storageStaff as string)
        // 按入职日期倒序排列，最新的显示在前面
        this.staffList.sort((a, b) => new Date(b.joinDate).getTime() - new Date(a.joinDate).getTime())
      }
    } catch (error) {
      console.error('获取人员数据失败:', error)
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.zuo'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            try {
              router.pushUrl({
                url: 'pages/chenjian'
              })
            } catch (error) {
              console.error('路由跳转失败：', error)
            }
          })
        Text('未晨检人员')
          .fontSize(18)
          .fontColor('#ff020101')
          .margin({ left: 85 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#00C853')

      // 主要内容区域
      Column() {
        if (this.staffList.length === 0) {
          // 无数据时显示提示
          Column() {
            Blank()
            Text('~暂无相关数据~')
              .fontSize(15)
              .fontColor('#BBBBBB')
            Blank()
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          // 有数据时显示列表
          List() {
            ForEach(this.checkRecords, (staff: CheckRecord) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(staff.userName)
                      .fontSize(30)
                      .fontColor('#333')
                    Blank()
                  }
                  .width('100%')
                  .padding({ top: 5, bottom: 5 })
                  Row() {
                    Text('人员状态：')
                      .fontSize(16)
                      .fontColor('#666')
                    Text(staff.type_dictText)
                      .fontSize(16)
                      .fontColor('#333')
                  }
                  .width('100%')
                  .padding({ top: 5, bottom: 5 })
                  Row() {
                    Text('人员岗位：')
                      .fontSize(16)
                      .fontColor('#666')
                    Text(staff.position)
                      .fontSize(16)
                      .fontColor('#333')
                  }
                  .width('100%')
                  .padding({ top: 5, bottom: 5 })

                  Row() {
                    Text('发证日期：')
                      .fontSize(16)
                      .fontColor('#666')
                    Text(staff.healthStartTime)
                      .fontSize(16)
                      .fontColor('#333')
                  }
                  .width('100%')
                  .padding({ top: 5, bottom: 5 })

                  Row() {
                    Text('到期日期：')
                      .fontSize(16)
                      .fontColor('#666')
                    Text(staff.healthEndTime)
                      .fontSize(16)
                      .fontColor('#333')
                  }
                  .width('100%')
                  .padding({ top: 5, bottom: 5 })

                  Row() {
                    Text('所属单位：')
                      .fontSize(16)
                      .fontColor('#666')
                    Text(staff.unitName)
                      .fontSize(16)
                      .fontColor('#333')
                  }
                  .width('100%')
                  .padding({ top: 5, bottom: 5 })

                  .width('100%')
                  .padding({ top: 5, bottom: 5 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFF')
                .border({
                  width: 1,
                  color: '#4CAF50',
                  style: BorderStyle.Solid
                })
                .borderRadius(8)
              }
              .margin({ bottom: 10 })
            })
          }
          .width('100%')
          .padding(10)

          // 底部显示-END-
          Text('-END-')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 20, bottom: 20 })
            .width('100%')
            .textAlign(TextAlign.Center)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
