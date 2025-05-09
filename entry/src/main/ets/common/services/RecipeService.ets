import dataPreferences from '@ohos.data.preferences'
import { RecipeData } from '../types'
import common from '@ohos.app.ability.common'

const STORE_NAME = 'RecipeStore'

export class RecipeServiceClass {
  private context: common.UIAbilityContext

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  private async getStore() {
    return await dataPreferences.getPreferences(this.context, STORE_NAME)
  }

  // 保存食谱数据
  async saveRecipe(recipe: RecipeData): Promise<void> {
    const store = await this.getStore()
    const key = `recipe_${recipe.date}`
    const existingRecipesStr = await store.get(key, '[]') as string
    const existingRecipes = JSON.parse(existingRecipesStr) as RecipeData[]
    existingRecipes.push(recipe)
    await store.put(key, JSON.stringify(existingRecipes))
    await store.flush()
  }

  // 更新食谱数据
  async updateRecipe(recipe: RecipeData, index: number): Promise<void> {
    const store = await this.getStore()
    const key = `recipe_${recipe.date}`
    const recipesStr = await store.get(key, '[]') as string
    const recipes = JSON.parse(recipesStr) as RecipeData[]
    recipes[index] = recipe
    await store.put(key, JSON.stringify(recipes))
    await store.flush()
  }

  // 删除食谱数据
  async deleteRecipe(date: string, index: number): Promise<void> {
    const store = await this.getStore()
    const key = `recipe_${date}`
    const recipesStr = await store.get(key, '[]') as string
    const recipes = JSON.parse(recipesStr) as RecipeData[]
    recipes.splice(index, 1)
    await store.put(key, JSON.stringify(recipes))
    await store.flush()
  }

  // 获取指定日期的食谱数据
  async getRecipesByDate(date: string): Promise<RecipeData[]> {
    const store = await this.getStore()
    const key = `recipe_${date}`
    const recipesStr = await store.get(key, '[]') as string
    return JSON.parse(recipesStr) as RecipeData[]
  }
}

// 创建单例实例
let recipeService: RecipeServiceClass | null = null

export function getRecipeService(context: common.UIAbilityContext): RecipeServiceClass {
  if (!recipeService) {
    recipeService = new RecipeServiceClass(context)
  }
  return recipeService
} 