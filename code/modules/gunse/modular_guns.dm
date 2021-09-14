/*
 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄                 ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄        ▄  ▄▄▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌               ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░▌      ▐░▌▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌               ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌▐░▌░▌     ▐░▌▐░█▀▀▀▀▀▀▀▀▀
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌          ▐░▌       ▐░▌▐░▌▐░▌    ▐░▌▐░▌
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌ ▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌▐░▌ ▐░▌   ▐░▌▐░█▄▄▄▄▄▄▄▄▄
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌▐░░░░░░░░▌▐░▌       ▐░▌▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌ ▀▀▀▀▀▀█░▌▐░▌       ▐░▌▐░▌   ▐░▌ ▐░▌ ▀▀▀▀▀▀▀▀▀█░▌
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌               ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌    ▐░▌▐░▌          ▐░▌
▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄      ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌     ▐░▐░▌ ▄▄▄▄▄▄▄▄▄█░▌
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌      ▐░░▌▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀        ▀▀  ▀▀▀▀▀▀▀▀▀▀▀

a new modular gunning system
every /obj/item/gun/modular/ has some basic stats and some basic shooting behavior. Nothing super complex.
by default all children of /obj/item/gun/modular/ should populate their own barrel/stock/magazine/accessory as appropriate
with some ordinary basic parts. barrel and mag are necessary, the other two whatever.
additional custom parts can be created with stat bonuses, and other effects in their add_part_to_gun() proc

*/
#define GUN_NANO 1
#define GUN_FOSS 2
#define GUN_JUICE 4
#define GUN_SOVIET 8
#define GUN_ITALIAN 16

ABSTRACT_TYPE(/obj/item/gun/modular)
/obj/item/gun/modular/ // PARENT TYPE TO ALL MODULER GUN'S
	var/gun_DRM = 0 // identify the gun model / type
	var/obj/item/gun_parts/barrel/barrel = null
	var/obj/item/gun_parts/stock/stock = null
	var/obj/item/gun_parts/magazine/magazine = null
	var/obj/item/gun_parts/accessory/accessory = null
	var/list/obj/item/gun_parts/parts = list()

	var/lensing = 0 // Variable used for optical gun barrels. laser intensity scales around 1.0

	var/flashbulb_only = 0 // FOSS guns only
	var/obj/item/ammo/flashbulb/flashbulb = null // FOSS guns only
	var/max_crank_level = 0 // FOSS guns only
	var/crank_level = 0 // FOSS guns only

	var/auto_eject = 0 // Do we eject casings on firing, or on reload?
	var/casings_to_eject = 0 // kee ptrack
	var/max_ammo_capacity = 1 // How much ammo can this gun hold? Don't make this null (Convair880).
	var/caliber = null // Can be a list too. The .357 Mag revolver can also chamber .38 Spc rounds, for instance (Convair880).

	var/accessory_alt = 0 //does the accessory offer an alternative firing mode?
	var/accessory_on_fire = 0 // does the accessory need to know when you fire?

	var/jam_frequency_reload = 1 //base % chance to jam on reload. Just reload again to clear.
	var/jam_frequency_fire = 1 //base % chance to jam on fire. Reload to clear.

	two_handed = 0
	can_dual_wield = 1


	New()
		..()
		build_gun()

ABSTRACT_TYPE(/obj/item/gun_parts)
/obj/item/gun_parts/
	var/part_DRM = 0 //which gun models is this part compatible with?
	var/obj/item/gun/modular/my_gun = null
	proc/add_part_to_gun(var/obj/item/gun/modular/gun)
		my_gun = gun
		return 1
	proc/remove_part_from_gun() // should safely un-do all of add_part_to_gun()
		my_gun = null
		return src

/obj/item/ammo/flashbulb // FOSS guns multi-use ammo thing!
	name = "cathodic arc tube"
	desc = "A sturdy glass vaccum tube filled with a special gas for producing bright arc flashes. Goes in laser guns."
	var/amount_left = 50



