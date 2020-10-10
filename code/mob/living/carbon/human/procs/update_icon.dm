#define wear_sanity_check(X) if (!X.wear_image) X.wear_image = image(X.wear_image_icon)
#define inhand_sanity_check(X) if (!X.inhand_image) X.inhand_image = image(X.inhand_image_icon)

/mob/living/carbon/human/update_clothing(var/loop_blocker)
	..()

	if (src.transforming || loop_blocker)
		return

	if (!blood_image)
		blood_image = image('icons/effects/blood.dmi')

	// lol

	var/head_offset = 0
	var/hand_offset = 0
	var/body_offset = 0
	var/list/override_states = null
	var/seal_hair = (src.head && src.head.seal_hair)

	if (src.mutantrace)
		head_offset = src.mutantrace.head_offset
		hand_offset = src.mutantrace.hand_offset
		body_offset = src.mutantrace.body_offset
		if (src.mutantrace.clothing_icon_override)
			override_states = icon_states(src.mutantrace.clothing_icon_override, 1)

	src.update_lying()

	// If he's wearing magnetic boots anchored = 1, otherwise anchored = 0
	reset_anchored(src)
	// Automatically drop anything in store / id / belt if you're not wearing a uniform.
	if (!src.w_uniform)
		for (var/atom in list(src.r_store, src.l_store, src.wear_id, src.belt)) //assuming things in all these slots will only ever be items
			var/obj/item/thing = atom
			if (thing)
				u_equip(thing, 1)

				if (thing)
					thing.set_loc(src.loc)
					thing.dropped(src)
					thing.layer = initial(thing.layer)

	src.UpdateOverlays(src.body_standing, "body")
	src.UpdateOverlays(src.hands_standing, "hands")
	src.UpdateOverlays(src.body_damage_standing, "body_damage")
	src.UpdateOverlays(src.head_damage_standing, "head_damage")
	src.UpdateOverlays(src.l_arm_damage_standing, "l_arm_damage")
	src.UpdateOverlays(src.r_arm_damage_standing, "r_arm_damage")
	src.UpdateOverlays(src.l_leg_damage_standing, "l_leg_damage")
	src.UpdateOverlays(src.r_leg_damage_standing, "r_leg_damage")
	src.UpdateOverlays(src.inhands_standing, "inhands")

	UpdateOverlays(src.fire_standing, "fire")

	src.update_face()
	if (src.organHolder && src.organHolder.head)
		if (!src.mutantrace || !src.mutantrace.override_eyes)
			UpdateOverlays(image_eyes, "eyes")
		else
			UpdateOverlays(null, "eyes")

		if (!seal_hair && (!src.mutantrace || !src.mutantrace.override_hair))
			UpdateOverlays(image_cust_one, "cust_one")
		else
			UpdateOverlays(null, "cust_one")
		if (!seal_hair && (!src.mutantrace || !src.mutantrace.override_detail))
			UpdateOverlays(image_cust_two, "cust_two")
		else
			UpdateOverlays(null, "cust_two")
		if (!seal_hair && (!src.mutantrace || !src.mutantrace.override_beard))
			UpdateOverlays(image_cust_three, "cust_three")
		else
			UpdateOverlays(null, "cust_three")


	else
		UpdateOverlays(null, "eyes")
		UpdateOverlays(null, "cust_one")
		UpdateOverlays(null, "cust_two")
		UpdateOverlays(null, "cust_three")

