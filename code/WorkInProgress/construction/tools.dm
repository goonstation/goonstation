// hack of the century
/obj/smes_spawner
	name = "power storage unit"
	icon = 'icons/obj/power.dmi'
	icon_state = "smes"
	density = 1
	anchored = 1
	New()
		SPAWN_DBG(1 SECOND)
			var/obj/term = new /obj/machinery/power/terminal(get_step(get_turf(src), dir))
			term.dir = get_dir(get_turf(term), src)
			new /obj/machinery/power/smes(get_turf(src))
			qdel(src)

/obj/ai_frame
	name = "\improper Asimov 5 Artifical Intelligence"
	desc = "An artificial intelligence unit which requires the brain of a living organism to function as a neural processor."
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai"
	anchored = 0
	density = 1
	opacity = 0

	var/processing = 0

	New()
		..()
		src.overlays += image('icons/mob/ai.dmi', "topopen")
		src.overlays += image('icons/mob/ai.dmi', "batterymode")

	attackby(var/obj/item/I as obj, user as mob)
		if (istype(I, /obj/item/organ/brain) && !processing)
			processing = 1
			var/valid = 0
			var/obj/item/organ/brain/B = I
			if(B.owner)
				if(B.owner.current)
					if(B.owner.current.client)
						valid = 1
			if (!valid)
				boutput(user, "<span class='alert'>This brain doesn't look any good to use!</span>")
				processing = 0
				return
			var/mob/M = B.owner.current
			M.set_loc(get_turf(src))
			var/mob/living/silicon/ai/TheAI = M.AIize(0, 1)
			TheAI.set_loc(src)
			B.set_loc(TheAI)
			TheAI.brain = B
			TheAI.anchored = 0
			TheAI.dismantle_stage = 3
			TheAI.update_appearance()
			qdel(src)
		else
			..()

/obj/machinery/turret/construction
	power_usage = 250
	var/obj/machinery/turretid/computer/control = null
	var/firesat = "humanoids"
	override_area_bullshit = 1

	process()
		if(status & BROKEN)
			return
		..()
		if(status & NOPOWER)
			return
		if(lastfired && world.time - lastfired < shot_delay)
			return
		lastfired = world.time
		if (src.cover==null)
			src.cover = new /obj/machinery/turretcover(src.loc)
		power_usage = 250
		var/list/targets = list()
		if (firesat == "humanoids")
			for (var/mob/living/carbon/M in view(5, src))
				if (!isdead(M))
					targets += M
		else if (firesat == "critters")
			for (var/obj/critter/C in view(5, src))
				if (C.alive)
					targets += C
		if (targets.len > 0)
			if (!isPopping())
				if (isDown())
					popUp()
					power_usage = 750
				else
					var/target = pick(targets)
					src.dir = get_dir(src, target)
					if (src.enabled)
						power_usage = 750
						src.shootAt(target)

