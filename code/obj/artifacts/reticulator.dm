// creatables
#define ARTRET_RESONATOR "resonator"
#define ARTRET_SCRAMBLER "scrambler"
#define ARTRET_TUNER "tuner"
#define ARTRET_PREVIOUS_ART "previous_art"
#define ARTRET_COMBINE_ARTS "combine_arts"

// modifications - to generic/categories of items, nothing specific
#define ARTRET_ADD_LIGHT "add_light"
#define ARTRET_PERFECT_GEM "perfect_gem"
#define ARTRET_BREAKDOWN_MATS "breakdown_mats"
#define ARTRET_MODIFY_MATERIAL "modify_material"
#define ARTRET_INCREASE_STORAGE "increase_storage"
#define ARTRET_INCREASE_REAGENTS "increase_reagents"
#define ARTRET_INCREASE_CELL_CAP "increase_cell_power"
#define ARTRET_INCREASE_MINING_POWER "increase_mining_power"

// machine that uses combined human and eldritch artifact technology in some way to modify things. an artifact black box that works without anyone knowing how
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
		ARTRET_SCRAMBLER = list(ARTIFACT_SHARD_ESSENCE = 2, ARTIFACT_SHARD_POWER = 1, "readable" = "2E 1P"),
		ARTRET_TUNER = list(ARTIFACT_SHARD_ESSENCE = 2, ARTIFACT_SHARD_SPACETIME = 1, "readable" = "2E 1S"),
		ARTRET_PREVIOUS_ART = list(ARTIFACT_SHARD_ESSENCE = 2, ARTIFACT_SHARD_POWER = 2, ARTIFACT_SHARD_SPACETIME = 2, "readable" = "2E 2P 2S"),
		ARTRET_COMBINE_ARTS = list(ARTIFACT_SHARD_ESSENCE = 1, ARTIFACT_SHARD_POWER = 1, ARTIFACT_SHARD_SPACETIME = 1, "readable" = "1E 1P 1S"),
		ARTRET_ADD_LIGHT = list(ARTIFACT_SHARD_ESSENCE = 1, "readable" = "1E"),
		ARTRET_PERFECT_GEM = list(ARTIFACT_SHARD_POWER = 1, "readable" = "1P"),
		ARTRET_BREAKDOWN_MATS = list(ARTIFACT_SHARD_SPACETIME = 1, "readable" = "1S"),
		ARTRET_MODIFY_MATERIAL = list(ARTIFACT_SHARD_ESSENCE = 1, ARTIFACT_SHARD_POWER = 1, ARTIFACT_SHARD_SPACETIME = 1, "readable" = "1E 1P 1S"),
		ARTRET_INCREASE_STORAGE = list(ARTIFACT_SHARD_SPACETIME = 3, "readable" = "3S"),
		ARTRET_INCREASE_REAGENTS = list(ARTIFACT_SHARD_SPACETIME = 1, "readable" = "1S"),
		ARTRET_INCREASE_CELL_CAP = list(ARTIFACT_SHARD_POWER = 1, "readable" = "1P"),
		ARTRET_INCREASE_MINING_POWER = list(ARTIFACT_SHARD_POWER = 1, "readable" = "1P"),
	)
	var/list/reticulated_artifacts = list()

	var/obj/stored_artifact
	var/obj/stored_item

	//ui_interact(mob/user, datum/tgui/ui)
	//ui_data(mob/user)
	//ui_act(action, params)

	attack_hand(mob/user)
		src.use_reticulator(user)

	attackby(obj/item/I, mob/user)
		..()
		src.MouseDrop_T(I, user, I.loc, src.loc)

	mouse_drop(atom/over_object, src_location, over_location)
		..()
		if (BOUNDS_DIST(src, over_location) > 0)
			return
		var/obj/O = over_object
		if (!istype(O) || O.anchored)
			return
		var/turf/T = get_turf(over_location)
		if (T.density)
			return
		if (ismob(src_location))
			var/mob/M = src_location
			M.drop_item(over_object)
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
		if (src.stored_artifact || !dropped.artifact || !dropped.artifact.activated)
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
					"Previous artifact ([src.get_readable_cost(ARTRET_PREVIOUS_ART)])" = ARTRET_PREVIOUS_ART,
					"Combine artifacts ([src.get_readable_cost(ARTRET_COMBINE_ARTS)])" = ARTRET_COMBINE_ARTS
				)
				var/to_create = creatables[tgui_input_list(user, "What would you like to create?[src.get_stored_info()]", "Create", creatables)]
				if (!to_create)
					return

				if (!src.can_create_thing(to_create))
					tgui_alert(user, "Can't create! Insufficient artifact shards.", "Error", list("Ok"))
					return
				if (to_create == ARTRET_COMBINE_ARTS)
					if (!src.stored_item.artifact || !src.stored_item.artifact.activated)
						tgui_alert(user, "The stored item must be an activated artifact!", "Error", list("Ok"))
						return
					if (!src.stored_artifact.can_combine_artifact(src.stored_item))
						tgui_alert(user, "The artifacts are incompatible!", "Error", list("Ok"))
						return

				src.create_thing(to_create, user)

			if ("Modify something")
				if (!src.stored_item)
					tgui_alert(user, "Can't modify! No stored item.", "Error", list("Ok"))
					return

				var/option_list = list(
					"Imbue light ([src.get_readable_cost(ARTRET_ADD_LIGHT)])" = ARTRET_ADD_LIGHT,
					"Perfect gem ([src.get_readable_cost(ARTRET_PERFECT_GEM)])" = ARTRET_PERFECT_GEM,
					"Breakdown into materials ([src.get_readable_cost(ARTRET_BREAKDOWN_MATS)])" = ARTRET_BREAKDOWN_MATS,
					"Set a material property ([src.get_readable_cost(ARTRET_MODIFY_MATERIAL)])" = ARTRET_MODIFY_MATERIAL,
					"Increase storage capacity ([src.get_readable_cost(ARTRET_INCREASE_STORAGE)])" = ARTRET_INCREASE_STORAGE,
					"Increase reagent capacity ([src.get_readable_cost(ARTRET_INCREASE_REAGENTS)])" = ARTRET_INCREASE_REAGENTS,
					"Increase power cell capacity ([src.get_readable_cost(ARTRET_INCREASE_CELL_CAP)])" = ARTRET_INCREASE_CELL_CAP,
					"Increase mining tool power ([src.get_readable_cost(ARTRET_INCREASE_MINING_POWER)])" = ARTRET_INCREASE_MINING_POWER,
				)
				var/picked_option = option_list[tgui_input_list(user, "How would you like to modify the stored item?[src.get_stored_info()]", "Pick option", option_list)]
				if (!picked_option)
					return

				if (!src.can_modify_item(src.stored_item, picked_option))
					tgui_alert(user, "Can't modify! Incompatible item or insufficient artifact shards.", "Error", list("Ok"))
					return

				src.modify_item(src.stored_item, picked_option, user)


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

		src.reticulated_artifacts[O.artifact.type_name] = O.artifact.type

		qdel(O)

	proc/can_create_thing(thing)
		return src.meets_cost_requirement(thing)

	proc/create_thing(thing, mob/user)
		switch (thing)
			if (ARTRET_RESONATOR)
				new /obj/item/artifact_resonator(get_turf(src))
			if (ARTRET_SCRAMBLER)
				new /obj/item/artifact_scrambler(get_turf(src))
			if (ARTRET_TUNER)
				new /obj/item/artifact_tuner(get_turf(src))
			if (ARTRET_PREVIOUS_ART)
				if (!length(src.reticulated_artifacts))
					tgui_alert(user, "No artifacts have been reticulated!", "Error", list("Ok"))
				else
					var/type_to_create = src.reticulated_artifacts[tgui_input_list(user, "Which artifact would you like to create?", "Create artifact", src.reticulated_artifacts)]
					if (type_to_create)
						var/obj/artifact/art = new type_to_create(get_turf(src))
						art.artifact.reticulated = TRUE
			if (ARTRET_COMBINE_ARTS)
				if (!src.stored_item.artifact || !src.stored_item.artifact.activated)
					tgui_alert(user, "The stored item must be an activated artifact!", "Error", list("Ok"))
					return
				if (!src.stored_artifact.can_combine_artifact(src.stored_item))
					tgui_alert(user, "The artifacts are incompatible!", "Error", list("Ok"))
					return
				if (tgui_alert(user, "Are you sure you wish to combine [src.stored_item] into [src.stored_artifact]? This can't be undone.", "Confirmation", list("Yes", "No")) != "Yes")
					return
				src.stored_artifact.combine_artifact(src.stored_item)
				src.stored_artifact.artifact.reticulated = TRUE
				src.stored_item = null

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
				var/typeinfo/obj/info = O.get_typeinfo()
				var/list/mats_used = info.mats
				compatible_type = length(mats_used)
			if (ARTRET_MODIFY_MATERIAL)
				compatible_type = O.material
			if (ARTRET_INCREASE_STORAGE)
				compatible_type = O.storage?.slots <= 13 && !istype(O, /obj/item/artifact/bag_of_holding)
			if (ARTRET_INCREASE_REAGENTS)
				compatible_type = O.reagents
			if (ARTRET_INCREASE_CELL_CAP)
				compatible_type = istype(O, /obj/item/cell) || istype(O, /obj/item/ammo/power_cell)
			if (ARTRET_INCREASE_MINING_POWER)
				compatible_type = istype(O, /obj/item/mining_tools)

		if (!compatible_type)
			return FALSE

		return src.meets_cost_requirement(action)

	proc/modify_item(obj/O, action, mob/user)
		switch(action)
			if (ARTRET_ADD_LIGHT)
				var/col = tgui_color_picker(user, "Select color to add", "Color selection")
				if (col)
					O.remove_simple_light("artret_added_light")
					O.add_simple_light("artret_added_light", rgb2num(col))
			if (ARTRET_PERFECT_GEM)
				var/datum/material/crystal/gemstone/mat = getMaterial(O.material.getID())
				mat.gem_tier++
				mat.update_properties()
			if (ARTRET_BREAKDOWN_MATS)
				var/typeinfo/obj/info = O.get_typeinfo()
				var/list/mats_used = info.mats
				for (var/mat in mats_used)
					var/datum/manufacturing_requirement/rqmt = getManufacturingRequirement(mat)
					var/datum/material/material = getMaterial(rqmt.get_art_ret_breakdown())
					var/bar = getProcessedMaterialForm(material)
					var/obj/item/material_piece/bar_output = new bar(get_turf(src))
					bar_output.setMaterial(material)
					bar_output.change_stack_amount(0)
			if (ARTRET_MODIFY_MATERIAL)
				var/list/props = O.material.getMaterialProperties()
				var/list/to_output = list()
				for (var/datum/material_property/prop as anything in props)
					var/prop_value = O.material.getProperty(prop.id)
					if (prop_value >= prop.max_value - 0.5 || prop_value <= prop.min_value + 0.5)
						continue
					to_output["[prop.name]: [O.material.getProperty(prop.id)]"] = prop.id
				if (!length(to_output))
					tgui_alert(user, "No available properties to modify!", "Error", list("Ok"))
					return
				var/to_modify = tgui_input_list(user, "Which property would you like to modify? It can be changed by + or - 0.5.", "Material modification", to_output)
				if (!to_modify)
					return
				var/to_change = tgui_alert(user, "Select modification for [to_modify].", "Material modification", list("+0.5", "-0.5", "Cancel"))
				if (to_change == "+0.5")
					var/material_prop_id = to_output[to_modify]
					O.material.setProperty(material_prop_id, O.material.getProperty(material_prop_id) + 0.5)
				else if (to_change == "-0.5")
					var/material_prop_id = to_output[to_modify]
					O.material.setProperty(material_prop_id, O.material.getProperty(material_prop_id) - 0.5)
			if (ARTRET_INCREASE_STORAGE)
				O.storage.increase_slots(1)
			if (ARTRET_INCREASE_REAGENTS)
				O.reagents.maximum_volume *= 1.1
				if (istype(O, /obj/item))
					var/obj/item/I = O
					I.inventory_counter?.update_counter()
			if (ARTRET_INCREASE_CELL_CAP)
				if (istype(O, /obj/item/cell))
					var/obj/item/cell/cell = O
					cell.maxcharge *= 1.1
					cell.UpdateIcon()
				else
					var/obj/item/ammo/power_cell/cell = O
					cell.max_charge *= 1.1
					cell.UpdateIcon()
			if (ARTRET_INCREASE_MINING_POWER)
				var/obj/item/mining_tools/tool = O
				tool.power *= 1.1
				if (tool.power > SPIKES_MEDAL_POWER_THRESHOLD)
					user.unlock_medal("This object menaces with spikes of...", TRUE)


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
	var/static/list/trigger_names = list()
	var/static/list/trigger_names_assoc = list()
	var/list/scanned_artifacts = list()

	New()
		..()
		if (!length(src.trigger_names))
			for (var/datum/artifact_trigger/trigger_type as anything in concrete_typesof(/datum/artifact_trigger))
				if (initial(trigger_type.used))
					src.trigger_names += initial(trigger_type.type_name)
					src.trigger_names_assoc[trigger_type] = initial(trigger_type.type_name)

	afterattack(atom/target, mob/user, reach, params)
		..()
		var/obj/O = target
		if (!istype(O) || !O.artifact)
			boutput(user, SPAN_NOTICE("[O] is not an artifact, results inconclusive."))
		else if (O.artifact.activated)
			var/datum/artifact_trigger/activating_trigger = O.artifact.triggers[1]
			boutput(user, SPAN_NOTICE("Analysis results:" + \
				"<br>Origin disguised: <B>[O.artifact.disguised ? "Yes" : "No"]</B>" + \
				"<br>Activation method: <B>[src.trigger_names_assoc[activating_trigger.type]]</B>") + \
				"<br>Artifacts combined: <B>[length(O.combined_artifacts) || 0]</B>")
		else
			if ("\ref[O]" in src.scanned_artifacts)
				boutput(user, src.scanned_artifacts["\ref[O]"])
			else
				var/datum/artifact_trigger/activating_trigger = O.artifact.triggers[1]
				var/list/possible_triggers = list(activating_trigger.type_name)
				var/list/other_triggers = src.trigger_names.Copy() - list(activating_trigger.type_name)
				for (var/i in 1 to 2)
					var/trigger = pick(other_triggers)
					other_triggers -= trigger
					possible_triggers += trigger
				shuffle_list(possible_triggers)
				src.scanned_artifacts["\ref[O]"] = SPAN_NOTICE("Analysis results:" + \
					"<br>Origin disguised: <B>[O.artifact.disguised ? "Yes" : "No"]</B>" + \
					"<br>Possible activation methods: <B>[english_list(possible_triggers)]</B>")
				boutput(user, src.scanned_artifacts["\ref[O]"])

