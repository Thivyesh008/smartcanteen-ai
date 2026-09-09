import { supabase } from '@/lib/supabase';
import type { DailyFoodData, Prediction, SurplusFood, SurplusStatus, MealType } from '@/types';

export async function fetchDailyData(): Promise<DailyFoodData[]> {
  const { data, error } = await supabase.from('daily_food_data').select('*').order('date', { ascending: false });
  if (error) throw error;
  return (data ?? []) as DailyFoodData[];
}

export async function createDailyData(entry: Omit<DailyFoodData, 'id' | 'created_at'>): Promise<DailyFoodData> {
  const { data, error } = await supabase.from('daily_food_data').insert(entry).select().maybeSingle();
  if (error) throw error;
  if (!data) throw new Error('Could not save daily data');
  return data as DailyFoodData;
}

export async function fetchPredictions(): Promise<Prediction[]> {
  const { data, error } = await supabase.from('predictions').select('*').order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as Prediction[];
}

export async function createPrediction(prediction: Omit<Prediction, 'id' | 'created_at'>): Promise<Prediction> {
  const { data, error } = await supabase.from('predictions').insert(prediction).select().maybeSingle();
  if (error) throw error;
  if (!data) throw new Error('Could not save prediction');
  return data as Prediction;
}

export async function fetchSurplus(): Promise<SurplusFood[]> {
  const { data, error } = await supabase.from('surplus_food').select('*').order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as SurplusFood[];
}

export async function createSurplus(entry: Omit<SurplusFood, 'id' | 'created_at'>): Promise<SurplusFood> {
  const { data, error } = await supabase.from('surplus_food').insert(entry).select().maybeSingle();
  if (error) throw error;
  if (!data) throw new Error('Could not create surplus alert');
  return data as SurplusFood;
}

export async function updateSurplusStatus(id: string, status: SurplusStatus): Promise<void> {
  const { error } = await supabase.from('surplus_food').update({ status }).eq('id', id);
  if (error) throw error;
}

export function isMealType(value: string): value is MealType {
  return ['Breakfast', 'Lunch', 'Snacks', 'Dinner'].includes(value);
}
