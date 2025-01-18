// creatables
#define ARTRET_RESONATOR "resonator"
#define ARTRET_SCRAMBLER "scrambler"
#define ARTRET_TUNER "tuner"
#define ARTRET_PREVIOUS_ART "previous_art"
#define ARTRET_COMBINE_ARTS "combine_arts"

// modifications - to generic/categories of items, nothing specific
#define ARTRET_ADD_LIGHT "add_light"
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
	var/fusion_shards = 0
	var/omni_shards = 0
	var/static/list/costs = list(
		ARTRET_RESONATOR = list(ARTIFACT_SHARD_ESSENCE = 3, "readable" = "3 Essence"),
		ARTRET_SCRAMBLER = list(ARTIFACT_SHARD_ESSENCE = 2, ARTIFACT_SHARD_POWER = 1, "readable" = "2 Essence 1 Power"),
		ARTRET_TUNER = list(ARTIFACT_SHARD_ESSENCE = 2, ARTIFACT_SHARD_SPACETIME = 1, "readable" = "2 Essence 1 Spacetime"),
		ARTRET_PREVIOUS_ART = list(ARTIFACT_SHARD_ESSENCE = 2, ARTIFACT_SHARD_POWER = 2, ARTIFACT_SHARD_SPACETIME = 2, "readable" = "2 Essence 2 Power 2 Spacetime"),
		ARTRET_COMBINE_ARTS = list(ARTIFACT_SHARD_FUSION = 2, "readable" = "1 Fusion"),
		ARTRET_ADD_LIGHT = list(ARTIFACT_SHARD_ESSENCE = 1, "readable" = "1 Essence"),
		ARTRET_BREAKDOWN_MATS = list(ARTIFACT_SHARD_SPACETIME = 1, "readable" = "1 Spacetime"),
		ARTRET_MODIFY_MATERIAL = list(ARTIFACT_SHARD_ESSENCE = 1, ARTIFACT_SHARD_POWER = 1, ARTIFACT_SHARD_SPACETIME = 1, "readable" = "1 Essence 1 Power 1 Spacetime"),
		ARTRET_INCREASE_STORAGE = list(ARTIFACT_SHARD_SPACETIME = 3, "readable" = "3 Spacetime"),
		ARTRET_INCREASE_REAGENTS = list(ARTIFACT_SHARD_SPACETIME = 1, "readable" = "1 Spacetime"),
		ARTRET_INCREASE_CELL_CAP = list(ARTIFACT_SHARD_POWER = 1, "readable" = "1 Power"),
		ARTRET_INCREASE_MINING_POWER = list(ARTIFACT_SHARD_POWER = 1, "readable" = "1 Power"),
	)
	var/static/artifact_shard_reference
	var/list/reticulated_artifacts = list()
	var/list/reticulated_art_names = list()

	var/obj/stored_artifact
	var/obj/stored_item

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Reticulator")
			ui.open()

	ui_data(mob/user)
		. = list(
			"essenceShards" = src.essence_shards,
			"powerShards" = src.power_shards,
			"spacetimeShards" = src.spacetime_shards,
			"fusionShards" = src.fusion_shards,
			"omniShards" = src.omni_shards,
			"storedArtifact" = src.stored_artifact?.name,
			"storedItem" = src.stored_item?.name,
			"canBreakdownArtifact" = src.stored_artifact,
    		"canBreakdownFusion" = src.stored_artifact && src.stored_item?.artifact,
    		"canCreateResonator" = src.meets_cost_requirement(ARTRET_RESONATOR),
    		"canCreateTuner" = src.meets_cost_requirement(ARTRET_TUNER),
    		"canCreateArtifact" = src.meets_cost_requirement(ARTRET_PREVIOUS_ART) && length(src.reticulated_artifacts),
    		"canCombineArtifacts" = src.can_combine(src.stored_artifact, src.stored_item),
    		"canImbueLight" = src.can_modify_item(ARTRET_ADD_LIGHT),
    		"canBreakdownForMats" = src.can_modify_item(ARTRET_BREAKDOWN_MATS),
    		"canModifyMaterial" = src.can_modify_item(ARTRET_MODIFY_MATERIAL),
    		"canUpgradeStorage" = src.can_modify_item(ARTRET_INCREASE_STORAGE),
    		"canIncreaseReagents" = src.can_modify_item(ARTRET_INCREASE_REAGENTS),
    		"canIncreaseCellCapacity" = src.can_modify_item(ARTRET_INCREASE_CELL_CAP),
    		"canUpgradeMiningPower" = src.can_modify_item(ARTRET_INCREASE_MINING_POWER),
			"breakdownTip" = "Breakdown stored artifact for a shard. -Required: Correctly labeled with a form.",
			"breakdownFusionTip" = "Breakdown stored artifacts for a Fusion shard. -Required: Two correctly labeled artifacts of different shard categories.",
			"resonatorTip" = "A handy device that reveals information about unactivated and activated artifacts. -Required: [src.costs[ARTRET_RESONATOR]["readable"]]",
			"tunerTip" = "A single-use device that randomizes faults of an activated artifact. -Required: [src.costs[ARTRET_TUNER]["readable"]]",
			"createArtTip" = "Re-create a previously broken down artifact. -Required: [src.costs[ARTRET_PREVIOUS_ART]["readable"]]",
			"combineArtsTip" = "Combine compatible artifacts into a new artifact with combined properties. -Required: [src.costs[ARTRET_COMBINE_ARTS]["readable"]]",
			"imbueLightTip" = "Imbue ambient light into the stored object. -Required: [src.costs[ARTRET_ADD_LIGHT]["readable"]]",
			"breakdownMatsTip" = "Breakdown a compatible item for materials. -Required: [src.costs[ARTRET_BREAKDOWN_MATS]["readable"]]",
			"modifyMaterialTip" = "Modify a property of the stored item's material by a value of +/- 0.5. -Required: [src.costs[ARTRET_MODIFY_MATERIAL]["readable"]]",
			"upgradeStorageTip" = "Increase the storage space of the stored item by 1. -Required: [src.costs[ARTRET_INCREASE_STORAGE]["readable"]]",
			"increaseReagentsTip" = "Increase the reagent capacity of the stored item by 10%. -Required: [src.costs[ARTRET_INCREASE_REAGENTS]["readable"]]",
			"increaseCellCapTip" = "Increase the cell capacity of the stored item by 10%. -Required: [src.costs[ARTRET_INCREASE_CELL_CAP]["readable"]]",
			"upgradeMiningPowerTip" = "Increase the mining power of the stored custom mining tool by 10%. -Required: [src.costs[ARTRET_INCREASE_MINING_POWER]["readable"]]",
			"reticulatedArtifacts" = src.reticulated_art_names
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return

		switch (action)
			if ("eject_art")
				src.eject_artifact()
			if ("eject_item")
				src.eject_item()
			if ("view_database")
				src.view_database(usr)

			if ("breakdown_artifact")
				src.break_down_artifact(usr)
			if ("breakdown_fusion")
				src.break_down_artifact_fusion(usr)

			if ("create_resonator")
				src.create_thing(ARTRET_RESONATOR, usr)
			if ("create_tuner")
				src.create_thing(ARTRET_TUNER, usr)
			if ("create_artifact")
				src.create_thing(ARTRET_PREVIOUS_ART, usr)
			if ("combine_artifacts")
				src.create_thing(ARTRET_COMBINE_ARTS, usr)

			if ("imbue_light")
				src.modify_item(ARTRET_ADD_LIGHT, usr)
			if ("breakdown_mats")
				src.modify_item(ARTRET_BREAKDOWN_MATS, usr)
			if ("modify_material")
				src.modify_item(ARTRET_MODIFY_MATERIAL, usr)
			if ("upgrade_storage")
				src.modify_item(ARTRET_INCREASE_STORAGE, usr)
			if ("increase_reagents")
				src.modify_item(ARTRET_INCREASE_REAGENTS, usr)
			if ("increase_cell_capacity")
				src.modify_item(ARTRET_INCREASE_CELL_CAP, usr)
			if ("upgrade_mining_power")
				src.modify_item(ARTRET_INCREASE_MINING_POWER, usr)

	attack_hand(mob/user)
		if (..())
			return
		src.ui_interact(user)

	attackby(obj/item/I, mob/user)
		..()
		src.MouseDrop_T(I, user, I.loc, src.loc)

	mouse_drop(atom/over_object, src_location, over_location)
		..()
		if (BOUNDS_DIST(src, over_location) > 0)
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
		if (!istype(dropped) || dropped.anchored)
			return
		if (!dropped.artifact)
			if (!src.stored_item)
				if (ismob(src_location))
					var/mob/M = src_location
					M.drop_item(dropped)
				src.stored_item = dropped
				dropped.set_loc(src)
			return
		var/list/options = list()
		if (!src.stored_artifact)
			options += "Break down"
		if (!src.stored_item)
			options += "Modification"
		options += "Cancel"
		if (length(options) == 1)
			return
		var/picked = tgui_alert(user, "What would you like to load the item for?", "Pick option", options)
		if (!picked || picked == "Cancel")
			return
		if (ismob(src_location))
			var/mob/M = src_location
			M.drop_item(dropped)
		switch (picked)
			if ("Break down")
				src.stored_artifact = dropped
				dropped.set_loc(src)
			if ("Modification")
				src.stored_item = dropped
				dropped.set_loc(src)

	verb/eject()
		set name = "Eject Storage"
		set src in oview(1)
		set category = "Local"

		src.eject_artifact()
		src.eject_item()

	proc/eject_artifact()
		src.stored_artifact?.set_loc(get_turf(src))
		src.stored_artifact = null

	proc/eject_item()
		src.stored_item?.set_loc(get_turf(src))
		src.stored_item = null

	proc/can_combine(obj/art1, obj/art2)
		. = TRUE
		if (!src.stored_artifact?.artifact?.activated || !src.stored_item?.artifact?.activated)
			return FALSE
		if (!src.stored_artifact.can_combine_artifact(src.stored_item))
			return FALSE
		if (!src.meets_cost_requirement(ARTRET_COMBINE_ARTS))
			return FALSE

	proc/break_down_artifact(mob/user)
		if (tgui_alert(user, "Attempt to breakdown stored artifact for a shard? It must be labeled correctly.", "Shard Extraction", list("Yes", "No") != "Yes"))
			return
		if (!src.stored_artifact)
			return
		var/datum/artifact/artifact = src.stored_artifact.artifact
		var/obj/item/sticker/postit/artifact_paper/paper = locate(/obj/item/sticker/postit/artifact_paper) in src.stored_artifact.vis_contents
		if (!paper || paper.lastAnalysis < 3)
			qdel(src.stored_artifact)
			src.stored_artifact = null
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

		src.fusion_shards += length(src.stored_artifact.combined_artifacts)

		src.reticulated_artifacts[src.stored_artifact.artifact.type_name] = src.stored_artifact.type
		src.reticulated_art_names |= src.stored_artifact.artifact.type_name

		qdel(src.stored_artifact)
		src.stored_artifact = null

	proc/break_down_artifact_fusion(mob/user)
		if (tgui_alert(user, "Attempt to breakdown stored artifacts for a Fusion shard? They must be labeled correctly.", "Shard Extraction", list("Yes", "No") != "Yes"))
			return
		if (!src.stored_artifact || !src.stored_item)
			return
		var/art1_breakdown_successful = FALSE
		var/art2_breakdown_successful = FALSE
		var/obj/item/sticker/postit/artifact_paper/paper = locate(/obj/item/sticker/postit/artifact_paper) in src.stored_artifact.vis_contents
		art1_breakdown_successful = paper?.lastAnalysis >= 3

		paper = locate(/obj/item/sticker/postit/artifact_paper) in src.stored_item.vis_contents
		art2_breakdown_successful = paper?.lastAnalysis >= 3

		if (art1_breakdown_successful && art2_breakdown_successful)
			src.fusion_shards++
			src.fusion_shards += length(src.stored_artifact.combined_artifacts)
			src.fusion_shards += length(src.stored_item.combined_artifacts)

		src.reticulated_artifacts[src.stored_artifact.artifact.type_name] = src.stored_artifact.type
		src.reticulated_artifacts[src.stored_item.artifact.type_name] = src.stored_item.type
		src.reticulated_art_names |= src.stored_artifact.artifact.type_name
		src.reticulated_art_names |= src.stored_item.artifact.type_name

		qdel(src.stored_artifact)
		src.stored_artifact = null
		qdel(src.stored_item)
		src.stored_item = null

	proc/create_thing(thing, mob/user)
		switch (thing)
			if (ARTRET_RESONATOR)
				new /obj/item/artifact_resonator(get_turf(src))
			//if (ARTRET_SCRAMBLER)
			//	new /obj/item/artifact_scrambler(get_turf(src))
			if (ARTRET_TUNER)
				new /obj/item/artifact_tuner(get_turf(src))
			if (ARTRET_PREVIOUS_ART)
				var/type_to_create = src.reticulated_artifacts[tgui_input_list(user, "Which artifact would you like to create?", "Create artifact", src.reticulated_artifacts)]
				if (type_to_create)
					var/obj/artifact/art = new type_to_create(get_turf(src))
					art.artifact.reticulated = TRUE
					art.name_prefix("synthetic")
					art.UpdateName()
			if (ARTRET_COMBINE_ARTS)
				if (tgui_alert(user, "Are you sure you wish to combine [src.stored_item] into [src.stored_artifact]? This can't be undone.", "Confirmation", list("Yes", "No")) != "Yes")
					return
				src.stored_artifact.combine_artifact(src.stored_item)
				src.stored_artifact.artifact.reticulated = TRUE
				src.stored_artifact.name_prefix("synthetic")
				src.stored_artifact.UpdateName()
				src.stored_item = null

		src.apply_cost(thing)

	proc/meets_cost_requirement(thing)
		. = TRUE
		var/essence_required = src.costs[thing][ARTIFACT_SHARD_ESSENCE]
		var/power_required = src.costs[thing][ARTIFACT_SHARD_POWER]
		var/spacetime_required = src.costs[thing][ARTIFACT_SHARD_SPACETIME]
		var/fusion_required = src.costs[thing][ARTIFACT_SHARD_FUSION]
		var/omni_required = src.costs[thing][ARTIFACT_SHARD_OMNI]

		if (src.essence_shards < essence_required)
			return FALSE
		if (src.power_shards < power_required)
			return FALSE
		if (src.spacetime_shards < spacetime_required)
			return FALSE
		if (src.fusion_shards < fusion_required)
			return FALSE
		if (src.omni_shards < omni_required)
			return FALSE

	proc/apply_cost(thing)
		src.essence_shards -= src.costs[thing][ARTIFACT_SHARD_ESSENCE]
		src.power_shards -= src.costs[thing][ARTIFACT_SHARD_POWER]
		src.spacetime_shards -= src.costs[thing][ARTIFACT_SHARD_SPACETIME]
		src.fusion_shards -= src.costs[thing][ARTIFACT_SHARD_FUSION]
		src.omni_shards -= src.costs[thing][ARTIFACT_SHARD_OMNI]

	proc/can_modify_item(action)
		. = TRUE
		if (!src.stored_item)
			return FALSE

		var/compatible_type = FALSE
		switch (action)
			if (ARTRET_ADD_LIGHT)
				compatible_type = TRUE
			if (ARTRET_BREAKDOWN_MATS)
				var/typeinfo/obj/info = src.stored_item.get_typeinfo()
				var/list/mats_used = info?.mats
				compatible_type = length(mats_used)
			if (ARTRET_MODIFY_MATERIAL)
				compatible_type = src.stored_item.material && src.stored_item.material.isMutable()
			if (ARTRET_INCREASE_STORAGE)
				compatible_type = src.stored_item.storage && src.stored_item.storage.slots <= 13 && !istype(src.stored_item, /obj/item/artifact/bag_of_holding)
			if (ARTRET_INCREASE_REAGENTS)
				compatible_type = src.stored_item.reagents && src.stored_item.reagents.maximum_volume > 0
			if (ARTRET_INCREASE_CELL_CAP)
				compatible_type = istype(src.stored_item, /obj/item/cell) || istype(src.stored_item, /obj/item/ammo/power_cell)
			if (ARTRET_INCREASE_MINING_POWER)
				compatible_type = istype(src.stored_item, /obj/item/mining_tools)

		if (!compatible_type)
			return FALSE

		return src.meets_cost_requirement(action)

	proc/modify_item(action, mob/user)
		switch(action)
			if (ARTRET_ADD_LIGHT)
				var/col = tgui_color_picker(user, "Select color to add", "Color selection")
				if (col && src.stored_item)
					src.stored_item.remove_simple_light("artret_added_light")
					src.stored_item.add_simple_light("artret_added_light", rgb2num(col) + list(255))
			if (ARTRET_PERFECT_GEM)
				var/datum/material/crystal/gemstone/mat = getMaterial(src.stored_item.material.getID())
				mat.gem_tier++
				mat.update_properties()
			if (ARTRET_BREAKDOWN_MATS)
				var/typeinfo/obj/info = src.stored_item.get_typeinfo()
				var/list/mats_used = info.mats
				for (var/mat in mats_used)
					var/datum/manufacturing_requirement/rqmt = getManufacturingRequirement(mat)
					var/datum/material/material = getMaterial(rqmt.get_art_ret_breakdown())
					var/bar = getProcessedMaterialForm(material)
					var/obj/item/material_piece/bar_output = new bar(get_turf(src))
					bar_output.setMaterial(material)
					bar_output.change_stack_amount(0)
				qdel(src.stored_item)
				src.stored_item = null
			if (ARTRET_MODIFY_MATERIAL)
				var/list/props = src.stored_item.material.getMaterialProperties()
				var/list/to_output = list()
				for (var/datum/material_property/prop as anything in props)
					var/prop_value = src.stored_item.material.getProperty(prop.id)
					if (prop_value >= prop.max_value - 0.5 || prop_value <= prop.min_value + 0.5)
						continue
					to_output["[prop.name]: [src.stored_item.material.getProperty(prop.id)]"] = prop.id
				if (!length(to_output))
					tgui_alert(user, "No available properties to modify!", "Error", list("Ok"))
					return
				var/to_modify = tgui_input_list(user, "Which property would you like to modify? It can be changed by + or - 0.5.", "Material modification", to_output)
				if (!to_modify)
					return
				var/to_change = tgui_alert(user, "Select modification for [to_modify].", "Material modification", list("+0.5", "-0.5", "Cancel"))
				if (to_change == "+0.5")
					var/material_prop_id = to_output[to_modify]
					src.stored_item.material.setProperty(material_prop_id, src.stored_item.material.getProperty(material_prop_id) + 0.5)
				else if (to_change == "-0.5")
					var/material_prop_id = to_output[to_modify]
					src.stored_item.material.setProperty(material_prop_id, src.stored_item.material.getProperty(material_prop_id) - 0.5)
			if (ARTRET_INCREASE_STORAGE)
				src.stored_item.storage.increase_slots(1)
			if (ARTRET_INCREASE_REAGENTS)
				src.stored_item.reagents.maximum_volume *= 1.1
				if (istype(src.stored_item, /obj/item))
					var/obj/item/I = src.stored_item
					I.inventory_counter?.update_counter()
			if (ARTRET_INCREASE_CELL_CAP)
				if (istype(src.stored_item, /obj/item/cell))
					var/obj/item/cell/cell = src.stored_item
					cell.maxcharge *= 1.1
					cell.UpdateIcon()
				else
					var/obj/item/ammo/power_cell/cell = src.stored_item
					cell.max_charge *= 1.1
					cell.UpdateIcon()
			if (ARTRET_INCREASE_MINING_POWER)
				var/obj/item/mining_tools/tool = src.stored_item
				tool.power *= 1.1
				if (tool.power > SPIKES_MEDAL_POWER_THRESHOLD)
					user.unlock_medal("This object menaces with spikes of...", TRUE)

		src.apply_cost(action)

	proc/view_database(mob/user)
		if (!src.artifact_shard_reference)
			var/list/art_reference = list()
			var/str
			for (var/datum/artifact/art as anything in concrete_typesof(/datum/artifact))
				switch (initial(art.shard_reward))
					if (ARTIFACT_SHARD_ESSENCE)
						str = "Essence"
					if (ARTIFACT_SHARD_POWER)
						str = "Power"
					if (ARTIFACT_SHARD_SPACETIME)
						str = "Spacetime"
					if (ARTIFACT_SHARD_OMNI)
						str = "Omni"
				art_reference += "[initial(art.type_name)] - [str]"

			sortList(art_reference, /proc/cmp_text_asc)

			for (var/i in 1 to length(art_reference))
				src.artifact_shard_reference += art_reference[i]
				if (i != length(art_reference))
					src.artifact_shard_reference += "<br>"

		tgui_message(user, src.artifact_shard_reference, "Artifact Shard Per Artifact")

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

// to be implmented in the future. requires a rewrite of code for each artifact to allow for this. ideal way would be for this to call art_datum.New(),
// art_datum.effect_activate(), and art_datum.post_setup() but not all artifacts are compatible with that
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
#undef ARTRET_BREAKDOWN_MATS
#undef ARTRET_MODIFY_MATERIAL
#undef ARTRET_INCREASE_STORAGE
#undef ARTRET_INCREASE_REAGENTS
#undef ARTRET_INCREASE_CELL_CAP
#undef ARTRET_INCREASE_MINING_POWER
