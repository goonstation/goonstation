var/global/list/color_caching = list()

proc/debug_color_of(var/thing)
	if(isnum(thing))
		thing = "[thing]"
	else if(!istext(thing))
		thing = "\ref[thing]"
	if(!thing || thing == "0" || thing == "null" || thing == "\[0x0\]")
		return "#ffffff"
	if(!(thing in color_caching))
		color_caching[thing] = "#[copytext(md5(thing), 1, 7)]"
	return color_caching[thing]

/client/proc
	map_debug_panel()
		SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

		var/area_txt = "<B>APC LOCATION REPORT</B><HR>"
		var/apc_count = 0
		var/list/apcs = new()
		for(var/area/area in world)
			if (!area.requires_power)
				continue

			for(var/obj/machinery/power/apc/current_apc in area)
				if (!apcs.Find(current_apc)) apcs += current_apc

			apc_count = apcs.len
			if (apc_count != 1)
				area_txt += "[area.name] [area.type] has [apc_count] APCs.<br>"
			apcs.len = 0

			LAGCHECK(LAG_LOW)

		usr.Browse(area_txt,"window=mapdebugpanel")


	general_report()
		SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

		if(!processScheduler)
			usr << alert("Process Scheduler not found.")

		var/mobs = global.mobs.len


		var/output = {"<B>GENERAL SYSTEMS REPORT</B><HR>
<B>General Processing Data</B><BR>
<B># of Machines:</B> [length(all_processing_machines()) + atmos_machines.len]<BR>
<B># of Pipe Networks:</B> [pipe_networks.len]<BR>
<B># of Processing Items:</B> [processing_items.len]<BR>
<B># of Power Nets:</B> [powernets.len]<BR>
<B># of Mobs:</B> [mobs]<BR>
"}

		usr.Browse(output,"window=generalreport")

	air_report()
		SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

		if(!processScheduler || !air_master)
			alert(usr,"processScheduler or air_master not found.","Air Report")
			return 0

		var/active_groups = 0
		var/inactive_groups = 0
		var/active_tiles = 0
		for(var/datum/air_group/group in air_master.air_groups)
			if(group.group_processing)
				active_groups++
			else
				inactive_groups++
				active_tiles += group.members.len

		var/hotspots = 0
		for(var/obj/hotspot/hotspot in world)
			hotspots++
			LAGCHECK(LAG_LOW)

		var/output = {"<B>AIR SYSTEMS REPORT</B><HR>
<B>General Processing Data</B><BR>
<B># of Groups:</B> [air_master.air_groups.len]<BR>
---- <I>Active:</I> [active_groups]<BR>
---- <I>Inactive:</I> [inactive_groups]<BR>
-------- <I>Tiles:</I> [active_tiles]<BR>
<B># of Active Singletons:</B> [air_master.active_singletons.len]<BR>
<BR>
<B>Total # of Gas Mixtures In Existence: </B>[total_gas_mixtures]<BR>
<B>Special Processing Data</B><BR>
<B>Hotspot Processing:</B> [hotspots]<BR>
<B>High Temperature Processing:</B> [air_master.active_super_conductivity.len]<BR>
<B>High Pressure Processing:</B> [air_master.high_pressure_delta.len] (not yet implemented)<BR>
<BR>
<B>Geometry Processing Data</B><BR>
<B>Group Rebuild:</B> [air_master.groups_to_rebuild.len]<BR>
<B>Tile Update:</B> [air_master.tiles_to_update.len]<BR>
[air_histogram()]
"}

		usr.Browse(output,"window=airreport")

	air_histogram()

		var/html = "<pre>"
		var/list/ghistogram = new
		var/list/ughistogram = new
		var/p

		for(var/datum/air_group/g in air_master.air_groups)
			if (g.group_processing)
				for(var/turf/simulated/member in g.members)
					p = round(max(-1, MIXTURE_PRESSURE(member.air)), 10)/10 + 1
					if (p > ghistogram.len)
						ghistogram.len = p
					ghistogram[p]++
			else
				for(var/turf/simulated/member in g.members)
					p = round(max(-1, MIXTURE_PRESSURE(member.air)), 10)/10 + 1
					if (p > ughistogram.len)
						ughistogram.len = p
					ughistogram[p]++

		html += "Group processing tiles pressure histogram data:\n"
		for(var/i=1,i<=ghistogram.len,i++)
			html += "[10*(i-1)]\t\t[ghistogram[i]]\n"
		html += "Non-group processing tiles pressure histogram data:\n"
		for(var/i=1,i<=ughistogram.len,i++)
			html += "[10*(i-1)]\t\t[ughistogram[i]]\n"
		return html

	air_status(turf/target as turf)
		SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
		set name = "Air Status"
		set popup_menu = 0


		if(!isturf(target))
			return

		var/datum/gas_mixture/GM = target.return_air()
		var/burning = 0
		if(istype(target, /turf/simulated))
			var/turf/simulated/T = target
			if(T.active_hotspot)
				burning = 1

		boutput(usr, "<span class='notice'>@[target.x],[target.y] ([GM.group_multiplier])<br>[MOLES_REPORT(GM)] t: [GM.temperature] Kelvin, [MIXTURE_PRESSURE(GM)] kPa [(burning)?("<span class='alert'>BURNING</span>"):(null)]</span>")

		if(GM.trace_gases)
			for(var/datum/gas/trace_gas in GM.trace_gases)
				boutput(usr, "[trace_gas.type]: [trace_gas.moles]")

	fix_next_move()
		SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
		set name = "Press this if everybody freezes up"
		var/largest_click_time = 0
		var/mob/largest_click_mob = null
		if (disable_next_click)
			boutput(usr, "<span class='alert'>next_click is disabled and therefore so is this command!</span>")
			return

		for(var/mob/M in mobs)
			if(!M.client)
				continue
			if(M.next_click >= largest_click_time)
				largest_click_mob = M
				if(M.next_click > world.time)
					largest_click_time = M.next_click - world.time
				else
					largest_click_time = 0
			logTheThing("admin", M, null, "lastDblClick = [M.next_click]  world.time = [world.time]")
			logTheThing("diary", M, null, "lastDblClick = [M.next_click]  world.time = [world.time]", "admin")
			M.next_click = 0
		message_admins("[key_name(largest_click_mob, 1)] had the largest click delay with [largest_click_time] frames / [largest_click_time/10] seconds!")
		message_admins("world.time = [world.time]")
		return

	debug_profiler()
		SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
		set name = "Open Profiler"

		admin_only
		world.SetConfig( "APP/admin", src.key, "role=admin" )
		input( src, "Enter '.debug profile' in the next command box. Blame BYOND.", "BYONDSucks", ".debug profile" )
		winset( usr, null, "command=.command" )

/datum/infooverlay
	var/help = "Huh."
	var/restricted = 0//if only coders+ can use it
	proc/GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
	proc/OnEnabled(var/client/C)
	proc/OnDisabled(var/client/C)
	proc/OnStartRendering(var/client/C)
	proc/OnFinishRendering(var/client/C)

	proc/makeText(text, additional_flags=0)
		var/mutable_appearance/mt = new
		mt.plane = FLOAT_PLANE
		mt.icon = 'icons/effects/effects.dmi'
		mt.icon_state = "nothing"
		mt.maptext = "<span class='pixel r ol'>[text]</span>"
		mt.maptext_x = -3
		mt.appearance_flags = RESET_COLOR | additional_flags
		return mt

	teleblocked
		help = "Red tiles are ones that are teleblocked, green ones can be teleported to."
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			img.app.color = is_teleportation_allowed(theTurf) ? "#0f0" : "#f00"

	blowout
		help = "Green tiles are safe from irradiation, red tiles are ones that are not."
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			if(theTurf.loc:do_not_irradiate)
				img.app.color = "#0f0"
			else
				img.app.color = "#f00"


	areas
		help = "Differentiates between different areas. Also gives you area names because thats cool and stuff."
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			if(!theTurf.loc:gencolor)
				theTurf.loc:gencolor = rgb( rand(1,255),rand(1,255),rand(1,255) )
			img.app.desc = "Area: [theTurf.loc:name]<br/>Type: [theTurf.loc:type]"
			img.app.color = theTurf.loc:gencolor
			img.mouse_opacity = 1


	atmos_air
		help = "Tile colors are based on what air group turf belongs to. Hover over a turf to get its atmos readout"
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			var/turf/simulated/sim = theTurf
			img.mouse_opacity = 1
			if(istype(sim, /turf/simulated))//byondood
				var/datum/air_group/group = sim.parent
				if(group)
					if(!group.gencolor)
						group.gencolor = rgb( rand(1,255),rand(1,255),rand(1,255) )
					img.app.color = group.gencolor
					img.app.desc = "Group \ref[group]<br>[MOLES_REPORT(group.air)]Temperature=[group.air.temperature]<br/>Spaced=[group.spaced]"
					if (group.spaced) img.app.overlays += image('icons/misc/air_debug.dmi', icon_state = "spaced")
					/*
					var/list/borders_space = list()
					for(var/turf/spaceses in group.space_borders)
						if(get_dist(spaceses, theTurf) == 1)
							var/dir = get_dir(theTurf, spaceses)
							if((dir & (dir-1)) == 0)
								if(dir & NORTH) borders_space[++borders_space.len] = "NORTH"
								if(dir & SOUTH) borders_space[++borders_space.len] = "SOUTH"
								if(dir & EAST) borders_space[++borders_space.len] = "EAST"
								if(dir & WEST) borders_space[++borders_space.len] = "WEST"
								var/image/airrowe = image('icons/misc/air_debug.dmi', icon_state = "space", dir = dir)
								airrowe.appearance_flags = RESET_COLOR
								img.app.overlays += airrowe
					if(borders_space.len)
						img.app.desc += "<br/>(borders space to the [borders_space.Join(" ")])"
					*/
					var/list/borders_individual = list()
					for(var/turf/ind in group.border_individual)
						if(get_dist(ind, theTurf) == 1)
							var/dir = get_dir(theTurf, ind)
							if((dir & (dir-1)) == 0)
								if(dir & NORTH) borders_individual[++borders_individual.len] = "NORTH"
								if(dir & SOUTH) borders_individual[++borders_individual.len] = "SOUTH"
								if(dir & EAST) borders_individual[++borders_individual.len] = "EAST"
								if(dir & WEST) borders_individual[++borders_individual.len] = "WEST"
								var/image/airrowe = image('icons/misc/air_debug.dmi', icon_state = "space", dir = dir)
								airrowe.appearance_flags = RESET_COLOR
								img.app.overlays += airrowe
					if(borders_individual.len)
						img.app.desc += "<br/>(borders individual to the [borders_individual.Join(" ")])"
					var/list/borders_group = list()
					for(var/turf/simulated/T in group.enemies)
						if(get_dist(T, theTurf) == 1)
							var/dir = get_dir(theTurf, T)
							if((dir & (dir-1)) == 0)
								if(dir & NORTH) borders_group[++borders_group.len] = "NORTH"
								if(dir & SOUTH) borders_group[++borders_group.len] = "SOUTH"
								if(dir & EAST) borders_group[++borders_group.len] = "EAST"
								if(dir & WEST) borders_group[++borders_group.len] = "WEST"
								var/image/airrowe = image('icons/misc/air_debug.dmi', icon_state = "space", dir = dir)
								airrowe.appearance_flags = RESET_COLOR
								if(T.parent)
									if(!T.parent.gencolor)
										T.parent.gencolor = rgb( rand(1,255),rand(1,255),rand(1,255) )
									airrowe.color = T.parent.gencolor
								img.app.overlays += airrowe
					if(borders_group.len)
						img.app.desc += "<br/>(borders groups to the [borders_group.Join(" ")])"
					if(theTurf in group.borders)
						var/image/mark = image('icons/misc/air_debug.dmi', icon_state = "border")
						mark.appearance_flags = RESET_COLOR
						img.app.overlays += mark
					if(theTurf in group.space_borders)
						var/image/mark = image('icons/misc/air_debug.dmi', icon_state = "space_border")
						mark.appearance_flags = RESET_COLOR
						img.app.overlays += mark
					if(theTurf in group.self_tile_borders)
						var/image/mark = image('icons/misc/air_debug.dmi', icon_state = "individual_border")
						mark.appearance_flags = RESET_COLOR
						img.app.overlays += mark
					if(theTurf in group.self_group_borders)
						var/image/mark = image('icons/misc/air_debug.dmi', icon_state = "group_border")
						mark.appearance_flags = RESET_COLOR
						img.app.overlays += mark
				else
					img.app.color = "#ffffff"
					img.app.desc = "No Atmos Group<br/>[MOLES_REPORT(sim)]Temperature=[sim.temperature]"
			else
				img.app.desc = "-unsimulated-"
				img.app.color = "#202020"



	atmos_status
		help = "turf color: black (no air), gray (less than normal), white (normal pressure), red (over normal)<br>top number: o2 pp%. white = breathable, orange = breathable w/ cyberlung, otherwise no good<br>middle number: atmos pressure (kPa)<br>bottom number: air temp (&deg;C)<br>colored square in bottom left:<br>color indicates group membership<br>solid: group mode on<br>outline: group mode off<br>no square: not in a group"
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			var/turf/simulated/sim = theTurf
			img.mouse_opacity = 1
			img.app.desc = ""
			img.app.color = null
			img.app.maptext = null
			if (istype(sim, /turf/simulated))
				img.app.alpha = 200

				var/datum/air_group/group = sim.parent
				var/datum/gas_mixture/air = null
				var/is_group = 0
				var/is_group_active = 0
				if (sim && sim.parent)
					if (!sim.parent.gencolor)
						group.gencolor = rgb( rand(1,255),rand(1,255),rand(1,255) )
					is_group = group.gencolor
					if (sim.parent.group_processing)
						is_group_active = 1
						air = sim.parent.air
					else
						air = sim.air
				else if (sim && sim.air)
					air = sim.air

				if (!air)
					img.app.color = "#6666FF"
					img.app.desc = "no air mix"
				else

					var/pressure = MIXTURE_PRESSURE(air)
					img.app.desc = ""


					var/breath_pressure = ((TOTAL_MOLES(air) * R_IDEAL_GAS_EQUATION * air.temperature) * BREATH_PERCENTAGE) / BREATH_VOLUME
					//Partial pressure of the O2 in our breath
					var/O2_pp = (TOTAL_MOLES(air)) && (air.oxygen / TOTAL_MOLES(air)) * breath_pressure
					var/O2_color
					var/T_color
					switch (O2_pp)
						if (17 to INFINITY)
							O2_color = "#eeeeff"
						if (9 to 17)
							O2_color = "#ff8800"
						if (-INFINITY to 0.01)
							O2_color = "#888888"
						else
							O2_color = "#ff0000"

					switch (air.temperature - T0C)
						if (100 to INFINITY)
							T_color = "#ff0000"
						if (75 to 100)
							T_color = "#ff8800"
						if (40 to 65)
							T_color = "#ffff00"
						if (15 to 40)
							T_color = "#ffffff"
						if (-15 to 0)
							T_color = "#99bbff"
						if (-40 to -15)
							T_color = "#5599ff"
						if (-INFINITY to -40)
							T_color = "#0000ff"

					T_color = "#ffffff"

					//mt.maptext = "<span class='pixel r' style='color: white; -dm-text-outline: 1px black;'>[round(TOTAL_MOLES(air), 0.1)]\n[round(pressure, 1)]\n[round(air.temperature - T0C, 1)]</span>"
					img.app.overlays = null

					if (is_group)
						var/image/gt = image('icons/Testing/atmos_testing.dmi', "group[is_group_active ? "" : "-paused"]")
						gt.appearance_flags = RESET_COLOR
						gt.color = is_group
						img.app.overlays += gt

					if (group && group.spaced) img.app.overlays += image('icons/misc/air_debug.dmi', icon_state = "spaced")

					img.app.overlays += src.makeText("<span style='color: [O2_color];'>[round(O2_pp, 0.01)]</span>\n[round(pressure, 0.1)]\n<span style='color: [T_color];'>[round(air.temperature - T0C, 1)]</span>")


					if (pressure > ONE_ATMOSPHERE)
						var/color1 = 255
						var/color2 = 255 - clamp(((pressure - ONE_ATMOSPHERE) / (ONE_ATMOSPHERE * 4)) * 255, 0, 255)
						img.app.color = rgb(color1, color2, color2)
					else
						var/color1 = clamp(pressure / ONE_ATMOSPHERE * 255, 0, 255)
						img.app.color = rgb(color1, color1, color1)


			else
				img.app.desc = "" //"unsim"
				img.app.color = "#0000ff"


	artists
		help = "Shows you the artists of the wonderful writing that's been written on the station."
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			var/list/artists = list()
			var/list/built = list()
			for(var/obj/decal/cleanable/writing/arte in theTurf)
				built += "[arte.icon_state] artpiece by [arte.artist]"
				artists |= arte.artist
			if(artists.len >= 2)
				img.app.color = "#7f0000"
			else if(artists.len == 1)
				img.app.color = debug_color_of(artists[1])
			img.app.desc = built.Join("<br/>")

	powernet
		help = {"red - contains 0 (no powernet), that's probably bad<br>white - contains multiple powernets<br>other - coloured based on the single powernet<br>numbers - ids of all powernets on the tile"}
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			img.mouse_opacity = 0
			var/list/netnums = list()
			for(var/obj/machinery/power/M in theTurf)
				if(M.netnum >= 0)
					netnums |= M.netnum
			for(var/obj/cable/C in theTurf)
				if(C.netnum >= 0)
					netnums |= C.netnum
			img.app.overlays = list(src.makeText(jointext(netnums, " ")))
			if(!netnums.len)
				img.app.color = "#00000000"
				img.app.alpha = 0
			else if(0 in netnums)
				img.app.color = "#ff0000"
			else if(netnums.len >= 2)
				img.app.color = "#ffffff"
			else
				img.app.color = debug_color_of(netnums[1])

	disposals
		help = {"shows all disposal pipes as an overlay<br>if there's stuff in a pipe it's highlighted in blue if moving and in red if stuck<br>number - how many objects are in the pipe"}
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			img.app.color = "#ffffff"
			img.app.overlays = list()
			img.app.alpha = 0
			for(var/obj/disposalpipe/pipe in theTurf)
				var/image/pipe_image = image(pipe.icon, icon_state = pipe.icon_state, dir = pipe.dir)
				img.app.alpha = 64
				pipe_image.alpha = 160
				pipe_image.appearance_flags = RESET_ALPHA | RESET_COLOR
				var/n_objects = 0
				for(var/obj/disposalholder/DH in pipe)
					n_objects += DH.contents.len
					if(DH.active)
						pipe_image.color = "#0000ff"
					else
						pipe_image.color = "#ff0000"
				if(n_objects)
					pipe_image.maptext = "<span class='pixel r ol'>[n_objects]</span>"
					pipe_image.maptext_x = -3
				img.app.overlays += pipe_image

	camera_coverage
		help = {"blue - tile visible by a camera<br>without overlay - tile not visible by a camera<br>number - number of cameras seeing the tile"}
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			if(theTurf.cameras && theTurf.cameras.len)
				img.app.overlays = list(src.makeText(theTurf.cameras.len))
				img.app.color = "#0000ff"
			else
				img.app.alpha = 0

	atmos_pipes
		help = {"highlights all atmos machinery<br>pipe color - the pipeline to which it belongs<br>numbers:<br>temperature<br>moles<br>pressure"}
		var/show_numbers = 1
		var/show_pipe_networks = 0
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			img.app.color = "#ffffff"
			img.app.overlays = list()
			img.app.alpha = 0
			for(var/obj/machinery/atmospherics/thing in theTurf)
				var/image/pipe_image = image(thing.icon, icon_state = thing.icon_state, dir = thing.dir)
				if(img.app.alpha == 0)
					img.app.alpha = 40
				pipe_image.alpha = 200
				pipe_image.appearance_flags = RESET_ALPHA | RESET_COLOR
				var/obj/machinery/atmospherics/pipe/pipe = thing
				if(istype(pipe))
					img.app.alpha = 80
					if(show_pipe_networks)
						pipe_image.color = debug_color_of(pipe.parent?.network)
					else
						pipe_image.color = debug_color_of(pipe.parent)
					var/datum/gas_mixture/air = pipe.return_air()
					if(show_numbers)
						if(TOTAL_MOLES(air) > ATMOS_EPSILON)
							pipe_image.maptext = "<span class='pixel r ol'>[round(air.temperature, 0.1)]<br>[round(TOTAL_MOLES(air), 0.1)]<br>[round(MIXTURE_PRESSURE(air), 0.1)]</span>"
							pipe_image.maptext_x = -3
						else if(TOTAL_MOLES(air) > 0)
							pipe_image.maptext = "<span class='pixel r ol'>&gt;0</span>"
							pipe_image.maptext_x = -3
				img.app.overlays += pipe_image

	atmos_pipes/without_numbers
		show_numbers = 0

	atmos_pipes/pipe_networks_instead_of_pipelines
		show_numbers = 0
		show_pipe_networks = 1

	interesting_stuff
		help = {"highlights turfs with stuff that has the var "interesting" set to something<br>red - only the turf is interesting<br>blue - interesting stuff is on the turf<br>number - number of interesting things<br>hover over the overlay to see what's interesting"}
		GetInfo(var/turf/theTurf, var/image/debugoverlay/img)
			img.app.alpha = 0
			var/list/lines = list()
			if(theTurf.interesting)
				img.app.alpha = 128
				lines += "[theTurf] - [theTurf.interesting]"
				img.app.color = "#ff0000"
			for(var/atom/A in theTurf)
				if(A.interesting)
					img.app.alpha = 128
					lines += "[A] - [A.interesting]"
					img.app.color = "#0000ff"
			if(lines.len)
				img.app.overlays = list(src.makeText(lines.len))
				img.app.desc = lines.Join("<br>")
			else
				img.app.desc = ""

	fluids
		help = {"highlights fluids<br>color - which fluid group does the fluid tile belong to<br>red - more than 1 fluid obj<br>text (one per group) - amount per tile"}
		var/type_to_process = /obj/fluid
		var/list/processed_groups
		GetInfo(turf/theTurf, image/debugoverlay/img)
			img.app.alpha = 0
			var/num_fluids = 0
			for(var/atom/X in theTurf)
				var/obj/fluid/F = X
				if(X.type != type_to_process)
					continue
				img.app.alpha = initial(img.app.alpha)
				if(num_fluids) // more than one
					img.app.overlays = list(src.makeText(">1 fluids"))
					img.app.color = "#ff0000"
					return
				var/datum/fluid_group/G = F.group
				img.app.color = debug_color_of(G)
				if(!(G in processed_groups))
					img.app.overlays = list(src.makeText(round(G.amt_per_tile, 0.1)))
					processed_groups += G
				num_fluids++

		OnStartRendering(client/C)
			processed_groups = list()

	fluids/smoke
		help = {"highlights smoke<br>color - which fluid group does the fluid tile belong to<br>red - more than 1 fluid obj<br>text (one per group) - amount per tile"}
		type_to_process = /obj/fluid/airborne

	lighting_needs_additive
		GetInfo(turf/theTurf, image/debugoverlay/img)
			img.app.color = theTurf.RL_NeedsAdditive ? "#00ff00" : "#ff0000"

	count_atoms_plus_overlays
		GetInfo(turf/theTurf, image/debugoverlay/img)
			// I should probably also count overlays on overlays but I'm lazy
			img.app.alpha = 0
			var/num = 1 + theTurf.overlays.len + theTurf.underlays.len
			for(var/X in theTurf)
				var/atom/A = X
				num += 1 + A.overlays.len + A.underlays.len
			img.app.overlays = list(src.makeText(num, RESET_ALPHA))

	count_atoms_plus_overlays_rec
		GetInfo(turf/theTurf, image/debugoverlay/img)
			img.app.alpha = 0
			var/num = 0
			for(var/X in theTurf.contents + theTurf)
				var/atom/A = X
				num += 1 + A.overlays.len + A.underlays.len
				for(var/O in A.overlays + A.underlays)
					var/atom/A2 = O
					num += A2.overlays.len + A2.underlays.len
			img.app.overlays = list(src.makeText(num, RESET_ALPHA))

	count_atoms
		GetInfo(turf/theTurf, image/debugoverlay/img)
			img.app.alpha = 0
			img.app.overlays = list(src.makeText(theTurf.contents.len, RESET_ALPHA))

	oshan_hotspots
		GetInfo(turf/theTurf, image/debugoverlay/img)
			. = ..()
			var/val = hotspot_controller.probe_turf(theTurf)
			img.app.color = rgb(val / 10, 0, 0)

			if(val)
				img.app.overlays = list(src.makeText(round(val), RESET_ALPHA))

	trace_gases // also known as Fart-o-Vision
		GetInfo(turf/theTurf, image/debugoverlay/img)
			. = ..()
			var/air_group_trace = 0
			var/direct_trace = 0
			var/turf/simulated/sim = theTurf
			if (istype(sim) && sim.air)
				for(var/datum/gas/tg in sim.air.trace_gases)
					img.app.desc += "[tg.type] [tg.moles]<br>"
					direct_trace = 1
				if(sim?.parent?.air)
					for(var/datum/gas/tg in sim.parent.air.trace_gases)
						img.app.desc += "(AG) [tg.type] [tg.moles]<br>"
						air_group_trace = 1
			if(air_group_trace && direct_trace)
				img.app.color = "#ff0000"
			else if(air_group_trace)
				img.app.color = "#ff8800"
			else if(direct_trace)
				img.app.color = "#ffff00"
			else
				img.app.color = "#ffffff"
				img.app.alpha = 50


/client/var/list/infoOverlayImages
/client/var/datum/infooverlay/activeOverlay

/image/debugoverlay
	mouse_opacity = 0
	icon = 'icons/effects/white.dmi'
	plane = PLANE_SCREEN_OVERLAYS
	override = 0
	color = null
	maptext = null
	alpha = 128
	var/mutable_appearance/debug_overlay_appearance/app = new

	New()
		..()
		app.plane = FLOAT_PLANE

	proc/reset()
		src.app.reset()
		src.mouse_opacity = initial(src.mouse_opacity)

	proc/apply()
		src.appearance = app

/mutable_appearance/debug_overlay_appearance
	icon = 'icons/effects/white.dmi'
	plane = PLANE_SCREEN_OVERLAYS
	override = 0
	color = null
	maptext = null
	alpha = 128
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM

	proc/reset()
		src.icon = initial(src.icon)
		src.color = initial(src.color)
		src.override = initial(src.override)
		src.desc = initial(src.desc)
		src.plane = initial(src.plane)
		src.overlays = initial(src.overlays)
		src.maptext = initial(src.maptext)
		src.alpha = initial(src.alpha)
		src.appearance_flags = initial(src.appearance_flags)


/client/proc/RenderOverlay()
	var/width
	var/height
	if(istext( view ))
		var/split = splittext(view, "x")
		width = text2num(split[1])+1
		height = text2num(split[2])+1
	else
		width = view*2
		height = view*2
	var/turf/center = get_turf(eye)
	activeOverlay.OnStartRendering(src)
	for(var/x = 1, x<=width , x++)
		for(var/y = 1, y<=height, y++)
			var/turf/t = locate( center.x + x - width/2, center.y + y - height/2, center.z )
			var/image/debugoverlay/overlay = infoOverlayImages[ "[x]-[y]" ]
			if(!overlay)
				continue
			overlay.loc = t
			overlay.reset()
			if(!t)
				overlay.app.icon_state = "notwhite"
				overlay.app.alpha = 0
			else
				overlay.app.icon_state = ""
				activeOverlay.GetInfo( t, overlay )
			overlay.apply()
	activeOverlay.OnFinishRendering(src)

/client/proc/GenerateOverlay()
	var/width = view
	var/height = view

	if(istext( view ))
		var/split = splittext(view, "x")
		width = text2num(split[1])/2
		height = text2num(split[2])/2
	if( !infoOverlayImages ) infoOverlayImages = list()
	for(var/x = 1, x<=width*2+1, x++)
		for(var/y = 1, y<=height*2+1, y++)
			if(!infoOverlayImages[ "[x]-[y]" ])
				var/image/debugoverlay/overlay = new
				infoOverlayImages[ "[x]-[y]" ] = overlay
				src.images += overlay

/client/proc/SetInfoOverlay( )
	set name = "Debug Overlay"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	admin_only
	var/name = input("Choose an overlay") in (childrentypesof( /datum/infooverlay ) + "Remove")
	if(activeOverlay)
		activeOverlay.OnDisabled(src)
	if(!name || name == "Remove")
		if(infoOverlayImages)
			for(var/img in infoOverlayImages)
				img = infoOverlayImages[img]//shhh
				screen -= img
				images -= img
				img:loc = null
				qdel(img)
			infoOverlayImages = list()
		activeOverlay = null
		qdel(activeOverlay)
	else
		activeOverlay = new name()
		boutput( src, "<span class='notice'>[activeOverlay.help]</span>" )
		GenerateOverlay()
		activeOverlay.OnEnabled(src)
		RenderOverlay()
		SPAWN_DBG(1 DECI SECOND)
			var/client/X = src
			while (X && X.activeOverlay)
				// its a debug overlay so f u
				X.RenderOverlay()
				sleep(1 SECOND)
/turf
	MouseEntered(location, control, params)
		if(usr.client.activeOverlay)
			var/list/lparams = params2list(params)
			var/offs = splittext(lparams["screen-loc"], ",")

			var/x = text2num(splittext(offs[1], ":")[1])+1
			var/y = text2num(splittext(offs[2], ":")[1])+1
			var/image/im = usr.client.infoOverlayImages["[x]-[y]"]
			if(im && im.desc)
				usr.client.tooltipHolder.transient.show(src, list(
					"params" = params,
					"title" = "Diagnostics",
					"content" = (im.desc)
				))
		else
			.=..()
	MouseExited()
		if(usr.client.activeOverlay)
			usr.client.tooltipHolder.transient.hide()
		else
			.=..()

/*
// having to wiggle around to update the overlay dumb, bad, esp when you can move real fast
/mob/OnMove()
	if(client && client.activeOverlay)
		client.GenerateOverlay()
		client.RenderOverlay()
	.=..()
*/
