#define colorcable(_color, _hexcolor)\
/obj/item/cable_coil/coloured/_color;\
/obj/item/cable_coil/coloured/_color/name = ""+#_color+"-coloured cable coil";\
/obj/item/cable_coil/coloured/_color/base_name = ""+#_color+"-coloured cable coil";\
/obj/item/cable_coil/coloured/_color/stack_type = /obj/item/cable_coil/coloured/_color;\
/obj/item/cable_coil/coloured/_color/spawn_insulator_name = ""+#_color+"rubber";\
/obj/item/cable_coil/coloured/_color/cable_obj_type = /obj/cable/coloured/_color;\
/obj/item/cable_coil/coloured/_color/cut;\
/obj/item/cable_coil/coloured/_color/cut/icon_state = "coil2";\
/obj/item/cable_coil/coloured/_color/cut/New(loc, length)\
{if (length){..(loc, length)};else{..(loc, rand(1,2))};}\
/obj/item/cable_coil/coloured/_color/cut/small;\
/obj/item/cable_coil/coloured/_color/cut/small/New(loc, length){..(loc, rand(1,5))};\
/obj/cable/coloured/_color;\
/obj/cable/coloured/_color/name = ""+#_color+"-coloured power cable";\
/obj/cable/coloured/_color/color = _hexcolor;\
/obj/cable/coloured/_color/insulator_default = ""+#_color+"rubber";\
/datum/material/fabric/synthrubber/coloured/_color;\
/datum/material/fabric/synthrubber/coloured/_color/mat_id = ""+#_color+"rubber";\
/datum/material/fabric/synthrubber/coloured/_color/name = ""+#_color+"rubber";\
/datum/material/fabric/synthrubber/coloured/_color/desc = ""+"A type of synthetic rubber. This one is "+#_color+".";\
/datum/material/fabric/synthrubber/coloured/_color/color = _hexcolor

colorcable(yellow, "#EED202")
colorcable(orange, "#C46210")
colorcable(blue, "#72A0C1")
colorcable(green, "#00AD83")
colorcable(purple, "#9370DB")
colorcable(black, "#414A4C")
colorcable(hotpink, "#FF69B4")
colorcable(brown, "#832A0D")
colorcable(white, "#EDEAE0")
