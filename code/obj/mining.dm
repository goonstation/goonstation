// Magnet Stuff

/obj/machinery/magnet_chassis
	name = "magnet chassis"
	desc = "A strong metal rig designed to hold and link up magnet apparatus with other technology."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "chassis"
	opacity = 0
	density = 1
	anchored = 1
	var/obj/machinery/mining_magnet/linked_magnet = null

	New()
		..()
		SPAWN(0)
			src.update_dir()
			for (var/obj/machinery/mining_magnet/MM in range(1,src))
				linked_magnet = MM
				MM.linked_chassis = src
				break

	disposing()
		if (linked_magnet)
			qdel(linked_magnet)
		linked_magnet = null
		..()

	attackby(obj/item/W, mob/user)
		#ifndef UNDERWATER_MAP
		if (istype(W,/obj/item/magnet_parts))
			if (istype(src.linked_magnet))
				boutput(user, "<span class='alert'>There's already a magnet installed.</span>")
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
	id = "magnet_build"
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
		owner.visible_message("<span class='notice'>[master] begins to assemble [mag_parts]!</span>")

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
		owner.visible_message("<span class='notice'>[owner] constructs [magnet]!</span>")

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

	proc/erase_area()
		var/turf/origin = get_turf(src)
		for (var/turf/T in block(origin, locate(origin.x + width - 1, origin.y + height - 1, origin.z)))
			for (var/obj/O in T)
				if (!(O.type in mining_controls.magnet_do_not_erase) && !istype(O, /obj/magnet_target_marker))
					qdel(O)
			T.ClearAllOverlays()

			if(istype(T,/turf/unsimulated) && ( T.GetComponent(/datum/component/buildable_turf) || (station_repair.station_generator && (origin.z == Z_LEVEL_STATION))))
				T.ReplaceWith(/turf/space, force=TRUE)
			else
				T.ReplaceWith(/turf/space)
			T.UpdateOverlays(new /image/fullbright, "fullbright")

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
		for (var/turf/T in block(origin, locate(origin.x + width - 1, origin.y + height - 1, origin.z)))

			for (var/mob/living/L in T)
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
				boutput(usr, "<span class='alert'>Error: magnet area spans over construction area bounds.</span>")
				return 0
			var/isterrain = T.GetComponent(/datum/component/buildable_turf) && istype(T,/turf/unsimulated)
			if ((!istype(T, /turf/space) && !isterrain) && !istype(T, /turf/simulated/floor/plating/airless/asteroid) && !istype(T, /turf/simulated/wall/auto/asteroid))
				boutput(usr, "<span class='alert'>Error: [T] detected in [width]x[height] magnet area. Cannot magnetize.</span>")
				return 0

		var/borders = list()
		for (var/cx = origin.x - 1, cx <= origin.x + width, cx++)
			var/turf/S = locate(cx, origin.y - 1, origin.z)
			var/isterrain = S.GetComponent(/datum/component/buildable_turf) && istype(S,/turf/unsimulated)
			if (!S || istype(S, /turf/space) || isterrain)
				boutput(usr, "<span class='alert'>Error: bordering tile has a gap, cannot magnetize area.</span>")
				return 0
			borders += S
			S = locate(cx, origin.y + height, origin.z)
			isterrain = S.GetComponent(/datum/component/buildable_turf) && istype(S,/turf/unsimulated)
			if (!S || istype(S, /turf/space) || isterrain)
				boutput(usr, "<span class='alert'>Error: bordering tile has a gap, cannot magnetize area.</span>")
				return 0
			borders += S

		for (var/cy = origin.y, cy <= origin.y + height - 1, cy++)
			var/turf/S = locate(origin.x - 1, cy, origin.z)
			var/isterrain = S.GetComponent(/datum/component/buildable_turf) && istype(S,/turf/unsimulated)
			if (!S || istype(S, /turf/space) || isterrain)
				boutput(usr, "<span class='alert'>Error: bordering tile has a gap, cannot magnetize area.</span>")
				return 0
			borders += S
			S = locate(origin.x + width, cy, origin.z)
			isterrain = S.GetComponent(/datum/component/buildable_turf) && istype(S,/turf/unsimulated)
			if (!S || istype(S, /turf/space) || isterrain)
				boutput(usr, "<span class='alert'>Error: bordering tile has a gap, cannot magnetize area.</span>")
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
			. += "<span class='notice'>The magnetizer is loaded with a plasmastone. Designate the mineral magnet to attach, then designate the lower left tile of the area to magnetize.</span>"
			. += "<span class='notice'>The magnetized area must be a clean shot of space, surrounded by bordering tiles on all sides.</span>"
			. += "<span class='notice'>A small mineral magnet requires an 7x7 area of space, a large one requires a 15x15 area of space.</span>"
		else
			. += "<span class='alert'>The magnetizer must be loaded with a chunk of plasmastone to use.</span>"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/raw_material/plasmastone) && !loaded)
			loaded = 1
			boutput(user, "<span class='notice'>You charge the magnetizer with the plasmastone.</span>")
			qdel(W)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		var/isterrain = target.GetComponent(/datum/component/buildable_turf) && istype(target,/turf/unsimulated)
		if (!magnet)
			if (istype(target, /obj/machinery/magnet_chassis))
				magnet = target:linked_magnet
			else
				magnet = target
			ENSURE_TYPE(magnet)
			else
				if (!loaded)
					boutput(user, "<span class='alert'>The magnetizer needs to be loaded with a plasmastone chunk first.</span>")
					magnet = null
				else if (magnet.target)
					boutput(user, "<span class='alert'>That magnet is already locked onto a location.</span>")
					magnet = null
				else
					boutput(user, "<span class='notice'>Magnet locked. Designate lower left tile of target area (excluding the borders).</span>")
		else if ((istype(target, /turf/space) || isterrain) && magnet)
			if (!loaded)
				boutput(user, "<span class='alert'>The magnetizer needs to be loaded with a plasmastone chunk first.</span>")
			if (magnet.target)
				boutput(user, "<span class='alert'>Magnet target already designated. Unlocking.</span>")
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
				boutput(user, "<span class='alert'>Designation failed: designated tile is outside magnet range.</span>")
				qdel(M)
			else if (!M.construct())
				boutput(user, "<span class='alert'>Designation failed.</span>")
				qdel(M)
			else
				boutput(user, "<span class='notice'>Designation successful. The magnet is now fully operational.</span>")
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
	anchored = 1
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
		src.visible_message("<b>[src] breaks apart!</b>")
		robogibs(src.loc,null)
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
				. += "<span class='alert'>It's rather badly damaged. It probably needs some wiring replaced inside.</span>"
			else
				. += "<span class='alert'>It's a bit damaged. It looks like it needs some welding done.</span>"

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
			boutput(user, "<span class='alert'>It's way too dangerous to do that while it's active!</span>")
			return

		if (isweldingtool(W))
			if (src.health < 50)
				boutput(user, "<span class='alert'>You need to use wire to fix the cabling first.</span>")
				return
			if(W:try_weld(user, 1))
				src.damage(-10)
				src.malfunctioning = 0
				user.visible_message("<b>[user]</b> uses [W] to repair some of [src]'s damage.")
				if (src.health >= 100)
					boutput(user, "<span class='notice'><b>[src] looks fully repaired!</b></span>")

		else if (istype(W,/obj/item/cable_coil/))
			var/obj/item/cable_coil/C = W
			if (src.health > 50)
				boutput(user, "<span class='alert'>The cabling looks fine. Use a welder to repair the rest of the damage.</span>")
				return
			C.use(1)
			src.damage(-10)
			user.visible_message("<b>[user]</b> uses [C] to repair some of [src]'s cabling.")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			if (src.health >= 50)
				boutput(user, "<span class='notice'>The wiring is fully repaired. Now you need to weld the external plating.</span>")
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

		if (damage_overlays.len == 4)
			switch(src.health)
				if (70 to 94)
					src.UpdateOverlays(damage_overlays[1], "magnet_damage")
				if (40 to 69)
					src.UpdateOverlays(damage_overlays[2], "magnet_damage")
				if (10 to 39)
					src.UpdateOverlays(damage_overlays[3], "magnet_damage")
				if (-INFINITY to 10)
					src.UpdateOverlays(damage_overlays[4], "magnet_damage")

		if (src.active)
			src.UpdateOverlays(src.active_overlay, "magnet_active")

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
		sleep_time /= 2

		if (malfunctioning && prob(20))
			do_malfunction()
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
			station_repair.repair_turfs(repair_turfs)

		sleep(sleep_time)
		if (malfunctioning && prob(20))
			do_malfunction()

		active = 0
		build_icon()

		for (var/obj/forcefield/mining/M in wall_bits)
			M.set_opacity(0)
			M.set_density(0)
			M.invisibility = INVIS_ALWAYS

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
					boutput(usr, "Uh oh, something's gotten really fucked up with the magnet system. Please report this to a coder!")
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
					boutput(usr, "Uh oh, something's gotten really fucked up with the magnet system. Please report this to a coder!")
					return

				if (target.check_for_unacceptable_content())
					src.visible_message("<b>[src.name]</b> states, \"Safety lock engaged. Please remove all personnel and vehicles from the magnet area.\"")
				else
					src.last_use_attempt = TIME + 10 // This is to prevent href exploits or autoclickers from pulling multiple times simultaneously
					src.pull_new_source()
					. = TRUE
			if("overridecooldown")
				if (!ishuman(usr))
					boutput(usr, "<span class='alert'>AI and robotic personnel may not access the override.</span>")
				else
					var/mob/living/carbon/human/H = usr
					if(!src.allowed(H))
						boutput(usr, "<span class='alert'>Access denied. Please contact the Chief Engineer or Captain to access the override.</span>")
					else
						src.cooldown_override = !src.cooldown_override
					. = TRUE
			if("automode")
				src.automatic_mode = !src.automatic_mode
				. = TRUE

	ui_status(mob/user, datum/ui_state/state)
		. = tgui_broken_state.can_use_topic(src, user)


