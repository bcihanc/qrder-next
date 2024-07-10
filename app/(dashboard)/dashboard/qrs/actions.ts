'use server';

import { createClient } from '@/utils/supabase/server';
import { SupabaseQRModel } from '@/app/(dashboard)/dashboard/qrs/types';
import { revalidatePath } from 'next/cache';
import { getCurrentBusiness } from '@/app/actions';

const supabase = createClient();

export async function getQRs(page = 1, limit = 10, search: string | null) {
  const start = (page - 1) * limit;
  const end = start + limit - 1;

  const business = await getCurrentBusiness();

  const query = supabase
    .from('qrs')
    .select('*, business:business_id(*)', { count: 'exact' })
    .eq('business_id', business.id);

  if (search) {
    const splitAndJoined = search.trim().split(' ').join(' & ');
    query.textSearch('fts', splitAndJoined, { config: 'turkish' });
  } else {
    query
      .range(start, end)
      .limit(limit)
      .order('updated_at', { ascending: false });
  }

  const { data: qrs, count, error } = await query.returns<SupabaseQRModel[]>();

  if (error) {
    debugger;
  }
  console.log(qrs);
  return {
    qrs,
    count,
    page
  };
}

// export async function getQRScanMonthCountById(qr_id: string) {
//   const { data, error } = await supabase.rpc('qr_scans_this_month', {
//     qr_id_param: qr_id
//   });
//
//   if (error) {
//     debugger;
//   }
//   debugger;
//   return data;
// }

export async function updateQRName(id: string, name: string) {
  const { data, error } = await supabase
    .from('qrs')
    .update({ name: name })
    .eq('id', id);

  if (error) {
    debugger;
  }

  revalidatePath('/dashboard/qrs');
  return data;
}
