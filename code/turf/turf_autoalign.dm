
/* =================================================== */
/* -------------------- SIMULATED -------------------- */
/* =================================================== */

/turf/simulated/wall/auto
	icon = 'icons/turf/walls_auto.dmi'
	var/mod = null
	var/light_mod = null
	var/connect_overlay = 0 // do we have wall connection overlays, ex nornwalls?
	var/list/connects_to = list(/turf/simulated/wall/auto,/turf/simulated/wall/false_wall)
	var/list/connects_to_exceptions = list() // because connections now work by parent type searches, this is for when you don't want certain subtypes to connect
	var/list/connects_with_overlay = null
	var/list/connects_with_overlay_exceptions = list() // same as above comment
	var/image/connect_image = null
	var/tmp/connect_overlay_dir = 0
	var/d_state = 0

	New()
		..()
		if (map_setting && ticker)
			src.update_neighbors()

		if (current_state > GAME_STATE_WORLD_INIT)
			SPAWN_DBG(0) //worldgen overrides ideally
				src.update_icon()

		else
			worldgenCandidates[src] = 1

	generate_worldgen()
		src.update_icon()

	Del()
		src.RL_SetSprite(null)
		..()

	the_tuff_stuff
		explosion_resistance = 7
	// ty to somepotato for assistance with making this proc actually work right :I
	proc/update_icon()
		var/builtdir = 0
		if (connect_overlay && !islist(connects_with_overlay))
			connects_with_overlay = list()
		src.connect_overlay_dir = 0
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (T && (istype(T, src.type)))
				builtdir |= dir
			else if (connects_to)
				for (var/i=1, i <= connects_to.len, i++)
					// if the turf appears in our connection list AND isn't in our exceptions...
					if (istype(T, connects_to[i]) && !(T.type in connects_to_exceptions))
						builtdir |= dir
						break
					// Search for non-turf atoms we can connect to
					var/atom/A = locate(connects_to[i]) in T
					if (!isnull(A))
						if (istype(A, /atom/movable))
							var/atom/movable/M = A
							if (!M.anchored)
								continue
						builtdir |= dir
						break
			if (connect_overlay && connects_with_overlay)
				for (var/i=1, i <= connects_with_overlay.len, i++)
					// if the turf appears in our overlay'd connection list, AND isn't in our exceptions, AND isn't... well, a copy of ourselves...
					if (istype(T, connects_with_overlay[i]) && !(T.type in connects_with_overlay_exceptions) && !(T.type == src.type))
						src.connect_overlay_dir |= dir
						break
					// Search for non-turf atoms we can connect to
					var/atom/A = locate(connects_with_overlay[i]) in T
					if (!isnull(A))
						if (istype(A, /atom/movable))
							var/atom/movable/M = A
							if (!M.anchored)
								continue
						src.connect_overlay_dir |= dir

		var/the_state = "[mod][builtdir]"
		if ( !(istype(src, /turf/simulated/wall/auto/jen)) && !(istype(src, /turf/simulated/wall/auto/reinforced/jen)) ) //please no more sprite, i drained my brain doing this
			src.icon_state += "[src.d_state ? "C" : null]"
		icon_state = the_state

		if (light_mod)
			src.RL_SetSprite("[light_mod][builtdir]")

		if (connect_overlay)
			if (src.connect_overlay_dir)
				if (!src.connect_image)
					src.connect_image = image(src.icon, "connect[src.connect_overlay_dir]")
				else
					src.connect_image.icon_state = "connect[src.connect_overlay_dir]"
				src.UpdateOverlays(src.connect_image, "connect")
			else
				src.UpdateOverlays(null, "connect")

	proc/update_neighbors()
		for (var/turf/simulated/wall/auto/T in orange(1,src))
			T.update_icon()
		for (var/obj/grille/G in orange(1,src))
			G.update_icon()

