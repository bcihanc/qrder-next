import { getQRs } from '@/app/(dashboard)/dashboard/qrs/actions';
import BreadCrumb from '@/components/breadcrumb';
import { Heading } from '@/components/ui/heading';
import Link from 'next/link';
import { cn } from '@/lib/utils';
import { buttonVariants } from '@/components/ui/button';
import { Plus } from 'lucide-react';
import { Separator } from '@/components/ui/separator';
import { columns } from '@/components/tables/qr-tables/columns';
import { QRTable } from '@/components/tables/qr-tables/qr-table';

const breadcrumbItems = [{ title: 'QRs', link: '/dashboard/qrs' }];

type paramsProps = {
  searchParams: {
    [key: string]: string | string[] | undefined;
  };
};

export default async function Page({ searchParams }: paramsProps) {
  const page = Number(searchParams.page) || 1;
  const pageLimit = Number(searchParams.limit) || 10;
  const offset = (page - 1) * pageLimit;

  const { data: qrs, count } = await getQRs(page, pageLimit);
  const totalUsers = count || 0;
  const pageCount = Math.ceil(totalUsers / pageLimit);
  return (
    <>
      <div className="flex-1 space-y-4  p-4 pt-6 md:p-8">
        <BreadCrumb items={breadcrumbItems} />

        <div className="flex items-start justify-between">
          <Heading
            title={`QRs (${totalUsers})`}
            description="Manage employees (Server side table functionalities.)"
          />

          <Link
            href={'/dashboard/qrs/new'}
            className={cn(buttonVariants({ variant: 'default' }))}
          >
            <Plus className="mr-2 h-4 w-4" /> Add New
          </Link>
        </div>
        <Separator />

        <QRTable
          searchKey="name"
          pageNo={page}
          columns={columns}
          totalUsers={totalUsers}
          data={qrs ?? []}
          pageCount={pageCount}
        />
      </div>
    </>
  );
}
