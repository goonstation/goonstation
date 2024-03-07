
type ManufacturerData = {
  all_categories:[string];

  card_owner:string;
  fabricator_name:string;

  available_blueprints:{ [key:string] : Manufacturable[]};
  downloaded_blueprints:{ [key:string] : Manufacturable[]};
  drive_recipe_blueprints:{ [key:string] : Manufacturable[]};
  hidden_blueprints:{ [key:string] : Manufacturable[]};

  resources:{ [key: string] : number };

  delete_allowed:boolean;
  hacked:boolean;
  malfunction:boolean;
  panel_open:boolean;
  repeat:boolean;

  mats_by_id:any;

  card_balance:number;
  speed:number;
  wire_bitflags:number;
}

// Keyed by name
type Manufacturable = {
  item_names:[string];
  item_amounts:[number];
  create:number;
  time:number;
  category:string;
  ref:string;
}
