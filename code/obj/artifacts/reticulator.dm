// creatables
#define ARTRET_RESONATOR "resonator"
#define ARTRET_SCRAMBLER "scrambler"
#define ARTRET_TUNER "tuner"
#define ARTRET_PREVIOUS_ART "previous_art"

// modifications
#define ARTRET_ADD_LIGHT "add_light"
#define ARTRET_PERFECT_GEM "perfect_gem"
#define ARTRET_BREAKDOWN_MATS "breakdown_mats"
#define ARTRET_INCREASE_STORAGE "increase_storage"
#define ARTRET_INCREASE_REAGENTS "increase_reagents"
#define ARTRET_INCREASE_CELL_CAP "increase_cell_power"
#define ARTRET_INCREASE_ATTACK_DMG "increase_attack_force"
#define ARTRET_INCREASE_MINING_POWER "increase_mining_power"
#define ARTRET_INCREASE_ARMOR "increase_armor"

/*
ARTRET_RESONATOR
ARTRET_SCRAMBLER
ARTRET_TUNER
ARTRET_PREVIOUS_ART
ARTRET_ADD_LIGHT
ARTRET_PERFECT_GEM
ARTRET_BREAKDOWN_MATS
ARTRET_INCREASE_STORAGE
ARTRET_INCREASE_REAGENTS
ARTRET_INCREASE_CELL_CAP
ARTRET_INCREASE_ATTACK_DMG
ARTRET_INCREASE_MINING_POWER
ARTRET_INCREASE_ARMOR
*/

