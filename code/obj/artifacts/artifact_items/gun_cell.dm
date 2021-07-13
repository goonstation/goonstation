/obj/item/ammo/power_cell/self_charging/artifact
	name = "artifact energy gun power cell"
	icon = 'icons/obj/artifacts/artifactsitemS.dmi'
	artifact = 1
	charge = 400.0
	max_charge = 400.0
	var/chargeCap = 400.0
	recharge_rate = 0.0
	module_research_no_diminish = 1
	mat_changename = 0
	mat_changedesc = 0

	New(var/loc, var/forceartiorigin)
		//src.artifact = new /datum/artifact/energyammo(src)
		var/datum/artifact/energyammo/A = new /datum/artifact/energyammo(src)
		if (forceartiorigin)
			A.validtypes = list("[forceartiorigin]")
		src.artifact = A
		SPAWN_DBG(0)
			src.ArtifactSetup()

			src.max_charge = rand(5,100)
			src.max_charge *= 10
			src.chargeCap = src.max_charge
			A.react_elec[2] = src.max_charge
			src.recharge_rate = rand(5,60)
		..()

	examine()
		. = list("You have no idea what this thing is!")
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (istext(A.examine_hint))
			. += A.examine_hint

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.Artifact_attackby(W,user))
			..()

	ArtifactActivated()
		. = ..()
		src.max_charge = src.chargeCap
		processing_items |= src

	ArtifactDeactivated()
		. = ..()
		src.max_charge = 1 // no divide by 0 pls
		src.charge = 1

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
	type_name = "Small power cell"
	rarity_weight = 0
	validtypes = list("ancient","eldritch","precursor")
	automatic_activation = 1
	react_elec = list("equal",0,0)
	react_xray = list(8,80,95,11,"SEGMENTED")
	examine_hint = "It kinda looks like it's supposed to be inserted into something."
	module_research = list("energy" = 15, "weapons" = 1, "miniaturization" = 15)
	module_research_insight = 1

	New()
		..()
		src.react_heat[2] = "VOLATILE REACTION DETECTED"
