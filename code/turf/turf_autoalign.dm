
/* =================================================== */
/* -------------------- SIMULATED -------------------- */
/* =================================================== */

// These are added to TYPEINFO so we can have nicer behavior with inheritance and all + effectively static
TYPEINFO(/turf/simulated/wall/auto)
	/// List of types this autowall connects to
	var/list/connects_to = null
	/// Because connections now work by parent type searches, this is for when you don't want certain subtypes to connect.
	/// This must be a typecache ([/proc/typecachesof]) list
	var/list/connects_to_exceptions = null
	/// do we have wall connection overlays, ex nornwalls?
	var/connect_overlay = 0
	var/list/connects_with_overlay = null
	var/list/connects_with_overlay_exceptions = null // same as above comment
	var/connect_across_areas = TRUE
	/// 0 = no diagonal sprites, 1 = diagonal only if both adjacent cardinals are present, 2 = always allow diagonals
	var/connect_diagonal = 0
TYPEINFO_NEW(/turf/simulated/wall/auto)
	. = ..()
	connects_to = typecacheof(list(/turf/simulated/wall/auto,/turf/simulated/wall/false_wall))
	connects_to_exceptions = typecacheof(/turf/simulated/wall/auto/shuttle)
	connects_with_overlay = list()
	connects_with_overlay_exceptions = list()
/turf/simulated/wall/auto
	icon = 'icons/turf/walls_auto.dmi'
	var/mod = null
	var/light_mod = null
	/// The image we're using to connect to stuff with
	var/image/connect_image = null
	/// Deconstruction state
	var/d_state = 0

	New()
		..()
		if (map_setting && ticker)
			src.update_neighbors() // lessen these calls

		if (current_state > GAME_STATE_WORLD_INIT)
			SPAWN(0) //worldgen overrides ideally
				src.UpdateIcon()
		else
			worldgenCandidates[src] = 1

	generate_worldgen()
		src.UpdateIcon()

	Del()
		src.RL_SetSprite(null)
		..()

	update_icon()
		var/typeinfo/turf/simulated/wall/auto/typinfo = get_typeinfo()

		var/connectdir = get_connected_directions_bitflag(typinfo.connects_to, typinfo.connects_to_exceptions, typinfo.connect_across_areas, typinfo.connect_diagonal)

		var/the_state = "[mod][connectdir]"
		if ( !(istype(src, /turf/simulated/wall/auto/jen)) && !(istype(src, /turf/simulated/wall/auto/reinforced/jen)) ) //please no more sprite, i drained my brain doing this
			src.icon_state += "[src.d_state ? "C" : null]"
		icon_state = the_state

		if (light_mod)
			src.RL_SetSprite("[light_mod][connectdir]")

		if (typinfo.connect_overlay)
			var/overlaydir = get_connected_directions_bitflag(typinfo.connects_with_overlay, typinfo.connects_with_overlay_exceptions, typinfo.connect_across_areas)
			if (overlaydir)
				if (!src.connect_image)
					src.connect_image = image(src.icon, "connect[overlaydir]")
				else
					src.connect_image.icon_state = "connect[overlaydir]"
				src.UpdateOverlays(src.connect_image, "connect")
			else
				src.UpdateOverlays(null, "connect")

	proc/update_neighbors()
		for (var/turf/simulated/wall/auto/T in orange(1,src))
			T.UpdateIcon()
		for (var/obj/grille/G in orange(1,src))
			G.UpdateIcon()

/turf/simulated/wall/auto/the_tuff_stuff
	explosion_resistance = 7

TYPEINFO(/turf/simulated/wall/auto/reinforced)
TYPEINFO_NEW(/turf/simulated/wall/auto/reinforced)
	. = ..()
	connects_to = typecacheof(list(/turf/simulated/wall/auto/reinforced,/turf/simulated/wall/false_wall/reinforced))
