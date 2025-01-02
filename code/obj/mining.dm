// Magnet Stuff

/obj/machinery/magnet_chassis
	name = "magnet chassis"
	desc = "A strong metal rig designed to hold and link up magnet apparatus with other technology."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "chassis"
	opacity = 0
	density = 1
	anchored = ANCHORED_ALWAYS
	var/obj/machinery/mining_magnet/linked_magnet = null

	New()
		..()
		START_TRACKING
		SPAWN(0)
			src.update_dir()
			for (var/obj/machinery/mining_magnet/MM in range(1,src))
				linked_magnet = MM
				MM.linked_chassis = src
				break

	disposing()
		STOP_TRACKING
		if (linked_magnet)
			qdel(linked_magnet)
		linked_magnet = null
		..()

	attackby(obj/item/W, mob/user)
		#ifndef UNDERWATER_MAP
		if (istype(W,/obj/item/magnet_parts))
			if (istype(src.linked_magnet))
				boutput(user, SPAN_ALERT("There's already a magnet installed."))
				return
			actions.start(new/datum/action/bar/icon/magnet_build(W, src, user), user)
		else
			..()
		#endif

	ex_act()
		return

	meteorhit()
		return

	blob_act(var/power)
		return

	bullet_act(var/obj/projectile/P)
		return

	proc/update_dir()
		if (src.dir & (EAST|WEST))
			src.bound_height = 64
			src.bound_width = 32
		else
			src.bound_height = 32
			src.bound_width = 64

#ifndef UNDERWATER_MAP
/datum/action/bar/icon/magnet_build
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 24 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
	var/obj/item/magnet_parts/mag_parts = null
	var/obj/machinery/magnet_chassis/chassis = null
	var/mob/master = null

	New(var/obj/item/magnet_parts/parts, var/obj/machinery/magnet_chassis/target, var/mob/user)
		..()
		mag_parts = parts
		chassis = target
		if (ismob(user))
			master = user
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onStart()
		..()
		if (!master || is_incapacitated(master) || !IN_RANGE(master, chassis, 2)) //range of 2 since its a 32x64 sprite
			interrupt(INTERRUPT_ALWAYS)
			return
		if(istype(master.equipped(), /obj/item/magtractor))
			var/obj/item/magtractor/magtractor = master.equipped()
			if(mag_parts != magtractor.holding)
				interrupt(INTERRUPT_ALWAYS)
		else if (mag_parts != master.equipped())
			interrupt(INTERRUPT_ALWAYS)
		owner.visible_message(SPAN_NOTICE("[master] begins to assemble [mag_parts]!"))

	onUpdate()
		..()
		if (!master || is_incapacitated(master) || !IN_RANGE(master, chassis, 2)) //range of 2 since its a 32x64 sprite
			interrupt(INTERRUPT_ALWAYS)
			return
		if(istype(master.equipped(), /obj/item/magtractor))
			var/obj/item/magtractor/magtractor = master.equipped()
			if(mag_parts != magtractor.holding)
				interrupt(INTERRUPT_ALWAYS)
		else if (mag_parts != master.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()
		var/obj/machinery/mining_magnet/magnet = new mag_parts.constructed_magnet(get_turf(chassis))
		magnet.set_dir(chassis.dir)
		qdel(mag_parts)
		owner.visible_message(SPAN_NOTICE("[owner] constructs [magnet]!"))

/obj/item/magnet_parts
	name = "mineral magnet parts"
	desc = "Used to construct a new magnet on a magnet chassis."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	var/constructed_magnet = /obj/machinery/mining_magnet

/obj/item/magnet_parts/construction
	constructed_magnet = /obj/machinery/mining_magnet/construction

	small
		name = "small mineral magnet parts"
		constructed_magnet = /obj/machinery/mining_magnet/construction/small
#endif

/obj/magnet_target_marker
	name = "mineral magnet target"
	desc = "Marks the location of an area of asteroid magnetting."
	invisibility = INVIS_ALWAYS
	var/width = 15
	var/height = 15
	var/scan_range = 7
	var/turf/magnetic_center
	alpha = 128
	anchored = ANCHORED_ALWAYS

	small
		width = 7
		height = 7
		scan_range = 3

	ex_act()
		return
	meteorhit()
		return
	bullet_act()
		return

	proc/get_encounter_size(size, P)
		. = size
		if(!P || prob(P))
			var/max_r = round(min(width,height)/2)-1
			. = rand(size, max_r)

	proc/erase_area()
		var/turf/origin = get_turf(src)
		for (var/turf/T in block(origin, locate(origin.x + width - 1, origin.y + height - 1, origin.z)))
			for (var/obj/O in T)
				if (!(O.type in mining_controls.magnet_do_not_erase) && !istype(O, /obj/magnet_target_marker))
					qdel(O)
			T.ClearAllOverlays()
			for (var/mob/living/L in T)
				if(ismobcritter(L) && isdead(L)) // we don't care about dead critters
					qdel(L)
			if(istype(T,/turf/unsimulated) && ( T.can_build || (station_repair.station_generator && (origin.z == Z_LEVEL_STATION))))
				T.ReplaceWith(/turf/space, force=TRUE)
			else
				T.ReplaceWith(/turf/space)
			T.AddOverlays(new /image/fullbright, "fullbright")

	proc/generate_walls()
		var/list/walls = list()
		var/turf/origin = get_turf(src)
		for (var/cx = origin.x - 1, cx <= origin.x + width, cx++)
			var/turf/S = locate(cx, origin.y - 1, origin.z)
			if (S)
				var/Q = new /obj/forcefield/mining(S)
				walls += Q
			S = locate(cx, origin.y + width, origin.z)
			if (S)
				var/Q = new /obj/forcefield/mining(S)
				walls += Q
		for (var/cy = origin.y, cy <= origin.y + height - 1, cy++)
			var/turf/S = locate(origin.x - 1, cy, origin.z)
			if (S)
				var/Q = new /obj/forcefield/mining(S)
				walls += Q
			S = locate(origin.x + width, cy, origin.z)
			if (S)
				var/Q = new /obj/forcefield/mining(S)
				walls += Q
		return walls

	proc/check_for_unacceptable_content()
		// this used to use an area, which meant it only checked
		var/turf/origin = get_turf(src)
		var/unacceptable = FALSE
		for (var/turf/T in block(locate(origin.x-1, origin.y-1, origin.z), locate(origin.x + width, origin.y + height, origin.z)))

			for (var/mob/living/L in T)
				if(ismobcritter(L)) // we don't care about critters
					continue
				if(!isintangible(L)) //neither blob overmind or AI eye should block this
					unacceptable = TRUE
					break
			for (var/obj/machinery/vehicle/V in T)
				unacceptable = TRUE
				break

			for (var/obj/artifact/A in T) // check if an artifact has someone inside
				if (istype(A, /obj/artifact/prison))
					var/datum/artifact/prison/P = A.artifact
					if(istype(P.prisoner))
						unacceptable = TRUE
						break
				else if (istype(A, /obj/artifact/cloner))
					var/datum/artifact/cloner/C = A.artifact
					if(istype(C.clone))
						unacceptable = TRUE
						break

		return unacceptable

	proc/UL()
		var/turf/origin = get_turf(src)
		var/turf/ul = locate(origin.x, origin.y + height - 1, origin.z)
		return ul

	proc/UR()
		var/turf/origin = get_turf(src)
		var/turf/ur = locate(origin.x + width - 1, origin.y + height - 1, origin.z)
		return ur

	proc/DL()
		return get_turf(src)

	proc/DR()
		var/turf/origin = get_turf(src)
		var/turf/dr = locate(origin.x + width - 1, origin.y, origin.z)
		return dr

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/construct()
		var/turf/origin = get_turf(src)
		for (var/turf/T in block(origin, locate(origin.x + width - 1, origin.y + height - 1, origin.z)))
			if (!T)
				boutput(usr, SPAN_ALERT("Error: magnet area spans over construction area bounds."))
				return 0
			var/isterrain = T.can_build && istype(T,/turf/unsimulated)
			if ((!istype(T, /turf/space) && !isterrain) && !istype(T, /turf/simulated/floor/plating/airless/asteroid) && !istype(T, /turf/simulated/wall/auto/asteroid))
				boutput(usr, SPAN_ALERT("Error: [T] detected in [width]x[height] magnet area. Cannot magnetize."))
				return 0

		var/borders = list()
		for (var/cx = origin.x - 1, cx <= origin.x + width, cx++)
			var/turf/S = locate(cx, origin.y - 1, origin.z)
			var/isterrain = S.can_build && istype(S,/turf/unsimulated)
			if (!S || istype(S, /turf/space) || isterrain)
				boutput(usr, SPAN_ALERT("Error: bordering tile has a gap, cannot magnetize area."))
				return 0
			borders += S
			S = locate(cx, origin.y + height, origin.z)
			isterrain = S.can_build && istype(S,/turf/unsimulated)
			if (!S || istype(S, /turf/space) || isterrain)
				boutput(usr, SPAN_ALERT("Error: bordering tile has a gap, cannot magnetize area."))
				return 0
			borders += S

		for (var/cy = origin.y, cy <= origin.y + height - 1, cy++)
			var/turf/S = locate(origin.x - 1, cy, origin.z)
			var/isterrain = S.can_build && istype(S,/turf/unsimulated)
			if (!S || istype(S, /turf/space) || isterrain)
				boutput(usr, SPAN_ALERT("Error: bordering tile has a gap, cannot magnetize area."))
				return 0
			borders += S
			S = locate(origin.x + width, cy, origin.z)
			isterrain = S.can_build && istype(S,/turf/unsimulated)
			if (!S || istype(S, /turf/space) || isterrain)
				boutput(usr, SPAN_ALERT("Error: bordering tile has a gap, cannot magnetize area."))
				return 0
			borders += S

		magnetic_center = locate(origin.x + round(width/2), origin.y + round(height/2), origin.z)
		for (var/turf/simulated/floor/T in borders)
			T.allows_vehicles = 1
		return 1

/obj/item/magnetizer
	name = "Magnetizer"
	desc = "A gun that manipulates the magnetic flux of an area. The designated area can then be activated or deactivated with a mineral magnet."
	icon = 'icons/obj/construction.dmi'
	icon_state = "magnet"
	var/loaded = 0
	force = 0
	var/obj/machinery/mining_magnet/construction/magnet = null

	examine()
		. = ..()
		if (loaded)
			. += SPAN_NOTICE("The magnetizer is loaded with a plasmastone. Designate the mineral magnet to attach, then designate the lower left tile of the area to magnetize.")
			. += SPAN_NOTICE("The magnetized area must be a clean shot of space, surrounded by bordering tiles on all sides.")
			. += SPAN_NOTICE("A small mineral magnet requires an 7x7 area of space, a large one requires a 15x15 area of space.")
		else
			. += SPAN_ALERT("The magnetizer must be loaded with a chunk of plasmastone to use.")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/raw_material/plasmastone) && !loaded)
			loaded = 1
			boutput(user, SPAN_NOTICE("You charge the magnetizer with the plasmastone."))
			W.change_stack_amount(-1)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		var/turf/target_turf = target
		var/isterrain = istype(target_turf,/turf/unsimulated) && target_turf.can_build
		if (!magnet)
			if (istype(target, /obj/machinery/magnet_chassis))
				magnet = target:linked_magnet
			else
				magnet = target
			ENSURE_TYPE(magnet)
			else
				if (!loaded)
					boutput(user, SPAN_ALERT("The magnetizer needs to be loaded with a plasmastone chunk first."))
					magnet = null
				else if (magnet.target)
					boutput(user, SPAN_ALERT("That magnet is already locked onto a location."))
					magnet = null
				else
					boutput(user, SPAN_NOTICE("Magnet locked. Designate lower left tile of target area (excluding the borders)."))
		else if ((istype(target, /turf/space) || isterrain) && magnet)
			if (!loaded)
				boutput(user, SPAN_ALERT("The magnetizer needs to be loaded with a plasmastone chunk first."))
			if (magnet.target)
				boutput(user, SPAN_ALERT("Magnet target already designated. Unlocking."))
				magnet = null
				return
			var/turf/T = target
			var/obj/magnet_target_marker/M = new magnet.marker_type(T)
			var/turf/A = M.DL()
			var/turf/B = M.DR()
			var/turf/C = M.UL()
			var/turf/D = M.UR()
			var/turf/O = get_turf(target)
			var/dist = min(min(GET_DIST(A, O), GET_DIST(B, O)), min(GET_DIST(C, O), GET_DIST(D, O)))
			if (dist > 10)
				boutput(user, SPAN_ALERT("Designation failed: designated tile is outside magnet range."))
				qdel(M)
			else if (!M.construct())
				boutput(user, SPAN_ALERT("Designation failed."))
				qdel(M)
			else
				boutput(user, SPAN_NOTICE("Designation successful. The magnet is now fully operational."))
				magnet.target = M
				loaded = 0
				magnet = null

