import dataPreferences from '@ohos.data.preferences'
import { SampleFormData } from '../types'
import common from '@ohos.app.ability.common'

const STORE_NAME = 'SampleStore'

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
    const store = await this.getStore()
    const key = `sample_${sample.date}`
    const existingSamplesStr = await store.get(key, '[]') as string
    const existingSamples = JSON.parse(existingSamplesStr) as SampleFormData[]
    existingSamples.push(sample)
    await store.put(key, JSON.stringify(existingSamples))
    await store.flush()
  }

  // 更新留样数据
  async updateSample(sample: SampleFormData, index: number): Promise<void> {
    const store = await this.getStore()
    const key = `sample_${sample.date}`
    const samplesStr = await store.get(key, '[]') as string
    const samples = JSON.parse(samplesStr) as SampleFormData[]
    samples[index] = sample
    await store.put(key, JSON.stringify(samples))
    await store.flush()
  }

  // 删除留样数据
  async deleteSample(date: string, index: number): Promise<void> {
    const store = await this.getStore()
    const key = `sample_${date}`
    const samplesStr = await store.get(key, '[]') as string
    const samples = JSON.parse(samplesStr) as SampleFormData[]
    samples.splice(index, 1)
    await store.put(key, JSON.stringify(samples))
    await store.flush()
  }

  // 获取指定日期的留样数据
  async getSamplesByDate(date: string): Promise<SampleFormData[]> {
    const store = await this.getStore()
    const key = `sample_${date}`
    const samplesStr = await store.get(key, '[]') as string
    return JSON.parse(samplesStr) as SampleFormData[]
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