/turf/simulated/wall/auto/reinforced
	name = "reinforced wall"
	health = 300
	explosion_resistance = 7
	mod = "R"
	icon_state = "mapwall_r"

	get_desc()
		switch (src.d_state)
			if (0)
				. += "<br>Looks like disassembling it starts with <b>snipping</b> some of those reinforcing rods."
			if (1)
				. += "<br>Up next in this long journey is <b>unscrewing</b> the reinforced rods."
			if (2)
				. += "<br>What'd really help at this point is <b>slicing</b> the metal cover with a welder."
			if (3)
				. += "<br>Your prying eyes suggest <b>prying</b> open the metal cover you just sliced."
			if (4)
				. += "<br>The latest <b>wrench</b> in your plans for wall disassembly appear to be some support rods."
			if (5)
				. += "<br>You should really <b>slice</b> the support rods you just loosened."
			if (6)
				. += "<br>Almost! Just need to <b>pry</b> off the outer sheath. Which you've somehow been working around this whole time. <em>Somehow</em>."


	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/light_parts))
			src.attach_light_fixture_parts(user, W) // Made this a proc to avoid duplicate code (Convair880).
			return

		/* ----- Deconstruction ----- */
		if (src.d_state == 0 && issnippingtool(W))
			actions.start(new /datum/action/bar/icon/wall_tool_interact(src, W, WALL_CUTRERODS), user)
			return

		else if (src.d_state == 1 && isscrewingtool(W))
			actions.start(new /datum/action/bar/icon/wall_tool_interact(src, W, WALL_REMOVERERODS), user)
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
			actions.start(new /datum/action/bar/icon/wall_tool_interact(src, W, WALL_LOOSENSUPPORTRODS), user)
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
			var/turf/simulated/wall/false_wall/temp/fakewall = src.ReplaceWith(/turf/simulated/wall/false_wall/temp, FALSE, TRUE, FALSE, TRUE)
			fakewall.was_rwall = 1
			fakewall.set_opacity(0)
			fakewall.RL_SetOpacity(1) //Lighting rebuild.
			return

		else if (istype(W, /obj/item/sheet) && src.d_state)
			var/obj/item/sheet/S = W
			boutput(user, "<span class='notice'>Repairing wall.</span>")
			if (do_after(user, 2.5 SECONDS) && S.change_stack_amount(-1))
				src.d_state = 0
				src.icon_state = initial(src.icon_state)
				if (S.material)
					src.setMaterial(S.material)
				else
					var/datum/material/M = getMaterial("steel")
					src.setMaterial(M)
				boutput(user, "<span class='notice'>You repaired the wall.</span>")
				return

		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!grab_smash(G, user))
				return ..(W, user)
			else
				return

		src.visible_message("<span class='alert'>[usr ? usr : "Someone"] uselessly hits [src] with [W].</span>", "<span class='alert'>You uselessly hit [src] with [W].</span>")

/turf/simulated/wall/auto/reinforced/the_tuff_stuff
	explosion_resistance = 11
	desc = "Looks <em>way</em> tougher than a regular wall."

TYPEINFO(/turf/simulated/wall/auto/jen)
	connect_overlay = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/jen)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/reinforced/supernorn, /turf/simulated/wall/auto/supernorn,
		/turf/simulated/wall/auto/shuttle, /turf/simulated/wall/auto/shuttle,
		/obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred,
		/turf/simulated/wall/auto/reinforced/jen
	))
/turf/simulated/wall/auto/jen
	icon = 'icons/turf/walls_jen.dmi'
	light_mod = "wall-jen-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.UpdateIcon()

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

TYPEINFO(/turf/simulated/wall/auto/reinforced/jen)
	connect_overlay = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/reinforced/jen)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/auto/jen,
		/turf/simulated/wall/auto/shuttle, /turf/simulated/wall/auto/shuttle,
		/obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/reinforced/supernorn/yellow, /turf/simulated/wall/auto/reinforced/supernorn/blackred
	))
	connects_with_overlay_exceptions = typecacheof(list(/turf/simulated/wall/auto/reinforced/jen))
/turf/simulated/wall/auto/reinforced/jen
	icon = 'icons/turf/walls_jen.dmi'
	light_mod = "wall-jen-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID

	the_tuff_stuff
		explosion_resistance = 3

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.UpdateIcon()

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


TYPEINFO(/turf/simulated/wall/auto/supernorn)
	connect_overlay = 1
	connect_diagonal = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/supernorn)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/auto/old, /turf/simulated/wall/auto/reinforced/old
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/shuttle,
		/turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen
	))
/turf/simulated/wall/auto/supernorn
	icon = 'icons/turf/walls_supernorn_smooth.dmi'
	mod = "norn-"
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID

	the_tuff_stuff
		explosion_resistance = 7

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.UpdateIcon()


TYPEINFO(/turf/simulated/wall/auto/reinforced/supernorn)
	connect_overlay = 1
	connect_diagonal = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/reinforced/supernorn)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle, /obj/machinery/door,
		/obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow,
		/turf/simulated/wall/auto/reinforced/supernorn/blackred, /turf/simulated/wall/auto/reinforced/supernorn/orange,
		/turf/simulated/wall/auto/old, /turf/simulated/wall/auto/reinforced/old
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window,
		/obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/paper
	))
/turf/simulated/wall/auto/reinforced/supernorn
	icon = 'icons/turf/walls_supernorn_smooth.dmi'
	mod = "norn-R-"
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID

	the_tuff_stuff
		explosion_resistance = 11

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.UpdateIcon()


