/*
# SmartCanteen AI — Initial Schema & Seed Data

## Purpose
Creates the full database structure for the SmartCanteen AI platform: a college
canteen food-waste reduction tool. Includes tables for users, daily food data,
predictions, and surplus food coordination, plus 30+ days of realistic sample
data so the dashboard and AI prediction work immediately on first load.

## Tables Created
1. **users** — demo login accounts (canteen staff + administrator roles)
2. **daily_food_data** — per-meal records of attendance, meals prepared/consumed, waste
3. **predictions** — AI demand predictions stored for history/comparison
4. **surplus_food** — surplus food coordination entries for volunteer redistribution

## Security
- RLS enabled on every table.
- Policies use `TO anon, authenticated` because this app uses demo client-side
  auth (not Supabase Auth) — the anon-key frontend must be able to read and write
  all data. The data is intentionally shared across the single canteen.

## Seed Data
- 2 demo users (staff + admin)
- ~35 days of daily_food_data with realistic variation across breakfast/lunch/snacks/dinner
  including weekday/weekend patterns, attendance fluctuations, and correlated waste
- A few sample predictions and surplus entries for immediate UI population
*/

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  role text NOT NULL DEFAULT 'staff' CHECK (role IN ('staff', 'admin')),
  email text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_users" ON users;