/turf/simulated/wall/auto/reinforced
	name = "reinforced wall"
	health = 300
	explosion_resistance = 7
	mod = "R"
	icon_state = "mapwall_r"
	connects_to = list(/turf/simulated/wall/auto/reinforced,/turf/simulated/wall/false_wall/reinforced)
	the_tuff_stuff
		explosion_resistance = 11
		desc = "Looks <em>way</em> tougher than a regular wall."


	get_desc()
		switch (src.d_state)
			if (0)
				. += "<br>Looks like disassembling it starts with snipping some of those reinforcing rods."
			if (1)
				. += "<br>Up next in this long journey is unscrewing the support lines."
			if (2)
				. += "<br>What'd really help at this point is unwelding the metal cover."
			if (3)
				. += "<br>Your prying eyes suggest prying off the metal cover you just unwelded."
			if (4)
				. += "<br>The latest wrench in your plans for wall disassembly appear to be some support rods."
			if (5)
				. += "<br>Is this wall okay? It's looking a little under the welder. Or maybe that's just its support rods."
			if (6)
				. += "<br>Almost! Just need to pry off the outer sheath. Which you've somehow been working around this whole time. <em>Somehow</em>."


	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/light_parts))
			src.attach_light_fixture_parts(user, W) // Made this a proc to avoid duplicate code (Convair880).
			return

		/* ----- Deconstruction ----- */
		if (src.d_state == 0 && issnippingtool(W))
			actions.start(new /datum/action/bar/icon/wall_tool_interact(src, W, WALL_REMOVERERODS), user)
			return

		else if (src.d_state == 1 && isscrewingtool(W))
			actions.start(new /datum/action/bar/icon/wall_tool_interact(src, W, WALL_REMOVESUPPORTLINES), user)
			return

		else if (src.d_state == 2 && isweldingtool(W))
			if(!W:try_weld(user,1,-1,1,1))
				return
			actions.start(new /datum/action/bar/icon/wall_tool_interact(src, W, WALL_SLICECOVER), user)
			return

		else if (src.d_state == 3 && ispryingtool(W))
			actions.start(new /datum/action/bar/icon/wall_tool_interact(src, W, WALL_PRYCOVER), user)
			return

		else if (src.d_state == 4 && iswrenchingtool(W))
			actions.start(new /datum/action/bar/icon/wall_tool_interact(src, W, WALL_DETATCHSUPPORTRODS), user)
			return

		else if (src.d_state == 5 && isweldingtool(W))
			if(!W:try_weld(user,1,-1,1,1))
				return
			actions.start(new /datum/action/bar/icon/wall_tool_interact(src, W, WALL_REMOVESUPPORTRODS), user)
			return

		else if (src.d_state == 6 && ispryingtool(W))
			actions.start(new /datum/action/bar/icon/wall_tool_interact(src, W, WALL_PRYSHEATH), user)
			return


	/* ----- End Deconstruction ----- */

		else if (istype(W, /obj/item/device/key/haunted))
			var/obj/item/device/key/haunted/H = W
			//Okay, create a temporary false wall.
			if (H.last_use && ((H.last_use + 300) >= world.time))
				boutput(user, "<span class='alert'>The key won't fit in all the way!</span>")
				return
			user.visible_message("<span class='alert'>[user] inserts [W] into [src]!</span>","<span class='alert'>The key seems to phase into the wall.</span>")
			H.last_use = world.time
			blink(src)
			var/turf/simulated/wall/false_wall/temp/fakewall = new /turf/simulated/wall/false_wall/temp(src)
			fakewall.was_rwall = 1
			fakewall.opacity = 0
			fakewall.RL_SetOpacity(1) //Lighting rebuild.
			return

		else if (istype(W, /obj/item/sheet) && src.d_state)
			var/obj/item/sheet/S = W
			var/turf/T = user.loc
			boutput(user, "<span class='notice'>Repairing wall.</span>")
			sleep(2.5 SECONDS)
			if (user.loc == T && user.equipped() == S)
				src.d_state = 0
				src.icon_state = initial(src.icon_state)
				if (S.material)
					src.setMaterial(S.material)
				else
					var/datum/material/M = getMaterial("steel")
					src.setMaterial(M)
				boutput(user, "<span class='notice'>You repaired the wall.</span>")
				if (S.amount > 1)
					S.amount--
				else
					qdel(W)
				return

			else if (isrobot(user) && user.loc == T)
				src.d_state = 0
				src.icon_state = initial(src.icon_state)
				if (W.material)
					src.setMaterial(S.material)
				boutput(user, "<span class='notice'>You repaired the wall.</span>")
				if (S.amount > 1)
					S.amount--
				else
					qdel(W)
				return

		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!grab_smash(G, user))
				return ..(W, user)
			else
				return

		if (src.material)
			var/fail = 0
			if (src.material.hasProperty("stability") && src.material.getProperty("stability") < 15)
				fail = 1
			if (src.material.quality < 0) if(prob(abs(src.material.quality)))
				fail = 1
			if (fail)
				user.visible_message("<span class='alert'>You hit the wall and it [getMatFailString(src.material.material_flags)]!</span>","<span class='alert'>[user] hits the wall and it [getMatFailString(src.material.material_flags)]!</span>")
				playsound(src.loc, "sound/impact_sounds/Generic_Stab_1.ogg", 25, 1)
				del(src)
				return

		src.take_hit(W)

