/obj/artifact/augmentor
	name = "artifact augmentor"
	associated_datum = /datum/artifact/augmentor

/datum/artifact/augmentor
	associated_object = /obj/artifact/augmentor
	type_name = "Surgery machine (cyborg/synth)"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	validtypes = list("ancient","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,
	/datum/artifact_trigger/cold, /datum/artifact_trigger/language)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activ_text = "opens up, revealing an array of strange tools!"
	deact_text = "closes itself up."
	react_xray = list(6,75,60,11,"SEGMENTED")
	combine_flags = ARTIFACT_ACCEPTS_ANY_COMBINE | ARTIFACT_COMBINES_INTO_LARGE
	combine_effect_priority = ARTIFACT_COMBINATION_TOUCHED
	var/datum/artifact_augmentation/augment = null
	var/augment_location = list()
	var/recharge_time = 600
	var/recharging = 0
	var/working = 0
	// per person
	var/limited_use = FALSE
	var/max_uses = INFINITY
	var/list/uses = list()
	// this monster of a list is used for quick reference to a path
	var/list/work_sounds = list('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/effects/airbridge_dpl.ogg','sound/impact_sounds/Slimy_Splat_1.ogg','sound/impact_sounds/Flesh_Tear_2.ogg','sound/impact_sounds/Slimy_Hit_3.ogg')
	var/global/list/augmentation_instances = list()

	// convenience dictionary because fuck writing a dozen more switch cases for this
	// this probably ought to be not here but i'll see if anything else uses it before i move it somewhere more central
	var/global/list/organ_names = list(
		"l_arm" = "left arm",
		"r_arm" = "right arm",
		"l_leg" = "left leg",
		"r_leg" = "right leg",
		"left_eye" = "left eye",
		"right_eye" = "right eye",
		"heart" = "heart",
		"butt" = "butt",
		"stomach" = "stomach",
		"intestines" = "intestines",
		"tail" = "tail",
		"pancreas" = "pancreas",
		"liver" = "liver",
		"spleen" = "spleen",
		"left_lung" = "left lung",
		"right_lung" = "right lung",
		"left_kidney" = "left kidney",
		"right_kidney" = "right kidney",
		"appendix" = "appendix")

	// lazy initialiser for augmentation datum cache
	proc/get_augmentation(var/type)
		if(augmentation_instances[type])
			return augmentation_instances[type]
		else
			var augmentation_path = text2path("/datum/artifact_augmentation/[type]")
			if(augmentation_path)
				var/datum/artifact_augmentation/augmentation = new augmentation_path
				augmentation_instances[type] = augmentation
				return augmentation

	post_setup()
		. = ..()
		recharge_time = rand(5,10) * 10
		// decide what augmentation this does
		switch(artitype.name)
			if ("ancient")
				// robot limbs
				augment = get_augmentation("borg")
			else
				// anything whatsoever
				augment = get_augmentation(pick("borg", "synth"))

		if(!augment)
			// we don't have augmentation data!!
			// backup: instantiate our own borg datum
			augment = new /datum/artifact_augmentation/borg()
		// which body parts should be augmented?

		if(prob(augment.area_chance))
			augment_location += "limbs"
		if(prob(augment.area_chance))
			augment_location += "eyes"
		if(prob(augment.area_chance))
			augment_location += "organs_1"
		if(prob(augment.area_chance))
			augment_location += "organs_2"
		if(prob(augment.area_chance))
			augment_location += "organs_3"
		if(prob(augment.area_chance))
			augment_location += "organs_4"
		if(!length(augment_location)) // just to be sure
			augment_location += "limbs"

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if(working)
			return
		if(recharging)
			boutput(user, "<b>[O]</b> doesn't react to your touch.")
			return
		var/turf/T = get_turf(O)

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(!H) return

			var/part_loc = augment.get_part_target(H, augment_location)
			if(!part_loc || (limited_use && uses[H.bioHolder.uid_hash] == max_uses))
				// you're already perfect, limbwise
				boutput(H, "<b>[O]</b> twitches slightly, then returns to a ready position.")
				return

			working = 1
			T.visible_message(SPAN_ALERT("<b>[O]</b> suddenly lashes out at [H.name] with a flurry of sharp implements!"))
			H.changeStatus("unconscious", 4 SECONDS)
			playsound(H.loc, pick(work_sounds), 50, 1, -1)
			random_brute_damage(user, 10)
			sleep(1 SECOND)

			var/obj/item/part_type = augment.get_part_type(part_loc)
			var/obj/item/part = new part_type()
			var/remove_action = "removes"
			var/replace_action = "appends something else"
			if(part)
				src.augment.modify_part(part)
				if(istype(part, /obj/item/parts)) // LIMBS
					var/obj/item/parts/old_limb = H.limbs.get_limb(part_loc)
					if(old_limb)
						old_limb.remove(FALSE)
					H.limbs.replace_with(part_loc, part_type, null , 0)
					H.update_body()
					remove_action = pick("tears off", "yanks off", "chops off")
					replace_action = pick("attaches something else to the stump", "reattaches it where it once was")
					ArtifactLogs(user, null, O, "touched by [H.real_name]", "given limb [part] as [part_loc]", 0)
				else // ORGANS
					var/obj/item/organ = part
					H.drop_organ(part_loc)
					H.receive_organ(organ, part_loc, 0, 1)
					H.update_body()
					remove_action = pick("rips out", "tears out", "swiftly removes")
					replace_action = pick("inserts something else where it was", "places something else inside", "shoves something else in their body")
					ArtifactLogs(user, null, O, "touched by [H.real_name]", "given organ [part] as [part_loc]", 0)

				T.visible_message(SPAN_ALERT("<b>[O]</b> [remove_action] [H.name]'s [organ_names[part_loc]], pulls it inside and [replace_action]! [pick("", "Holy fuck!", "It looks incredibly painful!")]"))

			playsound(H.loc, pick(work_sounds), 50, 1, -1)
			boutput(H, SPAN_ALERT("<b>[pick("IT HURTS!", "OH GOD!", "JESUS FUCK!")]</b>"))
			H.emote("scream")
			random_brute_damage(user, 30)
			bleed(H, 5, 5)
			O.ArtifactFaultUsed(H)
			if (limited_use)
				uses[H.bioHolder.uid_hash]++
			T.visible_message("<b>[O]</b> withdraws its instruments and slams shut.")
			working = 0
			recharging = 1
			SPAWN(recharge_time)
			recharging = 0
			T.visible_message("<b>[O]</b> opens itself up again.")
		else
			boutput(user, "<b>[O]</b> doesn't react to your touch.")




