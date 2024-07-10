'use client';

import { ColumnDef } from '@tanstack/react-table';
import { Input } from '@/components/ui/input';
import { updateQRName } from '@/app/(dashboard)/dashboard/qrs/actions';
import { useState } from 'react';
import { toast } from 'sonner';
import { SupabaseQRModel } from '@/app/(dashboard)/dashboard/qrs/types';

export const columns: ColumnDef<SupabaseQRModel>[] = [
  {
    accessorKey: 'name',
    header: 'Name',
    cell: function CellComponent({ row }) {
      const [name, setName] = useState(row.original.name);
      return (
        <>
          <Input
            value={name || ''}
            onChange={(event) => setName(event.currentTarget.value)}
            onKeyDown={(event) => {
              if (event.key === 'Enter') {
                event.currentTarget.blur();
                if (name !== row.original.name) {
                  updateQRName(row.original.id, name!).then(() => {
                    toast.success(`QR updated ${name}`);
                  });
                }
              }
            }}
          />
        </>
      );
    }
  },
  {
    accessorKey: 'scan_counts',
    header: 'Scan Counts'
  },
  {
    accessorKey: 'id',
    header: 'ID'
  }
];
