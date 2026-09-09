export type Role = 'staff' | 'admin';

export type MealType = 'Breakfast' | 'Lunch' | 'Snacks' | 'Dinner';

export type SurplusStatus = 'Available' | 'Reserved' | 'Collected' | 'Expired';

export interface User {
  id: string;
  name: string;
  role: Role;
  email: string;
  created_at?: string;
}

export interface DailyFoodData {
  id: string;
  date: string;
  students_present: number;
  meals_prepared: number;
  meals_consumed: number;
  leftover_kg: number;
  meal_type: MealType;
  notes: string | null;
  created_at?: string;
}

export interface Prediction {
  id: string;
  prediction_date: string;
  meal_type: MealType;
  expected_students: number;
  predicted_meals: number;
  recommended_preparation: number;
  expected_waste: number;
  confidence: number;
  actual_consumed: number | null;
  created_at?: string;
}

export interface SurplusFood {
  id: string;
  food_type: string;
  portions: number;
  available_time: string;
  location: string;
  contact_info: string;
  status: SurplusStatus;
  created_at: string;
}

export interface PredictionResult {
  expectedStudents: number;
  predictedMeals: number;
  recommendedPreparation: number;
  expectedWaste: number;
  confidence: number;
  method: 'regression' | 'weighted_average' | 'fallback';
  historicalAverage: number;
  factors: string[];
}