/obj/machinery/reticulator
	name = "Reticulator"
	desc = "A fancy machine for doing fancy artifact things."
	icon = 'icons/obj/networked.dmi'
	icon_state = "heptemitter1"
	anchored = ANCHORED
	density = TRUE
	var/essence_shards = 0
	var/power_shards = 0
	var/spacetime_shards = 0
	var/omni_shards = 0
	var/static/list/costs = list(
		ARTRET_RESONATOR = list(ARTIFACT_SHARD_ESSENCE = 3, "readable" = "3E"),
		ARTRET_SCRAMBLER = list(),
		ARTRET_TUNER = list(),
		ARTRET_PREVIOUS_ART = list(),
		ARTRET_ADD_LIGHT = list(),
		ARTRET_PERFECT_GEM = list(),
		ARTRET_BREAKDOWN_MATS = list(),
		ARTRET_INCREASE_STORAGE = list(),
		ARTRET_INCREASE_REAGENTS = list(),
		ARTRET_INCREASE_CELL_CAP = list(),
		ARTRET_INCREASE_ATTACK_DMG = list(),
		ARTRET_INCREASE_MINING_POWER = list(),
		ARTRET_INCREASE_ARMOR = list(),
	)

	var/obj/stored_artifact
	var/obj/stored_item

	//ui_interact(mob/user, datum/tgui/ui)
	//ui_data(mob/user)
	//ui_act(action, params)

	attack_hand(mob/user)
		src.use_reticulator(user)

	mouse_drop(atom/over_object, src_location, over_location)
		..()
		if (BOUNDS_DIST(src, over_location) > 0)
			return
		var/obj/O = over_object
		if (!istype(over_object) || O.anchored)
			return
		var/turf/T = get_turf(over_location)
		if (T.density)
			return
		src.stored_artifact?.set_loc(T)
		src.stored_artifact = null
		src.stored_item?.set_loc(T)
		src.stored_item = null

	MouseDrop_T(obj/dropped, user, src_location, over_location)
		..()
		if (BOUNDS_DIST(dropped, src) > 0)
			return
		if (!istype(dropped))
			return
		var/available_slots = list("Break down artifact", "Modification", "Cancel")
		if (src.stored_artifact || !dropped.artifact)
			available_slots -= "Break down artifact"
		if (src.stored_item)
			available_slots -= "Modification"
		if (available_slots[1] == "Cancel")
			tgui_alert(user, "[src] is full!", "Error", list("Ok"))
			return
		var/picked = tgui_alert(user, "What would you like to load the item for?", "Pick option", available_slots)
		switch(picked)
			if ("Break down artifact")
				src.stored_artifact = dropped
				dropped.set_loc(src)
			if ("Modification")
				src.stored_item = dropped
				dropped.set_loc(src)

	proc/use_reticulator(mob/user)
		var/choice = tgui_input_list(user, "Choose what you would like to do.[src.get_stored_info()]", "Choose Action", list("Break down artifact", "Create something", "Modify something"))
		switch (choice)
			if ("Break down artifact")
				if (!src.stored_artifact)
					tgui_alert(user, "Can't break down! No stored artifact.", "Error", list("Ok"))
				else if (!src.can_break_down(src.stored_artifact))
					tgui_alert(user, "Can't break down! Stored artifact is unlabeled.", "Error", list("Ok"))
				else
					src.break_down_artifact(src.stored_artifact, user)

			if ("Create something")
				var/creatables = list(
					"Resonator ([src.get_readable_cost(ARTRET_RESONATOR)])" = ARTRET_RESONATOR,
					"Scrambler ([src.get_readable_cost(ARTRET_SCRAMBLER)])" = ARTRET_SCRAMBLER,
					"Tuner ([src.get_readable_cost(ARTRET_TUNER)])" = ARTRET_TUNER,
					"Previous artifact ([src.get_readable_cost(ARTRET_PREVIOUS_ART)])" = ARTRET_PREVIOUS_ART
				)
				var/to_create = creatables[tgui_input_list(user, "What would you like to create?[src.get_stored_info()]", "Create", creatables)]
				if (!to_create)
					return

				if (!src.can_create_thing(to_create))
					tgui_alert(user, "Can't create! Insufficient artifact shards.", "Error", list("Ok"))
					return

				src.create_thing(to_create)

			if ("Modify something")
				if (!src.stored_item)
					tgui_alert(user, "Can't modify! No stored item.", "Error", list("Ok"))
					return

				var/option_list = list(
					"Imbue light ([src.get_readable_cost(ARTRET_ADD_LIGHT)])" = ARTRET_ADD_LIGHT,
					"Perfect gem ([src.get_readable_cost(ARTRET_PERFECT_GEM)])" = ARTRET_PERFECT_GEM,
					"Breakdown into materials ([src.get_readable_cost(ARTRET_BREAKDOWN_MATS)])" = ARTRET_BREAKDOWN_MATS,
					"Increase storage capacity ([src.get_readable_cost(ARTRET_INCREASE_STORAGE)])" = ARTRET_INCREASE_STORAGE,
					"Increase reagent capacity ([src.get_readable_cost(ARTRET_INCREASE_REAGENTS)])" = ARTRET_INCREASE_REAGENTS,
					"Increase power cell capacity ([src.get_readable_cost(ARTRET_INCREASE_CELL_CAP)])" = ARTRET_INCREASE_CELL_CAP,
					"Increase attack force ([src.get_readable_cost(ARTRET_INCREASE_ATTACK_DMG)])" = ARTRET_INCREASE_ATTACK_DMG,
					"Increase mining tool power ([src.get_readable_cost(ARTRET_INCREASE_MINING_POWER)])" = ARTRET_INCREASE_MINING_POWER,
					"Increase armor ([src.get_readable_cost(ARTRET_INCREASE_ARMOR)])" = ARTRET_INCREASE_ARMOR
				)
				var/picked_option = option_list[tgui_input_list(user, "How would you like to modify the stored item?[src.get_stored_info()]", "Pick option", option_list)]
				if (!picked_option)
					return

				if (!src.can_modify_item(src.stored_item, picked_option))
					tgui_alert(user, "Can't modify! Incompatible item or insufficient artifact shards.", "Error", list("Ok"))
					return

				src.modify_item(src.stored_item, picked_option)


	proc/can_break_down(obj/O)
		. = TRUE
		if (!O.artifact)
			return FALSE
		var/obj/item/sticker/postit/artifact_paper/paper = locate(/obj/item/sticker/postit/artifact_paper) in O.vis_contents
		if (!paper)
			return FALSE

	proc/break_down_artifact(obj/O, mob/user)
		var/datum/artifact/artifact = O.artifact
		var/obj/item/sticker/postit/artifact_paper/paper = locate(/obj/item/sticker/postit/artifact_paper/) in O.vis_contents
		if (paper.lastAnalysis < 3)
			qdel(O)
			return

		switch (artifact.shard_reward)
			if (ARTIFACT_SHARD_ESSENCE)
				src.essence_shards++
			if (ARTIFACT_SHARD_POWER)
				src.power_shards++
			if (ARTIFACT_SHARD_SPACETIME)
				src.spacetime_shards++
			if (ARTIFACT_SHARD_OMNI)
				src.omni_shards++

		qdel(O)

	proc/can_create_thing(thing)
		return src.meets_cost_requirement(thing)

	proc/create_thing(thing)
		switch (thing)
			if (ARTRET_RESONATOR)
				new /obj/item/artifact_resonator(get_turf(src))
			if (ARTRET_SCRAMBLER)
				new /obj/item/artifact_scrambler(get_turf(src))
			if (ARTRET_TUNER)
				new /obj/item/artifact_tuner(get_turf(src))

	proc/can_modify_item(obj/O, action)
		. = TRUE

		var/compatible_type = TRUE
		switch (action)
			if (ARTRET_ADD_LIGHT)
				compatible_type = TRUE
			if (ARTRET_PERFECT_GEM)
				compatible_type = istype(O, /obj/item/raw_material/gemstone)
				if (compatible_type)
					var/datum/material/crystal/gemstone/mat = getMaterial(O.material.getID())
					compatible_type = mat.gem_tier > 1
			if (ARTRET_BREAKDOWN_MATS)
				compatible_type = TRUE
			if (ARTRET_INCREASE_STORAGE)
				compatible_type = O.storage
			if (ARTRET_INCREASE_REAGENTS)
				compatible_type = O.reagents
			if (ARTRET_INCREASE_CELL_CAP)
				compatible_type = istype(O, /obj/item/cell)
			if (ARTRET_INCREASE_ATTACK_DMG)
				compatible_type = TRUE
			if (ARTRET_INCREASE_MINING_POWER)
				compatible_type = istype(O, /obj/item/mining_tool)
			if (ARTRET_INCREASE_ARMOR)
				compatible_type = TRUE

		if (!compatible_type)
			return FALSE

		return src.meets_cost_requirement(action)

	proc/modify_item(obj/O, action)
		/*
		switch(action)
			if (ARTRET_ADD_LIGHT)
			if (ARTRET_PERFECT_GEM)
			if (ARTRET_BREAKDOWN_MATS)
			if (ARTRET_INCREASE_STORAGE)
			if (ARTRET_INCREASE_REAGENTS)
				O.reagents.maximum_volume *= 1.1
				//if (O.inventory_counter?.pct_counter)
				//	O.inventory_counter.update_percent(O.reagents.total_volume, O.reagents.maximum_volume)
			if (ARTRET_INCREASE_CELL_CAP)
			if (ARTRET_INCREASE_ATTACK_DMG)
			if (ARTRET_INCREASE_MINING_POWER)
			if (ARTRET_INCREASE_ARMOR)
		*/

	proc/meets_cost_requirement(thing)
		. = TRUE
		var/essence_required = src.costs[thing][ARTIFACT_SHARD_ESSENCE]
		var/power_required = src.costs[thing][ARTIFACT_SHARD_POWER]
		var/spacetime_required = src.costs[thing][ARTIFACT_SHARD_SPACETIME]
		var/omni_required = src.costs[thing][ARTIFACT_SHARD_OMNI]

		if (src.essence_shards < essence_required)
			return FALSE
		if (src.power_shards < power_required)
			return FALSE
		if (src.spacetime_shards < spacetime_required)
			return FALSE
		if (src.omni_shards < omni_required)
			return FALSE

	proc/get_readable_cost(action)
		return src.costs[action]["readable"]

	proc/get_stored_info()
		return "<br>Stored artifact: [src.stored_artifact || "None"]" + \
			"<br>Stored item: [src.stored_item || "None"]" + \
			"<br>Essence shards (E): [src.essence_shards]" + \
			"<br>Power shards (P): [src.power_shards]" + \
			"<br>Spacetime shards (S): [src.spacetime_shards]" + \
			"<br>Omnishards (O): [src.omni_shards]"

