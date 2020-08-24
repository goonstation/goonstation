/obj/swapAreaEntry
	name = "entry point"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	color = "#0000ff"
	anchored = 1
	density = 0
	invisibility = 101

/obj/swapAreaLowerLeft
	name = "lower left corner"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	color = "#0000ff"
	anchored = 1
	density = 0
	invisibility = 101

/area/swap
	name = ""
	icon_state = "purple"
	requires_power = 0
	force_fullbright = 0
	luminosity = 0
	teleport_blocked = 1

//Area x y z = lowest x y z turf contained, don't need lower left marker.

/proc/getMeThere()
	var/source = locate(/obj/swapAreaLowerLeft)
	usr.set_loc(get_turf(source))

/proc/swapTheThing()
	var/atom/source = locate(/obj/swapAreaLowerLeft)
	if(!source)
		logTheThing("debug", null, null, "Swap failed, no source")
		return 0
	var/turf/corner = locate(source.x+1,source.y+1,source.z)
	if(!corner)
		logTheThing("debug", null, null, "Swap failed, no corner")
		return 0
	var/loaded = file2text("assets/maps/prefabs/prefab_ksol.dmm")
	if(corner && loaded)
		logTheThing("debug", null, null, "Starting SwapLoad (["assets/maps/prefabs/prefab_ksol.dmm"]) at [time2text(world.timeofday)]")
		var/dmm_suite/D = new/dmm_suite()
		var/datum/loadedProperties/props = D.read_map(loaded,corner.x,corner.y,corner.z,"assets/maps/prefabs/prefab_ksol.dmm")
		logTheThing("debug", null, null, "Finished SwapLoad (["assets/maps/prefabs/prefab_ksol.dmm"]) at [time2text(world.timeofday)]")
		logTheThing("debug", null, null, "Starting SwapDelete (size : [props.maxX - props.sourceX]x - [props.maxY - props.sourceY]y) at [time2text(world.timeofday)]")
		var/count = 0
		var/list/block = block(locate(props.sourceX, props.sourceY, props.sourceZ),locate(props.maxX, props.maxY, props.sourceZ))
		for(var/x in block)
			var/turf/T = x
			for(var/Y in T)
				if(isobj(Y) && !istype(Y, /obj/overlay/tile_effect))
					qdel(Y)
					count++
		logTheThing("debug", null, null, "Finished SwapDelete (count: [count]) at [time2text(world.timeofday)]")

/datum/swapMaster
	var/busy = 0
	var/obj/swapAreaLowerLeft/source = null

	proc/placeSwapPrefab(var/prefabPath=null)
		if(busy || prefabPath == null) return 0
		if(source == null)
			source = locate(/obj/swapAreaLowerLeft)
		if(!source)
			logTheThing("debug", null, null, "Swap failed, no source")
			return 0
		var/turf/corner = locate(source.x+1,source.y+1,source.z)
		if(!corner)
			logTheThing("debug", null, null, "Swap failed, no corner")
			return 0
		busy = 1
		var/loaded = grabResource(prefabPath, preventCache = 1)
		if(corner && loaded)
			logTheThing("debug", null, null, "Starting SwapLoad ([prefabPath]) at [time2text(world.timeofday)]")
			var/dmm_suite/D = new/dmm_suite()
			D.read_map(loaded,corner.x,corner.y,corner.z,prefabPath)
			logTheThing("debug", null, null, "Finished SwapLoad ([prefabPath]) at [time2text(world.timeofday)]")
			busy = 0
			return 1
		else
			busy = 0
			return 0