/turf/simulated/wall/auto/jen
	icon = 'icons/turf/walls_jen.dmi'
	light_mod = "wall-jen-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	connect_overlay = 1
	connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen)

	connects_with_overlay = list(/turf/simulated/wall/auto/reinforced/supernorn, /turf/simulated/wall/auto/supernorn,
	/turf/simulated/wall/false_wall/reinforced, /turf/simulated/wall/auto/shuttle, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred,
	/turf/simulated/wall/auto/reinforced/jen)

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.update_icon()

	the_tuff_stuff
		explosion_resistance = 7

	dark1
		color = "#dddddd"

	dark2
		color = "#bbbbbb"

	dark3
		color = "#999999"

	dark4
		color = "#777777"

	red
		color = "#ff9999"

	orange
		color = "#ffc599"

	brown
		color = "#d4ab8c"

	green
		color = "#9ec09e"

	yellow
		color = "#fff5a7"

	cyan
		color = "#86fbff"

	purple
		color = "#c5a8cc"

	blue
		color = "#87befd"

/turf/simulated/wall/auto/reinforced/jen
	icon = 'icons/turf/walls_jen.dmi'
	light_mod = "wall-jen-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	connect_overlay = 1
	connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
	/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred)

	connects_with_overlay = list(/turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/auto/jen,
	/turf/simulated/wall/false_wall/reinforced, /turf/simulated/wall/auto/shuttle, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred)

	the_tuff_stuff
		explosion_resistance = 3

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.update_icon()

	dark1
		color = "#dddddd"

	dark2
		color = "#bbbbbb"

	dark3
		color = "#999999"

	dark4
		color = "#777777"

	red
		color = "#ff9999"

	orange
		color = "#ffc599"

	brown
		color = "#d4ab8c"

	green
		color = "#9ec09e"

	yellow
		color = "#fff5a7"

	cyan
		color = "#86fbff"

	purple
		color = "#c5a8cc"

	blue
		color = "#87befd"

/turf/simulated/wall/auto/supernorn
	icon = 'icons/turf/walls_supernorn.dmi'
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	connect_overlay = 1
	connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen)

	connects_with_overlay = list(/turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/false_wall/reinforced, /turf/simulated/wall/auto/shuttle, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen)
	the_tuff_stuff
		explosion_resistance = 7

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.update_icon()

/turf/simulated/wall/auto/reinforced/supernorn
	icon = 'icons/turf/walls_supernorn.dmi'
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	connect_overlay = 1
	connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
	/turf/simulated/wall/false_wall/reinforced, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred, /turf/simulated/wall/auto/reinforced/supernorn/orange)

	connects_with_overlay = list(/turf/simulated/wall/auto/supernorn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
	/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred, /turf/simulated/wall/auto/reinforced/supernorn/orange, /turf/simulated/wall/auto/reinforced/paper,)

	connects_with_overlay_exceptions = list(/turf/simulated/wall/false_wall/reinforced)

	the_tuff_stuff
		explosion_resistance = 11

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.update_icon()

/turf/simulated/wall/auto/reinforced/supernorn/yellow
	icon = 'icons/turf/walls_azungar_yellow.dmi'
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	connect_overlay = 1
	connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
	/turf/simulated/wall/false_wall/reinforced, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn)

	connects_with_overlay = list(/turf/simulated/wall/auto/supernorn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
	/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn)

/turf/simulated/wall/auto/reinforced/supernorn/orange
	icon = 'icons/turf/walls_azungar_orange.dmi'
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	connect_overlay = 1
	explosion_resistance = 11
	connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
	/turf/simulated/wall/false_wall/reinforced, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn)

	connects_with_overlay = list(/turf/simulated/wall/auto/supernorn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
	/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn)

/turf/simulated/wall/auto/reinforced/supernorn/blackred
	icon = 'icons/turf/walls_azungar_blackred.dmi'
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	connect_overlay = 1
	explosion_resistance = 11
	connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
	/turf/simulated/wall/false_wall/reinforced, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn)

	connects_with_overlay = list(/turf/simulated/wall/auto/supernorn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
	/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn)


/turf/simulated/wall/auto/reinforced/paper
	icon = 'icons/turf/walls_paper.dmi'
	connects_to = list(/turf/simulated/wall/auto/reinforced/paper, /turf/simulated/wall/auto/reinforced/supernorn, /turf/simulated/wall/auto, /obj/table/reinforced/bar/auto, /obj/window, /obj/wingrille_spawn)
	connects_with_overlay = list(/obj/table/reinforced/bar/auto)

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.update_icon()
/turf/simulated/wall/auto/supernorn/wood
	icon = 'icons/turf/walls_wood.dmi'
	connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen)

	connects_with_overlay = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/false_wall, /turf/simulated/wall/false_wall/reinforced, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
	/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen)

