/obj/grille
	desc = "A sturdy metal mesh. Blocks large objects, but lets small items, gas, or energy beams through."
	name = "grille"
	icon = 'icons/obj/SL_windows_grilles.dmi'
	icon_state = "grille0-0"
	density = 1
	stops_space_move = 1
	var/health = 30
	var/health_max = 30
	var/ruined = 0
	var/blunt_resist = 0
	var/cut_resist = 0
	var/corrode_resist = 0
	var/temp_resist = 0
	var/shock_when_entered = 1
	var/auto = TRUE
	var/list/connects_to_turf = list(/turf/simulated/wall/auto, /turf/simulated/wall/auto/reinforced, /turf/simulated/shuttle/wall, /turf/unsimulated/wall)
	var/list/connects_to_obj = list(/obj/indestructible/shuttle_corner,	/obj/grille/, /obj/machinery/door, /obj/window)
	text = "<font color=#aaa>+"
	anchored = 1
	flags = FPRINT | CONDUCT | USEDELAY
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = GRILLE_LAYER
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER | USE_CANPASS

	New()
		..()
		if(src.auto)
			SPAWN_DBG(0) //fix for sometimes not joining on map load
				if (map_setting && ticker)
					src.update_neighbors()

				src.update_icon()

	disposing()
		var/list/neighbors = null
		if (src.auto && src.anchored && map_setting)
			neighbors = list()
			for (var/obj/grille/O in orange(1,src))
				neighbors += O //find all of our neighbors before we move
		..()
		for (var/obj/grille/O in neighbors)
			O?.update_icon() //now that we are in nullspace tell them to update

	steel
#ifdef IN_MAP_EDITOR
		icon_state = "grille0-0"