/obj/machinery/turretid/computer
	var/list/turrets = list()
	icon = 'icons/obj/computer.dmi'
	icon_state = "turret3"
	density = 1
	var/firesat = "humanoids"

	New()
		..()
		scan()

	proc/scan()
		for (var/obj/machinery/turret/construction/T in range(src, 7))
			if (!T.control && !(T in turrets))
				turrets += T
				T.control = src

	attack_hand(var/mob/user as mob)
		if ( (get_dist(src, user) > 1 ))
			if (!issilicon(user))
				boutput(user, text("Too far away."))
				src.remove_dialog(user)
				user.Browse(null, "window=turretid")
				return

		src.add_dialog(user)
		var/t = "<TT><B>Turret Control Panel</B><BR><B>Controlled turrets:</B> [turrets.len] (<A href='?src=\ref[src];rescan=1'>Rescan</a>)<HR>"

		if(src.locked && (!issilicon(user)))
			t += "<I>(Swipe ID card to unlock control panel.)</I><BR>"
		else
			t += text("Turrets [] - <A href='?src=\ref[];toggleOn=1'>[]?</a><br><br>", src.enabled?"activated":"deactivated", src, src.enabled?"Disable":"Enable")
			t += text("Currently firing at <A href='?src=\ref[];firesAt=1'>[]</a><br><br>", src, firesat)
			t += text("Currently set for [] - <A href='?src=\ref[];toggleLethal=1'>Change to []?</a><br><br>", src.lethal?"lethal":"stun repeatedly", src,  src.lethal?"Stun repeatedly":"Lethal")

		user.Browse(t, "window=turretid")
		onclose(user, "turretid")


	Topic(href, href_list)
		if (src.locked)
			if (!issilicon(usr))
				boutput(usr, "Control panel is locked!")
				return
		if (href_list["rescan"])
			scan()
		if (href_list["firesAt"])
			cycleFiresAt()
			updateFiresAt()
		..()

	proc/cycleFiresAt()
		if (!src.locked)
			switch (firesat)
				if ("humanoids")
					firesat = "critters"
				if ("critters")
					firesat = "humanoids"

	proc/updateFiresAt()
		for (var/obj/machinery/turret/construction/aTurret in turrets)
			aTurret.firesat = firesat

	updateTurrets()
		if (src.enabled)
			if (src.lethal)
				icon_state = "turret2"
			else
				icon_state = "turret3"
		else
			icon_state = "turret1"

		for (var/obj/machinery/turret/construction/aTurret in turrets)
			aTurret.setState(enabled, lethal)

/obj/item/room_marker
	name = "\improper Room Designator"
	icon = 'icons/obj/construction.dmi'
	icon_state = "room"
	item_state = "gun"
	w_class = 2

	mats = 6
	var/using = 0
	var/datum/progress/designated = null

	attack_self(var/mob/user)
		if (!(ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/construction)))
			boutput(user, "<span class='alert'>You can only use this tool in construction mode.</span>")
		var/datum/game_mode/construction/C = ticker.mode
		var/list/pickable = list()
		for (var/datum/progress/P in C.milestones)
			if (P.is_room && !P.completed)
				pickable += P
		if (!pickable.len)
			boutput(user, "<span class='alert'>No rooms available for designation.</span>")
		designated = input("Which room would you like to designate?", "Room", pickable[1]) in pickable
		boutput(user, "<span class='hint'>Using this tool will now designate the room: [designated]. A room is surrounded by dense objects or walls on all sides.</span>")
		if (designated.minimum_width)
			boutput(user, "<span class='hint'>The room must be at least [designated.minimum_width] tiles wide (including the walls).</span>")
		if (designated.minimum_height)
			boutput(user, "<span class='hint'>The room must be at least [designated.minimum_height] tiles high (including the walls).</span>")
		if (designated.requirements_cache)
			boutput(user, "<span class='hint'>The room must contain at least the following objects: [designated.requirements_cache].</span>")

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (!isturf(target))
			return
		if (!designated)
			boutput(user, "<span class='alert'>No designated room selected.</span>")
			return
		if (designated.completed)
			boutput(user, "<span class='notice'>The designated room already exists.</span>")
			designated = null
			return
		if (using)
			boutput(user, "<span class='alert'>Already verifying a room. Please wait.</span>")
			return
		using = 1
		boutput(user, "<span class='notice'>Designating room.</span>")
		SPAWN_DBG(0)
			if (designated.check_completion(target))
				boutput(user, "<span class='notice'>Designation successful, room matches required parameters.</span>")
				//new /obj/machinery/power/apc(get_turf(target))
				//boutput(user, "<span class='alert'>Yes I am aware that that APC is in a shit place. You will have to make do until I can actually finish working on power stuff okay???</span>")
				designated = null
			else
				boutput(user, "<span class='alert'>Designation failed.</span>")
			using = 0

/obj/item/clothing/glasses/construction
	name = "\improper Construction Visualizer"
	icon_state = "meson"
	item_state = "glasses"
	mats = 6
	desc = "The latest technology in viewing live blueprints."

