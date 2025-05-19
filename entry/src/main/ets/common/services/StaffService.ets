import dataPreferences from '@ohos.data.preferences'
import { Staff } from '../StaffModel'
import common from '@ohos.app.ability.common'
import http from '@ohos.net.http'

const STORE_NAME = 'StaffStore'
const API_BASE_URL = 'https://api.suoeryun.com/ifood'
const TENANT_ID = '10021011'
const API_TOKEN = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiIyZjg5NWM4NDI2MWFlNzJiYmUyMjVkMjllOWJhZjVjZCIsImV4cCI6MTc0NzYxOTExNiwidXNlcm5hbWUiOiIxNTUwMjkzMzY3MyJ9.Zsc8fNnV0rlF17dLSv1RpO3ecWn96FOYQ7pH9Y0JJ7Q'
// 固定的学校和单位ID
const SCHOOL_ID = '1651892693627330561'
const UNIT_ID = '1651892693627330561'

// API响应中的员工记录类型
interface ApiStaffRecord {
  id: number
  schoolId: string
  schoolName: string
  unitId: string
  unitName: string
  userName: string
  idCard: string
  portraitPhoto: string | null
  position: string
  tel: string
  type: string
  type_dictText: string
  licenceIssuing: string | null
  healthNumber: string
  healthUrl: string | null
  healthStartTime: string
  healthEndTime: string
  photoQualification: string | null
  remark: string | null
  inspectionType: number
  version: number
  canteenId: string | null
  wxopenId: string | null
  tenantId: string
  demandUnitIds: string | null
}

// API分页响应类型
interface ApiPageResult {
  records: ApiStaffRecord[]
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
  result: ApiPageResult | null | string
  timestamp: number
}

// API请求数据类型
interface ApiStaffRequestData {
  id?: number
  unitName: string
  unitId: string
  userName: string
  position: string
  tel: string
  type: string
  healthStartTime: string
  healthEndTime: string
  healthUrl: string
  portraitPhoto: string
  remark: string
  version: number
  inspectionType?: number
  canteenId?: null
  schoolId?: string
  schoolName?: string
}

export class StaffServiceClass {
  private context: common.UIAbilityContext

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  private async getStore(): Promise<dataPreferences.Preferences> {
    return await dataPreferences.getPreferences(this.context, STORE_NAME)
  }

  // 获取员工列表
  async getStaffList(page: number = 1, pageSize: number = 10): Promise<Staff[]> {
    try {
      // 尝试从API获取数据
      const apiStaff = await this.fetchStaffFromApi(page, pageSize)
      if (apiStaff && apiStaff.length > 0) {
        // 更新本地存储
        await this.updateStaffFromApi(apiStaff)
        return apiStaff
      }
    } catch (error) {
      console.error('从API获取员工数据失败:', error)
    }
    
    // 如果API获取失败，从本地获取
    const store = await this.getStore()
    const key = 'staff_list'
    const staffListStr = await store.get(key, '[]') as string
    return JSON.parse(staffListStr) as Staff[]
  }

  // 添加员工
  async addStaff(staff: Staff): Promise<boolean> {
    // 先调用API添加员工
    const apiSuccess = await this.addStaffToApi(staff)
    
    if (apiSuccess) {
      // API成功，尝试获取最新的员工列表并更新本地
      await this.getStaffList()
      return true
    } else {
      // API失败，但仍然保存到本地
      const store = await this.getStore()
      const key = 'staff_list'
      const existingStaffStr = await store.get(key, '[]') as string
      const existingStaff = JSON.parse(existingStaffStr) as Staff[]
      
      // 生成一个临时ID
      if (!staff.id) {
        staff.id = Date.now()
      }
      
      existingStaff.push(staff)
      await store.put(key, JSON.stringify(existingStaff))
      await store.flush()
      return true
    }
  }

  // 更新员工
  async updateStaff(staff: Staff): Promise<boolean> {
    // 确保有ID
    if (!staff.id) {
      throw new Error('员工ID不能为空')
    }

    // 先调用API更新员工
    const apiSuccess = await this.updateStaffToApi(staff)
    
    if (apiSuccess) {
      // API成功，尝试获取最新的员工列表并更新本地
      await this.getStaffList()
      return true
    } else {
      // API失败，但仍然更新本地
      const store = await this.getStore()
      const key = 'staff_list'
      const staffListStr = await store.get(key, '[]') as string
      const staffList = JSON.parse(staffListStr) as Staff[]
      
      const index = staffList.findIndex(item => item.id === staff.id)
      if (index >= 0) {
        staffList[index] = staff
        await store.put(key, JSON.stringify(staffList))
        await store.flush()
        return true
      } else {
        throw new Error('未找到要更新的员工')
      }
    }
  }