/obj/item/artifact_resonator
	name = "Artifact resonator"
	desc = "A useful device to assist in activating artifacts. It has the ability to detect disguised origin artifacts, as well as possible activation methods."

	afterattack(atom/target, mob/user, reach, params)
		..()
		var/obj/O = target
		if (!istype(O) || !O.artifact)
			boutput(user, SPAN_NOTICE("[O] is not an artifact, results inconclusive."))
		else if (O.artifact.activated)
			boutput(user, SPAN_NOTICE("[O] has been activated already!")) // activation method
		else
			// stuff

/obj/item/artifact_scrambler
	name = "Artifact scrambler"
	desc = "A device loaded with a one-time use charge that will randomly alter the makeup of an artifact."

/obj/item/artifact_tuner
	name = "Artifact tuner"
	desc = "A device loaded with a one-time use charge that will randomly alter the faults of an artifact."

#undef ARTRET_RESONATOR
#undef ARTRET_SCRAMBLER
#undef ARTRET_TUNER
#undef ARTRET_PREVIOUS_ART

#undef ARTRET_ADD_LIGHT
#undef ARTRET_PERFECT_GEM
#undef ARTRET_BREAKDOWN_MATS
#undef ARTRET_INCREASE_STORAGE
#undef ARTRET_INCREASE_REAGENTS
#undef ARTRET_INCREASE_CELL_CAP
#undef ARTRET_INCREASE_ATTACK_DMG
#undef ARTRET_INCREASE_MINING_POWER
#undef ARTRET_INCREASE_ARMOR
