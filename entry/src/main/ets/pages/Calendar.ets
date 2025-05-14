import router from '@ohos.router'
import { getSampleService } from '../common/services/SampleService'
import { SampleFormData } from '../common/types'
import promptAction from '@ohos.promptAction'
import common from '@ohos.app.ability.common'
import http from '@ohos.net.http'

// API响应中Sample记录的类型
interface ApiSampleRecord {
  id: string
  demandUnit: string
  demandUnitName: string
  reservedSampleDate: string
  mealCategory: string
  dishName: string
  remark: string
  cabinetTemperature: string
  destroyPerson: string
  destroyTime: string
  sampleType: string
  putWeight: string
  reservedSampleImages: string
  cabinetPhoto: string
}

// API分页响应类型
interface ApiPageResult {
  records: ApiSampleRecord[]
  total: number
  size: number
  current: number
  pages: number
}

// 接口响应类型
interface ApiResponse {
  success: boolean
  code: number
  message: string
  result: ApiPageResult | null
  timestamp: number
}

@Entry
@Component
struct CalendarPage {
  @State private currentDate: Date = new Date()
  @State private selectedDate: Date = new Date()
  @State private samples: SampleFormData[] = []
  @State private loading: boolean = false
  private weekDays: string[] = ['一', '二', '三', '四', '五', '六', '日']
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext
  private sampleService = getSampleService(this.context)

  aboutToAppear() {
    this.loadSamples()
  }

  onPageShow() {
    this.loadSamples()
  }

  async loadSamples() {
    this.loading = true
    try {
      const date = this.formatDate(this.selectedDate)
      this.samples = await this.sampleService.getSamplesByDate(date)
      
      // 尝试从API获取数据
      await this.fetchSamplesFromApi(date)
    } catch (error) {
      console.error('加载留样数据失败:', error)
    } finally {
      this.loading = false
    }
  }