/obj/item/material_shaper
	name = "\improper Window Planner"
	icon = 'icons/obj/construction.dmi'
	icon_state = "shaper"
	item_state = "gun"
	flags = FPRINT | TABLEPASS | EXTRADELAY
	mats = 6
	click_delay = 1

	var/mode = 0
	var/datum/material/metal = null
	var/metal_count = 0
	var/datum/material/glass = null
	var/glass_count = 0

	var/processing = 0

	w_class = 2

	var/sound/sound_process = sound('sound/effects/pop.ogg')
	var/sound/sound_grump = sound('sound/machines/buzz-two.ogg')

	proc/determine_material(var/obj/item/material_piece/D, mob/user as mob)
		var/datum/material/DM = D.material
		var/which = null
		if ((DM.material_flags & MATERIAL_METAL) && (DM.material_flags & MATERIAL_CRYSTAL))
			var/be_metal = 0
			var/be_glass = 0
			if (!metal)
				be_metal = 1
			else if (metal.mat_id == DM.mat_id)
				be_metal = 1
			if (!glass)
				be_glass = 1
			else if (glass.mat_id == DM.mat_id)
				be_glass = 1
			if (be_metal && be_glass)
				which = input("Use [D] as?", "Pick", null) in list("metal", "glass")
			else if (be_metal)
				which = "metal"
			else if (be_glass)
				which = "glass"
			else
				playsound(src.loc, sound_grump, 40, 1)
				boutput(user, "<span class='alert'>[D] incompatible with current metal or glass.</span>")
				return null
		else if (DM.material_flags & MATERIAL_METAL)
			if (!metal)
				which = "metal"
			else if (metal.mat_id == DM.mat_id)
				which = "metal"
			else
				playsound(src.loc, sound_grump, 40, 1)
				boutput(user, "<span class='alert'>[D] incompatible with current metal.</span>")
				return null
		else if (DM.material_flags & MATERIAL_CRYSTAL)
			if (!glass)
				which = "glass"
			else if (glass.mat_id == DM.mat_id)
				which = "glass"
			else
				playsound(src.loc, sound_grump, 40, 1)
				boutput(user, "<span class='alert'>[D] incompatible with current glass.</span>")
				return null
		else
			playsound(src.loc, sound_grump, 40, 1)
			boutput(user, "<span class='alert'>[D] is not a metal or glass material.</span>")
		if (!which)
			playsound(src.loc, sound_grump, 40, 1)
			boutput(user, "<span class='alert'>[D] is not a metal or glass material.</span>")

		if (which == "metal" && !metal)
			metal = DM
		else if (which == "glass" && !glass)
			glass = DM

		return which

	proc/has_materials(var/metalc, var/glassc)
		if (metal_count < metalc || glass_count < glassc)
			return 0
		return 1

	proc/use_materials(var/metalc, var/glassc)
		metal_count -= metalc
		glass_count -= glassc
		if (metal_count <= 0)
			metal = null
		if (glass_count <= 0)
			glass = null
		boutput(usr, "<span class='notice'>The shaper has [metal_count] units of metal and [glass_count] units of glass left.</span>")

	examine()
		. = ..()
		if (metal)
			. += "<span class='notice'>Metal: [metal_count] units of [metal.name].</span>"
		else
			. += "<span class='alert'>Metal: 0 units.</span>"

		if (glass)
			. += "<span class='notice'>Glass: [glass_count] units of [glass.name].</span>"
		else
			. += "<span class='alert'>Glass: 0 units</span>"

	attack_self(mob/user as mob)
		mode = !mode
		if (!mode)
			boutput(user, "<span class='notice'>Mode: marking/unmarking plans for grille and glass structures.</span>")
		else
			boutput(user, "<span class='notice'>Mode: constructing planned grille and glass structures.</span>")

	attackby(var/obj/item/W, mob/user as mob)
		if (W.disposed)
			return
		if (istype(W, /obj/item/material_piece))
			var/obj/item/material_piece/D = W
			var/which = determine_material(D, user)
			if (which == "metal")
				pool(W)
				metal_count += 10
			else if (which == "glass")
				pool(W)
				glass_count += 10
			else
				return

	pixelaction(atom/target, params, mob/user)
		if (mode)
			return 0
		var/turf/T = target
		if (!istype(T))
			T = get_turf(T)
		if (!T)
			return 0

		var/obj/plan_marker/glass_shaper/old = locate() in T
		if (old)
			old.cancelled()
		else
			new /obj/plan_marker/glass_shaper(T)

		boutput(user, "<span class='notice'>Done.</span>")
		return 1

	MouseDrop_T(var/obj/over_object, mob/user as mob)
		if (processing)
			return
		processing = 1
		var/procloc = user.loc
		if (!istype(over_object))
			processing = 0
			return
		if (!istype(over_object.loc, /turf))
			processing = 0
			return
		if (istype(over_object, /obj/item/material_piece))
			var/obj/item/material_piece/D = over_object
			if (!D.material)
				playsound(src.loc, sound_grump, 40, 1)
				boutput(user, "<span class='alert'>That does not have a usable material.</span>")
				return

			var/which = determine_material(D, user)
			if (!which)
				processing = 0
				return
			var/datum/material/DM = null
			if (which == "metal")
				DM = metal
			else if (which == "glass")
				DM = glass
			else
				processing = 0
				return

			user.visible_message("<span class='notice'>[user] begins stuffing materials into [src].</span>")

			for (var/obj/item/material_piece/M in over_object.loc)
				if (user.loc != procloc)
					break
				var/datum/material/MT = M.material
				if (!MT)
					continue
				if (MT.mat_id == DM.mat_id)
					playsound(src.loc, sound_process, 40, 1)
					if (which == "metal")
						metal_count += 10
					else
						glass_count += 10
					pool(M)
					sleep(0.1 SECONDS)
			processing = 0
			user.visible_message("<span class='notice'>[user] finishes stuffing materials into [src].</span>")