// Uniform
	if (src.w_uniform)
		if (src.bioHolder && bioHolder.HasEffect("fat") && !(src.w_uniform.c_flags & ONESIZEFITSALL))
			boutput(src, "<span class='alert'>You burst out of the [src.w_uniform.name]!</span>")
			var/obj/item/clothing/c = src.w_uniform
			src.u_equip(c)
			if (c)
				c.set_loc(src.loc)
				c.dropped(src)
				c.layer = initial(c.layer)
		if (src.w_uniform && istype(src.w_uniform,/obj/item/clothing/under/experimental))
			var/obj/item/clothing/under/experimental/worn_suit = src.w_uniform
			wear_sanity_check(worn_suit)

			var/counter = 0
			while (counter < 6)
				counter++
				if (counter > worn_suit.images.len)
					UpdateOverlays(null, "suit_image[counter]")
				else
					UpdateOverlays(worn_suit.images[counter], "suit_image[counter]")

			if (worn_suit.blood_DNA)
				blood_image.icon_state =  "uniformblood"
				blood_image.layer = MOB_CLOTHING_LAYER+0.1
				UpdateOverlays(blood_image, "suit_image_blood")
			else
				UpdateOverlays(null, "suit_image_blood")
		else if(src.w_uniform)
			var/image/suit_image
			if (src.bioHolder && src.bioHolder.HasEffect("fat"))
				if (!src.w_uniform.wear_image_fat) src.w_uniform.wear_image_fat = image(src.w_uniform.wear_image_fat_icon)
				suit_image = src.w_uniform.wear_image_fat
			else
				wear_sanity_check(src.w_uniform)
				suit_image = src.w_uniform.wear_image

			if (islist(override_states) && override_states.Find("js-[src.w_uniform.icon_state]"))
				suit_image.icon = src.mutantrace.clothing_icon_override
				suit_image.icon_state = "js-[src.w_uniform.icon_state]"
			else
				suit_image.icon = src.w_uniform.wear_image_icon
				suit_image.icon_state = src.w_uniform.icon_state

			suit_image.layer = MOB_CLOTHING_LAYER
			suit_image.alpha = src.w_uniform.alpha
			suit_image.color = src.w_uniform.color
			UpdateOverlays(suit_image, "suit_image1")
			var/counter = 1
			while (counter < 6)
				counter++
				UpdateOverlays(null, "suit_image[counter]")

			if (src.w_uniform.worn_material_texture_image != null)
				src.w_uniform.worn_material_texture_image.layer = MOB_CLOTHING_LAYER+0.1
				UpdateOverlays(src.w_uniform.worn_material_texture_image, "material_suit")
			else
				UpdateOverlays(null, "material_suit")

			if (src.w_uniform.blood_DNA)
				if (src.w_uniform.blood_DNA == "--conductive_substance--")
					blood_image.icon_state =  "uniformblood"
					blood_image.layer = MOB_CLOTHING_LAYER+0.1
					UpdateOverlays(blood_image, "suit_image_blood")
				else
					blood_image.icon_state =  "uniformblood_c"
					blood_image.layer = MOB_CLOTHING_LAYER+0.1
					UpdateOverlays(blood_image, "suit_image_blood")
			else
				UpdateOverlays(null, "suit_image_blood")

	else
		var/counter = 0
		while (counter < 6)
			counter++
			UpdateOverlays(null, "suit_image[counter]")
		UpdateOverlays(null, "suit_image_blood")
		UpdateOverlays(null, "material_suit")

	if (src.wear_id)
		wear_sanity_check(src.wear_id)
		src.wear_id.wear_image.icon_state = "id"
		src.wear_id.wear_image.pixel_y = body_offset
		src.wear_id.wear_image.layer = MOB_BELT_LAYER
		src.wear_id.wear_image.color = src.wear_id.color
		src.wear_id.wear_image.alpha = src.wear_id.alpha
		UpdateOverlays(src.wear_id.wear_image, "wear_id")
	else
		UpdateOverlays(null, "wear_id")

	// No blood overlay if we have gloves (e.g. bloody hands visible through clean gloves).
	if (src.blood_DNA && !src.gloves)
		if (src.lying)
			blood_image.pixel_x = hand_offset
			blood_image.pixel_y = 0
		else
			blood_image.pixel_x = 0
			blood_image.pixel_y = hand_offset

		blood_image.layer = MOB_HAND_LAYER2 + 0.1
		if (src.limbs && src.limbs.l_arm && src.limbs.l_arm.accepts_normal_human_overlays)
			if (src.blood_DNA == "--conductive_substance--")
				blood_image.icon_state = "left_bloodyhands"
			else
				blood_image.icon_state = "left_bloodyhands_c"
			UpdateOverlays(blood_image, "bloody_hands_l")

		if (src.limbs && src.limbs.r_arm && src.limbs.r_arm.accepts_normal_human_overlays)
			if (src.blood_DNA == "--conductive_substance--")
				blood_image.icon_state = "right_bloodyhands"
			else
				blood_image.icon_state = "right_bloodyhands_c"
			UpdateOverlays(blood_image, "bloody_hands_r")

		blood_image.pixel_x = 0
		blood_image.pixel_y = 0

	else
		UpdateOverlays(null, "bloody_hands_l")
		UpdateOverlays(null, "bloody_hands_r")

	// same as above but for shoes/bare feet
	if (islist(src.tracked_blood) && !src.shoes)

		blood_image.layer = MOB_CLOTHING_LAYER+0.1
		if (src.limbs && src.limbs.l_leg && src.limbs.l_leg.accepts_normal_human_overlays)
			if (src.blood_DNA == "--conductive_substance--")
				blood_image.icon_state = "left_shoeblood"
			else
				blood_image.icon_state = "left_shoeblood_c"
			UpdateOverlays(blood_image, "bloody_feet_l")

		if (src.limbs && src.limbs.r_leg && src.limbs.r_leg.accepts_normal_human_overlays)
			if (src.blood_DNA == "--conductive_substance--")
				blood_image.icon_state = "right_shoeblood"
			else
				blood_image.icon_state = "right_shoeblood_c"
			UpdateOverlays(blood_image, "bloody_feet_r")

		blood_image.pixel_x = 0
		blood_image.pixel_y = 0

	else
		UpdateOverlays(null, "bloody_feet_l")
		UpdateOverlays(null, "bloody_feet_r")

	// Gloves
	if (src.gloves)
		wear_sanity_check(src.gloves)
		var/icon_name = src.gloves.item_state
		if (!icon_name)
			icon_name = src.gloves.icon_state

		src.gloves.wear_image.layer = MOB_HAND_LAYER2

		if (!src.gloves.monkey_clothes)
			src.gloves.wear_image.pixel_x = 0
			src.gloves.wear_image.pixel_y = hand_offset

		if (src.limbs && src.limbs.l_arm && src.limbs.l_arm.accepts_normal_human_overlays) //src.bioHolder && !src.bioHolder.HasEffect("robot_left_arm"))
			src.gloves.wear_image.icon_state = "left_[icon_name]"
			src.gloves.wear_image.color = src.gloves.color
			src.gloves.wear_image.alpha = src.gloves.alpha
			UpdateOverlays(src.gloves.wear_image, "wear_gloves_l")
		else
			UpdateOverlays(null, "wear_gloves_l")

		if (src.limbs && src.limbs.r_arm && src.limbs.r_arm.accepts_normal_human_overlays) //src.bioHolder && !src.bioHolder.HasEffect("robot_right_arm"))
			src.gloves.wear_image.icon_state = "right_[icon_name]"
			src.gloves.wear_image.color = src.gloves.color
			src.gloves.wear_image.alpha = src.gloves.alpha
			UpdateOverlays(src.gloves.wear_image, "wear_gloves_r")
		else
			UpdateOverlays(null, "wear_gloves_r")

		if (src.gloves.blood_DNA)
			if (!src.gloves.monkey_clothes)
				if (src.lying)
					blood_image.pixel_x = hand_offset
					blood_image.pixel_y = 0
				else
					blood_image.pixel_x = 0
					blood_image.pixel_y = hand_offset

			blood_image.layer = MOB_HAND_LAYER2 + 0.1
			if (src.limbs && src.limbs.l_arm && src.limbs.l_arm.accepts_normal_human_overlays)
				if (src.blood_DNA == "--conductive_substance--")
					blood_image.icon_state = "left_bloodygloves"
				else
					blood_image.icon_state = "left_bloodygloves_c"
			UpdateOverlays(blood_image, "bloody_gloves_l")

			if (src.limbs && src.limbs.r_arm && src.limbs.r_arm.accepts_normal_human_overlays)
				if (src.blood_DNA == "--conductive_substance--")
					blood_image.icon_state = "right_bloodygloves"
				else
					blood_image.icon_state = "right_bloodygloves_c"
			UpdateOverlays(blood_image, "bloody_gloves_r")

			blood_image.pixel_x = 0
			blood_image.pixel_y = 0
		else
			UpdateOverlays(null, "bloody_gloves_l")
			UpdateOverlays(null, "bloody_gloves_r")

	else
		UpdateOverlays(null, "wear_gloves_l")
		UpdateOverlays(null, "wear_gloves_r")
		UpdateOverlays(null, "bloody_gloves_l")
		UpdateOverlays(null, "bloody_gloves_r")

	// Stun glove overlay
	if (src.gloves && src.gloves.uses >= 1)
		src.gloves.wear_image.icon_state = "stunoverlay"
		UpdateOverlays(src.gloves.wear_image, "stunoverlay")
	else
		UpdateOverlays(null, "stunoverlay")

	// Shoes
	if (src.shoes)
		wear_sanity_check(src.shoes)
		//. = src.limbs && (!src.limbs.l_leg || istype(src.limbs.l_leg, /obj/item/parts/robot_parts) //(src.bioHolder && src.bioHolder.HasOneOfTheseEffects("lost_left_leg","robot_left_leg","robot_treads"))
		src.shoes.wear_image.layer = MOB_CLOTHING_LAYER
		if (src.limbs && src.limbs.l_leg && src.limbs.l_leg.accepts_normal_human_overlays)
			src.shoes.wear_image.icon_state = "left_[src.shoes.icon_state]"
			src.shoes.wear_image.color = src.shoes.color
			UpdateOverlays(src.shoes.wear_image, "wear_shoes_l")
		else
			UpdateOverlays(null, "wear_shoes_l")

		if (src.limbs && src.limbs.r_leg && src.limbs.r_leg.accepts_normal_human_overlays)
			src.shoes.wear_image.icon_state = "right_[src.shoes.icon_state]"//[!( src.lying ) ? null : "2"]"
			src.shoes.wear_image.color = src.shoes.color
			src.shoes.wear_image.alpha = src.shoes.alpha
			UpdateOverlays(src.shoes.wear_image, "wear_shoes_r")
		else
			UpdateOverlays(null, "wear_shoes_r")

		if (src.shoes.blood_DNA)
			blood_image.layer = MOB_CLOTHING_LAYER+0.1
			if (src.limbs && src.limbs.l_leg && !.)
				if (src.blood_DNA == "--conductive_substance--")
					blood_image.icon_state = "left_shoeblood"
				else
					blood_image.icon_state = "left_shoeblood_c"
				UpdateOverlays(blood_image, "bloody_shoes_l")
			else
				UpdateOverlays(null, "bloody_shoes_l")

			if (src.limbs && src.limbs.r_leg && !.)
				if (src.blood_DNA == "--conductive_substance--")
					blood_image.icon_state = "right_shoeblood"
				else
					blood_image.icon_state = "right_shoeblood_c"
				UpdateOverlays(blood_image, "bloody_shoes_r")
			else
				UpdateOverlays(null, "bloody_shoes_l")
		else
			UpdateOverlays(null, "bloody_shoes_l")
			UpdateOverlays(null, "bloody_shoes_r")
	else
		UpdateOverlays(null, "bloody_shoes_l")
		UpdateOverlays(null, "bloody_shoes_r")
		UpdateOverlays(null, "wear_shoes_l")
		UpdateOverlays(null, "wear_shoes_r")

	if (src.wear_suit)
		if (src.bioHolder && src.bioHolder.HasEffect("fat") && !(src.wear_suit.c_flags & ONESIZEFITSALL))
			boutput(src, "<span class='alert'>You burst out of the [src.wear_suit.name]!</span>")
			var/obj/item/clothing/c = src.wear_suit
			src.u_equip(c)
			if (c)
				c.set_loc(src.loc)
				c.dropped(src)
				c.layer = initial(c.layer)
		else
			wear_sanity_check(src.wear_suit)
			if (src.wear_suit.over_all)
				src.wear_suit.wear_image.layer = MOB_OVERLAY_BASE
			else if (src.wear_suit.over_back)
				src.wear_suit.wear_image.layer = MOB_BACK_LAYER + 0.2
			else
				src.wear_suit.wear_image.layer = MOB_ARMOR_LAYER

			if (islist(override_states) && override_states.Find("suit-[src.wear_suit.icon_state]"))
				src.wear_suit.wear_image.icon = src.mutantrace.clothing_icon_override
				src.wear_suit.wear_image.icon_state = "suit-[src.wear_suit.icon_state]"
			else
				src.wear_suit.wear_image.icon = src.wear_suit.wear_image_icon
				src.wear_suit.wear_image.icon_state = src.wear_suit.icon_state

			src.wear_suit.wear_image.color = src.wear_suit.color
			src.wear_suit.wear_image.alpha = src.wear_suit.alpha
			UpdateOverlays(src.wear_suit.wear_image, "wear_suit")

			if (src.wear_suit.worn_material_texture_image != null)
				switch (src.wear_suit.wear_image.layer)
					if (MOB_OVERLAY_BASE)
						src.wear_suit.worn_material_texture_image.layer = MOB_OVERLAY_BASE + 0.1
					if (MOB_BACK_LAYER)
						src.wear_suit.worn_material_texture_image.layer = MOB_BACK_LAYER + 0.3
					if (MOB_ARMOR_LAYER)
						src.wear_suit.worn_material_texture_image.layer = MOB_ARMOR_LAYER + 0.1
				UpdateOverlays(src.wear_suit.worn_material_texture_image, "material_armor")
			else
				UpdateOverlays(null, "material_armor")

			if (src.wear_suit.blood_DNA)
				if (src.wear_suit.bloodoverlayimage & SUITBLOOD_ARMOR)
					if (src.wear_suit.blood_DNA == "--conductive_substance--")
						blood_image.icon_state = "armorblood"
					else
						blood_image.icon_state = "armorblood_c"
				else if (src.wear_suit.bloodoverlayimage & SUITBLOOD_COAT)
					if (src.wear_suit.blood_DNA == "--conductive_substance--")
						blood_image.icon_state = "coatblood"
					else
						blood_image.icon_state = "coatblood_c"
				else
					if (src.wear_suit.blood_DNA == "--conductive_substance--")
						blood_image.icon_state = "suitblood"
					else
						blood_image.icon_state = "suitblood_c"

				switch (src.wear_suit.wear_image.layer)
					if (MOB_OVERLAY_BASE)
						blood_image.layer = MOB_OVERLAY_BASE + 0.1
					if (MOB_ARMOR_LAYER)
						blood_image.layer = MOB_ARMOR_LAYER + 0.1
				UpdateOverlays(blood_image, "wear_suit_bloody")
			else
				UpdateOverlays(null, "wear_suit_bloody")

			if (src.wear_suit.restrain_wearer)
				if (src.hasStatus("handcuffed"))
					src.handcuffs.drop_handcuffs(src)
				if ((src.l_hand || src.r_hand))
					var/h = src.hand
					src.hand = 1
					drop_item()
					src.hand = 0
					drop_item()
					src.hand = h
	else
		UpdateOverlays(null, "wear_suit")
		UpdateOverlays(null, "wear_suit_bloody")
		UpdateOverlays(null, "material_armor")

	//tank transfer valve backpack's icon is handled in transfer_valve.dm
	if (src.back)
		wear_sanity_check(src.back)
		src.back.wear_image.icon_state = src.back.icon_state
		src.back.wear_image.pixel_x = 0
		src.back.wear_image.pixel_y = body_offset

		src.back.wear_image.layer = MOB_BACK_LAYER
		src.back.wear_image.color = src.back.color
		src.back.wear_image.alpha = src.back.alpha
		UpdateOverlays(src.back.wear_image, "wear_back")

		if (src.back.worn_material_texture_image != null)
			src.back.worn_material_texture_image.layer = MOB_BACK_LAYER+0.1
			UpdateOverlays(src.back.worn_material_texture_image, "material_back")
		else
			UpdateOverlays(null, "material_back")
		src.back.screen_loc = hud.layouts[hud.layout_style]["back"]
	else
		UpdateOverlays(null, "wear_back")
		UpdateOverlays(null, "material_back")

	// Glasses
	if (src.glasses)
		wear_sanity_check(src.glasses)
		src.glasses.wear_image.icon_state = src.glasses.icon_state
		src.glasses.wear_image.layer = MOB_GLASSES_LAYER
		if (!src.glasses.monkey_clothes)
			src.glasses.wear_image.pixel_x = 0
			src.glasses.wear_image.pixel_y = head_offset
		src.glasses.wear_image.color = src.glasses.color
		src.glasses.wear_image.alpha = src.glasses.alpha
		UpdateOverlays(src.glasses.wear_image, "wear_glasses")
		if (src.glasses.worn_material_texture_image != null)
			src.glasses.worn_material_texture_image.layer = MOB_CLOTHING_LAYER+0.1
			UpdateOverlays(src.glasses.worn_material_texture_image, "material_glasses")
		else
			UpdateOverlays(null, "material_glasses")
	else
		UpdateOverlays(null, "wear_glasses")
		UpdateOverlays(null, "material_glasses")
	// Ears
	if (src.ears)
		wear_sanity_check(src.ears)
		src.ears.wear_image.icon_state = "[src.ears.icon_state]"//[(!( src.lying ) ? null : "2")]"
		src.ears.wear_image.layer = MOB_GLASSES_LAYER
		src.ears.wear_image.pixel_x = 0
		src.ears.wear_image.pixel_y = head_offset
		src.ears.wear_image.color = src.ears.color
		src.ears.wear_image.alpha = src.ears.alpha
		UpdateOverlays(src.ears.wear_image, "wear_ears")
		if (src.ears.worn_material_texture_image != null)
			src.ears.worn_material_texture_image.layer = MOB_GLASSES_LAYER+0.1
			UpdateOverlays(src.ears.worn_material_texture_image, "material_ears")
		else
			UpdateOverlays(null, "material_ears")
	else
		UpdateOverlays(null, "wear_ears")
		UpdateOverlays(null, "material_ears")

	if (src.wear_mask)
		wear_sanity_check(src.wear_mask)
		var/no_offset = src.wear_mask.monkey_clothes
		if (islist(override_states) && override_states.Find("mask-[src.wear_mask.icon_state]"))
			src.wear_mask.wear_image.icon = src.mutantrace.clothing_icon_override
			src.wear_mask.wear_image.icon_state = "mask-[src.wear_mask.icon_state]"
			no_offset = 1
		else
			src.wear_mask.wear_image.icon = src.wear_mask.wear_image_icon
			src.wear_mask.wear_image.icon_state = src.wear_mask.icon_state

		if (!no_offset)
			src.wear_mask.wear_image.pixel_x = 0
			src.wear_mask.wear_image.pixel_y = head_offset
		src.wear_mask.wear_image.layer = MOB_HEAD_LAYER1
		src.wear_mask.wear_image.color = src.wear_mask.color
		src.wear_mask.wear_image.alpha = src.wear_mask.alpha
		UpdateOverlays(src.wear_mask.wear_image, "wear_mask")
		if (src.wear_mask.worn_material_texture_image != null)
			src.wear_mask.worn_material_texture_image.layer = MOB_HEAD_LAYER1+0.1
			UpdateOverlays(src.wear_mask.worn_material_texture_image, "material_mask")
		else
			UpdateOverlays(null, "material_mask")
		if (src.wear_mask.use_bloodoverlay)
			if (src.wear_mask.blood_DNA)
				if (src.wear_mask.blood_DNA == "--conductive_substance--")
					blood_image.icon_state = "maskblood"
					blood_image.layer = MOB_HEAD_LAYER1 + 0.1
				else
					blood_image.icon_state = "maskblood_c"
					blood_image.layer = MOB_HEAD_LAYER1 + 0.1
				if (!src.wear_mask.monkey_clothes)
					blood_image.pixel_x = 0
					blood_image.pixel_y = head_offset
				UpdateOverlays(blood_image, "wear_mask_blood")
				blood_image.pixel_x = 0
				blood_image.pixel_y = 0
			else
				UpdateOverlays(null, "wear_mask_blood")
	else
		UpdateOverlays(null, "wear_mask")
		UpdateOverlays(null, "wear_mask_blood")
		UpdateOverlays(null, "material_mask")
	// Head
	if (src.head)
		wear_sanity_check(src.head)

		var/no_offset = src.head.monkey_clothes
		if (islist(override_states) && override_states.Find("head-[src.head.icon_state]"))
			src.head.wear_image.icon = src.mutantrace.clothing_icon_override
			src.head.wear_image.icon_state = "head-[src.head.icon_state]"
			no_offset = 1
		else
			src.head.wear_image.icon = src.head.wear_image_icon
			src.head.wear_image.icon_state = src.head.icon_state

		src.head.wear_image.layer = MOB_HEAD_LAYER2
		if (!no_offset)
			src.head.wear_image.pixel_x = 0
			src.head.wear_image.pixel_y = head_offset
		src.head.wear_image.color = src.head.color
		src.head.wear_image.alpha = src.head.alpha
		UpdateOverlays(src.head.wear_image, "wear_head")
		if (src.head.worn_material_texture_image != null)
			src.head.worn_material_texture_image.layer = MOB_HEAD_LAYER2+0.1
			UpdateOverlays(src.head.worn_material_texture_image, "material_head")
		else
			UpdateOverlays(null, "material_head")
		if (src.head.blood_DNA)
			if (src.head.blood_DNA == "--conductive_substance--")
				blood_image.icon_state = "helmetblood"
				blood_image.layer = MOB_HEAD_LAYER2 + 0.1
			else
				blood_image.icon_state = "helmetblood_c"
				blood_image.layer = MOB_HEAD_LAYER2 + 0.1
			if (!src.head.monkey_clothes)
				blood_image.pixel_x = 0
				blood_image.pixel_y = head_offset
			UpdateOverlays(blood_image, "wear_head_blood")
			blood_image.pixel_x = 0
			blood_image.pixel_y = 0
		else
			UpdateOverlays(null, "wear_head_blood")
	else
		UpdateOverlays(null, "wear_head")
		UpdateOverlays(null, "wear_head_blood")
		UpdateOverlays(null, "material_head")
	// Belt
	if (src.belt)
		wear_sanity_check(src.belt)
		var/t1 = src.belt.item_state
		if (!t1)
			t1 = src.belt.icon_state
		src.belt.wear_image.icon_state = "[t1]"
		src.belt.wear_image.pixel_x = 0
		src.belt.wear_image.pixel_y = body_offset
		src.belt.wear_image.layer = MOB_BELT_LAYER
		src.belt.wear_image.color = src.belt.color
		src.belt.wear_image.alpha = src.belt.alpha
		UpdateOverlays(src.belt.wear_image, "wear_belt")
		if (src.belt.worn_material_texture_image != null)
			src.belt.worn_material_texture_image.layer = MOB_BELT_LAYER+0.1
			UpdateOverlays(src.belt.worn_material_texture_image, "material_belt")
		else
			UpdateOverlays(null, "material_belt")
		src.belt.screen_loc = hud.layouts[hud.layout_style]["belt"]
	else
		UpdateOverlays(null, "wear_belt")
		UpdateOverlays(null, "material_belt")

	src.UpdateName()