ABSTRACT_TYPE(/obj/item/gun_parts/barrel)
/obj/item/gun_parts/barrel/
	var/spread_angle = 0 // modifier, added to stock
	var/silenced = 0
	var/muzzle_flash = "muzzle_flash"
	var/lensing = 0 // Variable used for optical gun barrels. Scalar around 1.0
	var/jam_frequency_fire = 1 //additional % chance to jam on fire. Reload to clear.

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.barrel = src
		my_gun.spread_angle = max(0, (my_gun.spread_angle + src.spread_angle)) // so we cant dip below 0
		my_gun.silenced = src.silenced
		my_gun.muzzle_flash = src.muzzle_flash
		my_gun.lensing = src.lensing
		my_gun.jam_frequency_fire += src.jam_frequency_fire

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.barrel = null
		my_gun.spread_angle = initial(my_gun.spread_angle)
		my_gun.silenced = initial(my_gun.silenced)
		my_gun.muzzle_flash = initial(my_gun.muzzle_flash)
		my_gun.lensing = initial(my_gun.lensing)
		my_gun.jam_frequency_fire = initial(my_gun.jam_frequency_fire)
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/stock)
/obj/item/gun_parts/stock/
	var/can_dual_wield = 1
	var/spread_angle = 0 // modifier, added to stock
	var/max_ammo_capacity = 0 //modifier
	var/max_crank_level = 0 // FOSS guns only
	var/stock_two_handed = 0 // if gun or stock is 2 handed, whole gun is 2 handed
	var/stock_dual_wield = 1 // if gun AND stock can be dual wielded, whole gun can be dual wielded.
	var/jam_frequency_reload = 0 //attitional % chance to jam on reload. Just reload again to clear.


	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.stock = src
		my_gun.can_dual_wield = src.can_dual_wield
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.max_crank_level = src.max_crank_level
		my_gun.spread_angle = max(0, (my_gun.spread_angle + src.spread_angle)) // so we cant dip below 0
		my_gun.two_handed |= src.stock_two_handed // if either the stock or the gun design is 2-handed, so is the assy.
		my_gun.can_dual_wield &= src.stock_dual_wield
		my_gun.jam_frequency_reload += src.jam_frequency_reload

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.stock = null
		my_gun.can_dual_wield = initial(my_gun.can_dual_wield)
		my_gun.max_ammo_capacity = initial(my_gun.max_ammo_capacity)
		my_gun.max_crank_level = 0
		my_gun.spread_angle = initial(my_gun.spread_angle)
		my_gun.two_handed = initial(my_gun.two_handed)
		my_gun.can_dual_wield = initial(my_gun.can_dual_wield)
		my_gun.jam_frequency_reload = initial(my_gun.jam_frequency_reload)
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/magazine)
/obj/item/gun_parts/magazine/

	var/datum/projectile/current_projectile = null
	var/list/projectiles = null
	var/max_ammo_capacity = 0 //modifier
	var/jam_frequency_reload = 5 //additional % chance to jam on reload. Just reload again to clear.

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.magazine = src
		my_gun.current_projectile = src.current_projectile
		my_gun.projectiles = src.projectiles
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.jam_frequency_reload += src.jam_frequency_reload

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.magazine = null
		my_gun.current_projectile = initial(my_gun.current_projectile)
		my_gun.projectiles = initial(my_gun.projectiles)
		my_gun.max_ammo_capacity = initial(my_gun.max_ammo_capacity)
		my_gun.jam_frequency_reload = initial(my_gun.jam_frequency_reload)
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/accessory)
/obj/item/gun_parts/accessory/
	var/alt_fire = 0 //does this accessory offer an alt-mode? light perhaps?
	var/call_on_fire = 0 // does the gun call this accessory's on_fire() proc?

	proc/alt_fire()
		return alt_fire

	proc/on_fire()
		return call_on_fire

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.accessory = src
		my_gun.accessory_alt = alt_fire
		my_gun.accessory_on_fire = call_on_fire


	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.accessory = null
		my_gun.accessory_alt = 0
		my_gun.accessory_on_fire = 0
		. = ..()