  // 从API获取留样数据
  private async fetchSamplesFromApi(date: string) {
    try {
      const httpRequest = http.createHttp()
      // 确保URL格式正确
      const url = `https://api.suoeryun.com/ifood/jeecg-school/school/xxReservedSample/list?reservedSampleDate=${date}`
      
      // 添加日志调试
      console.info(`获取留样列表API URL: ${url}`);
      
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            // 使用使用的有效token
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
          }
        }
      )
      
      // 打印响应信息
      console.info(`获取留样列表API响应状态码: ${response.responseCode}`);
      if (response.result) {
        console.info(`获取留样列表API响应数据: ${response.result.toString().substring(0, 200)}...`);
      }
      
      if (response.responseCode === 200) {
        const apiResponse = JSON.parse(response.result as string) as ApiResponse
        
        // 打印API响应
        console.info(`API响应成功: ${apiResponse.success}, 代码: ${apiResponse.code}`);
        
        if (apiResponse.success && apiResponse.result && Array.isArray(apiResponse.result.records)) {
          // 打印获取到的记录数
          console.info(`获取到 ${apiResponse.result.records.length} 条留样记录`);
          
          // 将API返回的数据转换为应用内的数据格式
          const apiSamples = apiResponse.result.records.map(item => this.convertApiSampleToLocal(item))
          
          // 更新本地存储
          if (apiSamples.length > 0) {
            await this.sampleService.updateSamplesFromApi(date, apiSamples)
            // 重新加载数据
            this.samples = await this.sampleService.getSamplesByDate(date)
          }
        } else {
          console.info('API返回成功，但没有找到留样记录');
        }
      }
    } catch (error) {
      console.error('从API获取留样数据失败:', error)
    }
  }

  // 将API返回的留样数据转换为本地格式
  private convertApiSampleToLocal(apiSample: ApiSampleRecord): SampleFormData {
    // 餐别映射
    const mealCategoryMap: Record<string, string> = {
      '0': '早餐',
      '1': '午餐',
      '2': '晚餐',
      '3': '早点',
      '4': '午点',
      '5': '晚点',
      '6': '其他',
      '7': '营养改善计划'
    }
    
    // 留样类型映射
    const sampleTypeMap: Record<string, string> = {
      '0': '不区分',
      '1': '学生餐',
      '2': '教师餐'
    }
    
    return {
      id: apiSample.id || '',
      location: apiSample.demandUnitName || '实训第一学校餐厅',
      date: apiSample.reservedSampleDate || this.formatDate(new Date()),
      type: sampleTypeMap[apiSample.sampleType || '0'] || '不区分',
      mealType: mealCategoryMap[apiSample.mealCategory || '1'] || '午餐',
      temperature: Number(apiSample.cabinetTemperature) || 5,
      foodName: apiSample.dishName || '',
      weight: apiSample.putWeight || '125',
      staff: apiSample.destroyPerson || '',
      disposalTime: apiSample.destroyTime || '',
      images: apiSample.reservedSampleImages ? [apiSample.reservedSampleImages] : [],
      cabinetImages: apiSample.cabinetPhoto ? [apiSample.cabinetPhoto] : [],
      notes: apiSample.remark || ''
    }
  }

  private formatDate(date: Date): string {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
  }

  private getDatesForWeek(): number[] {
    const firstDayOfMonth = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), 1)
    const lastDayOfMonth = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 0)
    const selectedWeek = Math.floor((this.selectedDate.getDate() - 1) / 7)
    const startDate = new Date(firstDayOfMonth)
    startDate.setDate(selectedWeek * 7 + 1)

    const dates: number[] = []
    for (let i = 0; i < 7; i++) {
      const currentDate = new Date(startDate)
      currentDate.setDate(startDate.getDate() + i)
      if (currentDate <= lastDayOfMonth) {
        dates.push(currentDate.getDate())
      } else {
        dates.push(i + 1)
      }
    }
    return dates
  }

  private changeWeek(increment: number) {
    const newDate = new Date(this.selectedDate)
    newDate.setDate(this.selectedDate.getDate() + (increment * 7))

    // 更新月份和年份
    this.currentDate = new Date(newDate)
    this.selectedDate = newDate
    this.loadSamples()
  }

  @Builder
  private HeaderBuilder() {
    Row() {
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back()
          })
        Text('每日留样')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  private CalendarHeaderBuilder() {
    Row() {
      Text(`${this.currentDate.getFullYear()}年${this.currentDate.getMonth() + 1}月`)
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
      Blank()
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .margin({ right: 20 })
          .onClick(() => this.changeWeek(-1))
        Text('>')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .onClick(() => this.changeWeek(1))
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#00C853')
  }

  @Builder
  private WeekDaysBuilder() {
    Row() {
      ForEach(this.weekDays, (day: string) => {
        Text(day)
          .fontSize(14)
          .width('14.28%')
          .textAlign(TextAlign.Center)
          .fontColor('#FFFFFF')
      })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  private SampleListBuilder() {
    Column() {
      if (this.samples.length === 0) {
        Text('暂无相关数据')
          .fontSize(14)
          .fontColor('#999999')
      } else {
        List() {
          ForEach(this.samples, (sample: SampleFormData, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text(sample.mealType)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Text(`${sample.foodName || '-'} · ${sample.weight}克`)
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Row() {
                  Button('编辑')
                    .fontSize(14)
                    .fontColor('#00C853')
                    .backgroundColor('#FFFFFF')
                    .borderRadius(16)
                    .borderWidth(1)
                    .borderColor('#00C853')
                    .margin({ right: 8 })
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/SampleForm',
                        params: {
                          selectedDate: this.formatDate(this.selectedDate),
                          editSample: sample,
                          editIndex: index
                        }
                      })
                    })
                  Button('删除')
                    .fontSize(14)
                    .fontColor('#FF0000')
                    .backgroundColor('#FFFFFF')
                    .borderRadius(16)
                    .borderWidth(1)
                    .borderColor('#FF0000')
                    .onClick(async () => {
                      AlertDialog.show({
                        title: '删除确认',
                        message: '确定要删除该留样记录吗？',
                        primaryButton: {
                          value: '取消',
                          action: () => {
                            // 取消操作，不做任何事
                          }
                        },
                        secondaryButton: {
                          value: '确认',
                          action: async () => {
                            try {
                              // 显示删除中提示
                              await promptAction.showToast({ 
                                message: '删除中...', 
                                duration: 1000,
                                bottom: 100
                              })
                              
                              // 先确保样本有id
                              if (sample.id) {
                                console.info(`开始删除留样记录, ID: ${sample.id}`)
                              } else {
                                console.info(`开始删除本地留样记录，无ID`)
                              }
                              
                              // 调用删除API
                              await this.sampleService.deleteSample(this.formatDate(this.selectedDate), index)
                              
                              // 显示删除成功提示
                              await promptAction.showToast({ 
                                message: '删除成功', 
                                duration: 2000 
                              })
                              
                              // 重新加载数据
                              this.loadSamples()
                            } catch (error) {
                              console.error('删除留样失败:', error)
                              await promptAction.showToast({ 
                                message: '删除失败，请重试', 
                                duration: 2000 
                              })
                            }
                          }
                        }
                      })
                    })
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
            }
            .margin({ bottom: 8 })
          })
        }
        .width('100%')
        .padding(16)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#F5F5F5')
  }

  build() {
    Column() {
      this.HeaderBuilder()

      this.CalendarHeaderBuilder()

      Column() {
        this.WeekDaysBuilder()

        Row() {
          ForEach(this.getDatesForWeek(), (date: number) => {
            Column() {
              Stack() {
                if (date === this.selectedDate.getDate()) {
                  Circle()
                    .width(40)
                    .height(40)
                    .fill('#FFFFFF')
                }
                Text(`${date < 10 ? '0' : ''}${date}`)
                  .fontSize(18)
                  .fontColor(date === this.selectedDate.getDate() ? '#00C853' : '#FFFFFF')
              }
            }
            .width('14.28%')
            .height(50)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              const newDate = new Date(this.selectedDate)
              newDate.setDate(date)
              this.selectedDate = newDate
              this.loadSamples()
            })
          })
        }
        .width('100%')
        .padding({ bottom: 16 })
      }
      .width('100%')
      .backgroundColor('#00C853')

      this.SampleListBuilder()

      Button('新增留样')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#00C853')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SampleForm',
            params: {
              selectedDate: this.formatDate(this.selectedDate)
            }
          })
        })
    }
    .width('100%')
    .height('100%')
  }
} 