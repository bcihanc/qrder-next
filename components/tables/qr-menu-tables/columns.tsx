'use client';

import { ColumnDef } from '@tanstack/react-table';
import { SupabaseQRMenuModel } from '@/app/(dashboard)/dashboard/qr-menus/tpyes';

export const columns: ColumnDef<SupabaseQRMenuModel>[] = [
  {
    accessorKey: 'name',
    header: 'Name'
  },
  {
    accessorKey: 'id',
    header: 'ID'
  }
];
