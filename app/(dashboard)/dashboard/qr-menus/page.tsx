import BreadCrumb from '@/components/breadcrumb';
import { Heading } from '@/components/ui/heading';
import { Separator } from '@/components/ui/separator';
import { columns } from '@/components/tables/qr-menu-tables/columns';
import { getQRMenus } from '@/app/(dashboard)/dashboard/qr-menus/actions';
import { QrMenuTable } from '@/components/tables/qr-menu-tables/qr-menu-table';

const breadcrumbItems = [{ title: 'QR Menus', link: '/dashboard/qr-menus' }];

type paramsProps = {
  searchParams: {
    [key: string]: string | string[] | undefined;
  };
};

export default async function Page({ searchParams }: paramsProps) {
  const page = Number(searchParams.page) || 1;
  const pageLimit = Number(searchParams.limit) || 10;
  const search = searchParams.search as string | null;

  const { qrMenus, count } = await getQRMenus();
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

        <QrMenuTable
          searchKey="name"
          pageNo={page}
          columns={columns}
          totalUsers={totalUsers}
          data={qrMenus ?? []}
          pageCount={pageCount}
        />
      </div>
    </>
  );
}
