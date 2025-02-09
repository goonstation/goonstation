ADMIN_INTERACT_PROCS(/obj/geode, proc/break_open)
/obj/geode
	name = "rock geode"
	desc = "A very tough looking lump of rock."
	icon = 'icons/obj/geodes.dmi'
	icon_state = "pale"
	density = TRUE
	var/broken = FALSE
	var/break_power = 5
	///Weighting var for the random asteroid generation
	var/weight = 100

	proc/break_open()
		SHOULD_CALL_PARENT(TRUE)
		src.broken = TRUE
		src.icon_state = "[initial(src.icon_state)]-broken"
		src.visible_message(SPAN_ALERT("[src] breaks open!"))
		src.desc = "Half of a broken open rock geode."
		for (var/atom/movable/AM as anything in src.contents) //let admins hide goodies in here
			AM.set_loc(src.loc)

	ex_act(severity, last_touched, power, datum/explosion/explosion)
		if (!src.broken && ((explosion?.power || power) >= src.break_power))
			src.break_open()
		else if (src.broken && severity < 3) //prevent spamming concussive charges
			for (var/i in 1 to rand(2,3))
				new /obj/item/raw_material/rock(src.loc)
			qdel(src)

/obj/geode/crystal
	icon_state = "pale"
	var/crystal_path = /obj/item/raw_material/molitz
	var/amount = 5
	///If true, look for custom material icon states in the form `crystals$$materialname`, otherwise do a best attempt to recolour using the material colour
	///Darker materials (ie uqil) may need custom crystal sprites
	var/custom_crystal_states = FALSE
	var/embedded_crystals_left = 1

	New()
		..()
		src.set_crystal(src.crystal_path)
		src.embedded_crystals_left = rand(1,3)

	proc/get_crystal_material()
		RETURN_TYPE(/datum/material)
		var/obj/item/item_path = src.crystal_path
		return getMaterial(initial(item_path.default_material))

	proc/update_crystal_overlay()
		var/datum/material/crystal_material = src.get_crystal_material()
		var/image/crystals = null
		if (src.custom_crystal_states)
			crystals = image('icons/obj/geodes.dmi', "crystals[src.broken ? "-broken" : ""]$$[crystal_material.getID()]")
		else
			crystals = image('icons/obj/geodes.dmi', "crystals[src.broken ? "-broken" : ""]")
			crystals.color = crystal_material.getColor()
			crystals.alpha = 200
		src.AddOverlays(crystals, "crystals")

	proc/set_crystal(crystal_path)
		src.crystal_path = crystal_path
		src.update_crystal_overlay()

	break_open()
		for (var/i in 1 to src.amount)
			new src.crystal_path(src)
		..()
		src.update_crystal_overlay()

	attackby(obj/item/I, mob/user)
		if (!istypes(I, list(/obj/item/mining_tool, /obj/item/mining_tools)))
			return ..()
		if (!src.broken)
			boutput(user, SPAN_ALERT("Your [I.name] fails to make a dent in the tough rock."))
			return
		if (src.embedded_crystals_left <= 0)
			for (var/i in 1 to 3)
				new /obj/item/raw_material/rock(src.loc)
			src.visible_message(SPAN_ALERT("[src] smashes into pieces!"))
			qdel(src)
			return
		src.embedded_crystals_left--
		playsound(src.loc, 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', 50, 1)
		var/spawn_type = pick(100; /obj/item/raw_material/molitz, 50; src.crystal_path, 10; /obj/item/raw_material/gemstone)
		var/obj/item/crystal = new spawn_type(src.loc)
		boutput(user, SPAN_NOTICE("You pry \a [crystal] from [src]."))
		user.lastattacked = src //is this how this works?

	claretine
		amount = 6
		crystal_path = /obj/item/raw_material/claretine

	molitz_b
		crystal_path = /obj/item/raw_material/molitz_beta
		break_open()
			..()
			var/turf/simulated/T = get_turf(src)
			if (!istype(T))
				return
			var/datum/gas_mixture/release_gas = new
			release_gas.oxygen_agent_b = 400
			release_gas.temperature = T20C
			T.assume_air(release_gas)

	starstone
		icon_state = "dark"
		crystal_path = /obj/item/raw_material/starstone
		custom_crystal_states = TRUE
		weight = 20
		New()
			src.amount = rand(1,2)
			..()
			src.break_power = rand(15, 40)

	uqill
		icon_state = "red"
		crystal_path = /obj/item/raw_material/uqill
		custom_crystal_states = TRUE
		weight = 40
		New()
			..()
			src.break_power = rand(3, 10) //small chance you can break it with just a concussive charge

	erebite
		icon_state = "sandy"
		crystal_path = /obj/item/raw_material/erebite
		amount = 2
		weight = 60

ABSTRACT_TYPE(/obj/geode/fluid)
/obj/geode/fluid
	var/reagent_id = null
	var/temperature = 20 + T0C
	New()
		..()
		var/amt = rand(100, 300)
		src.create_reagents(amt)
		if (src.reagent_id)
			src.reagents.add_reagent(src.reagent_id, amt, temp_new = temperature)
		src.AddComponent(/datum/component/reagent_overlay, 'icons/obj/geodes.dmi', "trickles", 1)

	break_open()
		..()
		var/obj/reagent_dispensers/geode/fluid_shell = new(src.loc, src.reagents.total_volume)
		src.reagents.trans_to(fluid_shell, src.reagents.total_volume)
		fluid_shell.icon_state = src.icon_state
		if (src.material)
			fluid_shell.setMaterial(src.material)
		qdel(src)

	oil //weighted in generation code separately so it can be consistently high as more variants are added
		icon_state = "sandy"
		reagent_id = "oil"
		weight = 0

	sulfuric_acid
		reagent_id = "acid"
	//hehehehe
	cyanide
		reagent_id = "cyanide"
		temperature = 50 + T0C
	ants
		reagent_id = "ants"
		weight = 20
		break_open()
			new /mob/living/critter/fermid/worker(src.loc) //beeg ant
			src.visible_message(SPAN_ALERT(SPAN_BOLD("An angry fermid jumps out of [src]!")))
			..()

	gnesis
		default_material = "gnesis"
		uses_default_material_appearance = TRUE
		reagent_id = "flockdrone_fluid"
		weight = 20


/obj/reagent_dispensers/geode
	name = "broken geode"
	icon = 'icons/obj/geodes.dmi'
	icon_state = "pale-broken"

	New(loc, capacity)
		. = ..()
		src.flags |= OPENCONTAINER

	special_desc()
		return "Half of a broken open rock geode[src.reagents.total_volume > 0 ? ", filled with some kind of liquid" : "."]"

	New(loc, capacity)
		src.capacity = capacity || 400
		..()
		src.AddComponent(/datum/component/reagent_overlay, 'icons/obj/geodes.dmi', "geode", 4)
