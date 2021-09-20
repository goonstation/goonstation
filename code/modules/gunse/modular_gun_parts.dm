
/*
BASIC BROAD PART PARADIGMS:
" gun " : the reciever - determines whether it's single or double action, basic capacity (bolt or revolver), and DRM types
Barrels : largely handle how a shot behaves after leaving your gun. Spread, muzzle flash, silencing, damage modifiers.
Stocks  : everything to do with holding and interfacing the gun. Crankhandles, extra capacity, 2-handedness, and (on rare occasions) power cells go here
Mags    : entirely optional component that adds ammo capacity, but also increases jamming frequency. May affect action type by autoloading?
accssry : mall ninja bullshit. optics. gadgets. flashlights. horns. sexy nude men figurines. your pick.
*/





ABSTRACT_TYPE(/obj/item/gun_parts)
/obj/item/gun_parts/
	var/part_DRM = 0 //which gun models is this part compatible with?
	var/obj/item/gun/modular/my_gun = null
	proc/add_part_to_gun(var/obj/item/gun/modular/gun)
		my_gun = gun
		return 1
	proc/remove_part_from_gun() // should safely un-do all of add_part_to_gun()
		RETURN_TYPE(/obj/item/gun_parts/)
		my_gun = null
		return src



ABSTRACT_TYPE(/obj/item/gun_parts/barrel)
/obj/item/gun_parts/barrel/
	var/spread_angle = 0 // modifier, added to stock
	var/silenced = 0
	var/muzzle_flash = "muzzle_flash"
	var/lensing = 0 // Variable used for optical gun barrels. Scalar around 1.0
	var/jam_frequency_fire = 1 //additional % chance to jam on fire. Reload to clear.
	icon = 'icons/obj/items/items.dmi'
	icon_state = "c_tube"

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
	//add a var for a power cell later
	var/can_dual_wield = 1
	var/spread_angle = 0 // modifier, added to stock
	var/max_ammo_capacity = 0 //modifier
	var/flashbulb_only = 0 // FOSS guns only
	var/max_crank_level = 0 // FOSS guns only
	var/stock_two_handed = 0 // if gun or stock is 2 handed, whole gun is 2 handed
	var/stock_dual_wield = 1 // if gun AND stock can be dual wielded, whole gun can be dual wielded.
	var/jam_frequency_reload = 0 //attitional % chance to jam on reload. Just reload again to clear.
	var/list/ammo_list = list() // ammo that stays in the stock when removed
	icon = 'icons/obj/items/items.dmi'
	icon_state = "shovel"


	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.stock = src
		my_gun.can_dual_wield = src.can_dual_wield
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.spread_angle = max(0, (my_gun.spread_angle + src.spread_angle)) // so we cant dip below 0
		my_gun.two_handed |= src.stock_two_handed // if either the stock or the gun design is 2-handed, so is the assy.
		my_gun.can_dual_wield &= src.stock_dual_wield
		my_gun.jam_frequency_reload += src.jam_frequency_reload
		my_gun.ammo_list += src.ammo_list
		if(flashbulb_only)
			my_gun.flashbulb_only = src.flashbulb_only
			my_gun.max_crank_level = src.max_crank_level
		else
			my_gun.flashbulb_only = 0
			my_gun.max_crank_level = 0

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
		my_gun.flashbulb_only = 0
		my_gun.max_crank_level = 0
		if(my_gun.ammo_list.len)
			var/total = ((my_gun.ammo_list.len > src.max_ammo_capacity) ? max_ammo_capacity : 0)
			src.ammo_list = my_gun.ammo_list.Copy(1,(total))
			my_gun.ammo_list.Cut(1,(total))
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/magazine)
/obj/item/gun_parts/magazine/

	var/max_ammo_capacity = 0 //modifier
	var/jam_frequency_reload = 5 //additional % chance to jam on reload. Just reload again to clear.
	var/list/ammo_list = list() // ammo that stays in the mag when removed
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "ak47"

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.magazine = src
		my_gun.ammo_list += src.ammo_list
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.jam_frequency_reload += src.jam_frequency_reload

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.magazine = null
		if(my_gun.ammo_list.len)
			var/total = ((my_gun.ammo_list.len > src.max_ammo_capacity) ? max_ammo_capacity : 0)
			src.ammo_list = my_gun.ammo_list.Copy(1,(total))
			my_gun.ammo_list.Cut(1,(total))

		my_gun.max_ammo_capacity = initial(my_gun.max_ammo_capacity)
		my_gun.jam_frequency_reload = initial(my_gun.jam_frequency_reload)
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/accessory)
/obj/item/gun_parts/accessory/
	var/alt_fire = 0 //does this accessory offer an alt-mode? light perhaps?
	var/call_on_fire = 0 // does the gun call this accessory's on_fire() proc?
	icon = 'icons/obj/instruments.dmi'
	icon_state = "bike_horn"

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
/obj/item/gun_exploder/
	name = "gunsmithing anvil"
	desc = "hit it with a gun 'till the gun falls apart lmao"
	var/obj/item/gun_parts/part = null
	anchored = 1
	density = 1
	icon = 'icons/obj/dojo.dmi'
	icon_state = "anvil"

	attackby(obj/item/W as obj, mob/user as mob, params)
		if(!istype(W,/obj/item/gun/modular/) || prob(70))
			playsound(src.loc, "sound/impact_sounds/Wood_Hit_1.ogg", 70, 1)
			..()
			return
		var/obj/item/gun/modular/new_gun = W
		if(!new_gun.built)
			boutput(user, "<span class='notice'>You smash the pieces of the gun into place!</span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
			new_gun.build_gun()
			return
		else
			boutput(user, "<span class='notice'>You smash the pieces of the gun apart!</span>")
			playsound(src.loc, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
			user.u_equip(W)
			W.dropped(user)
			W.set_loc(src.loc)
			if(new_gun.barrel)
				src.part = new_gun.barrel.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.stock)
				src.part = new_gun.stock.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.magazine)
				src.part = new_gun.magazine.remove_part_from_gun()
				src.part.set_loc(src.loc)
			if(new_gun.accessory)
				src.part = new_gun.accessory.remove_part_from_gun()
				src.part.set_loc(src.loc)
			src.part = null
			new_gun.built = 0




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