/obj/machinery/computer/magnet
	name = "mineral magnet controls"
	icon = 'icons/obj/computer.dmi'
	icon_state = "mmagnet"
	circuit_type = /obj/item/circuitboard/mining_magnet
	var/temp = null
	var/list/linked_magnets = list()
	var/obj/machinery/mining_magnet/linked_magnet = null
	req_access = list(access_engineering_chief)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	can_reconnect = 1 //IDK why you'd want to but for consistency's sake

	New()
		..()
		SPAWN(0)
			src.connection_scan()

	ui_interact(mob/user, datum/tgui/ui)
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
					. = src.linked_magnet.ui_act(action, params)

	ui_status(mob/user, datum/ui_state/state)
		. = ..()
		if(istype(src.linked_magnet))
			. = min(., linked_magnet.ui_status(user))

/obj/machinery/computer/magnet/connection_scan()
	linked_magnets = list()
	var/badmagnets = 0
	for (var/obj/machinery/magnet_chassis/MC in range(20,src))
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
	icon = 'icons/turf/walls_asteroid.dmi'
	mod = "asteroid-"
	light_mod = "wall-"
	plane = PLANE_WALL-1
	layer = ASTEROID_LAYER
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	default_material = "rock"

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
	var/quality = 0
	var/default_ore = /obj/item/raw_material/rock
	var/datum/ore/ore = null
	var/datum/ore/event/event = null
	var/list/space_overlays = null

	//NEW VARS
	var/mining_health = 120
	var/mining_max_health = 120
	var/mining_toughness = 1 //Incoming damage divided by this unless tool has power enough to overcome.
	var/topnumber = 1
	var/orenumber = 1

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
					algea.filters += filter(type="alpha", icon=icon('icons/turf/walls_asteroid.dmi',"mask-side_[src.icon_state]"))
					UpdateOverlays(algea, "glow_algae")
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
		stone_color = "#9cc4f5"
		default_ore = /obj/item/raw_material/ice

	geode
		name = "compacted stone"
		desc = "This rock looks really hard to dig out."
		stone_color = "#4c535c"
		default_ore = null
		hardness = 10


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
			quality = 15
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
			algea.filters += filter(type="alpha", icon=icon('icons/turf/walls_asteroid.dmi',"mask-side_[src.icon_state]"))
			UpdateOverlays(algea, "glow_algae")
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
		src.space_overlays = list()
		src.topnumber = pick(1,2,3)
		src.orenumber = pick(1,2,3)
		..()
		worldgenCandidates += src
		if(current_state <= GAME_STATE_PREGAME)
			src.color = src.stone_color

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
			if (usr.bioHolder && usr.bioHolder.HasEffect("training_miner"))
				if (istype (src.ore,/datum/ore/))
					var/datum/ore/O = src.ore
					. = "It looks like it contains [O.name]."
				else
					. = "Doesn't look like there's any valuable ore here."
				if (src.event)
					. += "<br><span class='alert'>There's something not quite right here...</span>"

	attack_hand(var/mob/user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.gloves, /obj/item/clothing/gloves/concussive))
				var/obj/item/clothing/gloves/concussive/C = H.gloves
				src.dig_asteroid(user,C.tool)
				return
			else if (H.is_hulk())
				H.visible_message("<span class='alert'><b>[H.name] punches [src] with great strength!</span>")
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
			if (T.status)
				T.process_charges(T.digcost)
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
					message += "<span class='alert'>[E.analysis_string]</span><br>"
			message += "----------------------------------"
			boutput(user, message)
		else
			boutput(user, "<span class='alert'>You hit the [src.name] with [W], but nothing happens!</span>")
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
			UpdateOverlays(null, "damage")
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
		src.ClearAllOverlays() // i know theres probably a better way to handle this
		src.top_overlays()
		src.ore_overlays()

	proc/top_overlays() // replaced what was here with cool stuff for autowalls
		var/image/top_overlay = image('icons/turf/walls_asteroid.dmi',"top[src.topnumber]")
		top_overlay.filters += filter(type="alpha", icon=icon('icons/turf/walls_asteroid.dmi',"mask2[src.icon_state]"))
		top_overlay.layer = ASTEROID_TOP_OVERLAY_LAYER
		UpdateOverlays(top_overlay, "ast_top_rock")

	proc/ore_overlays()
		if(src.ore) // make sure ores dont turn invisible
			var/image/ore_overlay = image('icons/turf/walls_asteroid.dmi',"[src.ore?.name][src.orenumber]")
			ore_overlay.filters += filter(type="alpha", icon=icon('icons/turf/walls_asteroid.dmi',"mask-side_[src.icon_state]"))
			ore_overlay.layer = ASTEROID_ORE_OVERLAY_LAYER // so meson goggle nerds can still nerd away
			src.UpdateOverlays(ore_overlay, "ast_ore")

	proc/space_overlays()
		for (var/turf/space/A in orange(src,1))
			var/image/edge_overlay = image('icons/turf/walls_asteroid.dmi', "edge[get_dir(A,src)]")
			edge_overlay.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR | RESET_ALPHA
			edge_overlay.layer = src.layer + 1
			edge_overlay.plane = PLANE_WALL-1
			edge_overlay.layer = TURF_EFFECTS_LAYER
			edge_overlay.color = src.stone_color
			A.UpdateOverlays(edge_overlay, "ast_edge_[get_dir(A,src)]")
			src.space_overlays += edge_overlay

	proc/dig_asteroid(var/mob/living/user, var/obj/item/mining_tool/tool)
		if (!user || !tool || !istype(src)) return

		var/datum/ore/event/E = src.event

		if (tool.status)
			playsound(user.loc, tool.hitsound_charged, 50, 1)
		else
			playsound(user.loc, tool.hitsound_uncharged, 50, 1)

		if (tool.weakener)
			src.weaken_asteroid()

		var/strength = tool.dig_strength
		if (iscarbon(user))
			var/mob/living/carbon/C = user
			if (C.bioHolder && C.bioHolder.HasOneOfTheseEffects("strong","hulk"))
				strength++

		var/minedifference = src.hardness - strength

		if (E)
			E.onHit(src)

		if (src.ore)
			src.ore.onHit(src)
		//user.visible_message("<span class='alert'>[user.name] strikes [src] with [tool].</span>")

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
				boutput(user, "<span class='alert'>[dig_feedback]</span>")

		return

	proc/weaken_asteroid()
		if (src.weakened)
			return
		src.weakened = 1
		if (src.hardness >= 1)
			src.hardness /= 2
		else
			src.hardness = 0
		src.UpdateOverlays(image('icons/turf/walls_asteroid.dmi', "weakened"), "asteroid_weakened")

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
		var/datum/ore/O = src.ore
		var/datum/ore/event/E = src.event
		if (src.invincible)
			return
		if (E)
			if (E.excavation_string)
				src.visible_message("<span class='alert'>[E.excavation_string]</span>")
			E.onExcavate(src)
		var/ore_to_create = src.default_ore
		if (ispath(ore_to_create) && dropOre)
			if (O)
				ore_to_create = O.output
				O.onExcavate(src)
			var/makeores
			for(makeores = src.amount, makeores > 0, makeores--)
				var/obj/item/raw_material/MAT = new ore_to_create
				MAT.set_loc(src)

				if(MAT.material)
					if(MAT.material.quality != 0) //If it's 0 then that's probably the default, so let's use the asteroids quality only if it's higher. That way materials that have a quality by default will not occur at any quality less than the set one. And materials that do not have a quality by default, use the asteroids quality instead.
						var/newQual = max(MAT.material.quality, src.quality)
						MAT.material.quality = newQual
						MAT.quality = newQual
					else
						MAT.material.quality = src.quality
						MAT.quality = src.quality

				MAT.name = getOreQualityName(MAT.quality) + " [MAT.name]"
		if(!icon_old)
			icon_old = icon_state

		var/new_color = src.stone_color
		src.RL_SetOpacity(0)
		src.ReplaceWith(/turf/simulated/floor/plating/airless/asteroid)
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
				if (usable_turfs.len < 1)
					break
				AST = pick(usable_turfs)
				AST.event = E
				E.onGenerate(AST)
				usable_turfs -= AST

