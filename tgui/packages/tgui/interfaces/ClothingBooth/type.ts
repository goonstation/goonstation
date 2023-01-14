export interface ClothingBoothData {
  categoryList: Array<string>;
  clothingBoothList: ClothingBoothListData[];
  money: number;
  name: string;
}

export interface ClothingBoothListData {
  category: string;
  cost: number;
  img: string;
  name: string;
  path: string;
}