/obj/item/room_planner
	name = "\improper Floor and Wall Planner"
	icon = 'icons/obj/construction.dmi'
	icon_state = "plan"
	item_state = "gun"
	flags = FPRINT | TABLEPASS | EXTRADELAY
	mats = 6
	w_class = 2
	click_delay = 1

	var/selecting = 0
	var/mode = "floors"
	var/icons = list("floors" = 'icons/turf/construction_floors.dmi', "walls" = 'icons/turf/construction_walls.dmi')
	var/marker_class = list("floors" = /obj/plan_marker/floor, "walls" = /obj/plan_marker/wall)
	var/selected = "floor"
	// var/pod_turf = 0
	var/turf_op = 0

	attack_self(mob/user as mob)
		// This seems to not actually stop anything from working so just axing it.
		//if (!(ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/construction)))
		//	boutput(user, "<span class='alert'>You can only use this tool in construction mode.</span>")

		if (selecting)
			return

		selecting = 1
		mode = input("What to mark?", "Marking", mode) in icons
		selected = null
		var/states = list()
		if (mode == "walls")
			states += "* AUTO *"
		states += icon_states(icons[mode])
		selected = input("What kind?", "Marking", states[1]) in states
		// if (mode == "floors" && findtext(selected, "catwalk") != 0)
		// 	pod_turf = 1
		// else
		// 	pod_turf = 0
		if (mode == "floors" || (mode == "walls" && findtext(selected, "window") != 0))
			turf_op = 0
		else
			turf_op = 1
		boutput(user, "<span class='notice'>Now marking plan for [mode] of type [selected].</span>")
		selecting = 0

	pixelaction(atom/target, params, mob/user)
		var/turf/T = target
		if (!istype(T))
			T = get_turf(T)
		if (!T)
			return 0

		var/obj/plan_marker/old = null
		for (var/obj/plan_marker/K in T)
			if (istype(K, /obj/plan_marker/floor) || istype(K, /obj/plan_marker/wall))
				old = K
				break
		if (old)
			old.attackby(src, user)
		else
			var/class = marker_class[mode]
			old = new class(T, selected)
			old.dir = get_dir(user, T)
			// if (pod_turf)
			// 	old:allows_vehicles = 1
			old.turf_op = turf_op
			old:check()
		boutput(user, "<span class='notice'>Done.</span>")

		return 1

