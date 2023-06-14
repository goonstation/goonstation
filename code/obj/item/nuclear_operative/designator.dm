#define DESIGNATOR_MAX_RANGE 30

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
	/// Movement controller for the designator's "scope"
	var/datum/movement_controller/designatormove = null
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
		designatormove = new/datum/movement_controller/designator_look()
		desc = "A handheld monocular device with a laser built into it, used for calling in fire support. It has [src.uses] charge left."
		target_overlay = image('icons/effects/effects.dmi', "spinny_red")

	disposing()
		designatormove = null
		linked_gun = null
		target_overlay = null
		..()

	dropped(mob/M)
		remove_self(M)
		..()

	move_callback(mob/living/M, turf/source, turf/target)
		if (M.use_movement_controller)
			if (source != target)
				just_stop_designating(M)

	proc/airstrike(atom/target, params, mob/user, reach)
		uses -= 1
		in_use = TRUE
		if(!linked_gun.bombard(target, user))
			uses += 1
		in_use = FALSE

	proc/remove_self(mob/living/M)
		if (islist(M.move_laying))
			M.move_laying -= src
		else
			M.move_laying = null

		if (ishuman(M))
			M:special_sprint &= ~SPRINT_DESIGNATOR

		just_stop_designating(M)

	proc/just_stop_designating(mob/living/M) //removes overlay here
		M.use_movement_controller = null
		if (M.client)
			M.client.pixel_x = 0
			M.client.pixel_y = 0
			M.keys_changed(0,0xFFFF) //This is necessary for the designator to work

		M.removeOverlayComposition(/datum/overlayComposition/sniper_scope)

	attack_hand(mob/user)
		if (..() & ishuman(user))
			user:special_sprint |= SPRINT_DESIGNATOR
			var/mob/living/L = user

			//set move callback (when user moves, designator go down)
			if (islist(L.move_laying))
				L.move_laying += src
			else
				if (L.move_laying)
					L.move_laying = list(L.move_laying, src)
				else
					L.move_laying = list(src)

	get_movement_controller()
		.= designatormove

/mob/living/proc/begin_designating() //adds the overlay + sound here
	for (var/obj/item/device/laser_designator/laser_designator in equipped_list(check_for_magtractor = 0))
		src.use_movement_controller = laser_designator
		src.keys_changed(0,0xFFFF) //This is necessary for the designator to work
		if(!src.hasOverlayComposition(/datum/overlayComposition/sniper_scope))
			src.addOverlayComposition(/datum/overlayComposition/sniper_scope)
		playsound(src, 'sound/weapons/scope.ogg', 50, 1)
		break

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
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1)
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
	name = "Artillery Cannon"
	icon = 'icons/obj/large/96x32.dmi'
	icon_state = "152mm"
	desc = "A 152 millimeter artillery cannon, used for heavy fire support."
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
		playsound(user, 'sound/machines/whistlebeep.ogg', 50, 1)
		playsound(sound_turf, 'sound/weapons/energy/howitzer_firing.ogg', 50, 1)
		sleep(2.5 SECONDS)
		var/area/designated_area = get_area(target_turf)
		command_alert("Heavy ordinace has been detected launching from the Cairngorm towards the [initial(designated_area.name)], ETA 5 seconds.","Central Command Alert")
		flick("152mm_firing", src)
		firing_turf = get_step(firing_turf, WEST)
		firing_turf = get_step(firing_turf, WEST)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(firing_turf)
		animation.icon = 'icons/obj/large/96x32.dmi'
		animation.icon_state = "nothing"
		SPAWN(0)
			flick("152mm-flash", animation)
			sleep(1.2 SECONDS)
			qdel(animation)
		playsound(sound_turf, 'sound/weapons/energy/howitzer_shot.ogg', 50, 1)
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
			..()
			START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

		disposing()
			STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
			..()

#undef DESIGNATOR_MAX_RANGE
