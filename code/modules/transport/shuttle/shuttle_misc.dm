ABSTRACT_TYPE(/obj/machinery/shuttle)
/obj/machinery/shuttle
	name = "shuttle"
	icon = 'icons/obj/shuttle.dmi'

	New()
		..()
		UnsubscribeProcess()

/obj/machinery/shuttle/engine
	name = "engine"
	density = 1
	anchored = ANCHORED
	layer = EFFECTS_LAYER_UNDER_1

/obj/machinery/shuttle/engine/heater
	name = "heater"
	icon_state = "heater"

	seaheater_right
		icon_state = "seaheater_R"

	seaheater_left
		icon_state = "seaheater_L"

	seaheater_middle
		icon_state = "seaheater_M"

	seaheater
		icon_state = "seaheater"

/obj/machinery/shuttle/engine/platform
	name = "platform"
	icon_state = "platform"

/obj/machinery/shuttle/engine/propulsion
	name = "propulsion"
	icon_state = "propulsion"
	opacity = 1
	machine_registry_idx = MACHINES_SHUTTLEPROPULSION
	var/stat1 = 1
	var/stat2 = 1
	var/id = null

	sea_propulsion
		name = "propeller"
		icon_state = "sea_propulsion"


//////////////////////////////////////////
// SHUTTLE THRUSTER DAMAGE STARTS HERE
//////////////////////////////////////////

/obj/machinery/shuttle/engine/propulsion/attackby(obj/item/W, mob/user)
	if (isscrewingtool(W))
		if (src.stat1 == 0)
			boutput(user, "<span class='notice'>Resecuring outer frame.</span>")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			sleep(2 SECONDS)
			boutput(user, "<span class='notice'>Outer frame secured.</span>")
			src.stat1 = 1
			return
		if (src.stat1 == 1)
			boutput(user, "<span class='alert'>Unsecuring outer frame.</span>")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			sleep(2 SECONDS)
			boutput(user, "<span class='alert'>Done.</span>")
			src.stat1 = 0
			return
		else
			..()
			return
	else if (istype(W, /obj/item/rods) && src.stat2 == 0)
		boutput(user, "<span class='notice'>Now plating hull.</span>")
		sleep(2 SECONDS)
		boutput(user, "<span class='notice'>Plating secured.</span>")
		qdel(W)
		src.stat2 = 1
		return
	else if (iswrenchingtool(W) && src.stat2 == 1)
		var/obj/item/rods/R = new /obj/item/rods
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		boutput(user, "<span class='alert'>Removing outer hull plating.</span>")
		sleep(2 SECONDS)
		boutput(user, "<span class='alert'>Done.</span>")
		src.stat2 = 0
		R.set_loc(src.loc)
		return
	else
		..()
		return

/obj/machinery/shuttle/engine/propulsion/examine()
	if (src.stat1 == 1 && src.stat2 == 1)
		return list("<span class='notice'>The propulsion engine is working properly!</span>")
	else
		return list("<span class='alert'>The propulsion engine is not functioning.</span>")

/obj/machinery/shuttle/engine/propulsion/ex_act()
	if(src.stat1 == 0 && src.stat2 == 0) // don't break twice, that'd be silly
		src.visible_message("<span class='alert'>[src] explodes!</span>")
		src.stat1 = 0
		src.stat2 = 0
		return
/obj/machinery/shuttle/engine/propulsion/meteorhit()
	if(src.stat1 == 0 && src.stat2 == 0)
		src.visible_message("<span class='alert'>[src] explodes!</span>")
		src.stat1 = 0
		src.stat2 = 0
		return
/obj/machinery/shuttle/engine/propulsion/blob_act(var/power)
	if(src.stat1 == 0 && src.stat2 == 0)
		src.visible_message("<span class='alert'>[src] explodes!</span>")
		src.stat1 = 0
		src.stat2 = 0
		return

//////////////////////////////////////////
// SHUTTLE THRUSTER DAMAGE ENDS HERE
//////////////////////////////////////////

/obj/machinery/shuttle/engine/propulsion/burst
	name = "burst"

/obj/machinery/shuttle/engine/propulsion/burst/left
	name = "left"
	icon_state = "burst_l"

/obj/machinery/shuttle/engine/propulsion/burst/right
	name = "right"
	icon_state = "burst_r"

/obj/machinery/shuttle/engine/router
	name = "router"
	icon_state = "router"


///// SHIP-SCALE WEAPONRY. BEEOO BEEOO HIT THE DECK /////

ADMIN_INTERACT_PROCS(/obj/machinery/shuttle/weapon, proc/fire)

ABSTRACT_TYPE(/obj/machinery/shuttle/weapon)
/obj/machinery/shuttle/weapon
	proc/fire()
		return

/obj/machinery/shuttle/weapon/howitzer_plasma
	icon = 'icons/misc/64x32.dmi'
	icon_state = "howitzer-idle"
	name = "plasma howitzer"
	desc = "This sure looks dangerous."
	anchored = ANCHORED
	density = 1
	layer = 20
	dir = 8
	var/icon_firing = "howitzer-firing"
	var/sound_firing = 'sound/weapons/energy/howitzer_firing.ogg'
	var/sound_shot = 'sound/weapons/energy/howitzer_shot.ogg'
	var/current_projectile = new/datum/projectile/special/howitzer


	fire()
		flick(src.icon_firing, src)
		src.visible_message("<span class='alert'>[src] is charging up!</span>")
		playsound(src.loc, sound_firing, 70, 1)
		sleep(1.3 SECONDS)
		src.visible_message("<span class='alert'><b>[src] fires!</b></span>")
		shoot_projectile_DIR(src, current_projectile, dir)


/obj/machinery/shuttle/weapon/howitzer_152mm
	name = "BL 6-Inch Howitzer"
	desc = "A huge cannon firing six inch artillery rounds. It looks extremely dangerous."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "howitzerL"
	anchored = ANCHORED
	density = 1
	layer = 20
	dir = 8
	var/icon_firing = "howitzerL-firing"
	var/current_projectile = new/datum/projectile/bullet/howitzer

	fire()
		flick(src.icon_firing, src)
		src.visible_message("<span class='alert'><b>[src] fires!</b></span>")
		sleep(0.25 SECONDS)
		shoot_projectile_DIR((get_step(get_turf(src), SOUTH)), current_projectile, dir)

/obj/item/material_piece/sphere/plasmaball // heh
	name = "plasma round"
	desc = "A hefty weaponized sphere of compressed plasma contained within a mesh of exotic materials."
	w_class = W_CLASS_BULKY
	force = 40
	throw_speed = 0.3

	New()
		src.setMaterial(getMaterial("plasmastone"), appearance = 1, setname = 0)
		src.setMaterial(getMaterial("erebite"), appearance = 0, setname = 0)
		src.setMaterial(getMaterial("plasmaglass"), appearance = 1, setname = 0)
		src.setMaterial(getMaterial("dyneema"), appearance = 1, setname = 0)
		..()
