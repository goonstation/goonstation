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
	icon_state = "head"
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
	var/datum/mutantrace/donor_mutantrace = null

	var/icon/head_icon = null

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
				if (src.donor.bioHolder && src.donor.bioHolder.mobAppearance)
					src.donor_appearance = src.donor.bioHolder.mobAppearance

				else //The heck?
					src.donor_appearance = new(src)

				if (src.donor.mutantrace)
					src.donor_mutantrace = src.donor.mutantrace
				src.update_icon()
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

	proc/update_icon()
		if (!src.donor || !src.donor_appearance)
			return // vOv

		if (src.donor_mutantrace)
			src.head_icon = new /icon(src.icon, src.donor_mutantrace.icon_state)
		else
			src.head_icon = new /icon(src.icon, src.icon_state)

		if (!src.donor_mutantrace || !src.donor_mutantrace.override_skintone)
			if (src.donor_appearance.s_tone)
				src.head_icon.Blend(src.donor_appearance.s_tone, ICON_MULTIPLY)

		if (!src.donor_mutantrace || !src.donor_mutantrace.override_eyes)
			var/icon/e_icon = new /icon('icons/mob/human_hair.dmi', "eyes")
			var/ecol = src.donor_appearance.e_color
			if (!ecol || length(ecol) > 7)
				ecol = "#000000"
			e_icon.Blend(ecol, ICON_MULTIPLY)
			src.head_icon.Blend(e_icon, ICON_OVERLAY)

		if (!src.donor_mutantrace || !src.donor_mutantrace.override_hair)
			var/icon/h_icon = new /icon('icons/mob/human_hair.dmi', "[customization_styles[src.donor_appearance.customization_first]]")
			var/hcol = src.donor_appearance.customization_first_color
			if (!hcol || length(hcol) > 7)
				hcol = "#000000"
			h_icon.Blend(hcol, ICON_MULTIPLY)
			src.head_icon.Blend(h_icon, ICON_OVERLAY)

		if (!src.donor_mutantrace || !src.donor_mutantrace.override_beard)
			var/icon/f_icon = new /icon('icons/mob/human_hair.dmi', "[customization_styles[src.donor_appearance.customization_second]]")
			var/fcol = src.donor_appearance.customization_second_color
			if (!fcol || length(fcol) > 7)
				fcol = "#000000"
			f_icon.Blend(fcol, ICON_MULTIPLY)
			src.head_icon.Blend(f_icon, ICON_OVERLAY)

		if (!src.donor_mutantrace || !src.donor_mutantrace.override_detail)
			var/icon/d_icon = new /icon('icons/mob/human_hair.dmi', "[customization_styles[src.donor_appearance.customization_third]]")
			var/dcol = src.donor_appearance.customization_third_color
			if (!dcol || length(dcol) > 7)
				dcol = "#000000"
			d_icon.Blend(dcol, ICON_MULTIPLY)
			src.head_icon.Blend(d_icon, ICON_OVERLAY)

		src.icon = src.head_icon

	proc/update_headgear_image()
		src.overlays = null

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
				if (H && H.organHolder && H.organHolder.head && H.organHolder.head == src) // aaaaaa
					if (src.op_stage != 0.0)
						H.visible_message("<span class='alert'><b>[H]'s head comes loose and tumbles off of [his_or_her(H)] neck!</b></span>",\
						"<span class='alert'><b>Your head comes loose and tumbles off of your neck!</b></span>")
						H.organHolder.drop_organ("head") // :I

			return 1
		else
			return 0