// NOW WE HAVE THE INSTANCIBLE TYPES

// BASIC BARRELS

/obj/item/gun_parts/barrel/NT
	name = "standard barrel"
	desc = "A cylindrical barrel, unrifled."
	spread_angle = -13 // basic stabilisation
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN
	color = "#33FFFF"

/obj/item/gun_parts/barrel/NT/long
	name = "standard long barrel"
	desc = "A cylindrical barrel, rifled."
	spread_angle = -15

/obj/item/gun_parts/barrel/foss
	name = "\improper FOSS lensed barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = -16
	lensing = 0.9
	part_DRM = GUN_FOSS | GUN_SOVIET
	color = "#5555FF"

/obj/item/gun_parts/barrel/foss/long
	name = "\improper FOSS lensed long barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = -17
	lensing = 1.1
	part_DRM = GUN_FOSS | GUN_SOVIET

/obj/item/gun_parts/barrel/juicer
	name = "\improper BLASTA Barrel"
	desc = "A cheaply-built basic rifled barrel. Not great."
	spread_angle = -11
	jam_frequency_fire = 5 //but very poorly built
	part_DRM = GUN_JUICE | GUN_ITALIAN
	color = "#99FF99"

/obj/item/gun_parts/barrel/juicer/longer
	name = "\improper SNIPA Barrel"
	desc = "A cheaply-built extended rifled barrel. Not good."
	spread_angle = -17 // accurate??
	jam_frequency_fire = 15 //but very!!!!!!! poorly built

/obj/item/gun_parts/barrel/soviet
	name = "Сборка объектива"
	desc = "стопка линз для фокусировки вашего пистолета"
	spread_angle = -11
	lensing = 1.1
	part_DRM = GUN_FOSS | GUN_SOVIET
	color = "#FF9999"

/obj/item/gun_parts/barrel/italian
	name = "canna di fucile"
	desc = "una canna di fucile di base e di alta qualità"
	spread_angle = -9 // "alta qualità"
	part_DRM = GUN_JUICE | GUN_ITALIAN
	color = "#FFFF99"

// BASIC STOCKS
/obj/item/gun_parts/stock/NT
	name = "standard grip"
	desc = "A comfortable NT pistol grip"
	spread_angle = -2 // basic stabilisation
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN
	color = "#33FFFF"

/obj/item/gun_parts/stock/NT/shoulder
	name = "standard stock"
	desc = "A comfortable NT shoulder stock"
	spread_angle = -5 // better stabilisation
	stock_two_handed = 1
	can_dual_wield = 0
	max_ammo_capacity = 1 // additional shot in the butt
	jam_frequency_reload = 2 // a little more jammy
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN

/obj/item/gun_parts/stock/foss
	name = "\improper FOSS laser stock"
	desc = "An open-sourced laser dynamo, with a multiple-position winding spring."
	spread_angle = -2 // basic stabilisation
	part_DRM = GUN_FOSS | GUN_SOVIET
	flashbulb_only = 1
	max_crank_level = 2
	color = "#5555FF"

/obj/item/gun_parts/stock/foss/long
	name = "\improper FOSS laser rifle stock"
	spread_angle = -5 // better stabilisation
	stock_two_handed = 1
	can_dual_wield = 0
	max_crank_level = 3 // for syndicate ops


/obj/item/gun_parts/stock/italian
	name = "impugnatura a pistola"
	desc = "un'impugnatura rivestita in cuoio toscano per un revolver di alta qualità"
	max_ammo_capacity = 3 // to make that revolver revolve!
	jam_frequency_reload = 7 // a lot  more jammy!!
	part_DRM = GUN_ITALIAN | GUN_JUICE | GUN_SOVIET
	color = "#FFFF99"



// BASIC ACCESSORIES
	// flashlight!!
	// grenade launcher!!
	// a horn!!
/obj/item/gun_parts/accessory/horn
	name = "Tactical Alerter"
	desc = "Efficiently alerts your squadron within miliseconds of target engagement, using cutting edge over-the-airwaves technology"
	call_on_fire = 1

	on_fire()
		playsound(src.my_gun.loc, pick('sound/musical_instruments/Bikehorn_bonk1.ogg', 'sound/musical_instruments/Bikehorn_bonk2.ogg', 'sound/musical_instruments/Bikehorn_bonk3.ogg'), 50, 1, -1)


// No such thing as a basic magazine! they're all bullshit!!
/obj/item/gun_parts/magazine/juicer
	name = "HOTT SHOTTS MAG"
	desc = "Holds 3 rounds, and 30,000 followers."
	max_ammo_capacity = 3
	jam_frequency_reload = 8

/obj/item/gun_parts/magazine/juicer/bigger
	name = "HOTTER SHOTTS MAG"
	desc = "Holds 5 rounds, and 50,000 followers."
	max_ammo_capacity = 5
	jam_frequency_reload = 10

/obj/item/gun_parts/magazine/juicer/massive
	name = "HOTTEST SHOTTS MAG"
	desc = "Holds 6 rounds, and 69,000 followers."
	max_ammo_capacity = 6
	jam_frequency_reload = 13
