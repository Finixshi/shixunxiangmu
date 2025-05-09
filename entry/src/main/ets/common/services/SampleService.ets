import dataPreferences from '@ohos.data.preferences'
import { SampleFormData } from '../types'

const STORE_NAME = 'SampleStore'

class SampleServiceClass {
  private context: Context

  constructor(context: Context) {
    this.context = context
  }

  private async getStore() {
    return await dataPreferences.getPreferences(this.context, STORE_NAME)
  }

  // 保存留样数据
  async saveSample(sample: SampleFormData): Promise<void> {
    const store = await this.getStore()
    const key = `sample_${sample.date}`
    const existingSamplesStr = await store.get(key, '[]')
    const existingSamples = JSON.parse(existingSamplesStr as string) as SampleFormData[]
    existingSamples.push(sample)
    await store.put(key, JSON.stringify(existingSamples))
    await store.flush()
  }

  // 更新留样数据
  async updateSample(sample: SampleFormData, index: number): Promise<void> {
    const store = await this.getStore()
    const key = `sample_${sample.date}`
    const samplesStr = await store.get(key, '[]')
    const samples = JSON.parse(samplesStr as string) as SampleFormData[]
    samples[index] = sample
    await store.put(key, JSON.stringify(samples))
    await store.flush()
  }

  // 删除留样数据
  async deleteSample(date: string, index: number): Promise<void> {
    const store = await this.getStore()
    const key = `sample_${date}`
    const samplesStr = await store.get(key, '[]')
    const samples = JSON.parse(samplesStr as string) as SampleFormData[]
    samples.splice(index, 1)
    await store.put(key, JSON.stringify(samples))
    await store.flush()
  }

  // 获取指定日期的留样数据
  async getSamplesByDate(date: string): Promise<SampleFormData[]> {
    const store = await this.getStore()
    const key = `sample_${date}`
    const samplesStr = await store.get(key, '[]')
    return JSON.parse(samplesStr as string) as SampleFormData[]
  }
}

// 创建单例实例
let sampleService: SampleServiceClass | null = null

export function getSampleService(context: Context): SampleServiceClass {
  if (!sampleService) {
    sampleService = new SampleServiceClass(context)
  }
  return sampleService
} 