TYPEINFO(/turf/simulated/wall/auto/reinforced/supernorn/yellow)
	connect_overlay = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/reinforced/supernorn/yellow)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle,
		/obj/machinery/door, /obj/window, /obj/wingrille_spawn
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn
	))
/turf/simulated/wall/auto/reinforced/supernorn/yellow
	icon = 'icons/turf/walls_manta.dmi'
#ifdef IN_MAP_EDITOR
	icon_state = "mapwall_r-Y"
#endif
	mod = "norn-Y-"
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID


TYPEINFO(/turf/simulated/wall/auto/reinforced/supernorn/orange)
	connect_overlay = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/reinforced/supernorn/orange)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle,
		/obj/machinery/door, /obj/window, /obj/wingrille_spawn
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn
	))
/turf/simulated/wall/auto/reinforced/supernorn/orange
	icon = 'icons/turf/walls_manta.dmi'
#ifdef IN_MAP_EDITOR
	icon_state = "mapwall_r-O"
#endif
	mod = "norn-O-"
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	explosion_resistance = 11


TYPEINFO(/turf/simulated/wall/auto/reinforced/supernorn/blackred)
	connect_overlay = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/reinforced/supernorn/blackred)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle,
		/obj/machinery/door, /obj/window, /obj/wingrille_spawn
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn
	))
/turf/simulated/wall/auto/reinforced/supernorn/blackred
	icon = 'icons/turf/walls_manta.dmi'
#ifdef IN_MAP_EDITOR
	icon_state = "mapwall_r-BR"
#endif
	mod = "norn-BR-"
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	explosion_resistance = 11


TYPEINFO(/turf/simulated/wall/auto/reinforced/paper)
TYPEINFO_NEW(/turf/simulated/wall/auto/reinforced/paper)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/reinforced/paper, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/auto, /obj/table/reinforced/bar/auto, /obj/window, /obj/wingrille_spawn
	))
	connects_with_overlay = typecacheof(list(/obj/table/reinforced/bar/auto))
/turf/simulated/wall/auto/reinforced/paper
	icon = 'icons/turf/walls_paper.dmi'
	default_material = "bamboo"

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.UpdateIcon()


TYPEINFO(/turf/simulated/wall/auto/supernorn/wood)
	connect_diagonal = 0
TYPEINFO_NEW(/turf/simulated/wall/auto/supernorn/wood)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen
	))
/turf/simulated/wall/auto/supernorn/wood
	icon = 'icons/turf/walls_wood.dmi'
	mod = ""
	default_material = "wood"


TYPEINFO(/turf/simulated/wall/auto/gannets)
TYPEINFO_NEW(/turf/simulated/wall/auto/gannets)
	. = ..()
	connects_to = typecacheof(list(/turf/simulated/wall/auto/gannets, /turf/simulated/wall/false_wall))
/turf/simulated/wall/auto/gannets
	icon = 'icons/turf/walls_destiny.dmi'

/turf/simulated/wall/auto/gannets/the_tuff_stuff
	explosion_resistance = 7


TYPEINFO(/turf/simulated/wall/auto/marsoutpost)
	connect_overlay = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/marsoutpost)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/reinforced/supernorn,
		/obj/machinery/door, /obj/window
	))
/turf/simulated/wall/auto/marsoutpost
	icon = 'icons/turf/walls_marsoutpost.dmi'
	light_mod = "wall-"

	update_neighbors()
		..()
		for (var/obj/window/auto/O in orange(1,src))
			O.UpdateIcon()


TYPEINFO(/turf/simulated/wall/auto/reinforced/gannets)
TYPEINFO_NEW(/turf/simulated/wall/auto/reinforced/gannets)
	. = ..()
	connects_to = typecacheof(list(/turf/simulated/wall/auto/reinforced/gannets, /turf/simulated/wall/false_wall/reinforced))
/turf/simulated/wall/auto/reinforced/gannets
	icon = 'icons/turf/walls_destiny.dmi'


TYPEINFO(/turf/simulated/wall/auto/old)
	connect_overlay = 1
	connect_diagonal = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/old)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/false_wall, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/auto/old, /turf/simulated/wall/auto/reinforced/old
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/shuttle,
		/turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/
	))
/turf/simulated/wall/auto/old
	icon = 'icons/turf/walls_derelict.dmi'
	mod = "old-"
	icon_state = "old"
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID


TYPEINFO(/turf/simulated/wall/auto/reinforced/old)
	connect_overlay = 1
	connect_diagonal = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/reinforced/old)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle, /obj/machinery/door,
		/obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow,
		/turf/simulated/wall/auto/reinforced/supernorn/blackred, /turf/simulated/wall/auto/reinforced/supernorn/orange,
		/turf/simulated/wall/auto/old, /turf/simulated/wall/auto/reinforced/old
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/shuttle,
		/obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen
	))