/obj/plan_marker
	name = "\improper Plan Marker"
	icon = 'icons/turf/construction_walls.dmi'
	icon_state = null
	anchored = 1
	density = 0
	opacity = 0
	invisibility = 8
	var/allows_vehicles = 0
	var/turf_op = 1

	alpha = 128

	New(var/initial_loc, var/initial_state)
		..()
		color = rgb(0, 255, 0)
		icon_state = initial_state

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/room_planner))
			qdel(src)
			return
		var/turf/T = get_turf(src)
		if (T)
			T.attackby(W, user)
			W.afterattack(T, user)

/obj/plan_marker/glass_shaper
	name = "\improper Window Plan Marker"
	icon = 'icons/obj/grille.dmi'
	icon_state = "grille-0"
	anchored = 1
	density = 0
	opacity = 0
	invisibility = 8

	var/static/image/wE = null
	var/static/image/wW = null
	var/static/image/wN = null
	var/static/image/wS = null

	var/bmask = 15
	var/borders = 4

	var/filling = 0

	alpha = 128

	New(var/initial_loc)
		..()
		color = rgb(255, 0, 0)
		calculate_orientation(1)

		if (!wE)
			wE = image('icons/obj/construction.dmi', "plan_window_e")
		if (!wW)
			wW = image('icons/obj/construction.dmi', "plan_window_w")
		if (!wN)
			wN = image('icons/obj/construction.dmi', "plan_window_n")
		if (!wS)
			wS = image('icons/obj/construction.dmi', "plan_window_s")

		icon_state = "grille-0"

	proc/calculate_orientation(var/recurse = 0)
		var/borders_mask = 15
		var/gcount = 4
		var/turf/N = locate(x, y + 1, 1)
		var/turf/S = locate(x, y - 1, 1)
		var/turf/W = locate(x - 1, y, 1)
		var/turf/E = locate(x + 1, y, 1)
		if (N)
			var/obj/plan_marker/glass_shaper/G = locate() in N
			if (G)
				borders_mask -= 1
				gcount--
				if (recurse)
					G.calculate_orientation(0)
			else
				var/obj/grille/Gr = locate() in N
				if (Gr)
					borders_mask -= 1
					gcount--
		if (S)
			var/obj/plan_marker/glass_shaper/G = locate() in S
			if (G)
				borders_mask -= 2
				gcount--
				if (recurse)
					G.calculate_orientation(0)
			else
				var/obj/grille/Gr = locate() in S
				if (Gr)
					borders_mask -= 2
					gcount--
		if (E)
			var/obj/plan_marker/glass_shaper/G = locate() in E
			if (G)
				borders_mask -= 4
				gcount--
				if (recurse)
					G.calculate_orientation(0)
			else
				var/obj/grille/Gr = locate() in E
				if (Gr)
					borders_mask -= 4
					gcount--
		if (W)
			var/obj/plan_marker/glass_shaper/G = locate() in W
			if (G)
				borders_mask -= 8
				gcount--
				if (recurse)
					G.calculate_orientation(0)
			else
				var/obj/grille/Gr = locate() in W
				if (Gr)
					borders_mask -= 8
					gcount--

		bmask = borders_mask
		borders = gcount
		overlays.len = 0
		if (borders_mask & 1)
			overlays += wN
		if (borders_mask & 2)
			overlays += wS
		if (borders_mask & 4)
			overlays += wE
		if (borders_mask & 8)
			overlays += wW

	proc/spawn_in(var/obj/item/material_shaper/origin)
		if (filling)
			return
		filling = 1
		if (!isturf(src.loc))
			filling = 0
			return
		var/turf/T = src.loc
		if (T.density)
			boutput(usr, "<span class='alert'>Cannot complete material shaping: plan inside dense turf.</span>")
			filling = 0
			return
		else
			for (var/atom/movable/O in T)
				if ((istype(O, /obj) && O.density) || isliving(O))
					boutput(usr, "<span class='alert'>Cannot complete material shaping: [O] blocking construction.</span>")
					filling = 0
					return
		var/datum/material/metal = origin.metal
		var/datum/material/glass = origin.glass
		var/turf/L = get_turf(src)
		if (!metal)
			metal = getMaterial("steel")
		if (!glass)
			glass = getMaterial("glass")

		origin.use_materials(2, borders)

		var/obj/grille/G = new /obj/grille(L)
		G.setMaterial(metal)

		var/mask = bmask
		if (mask & 1)
			var/obj/window/reinforced/W = new /obj/window/reinforced(L)
			W.dir = 1
			W.setMaterial(glass)

		if (mask & 2)
			var/obj/window/reinforced/W = new /obj/window/reinforced(L)
			W.dir = 2
			W.setMaterial(glass)

		if (mask & 4)
			var/obj/window/reinforced/W = new /obj/window/reinforced(L)
			W.dir = 4
			W.setMaterial(glass)

		if (mask & 8)
			var/obj/window/reinforced/W = new /obj/window/reinforced(L)
			W.dir = 8
			W.setMaterial(glass)
		qdel(src)

	proc/cancelled()
		var/turf/N = locate(x, y + 1, 1)
		var/turf/S = locate(x, y - 1, 1)
		var/turf/W = locate(x - 1, y, 1)
		var/turf/E = locate(x + 1, y, 1)
		if (N)
			var/obj/plan_marker/glass_shaper/G = locate() in N
			if (G)
				G.calculate_orientation(0)
		if (S)
			var/obj/plan_marker/glass_shaper/G = locate() in S
			if (G)
				G.calculate_orientation(0)
		if (E)
			var/obj/plan_marker/glass_shaper/G = locate() in E
			if (G)
				G.calculate_orientation(0)
		if (W)
			var/obj/plan_marker/glass_shaper/G = locate() in W
			if (G)
				G.calculate_orientation(0)

		qdel(src)

	proc/handle_shaper(var/obj/item/material_shaper/W)
		if (!W:mode)
			cancelled()
		else
			if (W:has_materials(2, borders))
				spawn_in(W)
			else
				boutput(usr, "<span class='alert'>Insufficient materials -- requires 2 metal and [borders] glass.</span>")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/material_shaper))
			handle_shaper(W)
		else
			..()