/turf/simulated/floor/plating/airless/asteroid
	name = "asteroid"
	icon = 'icons/turf/walls_asteroid.dmi'
	icon_state = "astfloor1"
	plane = PLANE_FLOOR //Try to get the edge overlays to work with shadowing. I dare ya.
	oxygen = 0.001
	nitrogen = 0.001
	temperature = TCMB
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	has_material = FALSE
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

		src.ClearAllOverlays()
		src.color = src.stone_color
		#ifndef UNDERWATER_MAP
		if (fullbright)
			src.UpdateOverlays(new /image/fullbright, "fullbright")
		#endif

	proc/space_overlays() //For overlays ON THE SPACE TILE
		for (var/turf/space/A in orange(src,1))
			var/image/edge_overlay = image('icons/turf/walls_asteroid.dmi', "edge[get_dir(A,src)]")
			edge_overlay.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR | RESET_ALPHA
			edge_overlay.plane = PLANE_FLOOR
			edge_overlay.layer = TURF_EFFECTS_LAYER
			edge_overlay.color = src.stone_color
			A.UpdateOverlays(edge_overlay, "ast_edge_[get_dir(A,src)]")
			src.space_overlays += edge_overlay


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
	flags = ONBELT
	force = 7
	var/cell_type = null
	var/dig_strength = 1
	var/status = 0
	var/digcost = 0
	var/weakener = 0
	var/image/powered_overlay = null
	var/sound/hitsound_charged = 'sound/impact_sounds/Stone_Cut_1.ogg'
	var/sound/hitsound_uncharged = 'sound/impact_sounds/Stone_Cut_1.ogg'

	New()
		..()
		if(cell_type)
			var/cell = new cell_type
			AddComponent(/datum/component/cell_holder, cell)
		BLOCK_SETUP(BLOCK_ROD)

	// Seems like a basic bit of user feedback to me (Convair880).
	examine(mob/user)
		. = ..()
		if (isrobot(user))
			return // Drains battery instead.
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			. += "The [src.name] is turned [src.status ? "on" : "off"]. There are [ret["charge"]]/[ret["max_charge"]] PUs left!"

	proc/process_charges(var/use)
		if (!isnum(use) || use < 0)
			return 0
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			return 0

		if (SEND_SIGNAL(src, COMSIG_CELL_USE, use) & CELL_INSUFFICIENT_CHARGE)
			src.power_down()
			var/turf/T = get_turf(src)
			T.visible_message("<span class='alert'>[src] runs out of charge and powers down!</span>")
		return 1

	attack_self(var/mob/user as mob)
		if (!digcost)
			return
		if (src.process_charges(0))
			if (!src.status)
				boutput(user, "<span class='notice'>You power up [src].</span>")
				src.power_up()
				playsound(user.loc, 'sound/items/miningtool_on.ogg', 30, 1)
			else
				boutput(user, "<span class='notice'>You power down [src].</span>")
				src.power_down()
		else
			boutput(user, "<span class='alert'>No charge left in [src].</span>")

	afterattack(target as mob, mob/user as mob)
		..()
		if (src.status && !isturf(target))
			src.process_charges(digcost*5)

	proc/power_up()
		src.tooltip_rebuild = 1
		src.status = 1
		if (powered_overlay)
			src.overlays += powered_overlay
			signal_event("icon_updated")
		return

	proc/power_down()
		src.tooltip_rebuild = 1
		src.status = 0
		if (powered_overlay)
			src.overlays = null
			signal_event("icon_updated")
		return