/obj/machinery/mining_magnet
	name = "mineral magnet"
	desc = "A piece of machinery able to generate a strong magnetic field to attract mineral sources."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "magnet"
	opacity = 0
	density = 0 // collision is dealt with by the chassis
	anchored = ANCHORED_ALWAYS
	req_access = list(access_mining, access_mining_outpost)
	var/obj/machinery/magnet_chassis/linked_chassis = null
	var/health = 100
	var/attract_time = 300
	var/cooldown_time = 1200
	var/active = 0
	var/last_used = 0
	var/last_use_attempt = 0
	var/automatic_mode = 0
	var/auto_delay = 100
	var/last_delay = 0
	var/cooldown_override = 0
	var/malfunctioning = 0
	var/rarity_mod = 0

	var/autosetup = TRUE

	var/image/active_overlay = null
	var/list/damage_overlays = list()
	var/sound_activate = 'sound/machines/ArtifactAnc1.ogg'
	var/sound_destroyed = 'sound/impact_sounds/Machinery_Break_1.ogg'
	var/obj/machinery/power/apc/mining_apc = null

	var/marker_type = /obj/magnet_target_marker
	var/obj/magnet_target_marker/target = null
	var/list/wall_bits = list()

	// reworked to nolonger use areas
	proc/get_magnetic_center()
		return target?.magnetic_center // the target marker has the center

	proc/get_scan_range() // reworked
		if (target)
			return target.scan_range
		return 6 // 6 if there's no center marker

	proc/check_for_unacceptable_content()
		if (target)
			return target.check_for_unacceptable_content()
		return 1 // fail if there's no center marker

	proc/get_encounter(var/rarity_mod)
		return mining_controls.select_encounter(rarity_mod)

	construction // here so old maps dont get broken
		autosetup = FALSE

		small
			marker_type = /obj/magnet_target_marker/small
			get_encounter(rarity_mod)
				return mining_controls.select_small_encounter(rarity_mod)

	New()
		..()
		active_overlay = image(src.icon, "active")
		damage_overlays += image(src.icon, "damage-1")
		damage_overlays += image(src.icon, "damage-2")
		damage_overlays += image(src.icon, "damage-3")
		damage_overlays += image(src.icon, "damage-4")
		SPAWN(0)
			for (var/obj/machinery/magnet_chassis/MC in range(1,src))
				linked_chassis = MC
				MC.linked_magnet = src
				break
			// mining magnets can automatically set up immediately at roundstart as a treat
			if (!target && autosetup)
				var/obj/closest
				var/closestDistance = 300

				// find the closest marker. there should be one per magnet

				// Magnet center is used first
				for_by_tcl(marker, /obj/magnet_target_marker)
					if (istype(marker,marker_type))
						if (GET_DIST(marker,src) < closestDistance) // same as the magnetizer limit i think
							closest = marker
				src.target = closest
				if (istype(target))
					target.construct()
			if (!mining_apc) // no checking 400 tiles for an apc holy shit
				mining_apc = get_local_apc()

	process()

		if (!target)
			return
		if (automatic_mode && last_used < TIME && last_delay < TIME)
			if (target.check_for_unacceptable_content())
				last_delay = TIME + auto_delay
				return
			else
				SPAWN(0) //Did you know that if you sleep directly in process() you are the old lady at the mall who only pays in quarters.
					//Do not be quarter lady.
					pull_new_source()

	disposing()
		src.health = 0 // DIE!!!!!! GOD!!!! (this makes sure the computers know the magnet is Dead and Buried)
		src.visible_message("<b>[src] breaks apart!</b>")
		robogibs(src.loc)
		playsound(src.loc, src.sound_destroyed, 50, 2)
		overlays = list()
		damage_overlays = list()
		linked_chassis?.linked_magnet = null
		linked_chassis = null
		active_overlay = null
		sound_activate = null
		..()

	examine()
		. = ..()
		if (src.health < 100)
			if (src.health < 50)
				. += SPAN_ALERT("It's rather badly damaged. It probably needs some wiring replaced inside.")
			else
				. += SPAN_ALERT("It's a bit damaged. It looks like it needs some welding done.")

	ex_act(severity)
		switch(severity)
			if(1)
				src.damage(rand(75,120))
			if(2)
				src.damage(rand(25,75))
			if(3)
				src.damage(rand(10,25))

	meteorhit()
		src.damage(rand(10,25))
		return

	blob_act(var/power)
		return

	bullet_act(var/obj/projectile/P)
		return

	attackby(obj/item/W, mob/user)
		if (src.active)
			boutput(user, SPAN_ALERT("It's way too dangerous to do that while it's active!"))
			return

		if (isweldingtool(W))
			if (src.health < 50)
				boutput(user, SPAN_ALERT("You need to use wire to fix the cabling first."))
				return
			if(W:try_weld(user, 1))
				src.damage(-10)
				src.malfunctioning = 0
				user.visible_message("<b>[user]</b> uses [W] to repair some of [src]'s damage.")
				if (src.health >= 100)
					boutput(user, SPAN_NOTICE("<b>[src] looks fully repaired!</b>"))

		else if (istype(W,/obj/item/cable_coil/))
			var/obj/item/cable_coil/C = W
			if (src.health > 50)
				boutput(user, SPAN_ALERT("The cabling looks fine. Use a welder to repair the rest of the damage."))
				return
			C.use(1)
			src.damage(-10)
			user.visible_message("<b>[user]</b> uses [C] to repair some of [src]'s cabling.")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			if (src.health >= 50)
				boutput(user, SPAN_NOTICE("The wiring is fully repaired. Now you need to weld the external plating."))
				src.malfunctioning = 0

		else
			..()
			if (W.hitsound)
				playsound(src.loc, W.hitsound, 50, 1)
			if (W.force)
				var/damage = W.force
				damage /= 3
				if (user.is_hulk())
					damage *= 4
				if (iscarbon(user))
					var/mob/living/carbon/C = user
					if (C.bioHolder && C.bioHolder.HasEffect("strong"))
						damage *= 2
				if (damage >= 10)
					src.damage(damage)

	proc/build_icon()
		src.ClearAllOverlays()

		if (length(damage_overlays) == 4)
			switch(src.health)
				if (70 to 94)
					src.AddOverlays(damage_overlays[1], "magnet_damage")
				if (40 to 69)
					src.AddOverlays(damage_overlays[2], "magnet_damage")
				if (10 to 39)
					src.AddOverlays(damage_overlays[3], "magnet_damage")
				if (-INFINITY to 10)
					src.AddOverlays(damage_overlays[4], "magnet_damage")

		if (src.active)
			src.AddOverlays(src.active_overlay, "magnet_active")

	// Sanity check to make sure we gib on no health
	proc/check_should_die()
		if (isnull(src.health) || src.health <= 0)
			qdel(src)
			return TRUE
		return FALSE

	proc/damage(var/amount)
		if (!isnum(amount))
			return

		src.health -= amount
		src.health = clamp(src.health, 0, 100)

		if (src.health < 1 && !src.active)
			qdel(src)
			return

		build_icon()
		if (!prob(src.health) && amount > 0)
			src.malfunctioning = 1
		return

	proc/do_malfunction()
		var/picker = rand(1,2)
		switch(picker)
			if (1)
				src.visible_message("<b>[src] makes a loud bang! That didn't sound too good...</b>")
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				src.damage(rand(5,10))
			if (2)
				if (istype(mining_apc))
					mining_apc.visible_message("<b>Magnetic feedback causes [mining_apc] to go haywire!</b>")
					mining_apc.zapStuff()

	proc/pull_new_source(var/selectable_encounter_id = null)
		if (!target)
			return

		if (!length(wall_bits))
			wall_bits = target.generate_walls()

		for (var/obj/forcefield/mining/M in wall_bits)
			M.set_opacity(1)
			M.set_density(1)
			M.invisibility = INVIS_NONE

		active = 1

		if (last_used > TIME)
			damage(rand(2,6))

		last_used = TIME + cooldown_time
		playsound(src.loc, sound_activate, 100, 0, 3, 0.25)
		build_icon()

		target.erase_area()

		var/sleep_time = attract_time
		if (sleep_time < 1)
			sleep_time = 20
		sleep_time /= 3

		if (malfunctioning && prob(20))
			do_malfunction()
		sleep(sleep_time)

		// Ensure area is erased, helps if atmos is being a jerk
		target.erase_area()
		sleep(sleep_time)

		var/datum/mining_encounter/MC

		if(selectable_encounter_id != null)
			if(selectable_encounter_id in mining_controls.mining_encounters_selectable)
				MC = mining_controls.mining_encounters_selectable[selectable_encounter_id]
				mining_controls.remove_selectable_encounter(selectable_encounter_id)
			else
				boutput(usr, "Uh oh, something's gotten really fucked up with the magnet system. Please report this to a coder! (ERROR: INVALID ENCOUNTER)")
				MC = get_encounter(rarity_mod)
		else
			MC = get_encounter(rarity_mod)

		if(MC)
			MC.generate(target)
		else
			for (var/obj/forcefield/mining/M in wall_bits)
				M.set_opacity(0)
				M.set_density(0)
				M.invisibility = INVIS_INFRA
			active = 0
			boutput(usr, "Uh oh, something's gotten really fucked up with the magnet system. Please report this to a coder! (ERROR: NO ENCOUNTER)")
			return

		if(station_repair.station_generator)
			var/list/turf/space/repair_turfs = list()
			var/turf/origin = get_turf(target)
			for (var/turf/space/T in block(origin, locate(origin.x + target.width - 1, origin.y + target.height - 1, origin.z)))
				repair_turfs += T
			station_repair.repair_turfs(repair_turfs, force_floor=TRUE)

		sleep(sleep_time)
		if (malfunctioning && prob(20))
			do_malfunction()

		active = 0
		build_icon()

		for (var/obj/forcefield/mining/M in wall_bits)
			M.set_opacity(0)
			M.set_density(0)
			M.invisibility = INVIS_ALWAYS

		src.check_should_die()
		src.updateUsrDialog()
		return

	ui_data(mob/user)
		. = ..()
		.["magnetHealth"] = src.health
		.["magnetActive"] = src.active
		.["magnetLastUsed"] = src.last_used
		.["magnetCooldownOverride"] = src.cooldown_override
		.["magnetAutomaticMode"] = src.automatic_mode

		var/list/miningEncounters = list()
		for(var/encounter_id in mining_controls.mining_encounters_selectable)
			var/datum/mining_encounter/encounter = mining_controls.mining_encounters_selectable[encounter_id]
			if(istype(encounter))
				miningEncounters += list(list(
					name = encounter.name,
					id = encounter_id
				))
		.["miningEncounters"] = miningEncounters

		.["time"] = TIME

	ui_act(action, params)
		. = ..()
		var/magnetNotReady = src.active || (src.last_used > TIME && !src.cooldown_override) || src.last_use_attempt > TIME
		switch(action)
			if ("geoscan")
				var/MC = src.get_magnetic_center()
				if (!MC)
					boutput(usr, "Error. Magnet is not magnetized.")
					return
				mining_scan(MC, usr, src.get_scan_range())
			if ("activateselectable")
				if (magnetNotReady)
					return
				if (!target || !src.get_magnetic_center())
					src.visible_message("<b>[src.name]</b> states, \"Magnetic field strength error. Please ensure mining area is properly magnetized\"")
					return

				if (target.check_for_unacceptable_content())
					src.visible_message("<b>[src.name]</b> states, \"Safety lock engaged. Please remove all personnel and vehicles from the magnet area.\"")
				else
					src.last_use_attempt = TIME + 10
					src.pull_new_source(params["encounter_id"])
					. = TRUE
			if ("activatemagnet")
				if (magnetNotReady)
					return
				if (!target || !src.get_magnetic_center())
					src.visible_message("<b>[src.name]</b> states, \"Magnetic field strength error. Please ensure mining area is properly magnetized\"")
					return

				if (target.check_for_unacceptable_content())
					src.visible_message("<b>[src.name]</b> states, \"Safety lock engaged. Please remove all personnel and vehicles from the magnet area.\"")
				else
					src.last_use_attempt = TIME + 10 // This is to prevent href exploits or autoclickers from pulling multiple times simultaneously
					src.pull_new_source()
					. = TRUE
			if("overridecooldown")
				if (!ishuman(usr))
					boutput(usr, SPAN_ALERT("AI and robotic personnel may not access the override."))
				else
					var/mob/living/carbon/human/H = usr
					if(!src.allowed(H))
						boutput(usr, SPAN_ALERT("Access denied."))
					else
						src.cooldown_override = !src.cooldown_override
					. = TRUE
			if("automode")
				src.automatic_mode = !src.automatic_mode
				. = TRUE

	ui_status(mob/user, datum/ui_state/armed)
		. = tgui_broken_state.can_use_topic(src, user)


