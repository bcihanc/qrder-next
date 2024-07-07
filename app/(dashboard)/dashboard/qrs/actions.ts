'use server';

import { createClient } from '@/utils/supabase/server';
import { revalidateTag, unstable_cache } from 'next/cache';

const supabase = createClient();

export async function getQRs(page = 1, limit = 10) {
  const start = (page - 1) * limit;
  const end = start + limit - 1;

  const qrsCache = unstable_cache(
    async () =>
      await supabase
        .from('qrs')
        .select('*', { count: 'exact' })
        .range(start, end)
        .limit(limit)
        .order('updated_at', { ascending: false }),
    [`qrs/?page=${page}&limit=${limit}`],
    { tags: ['qrs'] }
  );

  const { data, count } = await qrsCache();

  return {
    data,
    count,
    page
  };
}

export async function updateQRName(id: string, name: string) {
  const { data } = await supabase
    .from('qrs')
    .update({ name: name })
    .eq('id', id);
  revalidateTag('qrs');
  return data;
}