obj/item/clothing/gloves/concussive
	name = "concussion gauntlets"
	desc = "These gloves enable miners to punch through solid rock with their hands instead of using tools."
	icon_state = "cgaunts"
	item_state = "bgloves"
	material_prints = "industrial-grade mineral fibers"
	var/obj/item/mining_tool/tool = null

	setupProperties()
		..()
		setProperty("conductivity", 0.6)

	New()
		..()
		var/obj/item/mining_tool/T = new /obj/item/mining_tool(src)
		src.tool = T
		T.name = src.name
		T.desc = src.desc
		T.dig_strength = 4
		T.hitsound_charged = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
		T.hitsound_uncharged = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
		AddComponent(/datum/component/wearertargeting/unarmedblock/concussive, list(SLOT_GLOVES))

/obj/item/mining_tool/power_pick
	name = "power pick"
	desc = "An energised mining tool."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "powerpick"
	item_state = "ppick1"
	flags = ONBELT
	dig_strength = 2
	digcost = 2
	cell_type = /obj/item/ammo/power_cell
	hitsound_charged = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
	hitsound_uncharged = 'sound/impact_sounds/Stone_Cut_1.ogg'

	New()
		..()
		powered_overlay = image('icons/obj/items/mining.dmi', "pp-glow")
		src.power_up()

	power_up()
		..()
		src.force = 15
		src.dig_strength = 2
		if(ismob(src.loc))
			var/mob/user = src.loc
			item_state = "ppick1"
			user.update_inhands()

	power_down()
		..()
		src.force = 7
		src.dig_strength = 1
		item_state = "ppick0"
		if(ismob(src.loc))
			var/mob/user = src.loc
			user.update_inhands()
			playsound(user.loc, 'sound/items/miningtool_off.ogg', 30, 1)

	borg
		process_charges(var/use)
			var/mob/living/silicon/robot/R = usr
			if (istype(R))
				if (R.cell.charge > use * 66)
					R.cell.use(66 * use)
					return 1
				return 0
			else
				. = ..()