/obj/machinery/computer/magnet
	name = "mineral magnet controls"
	icon = 'icons/obj/computer.dmi'
	icon_state = "mmagnet"
	circuit_type = /obj/item/circuitboard/mining_magnet
	var/temp = null
	var/list/linked_magnets = list()
	var/obj/machinery/mining_magnet/linked_magnet = null
	req_access = list(access_mining)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	can_reconnect = 1 //IDK why you'd want to but for consistency's sake

	New()
		..()
		SPAWN(0)
			src.connection_scan()

	ui_interact(mob/user, datum/tgui/ui)
		if(!src.allowed(user))
			boutput(user, SPAN_ALERT("Access Denied."))
			return
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "MineralMagnet", src.name)
			ui.open()

	ui_data(mob/user)
		. = ..()
		.["linkedMagnets"] = null

		if(istype(linked_magnet))
			. = linked_magnet.ui_data(user)
			.["isLinked"] = TRUE
		else
			var/list/linkedMagnets = list()
			for (var/obj/M in linked_magnets)
				var/magnetData = list(
					name = M.name,
					x = M.x,
					y = M.y,
					z = M.z,
					ref = "\ref[M]",
					angle = -arctan(M.x - user.x, M.y - user.y)
				)
				linkedMagnets += list(magnetData)
			.["linkedMagnets"] = linkedMagnets
			.["isLinked"] = FALSE

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch(action)
			if("linkmagnet")
				src.connection_scan() // Magnets can explode inbetween scanning and linking
				linked_magnet = locate(params["ref"]) in linked_magnets
				if (!istype(linked_magnet))
					linked_magnet = null
					src.visible_message("<b>[src.name]</b> states, \"Designated magnet is no longer operational.\"")
				. = TRUE
			if ("magnetscan")
				switch(src.connection_scan())
					if(1)
						src.visible_message("<b>[src.name]</b> states, \"Unoccupied Magnet Chassis located. Please connect magnet system to chassis.\"")
					if(2)
						src.visible_message("<b>[src.name]</b> states, \"Magnet equipment not found within range.\"")
					else
						src.visible_message("<b>[src.name]</b> states, \"Magnet equipment located. Link established.\"")
				. = TRUE
			if ("unlinkmagnet")
				src.linked_magnet = null
				. = TRUE
			else
				if(istype(src.linked_magnet))
					if (src.linked_magnet.health <= 0)
						src.linked_magnet = null // ITS DEAD!!!! STOP!!!
						src.visible_message("<b>[src.name]</b> states, \"Designated magnet is no longer operational.\"")
						return
					. = src.linked_magnet.ui_act(action, params)

/obj/machinery/computer/magnet/connection_scan()
	linked_magnets = list()
	var/badmagnets = 0
	for_by_tcl(MC, /obj/machinery/magnet_chassis)
		if(!IN_RANGE(MC, src, 20))
			continue
		if (MC.linked_magnet)
			linked_magnets += MC.linked_magnet
		else
			badmagnets++
	if (linked_magnets.len)
		return 0
	if (badmagnets)
		return 1
	return 2

// Turf Defines

TYPEINFO(/turf/simulated/wall/auto/asteroid)
TYPEINFO_NEW(/turf/simulated/wall/auto/asteroid)
	. = ..()
	connect_overlay = 0
	connect_diagonal = 1
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/asteroid,
		/turf/simulated/wall/false_wall,
		/obj/structure/woodwall,
		/obj/machinery/door/poddoor/blast/asteroid
	))
/turf/simulated/wall/auto/asteroid
	icon = 'icons/turf/walls/asteroid.dmi'
#ifdef PERSPECTIVE_EDITOR_WALL
	icon_state = "asteroid-perspective-map"
#else
	icon_state = "asteroid-map"
#endif
	mod = "asteroid-"
	light_mod = "wall-"
	plane = PLANE_NOSHADOW_BELOW
	layer = ASTEROID_LAYER
	flags = FLUID_DENSE | IS_PERSPECTIVE_FLUID
	default_material = "rock"
	color = "#D1E6FF"

#ifdef UNDERWATER_MAP
	name = "cavern wall"
	desc = "A cavern wall, possibly flowing with mineral deposits."
#else
	name = "asteroid"
	desc = "A free-floating mineral deposit from space."
#endif

#ifdef UNDERWATER_MAP
	var/hardness = 1
#else
	var/hardness = 0
#endif

	var/stone_color = "#D1E6FF"
	var/weakened = 0
	var/amount = 2
	var/invincible = 0
	var/default_ore = /obj/item/raw_material/rock
	var/datum/ore/ore = null
	var/datum/ore/event/event = null
	var/list/space_overlays = null
	var/turf/replace_type = /turf/simulated/floor/plating/airless/asteroid

	//NEW VARS
	var/mining_health = 120
	var/mining_max_health = 120
	var/mining_toughness = 1 //Incoming damage divided by this unless tool has power enough to overcome.
	var/topnumber = 1
	var/orenumber = 1
	var/static/list/icon/topoverlaycache

	dark
		fullbright = 0
		luminosity = 1

		space_overlays()
			. = ..()
			if (length(space_overlays)) // Are we on the edge of a chunk wall
				if (src.ore) return // Skip if there's ore here already
				var/list/color_vals = bioluminescent_algae?.get_color(src)
				if (length(color_vals))
					var/image/algea = image('icons/obj/sealab_objects.dmi', "algae")
					algea.color = rgb(color_vals[1], color_vals[2], color_vals[3])
					algea.filters += filter(type="alpha", icon=icon('icons/turf/walls/asteroid.dmi',"mask-side_[src.icon_state]"))
					AddOverlays(algea, "glow_algae")
					add_medium_light("glow_algae", color_vals)

		destroy_asteroid(dropOre)
			ClearSpecificOverlays("glow_algae")
			remove_medium_light("glow_algae")
			var/list/turf/neighbors = getNeighbors(src, alldirs)
			for (var/turf/T as anything in neighbors)
				if (!length(T.medium_lights)) continue
				T.update_medium_light_visibility()
			. = ..()

	lighted
		fullbright = 1

	ice
		name = "comet chunk"
		desc = "That's some cold stuff right there."
		color = "#9cc4f5"
		stone_color = "#9cc4f5"
		default_ore = /obj/item/raw_material/ice

	geode
		name = "compacted stone"
		desc = "This rock looks really hard to dig out."
		color = "#4c535c"
		stone_color = "#4c535c"
		default_ore = null
		hardness = 10

	jean
		name = "jasteroid"
		desc = "A free-floating jineral jeposit from space."
		default_ore = null
		hardness = 1
		default_material = "jean"
		default_ore = /obj/item/material_piece/cloth/jean
		replace_type = /turf/simulated/floor/plating/airless/asteroid/jean
		color = "#88c2ff"
		stone_color = "#88c2ff"


// cogwerks - adding some new wall types for cometmap and whatever else

	comet
		fullbright = 0
		name = "regolith"
		desc = "It's dusty and cold."
		stone_color = "#7d93ad"
		icon_state = "comet"
		hardness = 1
		default_ore = /obj/item/raw_material/rock

		// varied layers

		ice
			name = "comet ice"
			icon_state = "comet_ice"
			stone_color = "#a8cdfa"
			default_ore = /obj/item/raw_material/ice
			hardness = 2

		ice_dense
			name = "dense ice"
			desc = "A compressed layer of comet ice."
			icon_state = "comet_ice_dense"
			stone_color = "#2070CC"
			default_ore = /obj/item/raw_material/ice
			hardness = 5
			amount = 6

		ice_char
			name = "dark regolith"
			icon_state = "comet_char"
			desc = "An inky-black assortment of carbon-rich dust and ice."
			stone_color = "#111111"
			default_ore = /obj/item/raw_material/char

		glassy
			name = "blasted regolith"
			desc = "This stuff has been blasted and fused by stellar radiation and impacts."
			icon_state = "comet_glassy"
			stone_color = "#111111"
			default_ore = /obj/item/raw_material/molitz
			hardness = 4

		copper
			name = "metallic rock"
			desc = "Rich in soft metals."
			icon_state = "comet_copper"
			stone_color = "#553333"
			default_ore = /obj/item/raw_material/pharosium

		iron
			name = "ferrous rock"
			desc = "Dense metallic rock."
			icon_state = "comet_iron"
			stone_color = "#333333"
			default_ore = /obj/item/raw_material/mauxite
			hardness = 8

		plasma
			name = "plasma ice"
			desc = "Concentrated plasma trapped in dense ice."
			icon_state = "comet_plasma"
			default_ore = /obj/item/raw_material/plasmastone
			hardness = 5

		radioactive
			name = "radioactive metal"
			desc = "There's a hazardous amount of radioactive material in this metallic layer."
			icon_state = "comet_radioactive"
			stone_color = "#114444"
			default_ore = /obj/item/raw_material/cerenkite
			hardness = 10

	algae
		name = "sea foam"
		desc = "Rapid depressuziation has flash-frozen sea water and algae into hardened foam."
		color = "#6090a0"
		stone_color = "#6090a0"
		fullbright = 0
		luminosity = 1

		space_overlays()
			. = ..()
			if (!length(space_overlays)) // Are we on the edge of a chunk wall
				return
			var/image/algea = image('icons/obj/sealab_objects.dmi', "algae")
			var/color_vals = list(rand(100,200), rand(100,200), rand(100,200), 30)  // random colors, muted
			algea.color = rgb(color_vals[1], color_vals[2], color_vals[3])
			algea.filters += filter(type="alpha", icon=icon('icons/turf/walls/asteroid.dmi',"mask-side_[src.icon_state]"))
			AddOverlays(algea, "glow_algae")
			add_medium_light("glow_algae", color_vals)

		destroy_asteroid(dropOre)
			ClearSpecificOverlays("glow_algae")
			remove_medium_light("glow_algae")
			var/list/turf/neighbors = getNeighbors(src, alldirs)
			for (var/turf/T as anything in neighbors)
				if (!length(T.medium_lights)) continue
				T.update_medium_light_visibility()
			return ..()

	consider_superconductivity(starting)
		return FALSE


	New(var/loc)
		LAZYLISTINIT(topoverlaycache)
		src.space_overlays = list()
		src.topnumber = pick(1,2,3)
		src.orenumber = pick(1,2,3)
		..()
		if(current_state <= GAME_STATE_PREGAME)
			worldgenCandidates += src
			src.color = src.stone_color
		else
			SPAWN(1)
				if(istype(src, /turf/simulated/wall/auto/asteroid))
					space_overlays()

	generate_worldgen()
		. = ..()
		src.space_overlays()
		src.top_overlays()

	ex_act(severity)
		switch(severity)
			if(1)
				src.damage_asteroid(7)
			if(2)
				src.damage_asteroid(5)
			if(3)
				src.damage_asteroid(3)
		return

	meteorhit(obj/M as obj)
		src.damage_asteroid(5)

	blob_act(var/power)
		if(prob(power))
			src.damage_asteroid(7)

	dismantle_wall()
		return src.destroy_asteroid()

	get_desc(dist)
		if (dist > 1)
			return
		if (ishuman(usr))
			if (usr.bioHolder && usr.traitHolder.hasTrait("training_miner"))
				if (istype (src.ore,/datum/ore/))
					var/datum/ore/O = src.ore
					. = "It looks like it contains [O.name]."
				else
					. = "Doesn't look like there's any valuable ore here."
				if (src.event)
					. += "<br>[SPAN_ALERT("There's something not quite right here...")]"

	attack_hand(var/mob/user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.gloves, /obj/item/clothing/gloves/concussive))
				var/obj/item/clothing/gloves/concussive/C = H.gloves
				src.dig_asteroid(user,C.tool)
				return
			else if (H.is_hulk())
				H.visible_message(SPAN_ALERT("<b>[H.name] punches [src] with great strength!"))
				playsound(H.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 100, 1)
				src.damage_asteroid(3)
				return
		..()

