export interface WeaponVendorData {
  credits: {
    sidearm: number,
    loadout: number,
    utility: number,
    assistant: number,
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
