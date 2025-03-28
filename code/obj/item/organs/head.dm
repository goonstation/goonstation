/*==========================*/
/*---------- Head ----------*/
/*==========================*/

/obj/item/organ/head // vOv
	name = "head"
	organ_name = "head"
	desc = "Well, shit."
	organ_holder_name = "head"
	organ_holder_location = "head"
	var/scalp_op_stage = 0.0 // Needed to track a scalp gash (brain and skull removal) separately from op_stage (head removal)
	icon = 'icons/mob/human_head.dmi'
	icon_state = "invis" // we'll overlay some shit on here
	inhand_image_icon = 'icons/mob/inhand/hand_skulls.dmi'
	item_state = ""
	edible = 0
	rand_pos = 0 // we wanna override it below
	default_material = "bone"
	tooltip_flags = REBUILD_ALWAYS //TODO: handle better??
	max_damage = INFINITY
	throw_speed = 1
	var/default_hat_y = 0
	var/default_hat_x = 0

	var/obj/item/organ/brain/brain = null
	var/obj/item/skull/skull = null
	var/obj/item/organ/eye/left_eye = null
	var/obj/item/organ/eye/right_eye = null

	var/datum/appearanceHolder/donor_appearance = null
	/// Holds the head appearance flags. So a transplanted head doesn't get overwritten
	var/head_appearance_flags
	/// Defines what kind of head this is, for things like lizards being able to colorchange a transplanted lizardhead
	/// Since we can't easily swap out one head for a different type
	var/head_type = HEAD_HUMAN
	var/mob/living/carbon/human/linked_human = null

	var/image/head_image = null
	var/head_icon = null
	var/head_state = null

	var/image/head_image_eyes_L = null
	var/image/head_image_eyes_R = null
	var/image/head_image_nose = null
	var/image/head_image_cust_one = null
	var/image/head_image_cust_two = null
	var/image/head_image_cust_three = null

	var/image/head_image_special_one = null
	var/image/head_image_special_two = null
	var/image/head_image_special_three = null

	var/skintone = "#FFFFFF"

	// equipped items - they use the same slot names because eh.
	var/obj/item/clothing/head/head = null
	var/obj/item/ears = null //can be either obj/item/clothing/ears/ or obj/item/device/radio/headset, but those paths diverge a lot
	var/obj/item/clothing/mask/wear_mask = null
	var/obj/item/clothing/glasses/glasses = null

	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE

	New()
		..()
		if (src.donor)
			if(!src.bones)
				src.bones = new /datum/bone(src)
			src.bones.donor = src.donor
			src.bones.parent_organ = src.organ_name
			src.bones.name = "skull"
			if (src.donor?.bioHolder?.mobAppearance)
				src.donor_appearance = src.donor.bioHolder.mobAppearance
				src.UpdateIcon(/*makeshitup*/ 0)
			else //The heck?
				src.UpdateIcon(/*makeshitup*/ 1)
			if (src.donor.eye != null)
				src.donor.set_eye(null)
		else
			src.UpdateIcon(/*makeshitup*/ 1)
		if (!src.chat_text)
			src.chat_text = new(null, src)

	throw_at(atom/target, range, speed, list/params, turf/thrown_from, mob/thrown_by, throw_type = 1,
			allow_anchored = UNANCHORED, bonus_throwforce = 0, end_throw_callback = null)
		throw_unlimited = TRUE
		..()

	disposing()
		if (src.linked_human)
			if (isskeleton(src.linked_human))
				var/datum/mutantrace/skeleton/S = src.linked_human.mutantrace
				S.head_tracker = null
			src.UnregisterSignal(src.linked_human, COMSIG_CREATE_TYPING)
			src.UnregisterSignal(src.linked_human, COMSIG_REMOVE_TYPING)
			src.UnregisterSignal(src.linked_human, COMSIG_SPEECH_BUBBLE)
		if (holder)
			holder.head = null
		if (donor_original?.eye == src)
			donor_original.set_eye(null)
			boutput(donor_original, SPAN_ALERT("<b>You feel your vision forcibly punted back to your body!</b>"))
		skull = null
		brain = null
		left_eye = null
		right_eye = null

		head = null
		ears = null
		wear_mask = null
		glasses = null
		linked_human = null
		chat_text = null

		..()

	get_desc()
		if (src.ears)
			. += "<br>[SPAN_NOTICE("[src.name] has a [bicon(src.ears)] [src.ears.name] by its mouth.")]"

		if (src.head)
			if (src.head.blood_DNA)
				. += "<br>[SPAN_ALERT("[src.name] has a[src.head.blood_DNA ? " bloody " : " "][bicon(src.head)] [src.head.name] on it!")]"
			else
				. += "<br>[SPAN_NOTICE("[src.name] has a [bicon(src.head)] [src.head.name] on it.")]"

		if (src.wear_mask)
			if (src.wear_mask.blood_DNA)
				. += "<br>[SPAN_ALERT("[src.name] has a[src.wear_mask.blood_DNA ? " bloody " : " "][bicon(src.wear_mask)] [src.wear_mask.name] on its face!")]"
			else
				. += "<br>[SPAN_NOTICE("[src.name] has a [bicon(src.wear_mask)] [src.wear_mask.name] on its face.")]"

		if (src.glasses)
			if (((src.wear_mask && src.wear_mask.see_face) || !src.wear_mask) && ((src.head && src.head.see_face) || !src.head))
				if (src.glasses.blood_DNA)
					. += "<br>[SPAN_ALERT("[src.name] has a[src.glasses.blood_DNA ? " bloody " : " "][bicon(src.wear_mask)] [src.glasses.name] on its face!")]"
				else
					. += "<br>[SPAN_NOTICE("[src.name] has a [bicon(src.glasses)] [src.glasses.name] on its face.")]"

		if (!src.skull  && src.scalp_op_stage >= 3)
			. += "<br>[SPAN_ALERT("<B>[src.name] no longer has a skull in it, its face is just empty skin mush!</B>")]"

		if (!src.skull && src.scalp_op_stage >= 5)
			. += "<br>[SPAN_ALERT("<B>[src.name] has been cut open and its skull is gone!</B>")]"
		else if (!src.brain && src.scalp_op_stage >= 4)
			. += "<br>[SPAN_ALERT("<B>[src.name] has been cut open and its brain is gone!</B>")]"
		else if (src.scalp_op_stage >= 3)
			. += "<br>[SPAN_ALERT("<B>[src.name]'s head has been cut open!</B>")]"
		else if (src.scalp_op_stage > 0)
			. += "<br>[SPAN_ALERT("<B>[src.name] has an open incision on it!</B>")]"

		if (!src.right_eye)
			. += "<br>[SPAN_ALERT("<B>[src.name]'s right eye is missing!</B>")]"
		if (!src.left_eye)
			. += "<br>[SPAN_ALERT("<B>[src.name]'s left eye is missing!</B>")]"

		if (isalive(src.donor_original))
			. += "<br>[SPAN_NOTICE("<B>[src.name] appears conscious!</B>")]"

	/// This proc does a full rebuild of the head's stored data
	/// only call it if something changes the head in a major way, like becoming a lizard
	/// it will cause the head to be rebuilt from the mob's appearanceholder!
	update_icon(var/makeshitup, var/ignore_transplant) // should only happen once, maybe again if they change mutant race
		var/datum/appearanceHolder/AHead = null

		if(!src.donor_appearance || makeshitup || !src.donor)
			AHead = new/datum/appearanceHolder()
			randomize_look(AHead, 0, 0, 0, 0, 0, 0, src.donor)
			src.donor_appearance = AHead
			src.transplanted = FALSE // just in case
		else
			// we're getting just about everything from here:
			AHead = src.donor_appearance

		/// Load the mostly unchanging vars into the head isnt transplanted. Cept changers, they get to change it anyway
		/// note: may make yee expose changelings who've had head transplants. ok.
		/// Also lizards can colorchange lizard heads, even if they arent theirs
		if(ignore_transplant || !transplanted || ischangeling(src.donor))
			src.head_icon = AHead.head_icon
			src.head_state = AHead.head_icon_state
			src.head_appearance_flags = AHead.mob_appearance_flags
			src.head_image = image(src.head_icon,src.head_state, MOB_LIMB_LAYER)
			// setup skintone and mess with it as per appearance flags
			if (src.head_appearance_flags & HEAD_HAS_OWN_COLORS)
				src.skintone = "#FFFFFF"
			else
				src.skintone = AHead.s_tone
			src.head_image.color = src.skintone
			if(src.donor_name)
				src.name = "[src.donor_name]'s [src.organ_name]"
			else
				src.name = src.organ_name

		// The rest of this shit gets sent to update_face
		// get and install eyes, if any.
		if (src.head_appearance_flags & HAS_HUMAN_EYES)
			src.head_image_eyes_L = image(AHead.e_icon, "[AHead.e_state]_L", layer = MOB_FACE_LAYER)
			src.head_image_eyes_R = image(AHead.e_icon, "[AHead.e_state]_R", layer = MOB_FACE_LAYER)
		else if (src.head_appearance_flags & HAS_NO_EYES)
			src.head_image_eyes_L = image('icons/mob/human_hair.dmi', "none", layer = MOB_FACE_LAYER)
			src.head_image_eyes_R = image('icons/mob/human_hair.dmi', "none", layer = MOB_FACE_LAYER)

		if (AHead.customizations["hair_bottom"].style.id == "hetcroL")
			src.head_image_eyes_L.color = AHead.customizations["hair_bottom"].color
		else if (AHead.customizations["hair_middle"].style.id == "hetcroL")
			src.head_image_eyes_L.color = AHead.customizations["hair_middle"].color
		else if (AHead.customizations["hair_top"].style.id == "hetcroL")
			src.head_image_eyes_L.color = AHead.customizations["hair_top"].color
		else
			src.head_image_eyes_L.color = AHead.e_color

		if (AHead.customizations["hair_bottom"].style.id == "hetcroR")
			src.head_image_eyes_R.color = AHead.customizations["hair_bottom"].color
		else if (AHead.customizations["hair_middle"].style.id == "hetcroR")
			src.head_image_eyes_R.color = AHead.customizations["hair_middle"].color
		else if (AHead.customizations["hair_top"].style.id == "hetcroR")
			src.head_image_eyes_R.color = AHead.customizations["hair_top"].color
		else
			src.head_image_eyes_R.color = AHead.e_color

		// Add long nose if they have one
		if (src.head_appearance_flags & HAS_LONG_NOSE)
			src.head_image_nose = image(src.head_icon, "snout", layer = MOB_GLASSES_LAYER)
			src.head_image_nose.color = src.skintone
		else
			src.head_image_nose = null

		// Remove their hair first
		src.head_image_cust_one = image('icons/mob/human_hair.dmi', "none", layer = MOB_HAIR_LAYER2)
		src.head_image_cust_two = image('icons/mob/human_hair.dmi', "none", layer = MOB_HAIR_LAYER2)
		src.head_image_cust_three = image('icons/mob/human_hair.dmi', "none", layer = MOB_HAIR_LAYER2)
		src.head_image_special_one = image('icons/mob/human_hair.dmi', "none", layer = MOB_HAIR_LAYER2)
		src.head_image_special_two = image('icons/mob/human_hair.dmi', "none", layer = MOB_HAIR_LAYER2)
		src.head_image_special_three = image('icons/mob/human_hair.dmi', "none", layer = MOB_HAIR_LAYER2)

		// Then apply whatever hair things they should have
		src.head_image_cust_one = image(icon = AHead.customizations["hair_bottom"].style.icon, icon_state = AHead.customizations["hair_bottom"].style.id, layer = AHead.customizations["hair_bottom"].style.default_layer)
		src.head_image_cust_two = image(icon = AHead.customizations["hair_middle"].style.icon, icon_state = AHead.customizations["hair_middle"].style.id, layer = AHead.customizations["hair_middle"].style.default_layer)
		src.head_image_cust_three = image(icon = AHead.customizations["hair_top"].style.icon, icon_state = AHead.customizations["hair_top"].style.id, layer = AHead.customizations["hair_top"].style.default_layer)

		src.head_image_cust_one.color = AHead.customizations["hair_bottom"].color
		src.head_image_cust_two.color = AHead.customizations["hair_middle"].color
		src.head_image_cust_three.color = AHead.customizations["hair_top"].color

		src.head_image_special_one = image(icon = AHead.special_hair_1_icon, icon_state = AHead.special_hair_1_state, layer = AHead.special_hair_1_layer)
		src.head_image_special_two = image(icon = AHead.special_hair_2_icon, icon_state = AHead.special_hair_2_state, layer = AHead.special_hair_2_layer)
		src.head_image_special_three = image(icon = AHead.special_hair_3_icon, icon_state = AHead.special_hair_3_state, layer = AHead.special_hair_3_layer)

		var/colorheck = "#FFFFFF"
		switch(AHead.special_hair_1_color_ref)
			if(CUST_1)
				colorheck = AHead.customizations["hair_bottom"].color
			if(CUST_2)
				colorheck = AHead.customizations["hair_middle"].color
			if(CUST_3)
				colorheck = AHead.customizations["hair_top"].color
			else
				colorheck = "#FFFFFF"
		src.head_image_special_one.color = colorheck
		switch(AHead.special_hair_2_color_ref)
			if(CUST_1)
				colorheck = AHead.customizations["hair_bottom"].color
			if(CUST_2)
				colorheck = AHead.customizations["hair_middle"].color
			if(CUST_3)
				colorheck = AHead.customizations["hair_top"].color
			else
				colorheck = "#FFFFFF"
		src.head_image_special_two.color = colorheck
		switch(AHead.special_hair_3_color_ref)
			if(CUST_1)
				colorheck = AHead.customizations["hair_bottom"].color
			if(CUST_2)
				colorheck = AHead.customizations["hair_middle"].color
			if(CUST_3)
				colorheck = AHead.customizations["hair_top"].color
			else
				colorheck = "#FFFFFF"
		src.head_image_special_three.color = colorheck

		if (!src.donor) // maybe someone spawned us in? Construct the dropped thing
			update_head_image()
		else
			src.donor.update_face()
			src.donor.update_body()

	proc/update_head_image() // The thing that actually shows up when dropped
		var/mutable_appearance/actual_head = new

		src.head_image.pixel_x = 0
		src.head_image.pixel_y = 0
		actual_head.appearance = src.head_image
		actual_head.color = null
		actual_head.overlays += src.head_image
		src.head_image_eyes_L.pixel_x = 0
		src.head_image_eyes_L.pixel_y = 0
		if(src.left_eye)
			src.head_image_eyes_L.color = left_eye.iris_color
			actual_head.overlays += src.head_image_eyes_L
		src.head_image_eyes_R.pixel_x = 0
		src.head_image_eyes_R.pixel_y = 0
		if(src.right_eye)
			src.head_image_eyes_R.color = right_eye.iris_color
			actual_head.overlays += src.head_image_eyes_R

		if(src.head_image_nose)
			actual_head.overlays += src.head_image_nose

		if (src.glasses && src.glasses.wear_image_icon)
			actual_head.overlays += image(src.glasses.wear_image_icon, src.glasses.icon_state, layer = MOB_GLASSES_LAYER)

		if (src.wear_mask && src.wear_mask.wear_image_icon)
			actual_head.overlays += image(src.wear_mask.wear_image_icon, src.wear_mask.icon_state, layer = MOB_HEAD_LAYER2)

		if (src.ears && src.ears.wear_image_icon)
			actual_head.overlays += image(src.ears.wear_image_icon, src.ears.icon_state, layer = MOB_EARS_LAYER)

		if (src.head && src.head.wear_image)
			actual_head.overlays += src.head.wear_image

		else if (src.head && src.head.wear_image_icon)
			actual_head.overlays += image(src.head.wear_image_icon, src.head.icon_state, layer = MOB_HEAD_LAYER2)

		if(!(src.head && src.head.seal_hair))
			if(src.donor_appearance?.mob_appearance_flags & HAS_HUMAN_HAIR || src.donor?.hair_override)
				src.head_image_cust_one.pixel_x = 0
				src.head_image_cust_one.pixel_y = 0
				src.head_image_cust_two.pixel_x = 0
				src.head_image_cust_two.pixel_y = 0
				src.head_image_cust_three.pixel_x = 0
				src.head_image_cust_three.pixel_y = 0
				actual_head.overlays += src.head_image_cust_one
				actual_head.overlays += src.head_image_cust_two
				actual_head.overlays += src.head_image_cust_three
			if(src.donor_appearance?.mob_appearance_flags & HAS_SPECIAL_HAIR || src.donor?.special_hair_override)
				src.head_image_special_one.pixel_x = 0
				src.head_image_special_one.pixel_y = 0
				src.head_image_special_two.pixel_x = 0
				src.head_image_special_two.pixel_y = 0
				src.head_image_special_three.pixel_x = 0
				src.head_image_special_three.pixel_y = 0
				actual_head.overlays += src.head_image_special_one
				actual_head.overlays += src.head_image_special_two
				actual_head.overlays += src.head_image_special_three

		actual_head.appearance_flags |= KEEP_TOGETHER
		actual_head.pixel_y = -10
		src.UpdateOverlays(actual_head, "actual_head")

		src.pixel_y = rand(-8,8)
		src.pixel_x = rand(-8,8)

	on_transplant(mob/M)
		. = ..()
		// at this point in time, the head's "donor" is M, but the head's donor_appearance is the last person it was attached to's bioholder's mobappearance
		if(!src.donor?.bioHolder?.mobAppearance)
			return

		var/datum/appearanceHolder/currentHeadAppearanceOwner = src.donor_appearance

		// we will move the head's appearance onto its new owner's mobappearance and then update its appearance reference to that
		src.donor.bioHolder.mobAppearance.CopyOtherHeadAppearance(currentHeadAppearanceOwner)
		src.donor_appearance = src.donor.bioHolder.mobAppearance
	on_removal()
		src.transplanted = 1
		if (src.linked_human && (src.donor == src.linked_human))
		 	// if we're typing, attempt to seamlessly transfer it
			if (src.linked_human.has_typing_indicator && isskeleton(src.linked_human))
				src.linked_human.remove_typing_indicator()
				src.linked_human.has_typing_indicator = TRUE // proc above removes it
				src.create_typing_indicator()

			src.RegisterSignal(src.linked_human, COMSIG_CREATE_TYPING, PROC_REF(create_typing_indicator))
			src.RegisterSignal(src.linked_human, COMSIG_REMOVE_TYPING, PROC_REF(remove_typing_indicator))
			src.RegisterSignal(src.linked_human, COMSIG_SPEECH_BUBBLE, PROC_REF(speech_bubble))
		. = ..()

	///Taking items off a head
	attack_self(mob/user as mob)
		var/list/headwear = list(head, ears, wear_mask, glasses)
		var/obj/selection = input("Which item do you want to remove","Looting the dead") as null|obj in headwear
		if (!selection)
			return
		user.put_in_hand_or_drop(selection)
		if (selection == head)
			head = null
		if (selection == ears)
			ears = null
		if (selection == wear_mask)
			wear_mask = null
		if (selection == glasses)
			glasses = null
		update_head_image()


	attackby(obj/item/W, mob/user) // this is real ugly
		if (!user)
			return
		//Putting stuff on heads
		if (istype(W, /obj/item/clothing/head))
			if (!head)
				user.drop_item(W)
				head = W
				head.set_loc(src)
				update_head_image()
			else
				boutput(user, SPAN_ALERT("[src.name] is already wearing [src.head.name]!"))
			return
		if (istype(W, /obj/item/clothing/ears) || istype(W, /obj/item/device/radio/headset))
			if (!ears)
				user.drop_item(W)
				ears = W
				ears.set_loc(src)
				update_head_image()
			else
				boutput(user, SPAN_ALERT("[src.name] is already wearing [src.ears.name]!"))
			return
		if (istype(W, /obj/item/clothing/mask))
			if (!wear_mask)
				user.drop_item(W)
				wear_mask = W
				wear_mask.set_loc(src)
				update_head_image()
			else
				boutput(user, SPAN_ALERT("[src.name] is already wearing [src.wear_mask.name]!"))
			return
		if (istype(W, /obj/item/clothing/glasses))
			if (!glasses)
				user.drop_item(W)
				glasses = W
				glasses.set_loc(src)
				update_head_image()
			else
				boutput(user, SPAN_ALERT("[src.name] is already wearing [src.glasses.name]!"))
			return
		if (istype(W, /obj/item/cloth))
			playsound(src, 'sound/items/towel.ogg', 25, TRUE)
			user.visible_message(SPAN_NOTICE("[user] [pick("buffs", "shines", "cleans", "wipes", "polishes")] [src] with [W]."))
			src.clean_forensic()
			return
		if (istype(W, /obj/item/reagent_containers/food) && head_type == HEAD_SKELETON)
			user.visible_message(SPAN_NOTICE("[user] tries to feed [W] to [src] but it cannot swallow!"))
			return

		if (src.skull || src.brain)

			// scalpel surgery
			if (iscuttingtool(W))
				if (src.right_eye && src.right_eye.op_stage == 1.0 && user.find_in_hand(W) == user.r_hand)
					playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
					user.visible_message(SPAN_ALERT("<b>[user]</b> cuts away the flesh holding [src]'s right eye in with [W]!"),\
					SPAN_ALERT("You cut away the flesh holding [src]'s right eye in with [W]!"))
					src.right_eye.op_stage = 2
				else if (src.left_eye && src.left_eye.op_stage == 1.0 && user.find_in_hand(W) == user.l_hand)
					playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
					user.visible_message(SPAN_ALERT("<b>[user]</b> cuts away the flesh holding [src]'s left eye in with [W]!"),\
					SPAN_ALERT("You cut away the flesh holding [src]'s left eye in with [W]!"))
					src.left_eye.op_stage = 2
				else if (src.brain)
					if (src.brain.op_stage == 0.0)
						playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
						user.visible_message(SPAN_ALERT("<b>[user]</b> cuts [src] open with [W]!"),\
						SPAN_ALERT("You cut [src] open with [W]!"))
						src.brain.op_stage = 1
					else if (src.brain.op_stage == 2)
						playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
						user.visible_message(SPAN_ALERT("<b>[user]</b> removes the connections to [src]'s brain with [W]!"),\
						SPAN_ALERT("You remove [src]'s connections to [src]'s brain with [W]!"))
						src.brain.op_stage = 3
					else
						return ..()
				else if (src.skull && src.skull.op_stage == 0.0)
					playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
					user.visible_message(SPAN_ALERT("<b>[user]</b> cuts [src]'s skull away from the skin with [W]!"),\
					SPAN_ALERT("You cut [src]'s skull away from the skin with [W]!"))
					src.skull.op_stage = 1
				else
					return ..()

			// saw surgery
			else if (istype(W, /obj/item/circular_saw) || istype(W, /obj/item/saw) || istype(W, /obj/item/kitchen/utensil/fork))
				if (src.brain)
					if (src.brain.op_stage == 1.0)
						playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
						user.visible_message(SPAN_ALERT("<b>[user]</b> saws open [src]'s skull with [W]!"),\
						SPAN_ALERT("You saw open [src]'s skull with [W]!"))
						src.brain.op_stage = 2
					else if (src.brain.op_stage == 3.0)
						playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
						user.visible_message(SPAN_ALERT("<b>[user]</b> saws open [src]'s skull with [W]!"),\
						SPAN_ALERT("You saw open [src]'s skull with [W]!"))
						src.brain.set_loc(get_turf(src))
						src.brain = null
					else
						return ..()
				else if (src.skull && src.skull.op_stage == 1.0)
					playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
					user.visible_message(SPAN_ALERT("<b>[user]</b> saws [src]'s skull out with [W]!"),\
					SPAN_ALERT("You saw [src]'s skull out with [W]!"))
					src.skull.set_loc(get_turf(src))
					src.skull = null
				else
					return ..()

			// spoon surgery
			else if (isspooningtool(W))
				if (src.right_eye && src.right_eye.op_stage == 0.0 && user.find_in_hand(W) == user.r_hand)
					playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
					user.visible_message(SPAN_ALERT("<b>[user]</b> inserts [W] into [src]'s right eye socket!"),\
					SPAN_ALERT("You insert [W] into [src]'s right eye socket!"))
					src.right_eye.op_stage = 1
				else if (src.left_eye && src.left_eye.op_stage == 0.0 && user.find_in_hand(W) == user.l_hand)
					playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
					user.visible_message(SPAN_ALERT("<b>[user]</b> inserts [W] into [src]'s left eye socket!"),\
					SPAN_ALERT("You insert [W] into [src]'s left eye socket!"))
					src.left_eye.op_stage = 1
				else if (src.right_eye && src.right_eye.op_stage == 2 && user.find_in_hand(W) == user.r_hand)
					playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
					user.visible_message(SPAN_ALERT("<b>[user]</b> removes [src]'s right eye with [W]!"),\
					SPAN_ALERT("You remove [src]'s right eye with [W]!"))
					src.right_eye.set_loc(get_turf(src))
					src.right_eye = null
				else if (src.left_eye && src.left_eye.op_stage == 2 && user.find_in_hand(W) == user.l_hand)
					playsound(src, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
					user.visible_message(SPAN_ALERT("<b>[user]</b> removes [src]'s left eye with [W]!"),\
					SPAN_ALERT("You remove [src]'s left eye with [W]!"))
					src.left_eye.set_loc(get_turf(src))
					src.left_eye = null
				else
					return ..()

			else
				return ..()
		else
			return ..()

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Overrides parent function to handle special case for attaching heads. */

		if (src.linked_human && isskeleton(M))// return the typing indicator to the human only if we're put on a skeleton
			src.UnregisterSignal(src.linked_human, COMSIG_CREATE_TYPING)
			src.UnregisterSignal(src.linked_human, COMSIG_REMOVE_TYPING)
			src.UnregisterSignal(src.linked_human, COMSIG_SPEECH_BUBBLE)
		var/mob/living/carbon/human/H = M
		if (!isskeleton(M) && !src.can_attach_organ(H, user))
			return 0

		var/fluff = pick("attach", "shove", "place", "drop", "smoosh", "squish")
		if (!H.get_organ("head") && H.organHolder.receive_organ(src, "head", isskeleton(M) ? 0 : 3))

			user.tri_message(H, SPAN_ALERT("<b>[user]</b> [fluff][(fluff == "smoosh" || fluff == "squish" || fluff == "attach") ? "es" : "s"] [src] onto [H == user ? "[his_or_her(H)]" : "[H]'s"] neck stump!"),\
				SPAN_ALERT("You [fluff] [src] onto [user == H ? "your" : "[H]'s"] neck stump!"),\
				SPAN_ALERT("[H == user ? "You" : "<b>[user]</b>"] [fluff][(fluff == "smoosh" || fluff == "squish" || fluff == "attach") ? "es" : "s"] [src] onto your neck stump!"))
			playsound(H, 'sound/effects/attach.ogg', 50, TRUE)

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.update_equipment_screen_loc()

			SPAWN(rand(50,500))
				if (H?.organHolder?.head == src && src.op_stage != 0.0) // head has not been secured
					H.visible_message(SPAN_ALERT("<b>[H]'s head comes loose and tumbles off of [his_or_her(H)] neck!</b>"),\
					SPAN_ALERT("<b>Your head comes loose and tumbles off of your neck!</b>"))
					H.organHolder.drop_organ("head") // :I

			return 1
		else
			return 0

	proc/MakeMutantHead(var/mutant_race as num, var/headicon, var/headicon_state, var/skip_update = FALSE)
		if(!src.transplanted) /// no altering a reattached head

			// rebuild, start with a human head
			src.name = "head"
			src.desc = "Well, shit."
			src.scalp_op_stage = 0
			src.head_type = mutant_race

			// then set the head icon
			if(headicon)
				src.head_icon = headicon
			else
				src.head_icon = 'icons/mob/human_head.dmi'

			// Then the state
			if(headicon_state)
				src.head_state = headicon_state
			else
				src.head_state = "head"

			if(src.donor?.bioHolder.mobAppearance)
				src.donor.bioHolder.mobAppearance.head_icon = src.head_icon
				src.donor.bioHolder.mobAppearance.head_icon_state = src.head_state

			switch(mutant_race)	// then overwrite everything that's supposed to be different
				if(HEAD_HUMAN)
					src.organ_name = "head"

				if(HEAD_MONKEY)
					src.organ_name = "monkey head"
					src.desc = "The last thing a geneticist sees before they die."

				if(HEAD_LIZARD)
					src.organ_name = "lizard head"
					src.desc = "Well, sssshit."

				if(HEAD_COW)
					src.organ_name = "cow head"
					src.desc = "They're not dead, they're just a really good roleplayer."

				if(HEAD_PUG)
					src.organ_name = "pug head"
					src.desc = "Maybe a bit too smushed."

				if(HEAD_WEREWOLF)
					src.organ_name = "wolf head"
					src.desc = "Definitely not a good boy."
					src.max_damage = 250	// Robust head for a robust antag
					src.fail_damage = 240

				if(HEAD_SKELETON)
					src.organ_name = "bony head"
					src.desc = "...does that skull have another skull inside it?"
					src.item_state = "skull"

				if(HEAD_SEAMONKEY)
					src.organ_name = "seamonkey head"
					src.desc = "The last thing an assistant sees when they fall into the trench. Aside from all the robots."

				if(HEAD_CAT)
					src.organ_name = "cat head"
					src.desc = "Me-youch."

				if(HEAD_ROACH)
					src.organ_name = "roach head"
					src.desc = "Not the biggest bug you'll seen today, nor the last."
					src.setMaterial(getMaterial("chitin"))

				if(HEAD_FROG)
					src.organ_name = "frog head"
					src.desc = "Croak."

				if(HEAD_SHELTER)
					src.organ_name = "shelterfrog head"
					src.desc = "CroOoOoOooak."

				if(HEAD_VAMPTHRALL)
					src.organ_name = "vampiric thrall head"
					src.desc = "Deader than undead."

				if(HEAD_RELI)
					src.organ_name = "synthetic head"
					src.desc = "Half stone, half tofu, all unfinished."

				if(HEAD_CHICKEN)
					src.organ_name = "chicken head"
					src.desc = "Mike would be proud."

				if(HEAD_HUNTER)
					src.organ_name = "hunter head"
					src.desc = "Ironic, isn't it?"

				if(HEAD_ITHILLID)
					src.organ_name = "squid head"
					src.desc = "Blub, blub."

				if(HEAD_VIRTUAL)
					src.organ_name = "virtual head"
					src.desc = "W311, 5h17." // 1337 5p34k

				if(HEAD_FLASHY)
					src.organ_name = "psychedelic head"
					src.desc = "Well, that's trippy."
		if(!skip_update)
			src.UpdateIcon(/*makeshitup*/ 0)	// so our head actually looks like the thing its supposed to be
		// though if our head's a transplant, lets run it anyway, in case their hair changed or something