// XXXXX SHIT IS HERE zamujasa HONK FARTRIUM

	Bumped(var/atom/A) //This is a bit hacky, sorry. Better than duplicating all the code.
		if(isliving(A))
			var/mob/living/L = A
			var/mob/living/carbon/human/H
			if(ishuman(L))
				H = L
			var/obj/item/held = L.equipped()
			if(istype(held, /obj/item/mining_tool) || istype(held, /obj/item/mining_tools) || (isnull(held) && H && (H.is_hulk() || istype(H.gloves, /obj/item/clothing/gloves/concussive))))
				UNLINT(L.click(src, list(), null, null))
			return

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/mining_tool/))
			var/obj/item/mining_tool/T = W
			src.dig_asteroid(user,T)
		else if (istype(W, /obj/item/mining_tools))
			return // matsci `mining_tools` handle their own digging
		else if (istype(W, /obj/item/oreprospector))
			var/message = "----------------------------------<br>"
			message += "<B>Geological Report:</B><br><br>"
			var/datum/ore/O = src.ore
			var/datum/ore/event/E = src.event
			if (O)
				message += "This stone contains [O.name].<br>"
				message += "Analysis suggests [src.amount] units of viable ore are present.<br>"
			else
				message += "This rock contains no known ores.<br>"
			message += "The rock here has a hardness rating of [src.hardness].<br>"
			if (src.weakened)
				message += "The rock here has been weakened.<br>"
			if (E)
				if (E.analysis_string)
					message += "[SPAN_ALERT("[E.analysis_string]")]<br>"
			message += "----------------------------------"
			boutput(user, message)
		else
			boutput(user, SPAN_ALERT("You hit the [src.name] with [W], but nothing happens!"))
		return

	proc/change_health(var/amount=0)
		if(amount != 0)
			if(amount < 0)
				//Add conditional check for tool strengthh
				amount /= mining_toughness

			mining_health += amount
			if(mining_health <= 0)
				destroy_asteroid()
			else
				update_damage_overlay()
		return

	proc/update_damage_overlay()
		var/health_prc = (mining_health / mining_max_health)

		if(health_prc >= 1)
			ClearSpecificOverlays("damage")
		else if(health_prc > 0.66 && health_prc < 1)
			setTexture("damage1", BLEND_MULTIPLY, "damage")
		else if(health_prc > 0.33 && health_prc < 0.66)
			setTexture("damage2", BLEND_MULTIPLY, "damage")
		else if(health_prc < 0.33)
			setTexture("damage3", BLEND_MULTIPLY, "damage")
		return

	update_icon()
		. = ..()
		src.color = src.stone_color
		var/image/light
		if(!src.fullbright)
			light = src.GetOverlayImage("ambient")
		src.ClearAllOverlays() // i know theres probably a better way to handle this
		if(light)
			src.AddOverlays(light, "ambient")
		if(src.fullbright)
			src.AddOverlays(new/image/fullbright, "fullbright")
		src.top_overlays()
		src.ore_overlays()

	proc/top_overlays() // replaced what was here with cool stuff for autowalls
		var/image/top_overlay = mutable_appearance('icons/turf/walls/asteroid.dmi',"top[src.topnumber]")
		var/icon/cached = topoverlaycache["mask2[src.icon_state]"]
		if(!cached)
			topoverlaycache["mask2[src.icon_state]"] = icon('icons/turf/walls/asteroid.dmi',"mask2[src.icon_state]")
			cached = topoverlaycache["mask2[src.icon_state]"]
		top_overlay.filters += filter(type="alpha", icon=cached)
		top_overlay.layer = ASTEROID_TOP_OVERLAY_LAYER
		AddOverlays(top_overlay, "ast_top_rock")

	proc/ore_overlays()
		if(src.ore) // make sure ores dont turn invisible
			var/image/ore_overlay = mutable_appearance('icons/turf/walls/asteroid.dmi',"[src.ore?.name][src.orenumber]")
			ore_overlay.filters += filter(type="alpha", icon=icon('icons/turf/walls/asteroid.dmi',"mask-side_[src.icon_state]"))
			ore_overlay.layer = ASTEROID_ORE_OVERLAY_LAYER // so meson goggle nerds can still nerd away
			src.AddOverlays(ore_overlay, "ast_ore")

	proc/space_overlays()
		for (var/turf/A in orange(src,1))
			var/dir_from = get_dir(A, src)
			var/dir_to = get_dir(src, A)
			var/skip_this = !istype(A, /turf/space)
			if (!skip_this && !is_cardinal(dir_to))
				for (var/cardinal_dir in cardinal)
					if (dir_to & cardinal_dir)
						var/turf/T = get_step(src, cardinal_dir)
						if (!istype(T, /turf/space))
							skip_this = TRUE
							break
			if (skip_this)
				A.ClearSpecificOverlays("ast_edge_[dir_from]")
				continue
			var/image/edge_overlay = mutable_appearance('icons/turf/walls/asteroid.dmi', "edge[dir_from]")
			edge_overlay.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR | RESET_ALPHA
			edge_overlay.layer = src.layer + 1
			edge_overlay.plane = PLANE_NOSHADOW_BELOW
			edge_overlay.layer = TURF_EFFECTS_LAYER
			edge_overlay.color = src.stone_color
			A.AddOverlays(edge_overlay, "ast_edge_[dir_from]")
			src.space_overlays += edge_overlay

	Del()
		for(var/turf/T in orange(src, 1))
			T.ClearSpecificOverlays("ast_edge_[get_dir(T, src)]")
		..()

	proc/dig_asteroid(var/mob/living/user, var/obj/item/mining_tool/tool)
		if (!user || !tool || !istype(src)) return

		var/datum/ore/event/E = src.event

		playsound(user.loc, tool.get_mining_sound(), 50, 1)
		if (tool.is_weakener())
			src.weaken_asteroid()

		var/strength = tool.get_dig_strength()
		if (iscarbon(user))
			var/mob/living/carbon/C = user
			if (C.bioHolder && C.bioHolder.HasOneOfTheseEffects("strong","hulk"))
				strength++

		var/minedifference = src.hardness - strength

		if (E)
			E.onHit(src)

		if (src.ore)
			src.ore.onHit(src)
		//user.visible_message(SPAN_ALERT("[user.name] strikes [src] with [tool]."))

		var/dig_chance = 100
		var/dig_feedback = null

		switch(minedifference)
			if (1)
				dig_chance = 30
				dig_feedback = "This rock is tough. You may need a stronger tool."
			if (2)
				dig_chance = 10
				dig_feedback = "This rock is very tough. You'll be faster with a stronger tool."
			if (3 to INFINITY)
				dig_chance = 0
				dig_feedback = "You can't even make a dent! You need a stronger tool."

		if (prob(dig_chance))
			destroy_asteroid()
		else
			if (dig_feedback)
				boutput(user, SPAN_ALERT("[dig_feedback]"))

		return

	proc/weaken_asteroid()
		if (src.weakened)
			return
		src.weakened = 1
		if (src.hardness >= 1)
			src.hardness /= 2
		else
			src.hardness = 0
		src.AddOverlays(image('icons/turf/walls/asteroid.dmi', "weakened"), "asteroid_weakened")

	proc/damage_asteroid(var/power,var/allow_zero = 0)
		// use this for stuff that arent mining tools but still attack asteroids
		if (!isnum(power) || (power <= 0 && !allow_zero))
			return
		var/difference = ((src.hardness < 1) ? round(src.hardness) : src.hardness) - power //If less than 1, round to 0

		if (src.ore)
			src.ore.onHit(src)

		var/datum/ore/event/E = src.event

		if (E)
			E.onHit(src)

		if (difference <= 0)
			destroy_asteroid()
		else
			if (rand(1,difference) == 1)
				weaken_asteroid()

		return

	proc/destroy_asteroid(var/dropOre=1)
		var/image/weather = GetOverlayImage("weather")
		var/image/ambient = GetOverlayImage("ambient")

		var/datum/ore/O = src.ore
		var/datum/ore/event/E = src.event
		if (src.invincible)
			return
		if (E)
			if (E.excavation_string)
				src.visible_message(SPAN_ALERT("[E.excavation_string]"))
			E.onExcavate(src)
		var/ore_to_create = src.default_ore
		if (ispath(ore_to_create) && dropOre)
			if (O)
				ore_to_create = O.output
				O.onExcavate(src)
			var/makeores
			for(makeores = src.amount, makeores > 0, makeores--)
				new ore_to_create(src)
		if(!icon_old)
			icon_old = icon_state

		var/new_color = src.stone_color
		src.set_opacity(0)
		src.ReplaceWith(src.replace_type, FALSE)
		src.stone_color = new_color
		src.set_opacity(0)
		src.levelupdate()
		for (var/turf/simulated/wall/auto/asteroid/A in orange(src,1))
			A.UpdateIcon()
		for (var/turf/simulated/floor/plating/airless/asteroid/A in range(src,1))
			A.UpdateIcon()
#ifdef UNDERWATER_MAP
		if (current_state == GAME_STATE_PLAYING)
			hotspot_controller.disturb_turf(src)

		//mbc : fix bug where lighting persists after rock destroyd
		RL_Cleanup() //Cleans up/mostly removes the lighting.
		RL_Init()
		if (RL_Started) RL_UPDATE_LIGHT(src) //Then applies the proper lighting.
#endif

		if(weather)
			src.AddOverlays(weather, "weather")
		if(ambient)
			src.AddOverlays(ambient, "ambient")
		return src

	proc/set_event(var/datum/ore/event/E)
		if (!istype(E))
			return
		src.event = E
		E.onGenerate(src)
		if (E.prevent_excavation)
			src.invincible = 1
		if (E.nearby_tile_distribution_min > 0 && E.nearby_tile_distribution_max > 0)
			var/distributions = rand(E.nearby_tile_distribution_min,E.nearby_tile_distribution_max)
			var/list/usable_turfs = list()
			for (var/turf/simulated/wall/auto/asteroid/AST in range(E.distribution_range,src))
				if (!isnull(AST.event))
					continue
				usable_turfs += AST

			var/turf/simulated/wall/auto/asteroid/AST
			while (distributions > 0)
				distributions--
				if (length(usable_turfs) < 1)
					break
				AST = pick(usable_turfs)
				AST.event = E
				E.onGenerate(AST)
				usable_turfs -= AST


/turf/unsimulated/floor/plating/asteroid
	name = "asteroid"
	icon = 'icons/turf/walls/asteroid.dmi'
	icon_state = "astfloor1"
	plane = PLANE_FLOOR //Try to get the edge overlays to work with shadowing. I dare ya.
	oxygen = 0
	nitrogen = 0
	temperature = TCMB
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	default_material = null
	var/sprite_variation = 1
	var/stone_color = "#D1E6FF"
	var/image/coloration_overlay = null
	var/list/space_overlays = null
	turf_flags = MOB_SLIP | MOB_STEP | FLUID_MOVE
	can_build = TRUE

#ifdef UNDERWATER_MAP
	fullbright = 0
	luminosity = 3
#else
	luminosity = 1
#endif

	New()
		..()
		src.space_overlays = list()
		src.name = initial(src.name)
		src.sprite_variation = rand(1,3)
		icon_state = "astfloor" + "[sprite_variation]"
		coloration_overlay = image(src.icon,"color_overlay")
		coloration_overlay.blend_mode = 4
		UpdateIcon()
		if(current_state > GAME_STATE_PREGAME)
			SPAWN(1)
				if(istype(src, /turf/unsimulated/floor/plating/asteroid))
					space_overlays()
		else
			worldgenCandidates += src

	generate_worldgen()
		. = ..()
		src.space_overlays()

	ex_act(severity)
		return

	proc/destroy_asteroid()
		return

	proc/damage_asteroid(var/power)
		return

	proc/weaken_asteroid()
		return

	update_icon()
		. = ..()

		var/image/ambient_light = src.GetOverlayImage("ambient")
		var/image/weather = src.GetOverlayImage("weather")

		src.ClearAllOverlays()
		src.color = src.stone_color
		#ifndef UNDERWATER_MAP
		if (fullbright)
			src.AddOverlays(new /image/fullbright, "fullbright")
		#endif

		if(length(overlays) != length(overlay_refs)) //hack until #5872 is resolved
			overlay_refs.len = 0
		src.UpdateOverlays(ambient_light, "ambient")
		src.UpdateOverlays(weather, "weather")

	proc/space_overlays() //For overlays ON THE SPACE TILE
		for (var/turf/A in orange(src,1))
			var/dir_from = get_dir(A, src)
			var/dir_to = get_dir(src, A)
			var/skip_this = !istype(A, /turf/space)
			if (!skip_this && !is_cardinal(dir_to))
				for (var/cardinal_dir in cardinal)
					if (dir_to & cardinal_dir)
						var/turf/T = get_step(src, cardinal_dir)
						if (!istype(T, /turf/space))
							skip_this = TRUE
							break
			if (skip_this)
				A.ClearSpecificOverlays("ast_edge_[dir_from]")
				continue
			var/image/edge_overlay = image('icons/turf/walls/asteroid.dmi', "edge[dir_from]")
			edge_overlay.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR | RESET_ALPHA
			edge_overlay.plane = PLANE_FLOOR
			edge_overlay.layer = TURF_EFFECTS_LAYER
			edge_overlay.color = src.stone_color
			A.AddOverlays(edge_overlay, "ast_edge_[dir_from]")
			src.space_overlays += edge_overlay

	Del()
		for(var/turf/T in orange(src, 1))
			T.ClearSpecificOverlays("ast_edge_[get_dir(T, src)]")
		..()


