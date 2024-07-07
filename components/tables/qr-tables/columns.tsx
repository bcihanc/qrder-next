'use client';
import { ColumnDef, createColumnHelper } from '@tanstack/react-table';
import { Tables } from '@/types/supabase';
import { CellAction } from '@/components/tables/qr-tables/cell-action';
import { Input } from '@/components/ui/input';
import { updateQRName } from '@/app/(dashboard)/dashboard/qrs/actions';
import { useRef, useState } from 'react';
import { isEmpty } from 'lodash';
import { toast } from 'sonner';

const columnHelper = createColumnHelper<Tables<'qrs'>>();

export const columns: ColumnDef<Tables<'qrs'>>[] = [
  {
    accessorKey: 'id',
    header: 'ID'
  },
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
                event.target.blur();
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
    id: 'actions',
    cell: ({ row }) => <CellAction data={row.original} />
  }
];