//	if (src.wear_id) //Most of the inventory is now hidden, this is handled by other_update()
//		src.wear_id.screen_loc = ui_id

	if (src.l_store)
		src.l_store.screen_loc = hud.layouts[hud.layout_style]["storage1"]

	if (src.r_store)
		src.r_store.screen_loc = hud.layouts[hud.layout_style]["storage2"]

	if (src.hasStatus("handcuffed"))
		src.pulling = null
		handcuff_img.icon_state = "handcuff1"
		handcuff_img.pixel_x = 0
		handcuff_img.pixel_y = hand_offset
		handcuff_img.layer = MOB_HANDCUFF_LAYER
		UpdateOverlays(handcuff_img, "handcuffs")
	else
		UpdateOverlays(null, "handcuffs")

	var/shielded = 0

	for (var/atom/A as() in src)
		if (A.flags & NOSHIELD)
			if (istype(A,/obj/item/device/shield))
				var/obj/item/device/shield/S = A
				if (S.active)
					shielded = 1
					break
			if (istype(A,/obj/item/cloaking_device))
				var/obj/item/cloaking_device/S = A
				if (S.active)
					shielded = 2
					break

	if (shielded == 2)
		src.invisibility = 2
	else
		src.invisibility = 0

	if (shielded)
		UpdateOverlays(shield_image, "shield")
	else
		UpdateOverlays(null, "shield")

	for (var/I in implant_images)
		if (!(I in implant))
			UpdateOverlays(null, "implant--\ref[I]")
			implant_images -= I
	for (var/obj/item/implant/I in implant)
		if (I.implant_overlay && !(I in implant_images))
			UpdateOverlays(I.implant_overlay, "implant--\ref[I]")
			implant_images += I

	if (world.time - src.last_show_inv <= 30 SECONDS)
		for (var/client/C in src.showing_inv)
			if (C && C.mob)
				if (get_dist(src,C.mob) <= 1)
					src.show_inv(C.mob)
				else
					src.remove_dialog(C.mob)
			else
				src.showing_inv -= C


	src.last_b_state = src.stat

	clothing_dirty = 0

