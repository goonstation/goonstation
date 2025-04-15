// Note: Don't forget to check and modify /obj/machinery/computer/card (the ID computer) as needed
//       when you re-enable old credentials or add new ones.
//       Also check proc/get_access_desc() (ID computer lookup) in access.dm


// for stuff that is never allowed to open. Don't put this on any IDs etc
#define access_impossible -1

/// This is useful for scenarios where login is required but no particular access is needed.
#define access_fuck_all 0 // Because completely empty access lists can make things grump
#define access_security 1
#define access_brig 2
#define access_armory 3 // The HoS' armory
#define access_forensics_lockers 4
#define access_medical 5
#define access_morgue 6
#define access_tox 7
#define access_tox_storage 8
#define access_medlab 9
#define access_medical_lockers 10
#define access_research_director 11
#define access_maint_tunnels 12
#define access_ticket 13 // issuing tickets
#define access_fine_small 14
#define access_change_ids 15
#define access_ai_upload 16
#define access_teleporter 17
#define access_eva 18
#define access_heads 19 // Mostly just the bridge.
#define access_captain 20
#define access_all_personal_lockers 21 // Unused. Personal lockers are always linked to ID that was swiped first.
#define access_chapel_office 22
#define access_tech_storage 23
#define access_research 24
#define access_bar 25
#define access_janitor 26
#define access_crematorium 27
#define access_kitchen 28
#define access_robotics 29
#define access_fine_large 30
#define access_cargo 31 // QM.
#define access_construction 32 // Unused.
#define access_chemistry 33
#define access_dwaine_superuser 34 // So it's not the same as the RD's office and locker.
#define access_hydro 35
#define access_mail 36 // Unused.
#define access_maxsec 37 // The HoS' office
#define access_securitylockers 38
#define access_carrypermit 39 // Are allowed to carry sidearms as far as guardbuddies and secbots are concerned. Contraband permit defined at 75.
#define access_engineering 40 // General engineering area and substations.
#define access_engineering_storage 41 // Main metal/tool storage things.
#define access_engineering_eva 42 // Engineering space suits. Currently unused.
#define access_engineering_power 43 // APCs and related supplies.
#define access_engineering_engine 44 // Engine room.
#define access_engineering_mechanic 45 // Electronics lab.
#define access_engineering_atmos 46 // Engineering's supply of gas canisters.
#define access_engineering_control 48 // Engine control room.
#define access_engineering_chief 49 // CE's office.

#define access_mining_shuttle 47 // Unused.
#define access_mining 50
#define access_mining_outpost 51

#define access_syndicate_shuttle 52 // Also to the listening post.
#define access_medical_director 53
#define access_head_of_personnel 55

#define access_special_club 54 //Shouldnt be used for general gameplay. Used for adminevents.

#define access_ghostdrone 56 // drooooones

#define access_centcom 57 // self-explanatory?  :v

#define access_supply_console 58 // QM Console

#define access_money 59 //bank computer, because having bridge door access should not let you empty the budget

// skipping a few here to reserve a block
// for terra 8 and syndicate security clearances
#define access_syndicate_4 60
#define access_syndicate_8 61
#define access_syndicate_16 62
#define access_syndicate_32 63
#define access_syndicate_64 64 // level needed for access to terra8 underside
#define access_syndicate_128 65
#define access_syndicate_256 66 // highest level documents in terra8
#define access_syndicate_512 67 // allude to this but don't use it except for super special things

//Owlzone access
#define access_owlerymaint 70
#define access_owlerysec 71
#define access_owlerycommand 72

//Polaris access
#define access_polariscargo 73
#define access_polarisimportant 74

#define access_contrabandpermit 75

#define access_syndicate_commander 76

//nt retention center access
#define access_retention_blue 77
#define access_retention_green 78
#define access_retention_yellow 79
#define access_retention_orange 80
#define access_retention_red 81
#define access_retention_black 82

//rancher job
#define access_ranch 83

//pathologist job
#define access_pathology 84

//extra research access
#define access_researchfoyer 85
#define access_artlab 86
#define access_telesci 87
#define access_robotdepot 88

// Pirate ship access:
#define access_pirate 89
