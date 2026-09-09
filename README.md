# SmartCanteen AI

SmartCanteen AI is an AI-powered college canteen platform for predicting meal demand, reducing leftovers, monitoring food waste, and coordinating surplus food with authorized volunteers.

## Features

- Landing page with sustainability impact metrics
- Demo role-based access for canteen staff and administrators
- Dashboard for attendance, meals, waste, and AI insights
- Daily food data entry with validation and recent-entry history
- Demand prediction using weighted historical consumption, attendance ratios, and day-of-week patterns
- Waste monitoring with trend charts, alerts, and contributing-factor analysis
- Surplus food coordination with status tracking and volunteer notifications
- Administrator overview with campus-wide metrics and AI insights
- Daily, weekly, and monthly reports with print and download actions
- Responsive layout for desktop, tablet, and mobile

## Technology stack

- React + TypeScript + Vite
- Tailwind CSS
- Lucide React icons
- Supabase Postgres with Row Level Security
- SVG-based interactive charts

## How the AI prediction works

The prediction feature learns from the historical records stored in the database. It filters records by meal type, looks for matching days of the week, calculates recent attendance-to-consumption ratios, and combines weighted recent observations into a predicted meal count. The recommendation adds a small preparation buffer and estimates waste from historical leftover patterns. Confidence increases with more comparable records and decreases when historical consumption is volatile.

When there are fewer comparable records, the app clearly uses a preliminary fallback based on recent historical averages. Adding daily data improves the prediction inputs over time.

## Database structure

- `users`: demo workspace accounts and roles
- `daily_food_data`: attendance, preparation, consumption, leftovers, meal type, and notes
- `predictions`: saved prediction inputs, outputs, confidence, and actual consumption when available
- `surplus_food`: portions, pickup details, contact information, and coordination status

All tables have RLS enabled with shared single-tenant policies for the demo workspace. The database is seeded with more than 30 days of varied data across breakfast, lunch, snacks, and dinner.

## How to run

Install the project dependencies and start the Vite development server. The hosted project environment already provides the Supabase connection settings used by the app.

## Future improvements

- Replace demo role access with Supabase Auth and organization-level permissions
- Add model accuracy tracking by comparing predictions with actual consumption
- Add scheduled email or campus messaging notifications
- Add CSV export and richer report templates
- Add food safety checklist records for surplus handoff