TYPEINFO(/turf/simulated/floor/plating/airless/asteroid)
	mat_appearances_to_ignore = list("rock")
/turf/simulated/floor/plating/airless/asteroid
	name = "asteroid"
	icon = 'icons/turf/walls/asteroid.dmi'
	icon_state = "astfloor1"
	plane = PLANE_FLOOR //Try to get the edge overlays to work with shadowing. I dare ya.
	oxygen = 0
	nitrogen = 0
	temperature = TCMB
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	default_material = null
	var/sprite_variation = 1
	var/stone_color = "#D1E6FF"
	var/image/coloration_overlay = null
	var/list/space_overlays = null
	turf_flags = MOB_SLIP | MOB_STEP | IS_TYPE_SIMULATED | FLUID_MOVE

#ifdef UNDERWATER_MAP
	fullbright = 0
	luminosity = 3
#else
	luminosity = 1
#endif

	dark
		fullbright = 0
		luminosity = 0

	lighted
		fullbright = 1

	noborders
		update_icon()

			return
		space_overlays()
			return

	New()
		..()
		src.space_overlays = list()
		src.name = initial(src.name)
		src.sprite_variation = rand(1,3)
		icon_state = "astfloor" + "[sprite_variation]"
		coloration_overlay = image(src.icon,"color_overlay")
		coloration_overlay.blend_mode = 4
		UpdateIcon()
		if(current_state > GAME_STATE_PREGAME)
			SPAWN(1)
				if(istype(src, /turf/simulated/floor/plating/airless/asteroid))
					space_overlays()
		else
			worldgenCandidates += src

	generate_worldgen()
		. = ..()
		src.space_overlays()

	ex_act(severity)
		return

	proc/destroy_asteroid()
		return

	proc/damage_asteroid(var/power)
		return

	proc/weaken_asteroid()
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tile/))
			var/obj/item/tile/tile = W
			tile.build(src)

	update_icon()
		. = ..()

		var/image/ambient_light = src.GetOverlayImage("ambient")
		var/image/weather = src.GetOverlayImage("weather")

		src.ClearAllOverlays()
		src.color = src.stone_color
		#ifndef UNDERWATER_MAP
		if (fullbright)
			src.AddOverlays(new /image/fullbright, "fullbright")
		#endif

		if(length(overlays) != length(overlay_refs)) //hack until #5872 is resolved
			overlay_refs.len = 0
		src.UpdateOverlays(ambient_light, "ambient")
		src.UpdateOverlays(weather, "weather")

	proc/space_overlays() //For overlays ON THE SPACE TILE
		for (var/turf/A in orange(src,1))
			var/dir_from = get_dir(A, src)
			var/dir_to = get_dir(src, A)
			var/skip_this = !istype(A, /turf/space)
			if (!skip_this && !is_cardinal(dir_to))
				for (var/cardinal_dir in cardinal)
					if (dir_to & cardinal_dir)
						var/turf/T = get_step(src, cardinal_dir)
						if (!istype(T, /turf/space))
							skip_this = TRUE
							break
			if (skip_this)
				A.ClearSpecificOverlays("ast_edge_[dir_from]")
				continue
			var/image/edge_overlay = image('icons/turf/walls/asteroid.dmi', "edge[dir_from]")
			edge_overlay.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR | RESET_ALPHA
			edge_overlay.plane = PLANE_FLOOR
			edge_overlay.layer = TURF_EFFECTS_LAYER
			edge_overlay.color = src.stone_color
			A.AddOverlays(edge_overlay, "ast_edge_[dir_from]")
			src.space_overlays += edge_overlay

	Del()
		for(var/turf/T in orange(src, 1))
			T.ClearSpecificOverlays("ast_edge_[get_dir(T, src)]")
		..()


/turf/simulated/floor/plating/airless/asteroid/jean
	name = "jasteroid"
	desc = "A free-floating jineral jeposit from space."
	stone_color = "#88c2ff"

/turf/simulated/floor/plating/airless/asteroid/comet
	name = "regolith"
	desc = "It's dusty and cold."
	stone_color = "#7d93ad"
	color = "#7d93ad"

	ice
		name = "comet ice"
		stone_color = "#a8cdfa"
		color = "#a8cdfa"

	ice_dense
		name = "dense ice"
		desc = "A compressed layer of comet ice."
		stone_color = "#2070CC"
		color = "#2070CC"

	ice_char
		name = "dark regolith"
		desc = "An inky-black assortment of carbon-rich dust and ice."
		stone_color = "#111111"
		color = "#111111"

	glassy
		name = "blasted regolith"
		desc = "This stuff has been blasted and fused by stellar radiation and impacts."
		stone_color = "#111111"
		color = "#111111"

	copper
		name = "metallic rock"
		desc = "Rich in soft metals."
		stone_color = "#553333"
		color = "#553333"

	iron
		name = "ferrous rock"
		desc = "Dense metallic rock."
		stone_color = "#333333"
		color = "#333333"

	plasma
		name = "plasma ice"
		desc = "Concentrated plasma trapped in dense ice."

	radioactive
		name = "radioactive metal"
		desc = "There's a hazardous amount of radioactive material in this metallic layer."
		stone_color = "#114444"
		color = "#114444"


// Tool Defines

/obj/item/mining_tool
	name = "pickaxe"
	desc = "A thing to bash rocks with until they become smaller rocks."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "pickaxe"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "pick"
	health = 8
	w_class = W_CLASS_NORMAL
	c_flags = ONBELT
	force = 7
	VAR_PROTECTED/dig_strength = 1
	VAR_PROTECTED/weakener = FALSE //does this thing weaken asteroids when you hit them?
	VAR_PROTECTED/sound/mining_sound = 'sound/impact_sounds/Stone_Cut_1.ogg'

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)

	proc/get_dig_strength()
		return src.dig_strength

	proc/get_mining_sound()
		return src.mining_sound

	proc/is_weakener()
		return src.weakener

/obj/item/mining_tool/concussive_gloves_internal
	name = "concussive gloves internal mining tool"
	desc = "you shouldn't see this"
	dig_strength = 3
	mining_sound = 'sound/impact_sounds/Stone_Cut_1.ogg'

/obj/item/mining_tool/powered
	name = "power pick"
	desc = "An energised mining tool."
	icon_state = "powerpick"
	item_state = "ppick0"
	var/powered_item_state = "ppick1"
	VAR_PROTECTED/sound/powered_mining_sound = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
	force = 7
	var/default_cell = /obj/item/ammo/power_cell
	var/is_on = FALSE
	var/powered_force = 13
	VAR_PROTECTED/powered_dig_strength = 2
	VAR_PROTECTED/powered_weakener = FALSE //does this become able to weaken asteroids when it's on?
	VAR_PROTECTED/power_usage = 2 //power units expended per hit while on
	VAR_PROTECTED/robot_power_usage = 50 //power units expended when drawing from a robot's internal power cell, which tends to be 150x bigger
	var/violence_power_multiplier = 5 //multiply the cost by this if the thing we're hitting isnt a turf
	var/image/powered_overlay = null //the glowy bits for when its on
	var/datum/item_special/unpowered_item_special = /datum/item_special/simple
	var/datum/item_special/powered_item_special = /datum/item_special/simple

	New()
		..()
		if(src.default_cell)
			AddComponent(/datum/component/cell_holder, new default_cell)
			RegisterSignal(src, COMSIG_CELL_SWAP, PROC_REF(power_down_callback))
		src.setItemSpecial(unpowered_item_special)
		src.power_up()

	proc/get_power_usage(mob/user = null)
		if(user && isrobot(user))
			return src.robot_power_usage
		return src.power_usage

	get_dig_strength()
		if(src.is_on)
			return src.powered_dig_strength
		return ..()

	is_weakener()
		if(src.is_on)
			return src.powered_weakener
		return ..()

	get_mining_sound()
		if(src.is_on)
			return src.powered_mining_sound
		return ..()

	// Seems like a basic bit of user feedback to me (Convair880).
	examine(mob/user)
		. = ..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			. += "The [src] is turned [src.is_on ? "on" : "off"]. There are [ret["charge"]]/[ret["max_charge"]] PUs left!"

	attack_self(mob/user)
		..()
		src.mode_toggle(user)

	afterattack(atom/target, mob/user)
		..()
		if (src.is_on) //is the thing on? (or for the hedron beam, is it in mining mods)
			if(isturf(target))
				src.process_charges(src.get_power_usage(), user)
			else
				src.process_charges(src.get_power_usage() * src.violence_power_multiplier, user)

	proc/process_charges(var/powerCost, var/mob/user = null)
		//Returns FALSE if we failed to use power, otherwise returns TRUE
		if (!isnum(powerCost) || powerCost < 0)
			//We need a positive number
			return FALSE
		if(isrobot(user))
			//You are a robot, expend power from your internal cell
			var/mob/living/silicon/robot/robotUser = user
			if (robotUser.cell.charge > powerCost)
				robotUser.cell.use(powerCost)
				return TRUE
			//Not enough power
			src.power_down(user)
			OVERRIDE_COOLDOWN(src, "depowered", 8 SECONDS)
			boutput(user, SPAN_ALERT("Your charge is too low to power [src] and it shuts down!"))
			return FALSE
		//You passed the captcha, continue to use small cell power
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			//Cell needs to exist
			return FALSE
		if (SEND_SIGNAL(src, COMSIG_CELL_USE, powerCost) & CELL_INSUFFICIENT_CHARGE)
			//You just used power, continue down this branch if you ran out of power
			src.power_down(user)
			OVERRIDE_COOLDOWN(src, "depowered", 8 SECONDS)
			boutput(user, SPAN_ALERT("[src] runs out of charge and shuts down!"))
		return TRUE

	proc/mode_toggle(var/mob/user = null)
		if (src.process_charges(0, user))
			if(GET_COOLDOWN(src, "depowered"))
				boutput(user, SPAN_ALERT("[src] was recently power cycled and is still cooling down!"))
				return
			if (!src.is_on)
				boutput(user, SPAN_NOTICE("You power up [src]."))
				src.power_up(user)
			else
				boutput(user, SPAN_NOTICE("You power down [src]."))
				src.power_down(user)
		else
			boutput(user, SPAN_ALERT("No charge left in [src]."))

	proc/power_up(var/mob/user = null)
		src.tooltip_rebuild = TRUE
		src.is_on = TRUE
		src.force = src.powered_force
		src.item_state = src.powered_item_state
		if (src.powered_overlay)
			src.overlays.Add(powered_overlay)
			signal_event("icon_updated")
		if(user)
			user.update_inhands()
		playsound(user, 'sound/items/miningtool_on.ogg', 30, 1)
		src.setItemSpecial(src.powered_item_special)
		return

	proc/power_down_callback(obj/item/mining_tool/powered/tool, obj/item/ammo/power_cell/cell, mob/user)
		src.power_down(user)

	proc/power_down(var/mob/user = null)
		ON_COOLDOWN(src, "depowered", 1 SECOND)
		src.tooltip_rebuild = TRUE
		src.is_on = FALSE
		src.force = initial(src.force)
		src.item_state = initial(src.item_state)
		if (src.powered_overlay)
			src.overlays.Remove(powered_overlay)
			signal_event("icon_updated")
		if(user)
			user.update_inhands()
		playsound(user, 'sound/items/miningtool_off.ogg', 30, 1)
		src.setItemSpecial(src.unpowered_item_special)
		return

