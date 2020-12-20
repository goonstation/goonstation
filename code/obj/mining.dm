// Magnet Stuff

/obj/machinery/magnet_chassis
	name = "magnet chassis"
	desc = "A strong metal rig designed to hold and link up magnet apparatus with other technology."
	icon = 'icons/obj/64x64.dmi'
	icon_state = "chassis"
	opacity = 0
	density = 1
	anchored = 1
	var/obj/machinery/mining_magnet/linked_magnet = null

	New()
		..()
		SPAWN_DBG(0)
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

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/magnet_parts))
			if (istype(src.linked_magnet))
				boutput(user, "<span class='alert'>There's already a magnet installed.</span>")
				return
			user.visible_message("<b>[user]</b> begins constructing a new magnet.")
			var/turf/T = get_turf(user)
			sleep(24 SECONDS)
			if (user.loc == T && user.equipped() == W && !user.stat)
				var/obj/magnet = new W:constructed_magnet(get_turf(src))
				magnet.set_dir(src.dir)
				qdel(W)
		else
			..()

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

/obj/magnet_target_marker
	name = "mineral magnet target"
	desc = "Marks the location of an area of asteroid magnetting."
	invisibility = 101
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
			T.overlays.len = 0
			if (!istype(T, /turf/space))
				new /turf/space(T)

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
		var/turf/origin = get_turf(src)
		for (var/turf/T in block(locate(origin.x - 1, origin.y - 1, origin.z), locate(origin.x + width, origin.y + height, origin.z)))
			var/mob/M = locate() in T //living
			if (M)
				return 1
			var/obj/machinery/vehicle/V = locate() in T
			if (V)
				return 1
		return 0

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

	proc/construct()
		var/turf/origin = get_turf(src)
		for (var/turf/T in block(origin, locate(origin.x + width - 1, origin.y + height - 1, origin.z)))
			if (!T)
				boutput(usr, "<span class='alert'>Error: magnet area spans over construction area bounds.</span>")
				return 0
			if (!istype(T, /turf/space) && !istype(T, /turf/simulated/floor/plating/airless/asteroid) && !istype(T, /turf/simulated/wall/asteroid))
				boutput(usr, "<span class='alert'>Error: [T] detected in [width]x[height] magnet area. Cannot magnetize.</span>")
				return 0

		var/borders = list()
		for (var/cx = origin.x - 1, cx <= origin.x + width, cx++)
			var/turf/S = locate(cx, origin.y - 1, origin.z)
			if (!S || istype(S, /turf/space))
				boutput(usr, "<span class='alert'>Error: bordering tile has a gap, cannot magnetize area.</span>")
				return 0
			borders += S
			S = locate(cx, origin.y + height, origin.z)
			if (!S || istype(S, /turf/space))
				boutput(usr, "<span class='alert'>Error: bordering tile has a gap, cannot magnetize area.</span>")
				return 0
			borders += S

		for (var/cy = origin.y, cy <= origin.y + height - 1, cy++)
			var/turf/S = locate(origin.x - 1, cy, origin.z)
			if (!S || istype(S, /turf/space))
				boutput(usr, "<span class='alert'>Error: bordering tile has a gap, cannot magnetize area.</span>")
				return 0
			borders += S
			S = locate(origin.x + width, cy, origin.z)
			if (!S || istype(S, /turf/space))
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

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/raw_material/plasmastone) && !loaded)
			loaded = 1
			boutput(user, "<span class='notice'>You charge the magnetizer with the plasmastone.</span>")
			pool(W)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (!magnet)
			if (istype(target, /obj/machinery/magnet_chassis))
				magnet = target:linked_magnet
			else
				magnet = target
			if (!istype(magnet))
				magnet = null
			else
				if (!loaded)
					boutput(user, "<span class='alert'>The magnetizer needs to be loaded with a plasmastone chunk first.</span>")
					magnet = null
				else if (magnet.target)
					boutput(user, "<span class='alert'>That magnet is already locked onto a location.</span>")
					magnet = null
				else
					boutput(user, "<span class='notice'>Magnet locked. Designate lower left tile of target area (excluding the borders).</span>")
		else if (istype(target, /turf/space) && magnet)
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
			var/dist = min(min(get_dist(A, O), get_dist(B, O)), min(get_dist(C, O), get_dist(D, O)))
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
	icon = 'icons/obj/64x64.dmi'
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
	var/automatic_mode = 0
	var/auto_delay = 100
	var/last_delay = 0
	var/cooldown_override = 0
	var/malfunctioning = 0
	var/rarity_mod = 0

	var/uses_global_controls = TRUE

	var/image/active_overlay = null
	var/list/damage_overlays = list()
	var/sound_activate = 'sound/machines/ArtifactAnc1.ogg'
	var/sound_destroyed = 'sound/impact_sounds/Machinery_Break_1.ogg'
	var/obj/machinery/power/apc/mining_apc = null

	proc/get_magnetic_center()
		return mining_controls.magnetic_center

	proc/get_scan_range()
		return 6

	proc/check_for_unacceptable_content()
		return mining_controls.magnet_area.check_for_unacceptable_content()

	construction
		var/marker_type = /obj/magnet_target_marker
		var/obj/magnet_target_marker/target = null
		var/list/wall_bits = list()
		uses_global_controls = FALSE

		get_magnetic_center()
			if (target)
				return target.magnetic_center
			return null

		get_scan_range()
			if (target)
				return target.scan_range
			return 0

		check_for_unacceptable_content()
			if (target)
				return target.check_for_unacceptable_content()
			return 1

		New()
			..()
			if (mining_apc)
				mining_apc = null // Don't want random apcs across the map going haywire.

		process()
			if (!target)
				return
			if (automatic_mode && last_used < world.time && last_delay < world.time)
				if (target.check_for_unacceptable_content())
					last_delay = world.time + auto_delay
					return
				else
					SPAWN_DBG(0)
						pull_new_source()

		proc/get_encounter(var/rarity_mod)
			return mining_controls.select_encounter(rarity_mod)

		pull_new_source()
			if (!target)
				return

			if (!wall_bits.len)
				wall_bits = target.generate_walls()

			for (var/obj/forcefield/mining/M in wall_bits)
				M.opacity = 1
				M.set_density(1)
				M.invisibility = 0

			active = 1

			if (last_used > world.time)
				damage(rand(2,6))

			last_used = world.time + cooldown_time
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

			var/datum/mining_encounter/MC = get_encounter(rarity_mod)
			MC.generate(target)

			sleep(sleep_time)
			if (malfunctioning && prob(20))
				do_malfunction()

			active = 0
			build_icon()

			for (var/obj/forcefield/mining/M in wall_bits)
				M.opacity = 0
				M.set_density(0)
				M.invisibility = 101

			src.updateUsrDialog()
			return

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
		SPAWN_DBG(0)
			for (var/obj/machinery/magnet_chassis/MC in range(1,src))
				linked_chassis = MC
				MC.linked_magnet = src
				break

			for (var/obj/machinery/power/apc/APC in range(20,src))
				var/area/the_area = get_area(APC)
				if (the_area.type == /area/station/quartermaster/magnet)
					mining_apc = APC
					break

	process()
		..()
		if (automatic_mode && last_used < world.time && last_delay < world.time)
			if (mining_controls.magnet_area.check_for_unacceptable_content())
				last_delay = world.time + auto_delay
				return
			else
				SPAWN_DBG(0) //Did you know that if you sleep directly in process() you are the old lady at the mall who only pays in quarters.
					//Do not be quarter lady.
					pull_new_source()

	disposing()
		src.visible_message("<b>[src] breaks apart!</b>")
		robogibs(src.loc,null)
		playsound(src.loc, src.sound_destroyed, 50, 2)
		overlays = list()
		damage_overlays = list()
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

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.active)
			boutput(user, "<span class='alert'>It's way too dangerous to do that while it's active!</span>")
			return

		if (isweldingtool(W))
			if (src.health < 50)
				boutput(usr, "<span class='alert'>You need to use wire to fix the cabling first.</span>")
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
				boutput(usr, "<span class='alert'>The cabling looks fine. Use a welder to repair the rest of the damage.</span>")
				return
			C.use(1)
			src.damage(-10)
			user.visible_message("<b>[user]</b> uses [C] to repair some of [src]'s cabling.")
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
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
		src.overlays = list()

		if (damage_overlays.len == 4)
			switch(src.health)
				if (70 to 94)
					src.overlays += damage_overlays[1]
				if (40 to 69)
					src.overlays += damage_overlays[2]
				if (10 to 39)
					src.overlays += damage_overlays[3]
				if (-INFINITY to 10)
					src.overlays += damage_overlays[4]

		if (src.active)
			src.overlays += src.active_overlay

	proc/damage(var/amount)
		if (!isnum(amount))
			return

		src.health -= amount
		src.health = max(0,min(src.health,100))

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
				playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
				src.damage(rand(5,10))
			if (2)
				if (istype(mining_apc))
					mining_apc.visible_message("<b>Magnetic feedback causes [mining_apc] to go haywire!</b>")
					mining_apc.zapStuff()

	proc/pull_new_source(var/selectable_encounter_id = null)
		for (var/obj/forcefield/mining/M in mining_controls.magnet_shields)
			M.opacity = 1
			M.set_density(1)
			M.invisibility = 0

		active = 1

		if (last_used > world.time)
			damage(rand(2,6))

		last_used = world.time + cooldown_time
		playsound(src.loc, sound_activate, 100, 0, 3, 0.25)
		build_icon()

		for (var/obj/O in mining_controls.magnet_area.contents)
			if (!(O.type in mining_controls.magnet_do_not_erase))
				qdel(O)
		for (var/turf/simulated/T in mining_controls.magnet_area.contents)
			if (!istype(T,/turf/simulated/floor/airless/plating/catwalk/))
				T.ReplaceWithSpace()
				//qdel(T)
		for (var/turf/space/S in mining_controls.magnet_area.contents)
			S.overlays = list()

		var/sleep_time = attract_time
		if (sleep_time < 1)
			sleep_time = 20
		sleep_time /= 2

		if (malfunctioning && prob(20))
			do_malfunction()
		sleep(sleep_time)

		var/datum/mining_encounter/MC

		if(selectable_encounter_id != null)
			if(mining_controls.mining_encounters_selectable.Find(selectable_encounter_id))
				MC = mining_controls.mining_encounters_selectable[selectable_encounter_id]
				mining_controls.remove_selectable_encounter(selectable_encounter_id)
			else
				boutput(usr, "Uh oh, something's gotten really fucked up with the magnet system. Please report this to a coder! (ERROR: INVALID ENCOUNTER)")
				MC = mining_controls.select_encounter(rarity_mod)
		else
			MC = mining_controls.select_encounter(rarity_mod)

		if(MC)
			MC.generate(null)
		else
			for (var/obj/forcefield/mining/M in mining_controls.magnet_shields)
				M.opacity = 0
				M.set_density(0)
				M.invisibility = 1
			active = 0
			boutput(usr, "Uh oh, something's gotten really fucked up with the magnet system. Please report this to a coder! (ERROR: NO ENCOUNTER)")
			return

		sleep(sleep_time)
		if (malfunctioning && prob(20))
			do_malfunction()

		active = 0
		build_icon()

		for (var/obj/forcefield/mining/M in mining_controls.magnet_shields)
			M.opacity = 0
			M.set_density(0)
			M.invisibility = 101

		src.updateUsrDialog()
		return

	proc/generate_interface(var/mob/user as mob)
		src.add_dialog(user)

		var/dat = "<BR><B>Magnet Status:</B><BR>"
		dat += "<u>Condition:</u> "
		switch(src.health)
			if (95 to INFINITY)
				dat += "Optimal"
			if (70 to 94)
				dat += "Mild Structural Damage"
			if (40 to 69)
				dat += "Heavy Structural Damage"
			if (10 to 39)
				dat += "Extreme Structural Damage"
			if (-INFINITY to 10)
				dat += "Destruction Imminent"

		dat += "<br><u>Status:</u> "
		if (src.active)
			dat += "Pulling New Mineral Source"
		else
			if (src.last_used > world.time)
				dat += "Cooling Down: Ready in T-[max(0,round((src.last_used - world.time) / 10))]"
				if (src.cooldown_override)
					dat += "<br><i>Cooldown Override Engaged</i>"
			else
				dat += "Idle"

		dat += "<BR><HR>"
		if (src.active)
			dat += "Magnet Active<BR>"
		else
			if (src.last_used > world.time)
				if (src.cooldown_override)
					dat += "<A href='?src=\ref[src];activate_magnet=1'>Activate Magnet</A> (On Cooldown!)<BR>"
					if(mining_controls.mining_encounters_selectable.len > 0)
						dat += "<A href='?src=\ref[src];show_selectable=1'>Activate telescope location</A>  (On Cooldown!)<BR>"
				else
					dat += "Magnet Cooling Down<BR>"
			else
				dat += "<A href='?src=\ref[src];activate_magnet=1'>Activate Magnet</A><BR>"
				if(mining_controls.mining_encounters_selectable.len > 0)
					dat += "<A href='?src=\ref[src];show_selectable=1'>Activate telescope location</A><BR>"


			dat += "<A href='?src=\ref[src];geo_scan=1'>Scan Mining Area</A><BR>"

		var/auto_mode = "Enable Automatic Mode"
		if (src.automatic_mode)
			auto_mode = "Disable Automatic Mode"
		dat += "<A href='?src=\ref[src];auto_mode=1'>[auto_mode]</A><BR>"

		var/override_text = "Override Cooldown"
		if (src.cooldown_override)
			override_text = "Disable Cooldown Override"
		dat += "<A href='?src=\ref[src];override_cooldown=1'>[override_text]</A><BR>"
		dat += "<BR><A href='?action=mach_close&window=computer'>Close</A>"
		usr.Browse(dat, "window=computer;size=300x400")
		onclose(usr, "computer")
		return null

	Topic(href, href_list)
		if(status & (NOPOWER|BROKEN))
			boutput(usr, "<span class='alert'>That machine is not powered.</span>")
			return 1
		if(usr.restrained() || usr.lying || usr.stat)
			boutput(usr, "<span class='alert'>You are currently unable to do that.</span>")
			return 1

		var/rangecheck = 0
		if (issilicon(usr))
			rangecheck = 1
		if (istype(usr.loc,/obj/machinery/vehicle/))
			var/obj/machinery/vehicle/V = usr.loc
			if (istype(V.com_system,/obj/item/shipcomponent/communications/mining) && V.com_system.active)
				rangecheck = 1
		for(var/obj/machinery/computer/magnet/M in range(usr,1))
			rangecheck = 1
			break

		if (!rangecheck)
			boutput(usr, "<span class='alert'>You aren't in range of the controls.</span>")
			return
		src.add_dialog(usr)

		if (!istype(src))
			boutput(usr, "Error. Magnet not detected.")
			src.updateUsrDialog()
			return

		else if (href_list["back"])
			src.generate_interface(usr)

		else if (href_list["show_selectable"])
			if (src.uses_global_controls && !istype(mining_controls.magnet_area))
				boutput(usr, "Uh oh, something's gotten really fucked up with the magnet system. Please report this to a coder!")
				return

			var/html = ""
			for(var/X in mining_controls.mining_encounters_selectable)
				var/datum/mining_encounter/E = mining_controls.mining_encounters_selectable[X]
				if(istype(E))
					html += "<A href='?src=\ref[src];activate_selectable=[X]'>[E.name]</A><BR>"

			html += "<BR><A href='?src=\ref[src];back=1'>Back</A><BR>"
			usr.Browse(html, "window=computer;size=300x400")
			onclose(usr, "computer")
			return

		else if (href_list["activate_selectable"])
			if (src.uses_global_controls && !istype(mining_controls.magnet_area))
				boutput(usr, "Uh oh, something's gotten really fucked up with the magnet system. Please report this to a coder!")
				return

			if (src.check_for_unacceptable_content())
				src.visible_message("<b>[src.name]</b> states, \"Safety lock engaged. Please remove all personnel and vehicles from the magnet area.\"")
			else
				SPAWN_DBG(0)
					if (src) src.pull_new_source(href_list["activate_selectable"])

		else if (href_list["activate_magnet"])
			if (src.uses_global_controls && !istype(mining_controls.magnet_area))
				boutput(usr, "Uh oh, something's gotten really fucked up with the magnet system. Please report this to a coder!")
				return

			if (src.check_for_unacceptable_content())
				src.visible_message("<b>[src.name]</b> states, \"Safety lock engaged. Please remove all personnel and vehicles from the magnet area.\"")
			else
				SPAWN_DBG(0)
					if (src) src.pull_new_source()

		else if (href_list["override_cooldown"])
			if (!ishuman(usr))
				boutput(usr, "<span class='alert'>AI and robotic personnel may not access the override.</span>")
			else
				var/mob/living/carbon/human/H = usr
				if(!src.allowed(H))
					boutput(usr, "<span class='alert'>Access denied. Please contact the Chief Engineer or Captain to access the override.</span>")
				else
					src.cooldown_override = !src.cooldown_override

		else if (href_list["auto_mode"])
			src.automatic_mode = !src.automatic_mode

		else if (href_list["geo_scan"])
			var/MC = src.get_magnetic_center()
			if (!MC)
				boutput(usr, "Error. Magnet is not magnetized.")
				src.updateUsrDialog()
				return

			mining_scan(MC, usr, src.get_scan_range())

		src.generate_interface(usr)
		return