#endif
		New()
			..()
			var/datum/material/M = getMaterial("steel")
			src.setMaterial(M)

	steel/broken
		desc = "Looks like its been in this sorry state for quite some time."
		icon_state = "grille-cut"
		ruined = 1

		New()
			..()
			damage_slashing(1000)
			update_icon()

	catwalk
		name = "catwalk surface"
		icon = 'icons/obj/grille.dmi'
		icon_state = "catwalk"
		density = 0
		desc = "This doesn't look very safe at all!"
		layer = CATWALK_LAYER
		shock_when_entered = 0
		plane = PLANE_FLOOR
		auto = FALSE
		connects_to_turf = null
		connects_to_turf = null

		update_icon(special_icon_state)
			if (ruined)
				return

			if (istext(special_icon_state))
				icon_state = initial(src.icon_state) + "-" + special_icon_state
				return

			var/diff = get_fraction_of_percentage_and_whole(health,health_max)
			switch(diff)
				if(-INFINITY to 25)
					icon_state = initial(src.icon_state) + "-3"
				if(26 to 50)
					icon_state = initial(src.icon_state) + "-2"
				if(51 to 75)
					icon_state = initial(src.icon_state) + "-1"
				if(76 to INFINITY)
					icon_state = initial(src.icon_state) + "-0"

		cross //HEY YOU! YEAH, YOU LOOKING AT THIS. Use these for the corners of your catwalks!
			name = "catwalk surface" //Or I'll murder you since you are making things ugly on purpose.
			icon_state = "catwalk_cross" //(Statement does not apply when you actually want to use the other ones.)

		jen // ^^ no i made my own because i am epic
			name = "maintenance catwalk"
			icon_state = "catwalk_jen"
			desc = "This looks marginally more safe than the ones outside, at least..."
			layer = PIPE_LAYER + 0.01

			attack_hand(obj/M, mob/user)
				return 0

			attackby(obj/item/W, mob/user)
				if (issnippingtool(W))
					..()
				else
					src.loc.attackby(user.equipped(), user)

			reagent_act(var/reagent_id,var/volume)
				..()

			side
				icon_state = "catwalk_jen_side"

			inner
				icon_state = "catwalk_jen_inner"

			fourcorners
				icon_state = "catwalk_jen_4corner"

			twosides
				icon_state = "catwalk_jen_2sides"

	onMaterialChanged()
		..()
		if (istype(src.material))
			health_max = material.hasProperty("density") ? round(material.getProperty("density")) : 25
			health = health_max

			cut_resist = material.hasProperty("hard") ? material.getProperty("hard") : cut_resist
			blunt_resist = material.hasProperty("density") ? material.getProperty("density") : blunt_resist
			corrode_resist = material.hasProperty("corrosion") ? material.getProperty("corrosion") : corrode_resist
			//temp_resist = material.hasProperty(PROP_MELTING) ? material.getProperty(PROP_MELTING) : temp_resist
			if (blunt_resist != 0) blunt_resist /= 2

	damage_blunt(var/amount)
		if (!isnum(amount) || amount <= 0)
			return

		if (src.ruined)
			if (amount >= health_max / 2)
				qdel(src)
			return

		var/armor = 0

		if (src.material)
			armor = blunt_resist

			if (src.material.quality >= 25)
				armor += src.material.quality * 0.25
			else if (src.quality < 10)
				armor = 0
				//amount += rand(1,3)

			amount -= armor

		src.health = max(0,min(src.health - amount,src.health_max))
		if (src.health == 0)
			update_icon("cut")
			src.set_density(0)
			src.ruined = 1
		else
			update_icon()

	damage_slashing(var/amount)
		if (!isnum(amount) || amount <= 0)
			return

		if (src.ruined)
			drop_rods(1)
			qdel(src)
			return

		amount = get_damage_after_percentage_based_armor_reduction(cut_resist,amount)

		src.health = max(0,min(src.health - amount,src.health_max))
		if (src.health == 0)
			drop_rods(1)
			update_icon("cut")
			src.set_density(0)
			src.ruined = 1
		else
			update_icon()

	damage_corrosive(var/amount)
		if (!isnum(amount) || amount <= 0)
			return

		if (src.ruined)
			qdel(src)
			return

		amount = get_damage_after_percentage_based_armor_reduction(corrode_resist,amount)
		src.health = max(0,min(src.health - amount,src.health_max))
		if (src.health == 0)
			update_icon("corroded")
			src.set_density(0)
			src.ruined = 1
		else
			update_icon()

	damage_heat(var/amount)
		if (!isnum(amount) || amount <= 0)
			return

		if (src.ruined)
			qdel(src)
			return

		if (src.material)
			if (amount * 100000 <= temp_resist)
				// Not applying enough heat to melt it
				return

		src.health = max(0,min(src.health - amount,src.health_max))
		if (src.health == 0)
			update_icon("melted")
			src.set_density(0)
			src.ruined = 1
		else
			update_icon()

	meteorhit(var/obj/M)
		if (istype(M, /obj/newmeteor/massive))
			qdel(src)
			return

		src.damage_blunt(5)

		return

	blob_act(var/power)
		src.damage_blunt(3 * power / 20)

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.damage_blunt(40)
				src.damage_heat(40)

			if(2.0)
				src.damage_blunt(15)
				src.damage_heat(15)

			if(3.0)
				src.damage_blunt(7)
				src.damage_heat(7)
		return

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
			damage_blunt(5)
		else if (isobj(AM))
			var/obj/O = AM
			if (O.throwforce)
				damage_blunt(blunt_resist ? max(0.5, O.throwforce / blunt_resist) : 0.5) // we don't want people screaming right through these and you can still get through them by kicking/cutting/etc
		return

	attack_hand(mob/user)
		if (!islist(user)) //mbc : what the fuck. who is passing a list as an arg here. WHY. WHY i cant find it
			user.lastattacked = src
		if(!shock(user, 70))
			var/damage = 1
			var/dam_type = "blunt"
			var/text = "[user.kickMessage] [src]"

			if (user.is_hulk() && damage < 5)
				damage = 10
				text = "smashes [src] with incredible strength"

			src.visible_message("<span class='alert'><b>[user]</b> [text]!</span>")
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 80, 1)

			if (dam_type == "slashing")
				damage_slashing(damage)
			else
				damage_blunt(damage)

	attackby(obj/item/W, mob/user)
		// Things that won't electrocute you

		if (ispulsingtool(W) || istype(W, /obj/item/device/t_scanner))
			var/net = get_connection()
			if(!net)
				boutput(user, "<span class='notice'>No electrical current detected.</span>")
			else
				boutput(user, "<span class='alert'>CAUTION: Dangerous electrical current detected.</span>")
			return

		else if(istype(W, /obj/item/sheet/))
			var/obj/item/sheet/S = W
			if (S.material && S.material.material_flags & MATERIAL_CRYSTAL && S.amount_check(2))
				var/obj/window/WI
				var/win_thin = 0
				var/win_dir = 2