#undef wear_sanity_check
#undef inhand_sanity_check

/mob/living/carbon/human/update_face()
	..()

	if (src.organHolder && !src.organHolder.head)
		image_eyes.icon_state = "bald"
		image_cust_one.icon_state = "bald"
		image_cust_two.icon_state = "bald"
		image_cust_three.icon_state = "bald"
		return

	if (!src.bioHolder)
		return // fuck u

	var/datum/appearanceHolder/aH = src.bioHolder.mobAppearance
	var/datum/mutantrace/m_race = src.mutantrace
	if (src.organHolder && src.organHolder.head && src.organHolder.head.donor != src) // gaaaaaaaaaahhhhh
		if (src.organHolder.head.donor_appearance)
			aH = src.organHolder.head.donor_appearance
		if (src.organHolder.head.donor_mutantrace)
			m_race = src.organHolder.head.donor_mutantrace

	if (!m_race || !m_race.override_eyes)
		image_eyes.icon_state = "eyes"
		image_eyes.color = aH.e_color

	if (!m_race || !m_race.override_hair || src.head && src.head.seal_hair)
		cust_one_state = customization_styles[aH.customization_first]
		if (!cust_one_state)
			cust_one_state = customization_styles_gimmick[aH.customization_first]
		image_cust_one.icon_state = src.cust_one_state
		image_cust_one.color = aH.customization_first_color

	if (!m_race || !m_race.override_beard)
		cust_two_state = customization_styles[aH.customization_second]
		if (!cust_two_state)
			cust_two_state = customization_styles_gimmick[aH.customization_second]
		image_cust_two.icon_state = src.cust_two_state
		image_cust_two.color = aH.customization_second_color

	if (!m_race || !m_race.override_detail)
		cust_three_state = customization_styles[aH.customization_third]
		if (!cust_three_state)
			cust_three_state = customization_styles_gimmick[aH.customization_third]
		image_cust_three.icon_state = src.cust_three_state
		image_cust_three.color = aH.customization_third_color


