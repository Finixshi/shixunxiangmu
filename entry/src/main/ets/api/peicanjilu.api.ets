import router from '@ohos.router';
import http from '@ohos.net.http';
import { peicanjilu } from '../pages/peicanjilu';

// 定义记录类型接口
export interface peicanjilu {
  date: string
  unit: string
  meal: string
  position: string
  name: string
  evaluation: string
}

@Entry
@Component
struct DatePickerPage {
  @State currentDate: Date = new Date()
  @State selectedDate: string = '请选择供应日期'
  @State selectDate: Date = new Date()
  @State records: Array<peicanjilu> = []; // 存储陪餐记录
  @State showEmpty: boolean = true; // 控制是否显示空状态

  @Builder
  private RecordCardBuilder(record: peicanjilu) {
    Column() {
      Row() {
        Text(record.date).fontColor('#666').fontSize(14)
        Text(record.unit).fontColor('#333').fontSize(16).margin({ left: 10 })
      }
      .justifyContent(FlexAlign.Start)

      Row() {
        Text(`配餐日期：${record.meal}`).fontSize(14)
        Text(`提交单位：${record.position}`).margin({ left: 15 }) // 确保这里显示的是字符串值
      }
      .margin({ top: 8 })

      Text(`陪餐餐别：${record.name}`).fontSize(14).margin({ top: 4 })
      Text(`陪餐职务：${record.evaluation}`).fontSize(14).margin({ top: 4 })
    }
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ top: 10 })
    .width('90%')
    .shadow({ radius: 4, color: '#30000000', offsetX: 1, offsetY: 1 })
  }

  private getThisWeekDates(): Array<Date> {
    const start = new Date(this.currentDate)
    start.setDate(start.getDate() - start.getDay() + 1) // 周一

    const dates: Date[] = []
    for (let i = 0; i < 7; i++) {
      const d = new Date(start)
      d.setDate(start.getDate() + i)
      dates.push(d)
    }
    return dates
  }

  private showDateDialog() {
    DatePickerDialog.show({
      start: new Date('2000-1-1'),
      end: new Date('2100-1-1'),
      selected: this.selectDate,
      onAccept: (value: DatePickerResult) => {
        const year = value.year?? new Date().getFullYear()
        const month = value.month?? new Date().getMonth() + 1
        const day = value.day?? new Date().getDate()

        this.selectDate = new Date(year, month, day)
        this.selectedDate = `${year}-${(month + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`

        // 筛选该日期的记录
        this.filterRecordsByDate();
      }
    })
  }

  private filterRecordsByDate() {
    // 这里应该根据选择的日期从服务器获取数据
    console.info(`筛选日期：${this.selectedDate}`);
    console.info(`提交单位：${this.position}`)
    // 实际项目中应该调用API获取数据
  }

  onPageShow() {
    try {
      // 使用getParams获取参数
      const params = router.getParams() as peicanjilu;
      if (params) {
        const newRecord: peicanjilu = {
          date: params.date,
          unit: params.unit,
          meal: params.meal,
          position: params.position,
          name: params.name,
          evaluation: params.evaluation
        };
        this.records.push(newRecord);
        this.showEmpty = false;
      }
    } catch (error) {
      console.error('获取或处理路由参数时出错:', error);
    }
  }
  build() {
    Column({ space: 20 }) {
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          })
        Text('陪餐记录')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF');

      // 日期选择
      Row({ space: 10 }) {
        Select([])
          .value(this.selectedDate)
          .onClick(() => {
            this.showDateDialog()
          })
          .margin(10)
          .width('90%')
          .height(70)
          .font({ size: 20 })
      }
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: 20 })

      // 数据展示区 - 使用Scroll组件替代overflow属性
      Scroll() {
        Column() {
          if (this.showEmpty) {
            Text('~ 暂无相关数据 ~')
              .fontSize(16)
              .fontColor(Color.Gray)
              .padding(20)
          } else {
            ForEach(this.records, (record: peicanjilu) => {
              this.RecordCardBuilder(record)
            })
          }
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
      }
      .height('50%')

      // 上传按钮
      Button('上传陪餐记录')
        .fontSize(18)
        .backgroundColor('#2BB673')
        .fontColor(Color.White)
        .borderRadius(10)
        .width('80%')
        .onClick(() => {
          router.pushUrl({ url: 'pages/shangchuanpeican' })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

const BASE_URL = 'http://your-api-base-url';  // 需要替换为实际的API地址

// 获取陪餐记录列表
export async function getPeicanList(date?: string): Promise<Array<peicanjilu>> {
  try {
    let url = `${BASE_URL}/peican/list`;
    if (date) {
      url += `?date=${date}`;
    }
    
    let httpRequest = http.createHttp();
    let response = await httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      }
    );
    
    if (response.responseCode === 200) {
      return JSON.parse(response.result.toString()) as Array<peicanjilu>;
    }
    throw new Error('Failed to fetch peican records');
  } catch (error) {
    console.error('获取陪餐记录失败:', error instanceof Error ? error.message : String(error));
    throw new Error('获取陪餐记录失败: ' + (error instanceof Error ? error.message : String(error)));
  }
}

// 添加陪餐记录
export async function addPeicanRecord(record: peicanjilu): Promise<boolean> {
  try {
    let httpRequest = http.createHttp();
    let response = await httpRequest.request(
      `${BASE_URL}/peican/add`,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(record)
      }
    );
    
    return response.responseCode === 200;
  } catch (error) {
    console.error('添加陪餐记录失败:', error instanceof Error ? error.message : String(error));
    throw new Error('添加陪餐记录失败: ' + (error instanceof Error ? error.message : String(error)));
  }
}

// 更新陪餐记录
export async function updatePeicanRecord(record: peicanjilu): Promise<boolean> {
  try {
    let httpRequest = http.createHttp();
    let response = await httpRequest.request(
      `${BASE_URL}/peican/update`,
      {
        method: http.RequestMethod.PUT,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(record)
      }
    );
    
    return response.responseCode === 200;
  } catch (error) {
    console.error('更新陪餐记录失败:', error instanceof Error ? error.message : String(error));
    throw new Error('更新陪餐记录失败: ' + (error instanceof Error ? error.message : String(error)));
  }
}

// 删除陪餐记录
export async function deletePeicanRecord(recordId: string): Promise<boolean> {
  try {
    let httpRequest = http.createHttp();
    let response = await httpRequest.request(
      `${BASE_URL}/peican/delete/${recordId}`,
      {
        method: http.RequestMethod.DELETE,
        header: {
          'Content-Type': 'application/json'
        }
      }
    );
    
    return response.responseCode === 200;
  } catch (error) {
    console.error('删除陪餐记录失败:', error instanceof Error ? error.message : String(error));
    throw new Error('删除陪餐记录失败: ' + (error instanceof Error ? error.message : String(error)));
  }
}