//				var/turf/UT = get_turf(user)
				var/turf/ST = get_turf(src)

/*
				if (UT && isturf(UT) && ST && isturf(ST))
					// We're inside the grill.
					if (UT == ST)
						win_dir = usr.dir
						win_thin = 1
					// We're trying to install a window while standing on an adjacent tile, so make it face the mob.
					else
						win_dir = turn(usr.dir, 180)
						if (win_dir in list(NORTH, EAST, SOUTH, WEST))
							win_thin = 1

				win_thin = 0 //mbc : nah this is annoying. you can just make a thindow using the popup menu and push it into place anyway.
							 singh : if you're gonna disable it like this why not just comment out the entire thing and save the pointless checks
*/

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
					logTheThing("station", usr, null, "builds a [WI.name] (<b>Material:</b> [WI.material && WI.material.mat_id ? "[WI.material.mat_id]" : "*UNKNOWN*"]) at ([showCoords(usr.x, usr.y, usr.z)] in [usr.loc.loc])")
				else
					user.show_text("<b>Error:</b> Couldn't spawn window. Try again and please inform a coder if the problem persists.", "red")
					return

				S.consume_sheets(2)
				return
			else
				..()
				return

		// electrocution check

		var/OSHA_is_crying = 1
		var/dmg_mod = 0
		if ((src.material && src.material.hasProperty("electrical") && src.material.getProperty("electrical") < 30))
			OSHA_is_crying = 0

		if ((src.material && src.material.hasProperty("electrical") && src.material.getProperty("electrical") > 30))
			dmg_mod = 60 - src.material.getProperty("electrical")

		if (OSHA_is_crying && shock(user, 100 - dmg_mod))
			return

		// Things that will electrocute you

		if (issnippingtool(W))
			damage_slashing(src.health_max)
			src.visible_message("<span class='alert'><b>[usr]</b> cuts apart the [src] with [W].</span>")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)

		else if (isscrewingtool(W) && (istype(src.loc, /turf/simulated) || src.anchored))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			src.anchored = !( src.anchored )
			src.visible_message("<span class='alert'><b>[usr]</b> [src.anchored ? "fastens" : "unfastens"] [src].</span>")
			return

		else
			user.lastattacked = src
			attack_particle(user,src)
			src.visible_message("<span class='alert'><b>[usr]</b> attacks [src] with [W].</span>")
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 80, 1)

			switch(W.hit_type)
				if(DAMAGE_BURN)
					damage_heat(W.force)
				else
					damage_blunt(W.force * 0.5)
		return

	proc/update_icon(var/special_icon_state)
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
			G.update_icon()

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

	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
		if (istype(mover, /obj/projectile))
			if (density)
				return prob(50)
			return 1

		if (density && istype(mover, /obj/window))
			return 1

		return ..()

	HasEntered(AM as mob|obj)
		..()
		if (src.shock_when_entered)
			if (ismob(AM))
				if (!isliving(AM) || isintangible(AM)) // I assume this was left out by accident (Convair880).
					return
				var/mob/M = AM
				if (M.client && M.client.flying) // noclip
					return
				var/s_chance = 10
				if (M.m_intent != "walk") // move carefully
					s_chance += 50
				if (shock(M, s_chance, rand(0,1))) // you get a 50/50 shot to accidentally touch the grille with something other than your hands
					M.show_text("<b>You brush against [src] while moving past it and it shocks you!</b>", "red")
