/obj/artifact/container
	name = "artifact sealed container"
	associated_datum = /datum/artifact/container

/datum/artifact/container
	associated_object = /obj/artifact/container
	type_name = "Container"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 450
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activ_text = "seems like it has something inside of it..."
	deact_text = "locks back up."
	react_xray = list(7,50,40,11,"HOLLOW")
	var/generated_loot = FALSE

	post_setup()
		. = ..()
		src.react_heat[2] = "HIGH INTERNAL CONVECTION"

	effect_activate(obj/O)
		. = ..()
		if (.)
			return
		if (src.generated_loot)
			return
		src.generated_loot = TRUE
		switch(rand(1,4))
			if(1)
				if(prob(5))
					new/obj/item/artifact/activator_key(src.holder)
				else
					new/obj/item/cell/artifact(src.holder)
					new/obj/item/cell/artifact(src.holder)
					new/obj/item/cell/artifact(src.holder)
			if(2)
				if(prob(5))
					new/obj/critter/domestic_bee/buddy(src.holder)
					new/obj/item/clothing/suit/bee(src.holder)
				else
					new/obj/critter/domestic_bee_larva(src.holder)
					new/obj/critter/domestic_bee_larva(src.holder)
					new/obj/critter/domestic_bee_larva(src.holder)
					new/obj/critter/domestic_bee_larva(src.holder)
					new/obj/critter/domestic_bee_larva(src.holder)
			if(3)
				if(prob(5))
					new/obj/item/gimmickbomb/owlclothes(src.holder)
					new/obj/item/gimmickbomb/owlclothes(src.holder)
					new/obj/item/gimmickbomb/owlclothes(src.holder)
					new/obj/item/gimmickbomb/owlclothes(src.holder)
					new/obj/item/gimmickbomb/owlclothes(src.holder)
				else
					new/obj/item/gimmickbomb/owlclothes(src.holder)
			if(4)
				new/obj/item/old_grenade/light_gimmick(src.holder)

	effect_touch(var/obj/O,var/mob/living/user)
		. = ..()
		if (.)
			return
		for(var/atom/movable/I in (O.contents-O.vis_contents))
			I.set_loc(O.loc)
		for(var/mob/N in viewers(O, null))
			N.flash(3 SECONDS)
			if(N.client)
				shake_camera(N, 6, 16)
		O.visible_message("<span class='alert'><b>With a blinding light [O] vanishes, leaving its contents behind.</b></span>")
		O.ArtifactFaultUsed(user)
		playsound(O.loc, 'sound/effects/warp2.ogg', 50, 1)
		O.remove_artifact_forms()
		artifact_controls.artifacts -= src
		qdel(O)