/obj/machinery/computer/magnet
	name = "mineral magnet controls"
	icon = 'icons/obj/computer.dmi'
	icon_state = "mmagnet"
	var/temp = null
	var/list/linked_magnets = list()
	var/obj/machinery/mining_magnet/linked_magnet = null
	req_access = list(access_engineering_chief)
	object_flags = CAN_REPROGRAM_ACCESS

	New()
		..()
		SPAWN_DBG(0)
			src.connection_scan()

	attackby(obj/item/I as obj, mob/user as mob)
		if (isscrewingtool(I))
			playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
			if (do_after(user, 2 SECONDS))
				if (src.status & BROKEN)
					user.show_text("The broken glass falls out.", "blue")
					var/obj/computerframe/A = new /obj/computerframe(src.loc)
					if (src.material)
						A.setMaterial(src.material)
					var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
					G.set_loc(src.loc)
					var/obj/item/circuitboard/mining_magnet/M = new /obj/item/circuitboard/mining_magnet(A)
					for (var/obj/C in src)
						C.set_loc(src.loc)
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					qdel(src)
				else
					user.show_text("You disconnect the monitor.", "blue")
					var/obj/computerframe/A = new /obj/computerframe(src.loc)
					if (src.material)
						A.setMaterial(src.material)
					var/obj/item/circuitboard/mining_magnet/M = new /obj/item/circuitboard/mining_magnet(A)
					for (var/obj/C in src)
						C.set_loc(src.loc)
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					qdel(src)
		else
			src.attack_hand(user)
		return

	attack_hand(var/mob/user as mob)
		if(..())
			return
		if (istype(linked_magnet))
			linked_magnet.generate_interface(user)
		else
			src.add_dialog(user)
			var/dat = "<B>Mineral Mining Magnet Terminal</B><HR>"
			dat += "<A href='?src=\ref[src];scan_for_connection=1'>Scan for Magnets</A><BR><BR>"
			dat += "<B>Choose linked magnet:</B><BR>"
			for (var/obj/M in linked_magnets)
				dat += "<a href='?src=\ref[src];choosemagnet=\ref[M]'>[M] at ([M.x], [M.y])</a><BR>"
			dat += "<BR><B>Selected magnet:</B><BR>"
			if (linked_magnet)
				dat += "[linked_magnet] at ([linked_magnet.x], [linked_magnet.y])<BR>"
			else
				dat += "None<BR>"

			//dat += "<BR><a href='?src=\ref[src];unlink=1'>Disconnect Terminal from Magnet</a>"

			dat += "<BR><A href='?action=mach_close&window=computer'>Close</A>"
			user.Browse(dat, "window=computer;size=300x400")
			onclose(user, "computer")
		return

	Topic(href, href_list)
		if(..())
			return

		if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
			src.add_dialog(usr)

		src.add_fingerprint(usr)

		if (href_list["choosemagnet"])
			linked_magnet = locate(href_list["choosemagnet"])
			if (!linked_magnet)
				linked_magnet = null
				src.visible_message("<b>[src.name]</b> states, \"Designated magnet is no longer operational.\"")

		else if (href_list["scan_for_connection"])
			switch(src.connection_scan())
				if(1)
					src.visible_message("<b>[src.name]</b> states, \"Unoccupied Magnet Chassis located. Please connect magnet system to chassis.\"")
				if(2)
					src.visible_message("<b>[src.name]</b> states, \"Magnet equipment not found within range.\"")
				else
					src.visible_message("<b>[src.name]</b> states, \"Magnet equipment located. Link established.\"")

		else if (href_list["unlink"])
			src.linked_magnet = null

		src.updateUsrDialog()
		return

	proc/connection_scan()
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

