'use client';

import { Button } from '@/components/ui/button';
import { useRouter } from 'next/navigation';
import * as React from 'react';
import { createClient } from '@/utils/supabase/client';

export function UserNav() {
  const router = useRouter();

  return (
    <div>
      <Button
        variant="ghost"
        onClick={async () => {
          await createClient().auth.signOut();
          router.replace('/login');
        }}
      >
        Logout
      </Button>
    </div>
  );
  // return (
  //   <Button
  //     onClick={async () => {
  //       await createClient().auth.signOut();
  //       router.replace('/login');
  //     }}
  //   >
  //     Logout
  //   </Button>
  // );
  // return (
  //   <DropdownMenu>
  //     {/*<DropdownMenuTrigger asChild>*/}
  //     {/*  <Button variant="ghost" className="relative h-8 w-8 rounded-full">*/}
  //     {/*    <Avatar className="h-8 w-8">*/}
  //     {/*      <AvatarImage*/}
  //     {/*        src={session.user?.image ?? ''}*/}
  //     {/*        alt={session.user?.name ?? ''}*/}
  //     {/*      />*/}
  //     {/*      <AvatarFallback>{session.user?.name?.[0]}</AvatarFallback>*/}
  //     {/*    </Avatar>*/}
  //     {/*  </Button>*/}
  //     {/*</DropdownMenuTrigger>*/}
  //     <DropdownMenuContent className="w-56" align="end" forceMount>
  //       {/*<DropdownMenuLabel className="font-normal">*/}
  //       {/*  <div className="flex flex-col space-y-1">*/}
  //       {/*    <p className="text-sm font-medium leading-none">*/}
  //       {/*      {session.user?.name}*/}
  //       {/*    </p>*/}
  //       {/*    <p className="text-xs leading-none text-muted-foreground">*/}
  //       {/*      {session.user?.email}*/}
  //       {/*    </p>*/}
  //       {/*  </div>*/}
  //       {/*</DropdownMenuLabel>*/}
  //       <DropdownMenuSeparator />
  //       <DropdownMenuGroup>
  //         <DropdownMenuItem>
  //           Profile
  //           <DropdownMenuShortcut>⇧⌘P</DropdownMenuShortcut>
  //         </DropdownMenuItem>
  //         <DropdownMenuItem>
  //           Billing
  //           <DropdownMenuShortcut>⌘B</DropdownMenuShortcut>
  //         </DropdownMenuItem>
  //         <DropdownMenuItem>
  //           Settings
  //           <DropdownMenuShortcut>⌘S</DropdownMenuShortcut>
  //         </DropdownMenuItem>
  //         <DropdownMenuItem>New Team</DropdownMenuItem>
  //       </DropdownMenuGroup>
  //       <DropdownMenuSeparator />
  //       <DropdownMenuItem onClick={() => createClient().auth.signOut()}>
  //         Log out
  //         <DropdownMenuShortcut>⇧⌘Q</DropdownMenuShortcut>
  //       </DropdownMenuItem>
  //     </DropdownMenuContent>
  //   </DropdownMenu>
  // );
}
