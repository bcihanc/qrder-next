export interface SupabaseEmployeeBusinessesModel {
  business_id: string;
  employee_id: string;
  created_at: string;
  businesses: {
    id: string;
    name: string;
    created_at: string;
    last_switched_at: string;
  };
}
