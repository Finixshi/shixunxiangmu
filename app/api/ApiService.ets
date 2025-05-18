import { CommonResponse, LoginRequest, UserInfo, SampleRecord, MorningCheckRecord, KitchenStaff, PageParams, PageResponse } from '../types/api';
import http from '@ohos.net.http';
import preferences from '@ohos.data.preferences';

const BASE_URL = 'http://your-api-base-url';
const STORAGE_KEY = 'app_storage';

export class ApiService {
  private static instance: ApiService;
  private token: string = '';
  private storage: preferences.Preferences;

  private constructor() {}

  public static getInstance(): ApiService {
    if (!ApiService.instance) {
      ApiService.instance = new ApiService();
    }
    return ApiService.instance;
  }

  /**
   * 初始化存储
   */
  public async init() {
    this.storage = await preferences.getPreferences(getContext(this), STORAGE_KEY);
    this.token = await this.storage.get('token', '') as string;
  }

  /**
   * 发送HTTP请求
   */
  private async request<T>(method: http.RequestMethod, path: string, data?: any): Promise<CommonResponse<T>> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        `${BASE_URL}${path}`,
        {
          method,
          header: {
            'Content-Type': 'application/json',
            'Authorization': this.token ? `Bearer ${this.token}` : '',
          },
          extraData: data ? JSON.stringify(data) : undefined,
        }
      );
      
      if (response.responseCode === 200) {
        return JSON.parse(response.result.toString()) as CommonResponse<T>;
      }
      throw new Error(`请求失败: ${response.responseCode}`);
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 用户登录
   */
  public async login(data: LoginRequest): Promise<CommonResponse<UserInfo>> {
    const response = await this.request<UserInfo>('POST', '/auth/login', data);
    if (response.code === 0 && response.data) {
      this.token = response.data.id;
      await this.storage.put('token', this.token);
      await this.storage.flush();
    }
    return response;
  }

  /**
   * 修改密码
   */
  public async changePassword(oldPassword: string, newPassword: string): Promise<CommonResponse<void>> {
    return this.request('POST', '/auth/change-password', { oldPassword, newPassword });
  }

  /**
   * 获取留样记录列表
   */
  public async getSampleRecords(params: PageParams): Promise<CommonResponse<PageResponse<SampleRecord>>> {
    return this.request('GET', '/sample-records', params);
  }

  /**
   * 添加留样记录
   */
  public async addSampleRecord(data: Omit<SampleRecord, 'id' | 'createdAt' | 'updatedAt'>): Promise<CommonResponse<SampleRecord>> {
    return this.request('POST', '/sample-records', data);
  }

  /**
   * 获取晨检记录列表
   */
  public async getMorningCheckRecords(params: PageParams): Promise<CommonResponse<PageResponse<MorningCheckRecord>>> {
    return this.request('GET', '/morning-checks', params);
  }

  /**
   * 添加晨检记录
   */
  public async addMorningCheckRecord(data: Omit<MorningCheckRecord, 'id' | 'createdAt' | 'updatedAt'>): Promise<CommonResponse<MorningCheckRecord>> {
    return this.request('POST', '/morning-checks', data);
  }

  /**
   * 获取厨房员工列表
   */
  public async getKitchenStaff(params: PageParams): Promise<CommonResponse<PageResponse<KitchenStaff>>> {
    return this.request('GET', '/kitchen-staff', params);
  }

  /**
   * 添加厨房员工
   */
  public async addKitchenStaff(data: Omit<KitchenStaff, 'id' | 'createdAt' | 'updatedAt'>): Promise<CommonResponse<KitchenStaff>> {
    return this.request('POST', '/kitchen-staff', data);
  }

  /**
   * 更新厨房员工信息
   */
  public async updateKitchenStaff(id: string, data: Partial<KitchenStaff>): Promise<CommonResponse<KitchenStaff>> {
    return this.request('PUT', `/kitchen-staff/${id}`, data);
  }

  /**
   * 删除厨房员工
   */
  public async deleteKitchenStaff(id: string): Promise<CommonResponse<void>> {
    return this.request('DELETE', `/kitchen-staff/${id}`);
  }
} 