/turf/simulated/wall/auto/reinforced/old
	icon = 'icons/turf/walls_derelict.dmi'
	mod = "oldr-"
	icon_state = "oldr"
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID


TYPEINFO(/turf/simulated/wall/auto/hedge)
	connect_diagonal = 1
TYPEINFO_NEW(/turf/simulated/wall/auto/hedge)
	. = ..()
	connects_to = typecacheof(list(
		/turf/simulated/wall/auto/hedge, /turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
		/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle, /obj/machinery/door,
		/obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow,
		/turf/simulated/wall/auto/reinforced/supernorn/blackred, /turf/simulated/wall/auto/reinforced/supernorn/orange,
		/turf/simulated/wall/auto/old, /turf/simulated/wall/auto/reinforced/old
	))
	connects_with_overlay = typecacheof(list(
		/turf/simulated/wall/auto/shuttle,
		/turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
		/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen
	))
/turf/simulated/wall/auto/hedge // Some fun walls by Walpvrgis
	name = "hedge"
	desc = "This hedge is sturdy! No light seems to pass through it..."
	icon = 'icons/turf/walls_hedge.dmi'
	mod = "hedge-"
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	default_material = "wood"

/* ===================================================== */
/* -------------------- UNSIMULATED -------------------- */
/* ===================================================== */


TYPEINFO(/turf/unsimulated/wall/auto)
	var/list/connects_to = null
	/// must be typecache list
	var/list/connects_to_exceptions = null
	/// do we have wall connection overlays, ex nornwalls?
	var/connect_overlay = 0
	var/list/connects_with_overlay = null
	var/list/connects_with_overlay_exceptions = null
	/// 0 = no diagonal sprites, 1 = diagonal only if both adjacent cardinals are present, 2 = always allow diagonals
	var/connect_diagonal = 0
TYPEINFO_NEW(/turf/unsimulated/wall/auto)
	. = ..()
	connects_to = typecacheof(/turf/unsimulated/wall/auto)
	connects_to_exceptions = list()
	connects_with_overlay = list()
	connects_with_overlay_exceptions = list()
// I should really just have the auto-wall stuff on the base /turf so there's less copy/paste code shit going on
// but that will have to wait for another day so for now, copy/paste it is
/turf/unsimulated/wall/auto
	icon = 'icons/turf/walls_auto.dmi'
	var/mod = null
	var/light_mod = null
	var/image/connect_image = null
	/// deconstruct state
	var/d_state = 0

	New()
		. = ..()
		if (map_setting && ticker)
			src.update_neighbors()
		if (current_state > GAME_STATE_WORLD_INIT)
			SPAWN(0) //worldgen overrides ideally
				src.UpdateIcon()

		else
			worldgenCandidates[src] = 1

	generate_worldgen()
		src.UpdateIcon()

	Del()
		src.RL_SetSprite(null)
		..()

	update_icon()
		var/typeinfo/turf/unsimulated/wall/auto/typinfo = get_typeinfo()

		var/connectdir = get_connected_directions_bitflag(typinfo.connects_to, typinfo.connects_to_exceptions, TRUE, typinfo.connect_diagonal)
		var/the_state = "[mod][connectdir]"
		icon_state = the_state

		if (light_mod)
			src.RL_SetSprite("[light_mod][connectdir]")

		if (typinfo.connect_overlay)
			var/overlaydir = get_connected_directions_bitflag(typinfo.connects_with_overlay, typinfo.connects_with_overlay_exceptions, TRUE)
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
			T.UpdateIcon()
		for (var/obj/grille/G in orange(1,src))
			G.UpdateIcon()


TYPEINFO(/turf/unsimulated/wall/auto/reinforced)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/reinforced)
	. = ..()
	connects_to = typecacheof(/turf/unsimulated/wall/auto/reinforced)
/turf/unsimulated/wall/auto/reinforced
	name = "reinforced wall"
	mod = "R"
	icon_state = "mapwall_r"

TYPEINFO(/turf/unsimulated/wall/auto/supernorn)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/supernorn)
	. = ..()
	connect_overlay = 1
	connect_diagonal = 1
	connects_to = typecacheof(list(
		/turf/unsimulated/wall/auto/supernorn,
		/turf/unsimulated/wall/auto/reinforced/supernorn,
		/obj/machinery/door,
		/obj/window,
	))
	connects_with_overlay = typecacheof(list(/obj/machinery/door, /obj/window))
/turf/unsimulated/wall/auto/supernorn
	icon = 'icons/turf/walls_supernorn_smooth.dmi'
	light_mod = "wall-"
	mod = "norn-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID

