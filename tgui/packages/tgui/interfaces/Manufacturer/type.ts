
type ManufacturerData = {
  panel_open:boolean;
  hacked:boolean;
  malfunction:boolean;
  wire_bitflags:number;
  scanned_card:string;
  speed:number;
  repeat:boolean;
  resources:{ [key: string] : number };
  mats_by_id:any;
  all_categories:[string];
  available_blueprints:{ [key:string] : Manufacturable[]};
  downloaded_blueprints:{ [key:string] : Manufacturable[]};
  drive_recipe_blueprints:{ [key:string] : Manufacturable[]};
  hidden_blueprints:{ [key:string] : Manufacturable[]};
}

// See /datum/manufacture
// Name is the key for this type
type Manufacturable = {
  item_paths:[string];
  item_names:[string];
  item_amounts:[number];
  item_outputs:any;
  randomize_output:boolean;
  create:number;
  time:number;
  category:string;
  sanity_check_exemption:boolean;
  apply_material:boolean;
}
