/obj/grille
	desc = "A metal mesh often built underneath windows to reinforce them. The holes let fluids, gasses, and energy beams through."
	name = "grille"
	icon = 'icons/obj/SL_windows_grilles.dmi'
	icon_state = "grille0-0"
	density = 1
	stops_space_move = 1
	uses_material_appearance = TRUE
	var/health = 30
	var/health_max = 30
	var/ruined = 0
	var/blunt_resist = 0
	var/cut_resist = 0
	var/corrode_resist = 0
	var/shock_when_entered = 1
	var/amount_of_rods_when_destroyed = 2
	var/auto = TRUE
	//zewaka: typecacheof here
	var/list/connects_to_turf = list(/turf/simulated/wall/auto, /turf/simulated/wall/auto/reinforced, /turf/simulated/shuttle/wall, /turf/unsimulated/wall)
	var/list/connects_to_obj = list(/obj/indestructible/shuttle_corner,	/obj/grille/, /obj/machinery/door, /obj/window)
	text = "<font color=#aaa>+"
	anchored = ANCHORED
	flags = FPRINT | CONDUCT | USEDELAY
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = GRILLE_LAYER
	event_handler_flags = USE_FLUID_ENTER
	material_amt = 0.1
	///can you use wirecutters to dismantle it?
	var/can_be_snipped = TRUE
	///can you use a screwdriver to unanchor it?
	var/can_be_unscrewed = TRUE
	///can you use a multitool to check for current?
	var/can_be_probed = TRUE
	///can you use this as a base for a new window?
	var/can_build_window = TRUE


	New()
		..()
		START_TRACKING
		if(src.auto)
			SPAWN(0) //fix for sometimes not joining on map load
				if (map_setting && ticker)
					src.update_neighbors()

				src.UpdateIcon()

	disposing()
		STOP_TRACKING
		var/list/neighbors = null
		if (src.auto && src.anchored && map_setting)
			neighbors = list()
			for (var/obj/grille/O in orange(1,src))
				neighbors += O //find all of our neighbors before we move
		..()
		for (var/obj/grille/O in neighbors)
			O?.UpdateIcon() //now that we are in nullspace tell them to update

	steel
		icon_state = "grille1-0"
		default_material = "steel"

	steel/broken
		desc = "Looks like its been in this sorry state for quite some time."
		icon_state = "grille-cut"
		ruined = 1
		density = 0
		health = 0

		corroded
			icon_state = "grille-corroded"
		melted
			icon_state = "grille-melted"
	catwalk
		name = "catwalk surface"
		icon = 'icons/obj/catwalk.dmi'
		icon_state = "C15-0"
		density = FALSE
		desc = "This doesn't look very safe at all!"
		layer = CATWALK_LAYER
		shock_when_entered = FALSE
		auto = TRUE
		plane = PLANE_FLOOR
		amount_of_rods_when_destroyed = 1
		var/catwalk_type = "C" // Short for "Catwalk"
		var/connects_to = list(/obj/grille/catwalk, /obj/machinery/door) // We're working differently from grilles. We don't check a list and then another, we check all possible atoms to connect to.
		event_handler_flags = 0
		default_material = "steel"
		uses_material_appearance = FALSE
		mat_changename = FALSE

		update_icon(special_icon_state, override_parent = TRUE)
			if (ruined)
				return

			if (src.auto)
				var/connectdir = 0
				for (var/dir in cardinal)
					var/turf/T = get_step(src, dir)
					for (var/i in 1 to length(connects_to_obj))
						var/atom/movable/AM = locate(connects_to_obj[i]) in T
						if (AM?.anchored)
							connectdir |= dir
							break

				src.icon_state = "[src.catwalk_type][connectdir]"

			if (istext(special_icon_state) && special_icon_state != "cut")
				src.icon_state += "-" + special_icon_state
				return

			var/diff = get_fraction_of_percentage_and_whole(health,health_max)
			switch(diff)
				if(-INFINITY to 0)
					src.icon_state += "-4"
				if(1 to 25)
					src.icon_state += "-3"
				if(26 to 50)
					src.icon_state += "-2"
				if(51 to 75)
					src.icon_state += "-1"
				if(76 to INFINITY)
					src.icon_state += "-0"

		jen // ^^ no i made my own because i am epic
			name = "maintenance catwalk"
			icon_state = "M0-0"
			desc = "This looks marginally more safe than the ones outside, at least..."
			catwalk_type = "M" // Short for "Maintenance"
			layer = PIPE_LAYER + 0.01

			attack_hand(obj/M, mob/user)
				return 0

			attackby(obj/item/W, mob/user)
				if (issnippingtool(W))
					..()
				else
					src.loc.Attackby(user.equipped(), user)

			reagent_act(var/reagent_id,var/volume)
				..()

		dubious
			name = "rusty catwalk"
			desc = "This one looks even less safe than usual."
			var/collapsing = 0
			event_handler_flags = USE_FLUID_ENTER

			New()
				health = rand(5, 10)
				..()
				UpdateIcon()

			Crossed(atom/movable/A)
				..()
				if (ismob(A))
					src.collapsing++
					SPAWN(1 SECOND)
						collapse_timer()
						if (src.collapsing)
							playsound(src.loc, 'sound/effects/creaking_metal1.ogg', 25, 1)

			proc/collapse_timer()
				var/still_collapsing = 0
				for (var/mob/M in src.loc)
					src.collapsing++
					still_collapsing = 1
				if (!still_collapsing)
					src.collapsing--

				if (src.collapsing >= 5)
					playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
					for(var/mob/M in AIviewers(src, null))
						boutput(M, "[src] collapses!")
					qdel(src)

				if (src.collapsing)
					SPAWN(1 SECOND)
						src.collapse_timer()

	onMaterialChanged()
		..()
		if (istype(src.material))
			health_max = material.getProperty("density") * 10
			health = health_max

			cut_resist = material.getProperty("hard") * 10
			blunt_resist = material.getProperty("density") * 10
			corrode_resist = material.getProperty("chemical") * 10
			if (blunt_resist != 0) blunt_resist /= 2

	damage_blunt(var/amount)
		if (!isnum(amount) || amount <= 0)
			return

		if (src.ruined)
			if (amount >= health_max / 2)
				qdel(src)
			return

		src.health = clamp(src.health - amount, 0, src.health_max)
		if (src.health == 0)
			UpdateIcon("cut")
			src.set_density(0)
			src.ruined = 1
		else
			UpdateIcon()

	damage_slashing(var/amount)
		if (!isnum(amount) || amount <= 0)
			return

		if (src.ruined)
			drop_rods(src.amount_of_rods_when_destroyed)
			qdel(src)
			return

		amount = get_damage_after_percentage_based_armor_reduction(cut_resist,amount)

		src.health = clamp(src.health - amount, 0, src.health_max)
		if (src.health == 0)
			UpdateIcon("cut")
			src.set_density(0)
			src.ruined = 1
		else
			UpdateIcon()


	damage_corrosive(var/amount)
		if (!isnum(amount) || amount <= 0)
			return

		if (src.ruined)
			qdel(src)
			return

		amount = get_damage_after_percentage_based_armor_reduction(corrode_resist,amount)
		src.health = clamp(src.health - amount, 0, src.health_max)
		if (src.health == 0)
			UpdateIcon("corroded")
			src.set_density(0)
			src.ruined = 1
		else
			UpdateIcon()

	damage_heat(var/amount)
		if (!isnum(amount) || amount <= 0)
			return

		if (src.ruined)
			qdel(src)
			return

		src.health = clamp(src.health - amount, 0, src.health_max)
		if (src.health == 0)
			UpdateIcon("melted")
			src.set_density(0)
			src.ruined = 1
		else
			UpdateIcon()

	meteorhit(var/obj/M)
		if (istype(M, /obj/newmeteor/massive))
			qdel(src)
			return

		src.damage_blunt(5)

	blob_act(var/power)
		src.damage_blunt(3 * power / 20)

	ex_act(severity)
		switch(severity)
			if(1)
				src.damage_blunt(40)
				src.damage_heat(40)

			if(2)
				src.damage_blunt(15)
				src.damage_heat(15)

			if(3)
				src.damage_blunt(7)
				src.damage_heat(7)

	bullet_act(obj/projectile/P)
		..()
		var/damage_unscaled = P.power * P.proj_data.ks_ratio //stam component does nothing- can't tase a grille
		switch(P.proj_data.damage_type)
			if (D_PIERCING)
				src.damage_blunt(damage_unscaled)
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
			if (D_BURNING)
				src.damage_heat(damage_unscaled / 2)
			if (D_KINETIC)
				src.damage_blunt(damage_unscaled / 2)
				if (damage_unscaled > 10)
					var/datum/effects/system/spark_spread/sparks = new /datum/effects/system/spark_spread
					sparks.set_up(2, null, src) //sparks fly!
					playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 40, 1)
			if (D_ENERGY)
				src.damage_heat(damage_unscaled / 4)
			if (D_SPECIAL) //random guessing
				src.damage_blunt(damage_unscaled / 4)
				src.damage_heat(damage_unscaled / 8)
			//nothing for radioactive (useless) or slashing (unimplemented)

	reagent_act(var/reagent_id,var/volume)
		if (..())
			return
		switch(reagent_id)
			if("acid")
				damage_corrosive(volume / 2)
			if("pacid")
				damage_corrosive(volume)
			if("phlogiston")
				damage_heat(volume)
			if("infernite")
				damage_heat(volume * 2)
			if("foof")
				damage_heat(volume * 3)

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		..()
		src.visible_message("<span class='alert'><B>[src] was hit by [AM].</B></span>")
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
		if (ismob(AM))
			if(src?.material.hasProperty("electrical"))
				shock(AM, 60 + (5 * (src.material.getProperty("electrical") - 5)))  // sure loved people being able to throw corpses into these without any consequences.
			damage_blunt(5)
		else if (isobj(AM))
			var/obj/O = AM
			if (O.throwforce)
				damage_blunt((max(1, O.throwforce * (1 - (blunt_resist / 100)))) / 2) // we don't want people screaming right through these and you can still get through them by kicking/cutting/etc
		return

	attack_hand(mob/user)
		if(!shock(user, 70))
			user.lastattacked = src
			var/damage = 1
			var/text = "[user.kickMessage] [src]"

			if (user.is_hulk())
				damage = 10
				text = "smashes [src] with incredible strength"

			src.visible_message("<span class='alert'><b>[user]</b> [text]!</span>")
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 80, 1)

			damage_blunt(damage)

	attackby(obj/item/W, mob/user)
		// Things that won't electrocute you

		if (can_be_probed && (ispulsingtool(W) || istype(W, /obj/item/device/t_scanner)))
			var/net = get_connection()
			if(!net)
				boutput(user, "<span class='notice'>No electrical current detected.</span>")
			else
				boutput(user, "<span class='alert'>CAUTION: Dangerous electrical current detected.</span>")
			return

		else if(can_build_window && istype(W, /obj/item/sheet/))
			var/obj/item/sheet/S = W
			if (S.material && S.material.material_flags & MATERIAL_CRYSTAL && S.amount_check(2))
				var/obj/window/WI
				var/win_thin = 0
				var/win_dir = 2
				var/turf/ST = get_turf(src)

				if (ST && isturf(ST))
					if (S.reinforcement)
						if (map_settings)
							if (win_thin)
								WI = new map_settings.rwindows_thin (ST)
							else
								WI = new map_settings.rwindows (ST)
						else
							WI = new /obj/window/reinforced(ST)

					else
						if (map_settings)
							if (win_thin)
								WI = new map_settings.windows_thin (ST)
							else
								WI = new map_settings.windows(ST)
						else
							WI = new /obj/window(ST)

				if (WI && istype(WI))
					if (S.material)
						WI.setMaterial(S.material)
					if(win_thin)
						WI.set_dir(win_dir)
						WI.ini_dir = win_dir
					logTheThing(LOG_STATION, user, "builds a [WI.name] (<b>Material:</b> [WI.material && WI.material.mat_id ? "[WI.material.mat_id]" : "*UNKNOWN*"]) at ([log_loc(user)] in [user.loc.loc])")
				else
					user.show_text("<b>Error:</b> Couldn't spawn window. Try again and please inform a coder if the problem persists.", "red")
					return

				S.change_stack_amount(-2)
				return
			else
				..()
				return
		else if (istype(W, /obj/item/gun))
			var/obj/item/gun/G = W
			G.shoot_point_blank(src, user)
			return
		// electrocution check

		var/OSHA_is_crying = 1
		if (src.material && src.material.getProperty("electrical") < 4)
			OSHA_is_crying = 0

		if (OSHA_is_crying && src.material && (BOUNDS_DIST(src, user) == 0) && shock(user, 60 + (5 * (src?.material.getProperty("electrical") - 5))))
			return

		// Things that will electrocute you

		if (can_be_snipped && issnippingtool(W))
			damage_slashing(src.health_max)
			src.visible_message("<span class='alert'><b>[user]</b> cuts apart the [src] with [W].</span>")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)

		else if (can_be_unscrewed && (isscrewingtool(W) && (istype(src.loc, /turf/simulated) || src.anchored)))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			src.anchored = !( src.anchored )
			src.stops_space_move = !(src.stops_space_move)
			src.visible_message("<span class='alert'><b>[user]</b> [src.anchored ? "fastens" : "unfastens"] [src].</span>")
			return

		else
			user.lastattacked = src
			attack_particle(user,src)
			src.visible_message("<span class='alert'><b>[user]</b> attacks [src] with [W].</span>")
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 80, 1)

			switch(W.hit_type)
				if(DAMAGE_BURN)
					damage_heat(W.force)
				else
					damage_blunt(W.force * 0.5)
		return

	update_icon(var/special_icon_state)

		if (ruined)
			return

		if (istext(special_icon_state))
			icon_state = "grille-" + special_icon_state
			return

		var/builtdir = 0
		if (src.auto)
			for (var/dir in cardinal)
				var/turf/T = get_step(src, dir)
				var/connectable_turf = FALSE
				for (var/i in 1 to length(connects_to_turf))
					if (istype(T, connects_to_turf[i]))
						builtdir |= dir
						connectable_turf = TRUE
						break
				if (!connectable_turf) //no turfs to connect to, check for obj's
					for (var/i in 1 to length(connects_to_obj))
						var/atom/movable/AM = locate(connects_to_obj[i]) in T
						if (AM?.anchored)
							builtdir |= dir
							break

			switch(builtdir) //many states share icons
				if (0) //stand alone
					builtdir = (NORTH) //1
				if (SOUTH) //2
					builtdir = (NORTH + SOUTH) //3
				if (NORTH + EAST)//5
					builtdir = EAST //4
				if (SOUTH + EAST + NORTH) //7
					builtdir = (SOUTH + EAST) //6
				if (NORTH + WEST) //9
					builtdir = WEST //8
				if (NORTH + SOUTH + WEST) //11
					builtdir = (SOUTH + WEST) //10
				if (NORTH + EAST + WEST) //13
					builtdir = (EAST + WEST) //12
				if (NORTH + SOUTH + EAST + WEST) //15
					builtdir = (SOUTH + EAST + WEST) //14

		var/diff = get_fraction_of_percentage_and_whole(health,health_max)
		switch(diff)
			if(-INFINITY to 25)
				icon_state = "grille[builtdir]" + "-3"
			if(26 to 50)
				icon_state = "grille[builtdir]" + "-2"
			if(51 to 75)
				icon_state = "grille[builtdir]" + "-1"
			if(76 to INFINITY)
				icon_state = "grille[builtdir]" + "-0"

	proc/update_neighbors()
		for (var/obj/grille/G in orange(1,src))
			G.UpdateIcon()

	proc/drop_rods(var/amount)
		if (!isnum(amount))
			return
		var/obj/item/rods/R = new /obj/item/rods(get_turf(src))
		R.amount = amount
		if(src.material)
			R.setMaterial(src.material)
		else
			var/datum/material/M = getMaterial("steel")
			R.setMaterial(M)

	proc/get_connection()
		//returns the netnum of a stub cable at this grille loc, or 0 if none
		var/turf/T = src.loc
		if(!istype(T, /turf/simulated/floor))
			return

		for(var/obj/cable/C in T)
			if(C.d1 == 0)
				return C.netnum

		return 0

	proc/shock(mob/user, prb, var/ignore_gloves = 0)
		// shock user with probability prb (if all connections & power are working)
		// returns 1 if shocked, 0 otherwise

		if (!anchored)// || ruined) // allowing ruined grilles to still be connected so people have to move carefully through them
			// unanchored/ruined grilles are never connected
			return 0

		if (!prob(prb))
			return 0

		var/net = get_connection()
		// find the powernet of the connected cable

		if (!net)
			// cable is unpowered
			return 0

		return src.electrocute(user, prb, net, ignore_gloves)

	proc/lightningrod(lpower)
		if (!anchored)
			return FALSE
		var/net = get_connection()
		if (!powernets[net])
			return FALSE
		if(src.material)
			powernets[net].newavail += lpower / 100 * (100 - src.material.getProperty("electrical") * 5)
		else
			powernets[net].newavail += lpower / 7500

	Cross(atom/movable/mover)
		if (istype(mover, /obj/projectile))
			var/obj/projectile/P = mover
			if (density)
				if(P.proj_data.damage_type & D_RADIOACTIVE) // this shit isn't lead-lined
					return TRUE
				return prob(max(25, 1 - P.power))//big bullet = more chance to hit grille. 25% minimum
			return TRUE

		if (density && istype(mover, /obj/window))
			return TRUE

		return ..()

	Crossed(atom/movable/AM as mob|obj)
		..()
		if (src.shock_when_entered)
			if (ismob(AM))
				if (!isliving(AM) || isintangible(AM)) // I assume this was left out by accident (Convair880).
					return
				var/mob/M = AM
				if (M.client && M.client.flying || (ismob(M) && HAS_ATOM_PROPERTY(M, PROP_MOB_NOCLIP))) // noclip
					return
				var/s_chance = 10
				if (M.m_intent != "walk") // move carefully
					s_chance += 50
				if (shock(M, s_chance, rand(0,1))) // you get a 50/50 shot to accidentally touch the grille with something other than your hands
					M.show_text("<b>You brush against [src] while moving past it and it shocks you!</b>", "red")