/mob/living/carbon/human/update_burning_icon(var/force_remove=0, var/datum/statusEffect/simpledot/burning/B = 0)
	if (!B)
		B = src.hasStatus("burning")

	if (B && !force_remove)
		var/istate = "fire1"
		if (B.stage == 1)
			istate = "fire1"
			//src.fire_standing = image('icons/mob/human.dmi', "fire1", MOB_EFFECT_LAYER)
			//src.fire_lying = image('icons/mob/human.dmi', "fire1_l", MOB_EFFECT_LAYER)
		else if (B.stage == 2)
			istate = "fire2"
			//src.fire_standing = image('icons/mob/human.dmi', "fire2", MOB_EFFECT_LAYER)
			//src.fire_lying = image('icons/mob/human.dmi', "fire2_l", MOB_EFFECT_LAYER)
		else if (B.stage == 3)
			istate = "fire3"
			//src.fire_standing = image('icons/mob/human.dmi', "fire3", MOB_EFFECT_LAYER)
			//src.fire_lying = image('icons/mob/human.dmi', "fire3_l", MOB_EFFECT_LAYER)
		if (ismonkey(src))
			src.fire_standing = SafeGetOverlayImage("fire", 'icons/mob/monkey.dmi', istate, MOB_EFFECT_LAYER)
		else
			src.fire_standing = SafeGetOverlayImage("fire", 'icons/mob/human.dmi', istate, MOB_EFFECT_LAYER)

		//make them light up!
		add_simple_light("burning", list(255,110,135,255/2 + (round(0.5 + (getStatusDuration("burning")/ 10) / 150, 0.1))*255/2 ))
	else
		src.fire_standing = null
		remove_simple_light("burning")

	UpdateOverlays(src.fire_standing, "fire", 0, 1)

/mob/living/carbon/human/update_inhands()

	src.inhands_standing.len = 0
	var/image/i_r_hand = null
	var/image/i_l_hand = null

	var/hand_offset = 0
	if (src.mutantrace)
		hand_offset = src.mutantrace.hand_offset

	if (src.limbs)
		if(src.l_hand && src.r_hand && src.l_hand == src.r_hand && src.l_hand.two_handed)
			if (src.limbs.r_arm && src.r_hand && src.limbs.l_arm && src.l_hand)
				var/r_item_arm = !(!istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item) && isitem(src.r_hand))
				var/l_item_arm = !(!istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item) && isitem(src.l_hand))
				if (!r_item_arm && !l_item_arm)
					var/obj/item/I = src.l_hand
					if (!I.inhand_image)
						I.inhand_image = image(I.inhand_image_icon, "", MOB_INHAND_LAYER)

					var/state = I.item_state ? I.item_state + "-LR" : (I.icon_state ? I.icon_state + "-LR" : "LR")
					if(!(state in icon_states(I.inhand_image_icon)))
						state = I.item_state ? I.item_state + "-L" : (I.icon_state ? I.icon_state + "-L" : "L")

					I.inhand_image.icon_state = state
					I.inhand_image.color = I.color
					I.inhand_image.pixel_x = 0
					I.inhand_image.pixel_y = hand_offset
					i_r_hand = null
					i_l_hand = I.inhand_image

		else
			if (src.limbs.r_arm && src.r_hand)
				if (!istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item) && isitem(src.r_hand))
					var/obj/item/I = src.r_hand
					if (!I.inhand_image)
						I.inhand_image = image(I.inhand_image_icon, "", MOB_INHAND_LAYER)
					I.inhand_image.icon_state = I.item_state ? I.item_state + "-R" : (I.icon_state ? I.icon_state + "-R" : "R")
					I.inhand_image.color = I.color
					I.inhand_image.pixel_x = 0
					I.inhand_image.pixel_y = hand_offset
					i_r_hand = I.inhand_image


			if (src.limbs.l_arm && src.l_hand)
				if (!istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item) && isitem(src.l_hand))
					var/obj/item/I = src.l_hand
					if (!I.inhand_image)
						I.inhand_image = image(I.inhand_image_icon, "", MOB_INHAND_LAYER)
					I.inhand_image.icon_state = I.item_state ? I.item_state + "-L" : (I.icon_state ? I.icon_state + "-L" : "L")
					I.inhand_image.color = I.color
					I.inhand_image.pixel_x = 0
					I.inhand_image.pixel_y = hand_offset
					i_l_hand = I.inhand_image


	UpdateOverlays(i_r_hand, "i_r_hand")
	UpdateOverlays(i_l_hand, "i_l_hand")

/mob/living/carbon/human/proc/update_hair_layer()
	if (src.wear_suit && src.wear_suit.over_hair && ( src.head && src.head.seal_hair || (src.wear_suit.body_parts_covered & HEAD) ) )
		src.image_cust_one.layer = MOB_HAIR_LAYER1
		src.image_cust_two.layer = MOB_HAIR_LAYER1
		src.image_cust_three.layer = MOB_HAIR_LAYER1
	else
		src.image_cust_one.layer = MOB_HAIR_LAYER2
		src.image_cust_two.layer = MOB_HAIR_LAYER2
		src.image_cust_three.layer = MOB_HAIR_LAYER2


var/list/update_body_limbs = list("r_arm" = "stump_arm_right", "l_arm" = "stump_arm_left", "r_leg" = "stump_leg_right", "l_leg" = "stump_leg_left")