/obj/item/mining_tool/powered/pickaxe
	name = "energy pickaxe"
	desc = "An energised mining tool."
	icon_state = "powerpick"
	item_state = "ppick0"
	powered_item_state = "ppick1"
	powered_mining_sound = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
	c_flags = ONBELT
	force = 7
	powered_force = 14
	dig_strength = 2
	powered_dig_strength = 3
	power_usage = 2
	robot_power_usage = 50
	default_cell = /obj/item/ammo/power_cell
	powered_overlay = null

	New()
		src.powered_overlay = image('icons/obj/items/mining.dmi', "pp-glow")
		..()

/obj/item/mining_tool/powered/drill
	name = "energy drill"
	desc = "An energized mining tool that's more energy efficient than a pickaxe."
	icon_state = "powerdrill"
	item_state = "pdrill0"
	powered_item_state = "pdrill1"
	powered_mining_sound = 'sound/items/Welder.ogg'
	c_flags = ONBELT
	force = 7
	powered_force = 14
	dig_strength = 2
	powered_dig_strength = 3
	power_usage = 1
	robot_power_usage = 30
	default_cell = /obj/item/ammo/power_cell

	New()
		src.powered_overlay = image('icons/obj/items/mining.dmi', "pd-glow")
		..()

/obj/item/mining_tool/powered/hammer
	name = "energy hammer"
	desc = "An energised mining tool that's a bit more powerful than a pickaxe."
	icon_state = "powerhammer"
	item_state = "phammer0"
	powered_item_state = "phammer1"
	powered_mining_sound = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
	c_flags = ONBELT
	force = 9
	powered_force = 20
	dig_strength = 2
	powered_dig_strength = 3
	powered_weakener = TRUE
	power_usage = 3
	robot_power_usage = 75
	default_cell = /obj/item/ammo/power_cell
	powered_item_special = /datum/item_special/slam

	New()
		src.powered_overlay = image('icons/obj/items/mining.dmi', "ph-glow")
		..()

/obj/item/mining_tool/powered/shovel
	name = "power shovel"
	desc = "An energized mining tool that can be used to dig holes in the sand."
	icon_state = "powershovel"
	item_state = "pshovel0"
	powered_item_state = "pshovel1"
	powered_mining_sound = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
	c_flags = ONBELT
	force = 6
	powered_force = 12
	dig_strength = 0
	powered_dig_strength = 2
	power_usage = 2
	robot_power_usage = 50
	default_cell = /obj/item/ammo/power_cell
	powered_item_special = /datum/item_special/swipe

	New()
		powered_overlay = image('icons/obj/items/mining.dmi', "ps-glow")
		..()

TYPEINFO(/obj/item/mining_tool/powered/hedron_beam)
	mats = list("metal_dense" = 15,
				"conductive" = 8,
				"claretine" = 10,
				"koshmarite" = 2)
/obj/item/mining_tool/powered/hedron_beam
	//Being "On" (ie src.is_on() == TRUE) means it's in mining mode)
	name = "\improper Hedron beam device"
	desc = "A prototype multifunctional industrial tool capable of rapidly switching between welding and mining modes."
	icon_state = "hedron-W"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	item_state = "gun"
	powered_item_state = "gun"
	powered_mining_sound = 'sound/items/Welder.ogg'
	c_flags = ONBELT
	tool_flags = TOOL_WELDING
	force = 10
	dig_strength = 0
	powered_dig_strength = 3
	power_usage = 2
	robot_power_usage = 50
	default_cell = /obj/item/ammo/power_cell

	examine(mob/user)
		. = ..()
		. += "<br>Currently in [src.is_on ? "mining mode" : "welding mode"]."

	power_up(var/mob/user)
		src.set_icon_state("hedron-M")
		flick("hedron-WtoM", src)
		..()

	power_down(var/mob/user)
		src.set_icon_state("hedron-W")
		flick("hedron-MtoW", src)
		..()

	proc/try_weld(mob/user, var/fuel_amt = 2, var/use_amt = -1, var/noisy=TRUE, var/burn_eyes=FALSE)
	//All welding tools just copy and paste this proc? Horrible, but out of scope so it can be some other handsome coder's problem.
		if (!src.is_on) //are we in welding mode?
			if(use_amt == -1)
				use_amt = fuel_amt
			if (!src.process_charges(use_amt * src.violence_power_multiplier, user))
				boutput(user, SPAN_NOTICE("Cannot weld - cell insufficiently charged."))
				return FALSE //not enough power
			if(noisy)
				playsound(user.loc, list('sound/items/Welder.ogg', 'sound/items/Welder2.ogg')[noisy], 35, 1)
			return TRUE //welding checks passed
		//not in welding mode, dont weld
		boutput(user, SPAN_NOTICE("[src] is in mining mode and can't currently weld."))
		return FALSE

/obj/item/clothing/gloves/concussive
	name = "concussive gauntlets"
	desc = "These gloves enable miners to punch through solid rock with their hands instead of using tools."
	icon_state = "cgaunts"
	item_state = "bgloves"
	material_prints = "industrial-grade mineral fibers"
	fingertip_color = "#535353"
	var/obj/item/mining_tool/tool = new /obj/item/mining_tool/concussive_gloves_internal

	setupProperties()
		..()
		setProperty("conductivity", 0.6)

	New()
		..()
		AddComponent(/datum/component/wearertargeting/unarmedblock/concussive, list(SLOT_GLOVES))

/obj/item/breaching_charge/mining
	name = "concussive charge"
	desc = "It is set to detonate in 5 seconds."
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	w_class = W_CLASS_TINY
	var/emagged = 0
	var/hacked = 0
	expl_devas = 0
	expl_heavy = 1
	expl_light = 2
	expl_flash = 4

	light
		name = "low-yield concussive charge"
		desc = "It is set to detonate in 5 seconds."
		expl_devas = 0
		expl_heavy = 0
		expl_light = 1
		expl_flash = 2

	light/hacked
		hacked = 1
		desc = "It is set to detonate in 5 seconds. The safety light is off."

	hacked
		hacked = 1
		desc = "It is set to detonate in 5 seconds. The safety light is off."

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (user.equipped() == src)
			if (!src.armed)
				if (!src.check_placeable_target(target))
					return
				if(user.bioHolder.HasEffect("clumsy") || src.emagged)
					if(src.emagged)
						user.visible_message("<b>CLICK</b>")
						boutput(user, SPAN_ALERT("The timing mechanism malfunctions!"))
					else
						boutput(user, SPAN_ALERT("Huh? How does this thing work?!"))
					logTheThing(LOG_COMBAT, user, "accidentally triggers [src] (clumsy bioeffect) at [log_loc(user)].")
					SPAWN(0.5 SECONDS)
						concussive_blast()
						qdel (src)
						return
				else
					if (\
						(\
							istype(target, /turf/simulated/wall/auto/asteroid/) ||\
							istype(target, /obj/geode)\
						) && !src.hacked)
						boutput(user, SPAN_ALERT("You slap the charge on [target], [det_time/10] seconds!"))
						user.visible_message(SPAN_ALERT("[user] has attached [src] to [target]."))
						src.icon_state = "bcharge2"

						// Yes, please (Convair880).
						if (src?.hacked)
							logTheThing(LOG_COMBAT, user, "attaches a hacked [src] to [target] at [log_loc(target)].")

						user.set_dir(get_dir(user, target))
						user.drop_item()
						var/turf/T = get_turf(target)
						src.set_loc(T)
						src.anchored = ANCHORED
						step_towards(src, T)

						SPAWN( src.det_time )
							concussive_blast()
							if(target)
								if(istype(target,/obj/machinery))
									qdel(target)
							qdel(src)
							return
					else if (src.hacked)
						var/turf/T = get_turf(target)
						if(!IS_ARRIVALS(T.loc))
							..()
					else boutput(user, SPAN_ALERT("These will only work on asteroids."))
			return

	emag_act(var/mob/user, var/obj/item/card/emag/E)

		if(!src.emagged && !src.hacked)
			if (user)
				boutput(user, SPAN_NOTICE("You short out the timing mechanism!"))

			src.desc += " It has been tampered with."
			src.emagged = 1
			return 1
		else
			if (user)
				boutput(user, SPAN_ALERT("This has already been tampered with."))
			return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			boutput(user, SPAN_NOTICE("You repair the timing mechanism!"))
		src.emagged = 0
		src.desc = null
		src.desc = "It is set to detonate in 5 seconds."
		return 1

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/chargehacker))
			if(!src.emagged && !src.hacked)
				boutput(user, SPAN_NOTICE("You short out the attachment mechanism, removing its restrictions!"))
				src.desc += " It has been tampered with."
				src.hacked = 1
			else
				boutput(user, SPAN_ALERT("This has already been tampered with."))
		else ..()

	proc/concussive_blast()
		playsound(src.loc, 'sound/weapons/flashbang.ogg', 50, 1)
		for (var/turf/simulated/wall/auto/asteroid/A in range(src.expl_flash,src))
			if(GET_DIST(src,A) <= src.expl_heavy)
				A.damage_asteroid(4)
			if(GET_DIST(src,A) <= src.expl_light)
				A.damage_asteroid(3)
			if(GET_DIST(src,A) <= src.expl_flash)
				A.damage_asteroid(2)

		for(var/mob/living/carbon/C in range(src.expl_flash, src))
			if (!isdead(C) && C.client) shake_camera(C, 3, 2)
			if(GET_DIST(src,C) <= src.expl_light)
				C.changeStatus("stunned", 8 SECONDS)
				C.changeStatus("knockdown", 10 SECONDS)
				C.stuttering += 15
				boutput(C, SPAN_ALERT("The concussive blast knocks you off your feet!"))
			if(GET_DIST(src,C) <= src.expl_heavy)
				C.TakeDamage("All",rand(15,25)*(1-C.get_explosion_resistance()),0)
				boutput(C, SPAN_ALERT("You are battered by the concussive shockwave!"))

		for (var/obj/geode/geode in get_turf(src))
			geode.ex_act(2, null, 5 * src.expl_heavy)

/// Multiplier for power usage if the user is a silicon and the charge is coming from their internal cell
#define SILICON_POWER_COST_MOD 10

TYPEINFO(/obj/item/cargotele)
	mats = 4

