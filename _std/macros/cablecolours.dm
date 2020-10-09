#define colourcable(_colour, _hexcolour)\
/obj/item/cable_coil/coloured/_colour;\
/obj/item/cable_coil/coloured/_colour/name = ""+#_colour+"-coloured cable coil";\
/obj/item/cable_coil/coloured/_colour/base_name = ""+#_colour+"-coloured cable coil";\
/obj/item/cable_coil/coloured/_colour/stack_type = /obj/item/cable_coil/coloured/_colour;\
/obj/item/cable_coil/coloured/_colour/spawn_insulator_name = ""+#_colour+"rubber";\
/obj/item/cable_coil/coloured/_colour/cable_obj_type = /obj/cable/coloured/_colour;\
/obj/item/cable_coil/coloured/_colour/cut;\
/obj/item/cable_coil/coloured/_colour/cut/icon_state = "coil2";\
/obj/item/cable_coil/coloured/_colour/cut/New(loc, length)\
{if (length){..(loc, length)};else{..(loc, rand(1,2))};}\
/obj/item/cable_coil/coloured/_colour/cut/small;\
/obj/item/cable_coil/coloured/_colour/cut/small/New(loc, length){..(loc, rand(1,5))};\
/obj/cable/coloured/_colour;\
/obj/cable/coloured/_colour/name = ""+#_colour+"-coloured power cable";\
/obj/cable/coloured/_colour/colour = _hexcolour;\
/obj/cable/coloured/_colour/insulator_default = ""+#_colour+"rubber";\
/datum/material/fabric/synthrubber/coloured/_colour;\
/datum/material/fabric/synthrubber/coloured/_colour/mat_id = ""+#_colour+"rubber";\
/datum/material/fabric/synthrubber/coloured/_colour/name = ""+#_colour+"rubber";\
/datum/material/fabric/synthrubber/coloured/_colour/desc = ""+"A type of synthetic rubber. This one is "+#_colour+".";\
/datum/material/fabric/synthrubber/coloured/_colour/colour = _hexcolour;\
/obj/item/storage/box/cablesbox/coloured/_colour;\
/obj/item/storage/box/cablesbox/coloured/_colour/desc = "x2 "+#_colour+" Cabling Box (14 cable coils total)";\
/obj/item/storage/box/cablesbox/coloured/_colour/spawn_contents = list(/obj/item/cable_coil/+#_colour+ = 7);\
/datum/supply_packs/electrical/_colour;\
/datum/supply_packs/electrical/_colour/name = ""+#_colour+-"Electrical Supplies Crate - 2 pack";\
/datum/supply_packs/electrical/_colour/desc = "x2 "+#_colour+" Cabling Box (14 cable coils total)";\
/datum/supply_packs/electrical/_colour/contains = list(/obj/item/storage/box/+#_colour+ = 2);\
/datum/supply_packs/electrical/_colour/containername = ""+#_colour+"-Coloured Electrical Supplies Crate - 2 pack"

colourcable(yellow, "#EED202")
colourcable(orange, "#C46210")
colourcable(blue, "#72A0C1")
colourcable(green, "#00AD83")
colourcable(purple, "#9370DB")
colourcable(black, "#414A4C")
colourcable(hotpink, "#FF69B4")
colourcable(brown, "#832A0D")
colourcable(white, "#EDEAE0")

///datum/supply_packs/electrical/yellow
//	name = "Yellow-Coloured Electrical Supplies Crate - 2 pack"
//	desc = "x2 Yellow Cabling Box (14 cable coils total)"
//	contains = list(/obj/item/storage/box/cablesbox/coloured/yellow = 2)
//	containername = "Yellow-Coloured Electrical Supplies Crate - 2 pack"
//obj/item/storage/box/cablesbox/coloured/yellow
//	name = "yellow-coloured electrical cables storage"
//	spawn_contents = list(/obj/item/cable_coil/coloured/yellow = 7)