/obj/item/artifact_scrambler
	name = "Artifact scrambler"
	desc = "A device loaded with a one-time use charge that will randomly alter the makeup of an artifact."

/obj/item/artifact_tuner
	name = "Artifact tuner"
	desc = "A device loaded with a one-time use charge that will randomly alter the faults of an activated artifact."
	var/used = FALSE

	afterattack(atom/target, mob/user, reach, params)
		..()
		if (src.used)
			return
		var/obj/O = target
		if (!istype(O) || !O.artifact)
			boutput(user, SPAN_NOTICE("[O] is not an artifact, [src] will have no effect."))
			return
		if (!O.artifact.activated)
			boutput(user, SPAN_NOTICE("[O] is not activated, [src] will have no effect."))
			return
		var/datum/artifact/artifact = O.artifact
		if (length(artifact.faults))
			if (prob(90))
				artifact.faults -= pick(artifact.faults)
			if (prob(5))
				for (var/i in 1 to rand(1, 3))
					O.ArtifactDevelopFault(100)
			else
				O.ArtifactDevelopFault(100)
		else
			O.ArtifactDevelopFault(100) // bad effect guaranteed if fault didn't exist before

		src.name = "Used artifact tuner"
		src.desc = "A used artifact tuner. It has no more use and can be thrown away."
		src.used = TRUE

#undef ARTRET_RESONATOR
#undef ARTRET_SCRAMBLER
#undef ARTRET_TUNER
#undef ARTRET_PREVIOUS_ART
#undef ARTRET_COMBINE_ARTS

#undef ARTRET_ADD_LIGHT
#undef ARTRET_PERFECT_GEM
#undef ARTRET_BREAKDOWN_MATS
#undef ARTRET_MODIFY_MATERIAL
#undef ARTRET_INCREASE_STORAGE
#undef ARTRET_INCREASE_REAGENTS
#undef ARTRET_INCREASE_CELL_CAP
#undef ARTRET_INCREASE_MINING_POWER