/datum/artifact_augmentation // DO NOT INSTANTIATE
	var/list/left_arm = list()
	var/list/right_arm = list()
	var/list/left_leg = list()
	var/list/right_leg = list()
	var/list/eye = list()
	var/list/heart = list()
	var/list/butt = list()
	var/list/stomach = list()
	var/list/intestines = list()
	var/list/tail = list()
	var/list/pancreas = list()
	var/list/liver = list()
	var/list/spleen = list()
	var/list/left_lung = list() // unlike eyes, there is actually left and right types
	var/list/right_lung = list()
	var/list/left_kidney = list()
	var/list/right_kidney = list()
	var/list/appendix = list()

	var/list/part_list = list()
	var/list/limbs = list("l_arm", "r_arm", "l_leg", "r_leg")
	var/list/eyes = list("left_eye", "right_eye")
	var/list/organs_1 = list("stomach", "intestines", "butt", "tail")
	var/list/organs_2 = list("pancreas", "liver", "spleen")
	var/list/organs_3 = list("left_lung", "right_lung", "heart")
	var/list/organs_4 = list("left_kidney", "right_kidney", "appendix")

	var/area_chance = 25

	New()
		..()
		part_list["l_arm"] = left_arm
		part_list["r_arm"] = right_arm
		part_list["l_leg"] = left_leg
		part_list["r_leg"] = right_leg
		part_list["left_eye"] = eye
		part_list["right_eye"] = eye
		part_list["heart"] = heart
		part_list["butt"] = butt
		part_list["stomach"] = stomach
		part_list["intestines"] = intestines
		part_list["tail"] = tail
		part_list["pancreas"] = pancreas
		part_list["liver"] = liver
		part_list["spleen"] = spleen
		part_list["left_lung"] = left_lung
		part_list["right_lung"] = right_lung
		part_list["left_kidney"] = left_kidney
		part_list["right_kidney"] = right_kidney
		part_list["appendix"] = appendix

	proc/get_part_target(var/mob/living/carbon/human/H, var/part_category)
		if(!H) return
		var/list/available_parts = part_list.Copy()
		var/list/parts = list()
		for (var/body_area in part_category)
			switch(body_area)
				if("limbs")
					parts += limbs
				if("eyes")
					parts += eyes
				if("organs_1")
					parts += organs_1
				if("organs_2")
					parts += organs_2
				if("organs_3")
					parts += organs_3
				if("organs_4")
					parts += organs_4
		available_parts &= parts
		if(!H.organHolder)
			available_parts -= organs_1
			available_parts -= organs_2
			available_parts -= organs_3
			available_parts -= organs_4
		if(!H.limbs)
			available_parts -= limbs
		if(length(available_parts) <= 0)
			return // something went horribly wrong, abort

		var/list/missing_parts = list()
		var/list/candidates_to_remove = list()
		for(var/part_loc in available_parts)
			if(!length(available_parts[part_loc])) // sorry, we do not sell tails here
				candidates_to_remove += part_loc
				continue
			var/obj/item/bodypart = null
			if(part_loc in limbs)
				bodypart = H.limbs.get_limb(part_loc)
			else
				bodypart = H.get_organ(part_loc)
			if(!bodypart)
				missing_parts += part_loc
			else if(is_augmented_part(bodypart, part_loc))
				candidates_to_remove += part_loc
		if(length(missing_parts) > 0)
			// we have body parts of the target missing, pick one of them
			return pick(missing_parts)
		available_parts -= candidates_to_remove
		if(length(available_parts) > 0)
			return pick(available_parts)
		// else, return null (no unupgraded parts left)

	// get a random augmented body part type for the given part location
	proc/get_part_type(var/part_loc)
		if(!part_loc)
			return
		if(part_loc in part_list)
			var/list/augmented_part_types = part_list[part_loc]
			if(length(augmented_part_types))
				return pick(augmented_part_types)

	// check if given body part (in specific body location) should count as augmented or not
	proc/is_augmented_part(var/obj/item/bodypart, var/bodypart_loc)
		if(!bodypart) return
		if(!bodypart_loc) return

		. = 0 // assume false
		var/list/upgrade_types = part_list[bodypart_loc]
		if(!upgrade_types) return
		for(var/upgrade_type in upgrade_types)
			if(istype(bodypart, upgrade_type))
				. = 1
				return // early interrupt the for loop, we don't need to check further

	proc/modify_part(var/obj/item/bodypart)
		return