/turf/simulated/wall/asteroid
	name = "asteroid"
	desc = "A free-floating mineral deposit from space."
	icon = 'icons/turf/asteroid.dmi'
	icon_state = "ast1"
	plane = PLANE_FLOOR
	var/stone_color = "#CCCCCC"

#ifdef UNDERWATER_MAP
	var/hardness = 1
#else
	var/hardness = 0
#endif

	var/weakened = 0
	var/amount = 2
	var/invincible = 0
	var/quality = 0
	var/default_ore = /obj/item/raw_material/rock
	var/datum/ore/ore = null
	var/datum/ore/event/event = null
	var/list/space_overlays = list()

	//NEW VARS
	var/mining_health = 120
	var/mining_max_health = 120
	var/mining_toughness = 1 //Incoming damage divided by this unless tool has power enough to overcome.

#ifdef UNDERWATER_MAP
	fullbright = 0
	luminosity = 1
#else
	fullbright = 1
#endif

	trench
		name = "cavern wall"
		desc = "A cavern wall, possibly flowing with mineral deposits."
		space_overlays()
			return
		build_icon()
			return

	dark
		fullbright = 0

	lighted
		fullbright = 1

	ice
		name = "comet chunk"
		desc = "That's some cold stuff right there."
		stone_color = "#D1E6FF"
		default_ore = /obj/item/raw_material/ice

	geode
		name = "compacted stone"
		desc = "This rock looks really hard to dig out."
		stone_color = "#575A5E"
		default_ore = null
		hardness = 10


