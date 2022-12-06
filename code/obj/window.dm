/obj/window
	name = "window"
	icon = 'icons/obj/window.dmi'
	icon_state = "window"
	desc = "A window."
	density = 1
	stops_space_move = 1
	dir = 5 //full tile
	flags = FPRINT | USEDELAY | ON_BORDER | ALWAYS_SOLID_FLUID
	event_handler_flags = USE_FLUID_ENTER
	object_flags = HAS_DIRECTIONAL_BLOCKING
	text = "<font color=#aaf>#"
	var/health = 30
	var/health_max = 30
	var/health_multiplier = 1
	var/ini_dir = null
	var/state = 2
	var/hitsound = 'sound/impact_sounds/Glass_Hit_1.ogg'
	var/shattersound = "shatter"
	var/datum/material/reinforcement = null
	var/blunt_resist = 0
	var/cut_resist = 0
	var/stab_resist = 0
	var/corrode_resist = 0
	var/temp_resist = 0
	var/default_material = "glass"
	var/default_reinforcement = null
	var/reinf = 0 // cant figure out how to remove this without the map crying aaaaa - ISN
	var/deconstruct_time = 1 SECOND
	var/image/connect_image = null
	pressure_resistance = 4*ONE_ATMOSPHERE
	gas_impermeable = TRUE
	anchored = 1

	the_tuff_stuff
		explosion_resistance = 3

	New()
		..()
		src.ini_dir = src.dir
		update_nearby_tiles(need_rebuild=1,selfnotify=1) // self notify to stop fluid jankness
		if (default_material)
			src.setMaterial(getMaterial(default_material), copy = FALSE)
		if (default_reinforcement)
			src.reinforcement = getMaterial(default_reinforcement)
		onMaterialChanged()
		src.UpdateIcon()

		// The health multiplier var wasn't implemented at all, apparently (Convair880)?
		if (src.health_multiplier != 1 && src.health_multiplier > 0)
			src.health_max = src.health_max * src.health_multiplier
			src.health = src.health_max
			//DEBUG ("[src.name] [log_loc(src)] has [health] health / [health_max] max health ([health_multiplier] multiplier).")

		if(current_state >= GAME_STATE_WORLD_INIT)
			SPAWN(0)
				initialize()

	initialize()
		src.set_layer_from_settings()
		update_nearby_tiles(need_rebuild=1)

		#ifdef XMAS
		if(src.z == Z_LEVEL_STATION && current_state <= GAME_STATE_PREGAME && !is_cardinal(src.dir))
			xmasify()
		#endif
		..()

	proc/xmasify()
		var/turf/T = get_step(src, SOUTH)
		for(var/obj/O in T)
			if(istype(O, /obj/machinery/light) || istype(O, /obj/machinery/recharger/wall))
				if(O.pixel_y > 6)
					return
		if(locate(/obj/decal) in src.loc)
			return
		if(fixed_random(src.x / world.maxx, src.y / world.maxy) <= 0.02)
			new /obj/decal/wreath(src.loc)
		else
			if(!T.density && !(locate(/obj/window) in T) && !(locate(/obj/machinery/door) in T))
				var/obj/decal/xmas_lights/lights = new(src.loc)
				lights.light_pattern(y % 5)

	proc/set_layer_from_settings()
		if (!map_settings)
			return
		if (src.dir == NORTH && map_settings.window_layer_north)
			src.layer = map_settings.window_layer_north
		else if (src.dir == SOUTH && map_settings.window_layer_south)
			src.layer = map_settings.window_layer_south
		else if (src.dir in ordinal && map_settings.window_layer_full)
			src.layer = map_settings.window_layer_full
		else
			src.layer = initial(src.layer)
		return

	disposing()
		connect_image = null
		density = 0
		update_nearby_tiles(need_rebuild=1)
		. = ..()

	Move()
		set_density(0) //mbc : icky but useful for fluids
		update_nearby_tiles(need_rebuild=1, selfnotify = 1) //only selfnotify when density is 0, because i dont want windows to displace fluids every single move() step. would be slow probably
		set_density(1)
		. = ..()


		src.set_dir(src.ini_dir)
		update_nearby_tiles(need_rebuild=1)

		return

	onMaterialChanged()
		..()

		name = initial(name)

		if (istype(src.material))

			health_max = round(material.getProperty("density") * 15)
			health = health_max

			cut_resist 		= material.getProperty("hard") * 10
			blunt_resist 	= material.getProperty("density") * 5
			stab_resist 	= material.getProperty("hard") * 10
			corrode_resist 	= material.getProperty("chemical") * 10

			if (material.alpha > 220)
				set_opacity(1) // useless opaque window)
			else
				set_opacity(0)

		if (istype(reinforcement))

			health_max += round(reinforcement.getProperty("density") * 5)
			health = health_max

			cut_resist 		+= round(reinforcement.getProperty("hard") * 5)
			blunt_resist 	+= round(reinforcement.getProperty("density") * 5)
			stab_resist 	+= round(reinforcement.getProperty("hard") * 5)
			corrode_resist 	+= round(reinforcement.getProperty("chemical") * 5)

			name = "[reinforcement.name]-reinforced " + name

	proc/set_reinforcement(var/datum/material/M)
		if (!M)
			return
		reinforcement = M
		onMaterialChanged()

	damage_blunt(var/amount, var/nosmash)
		if (!isnum(amount) || amount <= 0)
			return

		amount = get_damage_after_percentage_based_armor_reduction(blunt_resist,amount)

		src.health = clamp(src.health - amount, 0, src.health_max)

		if (src.health == 0 && nosmash)
			qdel(src)
		else if (src.health == 0 && !nosmash)
			smash()

	damage_slashing(var/amount)
		if (!isnum(amount))
			return

		amount = get_damage_after_percentage_based_armor_reduction(cut_resist,amount)

		if (amount <= 0)
			return

		src.health = clamp(src.health - amount, 0, src.health_max)
		if (src.health == 0)
			smash()

	damage_piercing(var/amount)
		if (!isnum(amount))
			return

		amount = get_damage_after_percentage_based_armor_reduction(stab_resist,amount)

		if (amount <= 0)
			return

		src.health = clamp(src.health - amount, 0, src.health_max)
		if (src.health == 0)
			smash()

	damage_corrosive(var/amount)
		if (!isnum(amount) || amount <= 0)
			return

		amount = get_damage_after_percentage_based_armor_reduction(corrode_resist,amount)
		if (amount <= 0)
			return
		src.health = clamp(src.health - amount, 0, src.health_max)
		if (src.health == 0)
			smash()

	damage_heat(var/amount, var/nosmash)
		if (!isnum(amount) || amount <= 0)
			return

		if (src.material)
			if (amount * 100000 <= temp_resist)
				// Not applying enough heat to melt it
				return

		if (amount <= 0)
			return
		src.health = clamp(src.health - amount, 0, src.health_max)
		if (src.health == 0)
			if (nosmash)
				qdel(src)
			else
				smash()

	ex_act(severity)
		// Current windows have 30 HP
		// Reinforced windows, about 130
		// Plasma glass, 330 HP
		// Basically, explosions will pop windows real good now.

		switch(severity)
			if(1)
				src.damage_blunt(rand(150, 250), 1)
				src.damage_heat(rand(150, 250), 1)
			if(2)
				src.damage_blunt(rand(50, 100))
				src.damage_heat(rand(50, 100))
			if(3)
				src.damage_blunt(rand(10, 25))
				src.damage_heat(rand(10, 25))

	meteorhit(var/obj/M)
		if (istype(M, /obj/newmeteor/massive))
			smash()
			return
		src.damage_blunt(20)

	blob_act(var/power)
		src.damage_blunt(power * 1.25)

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		if (!P || !istype(P.proj_data,/datum/projectile/))
			return
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)
		if (damage < 1)
			return

		..()

		switch(P.proj_data.damage_type)
			if(D_KINETIC)
				damage_blunt(damage*3)
			if(D_PIERCING)
				damage_piercing(damage*2)
			if(D_ENERGY)
				damage_heat(damage / 5)

	reagent_act(var/reagent_id,var/volume)
		if (..())
			return
		// windows are good at resisting corrosion and heat
		switch(reagent_id)
			if("acid")
				damage_corrosive(volume / 4)
			if("pacid")
				damage_corrosive(volume / 2)
			if("phlogiston")
				damage_heat(volume / 4)
			if("infernite")
				damage_heat(volume / 2)
			if("foof")
				damage_heat(volume)

	get_desc()
		var/the_text = ""
		var/healthpercent = src.health/src.health_max * 100
		switch(healthpercent)
			if(90 to 99)//dont want to clog up the description unless it's actually damaged
				the_text += "It seems to be in mostly good condition"
			if(75 to 89)
				the_text += "[src] is barely [pick("chipped", "cracked", "scratched")]"
			if(50 to 74)
				the_text += "[src] looks [pick("cracked", "damaged", "messed up", "chipped")]."
			if(25 to 49)
				the_text += "[src] looks [pick("quite", "pretty", "rather", "notably")] [pick("spiderwebbed", "fractured", "cracked", "busted")]."
			if(0 to 24)
				the_text += "[src] is barely intact!"

		switch(src.state)
			if(0)
				if (!src.anchored)
					the_text += "It seems to be completely loose. You could probably slide it around."
				else
					the_text += "It seems to have been pried out of the frame."
			if(1)
				the_text += "It doesn't seem to be properly fastened down."
		if (opacity)
			the_text += " ...you can't see through it at all. What kind of idiot made this?"
		return the_text

	Cross(atom/movable/mover)
		if(!src.density)
			return TRUE
		if(istype(mover, /obj/projectile))
			var/obj/projectile/P = mover
			if(P.proj_data?.window_pass)
				return TRUE
		if (!is_cardinal(dir))
			return FALSE //full tile window, you can't move into it!
		if(get_dir(loc, mover) & dir)
			return !density
		else
			return TRUE

	gas_cross(turf/target)
		. = TRUE
		if (!is_cardinal(dir) || get_dir(loc, target) & dir)
			. = ..()

	Uncross(atom/movable/O, do_bump = TRUE)
		if (!src.density)
			return 1
		if(istype(O, /obj/projectile))
			var/obj/projectile/P = O
			if(P.proj_data.window_pass)
				return 1
		if (!is_cardinal(dir))
			return 1 // let people move out of full tile windows
		if (get_dir(loc, O.movement_newloc) & src.dir)
			. = 0
			UNCROSS_BUMP_CHECK(O)
			return
		return 1

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		..()
		src.visible_message("<span class='alert'><B>[src] was hit by [AM].</B></span>")
		playsound(src.loc, src.hitsound , 100, 1)
		if (ismob(AM))
			damage_blunt(15)
		else
			var/obj/O = AM
			if (O)
				damage_blunt(O.throwforce)

		if (src && src.health <= 2 && !reinforcement)
			src.anchored = 0
			src.stops_space_move = 0
			step(src, get_dir(AM, src))
		..()
		return

	attack_hand(mob/user)
		user.lastattacked = src
		attack_particle(user,src)
		if (user.a_intent == "harm")
			if (user.is_hulk())
				user.visible_message("<span class='alert'><b>[user]</b> punches the window.</span>")
				playsound(src.loc, src.hitsound, 100, 1)
				src.damage_blunt(10)
				return
			else
				src.visible_message("<span class='alert'><b>[user]</b> beats [src] uselessly!</span>")
				playsound(src.loc, src.hitsound, 100, 1)
				return
		else
			if (ishuman(user))
				src.visible_message("<span class='alert'><b>[user]</b> knocks on [src].</span>")
				playsound(src.loc, src.hitsound, 100, 1)
				SPAWN(-1) //uhhh maybe let's not sleep() an attack_hand. fucky effects up the chain?
					sleep(0.3 SECONDS)
					playsound(src.loc, src.hitsound, 100, 1)
					sleep(0.3 SECONDS)
					playsound(src.loc, src.hitsound, 100, 1)
				return

	attackby(obj/item/W, mob/user)
		user.lastattacked = src

		if (isscrewingtool(W))
			if (state == 10) // ???
				return
			else if (state >= 1)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
				if (deconstruct_time)
					var/total_decon_time = deconstruct_time
					if(ishuman(user))
						var/mob/living/carbon/human/H = user
						if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
							total_decon_time = round(total_decon_time / 2)
					user.show_text("You begin to [state == 1 ? "fasten the window to" : "unfasten the window from"] the frame...", "red")
					SETUP_GENERIC_ACTIONBAR(user, src, total_decon_time, /obj/window/proc/assembly_handler, list(user,W), W.icon, W.icon_state,null,null)
				else
					assembly_handler(user, W)
			else
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
				if (deconstruct_time)
					var/total_decon_time = deconstruct_time
					if(ishuman(user))
						var/mob/living/carbon/human/H = user
						if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
							total_decon_time = round(total_decon_time / 2)
					user.show_text("You begin to [src.anchored ? "unfasten the frame from" : "fasten the frame to"] the floor...", "red")
					SETUP_GENERIC_ACTIONBAR(user, src, total_decon_time, /obj/window/proc/assembly_handler, list(user,W), W.icon, W.icon_state,null,null)
				else
					assembly_handler(user, W)

		else if (ispryingtool(W) && state <= 1)
			//no sound here, snap is after the action
			if(!anchored)
				src.turn_window()
			else
				if (deconstruct_time)
					var/total_decon_time = deconstruct_time
					if(ishuman(user))
						var/mob/living/carbon/human/H = user
						if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
							total_decon_time = round(total_decon_time / 2)
					user.show_text("You begin to [src.state ? "pry the window out of" : "pry the window into"] the frame...", "red")
					SETUP_GENERIC_ACTIONBAR(user, src, total_decon_time, /obj/window/proc/assembly_handler, list(user,W), W.icon, W.icon_state,null,null)
				else
					assembly_handler(user, W)

		else if (iswrenchingtool(W) && src.state == 0 && !src.anchored)
			actions.start(new /datum/action/bar/icon/deconstruct_window(src, W), user)

		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (ishuman(G.affecting) && BOUNDS_DIST(G.affecting, src) == 0)
				src.visible_message("<span class='alert'><B>[user] slams [G.affecting]'s head into [src]!</B></span>")
				logTheThing(LOG_COMBAT, user, "slams [constructTarget(user,"combat")]'s head into [src]")
				playsound(src.loc, src.hitsound , 100, 1)
				G.affecting.TakeDamage("head", 5, 0)
				src.damage_blunt(G.affecting.throwforce)
				qdel(W)
		else
			attack_particle(user,src)
			playsound(src.loc, src.hitsound , 75, 1)
			src.damage_blunt(W.force)
			..()
		return

	proc/assembly_handler(var/mob/user,var/obj/item/W)
		if(isscrewingtool(W))
			if(state >= 1)
				state = 3 - state //cargo culting this a bit
				user.show_text("You have [state == 1 ? "unfastened the window from" : "fastened the window to"] the frame.", "blue")
			else
				src.anchored = !(src.anchored)
				src.stops_space_move = !(src.stops_space_move)
				user.show_text("You have [src.anchored ? "fastened the frame to" : "unfastened the frame from"] the floor.", "blue")
				logTheThing(LOG_STATION, user, "[src.anchored ? " anchored" : " unanchored"] [src] at [log_loc(src)].")
				src.align_window()
		else if(ispryingtool(W) && src.anchored)
			state = 1 - state
			user.show_text("You have [src.state ? "pried the window into" : "pried the window out of"] the frame.", "blue")
			playsound(src.loc, 'sound/items/Crowbar.ogg', 75, 1)

	proc/align_window()
		update_nearby_tiles(need_rebuild=1)
		src.ini_dir = src.dir
		src.set_layer_from_settings()
		if(istype(src,/obj/window/auto))
			var/obj/window/auto/AWI = src
			AWI.UpdateIcon()
			AWI.update_neighbors()

	proc/turn_window()
		update_nearby_tiles(need_rebuild=1) //Compel updates before
		src.set_dir(turn(src.dir, -90))
		update_nearby_tiles(need_rebuild=1)
		src.ini_dir = src.dir
		src.set_layer_from_settings()

	proc/smash()
		logTheThing(LOG_STATION, usr, "smashes a [src] in [src.loc?.loc] ([log_loc(src)])")
		if (src.health < (src.health_max * -0.75))
			// You managed to destroy it so hard you ERASED it.
			qdel(src)
			return
		var/atom/movable/A
		// catastrophic event litter reduction
		if(limiter.canISpawn(/obj/item/raw_material/shard))
			A = new /obj/item/raw_material/shard
			A.set_loc(src.loc)
			if(src.material)
				A.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("glass")
				A.setMaterial(M)
		if(reinforcement && limiter.canISpawn(/obj/item/rods))
			A = new /obj/item/rods(src.loc)
			A.setMaterial(reinforcement)
		playsound(src, src.shattersound, 70, 1)
		qdel(src)

	proc/update_nearby_tiles(need_rebuild, var/selfnotify = 0)
		if(!air_master) return 0

		var/turf/simulated/source = loc
		var/turf/simulated/target = get_step(source,dir)

		if(need_rebuild)
			if(istype(source)) //Rebuild/update nearby group geometry
				if(source.parent)
					air_master.groups_to_rebuild |= source.parent
				else
					air_master.tiles_to_update |= source
			if(istype(target))
				if(target.parent)
					air_master.groups_to_rebuild |= target.parent
				else
					air_master.tiles_to_update |= target
		else
			if(istype(source)) air_master.tiles_to_update |= source
			if(istype(target)) air_master.tiles_to_update |= target

		if (map_currently_underwater)
			var/turf/space/fluid/n = get_step(src,NORTH)
			var/turf/space/fluid/s = get_step(src,SOUTH)
			var/turf/space/fluid/e = get_step(src,EAST)
			var/turf/space/fluid/w = get_step(src,WEST)
			if(istype(n))
				n.tilenotify(src.loc)
			if(istype(s))
				s.tilenotify(src.loc)
			if(istype(e))
				e.tilenotify(src.loc)
			if(istype(w))
				w.tilenotify(src.loc)

		if (selfnotify && istype(source))
			source.selftilenotify() //for fluids

		return 1


