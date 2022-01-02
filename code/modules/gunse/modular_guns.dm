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

"average" base spread is 25 without a barrel, other guns may be less accurate, perhaps up to 30. few should ever be more accurate.
in order to balance this, barrels should be balanced around ~ -15 spread, and stocks around -5 (so -13 is a rough barrel, -17 is a good one, etc.)
giving an "average" spread for stock guns around 5-10
*/


ABSTRACT_TYPE(/obj/item/gun/modular)
/obj/item/gun/modular/ // PARENT TYPE TO ALL MODULER GUN'S
	var/gun_DRM = 0 // identify the gun model / type
	var/obj/item/gun_parts/barrel/barrel = null
	var/obj/item/gun_parts/stock/stock = null
	var/obj/item/gun_parts/magazine/magazine = null
	var/obj/item/gun_parts/accessory/accessory = null
	var/list/obj/item/gun_parts/parts = list()
	var/built = 0
	var/no_save = 0 // when 1, this should prevent the player from carrying it cross-round?
	icon_state = "tranq_pistol"
	contraband = 0


	var/lensing = 0 // Variable used for optical gun barrels. laser intensity scales around 1.0 (or will!)
	var/scatter = 0 // variable for using hella shotgun shells or something

	var/flashbulb_only = 0 // FOSS guns only
	var/flashbulb_health = 0 // FOSS guns only
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
	var/processing_ammo = 0


	two_handed = 0
	can_dual_wield = 1

	New()
		..()
		make_parts()
		build_gun()

/obj/item/gun/modular/proc/make_parts()
	return

/obj/item/gun/modular/proc/check_DRM(var/obj/item/gun_parts/part)
	if(!istype(part))
		return 0
	if(!part.part_DRM || !src.gun_DRM)
		playsound(src.loc, "sound/machines/buzz-sigh.ogg", 50, 1)
		return 1
	else
		return (src.gun_DRM & part.part_DRM)

/obj/item/gun/modular/buildTooltipContent()
	. = ..()
	if(gun_DRM)
		. += "<div><span>DRM LICENSE: </span>"
		if(gun_DRM & GUN_NANO)
			. += "<img src='[resource("images/tooltips/temp_nano.png")]' alt='' class='icon' />"
		if(gun_DRM & GUN_FOSS)
			. += "<img src='[resource("images/tooltips/temp_foss.png")]' alt='' class='icon' />"
		if(gun_DRM & GUN_JUICE)
			. += "<img src='[resource("images/tooltips/temp_juice.png")]' alt='' class='icon' />"
		if(gun_DRM & GUN_SOVIET)
			. += "<img src='[resource("images/tooltips/temp_soviet.png")]' alt='' class='icon' />"
		if(gun_DRM & GUN_ITALIAN)
			. += "<img src='[resource("images/tooltips/temp_italian.png")]' alt='' class='icon' />"
		. += "</div>"
	if(scatter)
		. += "<div><img src='[resource("images/tooltips/temp_scatter.png")]' alt='' class='icon' /></div>"

	. += "<div><img src='[resource("images/tooltips/temp_spread.png")]' alt='' class='icon' /><span>Spread: [src.spread_angle] </span></div>"

	if(lensing)
		. += "<div><img src='[resource("images/tooltips/lensing.png")]' alt='' class='icon' /><span>Lenses: [src.lensing] </span></div>"

	if(barrel && barrel.length)
		. += "<div><span>Barrel length: [src.barrel.length] </span></div>"

	if(jam_frequency_fire || jam_frequency_reload)
		. += "<div><img src='[resource("images/tooltips/jamjarrd.png")]' alt='' class='icon' /><span>Jammin: [src.jam_frequency_reload + src.jam_frequency_fire] </span></div>"

	. += "<div> <span>Maxcap: [src.max_ammo_capacity] </span></div>"
	. += "<div> <span>Loaded: [src.ammo_list.len + (src.current_projectile?1:0)] </span></div>"

	lastTooltipContent = .