/turf/simulated/wall/auto/gannets
	icon = 'icons/turf/walls_destiny.dmi'
	connects_to = list(/turf/simulated/wall/auto/gannets, /turf/simulated/wall/false_wall)
	the_tuff_stuff
		explosion_resistance = 7
/turf/simulated/wall/auto/marsoutpost
	icon = 'icons/turf/walls_marsoutpost.dmi'
	light_mod = "wall-"
	connect_overlay = 1
	connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window)

	connects_with_overlay = list(/turf/simulated/wall/auto/reinforced/supernorn,
	/turf/simulated/wall/false_wall/reinforced, /obj/machinery/door, /obj/window)

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.update_icon()

/turf/simulated/wall/auto/reinforced/gannets
	icon = 'icons/turf/walls_destiny.dmi'
	connects_to = list(/turf/simulated/wall/auto/reinforced/gannets, /turf/simulated/wall/false_wall/reinforced)

/* ===================================================== */
/* -------------------- UNSIMULATED -------------------- */
/* ===================================================== */

// I should really just have the auto-wall stuff on the base /turf so there's less copy/paste code shit going on
// but that will have to wait for another day so for now, copy/paste it is
/turf/unsimulated/wall/auto
	icon = 'icons/turf/walls_auto.dmi'
	var/mod = null
	var/light_mod = null
	var/connect_overlay = 0 // do we have wall connection overlays, ex nornwalls?
	var/list/connects_to = list(/turf/unsimulated/wall/auto)
	var/list/connects_to_exceptions = null
	var/list/connects_with_overlay = null
	var/list/connects_with_overlay_exceptions = null
	var/image/connect_image = null
	var/d_state = 0

	New()
		..()
		if (map_setting && ticker)
			src.update_neighbors()
		if (current_state > GAME_STATE_WORLD_INIT)
			SPAWN_DBG(0) //worldgen overrides ideally
				src.update_icon()

		else
			worldgenCandidates[src] = 1

	generate_worldgen()
		src.update_icon()

	Del()
		src.RL_SetSprite(null)
		..()


	proc/update_icon()
		var/builtdir = 0
		var/overlaydir = 0
		if (connect_overlay && !islist(connects_with_overlay))
			connects_with_overlay = list()
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (!T)
				continue
			if (T && (T.type == src.type || (T.type in connects_to)))
				builtdir |= dir
			else if (connects_to)
				for (var/i=1, i <= connects_to.len, i++)
					var/atom/A = locate(connects_to[i]) in T
					if (!isnull(A))
						if (istype(A, /atom/movable))
							var/atom/movable/M = A
							if (!M.anchored)
								continue
						builtdir |= dir
						break
			if (connect_overlay && connects_with_overlay)
				if (T.type in connects_with_overlay)
					overlaydir |= dir
				else
					for (var/i=1, i <= connects_with_overlay.len, i++)
						var/atom/A = locate(connects_with_overlay[i]) in T
						if (!isnull(A))
							if (istype(A, /atom/movable))
								var/atom/movable/M = A
								if (!M.anchored)
									continue
							overlaydir |= dir

		src.icon_state = "[mod][builtdir][src.d_state ? "C" : null]"
		if (light_mod)
			src.RL_SetSprite("[light_mod][builtdir]")

		if (connect_overlay)
			if (overlaydir)
				if (!src.connect_image)
					src.connect_image = image(src.icon, "connect[overlaydir]")
				else
					src.connect_image.icon_state = "connect[overlaydir]"
				src.UpdateOverlays(src.connect_image, "connect")
			else
				src.UpdateOverlays(null, "connect")

	proc/update_neighbors()
		for (var/turf/unsimulated/wall/auto/T in orange(1,src))
			T.update_icon()
		for (var/obj/grille/G in orange(1,src))
			G.update_icon()

/turf/unsimulated/wall/auto/reinforced
	name = "reinforced wall"
	mod = "R"
	icon_state = "mapwall_r"
	connects_to = list(/turf/unsimulated/wall/auto/reinforced)

/turf/unsimulated/wall/auto/supernorn
	icon = 'icons/turf/walls_supernorn.dmi'
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	connect_overlay = 1
	connects_to = list(/turf/unsimulated/wall/auto/supernorn, /turf/unsimulated/wall/auto/reinforced/supernorn, /obj/machinery/door,
	/obj/window)
	connects_with_overlay = list(/turf/unsimulated/wall/auto/reinforced/supernorn, /obj/machinery/door,
	/obj/window)