TYPEINFO(/turf/unsimulated/wall/auto/reinforced/supernorn)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/reinforced/supernorn)
	. = ..()
	connect_overlay = 1
	connect_diagonal = 1
	connects_to = typecacheof(list(
		/turf/unsimulated/wall/auto/supernorn,
		/turf/unsimulated/wall/auto/reinforced/supernorn,
		/obj/machinery/door,
		/obj/window,
		/turf/simulated/wall/false_wall/reinforced,
		/turf/unsimulated/wall/auto/adventure/old,
		/turf/unsimulated/wall/setpieces/fakewindow,
		/turf/unsimulated/wall/auto/adventure/meat,
	))
	connects_with_overlay = typecacheof(list(/obj/machinery/door, /obj/window))
/turf/unsimulated/wall/auto/reinforced/supernorn
	icon = 'icons/turf/walls_supernorn_smooth.dmi'
	light_mod = "wall-"
	mod = "norn-R-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID


TYPEINFO(/turf/unsimulated/wall/auto/supernorn/wood)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/supernorn/wood)
	. = ..()
	connect_diagonal = 0
	connects_to = typecacheof(list(
		/turf/unsimulated/wall/auto/supernorn,
		/turf/unsimulated/wall/auto/reinforced/supernorn,
		/turf/unsimulated/wall/auto/supernorn/wood,
		/obj/machinery/door,
		/obj/window,
		/obj/wingrille_spawn,
	))
	connects_with_overlay = typecacheof(list(
		/turf/unsimulated/wall/auto/supernorn,
		/turf/unsimulated/wall/auto/reinforced/supernorn,
		/turf/unsimulated/wall/auto/supernorn/wood,
		/obj/machinery/door,
		/obj/window,
		/obj/wingrille_spawn,
	))
/turf/unsimulated/wall/auto/supernorn/wood
	icon = 'icons/turf/walls_wood.dmi'
	mod = ""


TYPEINFO(/turf/unsimulated/wall/auto/gannets)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/gannets)
	. = ..()
	connects_to = typecacheof(/turf/unsimulated/wall/auto/gannets)
/turf/unsimulated/wall/auto/gannets
	icon = 'icons/turf/walls_destiny.dmi'


TYPEINFO(/turf/unsimulated/wall/auto/reinforced/gannets)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/reinforced/gannets)
	. = ..()
	connects_to = typecacheof(/turf/unsimulated/wall/auto/reinforced/gannets)
/turf/unsimulated/wall/auto/reinforced/gannets
	icon = 'icons/turf/walls_destiny.dmi'


TYPEINFO(/turf/unsimulated/wall/auto/virtual)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/virtual)
	. = ..()
	connects_to = typecacheof(/turf/unsimulated/wall/auto/virtual)
/turf/unsimulated/wall/auto/virtual
	icon = 'icons/turf/walls_destiny.dmi'
	name = "virtual wall"
	desc = "that sure is a wall, yep."


/turf/unsimulated/wall/auto/coral
	New()
		..()
		setMaterial(getMaterial("coral"), copy = FALSE)


// lead wall resprite by skeletonman0.... hooray for smoothwalls!
//ABSTRACT_TYPE(/turf/unsimulated/wall/auto/lead) // zewaka: unsimwall/auto used in places - parent abstract tree
TYPEINFO(/turf/unsimulated/wall/auto/lead)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/lead)
	. = ..()
	connect_overlay = 1
	connect_diagonal = 1
	connects_to = typecacheof(list(
		/turf/unsimulated/wall/auto/lead,
		/obj/machinery/door,
		/obj/window,
		/turf/unsimulated/wall/setpieces/leadwindow,
		/turf/unsimulated/wall/,
		/turf/simulated/wall/false_wall/,
		/turf/simulated/wall/false_wall/centcom,
	))
	connects_with_overlay = typecacheof(list(/obj/machinery/door, /obj/window))
/turf/unsimulated/wall/auto/lead
	name = "lead wall"
	icon = 'icons/turf/walls_lead.dmi'
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID

TYPEINFO(/turf/unsimulated/wall/auto/lead/blue)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/lead/blue)
	. = ..()
	connects_to_exceptions = typecacheof(/obj/window/auto) // fixes shuttle wall alignment
/turf/unsimulated/wall/auto/lead/blue
	icon_state = "mapiconb"
	mod = "leadb-"

/turf/unsimulated/wall/auto/lead/gray
	icon_state = "mapicong"
	mod = "leadg-"

/turf/unsimulated/wall/auto/lead/white
	icon_state = "mapiconw"
	mod = "leadw-"


