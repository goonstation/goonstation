export interface ClothingBoothData {
  categoryList: Array<string>;
  clothingBoothList: ClothingBoothListData[];
  money: number;
  name: string;
  preview: string;
  selectedItemCost: number;
  selectedItemName: string;
}

export interface ClothingBoothListData {
  category: string;
  cost: number;
  img: string;
  name: string;
  path: string;
}