/turf/unsimulated/wall/auto/reinforced/supernorn
	icon = 'icons/turf/walls_supernorn.dmi'
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	connect_overlay = 1
	connects_to = list(/turf/unsimulated/wall/auto/supernorn, /turf/unsimulated/wall/auto/reinforced/supernorn, /obj/machinery/door,
	/obj/window)
	connects_with_overlay = list(/turf/unsimulated/wall/auto/supernorn, /obj/machinery/door,
	/obj/window)

/turf/unsimulated/wall/auto/gannets
	icon = 'icons/turf/walls_destiny.dmi'
	connects_to = list(/turf/unsimulated/wall/auto/gannets)

/turf/unsimulated/wall/auto/reinforced/gannets
	icon = 'icons/turf/walls_destiny.dmi'
	connects_to = list(/turf/unsimulated/wall/auto/reinforced/gannets)

/turf/unsimulated/wall/auto/virtual
	icon = 'icons/turf/walls_destiny.dmi'
//	icon = 'icons/turf/walls_virtual.dmi'
	connects_to = list(/turf/unsimulated/wall/auto/virtual)
	name = "virtual wall"
	desc = "that sure is a wall, yep."

/turf/unsimulated/wall/auto/coral
	New()
		..()
		setMaterial(getMaterial("coral"))


/datum/action/bar/icon/wall_tool_interact
	id = "wall_tool_interact"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 5 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/turf/simulated/wall/auto/the_wall
	var/obj/item/the_tool
	var/interaction = WALL_REMOVERERODS

	New(var/obj/table/wall, var/obj/item/tool, var/interact, var/duration_i)
		..()
		if (wall)
			the_wall = wall
		if (usr)
			owner = usr
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (interact)
			interaction = interact
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (the_wall == null || the_tool == null || owner == null || get_dist(owner, the_wall) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && (the_tool != source.equipped() || isrobot(source)))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		var/message = ""
		switch (interaction)
			if (WALL_REMOVERERODS)
				message = "Removing some reinforcing rods."
				playsound(get_turf(the_wall), "sound/items/Wirecutter.ogg", 100, 1)
			if (WALL_REMOVESUPPORTLINES)
				message = "Removing support lines."
				playsound(get_turf(the_wall), "sound/items/Screwdriver.ogg", 100, 1)
			if (WALL_SLICECOVER)
				message = "Slicing metal cover."
			if (WALL_REMOVESUPPORTRODS)
				message = "Removing support rods."
			if (WALL_PRYCOVER)
				message = "Prying cover off."
				playsound(get_turf(the_wall), "sound/items/Crowbar.ogg", 100, 1)
			if (WALL_PRYSHEATH)
				message = "Prying outer sheath off."
				playsound(get_turf(the_wall), "sound/items/Crowbar.ogg", 100, 1)
			if (WALL_DETATCHSUPPORTRODS)
				playsound(get_turf(the_wall), "sound/items/Ratchet.ogg", 100, 1)
				message = "Detaching support rods."
		owner.visible_message("<span class='notice'>[message].</span>")

	onEnd()
		..()
		var/message = ""
		switch (interaction)
			if (WALL_REMOVERERODS)
				message = "You remove some reinforcing rods."
				var/atom/A = new /obj/item/rods( the_wall )
				if (the_wall.material)
					A.setMaterial(the_wall.material)
				else
					A.setMaterial(getMaterial("steel"))
				the_wall.d_state = 1
				the_wall.update_icon()
			if (WALL_REMOVESUPPORTLINES)
				message = "You removed the support lines."
				the_wall.d_state = 2
			if (WALL_SLICECOVER)
				message = "You removed the metal cover."
				the_wall.d_state = 3
			if (WALL_REMOVESUPPORTRODS)
				message = "You removed the support rods."
				the_wall.d_state = 6
				var/atom/A = new /obj/item/rods( the_wall )
				if (the_wall.material)
					A.setMaterial(the_wall.material)
				else
					A.setMaterial(getMaterial("steel"))
			if (WALL_PRYCOVER)
				message = "You removed the cover."
				the_wall.d_state = 4
			if (WALL_PRYSHEATH)
				message = "You removed the outer sheath."
				logTheThing("station", owner, null, "dismantles a Reinforced Wall in [owner.loc.loc] ([showCoords(owner.x, owner.y, owner.z)])")
				the_wall.dismantle_wall()
			if (WALL_DETATCHSUPPORTRODS)
				message = "You detach the support rods."
				the_wall.d_state = 5
		owner.visible_message("<span class='notice'>[message].</span>")
