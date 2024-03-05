
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
  categories:[string];
  available_blueprints:[Manufacturable];
  downloaded_blueprints:[string];
  drive_recipe_blueprints:[string];
  hidden_blueprints:[string];
}

// See /datum/manufacture
type Manufacturable = {
  name:string;
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