  // 删除员工
  async deleteStaff(id: number): Promise<boolean> {
    // 先调用API删除员工
    const apiSuccess = await this.deleteStaffFromApi(id)
    
    if (apiSuccess) {
      // API成功，尝试获取最新的员工列表并更新本地
      await this.getStaffList()
      return true
    } else {
      // API失败，但仍然从本地删除
      const store = await this.getStore()
      const key = 'staff_list'
      const staffListStr = await store.get(key, '[]') as string
      const staffList = JSON.parse(staffListStr) as Staff[]
      
      const newStaffList = staffList.filter(item => item.id !== id)
      await store.put(key, JSON.stringify(newStaffList))
      await store.flush()
      return true
    }
  }

  // 从API获取员工列表
  private async fetchStaffFromApi(page: number = 1, pageSize: number = 10): Promise<Staff[]> {
    try {
      const httpRequest = http.createHttp()
      // 确保URL格式正确
      const url = `${API_BASE_URL}/jeecg-school/school/xxUnitUser/list?pageNo=${page}&pageSize=${pageSize}&schoolId=${SCHOOL_ID}`
      
      // 添加日志调试
      console.info(`获取员工列表API URL: ${url}`)
      
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': TENANT_ID,
            // 使用有效token
            'X-Access-Token': API_TOKEN
          }
        }
      )
      
      // 打印响应信息
      console.info(`获取员工列表API响应状态码: ${response.responseCode}`)
      if (response.result) {
        console.info(`获取员工列表API响应数据: ${response.result.toString().substring(0, 200)}...`)
      }
      
      if (response.responseCode === 200) {
        const apiResponse = JSON.parse(response.result as string) as ApiResponse
        
        // 打印API响应
        console.info(`API响应成功: ${apiResponse.success}, 代码: ${apiResponse.code}`)
        
        // 检查是否有结果且结果是ApiPageResult类型
        if (apiResponse.success && apiResponse.result) {
          // 尝试将结果转换为ApiPageResult类型
          const resultObj = apiResponse.result;
          // 检查是否有records属性
          if (typeof resultObj === 'object' && resultObj !== null) {
            const pageResult = resultObj as ApiPageResult;
            if (pageResult.records && Array.isArray(pageResult.records)) {
              // 打印获取到的记录数
              console.info(`获取到 ${pageResult.records.length} 条员工记录`)
              
              // 将API返回的数据转换为应用内的数据格式
              return pageResult.records.map(item => this.convertApiStaffToLocal(item))
            }
          }
          console.info('API返回成功，但没有找到员工记录')
        }
      }
      return []
    } catch (error) {
      console.error('从API获取员工数据失败:', error)
      return []
    }
  }

  // 调用添加员工API
  private async addStaffToApi(staff: Staff): Promise<boolean> {
    try {
      const httpRequest = http.createHttp()
      const url = `${API_BASE_URL}/jeecg-school/school/xxUnitUser/add`
      
      // 添加日志调试
      console.info(`添加员工API URL: ${url}`)
      
      // 转换为API格式
      const apiData: ApiStaffRequestData = {
        unitName: staff.department,
        unitId: UNIT_ID,
        schoolId: SCHOOL_ID,
        schoolName: staff.department,
        userName: staff.name,
        position: staff.position,
        tel: staff.phone,
        type: staff.status === '在职' ? '1' : '2',
        healthStartTime: staff.issueDate,
        healthEndTime: staff.expiryDate,
        healthUrl: staff.healthCert || "https://admin.suoeryun.com/pcUpload/043015131332-32.png",
        portraitPhoto: "https://admin.suoeryun.com/pcUpload/043015131332-32.png",
        remark: "",
        version: 0
      }
      
      // 打印请求数据以便调试
      console.info(`添加员工API请求数据: ${JSON.stringify(apiData)}`)
      
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': TENANT_ID,
            'X-Access-Token': API_TOKEN
          },
          extraData: JSON.stringify(apiData)
        }
      )
      
      // 打印响应信息
      console.info(`添加员工API响应状态码: ${response.responseCode}`)
      console.info(`添加员工API响应数据: ${response.result}`)
      
      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse
        console.info(`添加员工API响应成功: ${resData.success}, 代码: ${resData.code}, 消息: ${resData.message}`)
        return resData.success === true || resData.code === 200
      }
      return false
    } catch (error) {
      console.error('添加员工API调用失败:', error)
      return false
    }
  }

  // 调用更新员工API
  private async updateStaffToApi(staff: Staff): Promise<boolean> {
    try {
      const httpRequest = http.createHttp()
      const url = `${API_BASE_URL}/jeecg-school/school/xxUnitUser/edit`
      
      // 添加日志调试
      console.info(`更新员工API URL: ${url}`)
      
      // 转换为API格式
      const apiData: ApiStaffRequestData = {
        id: staff.id,
        unitName: staff.department,
        unitId: UNIT_ID,
        schoolId: SCHOOL_ID,
        schoolName: staff.department,
        userName: staff.name,
        position: staff.position,
        tel: staff.phone,
        type: staff.status === '在职' ? '1' : '2',
        healthStartTime: staff.issueDate,
        healthEndTime: staff.expiryDate,
        healthUrl: staff.healthCert || "https://admin.suoeryun.com/pcUpload/043015131332-32.png",
        portraitPhoto: "https://admin.suoeryun.com/pcUpload/043015131332-32.png",
        remark: "",
        inspectionType: 0,
        version: 0,
        canteenId: null
      }
      
      // 打印请求数据以便调试
      console.info(`更新员工API请求数据: ${JSON.stringify(apiData)}`)
      
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': TENANT_ID,
            'X-Access-Token': API_TOKEN
          },
          extraData: JSON.stringify(apiData)
        }
      )
      
      // 打印响应信息
      console.info(`更新员工API响应状态码: ${response.responseCode}`)
      console.info(`更新员工API响应数据: ${response.result}`)
      
      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse
        console.info(`更新员工API响应成功: ${resData.success}, 代码: ${resData.code}, 消息: ${resData.message}`)
        return resData.success === true || resData.code === 200
      }
      return false
    } catch (error) {
      console.error('更新员工API调用失败:', error)
      return false
    }
  }

  // 调用删除员工API
  private async deleteStaffFromApi(id: number): Promise<boolean> {
    try {
      const httpRequest = http.createHttp()
      const url = `${API_BASE_URL}/jeecg-school/school/xxUnitUser/delete?id=${id}`
      
      // 添加日志调试
      console.info(`删除员工API URL: ${url}`)
      
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.DELETE,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': TENANT_ID,
            'X-Access-Token': API_TOKEN
          }
        }
      )
      
      // 打印响应信息
      console.info(`删除员工API响应状态码: ${response.responseCode}`)
      console.info(`删除员工API响应数据: ${response.result}`)
      
      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse
        console.info(`删除员工API响应成功: ${resData.success}, 代码: ${resData.code}, 消息: ${resData.message}`)
        return resData.success === true || resData.code === 200
      }
      return false
    } catch (error) {
      console.error('删除员工API调用失败:', error)
      return false
    }
  }

  // 将API返回的员工数据转换为本地格式
  private convertApiStaffToLocal(apiStaff: ApiStaffRecord): Staff {
    return new Staff(
      apiStaff.userName,
      apiStaff.position,
      apiStaff.unitName,
      apiStaff.tel,
      apiStaff.type === '1' ? '在职' : '离职',
      apiStaff.healthStartTime,
      apiStaff.healthEndTime,
      apiStaff.healthUrl || '',
      apiStaff.id
    )
  }

  // 更新API返回的员工数据到本地
  async updateStaffFromApi(staffList: Staff[]): Promise<void> {
    const store = await this.getStore()
    const key = 'staff_list'
    await store.put(key, JSON.stringify(staffList))
    await store.flush()
  }
}

// 创建单例实例
let staffService: StaffServiceClass | null = null

export function getStaffService(context: common.UIAbilityContext): StaffServiceClass {
  if (!staffService) {
    staffService = new StaffServiceClass(context)
  }
  return staffService
} 