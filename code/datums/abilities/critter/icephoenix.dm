ABSTRACT_TYPE(/datum/targetable/critter/ice_phoenix)
/datum/targetable/critter/ice_phoenix

// movement modifiers don't work in space it seems, needs to be fixed before this ability works
/datum/targetable/critter/ice_phoenix/sail
	name = "Sail"
	desc = "Channel to gain a large movement speed buff while in space for 10 seconds"
	cooldown = 10 SECONDS // 120 seconds
	cooldown_after_action = TRUE

	tryCast()
		if (!istype(get_turf(src.holder.owner), /turf/space))
			boutput(src.holder.owner, SPAN_ALERT("You need to be in space to use this ability!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		var/mob/living/L = src.holder.owner
		if (L.throwing)
			return
		EndSpacePush(L)
		// 10 seconds below
		SETUP_GENERIC_ACTIONBAR(src.holder.owner, null, 3 SECONDS, /mob/living/critter/ice_phoenix/proc/on_sail, null, \
			'icons/mob/critter/nonhuman/icephoenix.dmi', "icephoenix", null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)

/datum/targetable/critter/ice_phoenix/return_to_station
	name = "Return to Station Space"
	desc = "Toggles if you will return to station space when traveling off the current Z level.<br><br>Currently toggled off."

	cast()
		..()
		var/mob/living/critter/ice_phoenix/phoenix = src.holder.owner
		phoenix.travel_back_to_station = !phoenix.travel_back_to_station
		if (phoenix.travel_back_to_station)
			boutput(phoenix, SPAN_NOTICE("You will now travel back to station space when traveling off the Z level"))
		else
			boutput(phoenix, SPAN_NOTICE("You will no longer travel back to station space when traveling off the Z level"))
		src.object.desc = "Toggles if you will return to station space when traveling off the current Z level.<br><br>Currently toggled " + \
			"[!phoenix.travel_back_to_station ? "off" : "on"]."

/datum/targetable/critter/ice_phoenix/ice_barrier
	name = "Ice Barrier"
	desc = "Gives yourself a hardened ice barrier, reducing the damage of the next attack against you by 50%."
	cooldown = 2 SECONDS // 20 SECONDS

	cast(atom/target)
		. = ..()
		src.holder.owner.setStatus("phoenix_ice_barrier", 7 SECONDS)

/datum/targetable/critter/ice_phoenix/glacier
	name = "Glacier"
	desc = "Create a 5 tile wide compacted snow wall, perpendicular to the cast direction, or otherwise in a random direction. Can be destroyed by heat or force."
	cooldown = 2 SECONDS // 20 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		. = ..()
		var/wall_style

		var/turf/T = get_turf(target)
		if (T == get_turf(src.holder.owner))
			wall_style = pick("vertical", "horizontal")
		else
			var/angle = get_angle(src.holder.owner, T)
			if ((angle > 45 && angle < 135) || (angle > -135 && angle < -45))
				wall_style = "vertical"
			else if ((angle > -45 && angle < 45) || (angle < -135 && angle > 135))
				wall_style = "horizontal"
			else
				wall_style = pick("vertical", "horizontal")

		src.create_ice_wall(T, wall_style)

	proc/create_ice_wall(turf/center, spread_type)
		var/turf/T
		if (spread_type == "vertical")
			if (!center.density)
				new /obj/ice_phoenix_ice_wall/vertical_mid(center)
			T = get_step(center, NORTH)
			if (!T.density)
				new /obj/ice_phoenix_ice_wall/vertical_mid(T)
			T = get_step(T, NORTH)
			if (!T.density)
				new /obj/ice_phoenix_ice_wall/north(T)

			T = get_step(center, SOUTH)
			if (!T.density)
				new /obj/ice_phoenix_ice_wall/vertical_mid(T)
			T = get_step(T, SOUTH)
			if (!T.density)
				new /obj/ice_phoenix_ice_wall/south(T)
			return
		if (!center.density)
			new /obj/ice_phoenix_ice_wall/horizontal_mid(center)
		T = get_step(center, EAST)
		if (!T.density)
			new /obj/ice_phoenix_ice_wall/horizontal_mid(T)
		T = get_step(T, EAST)
		if (!T.density)
			new /obj/ice_phoenix_ice_wall/east(T)

		T = get_step(center, WEST)
		if (!T.density)
			new /obj/ice_phoenix_ice_wall/horizontal_mid(T)
		T = get_step(T, WEST)
		if (!T.density)
			new /obj/ice_phoenix_ice_wall/west(T)

/datum/targetable/critter/ice_phoenix/thermal_shock
	name = "Thermal Shock"
	desc = "Creates an atmospheric-blocking tunnel that allows travel through by anyone. Can only be cast on walls."
	cooldown = 2 SECONDS // 20 SECONDS
	targeted = TRUE
	target_anything = TRUE

	tryCast(atom/target, params)
		if (!iswall(target))
			boutput(src.holder.owner, SPAN_ALERT("You can only cast this ability on walls!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		..()
		var/turf/T = target
		new /turf/simulated/ice_phoenix_ice_tunnel(T, get_dir(src.holder.owner, T))

/datum/targetable/critter/ice_phoenix/wind_chill
	name = "Wind chill"
	desc = "Create a freezing aura at the targeted location, inflicting cold on those within 5 tiles nearby, or freezing them if their body temperature is low enough."
	cooldown = 2 SECONDS // 30 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		..()
		var/turf/T = get_turf(target)
		for (var/mob/living/L in range(5, T))
			L.changeStatus("shivering", 10 SECONDS)
			// also do ice cube

/datum/targetable/critter/ice_phoenix/touch_of_death
	name = "Touch of Death"
	desc = "Delivers constant chills to an adjacent target. If their body temperature is low enough, it will deal rapid burn damage. If recently frozen by an ice cube, they will be unable to move."
	cooldown = 2 SECONDS // 60 SECONDS

	tryCast(atom/target, params)
		if (!ishuman(target))
			boutput(src.holder.owner, SPAN_ALERT("You can only cast this ability on humans!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// temperature check
		return ..()

	cast(atom/target)
		..()
		actions.start(new /datum/action/bar/touch_of_death(target), src.holder.owner)

/datum/targetable/critter/ice_phoenix/map
	name = "Show Map"
	desc = "Shows a map of the space Z level."
	var/obj/minimap/ice_phoenix/map_obj
	var/atom/movable/minimap_ui_handler/station_map

	New()
		..()
		src.map_obj = new

	cast()
		..()
		if (!src.station_map)
			src.station_map = new(src.holder.owner, "ice_phoenix_map", src.map_obj, "Space Map", "ntos")
			src.map_obj.map.create_minimap_marker(src.holder.owner, 'icons/obj/minimap/minimap_markers.dmi', "pin")

		station_map.ui_interact(src.holder.owner)

/datum/action/bar/touch_of_death
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED
	duration = 1 SECOND
	//resumable = FALSE
	color_success = "#4444FF"

	var/mob/target

	New(atom/target)
		..()
		src.target = target

	onUpdate()
		..()
		if (src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return
		src.owner.visible_message(SPAN_ALERT("[src.owner] grips [src.target] with its talons!"), SPAN_ALERT("You begin channeling cold into [src.target]."))

	onEnd()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

		src.target.changeStatus("shivering", 2 SECONDS)
		// need to do a temperature check
		src.target.TakeDamage("All", burn = 10)

		src.onRestart()

	// need to do temperature check
	proc/check_for_interrupt()
		var/mob/living/critter/ice_phoenix/phoenix = src.owner
		return QDELETED(phoenix) || QDELETED(src.target) || isdead(phoenix) || isdead(src.target) || BOUNDS_DIST(src.target, phoenix) > 0

ABSTRACT_TYPE(/obj/ice_phoenix_ice_wall)
/obj/ice_phoenix_ice_wall
	name = "compacted snow wall"
	desc = "A wall of compacted snow and ice. An obstacle, yet, weak."
	icon = 'icons/turf/walls/moon.dmi'
	density = TRUE
	anchored = ANCHORED_ALWAYS
	default_material = "ice"
	mat_changename = FALSE
	var/hits_left = 3

	horizontal_mid
		icon_state = "moon-12"

	east
		icon_state = "moon-8"

	west
		icon_state = "moon-4"

	vertical_mid
		icon_state = "moon-3"

	north
		icon_state = "moon-2"

	south
		icon_state = "moon-1"

	attack_hand(mob/user)
		attack_particle(user, src)
		user.lastattacked = src

		if (istype(user, /mob/living/critter/ice_phoenix))
			qdel(src)
			return

		boutput(user, SPAN_ALERT("Unfortunately, the snow is a little too compacted to be destroyed by hand."))

	attackby(obj/item/I, mob/user)
		attack_particle(user, src)
		user.lastattacked = src

		if (isweldingtool(I))
			user.visible_message(SPAN_ALERT("[user] melts [src]!"), SPAN_ALERT("You melt [src]!"))
			qdel(src)
		else if (I.force)
			if (I.force >= 20)
				user.visible_message(SPAN_ALERT("[user] destroys [src]!"), SPAN_ALERT("You destroy [src]!"))
				qdel(src)
				return
			src.hits_left--
			if (src.hits_left > 0)
				user.visible_message(SPAN_ALERT("[user] damages [src]!"), SPAN_ALERT("You damage [src]!"))
			else
				user.visible_message(SPAN_ALERT("[user] destroys [src]!"), SPAN_ALERT("You destroy [src]!"))
				qdel(src)
		else
			..()

	bullet_act(obj/projectile/P)
		if (P.power >= 20)
			qdel(src)
		else
			src.hits_left--
			if (src.hits_left > 0)
				qdel(src)
			else
				..()

	hit_check(datum/thrown_thing/thr)

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		..()
		if (AM.throwforce > 20)
			qdel(src)
		else
			src.hits_left--
			if (src.hits_left <= 0)
				qdel(src)

	ex_act()
		qdel(src)

	blob_act()
		qdel(src)

	// need snow particle effects for destroying the wall
	disposing()
		// create water here
		..()

/turf/simulated/ice_phoenix_ice_tunnel
	icon = 'icons/mob/critter/nonhuman/icephoenix.dmi'
	icon_state = "ice_tunnel"
	density = FALSE
	opacity = FALSE
	name = "ice tunnel"
	desc = "A narrow ice tunnel that seems to prevent passage of air by a thick, icy mist. Interesting."
	gas_impermeable = TRUE

	New(newLoc, direct)
		..()
		if (istype(get_step(src, NORTH), /turf/space) || istype(get_step(src, SOUTH), /turf/space))
			src.dir = SOUTH
		else if (istype(get_step(src, EAST), /turf/space))
			src.dir = WEST
		else if (istype(get_step(src, WEST), /turf/space))
			src.dir = EAST
		else
			src.dir = direct