// cogwerks - adding some new wall types for cometmap and whatever else

	comet
		fullbright = 0
		name = "regolith"
		desc = "It's dusty and cold."
		stone_color = "#95A1AF"
		icon_state = "comet"
		hardness = 1
		default_ore = /obj/item/raw_material/rock

		// varied layers

		ice
			name = "comet ice"
			icon_state = "comet_ice"
			stone_color = "#D1E6FF"
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



	New(var/loc,var/do_overlays_now = 1)
		src.icon_state = pick("ast1","ast2","ast3")
		..()
		if (do_overlays_now)
			src.space_overlays()

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.damage_asteroid(7)
			if(2.0)
				src.damage_asteroid(5)
			if(3.0)
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

	attack_hand(var/mob/user as mob)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.gloves, /obj/item/clothing/gloves/concussive))
				var/obj/item/clothing/gloves/concussive/C = H.gloves
				src.dig_asteroid(user,C.tool)
				return
			else if (H.is_hulk())
				H.visible_message("<span class='alert'><b>[H.name] punches [src] with great strength!</span>")
				playsound(H.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 100, 1)
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
				L.click(src, list(), null, null)
			return

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/mining_tool/))
			var/obj/item/mining_tool/T = W
			src.dig_asteroid(user,T)
			if (T.status)
				T.process_charges(T.digcost)

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

	proc/build_icon(var/wipe_overlays = 0)
		if (wipe_overlays)
			src.overlays = list()
		var/image/coloration = image(src.icon,"color_overlay")
		coloration.blend_mode = 4
		coloration.color = src.stone_color
		src.overlays += coloration

	proc/space_overlays()
		for (var/turf/space/A in orange(src,1))
			var/image/edge_overlay = image('icons/turf/asteroid.dmi', "edge[get_dir(A,src)]")
			edge_overlay.layer = src.layer + 1
			edge_overlay.color = src.stone_color
			A.overlays += edge_overlay
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
				dig_feedback = "This rock is very tough. You need a stronger tool."
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
		src.overlays += image('icons/turf/asteroid.dmi', "weakened")

	proc/damage_asteroid(var/power,var/allow_zero = 0)
		// use this for stuff that arent mining tools but still attack asteroids
		if (!isnum(power) || (power <= 0 && !allow_zero))
			return
		var/difference = ((src.hardness < 1) ? round(src.hardness) : src.hardness) - power //If less than 1, round to 0

		if (src.ore)
			src.ore.onHit(src)

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
				var/obj/item/raw_material/MAT = unpool(ore_to_create)
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
		src.opacity = 0
		src.levelupdate()

		for (var/turf/simulated/floor/plating/airless/asteroid/A in range(src,1))
			A.update_icon()
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
			for (var/turf/simulated/wall/asteroid/AST in range(E.distribution_range,src))
				if (!isnull(AST.event))
					continue
				usable_turfs += AST

			var/turf/simulated/wall/asteroid/AST
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
	icon = 'icons/turf/asteroid.dmi'
	icon_state = "astfloor1"
	plane = PLANE_FLOOR //Try to get the edge overlays to work with shadowing. I dare ya.
	oxygen = 0.001
	nitrogen = 0.001
	temperature = TCMB
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	var/sprite_variation = 1
	var/stone_color = null
	var/image/coloration_overlay = null
	var/list/space_overlays = list()
	turf_flags = MOB_SLIP | MOB_STEP | IS_TYPE_SIMULATED | FLUID_MOVE

