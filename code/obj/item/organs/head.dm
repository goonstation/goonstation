/*==========================*/
/*---------- Head ----------*/
/*==========================*/

/obj/item/organ/head // vOv
	name = "head"
	organ_name = "head"
	desc = "Well, shit."
	organ_holder_name = "head"
	organ_holder_location = "head"
	organ_holder_required_op_stage = 0.0
	var/scalp_op_stage = 0.0 // Needed to track a scalp gash (brain and skull removal) separately from op_stage (head removal)
	icon = 'icons/mob/human_head.dmi'
	icon_state = "invis" // we'll overlay some shit on here
	edible = 0
	rand_pos = 0 // we wanna override it below
	made_from = "bone"
	tooltip_flags = REBUILD_ALWAYS //TODO: handle better??
	MAX_DAMAGE = INFINITY

	var/obj/item/organ/brain/brain = null
	var/obj/item/skull/skull = null
	var/obj/item/organ/eye/left_eye = null
	var/obj/item/organ/eye/right_eye = null

	var/datum/appearanceHolder/donor_appearance = null

	var/image/head_image = null
	var/head_icon = null
	var/head_state = null
	var/our_hair_icon = 'icons/mob/human_hair.dmi'

	var/image/head_image_eyes = null
	var/image/head_image_cust_one = null
	var/image/head_image_cust_two = null
	var/image/head_image_cust_three = null

	var/skintone = "#FFFFFF"

	// equipped items - they use the same slot names because eh.
	var/obj/item/clothing/head/head = null
	var/obj/item/clothing/ears/ears = null
	var/obj/item/clothing/mask/wear_mask = null
	var/obj/item/clothing/glasses/glasses = null

	New()
		..()
		SPAWN_DBG(0)
			if (src.donor)
				if(!src.bones)
					src.bones = new /datum/bone(src)
				src.bones.donor = src.donor
				src.bones.parent_organ = src.organ_name
				src.bones.name = "skull"
				if (src.donor?.bioHolder?.mobAppearance)
					src.donor_appearance = src.donor.bioHolder.mobAppearance
					src.update_icon(makeshitup = 0, initialize_head = 1)
				else //The heck?
					src.update_icon(makeshitup = 1, initialize_head = 1)
			else
				src.update_icon(makeshitup = 1, initialize_head = 1)
			src.pixel_y = rand(-20,-8)
			src.pixel_x = rand(-8,8)

	disposing()
		if (holder)
			holder.head = null
		skull = null
		brain = null
		left_eye = null
		right_eye = null

		head = null
		ears = null
		wear_mask = null
		glasses = null

		..()

	get_desc()
		if (src.ears)
			. += "<br><span class='notice'>[src.name] has a [bicon(src.ears)] [src.ears.name] by its mouth.</span>"

		if (src.head)
			if (src.head.blood_DNA)
				. += "<br><span class='alert'>[src.name] has a[src.head.blood_DNA ? " bloody " : " "][bicon(src.head)] [src.head.name] on it!</span>"
			else
				. += "<br><span class='notice'>[src.name] has a [bicon(src.head)] [src.head.name] on it.</span>"

		if (src.wear_mask)
			if (src.wear_mask.blood_DNA)
				. += "<br><span class='alert'>[src.name] has a[src.wear_mask.blood_DNA ? " bloody " : " "][bicon(src.wear_mask)] [src.wear_mask.name] on its face!</span>"
			else
				. += "<br><span class='notice'>[src.name] has a [bicon(src.wear_mask)] [src.wear_mask.name] on its face.</span>"

		if (src.glasses)
			if (((src.wear_mask && src.wear_mask.see_face) || !src.wear_mask) && ((src.head && src.head.see_face) || !src.head))
				if (src.glasses.blood_DNA)
					. += "<br><span class='alert'>[src.name] has a[src.glasses.blood_DNA ? " bloody " : " "][bicon(src.wear_mask)] [src.glasses.name] on its face!</span>"
				else
					. += "<br><span class='notice'>[src.name] has a [bicon(src.glasses)] [src.glasses.name] on its face.</span>"

		if (!src.skull  && src.scalp_op_stage >= 3)
			. += "<br><span class='alert'><B>[src.name] no longer has a skull in it, its face is just empty skin mush!</B></span>"

		if (!src.skull && src.scalp_op_stage >= 5)
			. += "<br><span class='alert'><B>[src.name] has been cut open and its skull is gone!</B></span>"
		else if (!src.brain && src.scalp_op_stage >= 4)
			. += "<br><span class='alert'><B>[src.name] has been cut open and its brain is gone!</B></span>"
		else if (src.scalp_op_stage >= 3)
			. += "<br><span class='alert'><B>[src.name]'s head has been cut open!</B></span>"
		else if (src.scalp_op_stage > 0)
			. += "<br><span class='alert'><B>[src.name] has an open incision on it!</B></span>"

		if (!src.right_eye)
			. += "<br><span class='alert'><B>[src.name]'s right eye is missing!</B></span>"
		if (!src.left_eye)
			. += "<br><span class='alert'><B>[src.name]'s left eye is missing!</B></span>"

	/// This proc does a full rebuild of the head's stored data
	/// only call it if something changes the head in a major way, like becoming a lizard
	/// it will cause the head to be rebuilt from the mob's appearanceholder!
	proc/update_icon(var/makeshitup, var/datum/appearanceHolder/AH_in, var/initialize_head) // should only happen once, maybe again if they change mutant race
		var/datum/appearanceHolder/AHead = null

		if(AH_in && istype(AH_in, /datum/appearanceHolder))
			AHead = AH_in
		else if(!src.donor_appearance || makeshitup || !src.donor)
			AHead = new/datum/appearanceHolder()
			randomize_look(AHead, 0, 0, 0, 0, 0, 0)
			src.donor_appearance = AHead
		else
			// we're getting just about everything from here:
			AHead = src.donor_appearance

		// setup skintone and mess with it as per appearance and color flags
		if (AHead.mob_color_flags & HEAD_HAS_OWN_COLORS)
			src.skintone = "#FFFFFF"
		else if (AHead.mob_appearance_flags & HAS_HUMAN_SKINTONE)
			src.skintone = AHead.s_tone
		else if (AHead.mob_appearance_flags & HAS_SPECIAL_SKINTONE)
			if (AHead.mob_color_flags & SKINTONE_USES_PREF_COLOR_1)
				src.skintone = AHead.customization_first_color
			else if (AHead.mob_color_flags & SKINTONE_USES_PREF_COLOR_2)
				src.skintone = AHead.customization_second_color
			else if (AHead.mob_color_flags & SKINTONE_USES_PREF_COLOR_3)
				src.skintone = AHead.customization_third_color
		else // in case you didn't set your flags, which you really should
			src.skintone = "#FFFFFF"

		/// Set the head icon on initialize, so any later updates don't change the head's intended shape
		if(initialize_head)
			src.head_icon = AHead.head_icon
			src.head_state = AHead.head_icon_state
		src.head_image = image(src.head_icon,src.head_state, MOB_LIMB_LAYER)
		src.head_image.color = src.skintone

		// The rest of this shit gets sent to update_face
		//get and install eyes, if any.
		if (AHead.mob_appearance_flags & HAS_HUMAN_EYES)
			src.head_image_eyes = image(AHead.e_icon, AHead.e_state, pixel_y = AHead.e_offset_y, layer = MOB_FACE_LAYER)
		else if (AHead.mob_appearance_flags & HAS_NO_EYES)
			src.head_image_eyes = image('icons/mob/human_hair.dmi', "none", layer = MOB_FACE_LAYER)
		src.head_image_eyes.color = AHead.e_color

		// Set up the hair icon
		if (!(AHead.mob_appearance_flags & HAS_NO_HAIR)) // if not have no hair
			if (AHead.mob_appearance_flags & HAS_HUMAN_HAIR) // which is to say they have hair
				our_hair_icon = AHead.customization_icon
			else if (AHead.mob_appearance_flags & HAS_SPECIAL_HAIR) // or special hair
				our_hair_icon = AHead.customization_icon_special
			else if (AHead.mob_appearance_flags & HAS_BODYDETAIL_HAIR) // or hair that isnt really hair but applied the same way
				our_hair_icon = AHead.head_icon
			src.head_image_cust_one = image(icon = our_hair_icon, pixel_y = AHead.customization_first_offset_y, layer = MOB_HAIR_LAYER2)
			src.head_image_cust_two = image(icon = our_hair_icon, pixel_y = AHead.customization_second_offset_y, layer = MOB_HAIR_LAYER2)
			src.head_image_cust_three = image(icon = our_hair_icon, pixel_y = AHead.customization_third_offset_y, layer = MOB_HAIR_LAYER2)

			// Set up the hair state
			var/list/hair_list = customization_styles + customization_styles_gimmick
			if (AHead.mob_appearance_flags & HAS_HUMAN_HAIR)
				src.head_image_cust_one.icon_state = hair_list[AHead.customization_first]
				src.head_image_cust_two.icon_state = hair_list[AHead.customization_second]
				src.head_image_cust_three.icon_state = hair_list[AHead.customization_third]
				src.head_image_cust_one.color = AHead.customization_first_color
				src.head_image_cust_two.color = AHead.customization_second_color
				src.head_image_cust_three.color = AHead.customization_third_color
			else
				if (AHead.mob_appearance_flags & HAS_SPECIAL_HAIR)
					src.head_image_cust_one.icon_state = hair_list[AHead.customization_first]
					src.head_image_cust_two.icon_state = hair_list[AHead.customization_second]
					src.head_image_cust_three.icon_state = hair_list[AHead.customization_third]
				else if (AHead.mob_appearance_flags & HAS_BODYDETAIL_HAIR) // no list to pick from, defined by mutantraces
					src.head_image_cust_one.icon_state = AHead.customization_first
					src.head_image_cust_two.icon_state = AHead.customization_second
					src.head_image_cust_three.icon_state = AHead.customization_third

				src.head_image_cust_one.color = AHead.customization_first_color
				src.head_image_cust_two.color = AHead.customization_second_color
				src.head_image_cust_three.color = AHead.customization_third_color

		else // no hair
			src.head_image_cust_one = image('icons/mob/human_hair.dmi', "none", layer = MOB_HAIR_LAYER2)
			src.head_image_cust_two = image('icons/mob/human_hair.dmi', "none", layer = MOB_HAIR_LAYER2)
			src.head_image_cust_three = image('icons/mob/human_hair.dmi', "none", layer = MOB_HAIR_LAYER2)

		if (!src.donor) // maybe someone spawned us in? Construct the dropped thing
			update_head_image()
		else
			src.donor.update_face()
			src.donor.update_body()

	proc/update_head_image() // The thing that actually shows up when dropped
		src.overlays = null

		src.overlays += src.head_image
		src.overlays += src.head_image_eyes
		src.overlays += src.head_image_cust_one
		src.overlays += src.head_image_cust_two
		src.overlays += src.head_image_cust_three

		if (src.glasses && src.glasses.wear_image_icon)
			src.overlays += image(src.glasses.wear_image_icon, src.glasses.icon_state)

		if (src.wear_mask && src.wear_mask.wear_image_icon)
			src.overlays += image(src.wear_mask.wear_image_icon, src.wear_mask.icon_state)

		if (src.ears && src.ears.wear_image_icon)
			src.overlays += image(src.ears.wear_image_icon, src.ears.icon_state)

		if (src.head && src.head.wear_image_icon)
			src.overlays += image(src.head.wear_image_icon, src.head.icon_state)

	do_missing()
		..()

	attackby(obj/item/W as obj, mob/user as mob) // this is real ugly
		if (src.skull || src.brain)

			// scalpel surgery
			if (istype(W, /obj/item/scalpel) || istype(W, /obj/item/razor_blade) || istype(W, /obj/item/knife/butcher) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/raw_material/shard))
				if (src.right_eye && src.right_eye.op_stage == 1.0 && user.find_in_hand(W) == user.r_hand)
					playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
					user.visible_message("<span class='alert'><b>[user]</b> cuts away the flesh holding [src]'s right eye in with [W]!</span>",\
					"<span class='alert'>You cut away the flesh holding [src]'s right eye in with [W]!</span>")
					src.right_eye.op_stage = 2.0
				else if (src.left_eye && src.left_eye.op_stage == 1.0 && user.find_in_hand(W) == user.l_hand)
					playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
					user.visible_message("<span class='alert'><b>[user]</b> cuts away the flesh holding [src]'s left eye in with [W]!</span>",\
					"<span class='alert'>You cut away the flesh holding [src]'s left eye in with [W]!</span>")
					src.left_eye.op_stage = 2.0
				else if (src.brain)
					if (src.brain.op_stage == 0.0)
						playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
						user.visible_message("<span class='alert'><b>[user]</b> cuts [src] open with [W]!</span>",\
						"<span class='alert'>You cut [src] open with [W]!</span>")
						src.brain.op_stage = 1.0
					else if (src.brain.op_stage == 2.0)
						playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
						user.visible_message("<span class='alert'><b>[user]</b> removes the connections to [src]'s brain with [W]!</span>",\
						"<span class='alert'>You remove [src]'s connections to [src]'s brain with [W]!</span>")
						src.brain.op_stage = 3.0
					else
						return ..()
				else if (src.skull && src.skull.op_stage == 0.0)
					playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
					user.visible_message("<span class='alert'><b>[user]</b> cuts [src]'s skull away from the skin with [W]!</span>",\
					"<span class='alert'>You cut [src]'s skull away from the skin with [W]!</span>")
					src.skull.op_stage = 1.0
				else
					return ..()

			// saw surgery
			else if (istype(W, /obj/item/circular_saw) || istype(W, /obj/item/saw) || istype(W, /obj/item/kitchen/utensil/fork))
				if (src.brain)
					if (src.brain.op_stage == 1.0)
						playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
						user.visible_message("<span class='alert'><b>[user]</b> saws open [src]'s skull with [W]!</span>",\
						"<span class='alert'>You saw open [src]'s skull with [W]!</span>")
						src.brain.op_stage = 2.0
					else if (src.brain.op_stage == 3.0)
						playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
						user.visible_message("<span class='alert'><b>[user]</b> saws open [src]'s skull with [W]!</span>",\
						"<span class='alert'>You saw open [src]'s skull with [W]!</span>")
						src.brain.set_loc(get_turf(src))
						src.brain = null
					else
						return ..()
				else if (src.skull && src.skull.op_stage == 1.0)
					playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
					user.visible_message("<span class='alert'><b>[user]</b> saws [src]'s skull out with [W]!</span>",\
					"<span class='alert'>You saw [src]'s skull out with [W]!</span>")
					src.skull.set_loc(get_turf(src))
					src.skull = null
				else
					return ..()

			// spoon surgery
			else if (istype(W, /obj/item/surgical_spoon) || istype(W, /obj/item/kitchen/utensil/spoon))
				if (src.right_eye && src.right_eye.op_stage == 0.0 && user.find_in_hand(W) == user.r_hand)
					playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
					user.visible_message("<span class='alert'><b>[user]</b> inserts [W] into [src]'s right eye socket!</span>",\
					"<span class='alert'>You insert [W] into [src]'s right eye socket!</span>")
					src.right_eye.op_stage = 1.0
				else if (src.left_eye && src.left_eye.op_stage == 0.0 && user.find_in_hand(W) == user.l_hand)
					playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
					user.visible_message("<span class='alert'><b>[user]</b> inserts [W] into [src]'s left eye socket!</span>",\
					"<span class='alert'>You insert [W] into [src]'s left eye socket!</span>")
					src.left_eye.op_stage = 1.0
				else if (src.right_eye && src.right_eye.op_stage == 2.0 && user.find_in_hand(W) == user.r_hand)
					playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
					user.visible_message("<span class='alert'><b>[user]</b> removes [src]'s right eye with [W]!</span>",\
					"<span class='alert'>You remove [src]'s right eye with [W]!</span>")
					src.right_eye.set_loc(get_turf(src))
					src.right_eye = null
				else if (src.left_eye && src.left_eye.op_stage == 2.0 && user.find_in_hand(W) == user.l_hand)
					playsound(get_turf(src), "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)
					user.visible_message("<span class='alert'><b>[user]</b> removes [src]'s left eye with [W]!</span>",\
					"<span class='alert'>You remove [src]'s left eye with [W]!</span>")
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
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		var/fluff = pick("attach", "shove", "place", "drop", "smoosh", "squish")
		if (!H.get_organ("head"))

			H.tri_message("<span class='alert'><b>[user]</b> [fluff][(fluff == "smoosh" || fluff == "squish" || fluff == "attach") ? "es" : "s"] [src] onto [H == user ? "[his_or_her(H)]" : "[H]'s"] neck stump!</span>",\
			user, "<span class='alert'>You [fluff] [src] onto [user == H ? "your" : "[H]'s"] neck stump!</span>",\
			H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][(fluff == "smoosh" || fluff == "squish" || fluff == "attach") ? "es" : "s"] [src] onto your neck stump!</span>")

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "head", 3.0)

			SPAWN_DBG(rand(50,500))
				if (H?.organHolder?.head && H.organHolder.head == src) // aaaaaa
					if (src.op_stage != 0.0)
						H.visible_message("<span class='alert'><b>[H]'s head comes loose and tumbles off of [his_or_her(H)] neck!</b></span>",\
						"<span class='alert'><b>Your head comes loose and tumbles off of your neck!</b></span>")
						H.organHolder.drop_organ("head") // :I

			return 1
		else
			return 0

	proc/MakeMutantHead(var/mutant_race as num)

		// rebuild, start with a human head
		src.name = "head"
		src.desc = "Well, shit."
		src.organ_holder_required_op_stage = 0.0
		src.scalp_op_stage = 0.0

		switch(mutant_race)	// then overwrite everything that's supposed to be different
			if(HEAD_HUMAN)
				src.name = "[src.donor_name]'s head"

			if(HEAD_MONKEY)
				src.name = "[src.donor_name]'s monkey head"
				src.desc = "The last thing a geneticist sees before they die."

			if(HEAD_LIZARD)
				src.name = "[src.donor_name]'s lizard head"
				src.desc = "Well, sssshit."

			if(HEAD_COW)
				src.name = "[src.donor_name]'s cow head"
				src.desc = "They're not dead, they're just a really good roleplayer."

			if(HEAD_WEREWOLF)
				src.name = "[src.donor_name]'s wolf head"
				src.desc = "Definitely not a good boy."
				src.MAX_DAMAGE = 250	// Robust head for a robust antag
				src.FAIL_DAMAGE = 240

			if(HEAD_SKELETON)
				src.name = "[src.donor_name]'s bony head"
				src.desc = "...does that skull have another skull inside it?"

			if(HEAD_SEAMONKEY)
				src.name = "[src.donor_name]'s seamonkey head"
				src.desc = "The last thing an assistant sees when they fall into the trench. Aside from all the robots."

			if(HEAD_CAT)
				src.name = "[src.donor_name]'s cat head"
				src.desc = "Me-youch."

			if(HEAD_ROACH)
				src.name = "[src.donor_name]'s roach head"
				src.desc = "Not the biggest bug you'll seen today, nor the last."
				src.made_from = "chitin"

			if(HEAD_FROG)
				src.name = "[src.donor_name]'s frog head"
				src.desc = "Croak."

			if(HEAD_SHELTER)
				src.name = "[src.donor_name]'s shelterfrog head"
				src.desc = "CroOoOoOooak."

			if(HEAD_VAMPZOMBIE)
				src.name = "[src.donor_name]'s zombie head"
				src.desc = "Deader than undead."

			if(HEAD_RELI)
				src.name = "[src.donor_name]'s synthetic head"
				src.desc = "Half stone, half tofu, all unfinished."

			if(HEAD_CHICKEN)
				src.name = "[src.donor_name]'s chicken head"
				src.desc = "Mike would be proud."

		src.update_icon(makeshitup = 0, initialize_head = 1)	// so our head actually looks like the thing its supposed to be