/obj/item/gun/modular/proc/build_gun()
	parts = list()
	if(barrel)
		parts += barrel
	if(stock)
		parts += stock
	if(magazine)
		parts += magazine
	if(accessory)
		parts += accessory

	for(var/obj/item/gun_parts/part as anything in parts)
		if(src.gun_DRM & part.part_DRM)
			part.add_part_to_gun(src)

	//update the icon to match!!!!!


// THIS NEXT PART MIGHT B STUPID
/*
ABSTRACT_TYPE(/obj/item/storage/gun_workbench/)
/obj/item/storage/gun_workbench/
	slots = 1
	var/part = null
	var/gun_DRM = 0
	var/partname = "nothing"
	max_wclass = 4

	barrel
		part = /obj/item/gun_parts/barrel/
		partname = "barrel"
	stock
		part = /obj/item/gun_parts/stock/
		partname = "stock"
	magazine
		part = /obj/item/gun_parts/magazine/
		partname = "magazine"
	accessory
		part = /obj/item/gun_parts/accessory/
		partname = "doodad"

	check_can_hold(obj/item/W)
		if(!istype(W,part))
			boutput(usr, "You can only place a [src.partname] here!")
			return
		else
			var/obj/item/gun_parts/new_part = W
			if(new_part.part_DRM & gun_DRM)
				..()
			else
				boutput(usr, "That part isn't compatible with your gun!")
				return
*/
//told u
/obj/table/gun_workbench/
	name = "gunsmithing workbench"
	desc = "lay down a rifle and start swappin bits"

	var/list/obj/item/gun_parts/parts = list()
	var/obj/item/gun/modular/gun = null
	var/obj/item/gun_parts/barrel/barrel = null
	var/obj/item/gun_parts/stock/stock = null
	var/obj/item/gun_parts/magazine/magazine = null
	var/obj/item/gun_parts/accessory/accessory = null
	var/gun_DRM = 0

	New()
		..()


	attackby(obj/item/W as obj, mob/user as mob, params)
		if(gun)
			boutput(user, "<span class='notice'>There's already a gun on [src].</span>")
			return
		if(!istype(W,/obj/item/gun/modular/))
			boutput(user, "<span class='notice'>You should probably only use this for guns.</span>")
			return
		else
			boutput(user, "<span class='notice'>You secure [W] on [src].</span>")
			//ok its a modular gun!
			//open the gunsmithing menu (cross-shaped inventory thing) and let the user swap parts around in it
			// when they're done, put the parts back in the gun's slots and call gun.build_gun()
			load_gun(W)
			return

	attack_hand(mob/user)
		if(!gun)
			boutput(user, "<span class='notice'>You need to put a gun on [src] first.</span>")
			return
		else
			//open gunsmithing menu
			return

	proc/load_gun(var/obj/item/gun/modular/new_gun)
		src.gun = new_gun
		src.parts = new_gun.parts

		//update DRM for the storage slots.
		src.gun_DRM = new_gun.gun_DRM

		//place parts in the storage slots
		if(new_gun.barrel)
			src.barrel = new_gun.barrel.remove_part_from_gun()
		if(new_gun.stock)
			src.stock = new_gun.stock.remove_part_from_gun()
		if(new_gun.magazine)
			src.magazine = new_gun.magazine.remove_part_from_gun()
		if(new_gun.accessory)
			src.accessory = new_gun.accessory.remove_part_from_gun()

		//update icon
//real stupid
	proc/open_gunsmithing_menu()
		//dear smart people please do
		return

	proc/remove_gun(mob/user as mob)
		//add parts to gun // this is gonna runtime you dipshit
		gun.barrel = src.barrel
		gun.stock = src.stock
		gun.magazine = src.magazine
		gun.accessory = src.accessory

		//dispense gun
		gun.build_gun()
		user.put_in_hand_or_drop(gun)

		//clear table
		gun = null
		barrel.contents = null
		stock.contents = null
		magazine.contents = null
		accessory = null


// BASIC GUN'S