/obj/item/mining_tool/drill
	name = "laser drill"
	desc = "Safe mining tool that doesn't require recharging."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "lasdrill"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "drill"
	flags = ONBELT
	force = 10
	mats = 4
	dig_strength = 2
	hitsound_charged = 'sound/items/Welder.ogg'
	hitsound_uncharged = 'sound/items/Welder.ogg'

/obj/item/mining_tool/powerhammer
	name = "power hammer"
	desc = "An energised mining tool."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "powerhammer"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "phammer1"
	cell_type = /obj/item/ammo/power_cell
	force = 9
	dig_strength = 3
	digcost = 3
	hitsound_charged = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
	hitsound_uncharged = 'sound/impact_sounds/Stone_Cut_1.ogg'

	New()
		..()
		src.powered_overlay = image('icons/obj/items/mining.dmi', "ph-glow")
		src.power_up()

	power_up()
		..()
		src.force = 20
		dig_strength = 3
		weakener = 1
		item_state = "phammer1"
		if(ismob(src.loc))
			var/mob/user = src.loc
			user.update_inhands()
		src.setItemSpecial(/datum/item_special/slam)

	power_down()
		..()
		src.force = 9
		dig_strength = 1
		weakener = 0
		item_state = "phammer0"
		if(ismob(src.loc))
			var/mob/user = src.loc
			user.update_inhands()
			playsound(user.loc, 'sound/items/miningtool_off.ogg', 30, 1)
		src.setItemSpecial(/datum/item_special/simple)

	borg
		process_charges(var/use)
			var/mob/living/silicon/robot/R = usr
			if (istype(R))
				if (R.cell.charge > use * 66)
					R.cell.use(66 * use)
					return 1
				return 0
			else
				. = ..()

/obj/item/mining_tool/power_shovel
	name = "power shovel"
	desc = "The final word in digging."
	icon = 'icons/obj/sealab_power.dmi'
	icon_state = "powershovel"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "pshovel1"
	flags = ONBELT
	dig_strength = 0
	digcost = 2
	cell_type = /obj/item/ammo/power_cell
	hitsound_charged = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
	hitsound_uncharged = 'sound/impact_sounds/Stone_Cut_1.ogg'

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		powered_overlay = image('icons/obj/sealab_power.dmi', "ps-glow")
		src.power_up()

	power_up()
		..()
		src.force = 8
		src.dig_strength = 0
		item_state = "pshovel1"
		if(ismob(src.loc))
			var/mob/user = src.loc
			user.update_inhands()

	power_down()
		..()
		src.force = 4
		src.dig_strength = 0
		item_state = "pshovel0"
		if(ismob(src.loc))
			var/mob/user = src.loc
			user.update_inhands()
			playsound(user.loc, 'sound/items/miningtool_off.ogg', 30, 1)

	borg
		process_charges(var/use)
			var/mob/living/silicon/robot/R = usr
			if (istype(R))
				if (R.cell.charge > use * 100)
					R.cell.use(100 * use)
					return 1
				return 0
			else
				. = ..()