TYPEINFO(/turf/unsimulated/wall/auto/adventure)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure)
	. = ..()
	connect_overlay = 1
	connect_diagonal = 1
	connects_to = typecacheof(list(
		/turf/cordon,
		/turf/unsimulated/wall/auto/adventure,
		/obj/machinery/door, /obj/window, /turf/unsimulated/wall/,
		/turf/simulated/wall/false_wall/,
		/turf/unsimulated/wall/setpieces/leadwindow, /turf/simulated/wall/false_wall/centcom,
		/turf/unsimulated/wall/setpieces/stranger, /obj/shifting_wall/sneaky/cave,
		/turf/simulated/shuttle/wall, /obj/indestructible/shuttle_corner
	))
	connects_with_overlay = typecacheof(list(/obj/machinery/door, /obj/window))
//ABSTRACT_TYPE(/turf/unsimulated/wall/auto/adventure)
/turf/unsimulated/wall/auto/adventure // azone fancy walls
	name = "lead wall"
	icon = 'icons/turf/walls_overgrown.dmi'
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID



/turf/unsimulated/wall/auto/adventure/overgrown1
	name = "overgrown wall"
	desc = "This wall is covered in vines."
	icon = 'icons/turf/walls_overgrown.dmi'
	mod = "root-"
	icon_state = "root-0"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/overgrown2)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/overgrown2)
	. = ..()
	connect_overlay = 0
/turf/unsimulated/wall/auto/adventure/overgrown2
	name = "Rock Wall"
	desc = "This wall is made of damp stone."
	icon = 'icons/turf/walls_overgrown.dmi'
	mod = "rock-"
	icon_state = "rock-0"


/turf/unsimulated/wall/auto/adventure/ancient
	name = "strange wall"
	desc = "A weird jet black metal wall indented with strange grooves and lines."
	icon = 'icons/turf/walls_ancient.dmi'
	mod = "ancient-"
	icon_state = "ancient-0"


/turf/unsimulated/wall/auto/adventure/cave
	name = "cave wall"
	icon = 'icons/turf/walls_cave.dmi'
	mod = "cave-"
	icon_state = "cave-0"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/shuttle)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/shuttle)
	. = ..()
	connect_overlay = 0
/turf/unsimulated/wall/auto/adventure/shuttle // fancy walls part 2: enough for debris field
	name = "shuttle wall"
	icon = 'icons/turf/walls_shuttle-debris.dmi'
	mod = "shuttle-"

TYPEINFO(/turf/unsimulated/wall/auto/adventure/shuttle/dark)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/shuttle/dark)
	. = ..()
	connect_overlay = 0
/turf/unsimulated/wall/auto/adventure/shuttle/dark
	mod = "dshuttle-"
	icon_state = "dshuttle"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/bee)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/bee)
	. = ..()
	connect_overlay = 0
	connects_to = typecacheof(list(/turf/unsimulated/wall/auto/adventure/bee, /turf/simulated/wall/false_wall/hive, /turf/unsimulated/wall/auto/adventure/bee/exterior))
/turf/unsimulated/wall/auto/adventure/bee
	name = "hive wall"
	desc = "Honeycomb's big, yeah yeah yeah."
	icon = 'icons/turf/walls_beehive.dmi'
	mod = "bee-"
	plane = PLANE_WALL-1 //We don't want depth shadows
	icon_state = "cave-0"

	exterior // so i dont have to make more parts for it to look good
		mod = "beeout-"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/martian)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/martian)
	. = ..()
	connect_overlay = 0
	connects_to = typecacheof(list(/turf/unsimulated/wall/auto/adventure/martian, /obj/machinery/door/unpowered/martian, /turf/unsimulated/wall/auto/adventure/martian/exterior,/obj/indestructible/shuttle_corner))
/turf/unsimulated/wall/auto/adventure/martian
	name = "organic wall"
	icon = 'icons/turf/walls_martian.dmi'
	mod = "martian-"

	exterior
		mod = "martout-"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/iomoon)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/iomoon)
	. = ..()
	connect_overlay = 0
/turf/unsimulated/wall/auto/adventure/iomoon // fancy walls part 3: the rest of z2
	name = "silicate crust"
	icon = 'icons/turf/walls_iomoon.dmi'
	icon_state = "silicate-0"
	mod = "silicate-"

	interior
		name = "strange wall"
		mod = "interior-"
		icon_state = "interior-0"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/hospital)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/hospital)
	. = ..()
	connect_overlay = 0
/turf/unsimulated/wall/auto/adventure/hospital
	name = "asteroid"
	icon = 'icons/turf/walls_hospital.dmi'
	mod = "exterior-"
	icon_state = "exterior-0"