/obj/item/gun/modular/NT
	name = "\improper NanoTrasen standard pistolet"
	desc = "A simple, reliable cylindrical bored weapon."
	max_ammo_capacity = 1 // single-shot pistols ha- unless you strap an expensive loading mag on it.
	gun_DRM = GUN_NANO
	spread_angle = 20 // value without a barrel. Add one to keep things in line.

/obj/item/gun/modular/foss // syndicate laser gun's!
	name = "\improper FOSS laser gun"
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/19"
	max_ammo_capacity = 1 // just takes a flash bulb.
	gun_DRM = GUN_FOSS
	spread_angle = 20 // value without a barrel. Add one to keep things in line.

/obj/item/gun/modular/juicer
	name = "\improper RAD BLASTA"
	desc = "A juicer-built, juicer-'designed', and most importantly juicer-marketed gun."
	max_ammo_capacity = 0 //fukt up mags only
	gun_DRM = GUN_JUICE
	spread_angle = 30 // value without a barrel. Add one to keep things in line.

/obj/item/gun/modular/soviet
	name = "лазерная пушка"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	max_ammo_capacity = 6 // laser revolver
	gun_DRM = GUN_SOVIET
	spread_angle = 25 // value without a barrel. Add one to keep things in line.

/obj/item/gun/modular/italian
	name = "cannone di qualità"
	desc = "Una pistola realizzata con acciaio, cuoio e olio d'oliva della più alta qualità possibile."
	max_ammo_capacity = 2 // basic revolving mechanism
	gun_DRM = GUN_ITALIAN
	spread_angle = 25 // value without a barrel. Add one to keep things in line.

// BASIC BARRELS

/obj/item/gun_parts/barrel/NT
	name = "standard barrel"
	desc = "A cylindrical barrel, unrifled."
	spread_angle = -10 // basic stabilisation
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN

/obj/item/gun_parts/barrel/foss
	name = "\improper FOSS Lensed Barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = -15
	lensing = 0.9
	part_DRM = GUN_FOSS | GUN_SOVIET

/obj/item/gun_parts/barrel/juicer
	name = "\improper BLASTA Barrel"
	desc = "A cheaply-built basic rifled barrel. Not great."
	spread_angle = -13 //decent stabilisation
	jam_frequency_fire = 5 //but very poorly built
	part_DRM = GUN_JUICE | GUN_ITALIAN

/obj/item/gun_parts/barrel/soviet
	name = "Сборка объектива"
	desc = "стопка линз для фокусировки вашего пистолета"
	spread_angle = -10
	lensing = 1.1
	part_DRM = GUN_FOSS | GUN_SOVIET

/obj/item/gun_parts/barrel/italian
	name = "canna di fucile"
	desc = "una canna di fucile di base e di alta qualità"
	spread_angle = -7 // "alta qualità"
	part_DRM = GUN_JUICE | GUN_ITALIAN

// BASIC STOCKS
/obj/item/gun_parts/stock/NT
	name = "standard grip"
	desc = "A comfortable NT pistol grip"
	spread_angle = -2 // basic stabilisation
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN

/obj/item/gun_parts/stock/NT_shoulder
	name = "standard stock"
	desc = "A comfortable NT shoulder stock"
	spread_angle = -5 // better stabilisation
	stock_two_handed = 1
	can_dual_wield = 0
	max_ammo_capacity = 1 // additional shot in the butt
	jam_frequency_reload = 2 // a little more jammy
	part_DRM = GUN_NANO | GUN_JUICE

/obj/item/gun_parts/stock/italian
	name = "impugnatura a pistola"
	desc = "un'impugnatura rivestita in cuoio toscano per un revolver di alta qualità"
	max_ammo_capacity = 3 // to make that revolver revolve!
	jam_frequency_reload = 7 // a lot  more jammy!!
	part_DRM = GUN_ITALIAN | GUN_JUICE

// BASIC ACCESSORIES
	// flashlight!!
	// grenade launcher!!
	// a horn!!

// No such thing as a basic magazine! they're all bullshit!!
