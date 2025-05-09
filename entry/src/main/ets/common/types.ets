export interface SampleFormData {
  location: string
  date: string
  type: string
  mealType: string
  temperature: number
  foodName: string
  weight: string
  staff: string
  disposalTime: string
  images: string[]
  cabinetImages: string[]
  notes: string
}

export interface RecipeData {
  date: string          // 食谱日期
  name: string          // 食谱名称
  mealType: string      // 餐别（早点、午餐、晚点等）
  diningType: string    // 用餐类型
  canteen: string       // 餐厅
  images?: string[]     // 可选的图片数组
}

export interface SelectOption {
  value: string
}

export interface DatePickerResult {
  year: number
  month: number
  day: number
}

export interface TimePickerResult {
  hour: number
  minute: number
}

export interface RecipeRouteParams {
  editRecipe?: RecipeData
  editIndex?: number
  selectedDate?: string
} 