/obj/item/breaching_charge/mining
	name = "concussive charge"
	desc = "It is set to detonate in 5 seconds."
	flags = ONBELT
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
			if (!src.state)
				if (istype(target, /obj/item/storage)) // no blowing yourself up if you have full backpack
					return
				if(user.bioHolder.HasEffect("clumsy") || src.emagged)
					if(src.emagged)
						user.visible_message("<b>CLICK</b>")
						boutput(user, "<span class='alert'>The timing mechanism malfunctions!</span>")
					else
						boutput(user, "<span class='alert'>Huh? How does this thing work?!</span>")
					logTheThing(LOG_COMBAT, user, "accidentally triggers [src] (clumsy bioeffect) at [log_loc(user)].")
					SPAWN(0.5 SECONDS)
						concussive_blast()
						qdel (src)
						return
				else
					if (istype(target, /turf/simulated/wall/auto/asteroid/) && !src.hacked)
						boutput(user, "<span class='alert'>You slap the charge on [target], [det_time/10] seconds!</span>")
						user.visible_message("<span class='alert'>[user] has attached [src] to [target].</span>")
						src.icon_state = "bcharge2"
						user.drop_item()

						// Yes, please (Convair880).
						if (src?.hacked)
							logTheThing(LOG_COMBAT, user, "attaches a hacked [src] to [target] at [log_loc(target)].")

						user.set_dir(get_dir(user, target))
						user.drop_item()
						var/t = (isturf(target) ? target : target.loc)
						step_towards(src, t)

						SPAWN( src.det_time )
							concussive_blast()
							if(target)
								if(istype(target,/obj/machinery))
									qdel(target)
							qdel(src)
							return
					else if (src.hacked) ..()
					else boutput(user, "<span class='alert'>These will only work on asteroids.</span>")
			return

	emag_act(var/mob/user, var/obj/item/card/emag/E)

		if(!src.emagged && !src.hacked)
			if (user)
				boutput(user, "<span class='notice'>You short out the timing mechanism!</span>")

			src.desc += " It has been tampered with."
			src.emagged = 1
			return 1
		else
			if (user)
				boutput(user, "<span class='alert'>This has already been tampered with.</span>")
			return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			boutput(user, "<span class='notice'>You repair the timing mechanism!</span>")
		src.emagged = 0
		src.desc = null
		src.desc = "It is set to detonate in 5 seconds."
		return 1

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/chargehacker))
			if(!src.emagged && !src.hacked)
				boutput(user, "<span class='notice'>You short out the attachment mechanism, removing its restrictions!</span>")
				src.desc += " It has been tampered with."
				src.hacked = 1
			else
				boutput(user, "<span class='alert'>This has already been tampered with.</span>")
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
				C.changeStatus("weakened", 10 SECONDS)
				C.stuttering += 15
				boutput(C, "<span class='alert'>The concussive blast knocks you off your feet!</span>")
			if(GET_DIST(src,C) <= src.expl_heavy)
				C.TakeDamage("All",rand(15,25)*(1-C.get_explosion_resistance()),0)
				boutput(C, "<span class='alert'>You are battered by the concussive shockwave!</span>")

/// Multiplier for power usage if the user is a silicon and the charge is coming from their internal cell
#define SILICON_POWER_COST_MOD 10

/obj/item/cargotele
	name = "cargo transporter"
	desc = "A device for teleporting crated goods."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "cargotele"
	/// Power cost per teleport
	var/cost = 25
	/// Target pad we send cargo to. Make sure you're sending to the pad's loc and not the pad itself
	var/obj/submachine/cargopad/target = null
	/// Type of cell used in this
	var/cell_type = /obj/item/ammo/power_cell/med_power
	/// List of types that cargo teles are allowed to send. Built in New, shared across all teles
	var/static/list/allowed_types = list()
	w_class = W_CLASS_SMALL
	flags = ONBELT | FPRINT | TABLEPASS | SUPPRESSATTACK
	mats = 4

	New()
		. = ..()
		var/list/allowed_supertypes = list(/obj/machinery/portable_atmospherics/canister, /obj/reagent_dispensers, /obj/storage)
		for (var/supertype in allowed_supertypes)
			for (var/subtype in typesof(supertype))
				allowed_types[subtype] = 1
		allowed_types -= /obj/storage/closet/flock

		var/cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, swappable = FALSE)
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CARGO_PAD_DISABLED, .proc/maybe_reset_target) //make sure cargo pads can GC

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
				. += "<span class='alert'>No power cell installed.</span>"
			else
				. += "There are [ret["charge"]]/[ret["max_charge"]] PUs left! Each use will consume [cost]PU."

	attack_self(mob/user) // Fixed --melon
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(usr, "<span class='alert'>The transporter is out of charge.</span>")
			return
		if (!length(global.cargo_pad_manager.pads))
			boutput(usr, "<span class='alert'>No receivers available.</span>")
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
				boutput(user, "<span class='alert'>You can't teleport [O] while it is anchored!</span>")
				return
			src.try_teleport(O, user)

	proc/can_teleport(var/obj/cargo, var/mob/user)
		if (!src.target)
			boutput(user, "<span class='alert'>You need to set a target first!</span>")
			return FALSE
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(user, "<span class='alert'>The transporter is out of charge.</span>")
			return FALSE
		if (isrobot(user))
			var/mob/living/silicon/robot/R = user
			if (R.cell.charge < src.cost * SILICON_POWER_COST_MOD)
				boutput(user, "<span class='alert'>There is not enough charge left in your cell to use this.</span>")
				return FALSE

		return TRUE

	proc/try_teleport(var/obj/cargo, var/mob/user)
		// Why didn't you implement checks for these in the first place, sigh (Convair880).
		if (cargo.loc == user && issilicon(user))
			user.show_text("The [cargo.name] is securely bolted to your chassis.", "red")
			return FALSE

		if (!src.can_teleport(cargo, user))
			return FALSE

		boutput(user, "<span class='notice'>Teleporting [cargo] to [src.target]...</span>")
		playsound(user.loc, 'sound/machines/click.ogg', 50, 1)
		SETUP_GENERIC_PRIVATE_ACTIONBAR(user, src, 3 SECONDS, .proc/finish_teleport, list(cargo, user), null, null, null, null)
		return TRUE


	proc/finish_teleport(var/obj/cargo, var/mob/user)
		if (ismob(cargo.loc) && cargo.loc == user)
			user.u_equip(cargo)
		if (istype(cargo.loc, /obj/item/storage))
			var/obj/item/storage/S_temp = cargo.loc
			var/datum/hud/storage/H_temp = S_temp.hud
			H_temp.remove_object(cargo)

		// And logs for good measure (Convair880).
		var/obj/storage/S = cargo
		ENSURE_TYPE(S)

		for (var/mob/M in cargo.contents)
			if (M)
				logTheThing(LOG_STATION, user, "uses a cargo transporter to send [cargo.name][S && S.locked ? " (locked)" : ""][S && S.welded ? " (welded)" : ""] with [constructTarget(M,"station")] inside to [log_loc(src.target)].")

		cargo.set_loc(get_turf(src.target))
		target.receive_cargo(cargo)
		elecflash(src)
		if (isrobot(user))
			var/mob/living/silicon/robot/R = user
			R.cell.charge -= cost * SILICON_POWER_COST_MOD
		else
			var/ret = SEND_SIGNAL(src, COMSIG_CELL_USE, cost)
			if (ret & CELL_INSUFFICIENT_CHARGE)
				boutput(user, "<span class='alert'>Transfer successful. The transporter is now out of charge.</span>")
			else
				boutput(user, "<span class='notice'>Transfer successful.</span>")