/datum/action/bar/icon/deconstruct_window
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "deconstruct_window"
	icon = 'icons/ui/actions.dmi'
	icon_state = "decon"
	var/obj/window/the_window
	var/obj/item/the_tool

	New(var/obj/window/windw, var/obj/item/tool)
		..()
		if (windw)
			the_window = windw
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, the_window) > 0 || the_window == null || owner == null || the_tool == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, the_window) > 0 || the_window == null || owner == null || the_tool == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		boutput(owner, "<span class='notice'>Now disassembling [the_window]</span>")
		playsound(the_window.loc, 'sound/items/Ratchet.ogg', 100, 1)

	onEnd()
		..()
		if(BOUNDS_DIST(owner, the_window) > 0 || the_window == null || owner == null || the_tool == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(ismob(owner))
			var/mob/M = owner
			if (!(the_tool in M.equipped_list()))
				interrupt(INTERRUPT_ALWAYS)
				return
		boutput(owner, "<span class='notice'>You dissasembled [the_window]!</span>")
		var/obj/item/sheet/A = new /obj/item/sheet(get_turf(the_window))
		if(the_window.material)
			A.setMaterial(the_window.material)
		else
			var/datum/material/M = getMaterial("glass")
			A.setMaterial(M)
		if(!(the_window.dir in cardinal)) // full window takes two sheets to make
			A.amount += 1
		if(the_window.reinforcement)
			A.set_reinforcement(the_window.reinforcement)
		qdel(the_window)

	onInterrupt()
		if (owner)
			boutput(owner, "<span class='alert'>Deconstruction of [the_window] interrupted!</span>")
		..()

/obj/window/pyro
	icon_state = "pyro"

/obj/window/reinforced
	icon_state = "rwindow"
	default_reinforcement = "steel"
	health = 50
	health_max = 50
	the_tuff_stuff
		explosion_resistance = 5

/obj/window/reinforced/pyro
	icon_state = "rpyro"

/obj/window/crystal
	default_material = "plasmaglass"
	hitsound = 'sound/impact_sounds/Crystal_Hit_1.ogg'
	shattersound = 'sound/impact_sounds/Crystal_Shatter_1.ogg'
	health = 80
	health_max = 80
	explosion_resistance = 2
	deconstruct_time = 2 SECONDS

/obj/window/crystal/pyro
	icon_state = "pyro"

/obj/window/crystal/reinforced
	icon_state = "rwindow"
	default_reinforcement = "steel"
	health = 100
	health_max = 100
	explosion_resistance = 4
	deconstruct_time = 5 SECONDS

/obj/window/crystal/reinforced/pyro
	icon_state = "rpyro"

//an unbreakable window
/obj/window/bulletproof
	name = "bulletproof window"
	desc = "A specially made, heavily reinforced window. Trying to break or shoot through this would be a waste of time."
	icon_state = "rwindow"
	default_material = "uqillglass"
	health_multiplier = 100
	deconstruct_time = 10 SECONDS

/obj/window/bulletproof/pyro
	icon_state = "rpyro"
/*
/obj/window/supernorn
	icon = 'icons/Testing/newicons/obj/NEWstructures.dmi'
	dir = 5

	attackby() // TODO: need to be able to smash them, this is a hack
	rotate()
		set hidden = 1

	New()
		for (var/turf/simulated/wall/auto/T in orange(1))
			T.UpdateIcon()
*/
/obj/window/north
	dir = NORTH

/obj/window/east
	dir = EAST

/obj/window/west
	dir = WEST

/obj/window/south
	dir = SOUTH

/obj/window/crystal/north
	dir = NORTH

/obj/window/crystal/east
	dir = EAST

/obj/window/crystal/west
	dir = WEST

/obj/window/crystal/south
	dir = SOUTH

/obj/window/crystal/reinforced/north
	dir = NORTH

/obj/window/crystal/reinforced/east
	dir = EAST

/obj/window/crystal/reinforced/west
	dir = WEST

/obj/window/crystal/reinforced/south
	dir = SOUTH

/obj/window/reinforced/north
	dir = NORTH

/obj/window/reinforced/east
	dir = EAST

/obj/window/reinforced/west
	dir = WEST

/obj/window/reinforced/south
	dir = SOUTH

/obj/window/bulletproof/north
	dir = NORTH

/obj/window/bulletproof/east
	dir = EAST

/obj/window/bulletproof/west
	dir = WEST

/obj/window/bulletproof/south
	dir = SOUTH

/obj/window/auto
	icon = 'icons/obj/window_pyro.dmi'
	icon_state = "mapwin"
	dir = 5
	health_multiplier = 2
	alpha = 160
	object_flags = 0 // so they don't inherit the HAS_DIRECTIONAL_BLOCKING flag from thindows
	flags = FPRINT | USEDELAY | ON_BORDER | ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID

	var/mod = "W-"
	var/static/list/connects_to = typecacheof(list(
		/obj/machinery/door,
		/obj/window,
		/turf/simulated/wall/auto/supernorn,
		/turf/simulated/wall/auto/reinforced/supernorn,
		/turf/unsimulated/wall/auto/reinforced/supernorn,

		/turf/simulated/shuttle/wall,
		/turf/unsimulated/wall,
		/turf/simulated/wall/auto/shuttle,
		/obj/indestructible/shuttle_corner,

		/turf/simulated/wall/auto/reinforced/supernorn/yellow,
		/turf/simulated/wall/auto/reinforced/supernorn/blackred,
		/turf/simulated/wall/auto/reinforced/supernorn/orange,
		/turf/simulated/wall/auto/reinforced/paper,
		/turf/simulated/wall/auto/jen,
		/turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/auto/supernorn/wood,
		/turf/unsimulated/wall/auto/supernorn/wood,

		/turf/unsimulated/wall/auto/lead/blue,
		/turf/unsimulated/wall/auto/adventure/shuttle/dark,
		/turf/simulated/wall/auto/reinforced/old,
		/turf/unsimulated/wall/auto/adventure/old,
		/turf/unsimulated/wall/auto/adventure/mars/interior,
		/turf/unsimulated/wall/auto/adventure/shuttle,
		/turf/simulated/wall/auto/marsoutpost,
		/turf/simulated/wall/false_wall,
	))

	/// Gotta be a typecache list
	var/static/list/connects_to_exceptions = typecacheof(list(
		/obj/window/reinforced,
		/obj/window/cubicle,
		/turf/unsimulated/wall/auto/lead/blue,
	))
	var/static/list/connects_with_overlay_exceptions = typecacheof(list(
		/obj/window,
		/obj/machinery/door/poddoor
	))

	New()
		..()

		if (map_setting && ticker)
			src.update_neighbors()

		SPAWN(0)
			src.UpdateIcon()

	disposing()
		..()

		if (map_setting)
			src.update_neighbors()

	update_icon()
		if (!src.anchored)
			icon_state = "[mod]0"
			src.UpdateOverlays(null, "connect")
			return

		var/connectdir = get_connected_directions_bitflag(connects_to, connects_to_exceptions, connect_diagonal=1)
		var/overlaydir = get_connected_directions_bitflag(connects_to, (connects_to_exceptions + connects_with_overlay_exceptions), connect_diagonal=1)

		src.icon_state = "[mod][connectdir]"
		if (overlaydir)
			if (!src.connect_image)
				src.connect_image = image(src.icon, "overlay-[overlaydir]")
			else
				src.connect_image.icon_state = "overlay-[overlaydir]"
				src.UpdateOverlays(src.connect_image, "connect")
		else
			src.UpdateOverlays(null, "connect")

	proc/update_neighbors()
		for (var/turf/simulated/wall/auto/T in orange(1,src))
			T.UpdateIcon()
		for (var/obj/window/auto/O in orange(1,src))
			O.UpdateIcon()
		for (var/obj/grille/G in orange(1,src))
			G.UpdateIcon()

/obj/window/auto/the_tuff_stuff
	explosion_resistance = 3

/obj/window/auto/reinforced
	icon_state = "mapwin_r"
	mod = "R-"
	default_reinforcement = "steel"
	health = 50
	health_max = 50
	the_tuff_stuff
		explosion_resistance = 5

/obj/window/auto/reinforced/indestructible
	desc = "A window. A particularly robust one at that."

	New()
		..()
		SPAWN(1 DECI SECOND)
			ini_dir = 5//gurgle
			set_dir(5)//grumble

	smash(var/actuallysmash)
		if(actuallysmash)
			return ..()

	attack_hand(mob/user)
		if(!ON_COOLDOWN(user, "glass_tap", 5 SECONDS))
			src.visible_message("<span class='alert'><b>[user]</b> knocks on [src].</span>")
			playsound(src.loc, src.hitsound, 100, 1)
			sleep(0.3 SECONDS)
			playsound(src.loc, src.hitsound, 100, 1)
			sleep(0.3 SECONDS)
			playsound(src.loc, src.hitsound, 100, 1)
		return

	attackby()
	hitby()
		SHOULD_CALL_PARENT(FALSE)
	reagent_act()
	bullet_act()
	ex_act()
	blob_act()
	meteorhit()
	damage_heat()
	damage_corrosive()
	damage_piercing()
	damage_slashing()
	damage_blunt()

/obj/window/auto/reinforced/indestructible/extreme
	name = "extremely indestructible window"
	desc = "An EXTREMELY indestructible window. An absurdly robust one at that."
	var/initialPos
	anchored = 2
	New()
		..()
		initialPos = loc

	disposing()
		SHOULD_CALL_PARENT(0) //These are ACTUALLY indestructible.

		SPAWN(0)
			loc = initialPos
			qdeled = 0// L   U    L

	set_loc()
		SHOULD_CALL_PARENT(FALSE)
		loc = initialPos
		return

	Del()
		if(!initialPos)
			return ..()
		loc = initialPos//LULLE

/obj/window/auto/crystal
	default_material = "plasmaglass"
	hitsound = 'sound/impact_sounds/Crystal_Hit_1.ogg'
	shattersound = 'sound/impact_sounds/Crystal_Shatter_1.ogg'
	health = 80
	health_max = 80
	deconstruct_time = 2 SECONDS

/obj/window/auto/crystal/reinforced
	icon_state = "mapwin_r"
	mod = "R-"
	default_reinforcement = "steel"
	health = 100
	health_max = 100
	deconstruct_time = 5 SECONDS

/obj/window/auto/bulletproof
	name = "bulletproof window"
	desc = "A specially made, heavily reinforced window. Trying to break or shoot through this would be a waste of time."
	icon_state = "mapwin_r"
	default_material = "uqillglass"
	health_multiplier = 100
	deconstruct_time = 10 SECONDS

/obj/window/auto/hardened
	name = "hardened window"
	desc = "A hardened external window reinforced with advanced materials."
	icon_state = "mapwin_r"
	default_material = "uqillglass"
	default_reinforcement = "bohrum"
	the_tuff_stuff
		explosion_resistance = 5

/obj/wingrille_spawn
	name = "window grille spawner"
	icon = 'icons/obj/window.dmi'
	icon_state = "wingrille"
	density = 1
	anchored = 1
	invisibility = INVIS_ALWAYS
	//layer = 99
	pressure_resistance = 4*ONE_ATMOSPHERE
	var/win_path = "/obj/window"
	var/grille_path = "/obj/grille/steel"
	var/full_win = 0 // adds a full window as well
	var/no_dirs = 0 //ignore directional

	New()
		..()
		if(current_state >= GAME_STATE_WORLD_INIT)
			SPAWN(0)
				initialize()

	initialize()
		. = ..()
		src.set_up()
		qdel(src)

	proc/set_up()
		if (!locate(text2path(src.grille_path)) in get_turf(src))
			var/obj/grille/new_grille = text2path(src.grille_path)
			new new_grille(src.loc)

		if (!no_dirs)
			for (var/dir in cardinal)
				var/turf/T = get_step(src, dir)
				if ((!locate(/obj/wingrille_spawn) in T) && (!locate(/obj/grille) in T))
					var/obj/window/new_win = text2path("[src.win_path]/[dir2text(dir)]")
					if(new_win)
						new new_win(src.loc)
					else
						CRASH("Invalid path: [src.win_path]/[dir2text(dir)]")
		if (src.full_win)
			if(!no_dirs || !locate(text2path(src.win_path)) in get_turf(src))
				// if we have directional windows, there's already a window (or windows) from directional windows
				// only check if there's no window if we're expecting there to be no window so spawn a full window
				var/obj/window/new_win = text2path(src.win_path)
				new new_win(src.loc)

	full
		icon_state = "wingrille_f"
		full_win = 1

	reinforced
		name = "reinforced window grille spawner"
		icon_state = "r-wingrille"
		win_path = "/obj/window/reinforced"

		full
			icon_state = "r-wingrille_f"
			full_win = 1

	crystal
		name = "crystal window grille spawner"
		icon_state = "p-wingrille"
		win_path = "/obj/window/crystal"

		full
			icon_state = "p-wingrille_f"
			full_win = 1

	reinforced_crystal
		name = "reinforced crystal window grille spawner"
		icon_state = "pr-wingrille"
		win_path = "/obj/window/crystal/reinforced"

		full
			icon_state = "pr-wingrille_f"
			full_win = 1

	bulletproof
		name = "bulletproof window grille spawner"
		icon_state = "br-wingrille"
		win_path = "/obj/window/bulletproof"

		full
			name = "bulletproof window grille spawner"
			icon_state = "br-wingrille"
			icon_state = "b-wingrille_f"
			full_win = 1

	hardened
		name = "hardened window grille spawner"
		icon_state = "br-wingrille"
		win_path = "/obj/window/hardened"

		full
			name = "hardened window grille spawner"
			icon_state = "br-wingrille"
			icon_state = "b-wingrille_f"
			full_win = 1


	auto
		name = "autowindow grille spawner"
		win_path = "/obj/window/auto"
		full_win = 1
		no_dirs = 1
		icon_state = "wingrille_f"

		reinforced
			name = "reinforced autowindow grille spawner"
			win_path = "/obj/window/auto/reinforced"
			icon_state = "r-wingrille_f"

		crystal
			name = "crystal autowindow grille spawner"
			win_path = "/obj/window/auto/crystal"
			icon_state = "p-wingrille_f"

			reinforced
				name = "reinforced crystal autowindow grille spawner"
				win_path = "/obj/window/auto/crystal/reinforced"
				icon_state = "pr-wingrille_f"

		tuff
			name = "tuff stuff reinforced autowindow grille spawner"
			win_path = "/obj/window/auto/reinforced/the_tuff_stuff"

//Cubicle walls! Also for the crunch. - from halloween.dm
/obj/window/cubicle
	name = "cubicle panel"
	desc = "The bland little uniform panels that make up the modern office place. It is within them that you will spend your adult life.  It is within them that you will die."
	icon = 'icons/obj/structures.dmi'
	icon_state = "cubicle"
	opacity = 1
	hitsound = 'sound/impact_sounds/Metal_Hit_Light_1.ogg'
	shattersound = 'sound/impact_sounds/Metal_Hit_Light_1.ogg'
	default_material = null

	New()
		..()

	update_nearby_tiles(need_rebuild, selfnotify)
		return

	smash()
		if(health <= 0)
			qdel(src)

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			src.anchored = !( src.anchored )
			src.stops_space_move = !(src.stops_space_move)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (src.anchored ? "You have fastened [src] to the floor." : "You have unfastened [src].")
			return

		else
			..()

	railing
		name = "guard railing"
		desc = "Doesn't look very sturdy, but it's better than nothing?"
		opacity = 0
		icon_state = "safetyrail"
		layer = EFFECTS_LAYER_BASE
		dir = 1
		default_material = "metal"

// flock windows

/obj/window/auto/feather
	default_material = "gnesisglass"
	var/flock_id = "Fibrewoven window"
	var/repair_per_resource = 1

/obj/window/auto/feather/New()
	connects_to += /turf/simulated/wall/auto/feather
	..()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection, FALSE, TRUE, TRUE)

