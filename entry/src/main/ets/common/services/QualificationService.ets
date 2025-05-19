import http from '@ohos.net.http';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import Observable from '@ohos.util';

const STORE_NAME = 'QualificationStore';
const API_BASE_URL = 'https://api.suoeryun.com/ifood';

// API请求数据类
export class QualificationRequestData {
  id?: string;
  qualificationName: string;
  issueDate: string;
  qualificationType: string;
  issuingAuthority: string;
  isLongTermValid: boolean;
  remarks?: string;
  imagePath?: string;

  constructor(
    qualificationName: string = '',
    issueDate: string = '',
    qualificationType: string = '',
    issuingAuthority: string = '',
    isLongTermValid: boolean = true,
    remarks: string = '',
    imagePath: string = '',
    id?: string
  ) {
    this.qualificationName = qualificationName;
    this.issueDate = issueDate;
    this.qualificationType = qualificationType;
    this.issuingAuthority = issuingAuthority;
    this.isLongTermValid = isLongTermValid;
    this.remarks = remarks;
    this.imagePath = imagePath;
    this.id = id;
  }
}

// 资质信息类
export class QualificationInfo {
  id?: string;
  qualificationName: string;
  issueDate: string;
  qualificationType: string;
  issuingAuthority: string;
  isLongTermValid: boolean;
  remarks?: string;
  imagePath?: string;
  status?: 'pending' | 'approved' | 'rejected';
  createTime?: string;
  updateTime?: string;

  constructor(
    qualificationName: string = '',
    issueDate: string = '',
    qualificationType: string = '',
    issuingAuthority: string = '',
    isLongTermValid: boolean = true,
    remarks: string = '',
    imagePath: string = '',
    id?: string,
    status?: 'pending' | 'approved' | 'rejected',
    createTime?: string,
    updateTime?: string
  ) {
    this.qualificationName = qualificationName;
    this.issueDate = issueDate;
    this.qualificationType = qualificationType;
    this.issuingAuthority = issuingAuthority;
    this.isLongTermValid = isLongTermValid;
    this.remarks = remarks;
    this.imagePath = imagePath;
    this.id = id;
    this.status = status;
    this.createTime = createTime;
    this.updateTime = updateTime;
  }

  toRequestData(): QualificationRequestData {
    return new QualificationRequestData(
      this.qualificationName,
      this.issueDate,
      this.qualificationType,
      this.issuingAuthority,
      this.isLongTermValid,
      this.remarks,
      this.imagePath,
      this.id
    );
  }
}

// API响应数据类型
type ApiResponseData = boolean | PageResponse | QualificationInfo | null;

// API响应接口
interface ApiResponse {
  success: boolean;
  code: number;
  message: string;
  result: ApiResponseData;
  timestamp: number;
}

// 分页响应接口
interface PageResponse {
  records: QualificationInfo[];
  total: number;
  size: number;
  current: number;
  pages: number;
}

export class QualificationService {
  private context: common.UIAbilityContext;
  private static instance: QualificationService;

  private constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  public static getInstance(context: common.UIAbilityContext): QualificationService {
    if (!QualificationService.instance) {
      QualificationService.instance = new QualificationService(context);
    }
    return QualificationService.instance;
  }

  private async getStore(): Promise<preferences.Preferences> {
    return await preferences.getPreferences(this.context, STORE_NAME);
  }

  // 添加资质信息
  async addQualification(data: QualificationInfo): Promise<boolean> {
    try {
      const httpRequest = http.createHttp();
      const requestData = data.toRequestData();
      const response = await httpRequest.request(
        `${API_BASE_URL}/jeecg-school/school/xxQualification/add`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
          },
          extraData: JSON.stringify(requestData)
        }
      );

      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse;
        return resData.success;
      }
      return false;
    } catch (error) {
      console.error('添加资质信息失败:', error);
      return false;
    }
  }

  // 更新资质信息
  async updateQualification(data: QualificationInfo): Promise<boolean> {
    try {
      const httpRequest = http.createHttp();
      const requestData = data.toRequestData();
      const response = await httpRequest.request(
        `${API_BASE_URL}/jeecg-school/school/xxQualification/edit`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
          },
          extraData: JSON.stringify(requestData)
        }
      );

      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse;
        return resData.success;
      }
      return false;
    } catch (error) {
      console.error('更新资质信息失败:', error);
      return false;
    }
  }

  // 删除资质信息
  async deleteQualification(id: string): Promise<boolean> {
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        `${API_BASE_URL}/jeecg-school/school/xxQualification/delete?id=${id}`,
        {
          method: http.RequestMethod.DELETE,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
          }
        }
      );

      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse;
        return resData.success;
      }
      return false;
    } catch (error) {
      console.error('删除资质信息失败:', error);
      return false;
    }
  }

  // 获取资质信息列表
  async getQualificationList(status: 'pending' | 'approved' | 'rejected' = 'pending', page: number = 1, pageSize: number = 10): Promise<PageResponse | null> {
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        `${API_BASE_URL}/jeecg-school/school/xxQualification/list?status=${status}&page=${page}&pageSize=${pageSize}`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
          }
        }
      );

      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse;
        if (resData.success && resData.result) {
          return resData.result as PageResponse;
        }
      }
      return null;
    } catch (error) {
      console.error('获取资质信息列表失败:', error);
      return null;
    }
  }

  // 获取资质信息详情
  async getQualificationDetail(id: string): Promise<QualificationInfo | null> {
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        `${API_BASE_URL}/jeecg-school/school/xxQualification/queryById?id=${id}`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Tenant-Id': '10021011',
            'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwd2QiOiI5NzJiNzBjMWQwNGQ3YTY0ZGFjYzUwYTY3MzkyOWRlZSIsImV4cCI6MTc0NzYzNzg5MSwidXNlcm5hbWUiOiIxODk5MTI3NDI2MSJ9.ucMMMTv2a3bC4h_pqUcB1URENVmPy1Q2MD3FWPdgSFY'
          }
        }
      );

      if (response.responseCode === 200) {
        const resData = JSON.parse(response.result as string) as ApiResponse;
        if (resData.success && resData.result) {
          return resData.result as QualificationInfo;
        }
      }
      return null;
    } catch (error) {
      console.error('获取资质信息详情失败:', error);
      return null;
    }
  }
}

// 导出获取服务实例的函数
export function getQualificationService(context: common.UIAbilityContext): QualificationService {
  return QualificationService.getInstance(context);
} 