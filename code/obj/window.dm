/obj/window
	name = "window"
	icon = 'icons/obj/window.dmi'
	icon_state = "window"
	desc = "A window."
	density = 1
	stops_space_move = 1
	dir = 5 //full tile
	flags = FPRINT | USEDELAY | ON_BORDER | ALWAYS_SOLID_FLUID
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT | USE_CANPASS
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
	var/deconstruct_time = 0//20
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1
	the_tuff_stuff
		explosion_resistance = 3
	New()
		..()
		src.ini_dir = src.dir
		update_nearby_tiles(need_rebuild=1)
		var/datum/material/M
		if (default_material)
			M = getMaterial(default_material)
			src.setMaterial(M)
		if (default_reinforcement)
			src.reinforcement = getMaterial(default_reinforcement)
		onMaterialChanged()

		// The health multiplier var wasn't implemented at all, apparently (Convair880)?
		if (src.health_multiplier != 1 && src.health_multiplier > 0)
			src.health_max = src.health_max * src.health_multiplier
			src.health = src.health_max
			//DEBUG ("[src.name] [log_loc(src)] has [health] health / [health_max] max health ([health_multiplier] multiplier).")

		if(current_state >= GAME_STATE_WORLD_INIT)
			SPAWN_DBG(0)
				initialize()

	initialize()
		src.set_layer_from_settings()
		update_nearby_tiles(need_rebuild=1)
		..()

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
		density = 0
		update_nearby_tiles(need_rebuild=1)
		..()

	Move()
		set_density(0) //mbc : icky but useful for fluids
		update_nearby_tiles(need_rebuild=1, selfnotify = 1) //only selfnotify when density is 0, because i dont want windows to displace fluids every single move() step. would be slow probably
		set_density(1)
		..()


		src.dir = src.ini_dir
		update_nearby_tiles(need_rebuild=1)

		return

	onMaterialChanged()
		..()

		name = initial(name)

		if (istype(src.material))
			health_max = material.hasProperty("density") ? round(max(material.getProperty("density"), 100) * 1.5) : health_max
			health = health_max
			cut_resist = material.hasProperty("hard") ? material.getProperty("hard")*2 : cut_resist
			blunt_resist = material.hasProperty("density") ? material.getProperty("density")*2 : blunt_resist
			stab_resist = material.hasProperty("hard") ? material.getProperty("hard")*2 : stab_resist
			if (blunt_resist != 0) blunt_resist /= 2
			corrode_resist = material.hasProperty("corrosion") ? material.getProperty("corrosion") : corrode_resist

			if (material.alpha > 220)
				opacity = 1 // useless opaque window
			else
				opacity = 0

			name = "[getQualityName(material.quality)] [material.name] " + name

		if (istype(reinforcement))
			if(reinforcement.hasProperty("density"))
				health_max += reinforcement.hasProperty("density") ? round(reinforcement.getProperty("density") / 2) : 0
				health = health_max
			else
				health_max += 30
				health = health_max
			cut_resist += reinforcement.hasProperty("hard") ? round(reinforcement.getProperty("hard") / 2) : 0
			blunt_resist += reinforcement.hasProperty("density") ? round(reinforcement.getProperty("density") / 2) : 0
			stab_resist += reinforcement.hasProperty("hard") ? round(reinforcement.getProperty("hard") / 2) : 0
			corrode_resist += reinforcement.hasProperty("corrosion") ? round(reinforcement.getProperty("corrosion") / 2) : 0

			name = "[reinforcement.name]-reinforced " + name

	proc/set_reinforcement(var/datum/material/M)
		if (!M)
			return
		reinforcement = M
		onMaterialChanged()

	damage_blunt(var/amount, var/nosmash)
		if (!isnum(amount) || amount <= 0)
			return

		var/armor = 0

		if (src.material)
			armor = blunt_resist

			if (src.material.getProperty("density") >= 10)
				armor += round(src.material.getProperty("density") / 10)
			else if (src.material.hasProperty("density") && src.material.getProperty("density") < 10)
				amount += rand(1,3)

		amount = get_damage_after_percentage_based_armor_reduction(armor,amount)

		src.health = max(0,min(src.health - amount,src.health_max))

		if (src.health == 0 && nosmash)
			qdel(src)
		else if (src.health == 0 && !nosmash)
			smash()

	damage_slashing(var/amount)
		if (!isnum(amount))
			return

		amount = get_damage_after_percentage_based_armor_reduction(cut_resist,amount)
		if (src.quality < 10)
			amount += rand(1,3)

		if (amount <= 0)
			return

		src.health = max(0,min(src.health - amount,src.health_max))
		if (src.health == 0)
			smash()

	damage_piercing(var/amount)
		if (!isnum(amount))
			return

		amount = get_damage_after_percentage_based_armor_reduction(stab_resist,amount)
		if (src.quality < 10)
			amount += rand(1,3)

		if (amount <= 0)
			return

		src.health = max(0,min(src.health - amount,src.health_max))
		if (src.health == 0)
			smash()

	damage_corrosive(var/amount)
		if (!isnum(amount) || amount <= 0)
			return

		amount = get_damage_after_percentage_based_armor_reduction(corrode_resist,amount)
		if (amount <= 0)
			return
		src.health = max(0,min(src.health - amount,src.health_max))
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
		src.health = max(0,min(src.health - amount,src.health_max))
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

		if(src.material) src.material.triggerOnBullet(src, src, P)

		switch(P.proj_data.damage_type)
			if(D_KINETIC)
				damage_blunt(damage*3)
			if(D_PIERCING)
				damage_piercing(damage*2)
			if(D_ENERGY)
				damage_heat(damage / 5)
		return

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

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(istype(mover, /obj/projectile))
			var/obj/projectile/P = mover
			if(P.proj_data.window_pass)
				return 1
		if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST)
			return 0 //full tile window, you can't move into it!
		if(get_dir(loc, target) == dir)

			return !density
		else
			return 1

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if (!src.density)
			return 1
		if(istype(O, /obj/projectile))
			var/obj/projectile/P = O
			if(P.proj_data.window_pass)
				return 1
		if (get_dir(O.loc, target) == src.dir)
			return 0
		return 1

	hitby(AM as mob|obj)
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
			step(src, get_dir(AM, src))
		..()
		return

	attack_hand(mob/user as mob)
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
			if (ishuman(usr))
				src.visible_message("<span class='alert'><b>[usr]</b> knocks on [src].</span>")
				playsound(src.loc, src.hitsound, 100, 1)
				SPAWN_DBG(-1) //uhhh maybe let's not sleep() an attack_hand. fucky effects up the chain?
					sleep(0.3 SECONDS)
					playsound(src.loc, src.hitsound, 100, 1)
					sleep(0.3 SECONDS)
					playsound(src.loc, src.hitsound, 100, 1)
				return

	attackby(obj/item/W as obj, mob/user as mob)
		user.lastattacked = src

		if (isscrewingtool(W))
			if (state == 10)
				return
			else if (state >= 1)
				playsound(src.loc, "sound/items/Screwdriver.ogg", 75, 1)
				if (deconstruct_time)
					user.show_text("You begin to [state == 1 ? "fasten the window to" : "unfasten the window from"] the frame...", "red")
					if (!do_after(user, deconstruct_time))
						boutput(user, "<span class='alert'>You were interrupted.</span>")
						return
				state = 3 - state
				user.show_text("You have [state == 1 ? "unfastened the window from" : "fastened the window to"] the frame.", "blue")
			else if (state == 0)
				playsound(src.loc, "sound/items/Screwdriver.ogg", 75, 1)
				if (deconstruct_time)
					user.show_text("You begin to [src.anchored ? "unfasten the frame from" : "fasten the frame to"] the floor...", "red")
					if (!do_after(user, deconstruct_time))
						boutput(user, "<span class='alert'>You were interrupted.</span>")
						return
				src.anchored = !(src.anchored)
				user.show_text("You have [src.anchored ? "fastened the frame to" : "unfastened the frame from"] the floor.", "blue")
				return 1
			else
				playsound(src.loc, "sound/items/Screwdriver.ogg", 75, 1)
				if (deconstruct_time)
					user.show_text("You begin to [src.anchored ? "unfasten the window from" : "fasten the window to"] the floor...", "red")
					if (!do_after(user, deconstruct_time))
						boutput(user, "<span class='alert'>You were interrupted.</span>")
						return
				src.anchored = !(src.anchored)
				user.show_text("You have [src.anchored ? "fastened the window to" : "unfastened the window from"] the floor.", "blue")
				return 1

		else if (ispryingtool(W) && state <= 1)
			if(!anchored)
				if (!(src.dir in cardinal))
					return
				update_nearby_tiles(need_rebuild=1) //Compel updates before
				src.dir = turn(src.dir, -90)
				/*var/action = input(usr,"Rotate it which way?","Window Rotation",null) in list("Clockwise ->","Anticlockwise <-","180 Degrees")
				if (!action) return*/

				/*switch(action)
					if ("Clockwise ->") src.dir = turn(src.dir, -90)
					if ("Anticlockwise <-") src.dir = turn(src.dir, 90)
					if ("180 Degrees") src.dir = turn(src.dir, 180)*/
				update_nearby_tiles(need_rebuild=1)
				src.ini_dir = src.dir
				src.set_layer_from_settings()
				return
			playsound(src.loc, "sound/items/Crowbar.ogg", 75, 1)
			if (deconstruct_time)
				user.show_text("You begin to [src.state ? "pry the window out of" : "pry the window into"] the frame...", "red")
				if (!do_after(user, deconstruct_time))
					boutput(user, "<span class='alert'>You were interrupted.</span>")
					return
			state = 1 - state
			user.show_text("You have [src.state ? "pried the window into" : "pried the window out of"] the frame.", "blue")

		else if (iswrenchingtool(W) && src.state == 0 && !src.anchored)
			playsound(src.loc, "sound/items/Ratchet.ogg", 100, 1)
			var/turf/T = get_turf(user)
			boutput(user, "<span class='notice'>Now disassembling the window</span>")
			sleep(4 SECONDS) // this should be a progressbar but other contruction / deconstruction things don't have them
			// so I'll just leave it as sleep and hope someone else replaces all of these with progressbars
			if(get_turf(user) == T)
				boutput(user, "<span class='notice'>You dissasembled the window!</span>")
				var/obj/item/sheet/A = new /obj/item/sheet(get_turf(src))
				if (src.material)
					A.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("glass")
					A.setMaterial(M)
				if(!(src.dir in cardinal)) // full window takes two sheets to make
					A.amount += 1
				if(src.reinforcement)
					A.set_reinforcement(src.reinforcement)
				qdel(src)

		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (ishuman(G.affecting) && get_dist(G.affecting, src) <= 1)
				src.visible_message("<span class='alert'><B>[user] slams [G.affecting]'s head into [src]!</B></span>")
				logTheThing("combat", user, G.affecting, "slams [constructTarget(user,"combat")]'s head into [src]")
				playsound(src.loc, src.hitsound , 100, 1)
				G.affecting:TakeDamage("head", 0, 5)
				src.damage_blunt(G.affecting.throwforce)
				qdel(W)
		else
			attack_particle(user,src)
			playsound(src.loc, src.hitsound , 75, 1)
			src.damage_blunt(W.force)
			if (src.health <= 2)
				src.anchored = 0
				step(src, get_dir(user, src))
			..()
		return

	proc/smash()
		if (src.health < (src.health_max * -0.75))
			// You managed to destroy it so hard you ERASED it.
			qdel(src)
			return
		var/atom/movable/A
		// catastrophic event litter reduction
		if(limiter.canISpawn(/obj/item/raw_material/shard))
			A = unpool(/obj/item/raw_material/shard)
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
					air_master.queue_update_group(source.parent)
				else
					air_master.queue_update_tile(source)
			if(istype(target))
				if(target.parent)
					air_master.queue_update_group(target.parent)
				else
					air_master.queue_update_tile(target)
		else
			if(istype(source)) air_master.queue_update_tile(source)
			if(istype(target)) air_master.queue_update_tile(target)

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