/mob/living/carbon/human/update_body()
	..()

	var/datum/appearanceHolder/AHol = src?.bioHolder.mobAppearance

	var/file
	if (!src.decomp_stage)
		file = 'icons/mob/human.dmi'
	else
		file = 'icons/mob/human_decomp.dmi'

	src.body_standing = SafeGetOverlayImage("body", file, "blank", MOB_LIMB_LAYER) // image('icons/mob/human.dmi', "blank", MOB_LIMB_LAYER)
	src.body_standing.overlays.len = 0
	src.hands_standing = SafeGetOverlayImage("hands", file, "blank", MOB_HAND_LAYER1) //image('icons/mob/human.dmi', "blank", MOB_HAND_LAYER1)
	src.hands_standing.overlays.len = 0

	/*
	src.body_standing = image('icons/mob/human_decomp.dmi', "blank", MOB_LIMB_LAYER)
	src.hands_standing = image('icons/mob/human_decomp.dmi', "blank", MOB_HAND_LAYER1)
	*/
	if (!src.mutantrace)
		if ((src.bioHolder && !src.bioHolder.HasEffect("fat")) || src.decomp_stage)
			var/gender_t = src.gender == FEMALE ? "f" : "m"

			var/skin_tone = (src.bioHolder && src.bioHolder.mobAppearance) ? src.bioHolder.mobAppearance.s_tone : "#777777"
			human_image.color = skin_tone
			human_decomp_image.color = skin_tone

			if (!src.decomp_stage)
				human_image.icon_state = "chest_[gender_t]"
				src.body_standing.overlays += human_image
				human_image.icon_state = "groin_[gender_t]"
				src.body_standing.overlays += human_image
				if (src.organHolder && src.organHolder.head)
					human_head_image.icon_state = "head"
					if (src.organHolder.head.donor_mutantrace)
						human_head_image.icon_state = "[src.organHolder.head.donor_mutantrace.icon_state]"
					else if (src.organHolder.head.donor_appearance && src.organHolder.head.donor_appearance.s_tone != skin_tone)
						var/h_skin_tone = src.organHolder.head.donor_appearance.s_tone
						human_head_image.color = h_skin_tone
					else
						human_head_image.color = skin_tone
					src.body_standing.overlays += human_head_image

			else
				human_decomp_image.icon_state = "body_decomp[src.decomp_stage]"
				src.body_standing.overlays += human_decomp_image

			if (src.limbs)
				src.limbs.reset_stone()

				var/sleeveless = 1
				if (istype(src.w_uniform, /obj/item/clothing) && !(src.w_uniform.c_flags & SLEEVELESS))
					sleeveless = 0
				if (istype(src.wear_suit, /obj/item/clothing) && !(src.wear_suit.c_flags & SLEEVELESS))
					sleeveless = 0

				for (var/name in update_body_limbs) // this is awful
					var/obj/item/parts/human_parts/limb = src.limbs.vars[name]
					if (limb)
						src.body_standing.overlays += limb.getMobIcon(0, src.decomp_stage)

						var/hand_icon_s = limb.getHandIconState(0, src.decomp_stage)

						var/part_icon_s = limb.getPartIconState(0, src.decomp_stage)

						if (limb.decomp_affected && src.decomp_stage)
							if (hand_icon_s) //isicon
								if (istext(hand_icon_s))
									if (limb.skintoned)
										var/oldlayer = human_decomp_image.layer // ugh
										human_decomp_image.layer = MOB_HAND_LAYER1
										human_decomp_image.icon_state = hand_icon_s
										src.hands_standing.layer = MOB_HAND_LAYER1
										src.hands_standing.overlays += human_decomp_image
										human_decomp_image.layer = oldlayer
									else
										var/oldlayer = human_untoned_decomp_image.layer // ugh
										human_untoned_decomp_image.layer = MOB_HAND_LAYER1
										human_untoned_decomp_image.icon_state = hand_icon_s
										src.hands_standing.layer = MOB_HAND_LAYER1
										src.hands_standing.overlays += human_untoned_decomp_image
										human_untoned_decomp_image.layer = oldlayer
								else
									var/image/I = hand_icon_s
									I.layer = MOB_LAYER_BASE
									if (limb.skintoned)
										I.color = human_decomp_image.color
									src.hands_standing.layer = MOB_LAYER_BASE
									src.hands_standing.overlays += I

							if (part_icon_s)
								if (istext(part_icon_s))
									if (limb.skintoned)
										human_decomp_image.icon_state = part_icon_s
										var/oldlayer
										if (sleeveless && (limb.slot == "l_arm" || limb.slot == "r_arm"))
											oldlayer = human_decomp_image.layer // ugh
											human_decomp_image.layer = MOB_HAND_LAYER1
										src.body_standing.overlays += human_decomp_image
										if (oldlayer)
											human_decomp_image.layer = oldlayer
									else
										human_untoned_decomp_image.icon_state = part_icon_s
										var/oldlayer
										if (sleeveless && (limb.slot == "l_arm" || limb.slot == "r_arm"))
											oldlayer = human_untoned_decomp_image.layer // ugh
											human_untoned_decomp_image.layer = MOB_HAND_LAYER1
										src.body_standing.overlays += human_untoned_decomp_image
										if (oldlayer)
											human_untoned_decomp_image.layer = oldlayer
								else
									var/image/I = part_icon_s
									I.layer = MOB_LAYER_BASE
									if (limb.skintoned)
										I.color = human_decomp_image.color
									src.body_standing.overlays += I
						else
							if (hand_icon_s)
								if (istext(hand_icon_s))
									if (limb.skintoned)
										var/oldlayer = human_image.layer // ugh
										human_image.layer = MOB_HAND_LAYER1
										human_image.icon_state = hand_icon_s
										src.hands_standing.layer = MOB_HAND_LAYER1
										src.hands_standing.overlays += human_image
										human_image.layer = oldlayer
									else
										var/oldlayer = human_untoned_image.layer // ugh
										human_untoned_image.layer = MOB_HAND_LAYER1
										human_untoned_image.icon_state = hand_icon_s
										src.hands_standing.layer = MOB_HAND_LAYER1
										src.hands_standing.overlays += human_untoned_image
										human_untoned_image.layer = oldlayer
								else
									var/image/I = hand_icon_s
									I.layer = MOB_LAYER_BASE
									if (limb.skintoned)
										I.color = human_image.color
									src.hands_standing.layer = MOB_LAYER_BASE
									src.hands_standing.overlays += I

							if (part_icon_s)
								if (istext(part_icon_s))
									if (limb.skintoned)
										human_image.icon_state = part_icon_s
										var/oldlayer
										if (sleeveless && (limb.slot == "l_arm" || limb.slot == "r_arm"))
											oldlayer = human_image.layer // ugh
											human_image.layer = MOB_HAND_LAYER1
										src.body_standing.overlays += human_image
										if (oldlayer)
											human_image.layer = oldlayer
									else
										human_untoned_image.icon_state = part_icon_s
										var/oldlayer
										if (sleeveless && (limb.slot == "l_arm" || limb.slot == "r_arm"))
											oldlayer = human_untoned_image.layer // ugh
											human_untoned_image.layer = MOB_HAND_LAYER1
										src.body_standing.overlays += human_untoned_image
										if (oldlayer)
											human_untoned_image.layer = oldlayer
								else
									var/image/I = part_icon_s
									I.layer = MOB_LAYER_BASE
									if (limb.skintoned)
										I.color = human_decomp_image.color
									src.body_standing.overlays += I
					else
						var/stump = update_body_limbs[name]
						if (src.decomp_stage)
							var/decomp = "_decomp[src.decomp_stage]"
							human_decomp_image.icon_state = "[stump][decomp]"
							src.body_standing.overlays += human_decomp_image
						else
							human_image.icon_state = "[stump]"
							src.body_standing.overlays += human_image

			human_image.color = "#fff"

			if (src.organHolder && src.organHolder.heart)
				if (src.organHolder.heart.robotic)
					heart_image.icon_state = "roboheart"
					src.body_standing.overlays += heart_image

				if (src.organHolder.heart.emagged)
					heart_emagged_image.layer = FLOAT_LAYER
					heart_emagged_image.icon_state = "roboheart_emagged"
					src.body_standing.overlays += heart_emagged_image

				if (src.organHolder.heart.synthetic)
					heart_image.icon_state = "synthheart"
					src.body_standing.overlays += heart_image

				if (!isnull(src.organHolder.heart.body_image))
					heart_image.icon_state = src.organHolder.heart.body_image
					src.body_standing.overlays += heart_image

			if (src.bioHolder.mobAppearance.underwear && src.decomp_stage < 3)
				undies_image.icon_state = underwear_styles[src.bioHolder.mobAppearance.underwear]
				undies_image.color = src.bioHolder.mobAppearance.u_color
				src.body_standing.overlays += undies_image

			if (src.bandaged.len > 0)
				for (var/part in src.bandaged)
					bandage_image.icon_state = "bandage-[part]"
					src.body_standing.overlays += bandage_image

			if (src.spiders)
				spider_image.icon_state = "spiders"
				src.body_standing.overlays += spider_image

			if (src.makeup && src.makeup_color)
				makeup_image.icon_state = "lipstick[src.makeup]" // 1 if normal, 2 if you kinda jacked up your application
				makeup_image.color = src.makeup_color
				src.body_standing.overlays += makeup_image

			if (src.juggling())
				juggle_image.icon_state = "juggle"
				src.body_standing.overlays += juggle_image

		else
			var/skin_tone = src.bioHolder.mobAppearance.s_tone
			human_image.color = skin_tone
			human_image.icon_state = "fatbody"
			src.body_standing.overlays += human_image
			human_image.color = "#fff"
	else
		if (src.mob_flags & IS_RELIQUARY_SOLDIER)
			var/list/reli_update_body_limbs = list("r_arm" = "stump_arm_right_reli", "l_arm" = "stump_arm_left_reli", "r_leg" = "stump_leg_right_reli", "l_leg" = "stump_leg_left_reli")
			human_image.icon_state = "chest_reli"
			src.body_standing.overlays += human_image
			human_image.icon_state = "groin_reli"
			src.body_standing.overlays += human_image
			human_image.color = null
			if (src.organHolder && src.organHolder.head)
				human_head_image.icon_state = "head_reli"
				human_head_image.color = null
				src.body_standing.overlays += human_head_image
				if (src.organHolder.head.donor_mutantrace)
					human_head_image.icon_state = "[src.organHolder.head.donor_mutantrace.icon_state]"
					src.body_standing.overlays += human_head_image
			if (src.limbs)
				var/sleeveless = 1
				if (istype(src.w_uniform, /obj/item/clothing) && !(src.w_uniform.c_flags & SLEEVELESS))
					sleeveless = 0
				if (istype(src.wear_suit, /obj/item/clothing) && !(src.wear_suit.c_flags & SLEEVELESS))
					sleeveless = 0

				for (var/name in reli_update_body_limbs)
					var/obj/item/parts/human_parts/limb = src.limbs.vars[name]
					if (limb)
						src.body_standing.overlays += limb.getMobIcon(0, src.decomp_stage)

						var/hand_icon_s = limb.getHandIconState(0, src.decomp_stage)

						var/part_icon_s = limb.getPartIconState(0, src.decomp_stage)

						if (limb.decomp_affected && src.decomp_stage)
							if (hand_icon_s) //isicon
								if (istext(hand_icon_s))
									if (limb.skintoned)
										var/oldlayer = human_decomp_image.layer // ugh
										human_decomp_image.layer = MOB_HAND_LAYER1
										human_decomp_image.icon_state = hand_icon_s
										src.hands_standing.layer = MOB_HAND_LAYER1
										src.hands_standing.overlays += human_decomp_image
										human_decomp_image.layer = oldlayer
									else
										var/oldlayer = human_untoned_decomp_image.layer // ugh
										human_untoned_decomp_image.layer = MOB_HAND_LAYER1
										human_untoned_decomp_image.icon_state = hand_icon_s
										src.hands_standing.layer = MOB_HAND_LAYER1
										src.hands_standing.overlays += human_untoned_decomp_image
										human_untoned_decomp_image.layer = oldlayer
								else
									var/image/I = hand_icon_s
									I.layer = MOB_LAYER_BASE
									if (limb.skintoned)
										I.color = human_decomp_image.color
									src.hands_standing.layer = MOB_LAYER_BASE
									src.hands_standing.overlays += I

							if (part_icon_s)
								if (istext(part_icon_s))
									if (limb.skintoned)
										human_decomp_image.icon_state = part_icon_s
										var/oldlayer
										if (sleeveless && (limb.slot == "l_arm" || limb.slot == "r_arm"))
											oldlayer = human_decomp_image.layer // ugh
											human_decomp_image.layer = MOB_HAND_LAYER1
										src.body_standing.overlays += human_decomp_image
										if (oldlayer)
											human_decomp_image.layer = oldlayer
									else
										human_untoned_decomp_image.icon_state = part_icon_s
										var/oldlayer
										if (sleeveless && (limb.slot == "l_arm" || limb.slot == "r_arm"))
											oldlayer = human_untoned_decomp_image.layer // ugh
											human_untoned_decomp_image.layer = MOB_HAND_LAYER1
										src.body_standing.overlays += human_untoned_decomp_image
										if (oldlayer)
											human_untoned_decomp_image.layer = oldlayer
								else
									var/image/I = part_icon_s
									I.layer = MOB_LAYER_BASE
									if (limb.skintoned)
										I.color = human_decomp_image.color
									src.body_standing.overlays += I
						else
							if (hand_icon_s)
								if (istext(hand_icon_s))
									if (limb.skintoned)
										var/oldlayer = human_image.layer // ugh
										human_image.layer = MOB_HAND_LAYER1
										human_image.icon_state = hand_icon_s
										src.hands_standing.layer = MOB_HAND_LAYER1
										src.hands_standing.overlays += human_image
										human_image.layer = oldlayer
									else
										var/oldlayer = human_untoned_image.layer // ugh
										human_untoned_image.layer = MOB_HAND_LAYER1
										human_untoned_image.icon_state = hand_icon_s
										src.hands_standing.layer = MOB_HAND_LAYER1
										src.hands_standing.overlays += human_untoned_image
										human_untoned_image.layer = oldlayer
								else
									var/image/I = hand_icon_s
									I.layer = MOB_LAYER_BASE
									if (limb.skintoned)
										I.color = human_image.color
									src.hands_standing.layer = MOB_LAYER_BASE
									src.hands_standing.overlays += I

							if (part_icon_s)
								if (istext(part_icon_s))
									if (limb.skintoned)
										human_image.icon_state = part_icon_s
										var/oldlayer
										if (sleeveless && (limb.slot == "l_arm" || limb.slot == "r_arm"))
											oldlayer = human_image.layer // ugh
											human_image.layer = MOB_HAND_LAYER1
										src.body_standing.overlays += human_image
										if (oldlayer)
											human_image.layer = oldlayer
									else
										human_untoned_image.icon_state = part_icon_s
										var/oldlayer
										if (sleeveless && (limb.slot == "l_arm" || limb.slot == "r_arm"))
											oldlayer = human_untoned_image.layer // ugh
											human_untoned_image.layer = MOB_HAND_LAYER1
										src.body_standing.overlays += human_untoned_image
										if (oldlayer)
											human_untoned_image.layer = oldlayer
								else
									var/image/I = part_icon_s
									I.layer = MOB_LAYER_BASE
									if (limb.skintoned)
										I.color = human_decomp_image.color
									src.body_standing.overlays += I
					else
						var/stump = reli_update_body_limbs[name]
						if (src.decomp_stage)
							var/decomp = "_decomp[src.decomp_stage]"
							human_decomp_image.icon_state = "[stump][decomp]"
							src.body_standing.overlays += human_decomp_image
						else
							human_image.icon_state = "[stump]"
							src.body_standing.overlays += human_image

			human_image.color = "#fff"
		else
			var/image/mutant_image
			src.body_standing.overlays += image(src.mutantrace.icon, src.mutantrace.icon_state, MOB_LIMB_LAYER)
			if (AHol.mob_color_flags & BODY_DETAIL_1)
				mutant_image = src.mutantrace.detail_1
				mutant_image.color = src.bioHolder?.mobAppearance.customization_first_color
				src.body_standing.overlays += mutant_image

			if (AHol.mob_color_flags & BODY_DETAIL_2)
				mutant_image = src.mutantrace.detail_2
				mutant_image.color = src.bioHolder?.mobAppearance.customization_second_color
				src.body_standing.overlays += mutant_image

			if (AHol.mob_color_flags & BODY_DETAIL_3)
				mutant_image = src.mutantrace.detail_3
				mutant_image.color = src.bioHolder?.mobAppearance.customization_third_color
				src.body_standing.overlays += mutant_image

			if (AHol.mob_color_flags & BODY_DETAIL_OVERSUIT_1)
				mutant_image = src.mutantrace.detail_over_suit // used by lizards so that when they're facing upwards their tail doesn't look awkward.
				if (AHol.mob_color_flags & BODY_DETAIL_OVERSUIT_IS_COLORFUL)
					mutant_image.color = src.bioHolder?.mobAppearance.customization_first_color
				else
					mutant_image.color = "#FFFFFF"
				src.body_standing.overlays += mutant_image

