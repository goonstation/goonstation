/obj/item/hive_module
	name = "hive robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS | CONDUCT
	var/list/modules = list()

/obj/item/hive_module/standard
	name = "give standard robot module"

/obj/item/hive_module/mining
	name = "HiveBot mining robot module"

/obj/item/hive_module/engineering
	name = "HiveBot engineering robot module"

/obj/item/hive_module/New()//Shit all the mods have
	src.modules += new /obj/item/device/flash(src)


/obj/item/hive_module/standard/New()
	..()
	src.modules += new /obj/item/baton/secbot(src)
	src.modules += new /obj/item/extinguisher(src)
//	var/obj/item/gun/mp5/M = new /obj/item/gun/mp5(src)


/obj/item/hive_module/mining/New()
	..()
	src.modules += new /obj/item/extinguisher(src)

	var/obj/item/rcd/R = new /obj/item/rcd(src)
	R.matter = 30
	src.modules += R

/obj/item/hive_module/engineering/New()

	src.modules += new /obj/item/extinguisher(src)

	src.modules += new /obj/item/weldingtool(src)
	src.modules += new /obj/item/wrench(src)
	src.modules += new /obj/item/crowbar(src)

	src.modules += new /obj/item/screwdriver(src)
	src.modules += new /obj/item/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)

	src.modules += new /obj/item/device/analyzer/atmospheric(src)


/obj/item/hive_module/construction/New()

	src.modules += new /obj/item/crowbar(src)
	src.modules += new /obj/item/weldingtool(src)

	var/obj/item/rcd/R = new /obj/item/rcd(src)
	R.matter = 60
	src.modules += R

	var/obj/item/sheet/M = new /obj/item/sheet(src)
	M.amount = 50
	src.modules += M

	var/obj/item/sheet/G = new /obj/item/sheet(src)
	G.amount = 50
	src.modules += G

	var/obj/item/cable_coil/W = new /obj/item/cable_coil(src)
	W.amount = 50
	src.modules += W


///obj/item/hive_module/security/New()
//	..()
//	src.modules += new /obj/item/baton/secbot(src)
//	src.modules += new /obj/item/gun/energy/laser_gun(src)

