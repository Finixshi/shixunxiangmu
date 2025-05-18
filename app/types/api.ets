/**
 * 通用响应格式
 */
export interface CommonResponse<T = any> {
  code: number;
  message: string;
  data: T;
}

/**
 * 分页查询参数
 */
export interface PageParams {
  page: number;
  pageSize: number;
}

/**
 * 分页响应数据
 */
export interface PageResponse<T> {
  total: number;
  list: T[];
}

/**
 * 用户登录请求
 */
export interface LoginRequest {
  username: string;
  password: string;
}

/**
 * 用户信息
 */
export interface UserInfo {
  id: string;
  username: string;
  name: string;
  role: string;
  avatar?: string;
}

/**
 * 留样记录
 */
export interface SampleRecord {
  id: string;
  date: string;
  foodName: string;
  quantity: number;
  keeper: string;
  remark?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * 晨检记录
 */
export interface MorningCheckRecord {
  id: string;
  date: string;
  staffId: string;
  staffName: string;
  temperature: number;
  healthStatus: string;
  remark?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * 厨房员工信息
 */
export interface KitchenStaff {
  id: string;
  name: string;
  gender: string;
  phone: string;
  position: string;
  healthCertificate: string;
  certificateExpiry: string;
  status: string;
  remark?: string;
  createdAt: string;
  updatedAt: string;
} 