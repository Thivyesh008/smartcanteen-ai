import { supabase } from '@/lib/supabase';
import type { Role, User } from '@/types';

export async function signInDemo(role: Role): Promise<User> {
  const email = role === 'admin' ? 'admin@smartcanteen.ai' : 'staff@smartcanteen.ai';
  const { data, error } = await supabase.from('users').select('*').eq('email', email).maybeSingle();
  if (error) throw error;
  if (!data) throw new Error('Demo account unavailable');
  localStorage.setItem('smartcanteen_user', JSON.stringify(data));
  return data as User;
}

export function getStoredUser(): User | null {
  const raw = localStorage.getItem('smartcanteen_user');
  if (!raw) return null;
  try { return JSON.parse(raw) as User; } catch { return null; }
}

export function signOutDemo(): void {
  localStorage.removeItem('smartcanteen_user');
}