/datum/artifact_augmentation/borg
	left_arm = list(/obj/item/parts/robot_parts/arm/left/light, /obj/item/parts/robot_parts/arm/left/standard)
	right_arm = list(/obj/item/parts/robot_parts/arm/right/light, /obj/item/parts/robot_parts/arm/right/standard)
	left_leg = list(/obj/item/parts/robot_parts/leg/left/standard, /obj/item/parts/robot_parts/leg/left/light, /obj/item/parts/robot_parts/leg/left/treads)
	right_leg = list(/obj/item/parts/robot_parts/leg/right/standard, /obj/item/parts/robot_parts/leg/right/light, /obj/item/parts/robot_parts/leg/right/treads)
	eye = list(/obj/item/organ/eye/cyber/configurable,/obj/item/organ/eye/cyber/sunglass,/obj/item/organ/eye/cyber/sechud,/obj/item/organ/eye/cyber/thermal,/obj/item/organ/eye/cyber/meson,/obj/item/organ/eye/cyber/spectro,/obj/item/organ/eye/cyber/prodoc,/obj/item/organ/eye/cyber/ecto,/obj/item/organ/eye/cyber/camera,/obj/item/organ/eye/cyber/nightvision,/obj/item/organ/eye/cyber/laser)
	heart = list(/obj/item/organ/heart/cyber)
	butt = list(/obj/item/clothing/head/butt/cyberbutt)
	stomach = list(/obj/item/organ/stomach/cyber)
	intestines = list(/obj/item/organ/intestines/cyber)
	tail = list()
	pancreas = list(/obj/item/organ/pancreas/cyber)
	liver = list(/obj/item/organ/liver/cyber)
	spleen = list(/obj/item/organ/spleen/cyber)
	left_lung = list(/obj/item/organ/lung/cyber/left)
	right_lung = list(/obj/item/organ/lung/cyber/right)
	left_kidney = list(/obj/item/organ/kidney/cyber/left)
	right_kidney = list(/obj/item/organ/kidney/cyber/right)
	appendix = list(/obj/item/organ/appendix/cyber)

	modify_part(var/obj/item/bodypart)
		if(istype(bodypart, /obj/item/organ/kidney/cyber))
			var/obj/item/organ/kidney/cyber/kidney = bodypart
			kidney.randomize_modifier()

