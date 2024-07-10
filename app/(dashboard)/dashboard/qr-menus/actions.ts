'use server';

import { createClient } from '@/utils/supabase/server';
import { SupabaseQRMenuModel } from '@/app/(dashboard)/dashboard/qr-menus/tpyes';
import { getCurrentBusiness } from '@/app/actions';

const supabase = createClient();

export async function getQRMenus() {
  const business = await getCurrentBusiness();

  const {
    data: qrMenus,
    count,
    error
  } = await supabase
    .from('qr_menus')
    .select('*')
    .eq('business_id', business.id)
    .returns<SupabaseQRMenuModel[]>();

  if (error) {
    throw error;
  }

  return {
    qrMenus,
    count
  };
}