#ifdef UNDERWATER_MAP
	fullbright = 0
	luminosity = 3
#else
	luminosity = 1
	fullbright = 1
#endif

	dark
		fullbright = 0
		luminosity = 0

	lighted
		fullbright = 1

	noborders
		update_icon()
			return
		apply_edge_overlay()
			return
		space_overlays()
			return

	New()
		..()
		src.sprite_variation = rand(1,3)
		icon_state = "astfloor" + "[sprite_variation]"
		coloration_overlay = image(src.icon,"color_overlay")
		coloration_overlay.blend_mode = 4
		update_icon()
		space_overlays()

	ex_act(severity)
		return

	proc/destroy_asteroid()
		return

	proc/damage_asteroid(var/power)
		return

	proc/weaken_asteroid()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(ispryingtool(W))
			src.ReplaceWithSpace()

	update_icon()
		src.overlays = list()
		if (!coloration_overlay)
			coloration_overlay = image(src.icon, "color_overlay")
		coloration_overlay.color = src.stone_color
		src.overlays += coloration_overlay
		SPAWN_DBG(1 DECI SECOND)
			if (istype(src)) //Wire note: just roll with this ok
				for (var/turf/simulated/wall/asteroid/A in orange(src,1))
					src.apply_edge_overlay(get_dir(src, A))
				for (var/turf/space/A in orange(src,1))
					src.apply_edge_overlay(get_dir(src, A))

				#ifdef UNDERWATER_MAP //FUCK THIS SHIT. NO FULLBRIGHT ON THE MINING LEVEL, I DONT CARE.
				if (z == AST_ZLEVEL) return
				#endif
				if (fullbright)
					src.overlays += /image/fullbright //Fixes perma-darkness

	proc/apply_edge_overlay(var/thedir) //For overlays ON THE FLOOR TILE
		var/image/dig_overlay = image('icons/turf/asteroid.dmi', "edge[thedir]")
		dig_overlay.color = src.stone_color
		//dig_overlay.layer = src.layer + 1
		src.overlays += dig_overlay

	proc/space_overlays() //For overlays ON THE SPACE TILE
		for (var/turf/space/A in orange(src,1))
			var/image/edge_overlay = image('icons/turf/asteroid.dmi', "edge[get_dir(A,src)]")
			//edge_overlay.layer = src.layer + 1
			edge_overlay.color = src.stone_color
			A.overlays += edge_overlay
			src.space_overlays += edge_overlay


// Tool Defines

/obj/item/mining_tool
	name = "pickaxe"
	desc = "A thing to bash rocks with until they become smaller rocks."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "pickaxe"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "pick"
	w_class = 3
	flags = ONBELT
	force = 7
	var/dig_strength = 1
	var/obj/item/ammo/power_cell/cell = null
	var/status = 0
	var/digcost = 0
	var/weakener = 0
	var/image/powered_overlay = null
	var/sound/hitsound_charged = 'sound/impact_sounds/Stone_Cut_1.ogg'
	var/sound/hitsound_uncharged = 'sound/impact_sounds/Stone_Cut_1.ogg'
	module_research = list("tools" = 3, "engineering" = 1, "mining" = 1)

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)

	// Seems like a basic bit of user feedback to me (Convair880).
	examine(mob/user)
		. = ..()
		if (!src.cell)
			return
		if (isrobot(user))
			return // Drains battery instead.
		. += "The [src.name] is turned [src.status ? "on" : "off"]. There are [src.cell.charge]/[src.cell.max_charge] PUs left!"

	proc/process_charges(var/use)
		if (!isnum(use) || use < 0)
			return 0
		if (cell.charge < 1)
			return 0
		src.cell.use(use)
		if (src.cell.charge == 0)
			src.power_down()
			var/turf/T = get_turf(src)
			T.visible_message("<span class='alert'>[src] runs out of charge and powers down!</span>")
		return 1

	afterattack(target as mob, mob/user as mob)
		..()
		if (src.status && !isturf(target))
			src.process_charges(digcost*5)

	proc/charge(var/amount)
		//Support for recharge stations. Increment uses by one until we reach max.
		if(src.cell)
			return src.cell.charge(amount)
		else//No cell, or not rechargeable. Tell anything trying to charge it.
			return -1

	proc/power_up()
		src.status = 1
		if (powered_overlay)
			src.overlays += powered_overlay
			signal_event("icon_updated")
		return

	proc/power_down()
		src.status = 0
		if (powered_overlay)
			src.overlays = null
			signal_event("icon_updated")
		return

	attackby(obj/item/b as obj, mob/user as mob)
		if (istype(b, /obj/item/ammo/power_cell/))
			var/obj/item/ammo/power_cell/pcell = b
			if (src.cell)
				if (pcell.swap(src))
					user.visible_message("<span class='alert'>[user] swaps [src]'s power cell.</span>")
		else
			..()

	proc/update_icon()
		return
obj/item/clothing/gloves/concussive
	name = "concussion gauntlets"
	desc = "These gloves enable miners to punch through solid rock with their hands instead of using tools."
	icon_state = "cgaunts"
	item_state = "bgloves"
	material_prints = "industrial-grade mineral fibers"
	var/obj/item/mining_tool/tool = null

	New()
		..()
		var/obj/item/mining_tool/T = new /obj/item/mining_tool(src)
		src.tool = T
		T.name = src.name
		T.desc = src.desc
		T.dig_strength = 4
		T.hitsound_charged = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
		T.hitsound_uncharged = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'

