import dataPreferences from '@ohos.data.preferences'
import { SampleFormData } from '../types'
import common from '@ohos.app.ability.common'
import http from '@ohos.net.http'

const STORE_NAME = 'SampleStore'
const API_BASE_URL = 'https://api.suoeryun.com/ifood'

// API请求数据类型
interface ApiSampleData {
  id?: string
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

// API响应中的result类型
interface ApiResultData {
  // 可能包含的字段
  id?: string
  createTime?: string
  updateTime?: string
  userInfo?: Record<string, string>
}

// API响应类型
interface ApiResponse {
  success: boolean
  code: number
  message: string
  result: ApiResultData | null
  timestamp: number
}

export class SampleServiceClass {
  private context: common.UIAbilityContext

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  private async getStore() {
    return await dataPreferences.getPreferences(this.context, STORE_NAME)
  }

  // 保存留样数据
  async saveSample(sample: SampleFormData): Promise<void> {
    // 先调用API保存留样
    const apiSuccess = await this.addSampleToApi(sample)
    
    if (apiSuccess) {
      // 本地也保存一份
      const store = await this.getStore()
      const key = `sample_${sample.date}`
      const existingSamplesStr = await store.get(key, '[]') as string
      const existingSamples = JSON.parse(existingSamplesStr) as SampleFormData[]
      existingSamples.push(sample)
      await store.put(key, JSON.stringify(existingSamples))
      await store.flush()
    } else {
      throw new Error('添加留样失败')
    }
  }

  // 更新留样数据
  async updateSample(sample: SampleFormData, index: number): Promise<void> {
    // 先调用API更新留样
    const apiSuccess = await this.editSampleToApi(sample)
    
    if (apiSuccess) {
      // 本地也更新一份
      const store = await this.getStore()
      const key = `sample_${sample.date}`
      const samplesStr = await store.get(key, '[]') as string
      const samples = JSON.parse(samplesStr) as SampleFormData[]
      samples[index] = sample
      await store.put(key, JSON.stringify(samples))
      await store.flush()
    } else {
      throw new Error('编辑留样失败')
    }
  }

  // 删除留样数据
  async deleteSample(date: string, index: number): Promise<void> {
    // 获取要删除的样本信息
    const store = await this.getStore()
    const key = `sample_${date}`
    const samplesStr = await store.get(key, '[]') as string
    const samples = JSON.parse(samplesStr) as SampleFormData[]
    
    if (index >= 0 && index < samples.length) {
      const sampleToDelete = samples[index]
      
      // 如果有ID，则调用API删除
      if (sampleToDelete.id) {
        const apiSuccess = await this.deleteSampleFromApi(sampleToDelete.id)
        console.info(`API删除留样${apiSuccess ? '成功' : '失败'}, ID: ${sampleToDelete.id}`)
      }
      
      // 本地也删除
      samples.splice(index, 1)
      await store.put(key, JSON.stringify(samples))
      await store.flush()
    }
  }

  // 获取指定日期的留样数据
  async getSamplesByDate(date: string): Promise<SampleFormData[]> {
    const store = await this.getStore()
    const key = `sample_${date}`
    const samplesStr = await store.get(key, '[]') as string
    return JSON.parse(samplesStr) as SampleFormData[]
  }

  // 调用添加留样API
  private async addSampleToApi(sample: SampleFormData): Promise<boolean> {
    try {
      const httpRequest = http.createHttp()
      // 注意：确保URL格式正确
      const url = 'https://api.suoeryun.com/ifood/jeecg-school/school/xxReservedSample/add'
      
      // 添加日志调试
      console.info(`添加留样API URL: ${url}`)
      
      // 参考shipu.ets中成功的API请求格式
      const apiData: ApiSampleData = {
        demandUnit: "1651892693627330561",
        demandUnitName: sample.location,
        reservedSampleDate: sample.date,
        mealCategory: this.getMealCategoryCode(sample.mealType),
        dishName: sample.foodName || "留样菜品",
        remark: sample.notes || "",
        cabinetTemperature: sample.temperature.toString(),
        destroyPerson: sample.staff || "",
        destroyTime: sample.disposalTime || "",
        sampleType: this.getSampleTypeCode(sample.type),
        putWeight: sample.weight,
        reservedSampleImages: sample.images.length > 0 ? sample.images[0] : "https://admin.suoeryun.com/pcUpload/1917474932601933825_1745996623568.png",
        cabinetPhoto: sample.cabinetImages.length > 0 ? sample.cabinetImages[0] : "https://admin.suoeryun.com/pcUpload/1917474946438942721_1745996626850.png"
      }
      
      // 打印请求数据以便调试
      console.info(`添加留样API请求数据: ${JSON.stringify(apiData)}`)
      
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            // 使用shipu.ets中使用的有效token
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
          },
          extraData: JSON.stringify(apiData)
        }
      )
      