TYPEINFO(/turf/unsimulated/wall/auto/adventure/hospital/interior)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/hospital/interior)
	. = ..()
	connects_to = typecacheof(list(/turf/cordon, /turf/unsimulated/wall/auto/adventure, /obj/machinery/door,
		/obj/window, /turf/unsimulated/wall/, /turf/simulated/wall/false_wall/,
		/turf/unsimulated/wall/setpieces/leadwindow, /turf/simulated/wall/false_wall/centcom,
		/turf/unsimulated/wall/setpieces/stranger, /obj/shifting_wall/sneaky/cave,
		/turf/simulated/shuttle/wall, /turf/unsimulated/wall/setpieces/hospital/window
	))
/turf/unsimulated/wall/auto/adventure/hospital/interior
	name = "panel wall"
	mod = "interior-"
	icon_state = "interior-0"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/icemoon)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/icemoon)
	. = ..()
	connect_overlay = 0
/turf/unsimulated/wall/auto/adventure/icemoon
	name = "ice wall"
	icon = 'icons/turf/walls_icemoon.dmi'
	mod = "ice-"
	icon_state = "ice-0"

	interior
		name = "blue wall"
		mod = "interior-"
		icon_state = "interior-0"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/moon)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/moon)
	. = ..()
	connect_overlay = 0
/turf/unsimulated/wall/auto/adventure/moon
	name = "moon rock"
	icon = 'icons/turf/walls_planet.dmi'
	mod = "moon-"
	icon_state = "moon-0"

TYPEINFO(/turf/unsimulated/wall/auto/adventure/mars)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/mars)
	. = ..()
	connect_overlay = 0
/turf/unsimulated/wall/auto/adventure/mars
	name = "martian rock"
	icon = 'icons/turf/walls_planet.dmi'
	mod = "mars-"
	icon_state = "mars-0"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/mars/interior)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/mars/interior)
	. = ..()
	connect_overlay = 1
/turf/unsimulated/wall/auto/adventure/mars/interior
	name = "wall"
	mod = "interior-"
	icon = 'icons/turf/walls_marsoutpost.dmi'
	icon_state = "interior-0"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/meat)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/meat)
	. = ..()
	connect_overlay = 0
	connects_to = typecacheof(list(
		/turf/cordon, /turf/unsimulated/wall/auto/adventure, /obj/machinery/door,
		/obj/window, /turf/unsimulated/wall/, /turf/simulated/wall/false_wall/,
		/turf/unsimulated/wall/setpieces/leadwindow, /turf/simulated/wall/false_wall/centcom,
		/turf/unsimulated/wall/setpieces/stranger, /obj/shifting_wall/sneaky/cave,
		/turf/simulated/shuttle/wall, /obj/indestructible/shuttle_corner,
		/turf/unsimulated/wall/auto/adventure/old,/turf/unsimulated/wall/auto/adventure/meat,
		/turf/unsimulated/wall/auto/adventure/meat/eyes, /turf/unsimulated/wall/auto/adventure/meat/meatier,
		/turf/unsimulated/wall/auto/reinforced/supernorn, /turf/simulated/wall/false_wall/reinforced
	))
/turf/unsimulated/wall/auto/adventure/meat
	name = "wall"
	icon = 'icons/turf/walls_meat.dmi'
	mod = "meaty-"
	icon_state = "meaty-0"

	meatier
		mod = "meatier-"
		icon_state = "meatier-0"

	eyes
		mod = "meateyes-"
		icon_state = "meateyes-0"


TYPEINFO(/turf/unsimulated/wall/auto/adventure/old)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/old)
	. = ..()
	connect_overlay = 0
	connects_to = typecacheof(list(
	/turf/cordon, /turf/unsimulated/wall/auto/adventure, /obj/machinery/door,
	/obj/window, /turf/unsimulated/wall/, /turf/simulated/wall/false_wall/,
	/turf/unsimulated/wall/setpieces/leadwindow, /turf/simulated/wall/false_wall/centcom,
	/turf/unsimulated/wall/setpieces/stranger, /obj/shifting_wall/sneaky/cave,
	/turf/simulated/shuttle/wall, /obj/indestructible/shuttle_corner, /turf/unsimulated/wall/auto/adventure/meat,
	/turf/unsimulated/wall/setpieces/fakewindow, /turf/unsimulated/wall/auto/reinforced/supernorn
	))
/turf/unsimulated/wall/auto/adventure/old
	name = "wall"
	icon = 'icons/turf/walls_derelict.dmi'
	mod = "old-"
	icon_state = ""

	reinforced
		name = "reinforced wall"
		icon = 'icons/turf/walls_derelict.dmi'
		mod = "oldr-"
		icon_state = "oldr"


TYPEINFO(/turf/unsimulated/wall/auto/hedge)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/hedge)
	. = ..()
	connect_diagonal = 1
	connects_to = typecacheof(list(/turf/unsimulated/wall/auto/hedge, /obj/machinery/door, /obj/window, /turf/unsimulated/wall/, /turf/simulated/wall/false_wall/))
