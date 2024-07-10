export interface SupabaseQRModel {
  id: string;
  created_at: Date;
  updated_at: Date;
  name: string | null;
  scan_counts: number;
  business: {
    id: string;
    created_at: Date;
    name: string;
  };
}
