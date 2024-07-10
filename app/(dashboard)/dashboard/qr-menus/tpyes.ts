export interface SupabaseBusinessModel {
  id: string;
  created_at: Date;
  name: string;
}

export interface SupabaseQRMenuModel {
  id: string;
  created_at: Date;
  business_id: string;
  name: string;
  active: boolean;
}

export interface SupabaseQRMenuItemModel {
  id: string;
  created_at: Date;
  qr_menu_id: string;
  name: string;
  active: boolean;
  notify: boolean;
  translations: {
    id: string;
    created_at: Date;
    qr_menu_item_id: string;
    language: string;
    name: string;
    description: string | null;
    image: string | null;
    price: number;
    currency: string;
  }[];
}