#if ASS_JAM
	src.maptext_y = 32
	src.maptext_width = 64
	src.maptext_x = -16
	health_update_queue |= src
#endif

	if (src.bioHolder)
		src.bioHolder.OnMobDraw()
	//Also forcing the updates since the overlays may have been modified on the images
	src.UpdateOverlays(src.body_standing, "body", 1, 1)
	src.UpdateOverlays(src.hands_standing, "hands", 1, 1)

#if ASS_JAM //Oh neat apparently this has to do with cool maptext for your health, very neat. plz comment cool things like this so I know what all is on assjam!
/mob/living/carbon/human/UpdateDamage()
	var/prev = health
	..()
	src.updatehealth()
	if (!isdead(src))
		var/h_color = "#999999"
		var/h_pct = round((health / (max_health != 0 ? max_health : 1)) * 100)
		switch (h_pct)
			if (50 to INFINITY)
				h_color	= "rgb([(100 - h_pct) / 50 * 255], 255, [(100 - h_pct) * 0.3])"
			if (0 to 50)
				h_color	= "rgb(255, [h_pct / 50 * 255], 0)"
			if (-100 to 0)
				h_color	= "#ffffff"
		src.maptext = "<span style='color: [h_color];' class='pixel c sh'>[h_pct]%</span>"
		if (prev != health)
			new /obj/maptext_junk/damage(get_turf(src), change = health - prev)
	else
		src.maptext = ""
