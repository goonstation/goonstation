export interface WeaponVendorData {
  credits: {
    Sidearm: number,
    Loadout: number,
    Utility: number,
    Assistant: number,
  };
  stock: WeaponVendorStockData[];
}

export interface WeaponVendorStockData {
  ref: string;
  name: string;
  description: string;
  cost: number;
  category: string;
}