/obj/window/pyro
	icon_state = "pyro"

/obj/window/reinforced
	icon_state = "rwindow"
	default_reinforcement = "steel"
	health = 50
	health_max = 50
	the_tuff_stuff
		explosion_resistance = 5
	//deconstruct_time = 30

/obj/window/reinforced/pyro
	icon_state = "rpyro"

/obj/window/crystal
	default_material = "plasmaglass"
	hitsound = 'sound/impact_sounds/Crystal_Hit_1.ogg'
	shattersound = 'sound/impact_sounds/Crystal_Shatter_1.ogg'
	health = 80
	health_max = 80
	explosion_resistance = 2
	//deconstruct_time = 40

/obj/window/crystal/pyro
	icon_state = "pyro"

/obj/window/crystal/reinforced
	icon_state = "rwindow"
	default_reinforcement = "steel"
	health = 100
	health_max = 100
	explosion_resistance = 4
	//deconstruct_time = 50

/obj/window/crystal/reinforced/pyro
	icon_state = "rpyro"

//an unbreakable window
/obj/window/bulletproof
	name = "bulletproof window"
	desc = "A specially made, heavily reinforced window. Trying to break or shoot through this would be a waste of time."
	icon_state = "rwindow"
	default_material = "uqillglass"
	health_multiplier = 100
	//deconstruct_time = 100

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
			T.update_icon()
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
	//deconstruct_time = 20
	flags = FPRINT | USEDELAY | ON_BORDER | ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID

	var/mod = null
	var/list/connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn, /turf/simulated/wall/auto/supernorn/wood, /turf/simulated/wall/auto/marsoutpost,
		/turf/simulated/shuttle/wall, /turf/unsimulated/wall, /turf/simulated/wall/auto/shuttle, /obj/indestructible/shuttle_corner,
		/obj/machinery/door, /obj/window, /turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred, /turf/simulated/wall/auto/reinforced/supernorn/orange, /turf/simulated/wall/auto/reinforced/paper,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/jen/red, /turf/simulated/wall/auto/jen/green, /turf/simulated/wall/auto/jen/yellow, /turf/simulated/wall/auto/jen/cyan, /turf/simulated/wall/auto/jen/purple,  /turf/simulated/wall/auto/jen/blue,
		/turf/simulated/wall/auto/reinforced/jen, /turf/simulated/wall/auto/reinforced/jen/red, /turf/simulated/wall/auto/reinforced/jen/green, /turf/simulated/wall/auto/reinforced/jen/yellow, /turf/simulated/wall/auto/reinforced/jen/cyan, /turf/simulated/wall/auto/reinforced/jen/purple, /turf/simulated/wall/auto/reinforced/jen/blue)
	alpha = 160
	the_tuff_stuff
		explosion_resistance = 3
	New()
		..()

		if (map_setting && ticker)
			src.update_neighbors()

		SPAWN_DBG(0)
			src.update_icon()

	disposing()
		..()

		if (map_setting)
			src.update_neighbors()

	proc/update_icon()
		if (!src.anchored)
			icon_state = "[mod]0"
			return

		var/builtdir = 0
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (T && (T.type in connects_to))
				builtdir |= dir
			else if (islist(connects_to) && connects_to.len)
				for (var/i=1, i <= connects_to.len, i++)
					var/atom/A = locate(connects_to[i]) in T
					if (!isnull(A))
						if (istype(A, /atom/movable))
							var/atom/movable/M = A
							if (!M.anchored)
								continue
						builtdir |= dir
						break
		src.icon_state = "[mod][builtdir]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (..(W, user))
			src.update_icon()

	proc/update_neighbors()
		for (var/turf/simulated/wall/auto/T in orange(1,src))
			T.update_icon()
		for (var/obj/window/auto/O in orange(1,src))
			O.update_icon()