/obj/item/cargotele
	name = "cargo transporter"
	desc = "A device for teleporting crated goods."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "cargotele"
	/// Power cost per teleport
	var/cost = 25
	/// Length of action bar before teleport completes
	var/teleport_delay = 3 SECONDS
	/// Target pad we send cargo to. Make sure you're sending to the pad's loc and not the pad itself
	var/obj/submachine/cargopad/target = null
	/// Type of cell used in this
	var/cell_type = /obj/item/ammo/power_cell/med_power
	/// List of types that cargo teles are allowed to send. Built in New, shared across all teles
	var/static/list/allowed_types = list()
	w_class = W_CLASS_SMALL
	flags = TABLEPASS | SUPPRESSATTACK
	c_flags = ONBELT


	New()
		. = ..()
		var/list/allowed_supertypes = list(/obj/machinery/portable_atmospherics/canister, /obj/reagent_dispensers, /obj/storage, /obj/geode)
		for (var/supertype in allowed_supertypes)
			for (var/subtype in typesof(supertype))
				allowed_types[subtype] = 1
		allowed_types -= /obj/storage/closet/flock

		var/cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, swappable = FALSE)
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CARGO_PAD_DISABLED, PROC_REF(maybe_reset_target)) //make sure cargo pads can GC

	proc/maybe_reset_target(datum/dummy, var/obj/submachine/cargopad/pad)
		if (target == pad)
			target = null

	examine(mob/user)
		. = ..()
		if(target)
			. += "It's currently set to [src.target]."
		else
			. += "No destination has been selected."
		if (isrobot(user))
			. += "Each use of the cargo teleporter will consume [cost * SILICON_POWER_COST_MOD]PU."
		else
			var/list/ret = list()
			if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST))
				. += SPAN_ALERT("No power cell installed.")
			else
				. += "There are [ret["charge"]]/[ret["max_charge"]] PUs left! Each use will consume [cost]PU."

	attack_self(mob/user) // Fixed --melon
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(user, SPAN_ALERT("The transporter is out of charge."))
			return
		if (!length(global.cargo_pad_manager.pads))
			boutput(user, SPAN_ALERT("No receivers available."))
		else
			var/mob/holder = src.loc
			var/selection = tgui_input_list(user, "Select Cargo Pad Location:", "Cargo Pads", global.cargo_pad_manager.pads, 15 SECONDS)
			if (src.loc != holder || !selection)
				return
			boutput(user, "Target set to [get_area(selection)].")
			//blammo! works!
			src.target = selection

	afterattack(var/obj/O, mob/user)
		if (!istype(O))
			return ..()
		if (O.artifact || src.allowed_types[O.type])
			if (O.anchored)
				boutput(user, SPAN_ALERT("You can't teleport [O] while it is anchored!"))
				return
			src.try_teleport(O, user)

	proc/can_teleport(var/obj/cargo, var/mob/user)
		if (!src.target)
			boutput(user, SPAN_ALERT("You need to set a target first!"))
			return FALSE
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(user, SPAN_ALERT("The transporter is out of charge."))
			return FALSE
		if (isrobot(user))
			var/mob/living/silicon/robot/R = user
			if (R.cell.charge < src.cost * SILICON_POWER_COST_MOD)
				boutput(user, SPAN_ALERT("There is not enough charge left in your cell to use this."))
				return FALSE

		return TRUE

	proc/try_teleport(var/obj/cargo, var/mob/user)
		// Why didn't you implement checks for these in the first place, sigh (Convair880).
		if (cargo.loc == user && issilicon(user))
			user.show_text("The [cargo.name] is securely bolted to your chassis.", "red")
			return FALSE

		if (!src.can_teleport(cargo, user))
			return FALSE

		boutput(user, SPAN_NOTICE("Teleporting [cargo] to [src.target]..."))
		playsound(user.loc, 'sound/machines/click.ogg', 50, 1)
		SETUP_GENERIC_PRIVATE_ACTIONBAR(user, src, src.teleport_delay, PROC_REF(finish_teleport), list(cargo, user), null, null, null, null)
		return TRUE


	proc/finish_teleport(var/obj/cargo, var/mob/user)
		if (ismob(cargo.loc) && cargo.loc == user)
			user.u_equip(cargo)
		if (istype(cargo, /obj/item))
			var/obj/item/I = cargo
			I.stored?.transfer_stored_item(I, get_turf(I), user = user)

		// And logs for good measure (Convair880).
		var/obj/storage/S = cargo
		ENSURE_TYPE(S)
		var/mob_teled = FALSE
		for (var/mob/M in cargo.contents)
			if (M)
				logTheThing(LOG_STATION, user, "uses a cargo transporter to send [cargo.name][S && S.locked ? " (locked)" : ""][S && S.welded ? " (welded)" : ""] with [constructTarget(M,"station")] inside to [log_loc(src.target)].")
				mob_teled = TRUE

		if(!mob_teled)
			logTheThing(LOG_STATION, user, "uses a cargo transporter to send [cargo.name][S && S.locked ? " (locked)" : ""][S && S.welded ? " (welded)" : ""] ([cargo.type]) to [log_loc(src.target)].")

		cargo.set_loc(get_turf(src.target))
		target.receive_cargo(cargo)
		elecflash(src)
		if (isrobot(user))
			var/mob/living/silicon/robot/R = user
			R.cell.charge -= cost * SILICON_POWER_COST_MOD
		else
			var/ret = SEND_SIGNAL(src, COMSIG_CELL_USE, cost)
			if (ret & CELL_INSUFFICIENT_CHARGE)
				boutput(user, SPAN_ALERT("Transfer successful. The transporter is now out of charge."))
			else
				boutput(user, SPAN_NOTICE("Transfer successful."))

#undef SILICON_POWER_COST_MOD

/obj/item/cargotele/efficient
	name = "Hedron cargo transporter"
	desc = "A device for teleporting crated goods. It's modified a bit from the standard design, and boasts improved efficiency and transport speed."
	cost = 20
	teleport_delay = 2 SECONDS
	icon_state = "cargotelegreen"

/obj/item/cargotele/traitor
	cost = 15
	///The account to credit for sales
	var/datum/db_record/account = null
	///The total amount earned from selling/stealing
	var/total_earned = 0

	attack_self() // Fixed --melon
		return

	can_teleport(obj/cargo, mob/user)
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(user, SPAN_ALERT("The transporter is out of charge."))
			return FALSE
		return TRUE

	try_teleport(obj/cargo, mob/user)
		if(..() && istype(cargo, /obj/storage))
			var/obj/storage/store = cargo
			store.weld(TRUE, user)

	finish_teleport(var/obj/cargo, var/mob/user)
		src.target = random_space_turf() || random_nonrestrictedz_turf()
		boutput(user, SPAN_NOTICE("Teleporting [cargo]..."))
		playsound(user.loc, 'sound/machines/click.ogg', 50, 1)
		var/value = shippingmarket.appraise_value(cargo.contents, sell = FALSE)
		// Logs for good measure (Convair880).
		for (var/atom/A in cargo.contents)
			if (ismob(A))
				var/mob/M = A
				logTheThing(LOG_STATION, user, "uses a Syndicate cargo transporter to send [cargo.name] with [constructTarget(M,"station")] inside to [log_loc(src.target)].")
				var/datum/job/job = find_job_in_controller_by_string(M.job)
				value += job?.wages * 5
			else
				cargo.contents -= A
				qdel(A)
		if (length(cargo.contents)) //if there's a mob left inside chuck it somewhere in space
			cargo.set_loc(src.target)
		else
			qdel(cargo)
		src.total_earned += value
		logTheThing(LOG_STATION, user, "uses a Syndicate cargo transporter to sell shit for [value] credits.")
		elecflash(src)
		var/ret = SEND_SIGNAL(src, COMSIG_CELL_USE, cost)
		boutput(user, "[bicon(src)] *beep*")
		if (src.account)
			account?["current_money"] += value
			boutput(user, "[bicon(src)] The [src.name] beeps: transfer successful, [value] credits have been deposited into your bank account. You have [src.account["current_money"]] credits total.")
		else
			boutput(user, "[bicon(src)] The [src.name] beeps: transfer successful, no account registered.")
		if (ret & CELL_INSUFFICIENT_CHARGE)
			boutput(user, SPAN_ALERT("[src] is now out of charge."))

	attackby(obj/item/item, mob/user)
		var/owner_name = null
		if (istype(item, /obj/item/device/pda2))
			var/obj/item/device/pda2/pda = item
			owner_name = pda.registered
		else if (istype(item, /obj/item/clothing/lanyard))
			var/obj/item/clothing/lanyard/lanyard = item
			owner_name = lanyard.registered
		else if (istype(item, /obj/item/card/id))
			var/obj/item/card/id/card = item
			owner_name = card.registered
		if (owner_name)
			boutput(user, SPAN_NOTICE("You set [src]'s payout account."))
			src.account = data_core.bank.find_record("name", owner_name)
			return
		..()

	get_desc()
		. = ..()
		if (src.total_earned)
			. += "<br>There is a little counter on the side, it says: Total amount earned: [src.total_earned] credits.<br>"

/obj/item/oreprospector
	name = "geological scanner"
	desc = "A device capable of detecting nearby mineral deposits."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "minanal"
	c_flags = ONBELT
	w_class = W_CLASS_TINY

	attack_self(var/mob/user as mob)
		mining_scan(get_turf(user), user, 6)

	afterattack(obj/geode/geode, mob/user, reach, params)
		if (!istype(geode))
			return ..()
		var/text = "----------------------------------<br>"
		text += "<B><U>Geological Report:</U></B><br>"
		text += "<b>Structural composition: [istype(geode, /obj/geode/fluid) ? "liquid" : "hollow"]</b><br>"
		text += "<b>Explosive resistance estimate:</b> [geode.break_power] Kiloblasts<br>"
		boutput(user, text)


/proc/mining_scan(var/turf/T, var/mob/living/L, var/range)
	if (!istype(T) || !istype(L))
		return
	if (!isnum(range) || range < 1)
		range = 6
	var/stone = 0
	var/anomaly = 0
	var/list/ores_found = list()
	var/datum/ore/O
	var/datum/ore/event/E
	for (var/turf/simulated/wall/auto/asteroid/AST in range(T,range))
		//clear out any scanning images if there are any
		var/datum/client_image_group/cig = get_image_group(T)
		for(var/image/i in cig.images)
			cig.remove_image(i)
		stone++
		O = AST.ore
		E = AST.event
		if (O && !(O.name in ores_found))
			ores_found += O.name
		if (E)
			anomaly++
			if (E.scan_decal)
				mining_scandecal(L, AST, E.scan_decal)
	var/found_string = ""
	if (length(ores_found) > 0)
		var/list_counter = 1
		for (var/X in ores_found)
			found_string += X
			if (list_counter != ores_found.len)
				found_string += " * "
			list_counter++
	else
		found_string = "None"

	var/rendered = "----------------------------------<br>"
	rendered += "<B><U>Geological Report:</U></B><br>"
	rendered += "<b>Scan Range:</b> [range] meters<br>"
	rendered += "<b>M^2 of Mineral in Range:</b> [stone]<br>"
	rendered += "<b>Ores Found:</b> [found_string]<br>"
	rendered += "<b>Anomalous Readings:</b> [anomaly]<br>"
	rendered += "----------------------------------"
	boutput(L, rendered)

/proc/mining_scandecal(var/mob/living/user, var/turf/T, var/decalicon)
	if(!user || !T || !decalicon) return
	var/image/O = image('icons/obj/items/mining.dmi',T,decalicon,ASTEROID_MINING_SCAN_DECAL_LAYER)
	var/datum/client_image_group/cig = get_image_group(T)
	cig.add_mob(user) //we can add this multiple times so if the user refreshes the scan, it times properly and uses the sub count to handle remove
	cig.add_image(O)

	SPAWN(2 MINUTES)
		cig.remove_mob(user)

///// MINER TRAITOR ITEM /////

/obj/item/device/chargehacker
	name = "geological scanner"
	desc = "The scanner doesn't look right somehow."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "minanal"
	c_flags = ONBELT
	w_class = W_CLASS_TINY

	attack_self(var/mob/user as mob)
		boutput(user, "The screen is clearly painted on. When you press Scan, a short metal spike extends from the top and sparks brightly before retracting again.")

