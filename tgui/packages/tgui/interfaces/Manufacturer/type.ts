
type ManufacturerData = {
  all_categories:[string];
  
  fabricator_name:string;
  scanned_card:string;

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

  speed:number;
  wire_bitflags:number;
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
  ref:string;
}
