import type { DailyFoodData, MealType, PredictionResult } from '@/types';
import { clamp, mean, round, stdDev, getDayOfWeek } from '@/lib/utils';

interface PredictionInput {
  date: string;
  expectedStudents: number;
  mealType: MealType;
}

export function calculatePrediction(history: DailyFoodData[], input: PredictionInput): PredictionResult {
  const matching = history.filter((row) => row.meal_type === input.mealType);
  const day = getDayOfWeek(input.date);
  const sameDay = matching.filter((row) => getDayOfWeek(row.date) === day);
  const recent = matching.slice(0, 14);
  const source = sameDay.length >= 3 ? sameDay : recent;
  const ratioValues = source.filter((row) => row.students_present > 0).map((row) => row.meals_consumed / row.students_present);
  const ratios = ratioValues.length ? ratioValues : [0.72];
  const weightedRatio = ratios.slice(0, 7).reduce((sum, ratio, index) => sum + ratio * (7 - index), 0) / Math.min(ratios.length, 7) / 4;
  const ratio = clamp(weightedRatio, 0.18, 1.1);
  const predictedMeals = Math.round(input.expectedStudents * ratio);
  const historicalAverage = Math.round(mean(source.map((row) => row.meals_consumed)) || predictedMeals);
  const spread = stdDev(source.map((row) => row.meals_consumed));
  const confidence = clamp(Math.round(72 + Math.min(source.length, 30) * 0.55 - Math.min(spread / Math.max(historicalAverage, 1) * 20, 18)), 58, 96);
  const avgWaste = mean(source.map((row) => Number(row.leftover_kg)));
  const recommendedPreparation = Math.ceil(predictedMeals * 1.035 / 5) * 5;
  const expectedWaste = round(Math.max(2, avgWaste * (recommendedPreparation / Math.max(historicalAverage, 1)) * 0.72), 1);
  const method = source.length >= 10 ? 'weighted_average' : source.length >= 3 ? 'fallback' : 'fallback';
  const factors = [
    `${source.length} ${input.mealType.toLowerCase()} records analyzed`,
    sameDay.length >= 3 ? 'Matched with this day of week' : 'Using recent consumption pattern',
    `Attendance adjusted to ${input.expectedStudents.toLocaleString()} students`,
  ];
  return { expectedStudents: input.expectedStudents, predictedMeals, recommendedPreparation, expectedWaste, confidence, method, historicalAverage, factors };
}
