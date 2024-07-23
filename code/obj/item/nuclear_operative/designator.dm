////////// Laser Designator & Airstrikes //////////
/obj/item/device/laser_designator
	name = "Laser Designator"
	icon = 'icons/obj/items/device.dmi'
	desc = "A handheld monocular device with a laser built into it, used for calling in fire support."
	icon_state = "laser_designator"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	/// How many times can this be used?
	var/uses = 1
	/// TRUE if an air strike is waiting to happen/happening
	var/in_use = FALSE
	/// The gun that "fires" the shell
	var/obj/machinery/broadside_gun/linked_gun = null
	/// Takes a string for a ship that's set in the `linked_gun`'s vars, e.g. "Cairngorm"
	var/ship_looking_for = ""
	/// Overlay sprite for where the strike will land, set to null for no overlay
	var/image/target_overlay = null

	New()
		..()
		desc = "A handheld monocular device with a laser built into it, used for calling in fire support. It has [src.uses] charge left."
		target_overlay = image('icons/effects/effects.dmi', "spinny_red")
		AddComponent(/datum/component/holdertargeting/sniper_scope, 10, 1000, /datum/overlayComposition/sniper_scope, 'sound/weapons/scope.ogg')

	disposing()
		linked_gun = null
		target_overlay = null
		..()

	proc/airstrike(atom/target, params, mob/user, reach)
		uses -= 1
		in_use = TRUE
		if(!linked_gun.bombard(target, user))
			uses += 1
		in_use = FALSE

