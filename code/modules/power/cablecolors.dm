#define colorcable(_color, _hexcolor)\
/obj/item/cable_coil/colored/_color;\
/obj/item/cable_coil/colored/_color/name = ""+#_color+"-colored cable coil";\
/obj/item/cable_coil/colored/_color/base_name = ""+#_color+"-colored cable coil";\
/obj/item/cable_coil/colored/_color/stack_type = /obj/item/cable_coil/colored/_color;\
/obj/item/cable_coil/colored/_color/spawn_insulator_name = ""+#_color+"rubber";\
/obj/item/cable_coil/colored/_color/cable_obj_type = /obj/cable/colored/_color;\
/obj/item/cable_coil/colored/_color/cut;\
/obj/item/cable_coil/colored/_color/cut/icon_state = "coil2";\
/obj/item/cable_coil/colored/_color/cut/New(loc, length)\
{if (length){..(loc, length)};else{..(loc, rand(1,2))};}\
/obj/item/cable_coil/colored/_color/cut/small;\
/obj/item/cable_coil/colored/_color/cut/small/New(loc, length){..(loc, rand(1,5))};\
/obj/cable/colored/_color;\
/obj/cable/colored/_color/name = ""+#_color+"-colored power cable";\
/obj/cable/colored/_color/color = _hexcolor;\
/obj/cable/colored/_color/insulator_default = ""+#_color+"rubber";\
/datum/material/fabric/synthrubber/colored/_color;\
/datum/material/fabric/synthrubber/colored/_color/mat_id = ""+#_color+"rubber";\
/datum/material/fabric/synthrubber/colored/_color/name = ""+#_color+"rubber";\
/datum/material/fabric/synthrubber/colored/_color/desc = ""+"A type of synthetic rubber. This one is "+#_color+".";\
/datum/material/fabric/synthrubber/colored/_color/color = _hexcolor;\
/obj/item/storage/box/cablesbox/colored/_color;\
/obj/item/storage/box/cablesbox/colored/_color/name = ""+"electrical cables storage ("+#_color+")";\
/obj/item/storage/box/cablesbox/colored/_color/spawn_contents = list(/obj/item/cable_coil/colored/_color = 7);\
/datum/supply_packs/electrical/_color;\
/datum/supply_packs/electrical/_color/name = ""+"Electrical Supplies Crate ("+#_color+") - 2 pack";\
/datum/supply_packs/electrical/_color/desc = ""+"x2 Cabling Box - "+#_color+" (14 cable coils total)";\
/datum/supply_packs/electrical/_color/contains = list(/obj/item/storage/box/cablesbox/colored/_color = 2);\
/datum/supply_packs/electrical/_color/containername = ""+"Electrical Supplies Crate ("+#_color+")- 2 pack"

colorcable(yellow, "#EED202")
colorcable(orange, "#C46210")
colorcable(blue, "#72A0C1")
colorcable(green, "#00AD83")
colorcable(purple, "#9370DB")
colorcable(black, "#414A4C")
colorcable(hotpink, "#FF69B4")
colorcable(brown, "#832A0D")
colorcable(white, "#EDEAE0")

#undef colorcable
