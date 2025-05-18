import promptAction from '@ohos.promptAction';

export class CommonUtils {
  /**
   * 显示提示消息
   */
  static showToast(message: string, duration: number = 2000) {
    promptAction.showToast({
      message,
      duration,
    });
  }

  /**
   * 格式化日期
   */
  static formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 格式化时间
   */
  static formatTime(date: Date): string {
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  /**
   * 验证手机号
   */
  static isValidPhone(phone: string): boolean {
    return /^1[3-9]\d{9}$/.test(phone);
  }

  /**
   * 验证身份证号
   */
  static isValidIdCard(idCard: string): boolean {
    return /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/.test(idCard);
  }

  /**
   * 深拷贝对象
   */
  static deepClone<T>(obj: T): T {
    return JSON.parse(JSON.stringify(obj));
  }

  /**
   * 防抖函数
   */
  static debounce(func: Function, wait: number) {
    let timeout: number | null = null;
    return function (...args: any[]) {
      if (timeout !== null) {
        clearTimeout(timeout);
      }
      timeout = setTimeout(() => {
        func.apply(this, args);
      }, wait);
    };
  }

  /**
   * 节流函数
   */
  static throttle(func: Function, wait: number) {
    let previous = 0;
    return function (...args: any[]) {
      const now = Date.now();
      if (now - previous > wait) {
        func.apply(this, args);
        previous = now;
      }
    };
  }
} 