/obj/item/device/laser_designator/syndicate
	name = "Laser Designator"
	desc = "A handheld monocular device with a laser built into it, used for calling in fire support from the Cairngorm."
	w_class = W_CLASS_SMALL
	uses = 2
	ship_looking_for = "Cairngorm"

	New()
		..()
		desc = "A handheld monocular device with a laser built into it, used for calling in fire support from the Cairngorm. It has [src.uses] charge left."

	airstrike(atom/target, params, mob/user, reach)
		..()
		src.desc = "A handheld monocular device with a laser built into it, used for calling in fire support from the Cairngorm. It has [src.uses] charge left."
		return TRUE

	pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
		if (reach)
			return FALSE
		if (!isturf(user.loc))
			return FALSE
		if (uses <= 0)
			return FALSE
		if (in_use)
			return FALSE
		if(target.z != 1 || user.z != 1)
			return

		for_by_tcl(A, /obj/machinery/broadside_gun)
			var/obj/machinery/broadside_gun/C = A
			if(C.firingfrom == src.ship_looking_for && !C.broken && ((C.ammo <= 0) || (!C.ammo == -1)))
				src.linked_gun = C
				break

		if(!src.linked_gun)
			boutput(user, "<span class='alert'>The [src] makes a grumpy beep. It seems there's no artillery guns in position currently.</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			return FALSE

		return src.airstrike(target, params, user, reach)

/obj/machinery/broadside_gun //Thanks to Cogwerks for the sprites
	name = "Broadside Gun Parent"
	icon = 'icons/obj/large/96x32.dmi'
	icon_state = "artillery_cannon"
	desc = "Parent of broadside guns for fire support."
	density = TRUE
	anchored = ANCHORED
	processing_tier = PROCESSING_EIGHTH
	bound_width = 96
	/// Ship name you're firing from, important for the designator
	var/firingfrom = ""
	var/broken = FALSE
	/// Amount of ammo the gun has, set to -1 for infinite
	var/ammo = 1
	/// In case you need to offset the gun firing's sound by offset tiles (if it's aiming left for example)
	var/sound_offset_length
	/// In case you need to offset the gun firing's sound dir (if it's aiming left for example)
	var/sound_offset_dir
	/// Holding var for the exact turf to play the gun's firing sound from
	var/turf/sound_turf
	/// Overlay sprite for where the strike will land, set to null for no overlay
	var/image/target_overlay = null

	/// Override this for the child of `/obj/machinery/broadside_gun` to determine what happens on-firing
	proc/bombard(atom/target, mob/user)
		SHOULD_CALL_PARENT(TRUE)
		logTheThing(LOG_BOMBING, user, "initiated an airstrike to [target ? "[log_loc(target)]" : "horrible no-loc nowhere void"].")
		message_admins("[key_name(user)] initiated an airstrike to [target ? "[log_loc(target)]" : "horrible no-loc nowhere void"].")
		return

	New()
		. = ..()
		START_TRACKING
		target_overlay = image('icons/effects/effects.dmi', "spinny_red")
		sound_turf = get_turf(src)

	disposing()
		. = ..()
		STOP_TRACKING
		target_overlay = null

/obj/machinery/broadside_gun/artillery_cannon
	name = "BlastoTek 12-inch Cannon"
	icon = 'icons/obj/large/96x32.dmi'
	icon_state = "152mm"
	desc = "A massive artillery cannon that breaks the terms of the Frontier Cruiser Treaty. Used for heavy fire support."
	bound_width = 96
	firingfrom = ""
	ammo = -1
	sound_offset_dir = EAST
	sound_offset_length = 3

	bombard(atom/target, mob/user)
		var/turf/target_turf = get_turf(target)
		var/turf/firing_turf = get_turf(src)
		if(getlineopaqueblocked(get_turf(user), target_turf) != target_turf)
			return FALSE
		..()

		if(!isnull(src.target_overlay))
			target_turf.overlays += src.target_overlay
		while(sound_offset_length > 0)
			sound_turf = get_step(src, sound_offset_dir)
			sound_offset_length--
		playsound(user, 'sound/machines/whistlebeep.ogg', 50, TRUE)
		playsound(sound_turf, 'sound/weapons/energy/howitzer_firing.ogg', 50, TRUE)
		sleep(2.5 SECONDS)
		var/area/designated_area = get_area(target_turf)
		command_alert("Heavy ordinace has been detected launching from the Cairngorm towards the [initial(designated_area.name)], ETA 5 seconds.","Central Command Alert")
		flick("152mm-firing", src)
		firing_turf = get_step(firing_turf, WEST)
		firing_turf = get_step(firing_turf, WEST)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(firing_turf)
		animation.icon = 'icons/obj/large/96x32.dmi'
		animation.icon_state = "nothing"
		SPAWN(0)
			flick("152mm-flash", animation)
			sleep(1.2 SECONDS)
			qdel(animation)
		playsound(sound_turf, 'sound/weapons/energy/howitzer_shot.ogg', 50, TRUE)
		sleep(rand(3 SECONDS, 7 SECONDS))
		if(!isnull(src.target_overlay))
			target_turf.overlays -= src.target_overlay
		explosion_new(user, target_turf, 100)
		sound_turf = get_turf(src)
		sound_offset_length = initial(sound_offset_length)
		return TRUE


	syndicate
		firingfrom = "Cairngorm"

		New()
			START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
			..()

		disposing()
			STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
			..()


ADMIN_INTERACT_PROCS(/obj/machinery/broadside_gun/directfire, proc/fire)

ABSTRACT_TYPE(/obj/machinery/broadside_gun/directfire)
/obj/machinery/broadside_gun/directfire
	name = "Shipscale Gun"
	ammo = -1
	dir = WEST
	icon = 'icons/obj/large/96x32.dmi'
	var/icon_firing = null
	var/current_projectile = new/datum/projectile/bullet/rifle_762_NATO
	var/muzzle_flash = null

	proc/fire()
		if(src.icon_firing)
			flick(src.icon_firing, src)
			src.visible_message(SPAN_ALERT("<b>[src] fires!</b>"))
			shoot_projectile_DIR(src, current_projectile, dir)
		if(src.muzzle_flash)
			var/turf/firing_turf = get_turf(src)
			firing_turf = get_step(get_step(firing_turf, WEST), WEST)
			var/atom/movable/overlay/animation = new /atom/movable/overlay(firing_turf)
			animation.icon = 'icons/obj/large/96x32.dmi'
			animation.icon_state = "nothing"
			SPAWN(0)
				flick(src.muzzle_flash, animation)
				sleep(1.2 SECONDS)
				qdel(animation)
			return

	siege
		name = "BlastoTek 12-inch Siege Gun"
		desc = "An absolute behemoth of a gun. Usage is restricted to battleship- and battlecruiser-class vessels flying under military authorization. "
		icon_state = "305mm"
		icon_firing = "305mm-firing"
		current_projectile = new/datum/projectile/bullet/howitzer/siege
		muzzle_flash = "120mm-flash"

	onetwentytwo
		name = "Zvezda-122"
		desc = "A hefty cannon firing 122mm standard Soviet howitzer rounds. Vast stockpiles of old munitions were recalled for service in the Martian Wars."
		icon_state = "zvezda122"
		icon_firing = "zvezda122-firing"
		current_projectile = new/datum/projectile/bullet/howitzer
		muzzle_flash = "120mm-flash"

	onetwenty
		name = "BlastoTek 120mm Howitzer"
		desc = "A hefty cannon firing 4.7 inch high explosive rounds. Usage by armed merchant cruisers and convoy escorts is strictly regulated."
		icon_state = "120mm"
		icon_firing = "120mm-firing"
		current_projectile = new/datum/projectile/bullet/howitzer
		muzzle_flash = "120mm-flash"

	fourty
		name = "BlastoTek Dual 2-pdrs"
		desc = "Two anti-spacecraft cannons on a tandem mount. Typically seen on convoy escorts, frigates, armed merchant cruisers, or in secondary batteries for larger warships."
		icon_state = "40mm"
		icon_firing = "40mm-firing"
		current_projectile = new/datum/projectile/bullet/grenade_round/high_explosive/double

	twenty
		name = "BlastoTek 20mm Repeater Cannon"
		desc = "A basic rapid-fire cannon for close-in defense, an easy solution to repel Martians, merchant raiders or deter space hazards and debris. Often used FOR raiding merchant convoys."
		icon_state = "20mm"
		icon_firing = "20mm-firing"
		current_projectile = new/datum/projectile/bullet/cannon/burst
		muzzle_flash = "20mm-flash"

	molotok
		name = "Auto-Molotok-4"
		desc = "A burstfire AA cannon adapted by the Zvezda Design Bureau for the Martian Wars, capable of rapidly shredding Martian biomechanical ships."
		icon_state = "molotok"
		icon_firing = "molotok-firing"
		current_projectile = new/datum/projectile/bullet/kuvalda_shrapnel/burst
		muzzle_flash = "20mm-flash"
