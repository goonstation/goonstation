#define colorcable(_color, _hexcolor)\
/obj/item/cable_coil/_color;\
/obj/item/cable_coil/_color/name = ""+#_color+" cable coil";\
/obj/item/cable_coil/_color/base_name = ""+#_color+" cable coil";\
/obj/item/cable_coil/_color/stack_type = /obj/item/cable_coil/_color;\
/obj/item/cable_coil/_color/spawn_insulator_name = ""+#_color+" synthrubber";\
/obj/item/cable_coil/_color/cable_obj_type = /obj/cable/_color;\
/obj/item/cable_coil/_color/cut;\
/obj/item/cable_coil/_color/cut/icon_state = "coil2";\
/obj/item/cable_coil/_color/cut/New(loc, length)\
{if (length){..(loc, length)};else{..(loc, rand(1,2))};}\
/obj/item/cable_coil/_color/cut/small;\
/obj/item/cable_coil/_color/cut/small/New(loc, length){..(loc, rand(1,5))};\
/obj/cable/_color;\
/obj/cable/_color/name = ""+#_color+" power cable";\
/obj/cable/_color/color = _hexcolor;\
/obj/cable/_color/insulator_default = ""+#_color+" synthrubber";\
/datum/material/rubber/synthrubber/_color;\
/datum/material/rubber/synthrubber/_color/mat_id = ""+#_color+" synthrubber";\
/datum/material/rubber/synthrubber/_color/name = ""+#_color+" synthrubber";\
/datum/material/rubber/synthrubber/_color/desc = ""+"A type of synthetic rubber. This one is "+#_color+".";\
/datum/material/rubber/synthrubber/_color/color = _hexcolor;\
/obj/item/storage/box/cablesbox/_color;\
/obj/item/storage/box/cablesbox/_color/name = ""+"electrical cables storage ("+#_color+")";\
/obj/item/storage/box/cablesbox/_color/spawn_contents = list(/obj/item/cable_coil/_color = 7);\
/datum/supply_packs/electrical/_color;\
/datum/supply_packs/electrical/_color/name = ""+"Electrical Supplies Crate ("+#_color+") - 2 pack";\
/datum/supply_packs/electrical/_color/desc = ""+"x2 Cabling Box - "+#_color+" (14 cable coils total)";\
/datum/supply_packs/electrical/_color/contains = list(/obj/item/storage/box/cablesbox/_color = 2);\
/datum/supply_packs/electrical/_color/containername = ""+"Electrical Supplies Crate ("+#_color+")- 2 pack";\
/obj/cable/auto/_color;\
/obj/cable/auto/_color/name = ""+#_color+" power cable";\
/obj/cable/auto/_color/color = _hexcolor;\
/obj/cable/auto/_color/cable_type = /obj/cable/_color;\
/obj/cable/auto/_color/node;\
/obj/cable/auto/_color/node/name = "node "+#_color+" cable spawner";\
/obj/cable/auto/_color/node/override_centre_connection = TRUE;\
/obj/cable/auto/_color/node/icon_state = "superstate-node"

colorcable(yellow, list(0.35, 0.35, 0.00, 0.00,\
						0.25, 0.25, 0.00, 0.00,\
						0.30, 0.30, 0.00, 0.00,\
						0.00, 0.00, 0.00, 1.00,\
						0.325, 0.325, 0.00, 0.00))
colorcable(orange, list(0.35, 0.20, 0.00, 0.00,\
						0.25, 0.10, 0.00, 0.00,\
						0.30, 0.10, 0.00, 0.00,\
						0.00, 0.00, 0.00, 1.00,\
						0.25, 0.15, 0.00, 0.00))
colorcable(blue, list(0.15, 0.15, 0.35, 0.00,\
					0.10, 0.10, 0.35, 0.00,\
					0.00, 0.00, 0.35, 0.00,\
					0.00, 0.00, 0.00, 1.00,\
					0.00, 0.05, 0.25, 0.00))
colorcable(green, list(0.00, 0.35, 0.00, 0.00,\
					0.00, 0.25, 0.00, 0.00,\
					0.00, 0.30, 0.00, 0.00,\
					0.00, 0.00, 0.00, 1.00,\
					0.00, 0.25, 0.00, 0.00))
colorcable(purple, list(0.30, 0.00, 0.35, 0.00,\
						0.20, 0.00, 0.25, 0.00,\
						0.25, 0.00, 0.30, 0.00,\
						0.00, 0.00, 0.00, 1.00,\
						0.20, 0.00, 0.25, 0.00))
colorcable(black, list(0.10, 0.10, 0.10, 0.00,\
						0.05, 0.05, 0.05, 0.00,\
						0.075, 0.075, 0.075, 0.00,\
						0.00, 0.00, 0.00, 1.00,\
						0.03, 0.03, 0.03, 0.00))
colorcable(hotpink, list(0.45, 0.00, 0.30, 0.00,\
						0.35, 0.00, 0.20, 0.00,\
						0.40, 0.00, 0.25, 0.00,\
						0.00, 0.00, 0.00, 1.00,\
						0.20, 0.00, 0.10, 0.00))
colorcable(brown, list(0.25, 0.15, 0.00, 0.00,\
						0.15, 0.05, 0.00, 0.00,\
						0.15, 0.05, 0.00, 0.00,\
						0.00, 0.00, 0.00, 1.00,\
						0.20, 0.10, 0.00, 0.00))
colorcable(white, list(0.60, 0.60, 0.60, 0.00,\
						0.25, 0.25, 0.25, 0.00,\
						0.40, 0.40, 0.40, 0.00,\
						0.00, 0.00, 0.00, 1.00,\
						0.20, 0.20, 0.20, 0.00))

#undef colorcable
