export type PipeData = {
  type: string;
  image: string; // base64
  cost: number;
};

export type HandPipeDispenserData = {
  atmospipes: PipeData[];
  atmosmachines: PipeData[];
  selectedimage: string; // base64 image
  destroying: boolean;
  selectedcost: number;
  resources: number;
};

// I feel like this should be common somewhere but :iiam:
export enum ByondDir {
  North = 1,
  South = 2,
  East = 4,
  West = 8,
}

export enum Tab {
  AtmosPipes = 'atmospipes',
  AtmosMachines = 'atmosmachines',
}
