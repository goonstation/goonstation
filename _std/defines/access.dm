// Note: Don't forget to check and modify /obj/machinery/computer/card (the ID computer) as needed
//       when you re-enable old credentials or add new ones.
//       Also check proc/get_access_desc() (ID computer lookup) in access.dm

/// This is useful for scenarios where login is required but no particular access is needed.
#define access_fuck_all "fuck_all" // Because completely empty access lists can make things grump
#define access_security "security"
#define access_brig "brig"
#define access_armory "armory" // Unused and replaced by maxsec (HoS-exclusive).
#define access_forensics_lockers "forensics"
#define access_medical "medical"
#define access_morgue "morgue"
#define access_tox "toxins"
#define access_tox_storage "toxins_storage"
#define access_medlab "medlab"
#define access_medical_lockers "medical_lockers"
#define access_research_director "research_director"
#define access_maint_tunnels "maint"
#define access_external_airlocks "external_airlocks" // Unused. Most are all- or maintenance access these days.
#define access_emergency_storage "emergency_storage"
#define access_change_ids "change_ids"
#define access_ai_upload "upload"
#define access_teleporter "teleporter"
#define access_eva "eva"
#define access_heads "heads" // Mostly just the bridge.
#define access_captain "captain"
#define access_all_personal_lockers "all_personal_lockers" // Unused. Personal lockers are always linked to ID that was swiped first.
#define access_chapel_office "chapel"
#define access_tech_storage "tech_storage"
#define access_research "research"
#define access_bar "bar"
#define access_janitor "janitor"
#define access_crematorium "crematorium"
#define access_kitchen "kitchen"
#define access_robotics "robotics"
#define access_hangar "hangar" // Unused. Theoretically the pod hangars, but not implemented as such in practice.
#define access_cargo "cargo" // QM.
#define access_construction "construction" // Unused.
#define access_chemistry "chemistry"
#define access_dwaine_superuser "dwaine_su" // So it's not the same as the RD's office and locker.
#define access_hydro "hydroponics"
#define access_mail "mail" // Unused.
#define access_maxsec "maxsec" // The HoS' armory.
#define access_securitylockers "security_lockers"
#define access_carrypermit "carry_permit" // Are allowed to carry sidearms as far as guardbuddies and secbots are concerned. Contraband permit defined at 75.
#define access_engineering "engineering" // General engineering area and substations.
#define access_engineering_storage "engineering_storage" // Main metal/tool storage things.
#define access_engineering_eva "engineering_eva" // Engineering space suits. Currently unused.
#define access_engineering_power "apcs" // APCs and related supplies.
#define access_engineering_engine "engine" // Engine room.
#define access_engineering_mechanic "mechlab" // Electronics lab.
#define access_engineering_atmos "gas_storage" // Engineering's supply of gas canisters.
#define access_engineering_control "engine_control" // Engine control room.
#define access_engineering_chief "chief_engineer" // CE's office.

#define access_mining_shuttle "mining_shuttle"
#define access_mining "mining"
#define access_mining_outpost "mining_outpost"

#define access_syndicate_shuttle "listening_post" // Also to the listening post.
#define access_medical_director "medical_director"
#define access_head_of_personnel "head_of_personnel"

#define access_special_club "special" //Shouldnt be used for general gameplay. Used for adminevents.

#define access_ghostdrone "ghostdrone" // drooooones

#define access_centcom "centcom" // self-explanatory?  :v

#define access_supply_console "cargo_console" // QM Console

// skipping a few here to reserve a block
// for terra 8 and syndicate security clearances
#define access_syndicate_4 "syndicate_4"
#define access_syndicate_8 "syndicate_8"
#define access_syndicate_16 "syndicate_16"
#define access_syndicate_32 "syndicate_32"
#define access_syndicate_64 "syndicate_64" // level needed for access to terra8 underside
#define access_syndicate_128 "syndicate_128"
#define access_syndicate_256 "syndicate_256" // highest level documents in terra8
#define access_syndicate_512 "syndicate_512" // allude to this but don't use it except for super special things

//Owlzone access
#define access_owlerymaint "owlery_maint"
#define access_owlerysec "owlery_sec"
#define access_owlerycommand "owlery_command"

//Polaris access
#define access_polariscargo "polaris_cargo"
#define access_polarisimportant "polaris_important"

#define access_contrabandpermit "contraband"

#define access_syndicate_commander "syndicate_commander"

//nt retention center access
#define access_retention_blue "retention_blue"
#define access_retention_green "retention_green"
#define access_retention_yellow "retention_yellow"
#define access_retention_orange "retention_orange"
#define access_retention_red "retention_red"
#define access_retention_black "retention_black"

//rancher job
#define access_ranch "ranch"

//pathologist job
#define access_pathology "pathology"

//extra research access
#define access_researchfoyer "research_foyer"
#define access_artlab "artlab"
#define access_telesci "telesci"
#define access_robotdepot "robot_depot"

// Pirate ship access:
#define access_pirate "pirate"
