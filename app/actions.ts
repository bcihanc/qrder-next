'use server';

import { createClient } from '@/utils/supabase/server';

const supabase = createClient();

export async function getCurrentUser() {
  const { data, error } = await supabase.auth.getUser();
  if (error) {
    throw error;
  }
  return data;
}

export async function getCurrentEmployee() {
  const user = await getCurrentUser();

  const { data, error } = await supabase
    .from('employees')
    .select()
    .eq('id', user.user?.id)
    .single();

  if (error) {
    throw error;
  }

  return data;
}

export async function getCurrentBusiness() {
  const employee = await getCurrentEmployee();

  const { data, error } = await supabase
    .from('businesses')
    .select()
    .eq('id', employee.business_id)
    .single();

  if (error) {
    throw error;
  }

  return data;
}
