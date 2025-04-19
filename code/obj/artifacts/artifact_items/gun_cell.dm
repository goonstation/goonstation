/obj/item/ammo/power_cell/self_charging/artifact
	name = "artifact energy gun power cell"
	icon = 'icons/obj/artifacts/artifactsitemS.dmi'
	artifact = 1
	charge = 400
	max_charge = 400
	recharge_rate = 0
	mat_changename = 0
	mat_changedesc = 0

	New(var/loc, var/forceartiorigin, var/min_charge)
		//src.artifact = new /datum/artifact/energyammo(src)
		src.max_charge = rand(5,100)
		src.max_charge *= 10
		src.max_charge = max(min_charge, max_charge)
		src.recharge_rate = rand(3,30)


		var/datum/artifact/energyammo/A = new /datum/artifact/energyammo(src)
		if (forceartiorigin)
			A.validtypes = list("[forceartiorigin]")
		src.artifact = A
		SPAWN(0)
			src.ArtifactSetup()
			A.react_elec[2] = src.max_charge

		..()

	examine()
		. = list("You have no idea what this thing is!")
		if (!src.ArtifactSanityCheck())
			return
		if ((usr && (usr.traitHolder?.hasTrait("training_scientist")) || isobserver(usr)))
			for (var/obj/O as anything in (list(src) + src.combined_artifacts || list()))
				if (istext(O.artifact.examine_hint))
					. += SPAN_ARTHINT(O.artifact.examine_hint)

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby(obj/item/W, mob/user)
		if (src.Artifact_attackby(W,user))
			..()

	ArtifactActivated()
		. = ..()
		processing_items |= src
		AddComponent(/datum/component/power_cell, max_charge, null, recharge_rate, 0)

	ArtifactDeactivated()
		. = ..()
		AddComponent(/datum/component/power_cell, 1, 1, 0, 0)

	reagent_act(reagent_id,volume)
		if (..())
			return
		src.Artifact_reagent_act(reagent_id, volume)
		return

	emp_act()
		src.Artifact_emp_act()
		..()

/datum/artifact/energyammo
	associated_object = /obj/item/ammo/power_cell/self_charging/artifact
	type_name = "Small Power Cell"
	type_size = ARTIFACT_SIZE_TINY
	rarity_weight = 0
	validtypes = list("ancient","eldritch","precursor")
	automatic_activation = 1
	react_elec = list("equal",0,0)
	react_xray = list(8,80,95,11,"SEGMENTED")
	examine_hint = "It kinda looks like it's supposed to be inserted into something."
	shard_reward = ARTIFACT_SHARD_POWER
	combine_flags = ARTIFACT_ACCEPTS_ANY_COMBINE

	New()
		..()
		src.react_heat[2] = "VOLATILE REACTION DETECTED"
