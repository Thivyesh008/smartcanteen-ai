import { useCallback, useEffect, useState } from 'react';
import { fetchDailyData, fetchPredictions, fetchSurplus } from '@/lib/data';
import type { DailyFoodData, Prediction, SurplusFood } from '@/types';

export function useDailyData() {
  const [data, setData] = useState<DailyFoodData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const refresh = useCallback(async () => {
    setLoading(true);
    try { setData(await fetchDailyData()); setError(null); } catch { setError('Unable to load canteen data.'); } finally { setLoading(false); }
  }, []);
  useEffect(() => { void refresh(); }, [refresh]);
  return { data, loading, error, refresh, setData };
}

export function usePredictions() {
  const [data, setData] = useState<Prediction[]>([]);
  const [loading, setLoading] = useState(true);
  const refresh = useCallback(async () => { setLoading(true); try { setData(await fetchPredictions()); } finally { setLoading(false); } }, []);
  useEffect(() => { void refresh(); }, [refresh]);
  return { data, loading, refresh };
}

export function useSurplus() {
  const [data, setData] = useState<SurplusFood[]>([]);
  const [loading, setLoading] = useState(true);
  const refresh = useCallback(async () => { setLoading(true); try { setData(await fetchSurplus()); } finally { setLoading(false); } }, []);
  useEffect(() => { void refresh(); }, [refresh]);
  return { data, loading, refresh, setData };
}
