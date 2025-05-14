import dataPreferences from '@ohos.data.preferences'
import { RecipeData } from '../types'
import common from '@ohos.app.ability.common'

const STORE_NAME = 'RecipeStore'

export class RecipeServiceClass {
  private context: common.UIAbilityContext

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  private async getStore(): Promise<dataPreferences.Preferences> {
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
    console.info(`尝试删除食谱: 日期=${date}, 索引=${index}`);
    const store = await this.getStore()
    const key = `recipe_${date}`
    const recipesStr = await store.get(key, '[]') as string
    console.info(`获取到食谱数据: ${recipesStr.substring(0, 100)}...`);
    
    const recipes = JSON.parse(recipesStr) as RecipeData[]
    console.info(`解析到 ${recipes.length} 条食谱数据`);
    
    // 删除食谱并保存
    if (index >= 0 && index < recipes.length) {
      console.info(`删除索引 ${index} 的食谱: ${JSON.stringify(recipes[index])}`);
      recipes.splice(index, 1)
      await store.put(key, JSON.stringify(recipes))
      await store.flush()
      console.info('成功删除食谱并保存');
    } else {
      console.error(`删除失败，索引 ${index} 超出范围 (0-${recipes.length-1})`);
    }
  }
  
  // 通过名称删除食谱
  async deleteRecipeByName(date: string, name: string): Promise<boolean> {
    console.info(`尝试通过名称删除食谱: 日期=${date}, 名称=${name}`);
    const store = await this.getStore()
    const key = `recipe_${date}`
    const recipesStr = await store.get(key, '[]') as string
    const recipes = JSON.parse(recipesStr) as RecipeData[]
    
    // 查找名称匹配的食谱
    const index = recipes.findIndex(recipe => recipe.name === name)
    if (index !== -1) {
      console.info(`找到名称为 "${name}" 的食谱，索引为 ${index}`);
      recipes.splice(index, 1)
      await store.put(key, JSON.stringify(recipes))
      await store.flush()
      console.info('成功删除食谱并保存');
      return true
    } else {
      console.error(`未找到名称为 "${name}" 的食谱`);
      return false
    }
  }

  // 通过ID删除食谱
  async deleteRecipeById(date: string, id: string): Promise<boolean> {
    if (!id) {
      console.error('删除失败，ID为空');
      return false;
    }
    
    console.info(`尝试通过ID删除食谱: 日期=${date}, ID=${id}`);
    const store = await this.getStore()
    const key = `recipe_${date}`
    const recipesStr = await store.get(key, '[]') as string
    const recipes = JSON.parse(recipesStr) as RecipeData[]
    
    // 查找ID匹配的食谱
    const index = recipes.findIndex(recipe => recipe.id === id)
    if (index !== -1) {
      console.info(`找到ID为 "${id}" 的食谱，索引为 ${index}`);
      recipes.splice(index, 1)
      await store.put(key, JSON.stringify(recipes))
      await store.flush()
      console.info('成功删除食谱并保存');
      return true
    } else {
      console.error(`未找到ID为 "${id}" 的食谱`);
      return false
    }
  }

  // 获取指定日期的食谱数据
  async getRecipesByDate(date: string): Promise<RecipeData[]> {
    const store = await this.getStore()
    const key = `recipe_${date}`
    const recipesStr = await store.get(key, '[]') as string
    return JSON.parse(recipesStr) as RecipeData[]
  }

  // 从API更新食谱数据
  async updateRecipesFromApi(date: string, apiRecipes: RecipeData[]): Promise<void> {
    if (apiRecipes.length === 0) {
      return;
    }
    
    const store = await this.getStore()
    const key = `recipe_${date}`
    const localRecipesStr = await store.get(key, '[]') as string
    let localRecipes = JSON.parse(localRecipesStr) as RecipeData[]
    
    // 合并API数据和本地数据，根据菜品名称、餐别和用餐类型判断是否为相同记录
    for (const apiRecipe of apiRecipes) {
      const existingIndex = localRecipes.findIndex(
        local => local.name === apiRecipe.name && 
                local.mealType === apiRecipe.mealType &&
                local.diningType === apiRecipe.diningType
      );
      
      if (existingIndex >= 0) {
        // 更新已有记录 - 不使用扩展运算符
        const existingItem = localRecipes[existingIndex];
        // 逐一复制属性而不使用扩展运算符
        localRecipes[existingIndex] = {
          id: apiRecipe.id || existingItem.id,  // 保留id字段
          date: apiRecipe.date || existingItem.date,
          name: apiRecipe.name || existingItem.name,
          mealType: apiRecipe.mealType || existingItem.mealType,
          diningType: apiRecipe.diningType || existingItem.diningType,
          canteen: apiRecipe.canteen || existingItem.canteen,
          images: apiRecipe.images || existingItem.images
        };
      } else {
        // 添加新记录
        localRecipes.push(apiRecipe);
      }
    }
    
    // 保存更新后的数据
    await store.put(key, JSON.stringify(localRecipes))
    await store.flush()
    
    console.info(`从API更新了 ${date} 的 ${apiRecipes.length} 条食谱数据`);
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