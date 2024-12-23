export enum Allowed {
  No = 0,
  Implicit = 1,
  Explicit = 2,
}

export enum RequestState {
  Pending = 'pending',
  Denied = 'denied',
  Fulfilled = 'fulfilled',
}

export interface RequestData {
  id: number;
  name: string;
  reagent_name: string;
  volume: number;
  reagent_color: [number, number, number] | null;
  notes: string;
  area: string;
  state: RequestState;
  age: string;
}

export interface ChemRequestReceiverData {
  requests: RequestData[];
  allowed: Allowed;
}
