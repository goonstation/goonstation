/obj/artifact/augmentor
	name = "artifact augmentor"
	associated_datum = /datum/artifact/augmentor

/datum/artifact/augmentor
	associated_object = /obj/artifact/augmentor
	rarity_class = 2
	validtypes = list("ancient","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,
	/datum/artifact_trigger/cold)
	activ_text = "opens up, revealing an array of strange tools!"
	deact_text = "closes itself up."
	react_xray = list(6,75,60,11,"SEGMENTED")
	var/datum/artifact_augmentation/augment = null
	var/augment_location = "limb"
	var/recharge_time = 600
	var/recharging = 0
	var/working = 0
	// this monster of a list is used for quick reference to a path
	var/global/list/work_sounds = list('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/effects/airbridge_dpl.ogg','sound/impact_sounds/Slimy_Splat_1.ogg','sound/impact_sounds/Flesh_Tear_2.ogg','sound/impact_sounds/Slimy_Hit_3.ogg')
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
		"butt" = "butt")

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
		// does this augment externally or internally?
		augment_location = pick("limb", "organ")
		if(prob(5))
			augment_location = "all"

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
			if(!part_loc)
				// you're already perfect, limbwise
				boutput(H, "<b>[O]</b> twitches slightly, then returns to a ready position.")
				return

			working = 1
			T.visible_message("<span class='alert'><b>[O]</b> suddenly lashes out at [H.name] with a flurry of sharp implements!</span>")
			H.changeStatus("paralysis", 40)
			playsound(H.loc, pick(work_sounds), 50, 1, -1)
			random_brute_damage(user, 10)
			sleep(1 SECOND)

			var/obj/item/part_type = augment.get_part_type(part_loc)
			var/obj/item/part = new part_type()
			var/remove_action = "removes"
			var/replace_action = "appends something else"
			if(part)
				if(istype(part, /obj/item/parts)) // LIMBS
					//var/obj/item/parts/limb = part
					H.limbs.replace_with(part_loc, part_type, null , 0)
					H.update_body()
					remove_action = pick("tears off", "yanks off", "chops off")
					replace_action = pick("attaches something else to the stump", "reattaches it where it once was")
					ArtifactLogs(user, null, O, "touched by [H.real_name]", "given limb [part] as [part_loc]", 0)
				else // ORGANS
					var/obj/item/organ = part
					H.receive_organ(organ, part_loc, 0, 1)
					H.update_body()
					remove_action = pick("rips out", "tears out", "swiftly removes")
					replace_action = pick("inserts something else where it was", "places something else inside", "shoves something else in their body")
					ArtifactLogs(user, null, O, "touched by [H.real_name]", "given organ [part] as [part_loc]", 0)

				T.visible_message("<span class='alert'><b>[O]</b> [remove_action] [H.name]'s [organ_names[part_loc]], pulls it inside and [replace_action]![pick("", "Holy fuck!", "It looks incredibly painful!")]</span>")

			playsound(H.loc, pick(work_sounds), 50, 1, -1)
			boutput(H, "<span class='alert'><b>[pick("IT HURTS!", "OH GOD!", "JESUS FUCK!")]</b></span>")
			H.emote("scream")
			random_brute_damage(user, 30)
			bleed(H, 5, 5)
			T.visible_message("<b>[O]</b> withdraws its instruments and slams shut.")
			working = 0
			recharging = 1
			SPAWN_DBG(recharge_time)
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

	var/list/part_list = list("l_arm", "r_arm", "l_leg", "r_leg", "left_eye", "right_eye", "heart", "butt")
	var/list/limbs = list("l_arm", "r_arm", "l_leg", "r_leg")
	var/list/organs = list("left_eye", "right_eye", "heart", "butt")

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

	proc/get_part_target(var/mob/living/carbon/human/H, var/part_category)
		if(!H) return
		var/list/available_parts = part_list.Copy()
		switch(part_category)
			if("limb")
				available_parts &= limbs
			if("organ")
				available_parts &= organs
			// else, do nothing (all inclusive!!)
		if(!H.organs)
			available_parts -= organs
		if(!H.limbs)
			available_parts -= limbs
		if(available_parts.len <= 0)
			return // something went horribly wrong, abort

		var/list/missing_parts = list()
		var/list/candidates_to_remove = list()
		for(var/part_loc in available_parts)
			var/obj/item/bodypart = null
			if(part_loc in limbs)
				bodypart = H.limbs.get_limb(part_loc)
			if(part_loc in organs)
				bodypart = H.get_organ(part_loc)
			if(!bodypart)
				missing_parts += part_loc
			else if(is_augmented_part(bodypart, part_loc))
				candidates_to_remove += part_loc
		if(missing_parts.len > 0)
			// we have body parts of the target missing, pick one of them
			return pick(missing_parts)
		available_parts -= candidates_to_remove
		if(available_parts.len > 0)
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

/datum/artifact_augmentation/borg
	left_arm = list(/obj/item/parts/robot_parts/arm/left/light, /obj/item/parts/robot_parts/arm/left)
	right_arm = list(/obj/item/parts/robot_parts/arm/right/light, /obj/item/parts/robot_parts/arm/right)
	left_leg = list(/obj/item/parts/robot_parts/leg/left, /obj/item/parts/robot_parts/leg/left/light, /obj/item/parts/robot_parts/leg/left/treads)
	right_leg = list(/obj/item/parts/robot_parts/leg/right, /obj/item/parts/robot_parts/leg/right/light, /obj/item/parts/robot_parts/leg/right/treads)
	eye = list(/obj/item/organ/eye/cyber,/obj/item/organ/eye/cyber/sunglass,/obj/item/organ/eye/cyber/sechud,/obj/item/organ/eye/cyber/thermal,/obj/item/organ/eye/cyber/meson,/obj/item/organ/eye/cyber/spectro,/obj/item/organ/eye/cyber/prodoc,/obj/item/organ/eye/cyber/ecto,/obj/item/organ/eye/cyber/camera,/obj/item/organ/eye/cyber/nightvision,/obj/item/organ/eye/cyber/laser)
	heart = list(/obj/item/organ/heart/cyber)
	butt = list(/obj/item/clothing/head/butt/cyberbutt)

/datum/artifact_augmentation/synth
	left_arm = list(/obj/item/parts/human_parts/arm/left/synth, /obj/item/parts/human_parts/arm/left/synth/bloom)
	right_arm = list(/obj/item/parts/human_parts/arm/right/synth, /obj/item/parts/human_parts/arm/right/synth/bloom)
	left_leg = list(/obj/item/parts/human_parts/leg/left/synth, /obj/item/parts/human_parts/leg/left/synth/bloom)
	right_leg = list(/obj/item/parts/human_parts/leg/right/synth, /obj/item/parts/human_parts/leg/right/synth/bloom)
	eye = list(/obj/item/organ/eye/synth)
	heart = list(/obj/item/organ/heart/synth)
	butt = list(/obj/item/clothing/head/butt/synth)