#else
/mob/living/carbon/human/tdummy/UpdateDamage()
	var/prev = health
	..()
	src.updatehealth()
	if (!isdead(src))
		var/h_color = "#999999"
		var/h_pct = round((health / (max_health != 0 ? max_health : 1)) * 100)
		switch (h_pct)
			if (50 to INFINITY)
				h_color	= "rgb([(100 - h_pct) / 50 * 255], 255, [(100 - h_pct) * 0.3])"
			if (0 to 50)
				h_color	= "rgb(255, [h_pct / 50 * 255], 0)"
			if (-100 to 0)
				h_color	= "#ffffff"
		src.maptext = "<span style='color: [h_color];' class='pixel c sh'>[h_pct]%</span>"
		if (prev != health)
			new /obj/maptext_junk/damage(get_turf(src), change = health - prev)
	else
		src.maptext = ""
#endif

/mob/living/carbon/human/UpdateDamageIcon()
	if (lastDamageIconUpdate && !(world.time - lastDamageIconUpdate))
		return
	..()

	var/brute = get_brute_damage()
	var/burn = get_burn_damage()
	var/brute_state = 0
	var/burn_state = 0

	if (!src.uses_damage_overlays)
		return

	if (brute > 100)
		brute_state = 3
	else if (brute > 50)
		brute_state = 2
	else if (brute > 25)
		brute_state = 1

	if (burn > 100)
		burn_state = 3
	else if (burn > 50)
		burn_state = 2
	else if (burn > 25)
		burn_state = 1

	var/obj/item/organ/head/HO = organs["head"]
	var/head_damage = null
	if (HO && organHolder && organHolder.head)
		var/head_brute = min(3,round(HO.brute_dam/10))
		var/head_burn = min(3,round(HO.burn_dam/10))
		if (head_brute+head_burn > 0)
			head_damage = "head[head_brute][head_burn]"

	if (ismonkey(src))
		src.body_damage_standing = SafeGetOverlayImage("body_damage", 'icons/mob/dam_monkey.dmi',"[brute_state][burn_state]")
		src.body_damage_standing.layer = MOB_DAMAGE_LAYER

		if(burn_state || brute_state)
			UpdateOverlays(src.body_damage_standing, "body_damage")
		else
			UpdateOverlays(null, "body_damage",0,1)
	else
		//Body damage, always present
		src.body_damage_standing = SafeGetOverlayImage("body_damage", 'icons/mob/dam_human.dmi',"body[brute_state][burn_state]", MOB_DAMAGE_LAYER)// image('icons/mob/dam_human.dmi', "[brute_state][burn_state]", MOB_DAMAGE_LAYER)

		//Head damage if applicable
		if (head_damage && organHolder && organHolder.head)
			src.head_damage_standing = SafeGetOverlayImage("head_damage", 'icons/mob/dam_human.dmi', head_damage, MOB_DAMAGE_LAYER) // image('icons/mob/dam_human.dmi', head_damage, MOB_DAMAGE_LAYER)
		else
			src.head_damage_standing = SafeGetOverlayImage("head_damage", 'icons/mob/dam_human.dmi', "00", MOB_DAMAGE_LAYER)//image('icons/mob/dam_human.dmi', "00", MOB_DAMAGE_LAYER)

		//Limb damage
		if(src.limbs && src.limbs.l_arm)
			src.l_arm_damage_standing = SafeGetOverlayImage("l_arm_damage", 'icons/mob/dam_human.dmi',"l_arm[brute_state][burn_state]", MOB_DAMAGE_LAYER)
		else
			src.l_arm_damage_standing = SafeGetOverlayImage("l_arm_damage", 'icons/mob/dam_human.dmi',"00")

		if(src.limbs && src.limbs.r_arm)
			src.r_arm_damage_standing = SafeGetOverlayImage("r_arm_damage", 'icons/mob/dam_human.dmi',"r_arm[brute_state][burn_state]", MOB_DAMAGE_LAYER)
		else
			src.r_arm_damage_standing = SafeGetOverlayImage("r_arm_damage", 'icons/mob/dam_human.dmi',"00")

		if(src.limbs && src.limbs.l_leg)
			src.l_leg_damage_standing = SafeGetOverlayImage("l_leg_damage", 'icons/mob/dam_human.dmi',"l_leg[brute_state][burn_state]", MOB_DAMAGE_LAYER)
		else
			src.l_leg_damage_standing = SafeGetOverlayImage("l_leg_damage", 'icons/mob/dam_human.dmi',"00")

		if(src.limbs && src.limbs.r_leg)
			src.r_leg_damage_standing = SafeGetOverlayImage("r_leg_damage", 'icons/mob/dam_human.dmi',"r_leg[brute_state][burn_state]", MOB_DAMAGE_LAYER)
		else
			src.r_leg_damage_standing = SafeGetOverlayImage("l_arm_damage", 'icons/mob/dam_human.dmi',"00")

		if(burn_state || brute_state)
			UpdateOverlays(src.body_damage_standing, "body_damage")
			UpdateOverlays(src.head_damage_standing, "head_damage")
			UpdateOverlays(src.l_arm_damage_standing, "l_arm_damage")
			UpdateOverlays(src.r_arm_damage_standing, "r_arm_damage")
			UpdateOverlays(src.l_leg_damage_standing, "l_leg_damage")
			UpdateOverlays(src.r_leg_damage_standing, "r_leg_damage")
		else
			UpdateOverlays(null, "body_damage",0,1)
			UpdateOverlays(null, "head_damage",0,1)
			UpdateOverlays(null, "l_arm_damage",0,1)
			UpdateOverlays(null, "r_arm_damage",0,1)
			UpdateOverlays(null, "l_leg_damage",0,1)
			UpdateOverlays(null, "r_leg_damage",0,1)
