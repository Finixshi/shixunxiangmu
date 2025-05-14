import http from '@ohos.net.http'
import { TimePickerResult } from '../types'

/**
 * HTTP请求头接口
 */
export interface HttpRequestHeader {
  'Content-Type': string;
  'Tenant-Id': string;
  'X-Access-Token': string;
}

/**
 * API响应接口
 */
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  code: number;
  result: T;
  timestamp: number;
}

/**
 * 时间选择参数接口
 */
export interface TimePickerParams {
  selected: Date;
  useMilitaryTime: boolean;
  onAccept: (value: TimePickerResult) => void;
} 

/**
 * 字体参数接口
 */
export interface FontParams {
  size: number;
  weight: FontWeight;
} 