// Some fun walls by Walpvrgis
//ABSTRACT_TYPE(/turf/unsimulated/wall/auto/hedge)
/turf/unsimulated/wall/auto/hedge
	name = "hedge"
	desc = "This hedge is sturdy! No light seems to pass through it..."
	icon = 'icons/turf/walls_hedge.dmi'
	mod = "hedge-"
	light_mod = "wall-"
	flags = ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID


/datum/action/bar/icon/wall_tool_interact
	id = "wall_tool_interact"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 5 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/turf/simulated/wall/auto/the_wall
	var/obj/item/the_tool
	var/interaction = WALL_CUTRERODS

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
		if (the_wall == null || the_tool == null || owner == null || BOUNDS_DIST(owner, the_wall) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && (the_tool != source.equipped()))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		var/message = ""
		var/self_message = ""
		switch (interaction)
			if (WALL_CUTRERODS)
				self_message = "You begin to cut the reinforced rods."
				message = "[owner] begins to cut \the [the_wall]'s reinforced rods."
				playsound(the_wall, 'sound/items/Wirecutter.ogg', 100, 1)
			if (WALL_REMOVERERODS)
				self_message = "You begin to remove the reinforced rods."
				message = "[owner] begins to remove \the [the_wall]'s reinforced rods."
				playsound(the_wall, 'sound/items/Screwdriver.ogg', 100, 1)
			if (WALL_SLICECOVER)
				self_message = "You begin to slice the metal cover."
				message = "[owner] begins to slice \the [the_wall]'s metal cover."
			if (WALL_PRYCOVER)
				self_message = "You begin to pry the metal cover apart."
				message = "[owner] begins to pry \the [the_wall]'s metal cover apart."
				playsound(the_wall, 'sound/items/Crowbar.ogg', 100, 1)
			if (WALL_LOOSENSUPPORTRODS)
				self_message = "You begin to loosen the support rods."
				message = "[owner] begins to loosen \the [the_wall]'s support rods."
				playsound(the_wall, 'sound/items/Ratchet.ogg', 100, 1)
			if (WALL_REMOVESUPPORTRODS)
				self_message = "You begin to remove the support rods."
				message = "[owner] begins to remove \the [the_wall]'s support rods."
			if (WALL_PRYSHEATH)
				self_message = "You begin to pry the outer sheath off."
				message = "[owner] begins to pry \the [the_wall]'s outer sheath off."
				playsound(the_wall, 'sound/items/Crowbar.ogg', 100, 1)
		owner.visible_message("<span class='alert'>[message]</span>", "<span class='notice'>[self_message]</span>")

	onEnd()
		..()
		var/message = ""
		var/self_message = ""
		switch (interaction)
			if (WALL_CUTRERODS)
				self_message = "You cut the reinforcing rods."
				message = "[owner] cuts \the [the_wall]'s reinforcing rods."
				the_wall.d_state = 1
				the_wall.UpdateIcon()
			if (WALL_REMOVERERODS)
				var/atom/A = new /obj/item/rods( the_wall )
				if (the_wall.material)
					A.setMaterial(the_wall.material)
				else
					A.setMaterial(getMaterial("steel"), copy = FALSE)
				self_message = "You remove the reinforcing rods."
				message = "[owner] removes \the [the_wall]'s reinforcing rods."
				the_wall.d_state = 2
			if (WALL_SLICECOVER)
				self_message = "You slice the metal cover."
				message = "[owner] slices \the [the_wall]'s metal cover."
				the_wall.d_state = 3
			if (WALL_PRYCOVER)
				self_message = "You pry the metal cover apart."
				message = "[owner] pries \the [the_wall]'s metal cover apart."
				the_wall.d_state = 4
			if (WALL_LOOSENSUPPORTRODS)
				self_message = "You loosen the support rods."
				message = "[owner] loosens \the [the_wall]'s support rods."
				the_wall.d_state = 5
			if (WALL_REMOVESUPPORTRODS)
				self_message = "You remove the support rods."
				message = "[owner] removes \the [the_wall]'s support rods."
				the_wall.d_state = 6
				var/atom/A = new /obj/item/rods( the_wall )
				if (the_wall.material)
					A.setMaterial(the_wall.material)
				else
					A.setMaterial(getMaterial("steel"), copy = FALSE)
			if (WALL_PRYSHEATH)
				self_message = "You remove the outer sheath."
				message = "[owner] removes \the [the_wall]'s outer sheath."
				logTheThing(LOG_STATION, owner, "dismantles a Reinforced Wall in [owner.loc.loc] ([log_loc(owner)])")
				the_wall.dismantle_wall()
		owner.visible_message("<span class='alert'>[message]</span>", "<span class='notice'>[self_message]</span>")
