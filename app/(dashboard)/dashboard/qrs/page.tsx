import { getQRs } from '@/app/(dashboard)/dashboard/qrs/actions';
import BreadCrumb from '@/components/breadcrumb';
import { Heading } from '@/components/ui/heading';
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
  const search = searchParams.search as string | null;

  const { qrs, count } = await getQRs(page, pageLimit, search);
  const totalUsers = count || 0;
  const pageCount = Math.ceil(totalUsers / pageLimit);
  return (
    <>
      <div className="flex-1 space-y-4  p-4 pt-6 md:p-8">
        <BreadCrumb items={breadcrumbItems} />
        <div className="flex items-start justify-between">
          <Heading
            title={`QRs (${totalUsers})`}
            description="QR kodları listesi"
          />
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