/datum/artifact_augmentation/synth
	left_arm = list(/obj/item/parts/human_parts/arm/left/synth, /obj/item/parts/human_parts/arm/left/synth/bloom)
	right_arm = list(/obj/item/parts/human_parts/arm/right/synth, /obj/item/parts/human_parts/arm/right/synth/bloom)
	left_leg = list(/obj/item/parts/human_parts/leg/left/synth, /obj/item/parts/human_parts/leg/left/synth/bloom)
	right_leg = list(/obj/item/parts/human_parts/leg/right/synth, /obj/item/parts/human_parts/leg/right/synth/bloom)
	eye = list(/obj/item/organ/eye/synth)
	heart = list(/obj/item/organ/heart/synth)
	butt = list(/obj/item/clothing/head/butt/synth)
	stomach = list(/obj/item/organ/stomach/synth)
	intestines = list(/obj/item/organ/intestines/synth)
	tail = list()
	pancreas = list(/obj/item/organ/pancreas/synth)
	liver = list(/obj/item/organ/liver/synth)
	spleen = list(/obj/item/organ/spleen/synth)
	left_lung = list(/obj/item/organ/lung/synth/left)
	right_lung = list(/obj/item/organ/lung/synth/right)
	left_kidney = list(/obj/item/organ/kidney/synth/left)
	right_kidney = list(/obj/item/organ/kidney/synth/right)
	appendix = list(/obj/item/organ/appendix/synth)

/obj/artifact/augmentor/limb_augmentor
	name = "artifact limb augmentor"
	associated_datum = /datum/artifact/augmentor/limb_augmentor

/datum/artifact/augmentor/limb_augmentor
	associated_object = /obj/artifact/augmentor/limb_augmentor
	type_name = "Surgery machine (artifact limbs)"
	rarity_weight = 200
	validtypes = list("eldritch", "martian", "precursor")
	limited_use = TRUE
	max_uses = 2
	work_sounds = list('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Slimy_Splat_1.ogg','sound/impact_sounds/Flesh_Tear_2.ogg','sound/impact_sounds/Slimy_Hit_3.ogg')

	post_setup()
		. = ..()
		recharge_time = pick(30, 60) SECONDS

		switch(artitype.name)
			if ("eldritch")
				augment = get_augmentation("artifact/artifact_eldritch")
			if ("martian")
				augment = get_augmentation("artifact/artifact_martian")
			if ("precursor")
				augment = get_augmentation("artifact/artifact_precursor")

		augment_location += "limbs"

/datum/artifact_augmentation/artifact
	get_part_target(mob/living/carbon/human/H)
		var/list/valid_limbs = list()
		for (var/limb in limbs)
			if (!istype(H.limbs.get_limb(limb), part_list[limb][1]))
				valid_limbs += limb

		if (!length(valid_limbs))
			return

		if (("l_arm" in valid_limbs) && !("r_arm" in valid_limbs))
			return "l_arm"
		if (!("l_arm" in valid_limbs) && ("r_arm" in valid_limbs))
			return "r_arm"
		if (("l_leg" in valid_limbs) && !("r_leg" in valid_limbs))
			return "l_leg"
		if (!("l_leg" in valid_limbs) && ("r_leg" in valid_limbs))
			return "r_leg"
		return pick(valid_limbs)

	get_part_type(part_loc)
		return part_list[part_loc][1]

/datum/artifact_augmentation/artifact/artifact_eldritch
	left_arm = list(/obj/item/parts/artifact_parts/arm/eldritch/left)
	right_arm = list(/obj/item/parts/artifact_parts/arm/eldritch/right)
	left_leg = list(/obj/item/parts/artifact_parts/leg/eldritch/left)
	right_leg = list(/obj/item/parts/artifact_parts/leg/eldritch/right)

/datum/artifact_augmentation/artifact/artifact_martian
	left_arm = list(/obj/item/parts/artifact_parts/arm/martian/left)
	right_arm = list(/obj/item/parts/artifact_parts/arm/martian/right)
	left_leg = list(/obj/item/parts/artifact_parts/leg/martian/left)
	right_leg = list(/obj/item/parts/artifact_parts/leg/martian/right)

/datum/artifact_augmentation/artifact/artifact_precursor
	left_arm = list(/obj/item/parts/artifact_parts/arm/precursor/left)
	right_arm = list(/obj/item/parts/artifact_parts/arm/precursor/right)
	left_leg = list(/obj/item/parts/artifact_parts/leg/precursor/left)
	right_leg = list(/obj/item/parts/artifact_parts/leg/precursor/right)
