ABSTRACT_TYPE(/datum/targetable/critter/space_phoenix)
/datum/targetable/critter/space_phoenix
	icon = 'icons/mob/critter/nonhuman/spacephoenix.dmi'
	icon_state = "template"

/datum/targetable/critter/space_phoenix/sail
	name = "Sail"
	desc = "Channel to gain a large movement speed buff while in space for 10 seconds"
	icon_state = "sail"
	cooldown = 30 SECONDS
	cooldown_after_action = TRUE

	tryCast()
		if (!istype(get_turf(src.holder.owner), /turf/space))
			boutput(src.holder.owner, SPAN_ALERT("You need to be in space to use this ability!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		actions.start(new /datum/action/bar/sail(), src.holder.owner)

/datum/targetable/critter/space_phoenix/ice_barrier
	name = "Ice Barrier"
	desc = "Gives yourself a hardened ice barrier for 10 seconds, capping incoming damage to a max value of 10."
	icon_state = "ice_barrier"
	cooldown = 20 SECONDS

	cast(atom/target)
		. = ..()
		src.holder.owner.setStatus("phoenix_ice_barrier", 10 SECONDS)
		playsound(get_turf(src.holder.owner), 'sound/misc/phoenix/phoenix_shield.ogg', 50, TRUE)

/datum/targetable/critter/space_phoenix/glacier
	name = "Glacier"
	desc = "Create a 5 tile wide compacted snow wall, perpendicular to the cast direction, or otherwise in a random direction. Can be destroyed by heat or force."
	icon_state = "ice_wall"
	cooldown = 30 SECONDS
	targeted = TRUE
	target_anything = TRUE

	tryCast(atom/target)
		if (GET_DIST(src.holder.owner, target) > 7)
			boutput(src.holder.owner, SPAN_ALERT("That tile is too far away!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (!(target in view(7, src.holder.owner)))
			boutput(src.holder.owner, SPAN_ALERT("That tile is out of sight!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

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
				new /obj/space_phoenix_ice_wall/vertical_mid(center)
			T = get_step(center, NORTH)
			if (!T.density)
				new /obj/space_phoenix_ice_wall/vertical_mid(T)
			T = get_step(T, NORTH)
			if (!T.density)
				new /obj/space_phoenix_ice_wall/north(T)

			T = get_step(center, SOUTH)
			if (!T.density)
				new /obj/space_phoenix_ice_wall/vertical_mid(T)
			T = get_step(T, SOUTH)
			if (!T.density)
				new /obj/space_phoenix_ice_wall/south(T)
			return
		if (!center.density)
			new /obj/space_phoenix_ice_wall/horizontal_mid(center)
		T = get_step(center, EAST)
		if (!T.density)
			new /obj/space_phoenix_ice_wall/horizontal_mid(T)
		T = get_step(T, EAST)
		if (!T.density)
			new /obj/space_phoenix_ice_wall/east(T)

		T = get_step(center, WEST)
		if (!T.density)
			new /obj/space_phoenix_ice_wall/horizontal_mid(T)
		T = get_step(T, WEST)
		if (!T.density)
			new /obj/space_phoenix_ice_wall/west(T)

/datum/targetable/critter/space_phoenix/thermal_shock
	name = "Thermal Shock"
	desc = "Channel to create an atmospheric-blocking tunnel that allows travel through by anyone. This ability can be cast on walls, girders, and windows. Girders are destroyed instead."
	icon_state = "thermal_shock"
	cooldown = 60 SECONDS
	targeted = TRUE
	target_anything = TRUE
	cooldown_after_action = TRUE

	tryCast(atom/target, params)
		if (BOUNDS_DIST(src.holder.owner, target) > 0)
			boutput(src.holder.owner, SPAN_ALERT("You need to be adjacent to the target!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (!(iswall(target) || istype(target, /obj/window) || istype(target, /obj/structure/girder)))
			boutput(src.holder.owner, SPAN_ALERT("You can only cast this ability on girders, walls, or windows!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (istype(target, /turf/unsimulated/wall))
			boutput(src.holder.owner, SPAN_ALERT("You can't cast this ability on this wall!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (isrestrictedz(target?.z))
			boutput(src.holder.owner, SPAN_ALERT("Your power is useless here!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		..()
		playsound(get_turf(target), 'sound/misc/phoenix/phoenix_thermal_shock.ogg', 50, TRUE)
		SETUP_GENERIC_ACTIONBAR(src.holder.owner, null, 5 SECONDS, /mob/living/critter/space_phoenix/proc/create_ice_tunnel, list(target), \
			null, null, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)

/datum/targetable/critter/space_phoenix/wind_chill
	name = "Wind chill"
	desc = "Create a freezing aura at the targeted location, inflicting cold on those within 2 tiles nearby, and freezing them solid if they're cold enough."
	icon_state = "windchill"
	cooldown = 30 SECONDS
	targeted = TRUE
	target_anything = TRUE

	tryCast(atom/target)
		if (GET_DIST(src.holder.owner, target) > 7)
			boutput(src.holder.owner, SPAN_ALERT("That tile is too far away!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (!(target in view(7, src.holder.owner)))
			boutput(src.holder.owner, SPAN_ALERT("That tile is out of sight!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		..()
		var/turf/center = get_turf(target)
		var/obj/particle/cryo_sparkle/sparkle
		for (var/turf/T as anything in block(center.x - 2, center.y - 2, center.z, center.x + 2, center.y + 2, center.z))
			sparkle = new /obj/particle/cryo_sparkle(T)
			sparkle.alpha = rand(180, 255)
			for (var/mob/living/L in T)
				if (isrobot(L) || isintangible(L))
					continue
				L.changeStatus("shivering", 10 SECONDS * (1 - 0.75 * L.get_cold_protection() / 100), TRUE)
				L.bodytemperature -= 10
				if (L.bodytemperature <= 255.372) // 0 degrees fahrenheit
					var/obj/icecube/block = new /obj/icecube(L.loc, L)
					block.anchored = TRUE
					block.setStatus("cold_snap", INFINITE_STATUS)
			SPAWN(2 SECONDS)
				qdel(sparkle)
		playsound(center, 'sound/misc/phoenix/phoenix_wind_chill.ogg', 50, TRUE)

/datum/targetable/critter/space_phoenix/touch_of_death
	name = "Touch of Death"
	desc = "Delivers constant chills to an adjacent target, dealing burn damage once their body temperature is low enough. If frozen by an ice cube, they will be broken out and unable to move."
	icon_state = "touch_of_death"
	cooldown = 60 SECONDS
	targeted = TRUE
	target_anything = TRUE

	tryCast(atom/target, params)
		if (BOUNDS_DIST(src.holder.owner, target) > 0)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (!ishuman(target) && !istype(target, /obj/icecube))
			boutput(src.holder.owner, SPAN_ALERT("You can only cast this ability on humans!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		else if (istype(target, /obj/icecube))
			var/obj/icecube/block = target
			if (!istype(block.held_mob, /mob/living/carbon/human))
				boutput(src.holder.owner, SPAN_ALERT("You can only cast this ability on humans!"))
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		..()
		actions.start(new /datum/action/bar/touch_of_death(target), src.holder.owner)

/datum/targetable/critter/space_phoenix/permafrost
	name = "Permafrost"
	desc = "Target an empty station floor to channel a powerful ice beam that makes the station area habitable to you at the end, guarded by a totem."
	icon_state = "permafrost"
	cooldown = 60 SECONDS
	targeted = TRUE
	target_anything = TRUE
	cooldown_after_action = TRUE

	tryCast(atom/target, params)
		if (GET_DIST(src.holder.owner, target) > 9)
			boutput(src.holder.owner, SPAN_ALERT("That tile is too far away!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (!(target in view(7, src.holder.owner)))
			boutput(src.holder.owner, SPAN_ALERT("That tile is out of sight!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		var/area/A = get_area(target)
		if (!istype(A, /area/station))
			boutput(src.holder.owner, SPAN_ALERT("You can only cast this ability on a station turf!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (A.permafrosted)
			boutput(src.holder.owner, SPAN_ALERT("You've already used Permafrost in this area!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		var/turf/T = get_turf(target)
		if (iswall(T))
			boutput(src.holder.owner, SPAN_ALERT("You can't cast this ability on a wall!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		var/turf/phoenix_turf = get_turf(src.holder.owner)
		if (T == phoenix_turf)
			boutput(src.holder.owner, SPAN_ALERT("You can't cast this ability on the same turf you're on!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		for (var/atom/atom as anything in T)
			if (atom.density)
				boutput(src.holder.owner, SPAN_ALERT("This turf has a blocking object on it!"))
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (istype(get_turf(target), /turf/simulated/space_phoenix_ice_tunnel))
			boutput(src.holder.owner, SPAN_ALERT("You can't cast this ability in an ice tunnel!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		..()
		actions.start(new /datum/action/bar/permafrost(target), src.holder.owner)
		playsound(target, "sound/effects/magic[pick(3, 4)].ogg", 50, TRUE)

/datum/action/bar/sail
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 8 SECONDS
	color_success = "#4444FF"

	onStart()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/living/L = src.owner
		if (L.throwing)
			return
		EndSpacePush(L)

	onUpdate()
		..()
		if (src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

		src.owner.setStatus("space_phoenix_sail", 10 SECONDS)
		var/mob/living/critter/space_phoenix/phoenix = src.owner
		var/datum/targetable/critter/space_phoenix/sail/abil = phoenix.getAbility(/datum/targetable/critter/space_phoenix/sail)
		abil.afterAction()
		playsound(get_turf(src.owner), 'sound/misc/phoenix/phoenix_sail.ogg', 40, TRUE)

	proc/check_for_interrupt()
		var/turf/T = get_turf(src.owner)
		return !istype(T, /turf/space)

/datum/action/bar/touch_of_death
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 1 SECOND
	color_success = "#4444FF"

	var/mob/living/target

	New(atom/target)
		..()
		if (istype(target, /obj/icecube))
			var/obj/icecube/block = target
			src.target = block.held_mob
			qdel(block)
		else
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
		src.owner.visible_message(SPAN_ALERT("[src.owner] grips [src.target] with its talons!"), SPAN_ALERT("You begin channeling your cold into [src.target]."))
		if (src.target.hasStatus("cold_snap"))
			src.target.changeStatus("paralysis", 1.2 SECONDS)
			src.target.changeStatus("cold_snap", 1.2 SECONDS)

	onEnd()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

		src.target.changeStatus("shivering", 2 SECONDS * (1 - 0.75 * target.get_cold_protection() / 100), TRUE)
		src.target.bodytemperature -= 15
		if (src.target.bodytemperature <= 227.59) // -50 degrees fahrenheit
			src.target.TakeDamage("All", burn = 10)
		playsound(get_turf(target), "sound/misc/phoenix/phoenix_tod_[rand(1, 4)].ogg", 50, TRUE)

		if (src.target.hasStatus("cold_snap"))
			src.target.changeStatus("paralysis", 1.2 SECONDS)
			src.target.changeStatus("cold_snap", 1.2 SECONDS)
		src.onRestart()

	onInterrupt()
		..()
		REMOVE_ATOM_PROPERTY(src.target, PROP_MOB_CANTMOVE, "phoenix_touch_of_death")

	proc/check_for_interrupt()
		var/mob/living/critter/space_phoenix/phoenix = src.owner
		return QDELETED(phoenix) || QDELETED(src.target) || isdead(phoenix) || isdead(src.target) || BOUNDS_DIST(src.target, phoenix) > 0

/datum/action/bar/permafrost
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED
	duration = 20 SECONDS
	color_success = "#4444FF"

	var/turf/target
	var/obj/beam_dummy/dummy

	New(atom/target)
		..()
		src.target = get_turf(target)

	onStart()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return
		EndSpacePush(src.owner)
		src.owner.set_dir(get_dir(src.owner, target))
		src.owner.visible_message(SPAN_ALERT("[src.owner] begins channeling a beam of ice!"), SPAN_ALERT("You begin channeling your ice power."))
		src.dummy = showLine(src.owner, target, "zigzag")
		src.dummy.color = "#2e2af1"
		src.dummy.mouse_opacity = 0

	onUpdate()
		..()
		if (src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

		var/area/A = get_area(target)
		A.add_permafrost()
		new /obj/space_phoenix_statue(target)

		QDEL_NULL(src.dummy)

		var/mob/living/critter/space_phoenix/phoenix = src.owner
		var/datum/targetable/critter/space_phoenix/sail/abil = phoenix.getAbility(/datum/targetable/critter/space_phoenix/permafrost)
		abil.afterAction()

		phoenix.permafrosted_areas |= "[A.name]-\ref[A]"

		logTheThing(LOG_STATION, phoenix, "[phoenix] successfully casts Permafrost at [log_loc(target)]")

	onInterrupt()
		..()
		QDEL_NULL(src.dummy)

	proc/check_for_interrupt()
		var/mob/living/critter/space_phoenix/phoenix = src.owner
		return QDELETED(phoenix) || isdead(phoenix)

ABSTRACT_TYPE(/obj/space_phoenix_ice_wall)
/obj/space_phoenix_ice_wall
	name = "compacted snow wall"
	desc = "A wall of compacted snow and ice. An obstacle that can be destroyed, best by heat."
	icon = 'icons/turf/walls/moon.dmi'
	density = TRUE
	anchored = ANCHORED_ALWAYS
	layer = TURF_LAYER
	default_material = "ice"
	mat_changename = FALSE
	stops_space_move = TRUE
	var/hits_left = 3

	New()
		..()
		playsound(get_turf(src), 'sound/misc/phoenix/phoenix_snow_crunch.ogg', 50, TRUE)

		SPAWN(1 MINUTE)
			qdel(src)

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
		user.lastattacked = get_weakref(src)

		if (istype(user, /mob/living/critter/space_phoenix))
			qdel(src)
			return

		boutput(user, SPAN_ALERT("Unfortunately, the snow is a little too compacted to be destroyed by hand."))

	attackby(obj/item/I, mob/user)
		attack_particle(user, src)
		user.lastattacked = get_weakref(src)
		playsound(get_turf(src), 'sound/misc/phoenix/phoenix_snow_crunch.ogg', 50, TRUE)

		if (isweldingtool(I) && I:welding)
			user.visible_message(SPAN_ALERT("[user] melts [src]!"), SPAN_ALERT("You melt [src]!"))
			qdel(src)
		else if (istype(I, /obj/item/shovel) || istype(I, /obj/item/slag_shovel) || istype(I, /obj/item/mining_tool/powered/shovel))
			user.visible_message(SPAN_ALERT("[user] shovels [src]!"), SPAN_ALERT("You shovel [src]!"))
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
			boutput(user, SPAN_ALERT("Unfortunately, [I] is too weak to damage [src]."))

	bullet_act(obj/projectile/P)
		playsound(get_turf(src), 'sound/misc/phoenix/phoenix_snow_crunch.ogg', 50, TRUE)
		if (P.power >= 20)
			src.visible_message(SPAN_ALERT("[src] is destroyed by [P]!"))
			qdel(src)
		else if (P.power)
			src.hits_left--
			if (src.hits_left <= 0)
				src.visible_message(SPAN_ALERT("[src] is destroyed by [P]!"))
				qdel(src)
			else
				..()

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		..()
		playsound(get_turf(src), 'sound/misc/phoenix/phoenix_snow_crunch.ogg', 50, TRUE)
		if (AM.throwforce >= 20)
			src.visible_message(SPAN_ALERT("[src] is destroyed by [AM]!"))
			qdel(src)
		else
			src.hits_left--
			if (src.hits_left <= 0)
				src.visible_message(SPAN_ALERT("[src] is destroyed by [AM]!"))
				qdel(src)

	Bumped(atom/A)
		if (istype(A, /obj/machinery/vehicle))
			playsound(get_turf(src), 'sound/misc/phoenix/phoenix_snow_crunch.ogg', 50, TRUE)
			qdel(src)
			return
		return ..()

	ex_act()
		playsound(get_turf(src), 'sound/misc/phoenix/phoenix_snow_crunch.ogg', 50, TRUE)
		qdel(src)

	blob_act()
		playsound(get_turf(src), 'sound/misc/phoenix/phoenix_snow_crunch.ogg', 50, TRUE)
		qdel(src)

	disposing()
		if (!(locate(/obj/decal/cleanable/water) in get_turf(src)))
			make_cleanable(/obj/decal/cleanable/water, get_turf(src))
		..()