/obj/window/auto/feather/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> [src.flock_id]
		<br><span class='bold'>System Integrity:</span> [round((src.health/src.health_max)*100)]%
		<br><span class='bold'>###=-</span></span>"}

/obj/window/auto/feather/proc/repair(resources_available)
	var/health_given = min(min(resources_available, FLOCK_REPAIR_COST) * src.repair_per_resource, src.health_max - src.health)
	src.health += health_given
	return ceil(health_given / src.repair_per_resource)

/obj/window/auto/feather/Crossed(atom/movable/mover)
	. = ..()
	var/mob/living/critter/flock/drone/drone = mover
	if(istype(drone) && isfeathertile(src.loc) && (drone.is_npc || (drone.client && drone.client.check_key(KEY_RUN))))
		if(drone.floorrunning || (drone.can_floorrun && drone.resources >= 1))
			drone.set_loc(src.loc)
			drone.start_floorrunning()
			return TRUE

/obj/window/auto/feather/Cross(atom/movable/mover)
	if(istype(mover, /mob/living/critter/flock/drone))
		var/mob/living/critter/flock/drone/F = mover
		return isfeathertile(src.loc) && (F.floorrunning || (F.can_floorrun && F.resources >= 1)) && (F.is_npc || (F.client && F.client.check_key(KEY_RUN)))

/obj/window/feather
	var/flock_id = "Fibrewoven window"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "window"
	default_material = "gnesisglass"
	hitsound = 'sound/impact_sounds/Crystal_Hit_1.ogg'
	shattersound = 'sound/impact_sounds/Crystal_Shatter_1.ogg'
	mat_appearances_to_ignore = list("gnesis")
	mat_changename = FALSE
	mat_changedesc = FALSE
	health = 50 // as strong as reinforced glass, but not as strong as plasmaglass
	health_max = 50
	var/repair_per_resource = 1
	density = TRUE

/obj/window/feather/New()
	..()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection)

/obj/window/feather/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> [src.flock_id]
		<br><span class='bold'>System Integrity:</span> [round((src.health/src.health_max)*100)]%
		<br><span class='bold'>###=-</span></span>"}

/obj/window/feather/proc/repair(resources_available)
	var/health_given = min(min(resources_available, FLOCK_REPAIR_COST) * src.repair_per_resource, src.health_max - src.health)
	src.health += health_given
	return ceil(health_given / src.repair_per_resource)

/obj/window/feather/north
	dir = NORTH

/obj/window/feather/east
	dir = EAST

/obj/window/feather/west
	dir = WEST

/obj/window/feather/south
	dir = SOUTH