#undef SILICON_POWER_COST_MOD

/obj/item/cargotele/traitor
	cost = 15
	var/static/list/possible_targets = list()

	New()
		..()
		if (!length(possible_targets))
			for(var/turf/T in world) //hate to do this but it's only once vOv
				LAGCHECK(LAG_LOW)
				if(istype(T,/turf/space) && T.z != 1 && T.z != 6 && !isrestrictedz(T.z)) //do not foot ball, do not collect 200
					possible_targets += T

	attack_self() // Fixed --melon
		return

	can_teleport(obj/cargo, mob/user)
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(user, "<span class='alert'>The transporter is out of charge.</span>")
			return FALSE
		return TRUE

	try_teleport(obj/cargo, mob/user)
		if(..() && istype(cargo, /obj/storage))
			var/obj/storage/store = cargo
			store.weld(TRUE, user)

	finish_teleport(var/obj/cargo, var/mob/user)
		if (!length(src.possible_targets))
			CRASH("Tried to syndi-teleport [cargo] but the list of possible turf targets was empty.")
		src.target = pick(src.possible_targets)
		boutput(user, "<span class='notice'>Teleporting [cargo]...</span>")
		playsound(user.loc, 'sound/machines/click.ogg', 50, 1)

		// Logs for good measure (Convair880).
		for (var/mob/M in cargo.contents)
			logTheThing(LOG_STATION, user, "uses a Syndicate cargo transporter to send [cargo.name] with [constructTarget(M,"station")] inside to [log_loc(src.target)].")

		cargo.set_loc(src.target)
		elecflash(src)
		var/ret = SEND_SIGNAL(src, COMSIG_CELL_USE, cost)
		if (ret & CELL_INSUFFICIENT_CHARGE)
			boutput(user, "<span class='alert'>Transfer successful. The transporter is now out of charge.</span>")
		else
			boutput(user, "<span class='notice'>Transfer successful.</span>")

/obj/item/oreprospector
	name = "geological scanner"
	desc = "A device capable of detecting nearby mineral deposits."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "minanal"
	flags = ONBELT
	w_class = W_CLASS_TINY

	attack_self(var/mob/user as mob)
		mining_scan(get_turf(user), user, 6)

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
	if (ores_found.len > 0)
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
	flags = ONBELT
	w_class = W_CLASS_TINY

	attack_self(var/mob/user as mob)
		boutput(user, "The screen is clearly painted on. When you press Scan, a short metal spike extends from the top and sparks brightly before retracting again.")

/obj/machinery/oreaccumulator
	name = "mineral accumulator"
	desc = "A powerful device for quick ore and salvage collection and movement."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gravgen-off"
	density = 1
	opacity = 0
	anchored = 0
	var/active = 0
	var/obj/item/cell/cell = null
	var/target = null
	var/group = null

	New()
		var/obj/item/cell/P = new/obj/item/cell(src)
		P.charge = P.maxcharge
		src.cell = P
		..()

	attack_hand(var/mob/user)
		if (!src.cell) boutput(user, "<span class='alert'>It won't work without a power cell!</span>")
		else
			var/action = tgui_input_list(user, "What do you want to do?", "Mineral Accumulator", list("Flip the power switch","Change the destination","Remove the power cell"))
			if (action == "Remove the power cell")
				var/obj/item/cell/PCEL = src.cell
				user.put_in_hand_or_drop(PCEL)
				boutput(user, "You remove [cell].")
				if (PCEL) //ZeWaka: fix for null.updateicon
					PCEL.UpdateIcon()

				src.cell = null
			else if (action == "Change the destination")
				src.change_dest(user)
			else if (action == "Flip the power switch")
				if (!src.active)
					user.visible_message("[user] powers up [src].", "You power up [src].")
					src.active = 1
					src.anchored = 1
					icon_state = "gravgen-on"
				else
					user.visible_message("[user] shuts down [src].", "You shut down [src].")
					src.active = 0
					src.anchored = 0
					icon_state = "gravgen-off"
			else
				user.visible_message("[user] stares at [src] in confusion!", "You're not sure what that did.")

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/cell/))
			if (src.cell) boutput(user, "<span class='alert'>It already has a power cell inserted!</span>")
			else
				user.drop_item()
				W.set_loc(src)
				cell = W
				user.visible_message("[user] inserts [W] into [src].", "You insert [W] into [src].")
		else ..()

	process()
		var/moved = 0
		if (src.active)
			if (!src.cell)
				src.visible_message("<span class='alert'>[src] instantly shuts itself down.</span>")
				src.active = 0
				src.anchored = 0
				icon_state = "gravgen-off"
				return
			var/obj/item/cell/PCEL = src.cell
			if (PCEL.charge <= 0)
				src.visible_message("<span class='alert'>[src] runs out of power and shuts down.</span>")
				src.active = 0
				src.anchored = 0
				icon_state = "gravgen-off"
				return
			PCEL.charge -= 5
			if (src.target)
				for(var/obj/item/raw_material/O in orange(1,src))
					if (istype(O,/obj/item/raw_material/rock)) continue
					PCEL.charge -= 2
					O.set_loc(src.target)
				for(var/obj/item/scrap/S in orange(1,src))
					PCEL.charge -= 2
					S.set_loc(src.target)
				for(var/obj/decal/cleanable/machine_debris/D in orange(1,src))
					PCEL.charge -= 2
					D.set_loc(src.target)
				for(var/obj/decal/cleanable/robot_debris/R in orange(1,src))
					PCEL.charge -= 2
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
			boutput(user, "<span class='alert'>No receivers available.</span>")
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
				boutput(user, "<span class='alert'>Target not set!</span>")
				return
			boutput(user, "Target set to [selection] at [T.loc].")
			src.target = T

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

