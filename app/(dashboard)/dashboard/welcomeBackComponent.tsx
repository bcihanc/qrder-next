'use client';

import useUser from '@/hooks/useUser';

export function WelcomeBackComponent() {
  const { user } = useUser();

  return (
    <h2 className="text-3xl font-bold tracking-tight">
      Hi, Welcome back 👋 {user?.id}
    </h2>
  );
}