/obj/item/mining_tool/power_pick
	name = "power pick"
	desc = "An energised mining tool."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "powerpick"
	item_state = "ppick1"
	flags = ONBELT
	dig_strength = 2
	digcost = 2
	cell = new/obj/item/ammo/power_cell
	hitsound_charged = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
	hitsound_uncharged = 'sound/impact_sounds/Stone_Cut_1.ogg'
	module_research = list("tools" = 5, "engineering" = 2, "mining" = 3)

	New()
		..()
		powered_overlay = image('icons/obj/items/mining.dmi', "pp-glow")
		src.power_up()

	attack_self(var/mob/user as mob)
		tooltip_rebuild = 1
		if (src.process_charges(0))
			if (!src.status)
				boutput(user, "<span class='notice'>You power up [src].</span>")
				src.power_up()
				item_state = "ppick1"
				user.update_inhands()
				playsound(user.loc, "sound/items/miningtool_on.ogg", 50, 1)
			else
				boutput(user, "<span class='notice'>You power down [src].</span>")
				src.power_down()
				item_state = "ppick0"
				user.update_inhands()
				playsound(user.loc, "sound/items/miningtool_off.ogg", 50, 1)
		else
			boutput(user, "<span class='alert'>No charge left in [src].</span>")


	power_up()
		..()
		src.force = 15
		src.dig_strength = 2

	power_down()
		..()
		src.force = 7
		src.dig_strength = 1


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
	module_research = list("tools" = 5, "engineering" = 3, "mining" = 5)

/obj/item/mining_tool/powerhammer
	name = "power hammer"
	desc = "An energised mining tool."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "powerhammer"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "phammer1"
	cell = new/obj/item/ammo/power_cell
	force = 9
	dig_strength = 3
	digcost = 3
	hitsound_charged = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
	hitsound_uncharged = 'sound/impact_sounds/Stone_Cut_1.ogg'
	module_research = list("tools" = 5, "engineering" = 1, "mining" = 5)

	New()
		..()
		src.powered_overlay = image('icons/obj/items/mining.dmi', "ph-glow")
		src.power_up()

	power_up()
		..()
		src.force = 20
		dig_strength = 3
		weakener = 1
		src.setItemSpecial(/datum/item_special/slam)

	power_down()
		..()
		src.force = 9
		dig_strength = 1
		weakener = 0
		src.setItemSpecial(/datum/item_special/simple)

	attack_self(var/mob/user as mob)
		tooltip_rebuild = 1
		if (src.process_charges(0))
			if (!src.status)
				boutput(user, "<span class='notice'>You power up [src].</span>")
				src.power_up()
				item_state = "phammer1"
				user.update_inhands()
				playsound(user.loc, "sound/items/miningtool_on.ogg", 50, 1)
			else
				boutput(user, "<span class='notice'>You power down [src].</span>")
				src.power_down()
				item_state = "phammer0"
				user.update_inhands()
				playsound(user.loc, "sound/items/miningtool_off.ogg", 50, 1)
		else
			boutput(user, "<span class='alert'>No charge left in [src].</span>")

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
	cell = new/obj/item/ammo/power_cell
	hitsound_charged = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
	hitsound_uncharged = 'sound/impact_sounds/Stone_Cut_1.ogg'
	module_research = list("tools" = 5, "engineering" = 2, "mining" = 3)

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		powered_overlay = image('icons/obj/sealab_power.dmi', "ps-glow")
		src.power_up()

	attack_self(var/mob/user as mob)
		tooltip_rebuild = 1
		if (src.process_charges(0))
			if (!src.status)
				boutput(user, "<span class='notice'>You power up [src].</span>")
				src.power_up()
				item_state = "pshovel1"
				user.update_inhands()
				playsound(user.loc, "sound/items/miningtool_on.ogg", 50, 1)
			else
				boutput(user, "<span class='notice'>You power down [src].</span>")
				src.power_down()
				item_state = "pshovel0"
				user.update_inhands()
				playsound(user.loc, "sound/items/miningtool_off.ogg", 50, 1)
		else
			boutput(user, "<span class='alert'>No charge left in [src].</span>")

	power_up()
		..()
		src.force = 8
		src.dig_strength = 0

	power_down()
		..()
		src.force = 4
		src.dig_strength = 0

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
	w_class = 1
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
					logTheThing("combat", user, null, "accidentally triggers [src] (clumsy bioeffect) at [log_loc(user)].")
					SPAWN_DBG(0.5 SECONDS)
						concussive_blast()
						qdel (src)
						return
				else
					if (istype(target, /turf/simulated/wall/asteroid/) && !src.hacked)
						boutput(user, "<span class='alert'>You slap the charge on [target], [det_time/10] seconds!</span>")
						user.visible_message("<span class='alert'>[user] has attached [src] to [target].</span>")
						src.icon_state = "bcharge2"
						user.drop_item()

						// Yes, please (Convair880).
						if (src?.hacked)
							logTheThing("combat", user, null, "attaches a hacked [src] to [target] at [log_loc(target)].")

						user.set_dir(get_dir(user, target))
						user.drop_item()
						var/t = (isturf(target) ? target : target.loc)
						step_towards(src, t)

						SPAWN_DBG( src.det_time )
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

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/device/chargehacker))
			if(!src.emagged && !src.hacked)
				boutput(user, "<span class='notice'>You short out the attachment mechanism, removing its restrictions!</span>")
				src.desc += " It has been tampered with."
				src.hacked = 1
			else
				boutput(user, "<span class='alert'>This has already been tampered with.</span>")
		else ..()

	proc/concussive_blast()
		playsound(src.loc, "sound/weapons/flashbang.ogg", 50, 1)
		for (var/turf/simulated/wall/asteroid/A in range(src.expl_flash,src))
			if(get_dist(src,A) <= src.expl_heavy)
				A.damage_asteroid(4)
			if(get_dist(src,A) <= src.expl_light)
				A.damage_asteroid(3)
			if(get_dist(src,A) <= src.expl_flash)
				A.damage_asteroid(2)

		for(var/mob/living/carbon/C in range(src.expl_flash, src))
			if (!isdead(C) && C.client) shake_camera(C, 3, 2)
			if(get_dist(src,C) <= src.expl_light)
				C.changeStatus("stunned", 80)
				C.changeStatus("weakened", 10 SECONDS)
				C.stuttering += 15
				boutput(C, "<span class='alert'>The concussive blast knocks you off your feet!</span>")
			if(get_dist(src,C) <= src.expl_heavy)
				C.TakeDamage("All",rand(15,25)*(1-C.get_explosion_resistance()),0)
				boutput(C, "<span class='alert'>You are battered by the concussive shockwave!</span>")

