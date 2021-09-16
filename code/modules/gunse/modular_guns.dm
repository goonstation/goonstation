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


ABSTRACT_TYPE(/obj/item/gun/modular)
/obj/item/gun/modular/ // PARENT TYPE TO ALL MODULER GUN'S
	var/gun_DRM = 0 // identify the gun model / type
	var/obj/item/gun_parts/barrel/barrel = null
	var/obj/item/gun_parts/stock/stock = null
	var/obj/item/gun_parts/magazine/magazine = null
	var/obj/item/gun_parts/accessory/accessory = null
	var/list/obj/item/gun_parts/parts = list()
	icon_state = "tranq_pistol"



	var/lensing = 0 // Variable used for optical gun barrels. laser intensity scales around 1.0

	var/flashbulb_only = 0 // FOSS guns only
	var/obj/item/ammo/flashbulb/flashbulb = null // FOSS guns only
	var/max_crank_level = 0 // FOSS guns only
	var/crank_level = 0 // FOSS guns only

	var/auto_eject = 0 // Do we eject casings on firing, or on reload?
	var/casings_to_eject = 0 // kee ptrack
	var/max_ammo_capacity = 1 // How much ammo can this gun hold? Don't make this null (Convair880).
	var/list/ammo_list = list() // a list of datum/projectile types
	current_projectile = null // chambered round

	var/accessory_alt = 0 //does the accessory offer an alternative firing mode?
	var/accessory_on_fire = 0 // does the accessory need to know when you fire?

	var/jam_frequency_reload = 1 //base % chance to jam on reload. Just reload again to clear.
	var/jam_frequency_fire = 1 //base % chance to jam on fire. Reload to clear.
	var/jammed = 0


	two_handed = 0
	can_dual_wield = 1


	New()
		..()
		build_gun()

/obj/item/gun/modular/attackby(var/obj/item/I as obj, mob/user as mob)
	if (istype(I, /obj/item/stackable_ammo))
		var/obj/item/stackable_ammo/SA = I
		SA.reload(src)
		return
	..()

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
	var/list/ammo_list = list() // ammo that stays in the stock when removed


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
		my_gun.ammo_list += src.ammo_list

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
		if(my_gun.ammo_list.len)
			var/total = ((my_gun.ammo_list.len > src.max_ammo_capacity) ? max_ammo_capacity : 0)
			src.ammo_list = my_gun.ammo_list.Copy(1,(total))
			my_gun.ammo_list.Cut(1,(total))
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/magazine)
/obj/item/gun_parts/magazine/

	var/datum/projectile/current_projectile = null
	var/list/projectiles = null
	var/max_ammo_capacity = 0 //modifier
	var/jam_frequency_reload = 5 //additional % chance to jam on reload. Just reload again to clear.
	var/list/ammo_list = list() // ammo that stays in the mag when removed

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

/obj/item/gun/modular/process_ammo(mob/user)
	if(jammed)
		boutput(user,"<span class='notice'><b>You clear the ammunition jam.</b></span>")
		jammed = 0
		playsound(src.loc, "sound/weapons/gunload_heavy.ogg", 40, 1)
		return
	if(!ammo_list.len) // empty!
		playsound(src.loc, "sound/weapons/Gunclick.ogg", 40, 1)
		return
	if(ammo_list.len > max_ammo_capacity)
		var/waste = ammo_list.len - max_ammo_capacity
		ammo_list.Cut(1,(1 + waste))
		boutput(user,"<span class='alert'><b>Error! Storage space low! Deleting [waste] ammunition...</b></span>")
		playsound(src.loc, 'sound/items/mining_drill.ogg', 20, 1,0,0.8)

	if(!ammo_list.len) // empty! again!! just in case max ammo capacity was 0!!!
		playsound(src.loc, "sound/weapons/Gunclick.ogg", 40, 1)
		return

	if(current_projectile) // chamber is loaded
		return

	if(prob(jam_frequency_reload))
		jammed = 1
		boutput(user,"<span class='alert'><b>Error! Jam detected!</b></span>")
		playsound(src.loc, "sound/weapons/trayhit.ogg", 60, 1)
		return
	else
		current_projectile = unpool(ammo_list[ammo_list.len]) // last one goes in
		ammo_list.Remove(ammo_list[ammo_list.len]) //and remove it from the list
		playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)


/obj/item/gun/modular/attack_self(mob/user)
	src.visible_message("<span class='alert'><b>debug: reloading i guess </b></span>")
	process_ammo(user)

/obj/item/gun/modular/canshoot()
	if(jammed)
		return 0
	if(current_projectile)
		return 1
	return 0

