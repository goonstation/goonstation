#define colorcable(_color, _hexcolor)\
/obj/item/cable_coil/_color;\
/obj/item/cable_coil/_color/name = ""+#_color+" cable coil";\
/obj/item/cable_coil/_color/base_name = ""+#_color+" cable coil";\
/obj/item/cable_coil/_color/stack_type = /obj/item/cable_coil/_color;\
/obj/item/cable_coil/_color/spawn_insulator_name = ""+#_color+"rubber";\
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
/obj/cable/_color/insulator_default = ""+#_color+"rubber";\
/datum/material/fabric/synthrubber/_color;\
/datum/material/fabric/synthrubber/_color/mat_id = ""+#_color+"rubber";\
/datum/material/fabric/synthrubber/_color/name = ""+#_color+"rubber";\
/datum/material/fabric/synthrubber/_color/desc = ""+"A type of synthetic rubber. This one is "+#_color+".";\
/datum/material/fabric/synthrubber/_color/color = _hexcolor;\
/obj/item/storage/box/cablesbox/_color;\
/obj/item/storage/box/cablesbox/_color/name = ""+"electrical cables storage ("+#_color+")";\
/obj/item/storage/box/cablesbox/_color/spawn_contents = list(/obj/item/cable_coil/_color = 7);\
/datum/supply_packs/electrical/_color;\
/datum/supply_packs/electrical/_color/name = ""+"Electrical Supplies Crate ("+#_color+") - 2 pack";\
/datum/supply_packs/electrical/_color/desc = ""+"x2 Cabling Box - "+#_color+" (14 cable coils total)";\
/datum/supply_packs/electrical/_color/contains = list(/obj/item/storage/box/cablesbox/_color = 2);\
/datum/supply_packs/electrical/_color/containername = ""+"Electrical Supplies Crate ("+#_color+")- 2 pack";\
/obj/cablespawner/_color;\
/obj/cablespawner/_color/name = ""+#_color+" power cable";\
/obj/cablespawner/_color/color = _hexcolor;\
/obj/cablespawner/_color/cable_type = /obj/cable/_color;\
/obj/cablespawner/_color/node;\
/obj/cablespawner/_color/node/name = "node "+#_color+" cable spawner";\
/obj/cablespawner/_color/node/override_centre_connection = TRUE;\
/obj/cablespawner/_color/node/icon_state = "superstate-node"

colorcable(yellow, "#fffb00")
colorcable(orange, "#FF5D06")
colorcable(blue, "#009ae7")
colorcable(green, "#03c53d")
colorcable(purple, "#9b59b6")
colorcable(black, "#272e30")
colorcable(hotpink, "#FF69B4")
colorcable(brown, "#633221")
colorcable(white, "#ffffff")

#undef colorcable
