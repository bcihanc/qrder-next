// useUser.ts
import { useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import useSWRImmutable from 'swr/immutable';

const supabase = createClient();

const fetcher = async () => {
  const {
    data: { user },
    error
  } = await supabase.auth.getUser();
  if (error) throw error;
  return user;
};

const useUser = () => {
  const { data: user, error, mutate } = useSWRImmutable('user', fetcher);

  useEffect(() => {
    const {
      data: { subscription }
    } = supabase.auth.onAuthStateChange((event, session) => {
      mutate();
    });

    return () => subscription?.unsubscribe();
  }, [mutate]);

  return {
    user,
    isLoading: !error && !user,
    isError: error
  };
};

export default useUser;