/obj/item/gun/modular/shoot(var/target,var/start,var/mob/user,var/POX,var/POY,var/is_dual_wield)
	if (isghostdrone(user))
		user.show_text("<span class='combat bold'>Your internal law subroutines kick in and prevent you from using [src]!</span>")
		return FALSE
	if (!canshoot())
		if (ismob(user))
			user.show_text("*click* *click*", "red") // No more attack messages for empty guns (Convair880).
			if (!silenced)
				playsound(user, "sound/weapons/Gunclick.ogg", 60, 1)
		return FALSE
	if (!isturf(target) || !isturf(start))
		return FALSE
	if (!istype(src.current_projectile,/datum/projectile/))
		return FALSE

	if (src.muzzle_flash)
		if (isturf(user.loc))
			var/turf/origin = user.loc
			muzzle_flash_attack_particle(user, origin, target, src.muzzle_flash)


	if (ismob(user))
		var/mob/M = user
		if (M.mob_flags & AT_GUNPOINT)
			for(var/obj/item/grab/gunpoint/G in M.grabbed_by)
				G.shoot()
		if(slowdown)
			SPAWN_DBG(-1)
				M.movement_delay_modifier += slowdown
				sleep(slowdown_time)
				M.movement_delay_modifier -= slowdown

	if(prob(jam_frequency_fire))
		jammed = 1
		user.show_text("*clunk* *clack*", "red")
		playsound(user, "sound/impact_sounds/Generic_Click_1.ogg", 60, 1)


	var/spread = is_dual_wield*10
	if (user.reagents)
		var/how_drunk = 0
		var/amt = user.reagents.get_reagent_amount("ethanol")
		switch(amt)
			if (110 to INFINITY)
				how_drunk = 2
			if (1 to 110)
				how_drunk = 1
		how_drunk = max(0, how_drunk - isalcoholresistant(user) ? 1 : 0)
		spread += 5 * how_drunk
	spread = max(spread, spread_angle)

	var/obj/projectile/P = shoot_projectile_ST_pixel_spread(user, current_projectile, target, POX, POY, spread, alter_proj = new/datum/callback(src, .proc/alter_projectile))
	if (P)
		P.forensic_ID = src.forensic_ID

	if(user && !suppress_fire_msg)
		if(!src.silenced)
			for(var/mob/O in AIviewers(user, null))
				O.show_message("<span class='alert'><B>[user] fires [src] at [target]!</B></span>", 1, "<span class='alert'>You hear a gunshot</span>", 2)
		else
			if (ismob(user)) // Fix for: undefined proc or verb /obj/item/mechanics/gunholder/show text().
				user.show_text("<span class='alert'>You silently fire the [src] at [target]!</span>") // Some user feedback for silenced guns would be nice (Convair880).

		var/turf/T = target
		src.log_shoot(user, T, P)

	SEND_SIGNAL(user, COMSIG_CLOAKING_DEVICE_DEACTIVATE)

	if (ismob(user))
		var/mob/M = user
		if (ishuman(M) && src.add_residue) // Additional forensic evidence for kinetic firearms (Convair880).
			var/mob/living/carbon/human/H = user
			H.gunshot_residue = 1

	current_projectile = null // empty chamber

	src.update_icon()
	return TRUE

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

	process_ammo()

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

	New()
		barrel = new /obj/item/gun_parts/barrel/NT(src)
		stock = new /obj/item/gun_parts/stock/NT(src)
		..()

/obj/item/gun/modular/foss // syndicate laser gun's!
	name = "\improper FOSS laser gun"
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/19"
	max_ammo_capacity = 1 // just takes a flash bulb.
	gun_DRM = GUN_FOSS
	spread_angle = 20 // value without a barrel. Add one to keep things in line.

	New()
		barrel = new /obj/item/gun_parts/barrel/foss(src)
		stock = new /obj/item/gun_parts/stock(src)
		..()

/obj/item/gun/modular/juicer
	name = "\improper RAD BLASTA"
	desc = "A juicer-built, juicer-'designed', and most importantly juicer-marketed gun."
	max_ammo_capacity = 0 //fukt up mags only
	gun_DRM = GUN_JUICE
	spread_angle = 30 // value without a barrel. Add one to keep things in line.

	New()
		barrel = new /obj/item/gun_parts/barrel/juicer(src)
		stock = new /obj/item/gun_parts/stock/NT_shoulder(src)
		..()

/obj/item/gun/modular/soviet
	name = "лазерная пушка"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	max_ammo_capacity = 6 // laser revolver
	gun_DRM = GUN_SOVIET
	spread_angle = 25 // value without a barrel. Add one to keep things in line.

	New()
		barrel = new /obj/item/gun_parts/barrel/soviet(src)
		stock = new /obj/item/gun_parts/stock/italian(src)
		..()

	shoot()
		..()
		process_ammo()

/obj/item/gun/modular/italian
	name = "cannone di qualità"
	desc = "Una pistola realizzata con acciaio, cuoio e olio d'oliva della più alta qualità possibile."
	max_ammo_capacity = 2 // basic revolving mechanism
	gun_DRM = GUN_ITALIAN
	spread_angle = 25 // value without a barrel. Add one to keep things in line.

	New()
		barrel = new /obj/item/gun_parts/barrel/italian(src)
		stock = new /obj/item/gun_parts/stock/italian(src)
		..()

	shoot()
		..()
		process_ammo()

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
