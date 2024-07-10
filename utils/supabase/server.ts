import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { Database } from '@/types/supabase';

export const createFetch =
  (options: Pick<RequestInit, 'next' | 'cache'>) =>
  (url: RequestInfo | URL, init?: RequestInit) => {
    return fetch(url, { ...init, ...options });
  };

export function createClient() {
  const cookieStore = cookies();
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      global: {
        // fetch: createFetch({
        //   cache: 'no-cache'
        // })
      },
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch (error) {
            debugger;
          }
        }
      }
    }
  );
}