CREATE POLICY "anon_select_users" ON users FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_users" ON users;
CREATE POLICY "anon_insert_users" ON users FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_users" ON users;
CREATE POLICY "anon_update_users" ON users FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_users" ON users;
CREATE POLICY "anon_delete_users" ON users FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- DAILY_FOOD_DATA
-- ============================================================
CREATE TABLE IF NOT EXISTS daily_food_data (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  students_present integer NOT NULL CHECK (students_present >= 0),
  meals_prepared integer NOT NULL CHECK (meals_prepared >= 0),
  meals_consumed integer NOT NULL CHECK (meals_consumed >= 0),
  leftover_kg numeric(8,2) NOT NULL DEFAULT 0 CHECK (leftover_kg >= 0),
  meal_type text NOT NULL CHECK (meal_type IN ('Breakfast', 'Lunch', 'Snacks', 'Dinner')),
  notes text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_daily_food_data_date ON daily_food_data(date DESC);
CREATE INDEX IF NOT EXISTS idx_daily_food_data_meal_type ON daily_food_data(meal_type);
CREATE INDEX IF NOT EXISTS idx_daily_food_data_date_meal ON daily_food_data(date, meal_type);

ALTER TABLE daily_food_data ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_daily_food_data" ON daily_food_data;
CREATE POLICY "anon_select_daily_food_data" ON daily_food_data FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_daily_food_data" ON daily_food_data;
CREATE POLICY "anon_insert_daily_food_data" ON daily_food_data FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_daily_food_data" ON daily_food_data;
CREATE POLICY "anon_update_daily_food_data" ON daily_food_data FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_daily_food_data" ON daily_food_data;
CREATE POLICY "anon_delete_daily_food_data" ON daily_food_data FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- PREDICTIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS predictions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prediction_date date NOT NULL,
  meal_type text NOT NULL CHECK (meal_type IN ('Breakfast', 'Lunch', 'Snacks', 'Dinner')),
  expected_students integer NOT NULL DEFAULT 0,
  predicted_meals integer NOT NULL DEFAULT 0,
  recommended_preparation integer NOT NULL DEFAULT 0,
  expected_waste numeric(8,2) NOT NULL DEFAULT 0,
  confidence numeric(5,2) NOT NULL DEFAULT 0 CHECK (confidence >= 0 AND confidence <= 100),
  actual_consumed integer,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_predictions_date ON predictions(prediction_date DESC);
CREATE INDEX IF NOT EXISTS idx_predictions_meal_type ON predictions(meal_type);

ALTER TABLE predictions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_predictions" ON predictions;
CREATE POLICY "anon_select_predictions" ON predictions FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_predictions" ON predictions;
CREATE POLICY "anon_insert_predictions" ON predictions FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_predictions" ON predictions;
CREATE POLICY "anon_update_predictions" ON predictions FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_predictions" ON predictions;
CREATE POLICY "anon_delete_predictions" ON predictions FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- SURPLUS_FOOD
-- ============================================================
CREATE TABLE IF NOT EXISTS surplus_food (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  food_type text NOT NULL,
  portions integer NOT NULL CHECK (portions > 0),
  available_time text NOT NULL,
  location text NOT NULL,
  contact_info text NOT NULL,
  status text NOT NULL DEFAULT 'Available' CHECK (status IN ('Available', 'Reserved', 'Collected', 'Expired')),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_surplus_food_status ON surplus_food(status);
CREATE INDEX IF NOT EXISTS idx_surplus_food_created ON surplus_food(created_at DESC);

ALTER TABLE surplus_food ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_surplus_food" ON surplus_food;
CREATE POLICY "anon_select_surplus_food" ON surplus_food FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_surplus_food" ON surplus_food;
CREATE POLICY "anon_insert_surplus_food" ON surplus_food FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_surplus_food" ON surplus_food;
CREATE POLICY "anon_update_surplus_food" ON surplus_food FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_surplus_food" ON surplus_food;
CREATE POLICY "anon_delete_surplus_food" ON surplus_food FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- SEED: USERS
-- ============================================================
INSERT INTO users (name, role, email) VALUES
  ('Sarah Chen', 'staff', 'staff@smartcanteen.ai'),
  ('Dr. James Patel', 'admin', 'admin@smartcanteen.ai')
ON CONFLICT (email) DO NOTHING;

-- ============================================================
-- SEED: DAILY_FOOD_DATA (35 days, 4 meal types per day)
-- Uses a PL/pgSQL block to generate realistic varied data with
-- weekday/weekend patterns, seasonal-ish attendance drift, and
-- correlated waste (higher waste when prepared >> consumed).
-- ============================================================
DO $$
DECLARE
  d integer;
  rec_date date;
  dow integer;       -- 0=Sunday ... 6=Saturday
  base_attendance integer;
  breakfast_attendance integer;
  lunch_attendance integer;
  snacks_attendance integer;
  dinner_attendance integer;
  b_prep integer; b_cons integer; b_waste numeric;
  l_prep integer; l_cons integer; l_waste numeric;
  s_prep integer; s_cons integer; s_waste numeric;
  d_prep integer; d_cons integer; d_waste numeric;
  noise integer;
  meal_notes text;
BEGIN
  FOR d IN 0..34 LOOP
    rec_date := CURRENT_DATE - (35 - d);
    dow := EXTRACT(DOW FROM rec_date)::integer;

    -- Weekend: much lower attendance
    IF dow IN (0, 6) THEN
      base_attendance := 180 + (random() * 80)::integer;
    ELSE
      base_attendance := 680 + (random() * 140)::integer;
    END IF;

    -- Friday slightly lower for lunch
    breakfast_attendance := (base_attendance * 0.45 + (random() * 40 - 20))::integer;
    lunch_attendance := GREATEST(base_attendance - (random() * 60)::integer, 200);
    IF dow = 5 THEN
      lunch_attendance := (lunch_attendance * 0.85)::integer;
    END IF;
    snacks_attendance := (base_attendance * 0.30 + (random() * 30 - 15))::integer;
    dinner_attendance := (base_attendance * 0.25 + (random() * 20 - 10))::integer;

    -- Breakfast: ~0.4 meals per attending student
    noise := (random() * 30 - 15)::integer;
    b_cons := GREATEST((breakfast_attendance * 0.40 + noise)::integer, 50);
    b_prep := (b_cons * (1.05 + random() * 0.12))::integer;
    b_waste := GREATEST(((b_prep - b_cons) * 0.12 + random() * 3)::numeric, 0);

    -- Lunch: ~0.85 meals per attending student
    noise := (random() * 50 - 25)::integer;
    l_cons := GREATEST((lunch_attendance * 0.85 + noise)::integer, 100);
    l_prep := (l_cons * (1.08 + random() * 0.15))::integer;
    l_waste := GREATEST(((l_prep - l_cons) * 0.15 + random() * 5)::numeric, 0);

    -- Snacks: ~0.5 per attending student
    noise := (random() * 20 - 10)::integer;
    s_cons := GREATEST((snacks_attendance * 0.50 + noise)::integer, 30);
    s_prep := (s_cons * (1.10 + random() * 0.18))::integer;
    s_waste := GREATEST(((s_prep - s_cons) * 0.10 + random() * 2)::numeric, 0);

    -- Dinner: ~0.7 per attending student
    noise := (random() * 15 - 7)::integer;
    d_cons := GREATEST((dinner_attendance * 0.70 + noise)::integer, 40);
    d_prep := (d_cons * (1.06 + random() * 0.14))::integer;
    d_waste := GREATEST(((d_prep - d_cons) * 0.11 + random() * 2)::numeric, 0);

    meal_notes := CASE
      WHEN random() > 0.7 THEN 'Special menu day'
      WHEN random() > 0.5 THEN 'Weather affected attendance'
      ELSE NULL
    END;

    INSERT INTO daily_food_data (date, students_present, meals_prepared, meals_consumed, leftover_kg, meal_type, notes)
    VALUES
      (rec_date, breakfast_attendance, b_prep, b_cons, ROUND(b_waste, 2), 'Breakfast', meal_notes),
      (rec_date, lunch_attendance, l_prep, l_cons, ROUND(l_waste, 2), 'Lunch', meal_notes),
      (rec_date, snacks_attendance, s_prep, s_cons, ROUND(s_waste, 2), 'Snacks', NULL),
      (rec_date, dinner_attendance, d_prep, d_cons, ROUND(d_waste, 2), 'Dinner', NULL);
  END LOOP;
END $$;

-- ============================================================
-- SEED: PREDICTIONS (a few recent ones)
-- ============================================================
INSERT INTO predictions (prediction_date, meal_type, expected_students, predicted_meals, recommended_preparation, expected_waste, confidence, actual_consumed)
SELECT
  CURRENT_DATE,
  'Lunch',
  750,
  630,
  660,
  12.50,
  88.00,
  NULL
WHERE NOT EXISTS (SELECT 1 FROM predictions WHERE prediction_date = CURRENT_DATE AND meal_type = 'Lunch');

-- ============================================================
-- SEED: SURPLUS_FOOD
-- ============================================================
INSERT INTO surplus_food (food_type, portions, available_time, location, contact_info, status) VALUES
  ('Veg Biryani', 35, '1:00 PM - 2:00 PM', 'Main Canteen - Counter 3', 'staff@smartcanteen.ai', 'Available'),
  ('Dal & Rice', 20, '7:30 PM - 8:30 PM', 'Main Canteen - Counter 1', 'staff@smartcanteen.ai', 'Available'),
  ('Pasta Alfredo', 15, '12:30 PM - 1:30 PM', 'Cafe Block B', 'staff@smartcanteen.ai', 'Reserved')
ON CONFLICT DO NOTHING;