/obj/item/gun/modular/attackby(var/obj/item/I as obj, mob/user as mob)
	if (istype(I, /obj/item/stackable_ammo))
		var/obj/item/stackable_ammo/SA = I
		SA.reload(src, user)
		return
	if(istype(I,/obj/item/gun_parts/))
		if(built)
			boutput(user,"<span class='notice'><b>You cannot place parts onto an assembled gun.</b></span>")
			return
		var/obj/item/gun_parts/part = I
		if(src.check_DRM(part))
			boutput(user,"<span class='notice'><b>You loosely place [I] onto [src].</b></span>")
			if (istype(I, /obj/item/gun_parts/barrel/))
				barrel = I
			if (istype(I, /obj/item/gun_parts/stock/))
				stock = I
			if (istype(I, /obj/item/gun_parts/magazine/))
				magazine = I
			if (istype(I, /obj/item/gun_parts/accessory/))
				accessory = I
			user.u_equip(I)
			I.dropped(user)
			I.set_loc(src)
		else
			boutput(user,"<span class='notice'><b>The [src]'s DRM prevents you from attatching [I].</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
	else
		..()

/obj/item/gun/modular/alter_projectile(var/obj/projectile/P)
	if(P.proj_data.window_pass)
		if(lensing)
			P.power *= lensing
			return
		P.power *= PROJ_PENALTY_BARREL
		return

	else
		if(!barrel)
			P.power *= PROJ_PENALTY_BARREL
			if(usr && (prob(10)))
				boutput(usr, "<span class='alert'><b>You're stunned by the uncontained muzzle flash!</b></span>")
				usr.apply_flash(2,1,1,0,1,1)
			return

		if(barrel && lensing)
			src.jammed = 1
			barrel.lensing = 0
			barrel.spread_angle += 5
			barrel.desc += " The internal lenses have been destroyed."
			src.lensing = 0
			src.spread_angle += 5 // this will reset to stock when the gun is rebuilt
			src.jam_frequency_fire += 5 // this will reset to stock when the gun is rebuilt
			src.jam_frequency_reload += 5 // this will reset to stock when the gun is rebuilt
			P.power *= PROJ_PENALTY_BARREL
			if(usr)
				boutput(usr, "<span class='alert'><b>[src.barrel] is shattered by the projectile!</b></span>")
			playsound(get_turf(src), "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
			barrel.buildTooltipContent()
			buildTooltipContent()
			return

		P.power *= (barrel.length / STANDARD_BARREL_LEN) // 20 CM
		return







/obj/item/gun/modular/proc/flash_process_ammo(mob/user)
	if(processing_ammo)
		return

	if(jammed)
		boutput(user,"<span class='notice'><b>You clear the ammunition jam.</b></span>")
		jammed = 0
		playsound(src.loc, "sound/weapons/gunload_heavy.ogg", 40, 1)
		return

	if(flashbulb_health) // bulb still loaded
		processing_ammo = 1
		if(max_crank_level)
			crank(user)
		else
			handle_egun_shit(user)
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

	if(prob(jam_frequency_reload))
		jammed = 1
		boutput(user,"<span class='alert'><b>Error! Jam detected!</b></span>")
		playsound(src.loc, "sound/weapons/trayhit.ogg", 60, 1)
		return
	else
		processing_ammo = 1
		var/obj/item/stackable_ammo/flashbulb/FB = ammo_list[ammo_list.len]
		if(!istype(FB))
			boutput(user,"<span class='notice'><b>Error! This device is configured only for FOSS Cathodic Flash Bulbs.</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
		else
			flashbulb_health = rand(FB.min_health, FB.max_health)
			boutput(user,"<span class='notice'><b>FOSS Cathodic Flash Bulb loaded.</b></span>")
			playsound(src.loc, "sound/weapons/gun_cocked_colt45.ogg", 60, 1)

		pool(ammo_list[ammo_list.len])
		ammo_list.Remove(ammo_list[ammo_list.len]) //and remove it from the list

		processing_ammo = 0

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
	if(flashbulb_only)
		flash_process_ammo(user)
	else
		process_ammo(user)
	buildTooltipContent()

/obj/item/gun/modular/canshoot()
	if(jammed)
		return 0
	if(!built)
		return 0
	if(flashbulb_only && !flashbulb_health)
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

	if(accessory && accessory_on_fire)
		accessory.on_fire()

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


	if(flashbulb_health)// this should be nonzero if we have a flashbulb loaded.
		flashbulb_health = max(0,(flashbulb_health - crank_level))//subtract cranks from life
		crank_level = 0 // reset
		if(!flashbulb_health) // that was the end of it!
			user.show_text("<span class='alert'>Your gun's flash bulb burns out!</span>")


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
		part.add_part_to_gun(src)

	buildTooltipContent()
	built = 1

	//update the icon to match!!!!!

/obj/item/gun/modular/proc/crank(mob/user)
	SPAWN_DBG(1)
		if(crank_level > max_crank_level)
			boutput(user,"<span class='notice'><b>Error! This device cannot be further overloaded.</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
			processing_ammo = 0
			return
		if(crank_level == max_crank_level)
			boutput(user,"<span class='notice'><b>Notice! Exceeding design specification.</b></span>")
			playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1)
			sleep(0.5 SECONDS)
			crank_level++
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		if(crank_level < max_crank_level)
			boutput(user,"<span><b>You crank the handle.</b></span>")
			crank_level++
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		if(current_projectile)
			pool(current_projectile)
		switch(crank_level)
			if (0)
				current_projectile = null // this shouldnt happen but just in case!
			if (1)
				current_projectile = unpool(/datum/projectile/laser/flashbulb/)
			if (2)
				current_projectile = unpool(/datum/projectile/laser/flashbulb/two/)
			if (3)
				current_projectile = unpool(/datum/projectile/laser/flashbulb/three/)
			if (4)
				current_projectile = unpool(/datum/projectile/laser/flashbulb/four/)
			//if (5)
				//current_projectile = /datum/projectile/laser/flashbulb/five
		processing_ammo = 0

/obj/item/gun/modular/proc/handle_egun_shit(mob/user)
	return

// BASIC GUN'S

/obj/item/gun/modular/NT
	name = "\improper NT pistol"
	real_name = "\improper NT pistol"
	desc = "A simple, reliable cylindrical bored weapon."
	max_ammo_capacity = 1 // single-shot pistols ha- unless you strap an expensive loading mag on it.
	gun_DRM = GUN_NANO
	spread_angle = 24 // value without a barrel. Add one to keep things in line.
	color = "#33FFFF"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/NT(src)
		stock = new /obj/item/gun_parts/stock/NT(src)

/obj/item/gun/modular/NT/long
	name = "\improper NT rifle"
	real_name = "\improper NT rifle"
	desc = "A simple, reliable rifled bored weapon."
	max_ammo_capacity = 2
	make_parts()
		barrel = new /obj/item/gun_parts/barrel/NT/long(src)
		stock = new /obj/item/gun_parts/stock/NT/shoulder(src)


/obj/item/gun/modular/foss // syndicate laser gun's!
	name = "\improper FOSS laser"
	real_name = "\improper FOSS laser"
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/19"
	max_ammo_capacity = 1 // just takes a flash bulb.
	gun_DRM = GUN_FOSS
	spread_angle = 25 // value without a barrel. Add one to keep things in line.
	color = "#5555FF"
	icon_state = "caplaser"
	contraband = 2


	make_parts()
		barrel = new /obj/item/gun_parts/barrel/foss(src)
		stock = new /obj/item/gun_parts/stock/foss(src)


/obj/item/gun/modular/foss/long
	desc = "An open-sourced and freely modifiable FOSS Inductive Flash Arc, Model 2k/20"
	color = "#9955FF"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/foss/long(src)
		stock = new /obj/item/gun_parts/stock/foss/long(src)




/obj/item/gun/modular/juicer
	name = "\improper BLASTA"
	real_name = "\improper BLASTA"
	desc = "A juicer-built, juicer-'designed', and most importantly juicer-marketed gun."
	max_ammo_capacity = 0 //fukt up mags only
	gun_DRM = GUN_JUICE
	spread_angle = 30 // value without a barrel. Add one to keep things in line.
	color = "#99FF99"
	contraband = 1

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/juicer(src)
		stock = new /obj/item/gun_parts/stock/NT(src)
		magazine = new /obj/item/gun_parts/magazine/juicer/small(src)

/obj/item/gun/modular/juicer/long
	desc = "A juicer-built, juicer-'designed', and most importantly juicer-marketed gun."
	color = "#55FF88"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/juicer/longer(src)
		stock = new /obj/item/gun_parts/stock/italian(src)

/obj/item/gun/modular/soviet
	name = "\improper Soviet лазерная"
	real_name = "\improper Soviet лазерная"
	desc = "Энергетическая пушка советской разработки с пиротехническими лампами-вспышками."
	max_ammo_capacity = 4 // laser revolver
	gun_DRM = GUN_SOVIET
	spread_angle = 25 // value without a barrel. Add one to keep things in line.
	color = "#FF9999"
	icon_state = "laser"
	contraband = 1

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/soviet(src)
		stock = new /obj/item/gun_parts/stock/italian(src)


	shoot()
		..()
		process_ammo()

/obj/item/gun/modular/italian
	name = "\improper Italiano"
	real_name = "\improper Italiano"
	desc = "Una pistola realizzata con acciaio, cuoio e olio d'oliva della più alta qualità possibile."
	max_ammo_capacity = 2 // basic revolving mechanism
	gun_DRM = GUN_ITALIAN
	spread_angle = 27 // value without a barrel. Add one to keep things in line.
	color = "#FFFF99"

	make_parts()
		barrel = new /obj/item/gun_parts/barrel/italian(src)
		stock = new /obj/item/gun_parts/stock/italian(src)


	shoot()
		..()
		process_ammo()

