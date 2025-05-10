import { router } from '@kit.ArkUI'
import preferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'
import http from '@ohos.net.http'
import { promptAction } from '@kit.ArkUI'

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

// 晨检记录对象接口
interface CheckRecord {
  id: string;
  personName: string;
  temperature: number;
  health: string;
  healthStr: string;
  checkDate: string;
  checkDayTime: string;
  pictureImg: string;
  pictureBackImg: string;
  sceneImg: string;
  healthCertificateState: number;
  healthCertificateStateStr: string;
  state: string;
  temperatureWay: string;
  unitName: string;
}

// 分页响应接口
interface PageResponse {
  records: CheckRecord[];
  total: number;
  size: number;
  current: number;
  pages: number;
}

// API响应接口
interface ApiResponse {
  code: number;
  message: string;
  result: PageResponse;
  success: boolean;
  timestamp: number;
}

// 单条记录查询响应接口
interface SingleRecordResponse {
  code: number;
  message: string;
  result: CheckRecord;
  success: boolean;
  timestamp: number;
}

// HTTP响应类型
interface HttpResponse {
  responseCode: number;
  result: string;
}

@Entry
@Component
struct CalendarPage {
  // 当前显示的月份和年份（响应式状态变量）
  @State private currentDate: Date = new Date()
  // 当前选中的日期（响应式状态变量）
  @State private selectedDate: Date = new Date()
  // 星期显示文本
  private weekDays: string[] = ['日', '一', '二', '三', '四', '五', '六']
  @State private selectedTab: number = 0 // 0:全部 1:晨检 2:午检 3:晚检
  private tabList: string[] = ['全部', '晨检', '午检', '晚检']
  
