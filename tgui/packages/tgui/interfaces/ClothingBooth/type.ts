export interface ClothingBoothData {
  clothingBoothCategories: ClothingBoothCategory[];
  money: number;
  name: string;
  previewHeight: number;
  previewIcon: string;
  selectedItemCost: number;
  selectedItemName: string;
}

export interface ClothingBoothCategory {
  category: string;
  items: BoothItemData[];
}

export interface BoothItemData {
  cost: number;
  img: string;
  name: string;
  path: string;
}