/// Basically a list wrapper that removes and adds cargo pads to a global list when it recieves the respective signals
/datum/cargo_pad_manager
	var/list/pads = list()

	New()
		..()
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CARGO_PAD_ENABLED, .proc/add_pad)
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CARGO_PAD_DISABLED, .proc/remove_pad)

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

/obj/submachine/cargopad
	name = "Cargo Pad"
	desc = "Used to receive objects transported by a cargo transporter."
	icon = 'icons/obj/objects.dmi'
	icon_state = "cargopad"
	anchored = TRUE
	plane = PLANE_FLOOR
	mats = 10 //I don't see the harm in re-adding this. -ZeWaka
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
			UpdateOverlays(image('icons/obj/objects.dmi', "cpad-rec"), "lights")
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
		if (src.active == 1)
			boutput(user, "<span class='notice'>You switch the receiver off.</span>")
			UpdateOverlays(null, "lights")
			src.active = FALSE
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_DISABLED, src)
		else
			boutput(user, "<span class='notice'>You switch the receiver on.</span>")
			UpdateOverlays(image('icons/obj/objects.dmi', "cpad-rec"), "lights")
			src.active = TRUE
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_ENABLED, src)

	proc/receive_cargo(var/obj/cargo)
		if (!src.mailgroup)
			return
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(src.mailgroup), "sender"="00000000", "message"="Notification: Incoming delivery to [src.name].")
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)

// satchels -> obj/item/satchel.dm

/obj/item/ore_scoop
	name = "ore scoop"
	desc = "A device that sucks up ore into a satchel automatically. Just load in a satchel and walk over ore to scoop it up."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "scoop"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "buildpipe"
	w_class = W_CLASS_SMALL
	mats = 6
	var/obj/item/satchel/mining/satchel = null

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
				if (satchel)
					user.put_in_hand_or_drop(satchel)
				S.set_loc(src)
				satchel = S
				icon_state = "scoop-bag"
				user.visible_message("[user] inserts [S] into [src].", "You insert [S] into [src].")
			else
				boutput(user, "<span class='alert'>The satchel is firmly secured to the scoop.</span>")
		else
			..()
			return

	attack_self(var/mob/user as mob)
		if(!issilicon(user))
			if (satchel)
				user.visible_message("[user] unloads [satchel] from [src].", "You unload [satchel] from [src].")
				user.put_in_hand_or_drop(satchel)
				satchel = null
				icon_state = "scoop"
			else
				boutput(user, "<span class='alert'>There's no satchel in [src] to unload.</span>")
		else
			boutput(user, "<span class='alert'>The satchel is firmly secured to the scoop.</span>")

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if(isturf(target))
			if (!satchel)
				boutput(user, "<span class='alert'>There's no satchel in [src] to dump out.</span>")
				return
			if (satchel.contents.len < 1)
				boutput(user, "<span class='alert'>The satchel in [src] is empty.</span>")
				return
			user.visible_message("[user] dumps out [src]'s satchel contents.", "You dump out [src]'s satchel contents.")
			for (var/obj/item/I in satchel.contents)
				I.set_loc(target)
			satchel.UpdateIcon()
			return
		if (istype(target, /obj/item/satchel/mining))
			user.swap_hand() //Needed so you don't drop the scoop instead of the satchel
			src.attackby(target, user)
			user.swap_hand()

////// Shit that goes in the asteroid belt, might split it into an exploring.dm later i guess

/turf/simulated/wall/ancient
	name = "strange wall"
	desc = "A weird jet black metal wall indented with strange grooves and lines."
	icon_state = "ancient"

	attackby(obj/item/W, mob/user)
		boutput(user, "<span class='combat'>You attack [src] with [W] but fail to even make a dent!</span>")
		return

	ex_act(severity)
		if (severity == 1.0)
			if (prob(8))
				src.RL_SetOpacity(0)
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
		boutput(user, "<span class='combat'>You attack [src] with [W] but fail to even make a dent!</span>")
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
		boutput(user, "<span class='combat'>You attack [src] with [W] but fail to even make a dent!</span>")
		return

	ex_act(severity)
		return