/obj/plan_marker/wall
	name = "\improper Wall Plan Marker"
	desc = "Build a wall here to complete the plan."

	proc/check()
		var/turf/T = get_turf(src)
		// Originally worked only on this type specifically.
		// Which meant it didn't work with the fancy new auto-walls
		if (istype(T, /turf/simulated/wall))
			// Only update if the wall should have a different type
			if (src.icon_state != "* AUTO *")
				T.icon = src.icon
				T.icon_state = src.icon_state
				T.dir = src.dir
				T:allows_vehicles = src.allows_vehicles
			else if (istype(T, /turf/simulated/wall/auto))
				var/turf/simulated/wall/auto/AT = T
				AT.icon = initial(AT.icon)
				AT.icon_state = initial(AT.icon_state)
				AT.dir = initial(AT.dir)
				AT:allows_vehicles = initial(AT.allows_vehicles)
				AT.update_icon()
				AT.update_neighbors()
			qdel(src)

/obj/plan_marker/floor
	name = "\improper Floor Plan Marker"
	desc = "Build a floor here to complete the plan."
	icon = 'icons/turf/construction_floors.dmi'

	proc/check()
		var/turf/T = get_turf(src)
		if (istype(T, /turf/simulated/floor))
			// Same deal as above, only checked for that specific type of floor
			// so the various alternate designs weren't able to be converted
			T.icon = src.icon
			T.icon_state = src.icon_state
			T.dir = src.dir
			// T:allows_vehicles = src.allows_vehicles
			qdel(src)
