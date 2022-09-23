/obj/artifact/container
	name = "artifact sealed container"
	associated_datum = /datum/artifact/container

	New(var/loc, var/forceartiorigin)
		..()

	ArtifactActivated(var/mob/living/user as mob)
		var/datum/artifact/A = src.artifact
		if (A.activated)
			return
		A.activated = 1
		playsound(src.loc, A.activ_sound, 100, 1)
		src.overlays += A.fx_image
		src.visible_message("<b>[src] seems like it has something inside it...</b>")
		switch(rand(1,4))
			if(1)
				if(prob(5))
					new/obj/item/artifact/activator_key(src)
				else
					new/obj/item/cell/artifact(src)
					new/obj/item/cell/artifact(src)
					new/obj/item/cell/artifact(src)
			if(2)
				if(prob(5))
					new/obj/critter/domestic_bee/buddy(src)
					new/obj/item/clothing/suit/bee(src)
				else
					new/obj/critter/domestic_bee_larva(src)
					new/obj/critter/domestic_bee_larva(src)
					new/obj/critter/domestic_bee_larva(src)
					new/obj/critter/domestic_bee_larva(src)
					new/obj/critter/domestic_bee_larva(src)
			if(3)
				if(prob(5))
					new/obj/item/gimmickbomb/owlclothes(src)
					new/obj/item/gimmickbomb/owlclothes(src)
					new/obj/item/gimmickbomb/owlclothes(src)
					new/obj/item/gimmickbomb/owlclothes(src)
					new/obj/item/gimmickbomb/owlclothes(src)
				else
					new/obj/item/gimmickbomb/owlclothes(src)
			if(4)
				new/obj/item/old_grenade/light_gimmick(src)

/datum/artifact/container
	associated_object = /obj/artifact/container
	type_name = "Container"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 450
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activ_text = "deposits its contents on the ground."
	deact_text = "ceases functioning."
	react_xray = list(7,50,40,11,"HOLLOW")

	New()
		..()
		src.react_heat[2] = "HIGH INTERNAL CONVECTION"

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
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
		return
