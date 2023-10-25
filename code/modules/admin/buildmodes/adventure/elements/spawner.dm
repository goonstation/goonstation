/datum/puzzlewizard/spawnloc
	name = "AB CREATE: Critter Spawn Location"
	var/critter_amount = 0
	var/critter_type
	var/critter_icon
	var/critter_icon_state
	var/initial_state = 0
	var/cvars = list()

	initialize()
		var/datum/adventure_submode/critter/adv = new() // instantiating for statics grghhgh.
		var/cname = input("What kind of critter?", "Critter type", "Skeleton") in adv.critters
		critter_amount = input("How many [cname]s to spawn?", "Critter count", 1) as num
		critter_type = adv.critters[cname]
		var/obj/critter/template = new critter_type()
		critter_icon = template.icon
		critter_icon_state = template.icon_state
		qdel(template)
		var/enstr = input("Is spawner initially enabled?", "Enabled", "yes") in list("yes", "no")
		initial_state = (enstr == "yes") ? 1 : 0
		qdel(adv)
		boutput(usr, "<span class='notice'>Left click to create a critter spawn location. Right click to set critter initial data in all <i>subsequent</i> critter spawners. Ctrl+click to proceed.</span>")
		boutput(usr, "<span class='notice'>NOTE: Set critter data BEFORE placing the spawn locations!</span>")

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				return
			if (T)
				var/obj/adventurepuzzle/triggerable/spawnloc/spawnloc = new /obj/adventurepuzzle/triggerable/spawnloc(T)
				spawnloc.icon = critter_icon
				spawnloc.icon_state = critter_icon_state
				spawnloc.critter = critter_type
				spawnloc.spawn_count = critter_amount
				spawnloc.is_on = initial_state
				for (var/vname in cvars)
					spawnloc.critter_vars[vname] = cvars[vname]
		else if ("right" in pa)
			var/vname = input("Which variable?", "Which variable?", "health") in list("aggressive", "atkcarbon", "atksilicon", "health", "opensdoors", "wanderer")
			var/vvalue = input("Set [vname] to ", "Setting variable", 0) as num
			if (!(vname in cvars))
				cvars += vname
			cvars[vname] = vvalue

/obj/adventurepuzzle/triggerable/spawnloc
	name = "critter spawn location"
	invisibility = INVIS_ADVENTURE
	icon = 'icons/misc/critter.dmi'
	icon_state = "critter_spawn"
	density = 0
	opacity = 0
	anchored = ANCHORED
	var/critter = /mob/living/critter/bear
	var/spawn_delay = 20
	var/tmp/next_spawn = 0
	var/spawn_count = 1

	var/is_on = 1

	var/static/list/triggeracts = list("Decrease spawned critters" = "sub", "Destroy" = "del", "Disable" = "off", "Do nothing" = "nop", "Enable" = "on", "Increase spawned critters" = "add", "Spawn" = "spawn")

	var/list/critter_vars = list()

	// objcritter options
	var/aggressive = null // bool
	var/atkcarbon = null // bool
	var/atksilicon = null // bool
	var/health = null // bool
	var/opensdoors = null //bool
	var/wanderer = null // bool

	// mobcritter options
	var/health_brute = null
	var/health_burn = null



	New()
		..()
		src.underlays += image('icons/obj/randompuzzles.dmi', "critter_spawn")
		if (ispath(critter, /obj/critter))
			if (src.aggressive != null)
				src.critter_vars += "aggressive"
				src.critter_vars["aggressive"] = src.aggressive

			if (src.atkcarbon != null)
				src.critter_vars += "atkcarbon"
				src.critter_vars["atkcarbon"] = src.atkcarbon

			if (src.atksilicon != null)
				src.critter_vars += "atksilicon"
				src.critter_vars["atksilicon"] = src.atksilicon

			if (src.health != null)
				src.critter_vars += "health"
				src.critter_vars["health"] = src.health

			if (src.opensdoors != null)
				src.critter_vars += "opensdoors"
				src.critter_vars["opensdoors"] = src.opensdoors

			if (src.wanderer != null)
				src.critter_vars += "wanderer"
				src.critter_vars["wanderer"] = src.wanderer

		else if (ispath(critter, /mob/living/critter))
			if (!isnull(src.critter_vars["health_brute"]))
				src.critter_vars["health_brute"] = src.health_brute
			if (!isnull(src.critter_vars["health_burn"]))
				src.critter_vars["health_burn"] = src.health_burn
		else
			stack_trace("There's an enemy spawn trigger which has a non-critter path, someone should fix that")

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("del")
				is_on = 0
				qdel(src)
			if ("sub")
				if (spawn_count > 0)
					spawn_count--
				return
			if ("add")
				if (spawn_count < 50)
					spawn_count++
				return
			if ("off")
				is_on = 0
				return
			if ("on")
				is_on = 1
				return
			if ("spawn")
				if (is_on && world.time > next_spawn)
					next_spawn = world.time + spawn_delay
					var/turf/T = get_turf(src)
					for (var/i = 0, i < spawn_count, i++)
						var/atom/movable/C = new critter(T) // we're using `.vars` anyways, who gives a shit about types
						for (var/varname in src.critter_vars)
							C.vars[varname] = src.critter_vars[varname]

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].is_on"] << is_on
		F["[path].critter"] << critter
		F["[path].spawn_delay"] << spawn_delay
		F["[path].spawn_count"] << spawn_count

		F["[path].critter_vars.COUNT"] << length(critter_vars)
		for (var/i = 1, i <= critter_vars.len, i++)
			var/varname = critter_vars[i]
			var/varvalue = critter_vars[varname]
			F["[path].critter_vars.[i].VARNAME"] << varname
			F["[path].critter_vars.[i].VARVAL"] << varvalue


	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].is_on"] >> is_on
		F["[path].critter"] >> critter
		F["[path].spawn_delay"] >> spawn_delay
		F["[path].spawn_count"] >> spawn_count

		var/cvcount
		F["[path].critter_vars.COUNT"] >> cvcount
		for (var/i = 1, i <= cvcount, i++)
			var/varname
			var/varvalue
			F["[path].critter_vars.[i].VARNAME"] >> varname
			F["[path].critter_vars.[i].VARVAL"] >> varvalue
			critter_vars += varname
			critter_vars[varname] = varvalue