/obj/machinery/oreaccumulator
	name = "mineral accumulator"
	desc = "A powerful device for quick ore and salvage collection and movement."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "accumulator-off"
	density = 1
	opacity = 0
	anchored = UNANCHORED
	var/active = FALSE
	var/obj/item/cell/cell = null
	var/target = null
	var/group = null
	var/image/hatch_image = null //no connected magnet = hatch closed cuz it won't take ore in
	var/image/powercell_image = null

	New()
		var/obj/item/cell/P = new/obj/item/cell(src)
		P.charge = P.maxcharge
		src.cell = P
		UpdateIcon()
		..()

	update_icon()
		if (!src.powercell_image)
			src.powercell_image = image(src.icon)
			src.powercell_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
			src.powercell_image.icon_state = "accumulator_cell_missing"
		if (!src.hatch_image)
			src.hatch_image = image(src.icon)
			src.hatch_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
			src.hatch_image.icon_state = "accumulator_closed"

		if(!src.cell)
			src.UpdateOverlays(src.powercell_image, "powercell")
		else
			src.UpdateOverlays(null, "powercell")

		if(!target)
			src.UpdateOverlays(src.hatch_image, "hatch")
		else
			src.UpdateOverlays(null, "hatch")

		if(active)
			icon_state = "accumulator-on"
		else
			icon_state = "accumulator-off"


	attack_hand(var/mob/user)
		if (!src.cell) boutput(user, SPAN_ALERT("It won't work without a power cell!"))
		else
			var/action = tgui_input_list(user, "What do you want to do?", "Mineral Accumulator", list("Flip the power switch","Change the destination","Remove the power cell"))
			if (action == "Remove the power cell")
				var/obj/item/cell/PCEL = src.cell
				boutput(user, "You remove [cell].")
				if (PCEL) //ZeWaka: fix for null.updateicon
					PCEL.UpdateIcon()
				user.put_in_hand_or_drop(PCEL)
				src.cell = null
			else if (action == "Change the destination")
				src.change_dest(user)
			else if (action == "Flip the power switch")
				if (!src.active)
					user.visible_message("[user] powers up [src].", "You power up [src].")
					src.active = TRUE
					src.anchored = ANCHORED
				else
					user.visible_message("[user] shuts down [src].", "You shut down [src].")
					src.active = FALSE
					src.anchored = UNANCHORED
			else
				user.visible_message("[user] stares at [src] in confusion!", "You're not sure what that did.")
			UpdateIcon()

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/cell/))
			if (src.cell) boutput(user, SPAN_ALERT("It already has a power cell inserted!"))
			else
				user.drop_item()
				W.set_loc(src)
				cell = W
				user.visible_message("[user] inserts [W] into [src].", "You insert [W] into [src].")
		else ..()
		UpdateIcon()

	process()
		var/moved = 0
		if (src.active)
			if (!src.cell)
				src.visible_message(SPAN_ALERT("[src] instantly shuts itself down."))
				src.active = FALSE
				src.anchored = UNANCHORED
				UpdateIcon()
				return
			var/obj/item/cell/PCEL = src.cell
			if (PCEL.charge <= 0)
				src.visible_message(SPAN_ALERT("[src] runs out of power and shuts down."))
				src.active = FALSE
				src.anchored = UNANCHORED
				UpdateIcon()
				return
			PCEL.use(5)
			if (src.target)
				for(var/obj/item/raw_material/O in orange(1,src))
					if (istype(O,/obj/item/raw_material/rock)) continue
					PCEL.use(2)
					O.set_loc(src.target)
				for(var/obj/item/scrap/S in orange(1,src))
					PCEL.use(2)
					S.set_loc(src.target)
				for(var/obj/decal/cleanable/machine_debris/D in orange(1,src))
					PCEL.use(2)
					D.set_loc(src.target)
				for(var/obj/decal/cleanable/robot_debris/R in orange(1,src))
					PCEL.use(2)
					R.set_loc(src.target)
			for(var/obj/item/raw_material/O in range(6,src))
				if (moved >= 10)
					break
				if (istype(O,/obj/item/raw_material/rock)) continue
				step_towards(O, src.loc)
				moved++
			for(var/obj/item/scrap/S in range(6,src))
				if (moved >= 10)
					break
				step_towards(S, src.loc)
				moved++
			for(var/obj/decal/cleanable/machine_debris/D in range(6,src))
				if (moved >= 10)
					break
				step_towards(D, src.loc)
				moved++
			for(var/obj/decal/cleanable/robot_debris/R in range(6, src))
				if (moved >= 10)
					break
				step_towards(R, src.loc)
				moved++

	proc/change_dest(mob/user as mob)
		if (!length(cargo_pad_manager.pads))
			boutput(user, SPAN_ALERT("No receivers available."))
		else
			var/list/L
			if (src.group)
				L = list()
				for (var/obj/submachine/cargopad/C in global.cargo_pad_manager.pads)
					if (C.group == src.group)
						L += C
			else
				L = global.cargo_pad_manager.pads
			var/selection = tgui_input_list(user, "Select target output:", "Cargo Pads", L)
			if(!selection)
				return
			var/turf/T = get_turf(selection)
			if (!T)
				boutput(user, SPAN_ALERT("Target not set!"))
				return
			boutput(user, "Target set to [selection] at [T.loc].")
			src.target = T
		UpdateIcon()

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

/// Basically a list wrapper that removes and adds cargo pads to a global list when it receives the respective signals
/datum/cargo_pad_manager
	var/list/pads = list()

	New()
		..()
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CARGO_PAD_ENABLED, PROC_REF(add_pad))
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CARGO_PAD_DISABLED, PROC_REF(remove_pad))

	/// Add a pad to the global pads list. Do nothing if the pad is already in the pads list.
	proc/add_pad(datum/holder, obj/submachine/cargopad/pad)
		if (!istype(pad)) //wuh?
			return
		src.pads |= pad

	/// Remove a pad from the global pads list. Do nothing if the pad is already in the pads list.
	proc/remove_pad(datum/holder, obj/submachine/cargopad/pad)
		if (!istype(pad)) //wuh!
			return
		src.pads -= pad


var/global/datum/cargo_pad_manager/cargo_pad_manager

TYPEINFO(/obj/submachine/cargopad)
	mats = 10 //I don't see the harm in re-adding this. -ZeWaka

/obj/submachine/cargopad
	name = "Cargo Pad"
	desc = "Used to receive objects transported by a cargo transporter."
	icon = 'icons/obj/objects.dmi'
	icon_state = "cargopad"
	anchored = ANCHORED
	plane = PLANE_FLOOR
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	var/active = TRUE
	var/group
	/// The mailgroup to send notifications to
	var/mailgroup = null

	podbay
		name = "Pod Bay Pad"
	hydroponic
		mailgroup = MGD_BOTANY
		name = "Hydroponics Pad"
	robotics
		mailgroup = MGD_MEDRESEACH
		name = "Robotics Pad"
	artlab
		mailgroup = MGD_SCIENCE
		name = "Artifact Lab Pad"
	engineering
		mailgroup = MGO_ENGINEER
		name = "Engineering Pad"
	mechanics
		mailgroup = MGO_ENGINEER
		name = "Mechanics Pad"
	magnet
		mailgroup = MGD_MINING
		name = "Mineral Magnet Pad"
	miningoutpost
		mailgroup = MGD_MINING
		name = "Mining Outpost Pad"
	qm
		mailgroup = MGD_CARGO
		name = "QM Pad"
	qm2
		mailgroup = MGD_CARGO
		name = "QM Pad 2"
	researchoutpost
		mailgroup = MGD_SCIENCE
		name = "Research Outpost Pad"

	New()
		..()
		if (src.name == "Cargo Pad")
			src.name += " ([rand(100,999)])"

		//sadly maps often don't use the subtypes, so we do this instead
		if (!src.mailgroup)
			var/area/area = get_area(src)
			if (istype(area, /area/station/hydroponics) || istype(area, /area/station/storage/hydroponics) || istype(area, /area/station/ranch))
				src.mailgroup = MGD_BOTANY
			else if (istype(area, /area/station/medical))
				src.mailgroup = MGD_MEDRESEACH
			else if (istype(area, /area/station/science) || istype(area, /area/research_outpost))
				src.mailgroup = MGD_SCIENCE
			else if (istype(area, /area/station/engine))
				src.mailgroup = MGO_ENGINEER
			else if (istype(area, /area/station/mining) || istype(area, /area/station/quartermaster/refinery) || istype(area, /area/mining))
				src.mailgroup = MGD_MINING
			else if (istype(area, /area/station/quartermaster))
				src.mailgroup = MGD_CARGO

		if (src.active) //in case of map edits etc
			AddOverlays(image('icons/obj/objects.dmi', "cpad-rec"), "lights")
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_ENABLED, src)

	disposing()
		SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_DISABLED, src)
		..()

	was_deconstructed_to_frame(mob/user)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_DISABLED, src)
		..()

	was_built_from_frame(mob/user, newly_built)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_ENABLED, src)
		..()

	attack_hand(var/mob/user)
		toggle(user)

	attack_ai(mob/user)
		. = ..()
		toggle(user)

	proc/toggle(mob/user)
		if (src.active == 1)
			boutput(user, SPAN_NOTICE("You switch the receiver off."))
			ClearSpecificOverlays("lights")
			src.active = FALSE
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_DISABLED, src)
		else
			boutput(user, SPAN_NOTICE("You switch the receiver on."))
			AddOverlays(image('icons/obj/objects.dmi', "cpad-rec"), "lights")
			src.active = TRUE
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_ENABLED, src)

	proc/receive_cargo(var/obj/cargo)
		if (!src.mailgroup)
			return
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(src.mailgroup), "sender"="00000000", "message"="Notification: Incoming delivery to [src.name].")
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)

// satchels -> obj/item/satchel.dm

TYPEINFO(/obj/item/ore_scoop)
	mats = 6

/obj/item/ore_scoop
	name = "ore scoop"
	desc = "A device that sucks up ore into a satchel automatically. Just load in a satchel and walk over ore to scoop it up."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "scoop"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "buildpipe"
	w_class = W_CLASS_SMALL
	var/obj/item/satchel/mining/satchel = null
	///Does this scoop pick up rock, ice etc.
	var/collect_junk = FALSE

	prepared
		New()
			..()
			var/obj/item/satchel/mining/S = new /obj/item/satchel/mining(src)
			satchel = S
			icon_state = "scoop-bag"

	borg
		New()
			..()
			var/obj/item/satchel/mining/large/S = new /obj/item/satchel/mining/large(src)
			satchel = S

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/satchel/mining/))
			if (!issilicon(user))
				var/obj/item/satchel/mining/S = W
				user.drop_item()
				var/obj/item/satchel/mining/old_satchel = src.satchel
				if (old_satchel)
					old_satchel.set_loc(get_turf(user))
				S.set_loc(src)
				src.satchel = S
				if (old_satchel)
					user.put_in_hand_or_drop(old_satchel)
				src.icon_state = "scoop-bag"
				user.visible_message("[user] inserts [S] into [src].", "You insert [S] into [src].")
			else
				boutput(user, SPAN_ALERT("The satchel is firmly secured to the scoop."))
		else
			..()
			return

	attack_self(var/mob/user as mob)
		if(issilicon(user))
			boutput(user, SPAN_ALERT("The satchel is firmly secured to the scoop."))
			return
		if (!satchel)
			src.collect_junk = !src.collect_junk
			if (src.collect_junk)
				boutput(user, SPAN_NOTICE("Now collecting junk."))
			else
				boutput(user, SPAN_NOTICE("No longer collecting junk."))
		else
			user.visible_message("[user] unloads [satchel] from [src].", "You unload [satchel] from [src].")
			user.put_in_hand_or_drop(satchel)
			satchel = null
			icon_state = "scoop"


	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if(isturf(target))
			if (!satchel)
				boutput(user, SPAN_ALERT("There's no satchel in [src] to dump out."))
				return
			if (length(satchel.contents) < 1)
				boutput(user, SPAN_ALERT("The satchel in [src] is empty."))
				return
			if(!is_blocked_turf(target))
				user.visible_message("[user] dumps out [src]'s satchel contents onto the ground.", "You dump out [src]'s satchel contents onto the ground.")
				for (var/obj/item/I in satchel.contents)
					I.set_loc(target)
				satchel.UpdateIcon()
			return
		if (istype(target, /obj/item/satchel/mining))
			if (!issilicon(user))
				var/obj/item/satchel/mining/new_satchel = target
				var/atom/old_location = null //this stores the old location so we know where the clicked item came from
				var/was_stored = FALSE //For stuff with storage datums, we can move the item to that storage
				if (new_satchel.stored)
					old_location = new_satchel.stored.linked_item
					was_stored = TRUE
				else
					old_location = new_satchel.loc
				if (ismob(old_location) && !was_stored)
					var/mob/old_user = old_location
					old_user.drop_item(new_satchel) // not only user since you could click on a satchel carried by someone else... ugh
				var/obj/item/satchel/mining/old_satchel = src.satchel
				if (old_satchel)
					old_satchel.set_loc(get_turf(user))
				new_satchel.set_loc(src)
				src.satchel = new_satchel
				if (old_satchel && old_location)
					if (was_stored) //if the old satchel was in a storage item, the new item should fit as well
						old_location.storage.add_contents(old_satchel, user, FALSE)
					else
						user.put_in_hand_or_drop(old_satchel)
				src.icon_state = "scoop-bag"
				user.visible_message("[user] inserts [new_satchel] into [src].", "You insert [new_satchel] into [src].")
			else
				boutput(user, SPAN_ALERT("The satchel is firmly secured to the scoop."))

////// Shit that goes in the asteroid belt, might split it into an exploring.dm later i guess

/turf/simulated/wall/ancient
	name = "strange wall"
	desc = "A weird jet black metal wall indented with strange grooves and lines."
	icon_state = "ancient"

	attackby(obj/item/W, mob/user)
		boutput(user, SPAN_COMBAT("You attack [src] with [W] but fail to even make a dent!"))
		return

	ex_act(severity)
		if (severity == 1.0)
			if (prob(8))
				src.set_opacity(0)
				src.set_density(0)
				src.icon_state = "ancient-b"
				return
		else return

/turf/simulated/floor/ancient
	name = "strange surface"
	desc = "A strange jet black metal floor. There are odd lines carved into it."
	icon_state = "ancient"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	attackby(obj/item/W, mob/user)
		boutput(user, SPAN_COMBAT("You attack [src] with [W] but fail to even make a dent!"))
		return

	ex_act(severity)
		return

/turf/unsimulated/floor/ancient
	name = "strange surface"
	desc = "A strange jet black metal floor. There are odd lines carved into it."
	icon_state = "ancient"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	attackby(obj/item/W, mob/user)
		boutput(user, SPAN_COMBAT("You attack [src] with [W] but fail to even make a dent!"))
		return

	ex_act(severity)
		return