      // 打印响应信息
      console.info(`添加留样API响应状态码: ${response.responseCode}`)
      console.info(`添加留样API响应数据: ${response.result}`)
      
      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse
        console.info(`添加留样API响应成功: ${resData.success}, 代码: ${resData.code}, 消息: ${resData.message}`)
        return resData.success === true || resData.code === 200
      }
      return false
    } catch (error) {
      console.error('添加留样API调用失败:', error)
      return false
    }
  }

  // 调用编辑留样API
  private async editSampleToApi(sample: SampleFormData): Promise<boolean> {
    try {
      const httpRequest = http.createHttp()
      // 注意：确保URL格式正确
      const url = 'https://api.suoeryun.com/ifood/jeecg-school/school/xxReservedSample/edit'
      
      // 添加日志调试
      console.info(`编辑留样API URL: ${url}`)
      
      // 参考shipu.ets中成功的API请求格式
      const apiData: ApiSampleData = {
        id: sample.id || '', // 使用点表示法代替索引访问
        demandUnit: "1651892693627330561",
        demandUnitName: sample.location,
        reservedSampleDate: sample.date,
        mealCategory: this.getMealCategoryCode(sample.mealType),
        dishName: sample.foodName || "留样菜品",
        remark: sample.notes || "",
        cabinetTemperature: sample.temperature.toString(),
        destroyPerson: sample.staff || "",
        destroyTime: sample.disposalTime || "",
        sampleType: this.getSampleTypeCode(sample.type),
        putWeight: sample.weight,
        reservedSampleImages: sample.images.length > 0 ? sample.images[0] : "https://admin.suoeryun.com/pcUpload/1917474932601933825_1745996623568.png",
        cabinetPhoto: sample.cabinetImages.length > 0 ? sample.cabinetImages[0] : "https://admin.suoeryun.com/pcUpload/1917474946438942721_1745996626850.png"
      }
      
      // 打印请求数据以便调试
      console.info(`编辑留样API请求数据: ${JSON.stringify(apiData)}`)
      
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            // 使用shipu.ets中使用的有效token
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
          },
          extraData: JSON.stringify(apiData)
        }
      )
      
      // 打印响应信息
      console.info(`编辑留样API响应状态码: ${response.responseCode}`)
      console.info(`编辑留样API响应数据: ${response.result}`)
      
      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse
        console.info(`编辑留样API响应成功: ${resData.success}, 代码: ${resData.code}, 消息: ${resData.message}`)
        return resData.success === true || resData.code === 200
      }
      return false
    } catch (error) {
      console.error('编辑留样API调用失败:', error)
      return false
    }
  }

  // 调用删除留样API
  private async deleteSampleFromApi(id: string): Promise<boolean> {
    try {
      const httpRequest = http.createHttp()
      // 确保URL格式正确
      const url = `https://api.suoeryun.com/ifood/jeecg-school/school/xxReservedSample/delete?id=${id}`
      
      // 添加日志调试
      console.info(`删除留样API URL: ${url}`)
      
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.DELETE,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            // 使用shipu.ets中使用的有效token
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
          }
        }
      )
      
      // 打印响应信息
      console.info(`删除留样API响应状态码: ${response.responseCode}`)
      console.info(`删除留样API响应数据: ${response.result}`)
      
      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse
        console.info(`删除留样API响应成功: ${resData.success}, 代码: ${resData.code}, 消息: ${resData.message}`)
        return resData.success === true || resData.code === 200
      }
      return false
    } catch (error) {
      console.error('删除留样API调用失败:', error)
      return false
    }
  }

  // 餐别代码转换
  private getMealCategoryCode(mealType: string): string {
    const mealMap: Record<string, string> = {
      '早餐': '0',
      '午餐': '1',
      '晚餐': '2',
      '早点': '3',
      '午点': '4',
      '晚点': '5',
      '其他': '6',
      '营养改善计划': '7'
    }
    return mealMap[mealType] || '6' // 默认为其他
  }

  // 留样类型代码转换
  private getSampleTypeCode(type: string): string {
    const typeMap: Record<string, string> = {
      '学生餐': '1',
      '教师餐': '2',
      '不区分': '0'
    }
    return typeMap[type] || '0' // 默认为不区分
  }

  // 更新API返回的留样数据到本地
  async updateSamplesFromApi(date: string, samples: SampleFormData[]): Promise<void> {
    const store = await this.getStore()
    const key = `sample_${date}`
    await store.put(key, JSON.stringify(samples))
    await store.flush()
  }
}

// 创建单例实例
let sampleService: SampleServiceClass | null = null

export function getSampleService(context: common.UIAbilityContext): SampleServiceClass {
  if (!sampleService) {
    sampleService = new SampleServiceClass(context)
  }
  return sampleService
} 