/obj/window/auto/reinforced
	icon_state = "mapwin_r"
	mod = "R"
	default_reinforcement = "steel"
	health = 50
	health_max = 50
	the_tuff_stuff
		explosion_resistance = 5
	//deconstruct_time = 30

/obj/window/auto/reinforced/indestructible
	desc = "A window. A particularly robust one at that."

	New()
		..()
		SPAWN_DBG(1 DECI SECOND)
			ini_dir = 5//gurgle
			dir = 5//grumble

	smash(var/actuallysmash)
		if(actuallysmash)
			return ..()

	attack_hand()
		src.visible_message("<span class='alert'><b>[usr]</b> knocks on [src].</span>")
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

		SPAWN_DBG(0)
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
	//deconstruct_time = 40

/obj/window/auto/crystal/reinforced
	icon_state = "mapwin_r"
	mod = "R"
	default_reinforcement = "steel"
	health = 100
	health_max = 100
	//deconstruct_time = 50

/obj/window/auto/bulletproof
	name = "bulletproof window"
	desc = "A specially made, heavily reinforced window. Trying to break or shoot through this would be a waste of time."
	icon_state = "mapwin_r"
	default_material = "uqillglass"
	health_multiplier = 100
	//deconstruct_time = 100

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
	anchored = 1.0
	invisibility = 101
	//layer = 99
	pressure_resistance = 4*ONE_ATMOSPHERE
	var/win_path = "/obj/window"
	var/grille_path = "/obj/grille/steel"
	var/full_win = 0 // adds a full window as well
	var/no_dirs = 0 //ignore directional

	New()
		SPAWN_DBG(1 DECI SECOND)
			src.set_up()
			SPAWN_DBG(1 SECOND)
				qdel(src)

	proc/set_up()
		if (!locate(text2path(src.grille_path)) in get_turf(src))
			var/obj/grille/new_grille = text2path(src.grille_path)
			new new_grille(src.loc)

		if (!no_dirs)
			for (var/dir in cardinal)
				var/turf/T = get_step(src, dir)
				if (!locate(/obj/wingrille_spawn) in T)
					var/obj/window/new_win = text2path("[src.win_path]/[dir2text(dir)]")
					new new_win(src.loc)
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
		name = "reinforced autowindow grille spawner"
		win_path = "/obj/window/auto/reinforced"
		full_win = 1
		no_dirs = 1
		icon_state = "r-wingrille_f"

		crystal
			name = "crystal autowindow grille spawner"
			win_path = "/obj/window/auto/crystal/reinforced"
			icon_state = "p-wingrille_f"

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

	New()
		return

	smash()
		if(health <= 0)
			qdel(src)

	attackby(obj/item/W as obj, mob/user as mob)
		if (isscrewingtool(W))
			src.anchored = !( src.anchored )
			playsound(src.loc, "sound/items/Screwdriver.ogg", 75, 1)
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


// Flockdrone BS goes here - cirr
/obj/window/feather
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "window"
	default_material = "gnesisglass"
	hitsound = 'sound/impact_sounds/Crystal_Hit_1.ogg'
	shattersound = 'sound/impact_sounds/Crystal_Shatter_1.ogg'
	health = 50 // as strong as reinforced glass, but not as strong as plasmaglass
	health_max = 50
	density = 1

/obj/window/feather/special_desc(dist, mob/user)
  if(isflock(user))
    var/special_desc = "<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received."
    special_desc += "<br><span class='bold'>ID:</span> Fibrewoven Window"
    special_desc += "<br><span class='bold'>System Integrity:</span> [round((src.health/src.health_max)*100)]%" // todo: damageable walls
    special_desc += "<br><span class='bold'>###=-</span></span>"
    return special_desc
  else
    return null // give the standard description

/obj/window/feather/north
	dir = NORTH

/obj/window/feather/east
	dir = EAST

/obj/window/feather/west
	dir = WEST

/obj/window/feather/south
	dir = SOUTH