/obj/item/cargotele
	name = "cargo transporter"
	desc = "A device for teleporting crated goods."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "cargotele"
	var/charges = 8
	var/maximum_charges = 8
	var/robocharge = 250
	var/target = null
	w_class = 2
	flags = ONBELT
	mats = 4

	examine(mob/user)
		. = ..()
		if (isrobot(user))
			return // Drains battery instead.
		. += "There are [src.charges]/[src.maximum_charges] charges left!"

	attack_self() // Fixed --melon
		if (src.charges < 1)
			boutput(usr, "<span class='alert'>The transporter is out of charge.</span>")
			return
		if (!cargopads.len) boutput(usr, "<span class='alert'>No receivers available.</span>")
		else
		//here i set up an empty var that can take any object, and tell it to look for absolutely anything in the list
			var/selection = input("Select Cargo Pad Location:", "Cargo Pads", null, null) as null|anything in cargopads
			if(!selection)
				return
			var/turf/T = get_turf(selection)
			//get the turf of the pad itself
			if (!T)
				boutput(usr, "<span class='alert'>Target not set!</span>")
				return
			boutput(usr, "Target set to [T.loc].")
			//blammo! works!
			src.target = T

	proc/charge(var/amount)
		//Support for recharge stations. Increment uses by one until we reach max.
		src.charges = src.charges + 1 > src.maximum_charges ? src.maximum_charges : src.charges + 1

		//Return if we are finished charging or not to the recharger
		return src.charges < src.maximum_charges

	proc/cargoteleport(var/obj/T, var/mob/user)
		if (!src.target)
			boutput(user, "<span class='alert'>You need to set a target first!</span>")
			return
		if (src.charges < 1)
			boutput(user, "<span class='alert'>The transporter is out of charge.</span>")
			return
		if (isrobot(user))
			var/mob/living/silicon/robot/R = user
			if (R.cell.charge < src.robocharge)
				boutput(user, "<span class='alert'>There is not enough charge left in your cell to use this.</span>")
				return

		// Why didn't you implement checks for these in the first place, sigh (Convair880).
		if (ismob(T.loc) && T.loc == user && issilicon(user))
			user.show_text("The [T.name] is securely bolted to your chassis.", "red")
			return

		boutput(user, "<span class='notice'>Teleporting [T]...</span>")
		playsound(user.loc, "sound/machines/click.ogg", 50, 1)

		if(do_after(user, 5 SECONDS))
			// And these too (Convair880).
			if (ismob(T.loc) && T.loc == user)
				user.u_equip(T)
			if (istype(T.loc, /obj/item/storage))
				var/obj/item/storage/S_temp = T.loc
				var/datum/hud/storage/H_temp = S_temp.hud
				H_temp.remove_object(T)

			// And logs for good measure (Convair880).
			var/is_locked = 0
			var/is_welded = 0
			if (istype(T, /obj/storage)) // Other containers (e.g. prison artifacts) can hold mobs too.
				var/obj/storage/S = T
				if (S.locked) is_locked = 1
				if (S.welded) is_welded = 1

			for (var/mob/M in T.contents)
				if (M)
					logTheThing("station", user, M, "uses a cargo transporter to send [T.name][is_locked ? " (locked)" : ""][is_welded ? " (welded)" : ""] with [constructTarget(M,"station")] inside to [log_loc(src.target)].")

			T.set_loc(src.target)
			elecflash(src)
			if (isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= src.robocharge
			else
				src.charges -= 1
				if (src.charges < 0)
					src.charges = 0
				if (src.charges == 0)
					boutput(user, "<span class='alert'>Transfer successful. The transporter is now out of charge.</span>")
				else
					boutput(user, "<span class='notice'>Transfer successful. [src.charges] charges remain.</span>")
		return

/obj/item/cargotele/traitor
	charges = 14
	maximum_charges = 14
	var/list/possible_targets = list()

	New()
		..()
		for(var/turf/T in world) //hate to do this but it's only once per spawn vOv
			LAGCHECK(LAG_LOW)
			if(istype(T,/turf/space) && T.z != 1 && !isrestrictedz(T.z))
				possible_targets += T

	attack_self() // Fixed --melon
		return

	cargoteleport(var/obj/T, var/mob/user)
		src.target = pick(src.possible_targets)
		if (!src.target)
			boutput(user, "<span class='alert'>No target found!</span>")
			return
		if (src.charges < 1)
			boutput(user, "<span class='alert'>The transporter is out of charge.</span>")
			return
		boutput(user, "<span class='notice'>Teleporting [T]...</span>")
		playsound(user.loc, "sound/machines/click.ogg", 50, 1)

		if(do_after(user, 5 SECONDS))

			// Logs for good measure (Convair880).
			for (var/mob/M in T.contents)
				if (M)
					logTheThing("station", user, M, "uses a Syndicate cargo transporter to send [T.name] with [constructTarget(M,"station")] inside to [log_loc(src.target)].")

			T.set_loc(src.target)
			if(hasvar(T, "welded")) T:welded = 1
			elecflash(src)
			src.charges -= 1
			if (src.charges < 0)
				src.charges = 0
			if (src.charges == 0)
				boutput(user, "<span class='alert'>Transfer successful. The transporter is now out of charge.</span>")
			else
				boutput(user, "<span class='notice'>Transfer successful. [src.charges] charges remain.</span>")
		return

/obj/item/oreprospector
	name = "geological scanner"
	desc = "A device capable of detecting nearby mineral deposits."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "minanal"
	flags = ONBELT
	w_class = 1.0

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
	for (var/turf/simulated/wall/asteroid/AST in range(T,range))
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
	var/image/O = image('icons/obj/items/mining.dmi',T,decalicon,AREA_LAYER+1)
	user << O
	SPAWN_DBG(2 MINUTES)
		if (user?.client)
			user.client.images -= O
			user.client.screen -= O
		qdel (O)
		O = null

///// MINER TRAITOR ITEM /////

/obj/item/device/chargehacker
	name = "geological scanner"
	desc = "The scanner doesn't look right somehow."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "minanal"
	flags = ONBELT
	w_class = 1.0

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
	var/cell = null
	var/target = null

	New()
		var/obj/item/cell/P = new/obj/item/cell(src)
		P.charge = P.maxcharge
		src.cell = P
		..()

	attack_hand(var/mob/user as mob)
		if (!src.cell) boutput(user, "<span class='alert'>It won't work without a power cell!</span>")
		else
			var/action = input("What do you want to do?", "Mineral Accumulator") in list("Flip the power switch","Change the destination","Remove the power cell")
			if (action == "Remove the power cell")
				var/obj/item/cell/PCEL = src.cell
				user.put_in_hand_or_drop(PCEL)
				boutput(user, "You remove [cell].")
				if (PCEL) //ZeWaka: fix for null.updateicon
					PCEL.updateicon()

				src.cell = null
			else if (action == "Change the destination")
				if (!cargopads.len) boutput(usr, "<span class='alert'>No receivers available.</span>")
				else
					var/selection = input("Select Cargo Pad Location:", "Cargo Pads", null, null) as null|anything in cargopads
					if(!selection)
						return
					var/turf/T = get_turf(selection)
					if (!T)
						boutput(usr, "<span class='alert'>Target not set!</span>")
						return
					boutput(usr, "Target set to [T.loc].")
					src.target = T
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

	attackby(obj/item/W as obj, mob/user as mob)
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

var/global/list/cargopads = list()

/obj/submachine/cargopad
	name = "Cargo Pad"
	desc = "Used to receive objects transported by a cargo transporter."
	icon = 'icons/obj/objects.dmi'
	icon_state = "cargopad"
	anchored = 1
	plane = PLANE_FLOOR
	mats = 10 //I don't see the harm in re-adding this. -ZeWaka
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	var/active = 1

	podbay
		name = "Pod Bay Pad"
	hydroponic
		name = "Hydroponics Pad"
	robotics
		name = "Robotics Pad"
	artlab
		name = "Artifact Lab Pad"
	engineering
		name = "Engineering Pad"
	mechanics
		name = "Mechanics Pad"
	magnet
		name = "Mineral Magnet Pad"
	miningoutpost
		name = "Mining Outpost Pad"
	qm
		name = "QM Pad"
	qm2
		name = "QM Pad 2"
	researchoutpost
		name = "Research Outpost Pad"

	New()
		..()
		src.overlays += image('icons/obj/objects.dmi', "cpad-rec")
		if (src.name == "Cargo Pad")
			src.name += " ([rand(100,999)])"
		if (src.active && !cargopads.Find(src))
			cargopads.Add(src)

	disposing()
		if (cargopads.Find(src))
			cargopads.Remove(src)
		..()


	was_deconstructed_to_frame(mob/user)
		if (cargopads.Find(src))
			cargopads.Remove(src)
		..()

	was_built_from_frame(mob/user, newly_built)
		if (!cargopads.Find(src))
			cargopads.Add(src)
		..()


	attack_hand(var/mob/user as mob)
		if (src.active == 1)
			boutput(user, "You switch the receiver off.")
			src.overlays = null
			src.active = 0
			if (cargopads.Find(src))
				cargopads.Remove(src)
		else
			boutput(user, "You switch the receiver on.")
			src.overlays += image('icons/obj/objects.dmi', "cpad-rec")
			src.active = 1
			if (!cargopads.Find(src))
				cargopads.Add(src)

// satchels -> obj/item/satchel.dm

/obj/item/ore_scoop
	name = "ore scoop"
	desc = "A device that sucks up ore into a satchel automatically. Just load in a satchel and walk over ore to scoop it up."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "scoop"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "buildpipe"
	w_class = 2
	mats = 6
	var/obj/item/satchel/mining/satchel = null

	borg
		New()
			..()
			var/obj/item/satchel/mining/large/S = new /obj/item/satchel/mining/large(src)
			satchel = S

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/satchel/mining/))
			var/obj/item/satchel/mining/S = W
			if (satchel)
				boutput(user, "<span class='alert'>There's already a satchel hooked up to [src].</span>")
				return
			user.drop_item()
			S.set_loc(src)
			satchel = S
			icon_state = "scoop-bag"
			user.visible_message("[user] inserts [S] into [src].", "You insert [S] into [src].")
		else
			..()
			return

	attack_self(var/mob/user as mob)
		if(!issilicon(user))
			if (satchel)
				user.visible_message("[user] unloads [satchel] from [src].", "You unload [satchel] from [src].")
				satchel.set_loc(get_turf(user))
				satchel = null
				icon_state = "scoop"
			else
				boutput(user, "<span class='alert'>There's no satchel in [src] to unload.</span>")
		else
			boutput(user, "<span class='alert'>The satchel is firmly secured.</span>")

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if (!isturf(target))
			target = get_turf(target)
		if (!satchel)
			boutput(user, "<span class='alert'>There's no satchel in [src] to dump out.</span>")
			return
		if (satchel.contents.len < 1)
			boutput(user, "<span class='alert'>The satchel in [src] is empty.</span>")
			return
		user.visible_message("[user] dumps out [src]'s satchel contents.", "You dump out [src]'s satchel contents.")
		for (var/obj/item/I in satchel.contents)
			I.set_loc(target)
		satchel.satchel_updateicon()

////// Shit that goes in the asteroid belt, might split it into an exploring.dm later i guess

/turf/simulated/wall/ancient
	name = "strange wall"
	desc = "A weird jet black metal wall indented with strange grooves and lines."
	icon_state = "ancient"

	attackby(obj/item/W as obj, mob/user as mob)
		boutput(usr, "<span class='combat'>You attack [src] with [W] but fail to even make a dent!</span>")
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

	attackby(obj/item/W as obj, mob/user as mob)
		boutput(usr, "<span class='combat'>You attack [src] with [W] but fail to even make a dent!</span>")
		return

	ex_act(severity)
		return

/turf/unsimulated/floor/ancient
	name = "strange surface"
	desc = "A strange jet black metal floor. There are odd lines carved into it."
	icon_state = "ancient"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	attackby(obj/item/W as obj, mob/user as mob)
		boutput(usr, "<span class='combat'>You attack [src] with [W] but fail to even make a dent!</span>")
		return

	ex_act(severity)
		return