  // 添加统计相关的状态变量
  @State private totalCount: number = 0
  @State private checkedCount: number = 0
  @State private uncheckedCount: number = 0
  @State private failedCount: number = 0
  @State private checkRecords: CheckRecord[] = [] // 晨检记录列表
  @State private loading: boolean = false // 加载状态
  @State private currentPage: number = 1 // 当前页码
  @State private pageSize: number = 10 // 每页数量
  private token: string = '' // 用于存储token
  private context = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.getStaffStatistics()
    this.loadToken()
  }

  // 获取后厨人员统计数据
  private async getStaffStatistics(): Promise<void> {
    try {
      const prefer: preferences.Preferences = await preferences.getPreferences(this.context, 'myPreferences')
      const storageStaff: string = await prefer.get('staffList', '[]') as string
      if (storageStaff) {
        const staffList: KitchenStaff[] = JSON.parse(storageStaff)
        const activeStaff: KitchenStaff[] = staffList.filter((staff: KitchenStaff) => staff.status === '在职')
        this.totalCount = activeStaff.length
        this.checkedCount = 0
        this.uncheckedCount = this.totalCount
        this.failedCount = 0
      }
    } catch (error) {
      console.error('获取人员统计数据失败:', error)
    }
  }

  // 加载token
  private async loadToken(): Promise<void> {
    try {
      const prefer: preferences.Preferences = await preferences.getPreferences(this.context, 'myPreferences')
      this.token = await prefer.get('token', '') as string
      if (this.token) {
        this.fetchCheckRecords()
      }
    } catch (error) {
      console.error('加载token失败:', error)
    }
  }

  // 获取晨检记录列表
  private async fetchCheckRecords(): Promise<void> {
    if (this.loading) return
    this.loading = true

    try {
      const httpRequest = http.createHttp()
      const response = await httpRequest.request(
        'https://api.suoeryun.com/ifood/jeecg-school/school/xxUnitCheckdata/list',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Access-Token': this.token
          },
          extraData: {
            pageNo: this.currentPage,
            pageSize: this.pageSize,
            checkDayTime: this.selectedTab === 1 ? '晨检' : 
                         this.selectedTab === 2 ? '午检' : 
                         this.selectedTab === 3 ? '晚检' : undefined
          }
        }
      )

      if (response.responseCode === 200 && typeof response.result === 'string') {
        const jsonData: ApiResponse = JSON.parse(response.result)
        if (jsonData.success) {
          this.checkRecords = jsonData.result.records
          this.totalCount = jsonData.result.total
          this.updateStatistics()
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

  // 更新统计数据
  private updateStatistics() {
    this.checkedCount = this.checkRecords.filter(record => record.health === '0').length
    this.uncheckedCount = this.totalCount - this.checkedCount
    this.failedCount = this.checkRecords.filter(record => record.health === '1').length
  }

  // 通过ID查询晨检记录
  private async fetchCheckRecordById(id: string): Promise<CheckRecord | null> {
    try {
      const httpRequest = http.createHttp()
      const response = await httpRequest.request(
        `https://api.suoeryun.com/ifood/jeecg-school/school/xxUnitCheckdata/queryById?id=${id}`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Access-Token': this.token
          }
        }
      )

      if (response.responseCode === 200 && typeof response.result === 'string') {
        const jsonData: SingleRecordResponse = JSON.parse(response.result)
        if (jsonData.success) {
          return jsonData.result
        }
      }
      return null
    } catch (error) {
      console.error('查询晨检记录详情失败:', error)
      promptAction.showToast({ message: '查询晨检记录详情失败' })
      return null
    }
  }

  /**
   * 格式化日期为 YYYY-MM-DD 格式
   * @param date - 需要格式化的日期对象
   * @returns 格式化后的日期字符串
   */
  private (date: Date): string {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
  }

  /**
   * 获取当前选中周的所有日期
   * @returns 包含7个日期数字的数组
   */
  private getDatesForWeek(): number[] {
    // 计算当月第一天
    const firstDayOfMonth = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), 1)
    // 计算当月最后一天
    const lastDayOfMonth = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 0)

    // 获取当前选中日期的星期几（0-6，0表示星期日）
    const currentDayOfWeek = this.selectedDate.getDay()

    // 计算当前选中日期所在周的第一天（星期日）
    const startDate = new Date(this.selectedDate)
    startDate.setDate(this.selectedDate.getDate() - currentDayOfWeek)

    // 生成当前周的日期数组
    const dates: number[] = []
    for (let i = 0; i < 7; i++) {
      const currentDate = new Date(startDate)
      currentDate.setDate(startDate.getDate() + i)
      dates.push(currentDate.getDate())
    }
    return dates
  }

  /**
   * 更改选中的周
   * @param increment - 增量值，负数表示上一周，正数表示下一周
   */
  private changeWeek(increment: number) {
    // 计算新日期（当前日期 ± 增量周数）
    const newDate = new Date(this.selectedDate)
    newDate.setDate(this.selectedDate.getDate() + (increment * 7))

    // 更新月份和年份显示
    this.currentDate = new Date(newDate)
    this.selectedDate = newDate
  }

  /**
   * 构建日历头部（显示年月和周切换按钮）
   */
  @Builder
  private CalendarHeaderBuilder() {
    Row() {
      // 添加zuo图片
      Image($r('app.media.zuo'))
        .width(24)
        .height(24)
        .margin({ right: 16 })
        .onClick(() => {
          try {
            router.pushUrl({
              url: 'pages/shouye'
            })
          } catch (error) {
            console.error('路由跳转失败：', error)
          }
        })
      // 显示当前年月
      Text(`${this.currentDate.getFullYear()}年${this.currentDate.getMonth() + 1}月`)
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor('#ffffffff')
      Blank()
      // 周切换按钮
      Row() {
        Text('<') // 上一周按钮
          .fontSize(24)
          .fontColor('#ffffffff')
          .margin({ right: 20 })
          .onClick(() => this.changeWeek(-1))
        Text('>') // 下一周按钮
          .fontSize(24)
          .fontColor('#ffffffff')
          .onClick(() => this.changeWeek(1))
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#00C853')
  }

  /**
   * 构建星期标题行
   */
  @Builder
  private WeekDaysBuilder() {
    Row() {
      // 渲染星期文本（一至日）
      ForEach(this.weekDays, (day: string) => {
        Text(day)
          .fontSize(15)
          .width('14.28%') // 平均分配宽度（100%/7）
          .textAlign(TextAlign.Center)
          .fontColor('#ffffffff')
      })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  /**
   * 构建底部按钮行
   * 包含"全部、晨检、午检、晚检"四个切换按钮，靠左排列，点击高亮；
   * 右侧为"未晨检人员>"跳转按钮。
   * 整体底部白色横条，按钮间距紧凑，样式与日历区域分层。
   */
  @Builder
  private TabButtonRowBuilder() {
    Row() {
      Row() {
        ForEach(this.tabList, (tab: string, idx: number) => {
          Text(tab)
            .fontSize(13)
            .fontColor(this.selectedTab === idx ? '#ffffffff' : '#ff000000')
            .backgroundColor(this.selectedTab === idx ? '#00C853' : '#ffe5e5e5')
            .border({ color: this.selectedTab === idx ? '#00C853' : '#ffffffff', width: 1 })
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .margin({ right: 2 })
            .onClick(() => { 
              this.selectedTab = idx
              this.currentPage = 1
              this.fetchCheckRecords()
            })
        })
      }
      .layoutWeight(1)
      
      Blank()
      Text('未晨检人员 >')
        .fontSize(13)
        .fontColor('#00C853')
        .onClick(() => {
          // 可以添加跳转到未晨检人员列表的逻辑
        })
    }
    .width('100%')
    .backgroundColor('#ffffffff')
    .padding(8)
  }

  // 添加晨检记录列表构建器
  @Builder
  private CheckRecordListBuilder() {
    List() {
      ForEach(this.checkRecords, (record: CheckRecord) => {
        ListItem() {
          Column() {
            Row() {
              Text(record.personName)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Blank()
              Text(record.checkDate)
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('100%')
            .padding({ bottom: 8 })

            Row() {
              Text(`体温: ${record.temperature}℃`)
                .fontSize(14)
              Blank()
              Text(record.healthStr)
                .fontSize(14)
                .fontColor(record.health === '0' ? '#00C853' : '#FF0000')
            }
            .width('100%')
            .padding({ bottom: 4 })

            Text(`检查时段: ${record.checkDayTime}`)
              .fontSize(14)
              .fontColor('#666666')
          }
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ bottom: 8 })
          .onClick(async () => {
            const detail: CheckRecord | null = await this.fetchCheckRecordById(record.id)
            if (detail) {
              // 这里可以添加显示详情的逻辑
              promptAction.showToast({ message: '查看详情功能待实现' })
            }
          })
        }
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  /**
   * 组件构建方法
   */
  build() {
    Column() {
      // 渲染日历头部
      this.CalendarHeaderBuilder()
      // 日历内容绿色区域
      Column() {
        // 渲染星期标题行
        this.WeekDaysBuilder()
        // 渲染日期选择行
        Row() {
          ForEach(this.getDatesForWeek(), (date: number) => {
            Column() {
              Stack() {
                // 选中日期高亮背景
                if (date === this.selectedDate.getDate()) {
                  Circle()
                    .width(40)
                    .height(40)
                    .fill('#ffffffff')
                }
                // 日期文本（选中日期使用主题色，未选中使用白色）
                Text(`${date < 10 ? '0' : ''}${date}`)
                  .fontSize(18)
                  .fontColor(date === this.selectedDate.getDate() ? '#00C853' : '#FFFFFF')
              }
            }
            .width('14.28%') // 平均分配宽度（100%/7）
            .height(50)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              // 更新选中日期
              const newDate = new Date(this.selectedDate)
              newDate.setDate(date)
              this.selectedDate = newDate
            })
          })
        }
        .width('100%')
        .padding({ bottom: 16 })
      }
      .width('100%')
      .backgroundColor('#00C853') // 绿色背景只包裹日历内容
      // 添加统计信息显示
      Row() {
        Column() {
          Text('总人数')
            .fontSize(14)
          Text(this.totalCount.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        
        Column() {
          Text('已检查')
            .fontSize(14)
          Text(this.checkedCount.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#00C853')
        }
        .layoutWeight(1)
        
        Column() {
          Text('未检查')
            .fontSize(14)
          Text(this.uncheckedCount.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')
        }
        .layoutWeight(1)
        
        Column() {
          Text('异常')
            .fontSize(14)
          Text(this.failedCount.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF0000')
        }
        .layoutWeight(1)
      }
      .padding(16)
      .backgroundColor('#FFFFFF')
      // 添加切换按钮行
      this.TabButtonRowBuilder()
      // 添加晨检记录列表
      this.CheckRecordListBuilder()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}