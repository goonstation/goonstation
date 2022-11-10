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

	// mutantrace clothing overrides
	var/list/uniform_overrides = null
	var/list/id_overrides = null
	var/list/gloves_overrides = null
	var/list/shoe_overrides = null
	var/list/suit_overrides = null
	var/list/back_overrides = null
	var/list/glasses_overrides = null
	var/list/ears_overrides = null
	var/list/mask_overrides = null
	var/list/head_overrides = null
	var/list/belt_overrides = null

	if (src.mutantrace)
		head_offset = src.mutantrace.head_offset
		hand_offset = src.mutantrace.hand_offset
		body_offset = src.mutantrace.body_offset
		uniform_overrides = icon_states(src.mutantrace.clothing_icon_uniform, 1)
		id_overrides = icon_states(src.mutantrace.clothing_icon_id, 1)
		gloves_overrides = icon_states(src.mutantrace.clothing_icon_hands, 1)
		shoe_overrides = icon_states(src.mutantrace.clothing_icon_feet, 1)
		suit_overrides = icon_states(src.mutantrace.clothing_icon_overcoats, 1)
		back_overrides = icon_states(src.mutantrace.clothing_icon_back, 1)
		glasses_overrides = icon_states(src.mutantrace.clothing_icon_eyes, 1)
		ears_overrides = icon_states(src.mutantrace.clothing_icon_ears, 1)
		mask_overrides = icon_states(src.mutantrace.clothing_icon_mask, 1)
		head_overrides = icon_states(src.mutantrace.clothing_icon_head, 1)
		belt_overrides = icon_states(src.mutantrace.clothing_icon_belt, 1)

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

	UpdateOverlays(src.fire_standing, "fire")

	src.update_face()

	// Uniform
	if (src.w_uniform)
		var/image/suit_image
		wear_sanity_check(src.w_uniform)
		suit_image = src.w_uniform.wear_image
		suit_image.filters = src.w_uniform.filters.Copy()
		var/wear_state = src.w_uniform.wear_state || src.w_uniform.icon_state
		if ((islist(uniform_overrides)) && (wear_state in uniform_overrides))
			suit_image.icon = src.mutantrace.clothing_icon_uniform
		else
			suit_image.icon = src.w_uniform.wear_image_icon
		suit_image.icon_state = wear_state

		suit_image.layer = src.w_uniform.wear_layer
		suit_image.alpha = src.w_uniform.alpha
		suit_image.color = src.w_uniform.color
		src.w_uniform.update_wear_image(src, src.w_uniform.wear_image.icon != src.w_uniform.wear_image_icon)
		UpdateOverlays(suit_image, "suit_image1")
		var/counter = 1
		while (counter < 6)
			counter++
			UpdateOverlays(null, "suit_image[counter]")

		if (src.w_uniform.worn_material_texture_image != null)
			src.w_uniform.worn_material_texture_image.layer = src.w_uniform.wear_image.layer + 0.1
			UpdateOverlays(src.w_uniform.worn_material_texture_image, "material_suit")
		else
			UpdateOverlays(null, "material_suit")

		if (src.w_uniform.blood_DNA)
			blood_image.icon_state =  "uniformblood_c"
			blood_image.layer = src.w_uniform.wear_layer + 0.1
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

	// ID
	if (src.wear_id)
		wear_sanity_check(src.wear_id)
		var/wear_state = src.wear_id.wear_state || src.wear_id.icon_state
		var/no_offset = 0
		if ((islist(id_overrides)) && (wear_state in id_overrides))
			src.wear_id.wear_image.icon = src.mutantrace.clothing_icon_id
			no_offset = 1
		else
			src.wear_id.wear_image.icon = src.wear_id.wear_image_icon
		src.wear_id.wear_image.icon_state = wear_state

		if (!no_offset)
			src.wear_id.wear_image.pixel_x = 0
			src.wear_id.wear_image.pixel_y = head_offset

		src.wear_id.wear_image.layer = src.wear_id.wear_layer
		src.wear_id.wear_image.color = src.wear_id.color
		src.wear_id.wear_image.alpha = src.wear_id.alpha
		src.wear_id.wear_image.filters = src.wear_id.filters.Copy()
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
			blood_image.icon_state = "left_bloodyhands_c"
			UpdateOverlays(blood_image, "bloody_hands_l")

		if (src.limbs && src.limbs.r_arm && src.limbs.r_arm.accepts_normal_human_overlays)
			blood_image.icon_state = "right_bloodyhands_c"
			UpdateOverlays(blood_image, "bloody_hands_r")

		blood_image.pixel_x = 0
		blood_image.pixel_y = 0

	else
		UpdateOverlays(null, "bloody_hands_l")
		UpdateOverlays(null, "bloody_hands_r")

	// same as above but for shoes/bare feet
	if (islist(src.tracked_blood) && !src.shoes)

		blood_image.layer = MOB_CLOTHING_LAYER + 0.1 // idk what layer exactly this is supposed to be on TODO figure that out
		if (src.limbs && src.limbs.l_leg && src.limbs.l_leg.accepts_normal_human_overlays)
			blood_image.icon_state = "left_shoeblood_c"
			UpdateOverlays(blood_image, "bloody_feet_l")

		if (src.limbs && src.limbs.r_leg && src.limbs.r_leg.accepts_normal_human_overlays)
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
		var/icon_name = src.gloves.wear_state || src.gloves.item_state || src.gloves.icon_state
		var/no_offset = FALSE
		src.gloves.wear_image.layer = src.gloves.wear_layer
		src.gloves.wear_image.filters = src.gloves.filters.Copy()

		if (src.limbs && src.limbs.l_arm && src.limbs.l_arm.accepts_normal_human_overlays) //src.bioHolder && !src.bioHolder.HasEffect("robot_left_arm"))
			if (islist(gloves_overrides) && ("left_[icon_name]" in gloves_overrides)) //checking if the wearer is a mutant, and if so swaps the left glove with the special sprite if there is one.
				src.gloves.wear_image.icon = src.mutantrace.clothing_icon_hands
				no_offset = TRUE
			else
				src.gloves.wear_image.icon = src.gloves.wear_image_icon
			src.gloves.wear_image.icon_state = "left_[icon_name]"
			src.gloves.wear_image.color = src.gloves.color
			src.gloves.wear_image.alpha = src.gloves.alpha
			src.gloves.update_wear_image(src, src.gloves.wear_image.icon != src.gloves.wear_image_icon)
			UpdateOverlays(src.gloves.wear_image, "wear_gloves_l")
		else
			UpdateOverlays(null, "wear_gloves_l")

		if (src.limbs && src.limbs.r_arm && src.limbs.r_arm.accepts_normal_human_overlays) //src.bioHolder && !src.bioHolder.HasEffect("robot_right_arm"))
			if (islist(gloves_overrides) && ("right_[icon_name]" in gloves_overrides)) //above but right glove
				src.gloves.wear_image.icon = src.mutantrace.clothing_icon_hands
				no_offset = TRUE
			else
				src.gloves.wear_image.icon = src.gloves.wear_image_icon
			src.gloves.wear_image.icon_state = "right_[icon_name]"
			src.gloves.wear_image.color = src.gloves.color
			src.gloves.wear_image.alpha = src.gloves.alpha
			UpdateOverlays(src.gloves.wear_image, "wear_gloves_r")
		else
			UpdateOverlays(null, "wear_gloves_r")

		if (!no_offset)
			src.gloves.wear_image.pixel_x = 0
			src.gloves.wear_image.pixel_y = hand_offset

		if (src.gloves.blood_DNA)
			if (src.lying)
				blood_image.pixel_x = hand_offset
				blood_image.pixel_y = 0
			else
				blood_image.pixel_x = 0
				blood_image.pixel_y = hand_offset

			blood_image.layer = MOB_HAND_LAYER2 + 0.1
			if (src.limbs && src.limbs.l_arm && src.limbs.l_arm.accepts_normal_human_overlays)
				blood_image.icon_state = "left_bloodygloves_c"
			UpdateOverlays(blood_image, "bloody_gloves_l")

			if (src.limbs && src.limbs.r_arm && src.limbs.r_arm.accepts_normal_human_overlays)
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
		var/wear_state = src.shoes.wear_state || src.shoes.icon_state
		src.shoes.wear_image.layer = src.shoes.wear_layer
		src.shoes.wear_image.color = src.shoes.color
		src.shoes.wear_image.alpha = src.shoes.alpha
		src.shoes.wear_image.overlays = null

		var/shoes_count = 0
		if (src.limbs && src.limbs.l_leg && src.limbs.l_leg.accepts_normal_human_overlays)
			shoes_count++
			if (islist(shoe_overrides) && ("left_[wear_state]" in shoe_overrides)) //checks if they are a mutantrace with special left shoe sprites and then replaces them if they do
				src.shoes.wear_image.icon = src.mutantrace.clothing_icon_feet
			else
				src.shoes.wear_image.icon = src.shoes.wear_image_icon
			src.shoes.wear_image.icon_state = "left_[wear_state]"

		if (src.limbs && src.limbs.r_leg && src.limbs.r_leg.accepts_normal_human_overlays)
			shoes_count++
			if(shoes_count == 1)
				if (islist(shoe_overrides) && ("right_[wear_state]" in shoe_overrides)) //like above, but for right shoes
					src.shoes.wear_image.icon = src.mutantrace.clothing_icon_feet
				else
					src.shoes.wear_image.icon = src.shoes.wear_image_icon
				src.shoes.wear_image.icon_state = "right_[wear_state]"
			else
				if (islist(shoe_overrides) && ("right_[wear_state]" in shoe_overrides))
					src.shoes.wear_image.icon = src.mutantrace.clothing_icon_feet
				else
					src.shoes.wear_image.icon = src.shoes.wear_image_icon
				var/image/right_shoe_overlay = image(src.shoes.wear_image.icon, "right_[wear_state]")
				right_shoe_overlay.filters = src.shoes.filters.Copy()
				src.shoes.wear_image.overlays += right_shoe_overlay


		if(shoes_count)
			src.shoes.wear_image.filters = src.shoes.filters.Copy()
			UpdateOverlays(src.shoes.wear_image, "wear_shoes")
		else
			UpdateOverlays(null, "wear_shoes")

		if (src.shoes.blood_DNA)
			blood_image.layer = src.shoes.wear_layer + 0.1
			if (src.limbs && src.limbs.l_leg && !.)
				blood_image.icon_state = "left_shoeblood_c"
				UpdateOverlays(blood_image, "bloody_shoes_l")
			else
				UpdateOverlays(null, "bloody_shoes_l")

			if (src.limbs && src.limbs.r_leg && !.)
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
		UpdateOverlays(null, "wear_shoes")

	// Suit
	if (src.wear_suit)
		wear_sanity_check(src.wear_suit)
		src.wear_suit.wear_image.layer = src.wear_suit.wear_layer
		src.wear_suit.wear_image.filters = src.wear_suit.filters.Copy()

		var/wear_state = src.wear_suit.wear_state || src.wear_suit.icon_state
		if (islist(suit_overrides) && (wear_state in suit_overrides))
			src.wear_suit.wear_image.icon = src.mutantrace.clothing_icon_overcoats
		else
			src.wear_suit.wear_image.icon = src.wear_suit.wear_image_icon
		src.wear_suit.wear_image.icon_state = wear_state

		src.wear_suit.update_wear_image(src, src.wear_suit.wear_image.icon != src.wear_suit.wear_image_icon)
		src.wear_suit.wear_image.color = src.wear_suit.color
		src.wear_suit.wear_image.alpha = src.wear_suit.alpha

		if (src.organHolder?.tail) update_tail_clothing(wear_state)

		UpdateOverlays(src.wear_suit.wear_image, "wear_suit")

		if (src.wear_suit.worn_material_texture_image != null)
			src.wear_suit.worn_material_texture_image.layer = src.wear_suit.wear_image.layer + 0.1
			UpdateOverlays(src.wear_suit.worn_material_texture_image, "material_armor")
		else
			UpdateOverlays(null, "material_armor")

		if (src.wear_suit.blood_DNA)
			if (src.wear_suit.bloodoverlayimage & SUITBLOOD_ARMOR)
				blood_image.icon_state = "armorblood_c"
			else if (src.wear_suit.bloodoverlayimage & SUITBLOOD_COAT)
				blood_image.icon_state = "coatblood_c"
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
		if (src.organHolder?.tail)  update_tail_clothing()
		src.UpdateOverlays(src.tail_standing, "tail", 1, 1) // i blame pali for giving me this power
		src.UpdateOverlays(src.tail_standing_oversuit, "tail_oversuit", 1, 1)
		src.UpdateOverlays(src.detail_standing_oversuit, "detail_oversuit", 1, 1)


	//tank transfer valve backpack's icon is handled in transfer_valve.dm
	if (src.back)
		wear_sanity_check(src.back)
		var/wear_state = src.back.wear_state || src.back.icon_state
		var/no_offset = FALSE
		if (islist(back_overrides) && (wear_state in back_overrides)) //checks if they are a mutantrace with special back sprites and then replaces them if they do
			src.back.wear_image.icon = src.mutantrace.clothing_icon_back
			no_offset = TRUE
		else
			src.back.wear_image.icon = src.back.wear_image_icon
		src.back.wear_image.icon_state = wear_state
		if (!no_offset)
			src.back.wear_image.pixel_x = 0
			src.back.wear_image.pixel_y = body_offset
		src.back.wear_image.layer = src.back.wear_layer
		if(src.back.wear_image.layer == MOB_CLOTHING_LAYER) // if default let's assume you actually want this on back
			src.back.wear_image.layer = MOB_BACK_LAYER
		src.back.wear_image.color = src.back.color
		src.back.wear_image.alpha = src.back.alpha
		src.back.update_wear_image(src, src.back.wear_image.icon != src.back.wear_image_icon)
		src.back.wear_image.filters = src.back.filters.Copy()
		UpdateOverlays(src.back.wear_image, "wear_back")

		if (src.back.worn_material_texture_image != null)
			src.back.worn_material_texture_image.layer = src.back.wear_image.layer + 0.1
			UpdateOverlays(src.back.worn_material_texture_image, "material_back")
		else
			UpdateOverlays(null, "material_back")
		src.back.screen_loc =  do_hud_offset_thing(src.back, hud.layouts[hud.layout_style]["back"])
	else
		UpdateOverlays(null, "wear_back")
		UpdateOverlays(null, "material_back")

	// Glasses
	if (src.glasses)
		wear_sanity_check(src.glasses)
		var/wear_state = src.glasses.wear_state || src.glasses.icon_state
		var/no_offset = FALSE
		if (islist(glasses_overrides) && (wear_state in glasses_overrides)) //checks for special glasses sprites for mutantraces and replaces the sprite with it if there is one.
			src.glasses.wear_image.icon = src.mutantrace.clothing_icon_eyes
			no_offset = TRUE
		else
			src.glasses.wear_image.icon = src.glasses.wear_image_icon
		src.glasses.wear_image.icon_state = wear_state
		src.glasses.wear_image.layer = src.glasses.wear_layer
		if (!no_offset)
			src.glasses.wear_image.pixel_x = 0
			src.glasses.wear_image.pixel_y = head_offset
		src.glasses.wear_image.color = src.glasses.color
		src.glasses.wear_image.alpha = src.glasses.alpha
		src.glasses.update_wear_image(src, src.glasses.wear_image.icon != src.glasses.wear_image_icon)
		src.glasses.wear_image.filters = src.glasses.filters.Copy()
		UpdateOverlays(src.glasses.wear_image, "wear_glasses")
		if (src.glasses.worn_material_texture_image != null)
			src.glasses.worn_material_texture_image.layer = src.glasses.wear_image.layer + 0.1
			UpdateOverlays(src.glasses.worn_material_texture_image, "material_glasses")
		else
			UpdateOverlays(null, "material_glasses")
	else
		UpdateOverlays(null, "wear_glasses")
		UpdateOverlays(null, "material_glasses")
	// Ears
	if (src.ears)
		wear_sanity_check(src.ears)
		var/no_offset = FALSE
		var/wear_state = src.ears.wear_state || src.ears.icon_state
		if (islist(ears_overrides) && (wear_state in ears_overrides)) //checks if they are a mutantrace with special earwear sprites and then replaces them if they do
			src.ears.wear_image.icon = src.mutantrace.clothing_icon_ears
			no_offset = TRUE
		else
			src.ears.wear_image.icon = src.ears.wear_image_icon
		src.ears.wear_image.icon_state = wear_state
		src.ears.wear_image.layer = src.ears.wear_layer
		if (!no_offset)
			src.ears.wear_image.pixel_x = 0
			src.ears.wear_image.pixel_y = head_offset
		src.ears.wear_image.color = src.ears.color
		src.ears.wear_image.alpha = src.ears.alpha
		src.ears.wear_image.filters = src.ears.filters.Copy()
		UpdateOverlays(src.ears.wear_image, "wear_ears")
		if (src.ears.worn_material_texture_image != null)
			src.ears.worn_material_texture_image.layer = src.ears.wear_image.layer + 0.1
			UpdateOverlays(src.ears.worn_material_texture_image, "material_ears")
		else
			UpdateOverlays(null, "material_ears")
	else
		UpdateOverlays(null, "wear_ears")
		UpdateOverlays(null, "material_ears")

	// Mask
	if (src.wear_mask)
		wear_sanity_check(src.wear_mask)
		var/no_offset = FALSE

		var/wear_state = src.wear_mask.wear_state || src.wear_mask.icon_state
		if (islist(mask_overrides) && (wear_state in mask_overrides))
			src.wear_mask.wear_image.icon = src.mutantrace.clothing_icon_mask
			no_offset = TRUE
		else
			src.wear_mask.wear_image.icon = src.wear_mask.wear_image_icon
		src.wear_mask.wear_image.icon_state = wear_state

		if (!no_offset)
			src.wear_mask.wear_image.pixel_x = 0
			src.wear_mask.wear_image.pixel_y = head_offset
		src.wear_mask.wear_image.layer = src.wear_mask.wear_layer
		src.wear_mask.wear_image.color = src.wear_mask.color
		src.wear_mask.wear_image.alpha = src.wear_mask.alpha
		src.wear_mask.update_wear_image(src, src.wear_mask.wear_image.icon != src.wear_mask.wear_image_icon)
		src.wear_mask.wear_image.filters = src.wear_mask.filters.Copy()
		UpdateOverlays(src.wear_mask.wear_image, "wear_mask")
		if (src.wear_mask.worn_material_texture_image != null)
			src.wear_mask.worn_material_texture_image.layer = src.wear_mask.wear_image.layer + 0.1
			UpdateOverlays(src.wear_mask.worn_material_texture_image, "material_mask")
		else
			UpdateOverlays(null, "material_mask")
		if (src.wear_mask.use_bloodoverlay)
			if (src.wear_mask.blood_DNA)
				blood_image.icon_state = "maskblood_c"
				blood_image.layer = MOB_HEAD_LAYER1 + 0.1
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

		var/no_offset = FALSE
		var/wear_state = src.head.wear_state || src.head.icon_state
		if (islist(head_overrides) && (wear_state in head_overrides))
			src.head.wear_image.icon = src.mutantrace.clothing_icon_head
			no_offset = TRUE
		else
			src.head.wear_image.icon = src.head.wear_image_icon
		src.head.wear_image.icon_state = wear_state

		src.head.wear_image.layer = src.head.wear_layer
		if (!no_offset)
			src.head.wear_image.pixel_x = 0
			src.head.wear_image.pixel_y = head_offset
		src.head.wear_image.color = src.head.color
		src.head.wear_image.alpha = src.head.alpha
		src.head.update_wear_image(src, src.head.wear_image.icon != src.head.wear_image_icon)
		src.head.wear_image.filters = src.head.filters.Copy()
		UpdateOverlays(src.head.wear_image, "wear_head")
		if (src.head.worn_material_texture_image != null)
			src.head.worn_material_texture_image.layer = src.head.wear_image.layer + 0.1
			UpdateOverlays(src.head.worn_material_texture_image, "material_head")
		else
			UpdateOverlays(null, "material_head")
		if (src.head.blood_DNA)
			blood_image.icon_state = "helmetblood_c"
			blood_image.layer = MOB_HEAD_LAYER2 + 0.1
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
		var/wear_state = src.belt.wear_state || src.belt.item_state || src.belt.icon_state
		var/no_offset = FALSE
		//
		if (islist(belt_overrides) && (wear_state in belt_overrides)) //checks if they are a mutantrace with special belt sprites and then replaces them if they do
			src.belt.wear_image.icon = src.mutantrace.clothing_icon_belt
			no_offset = TRUE
		else
			src.belt.wear_image.icon = src.belt.wear_image_icon
		src.belt.wear_image.icon_state = wear_state
		if (!no_offset)
			src.belt.wear_image.pixel_x = 0
			src.belt.wear_image.pixel_y = body_offset
		src.belt.wear_image.layer = src.belt.wear_layer
		if(src.belt.wear_image.layer == MOB_CLOTHING_LAYER) // if default let's assume you actually want this on back
			src.belt.wear_image.layer = MOB_BELT_LAYER
		src.belt.wear_image.color = src.belt.color
		src.belt.wear_image.alpha = src.belt.alpha
		src.belt.wear_image.filters = src.belt.filters.Copy()
		UpdateOverlays(src.belt.wear_image, "wear_belt")
		if (src.belt.worn_material_texture_image != null)
			src.belt.worn_material_texture_image.layer = src.belt.wear_image.layer + 0.1
			UpdateOverlays(src.belt.worn_material_texture_image, "material_belt")
		else
			UpdateOverlays(null, "material_belt")
		src.belt.screen_loc = do_hud_offset_thing(belt, hud.layouts[hud.layout_style]["belt"])
	else
		UpdateOverlays(null, "wear_belt")
		UpdateOverlays(null, "material_belt")

	src.UpdateName()

//	if (src.wear_id) //Most of the inventory is now hidden, this is handled by other_update()
//		src.wear_id.screen_loc = ui_id

	if (src.l_store)
		src.l_store.screen_loc = do_hud_offset_thing(src.l_store, hud.layouts[hud.layout_style]["storage1"])

	if (src.r_store)
		src.r_store.screen_loc = do_hud_offset_thing(src.r_store, hud.layouts[hud.layout_style]["storage2"])

	if (src.hasStatus("handcuffed"))
		src.remove_pulling()
		handcuff_img.icon_state = "handcuff1"
		handcuff_img.pixel_x = 0
		handcuff_img.pixel_y = hand_offset
		handcuff_img.layer = MOB_HANDCUFF_LAYER
		UpdateOverlays(handcuff_img, "handcuffs")
	else
		UpdateOverlays(null, "handcuffs")

	var/shielded = 0

	for (var/atom/A as anything in src)
		if (A.flags & NOSHIELD)
			if (istype(A,/obj/item/device/shield))
				var/obj/item/device/shield/S = A
				if (S.active)
					shielded = 1
					break

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

	src.last_b_state = src.stat

	clothing_dirty = 0

#undef wear_sanity_check
#undef inhand_sanity_check

/mob/living/carbon/human/proc/update_tail_clothing(var/icon_state)
	src.tail_standing = SafeGetOverlayImage("tail", 'icons/mob/human.dmi', "blank", MOB_TAIL_LAYER1)
	src.tail_standing.overlays.len = 0
	src.tail_standing_oversuit = SafeGetOverlayImage("tail_oversuit", 'icons/mob/human.dmi', "blank", MOB_OVERSUIT_LAYER1)
	src.tail_standing_oversuit.overlays.len = 0
	var/obj/item/organ/tail/our_tail = src.organHolder.tail // visual tail data is stored in the tail

	// does a suit potentially cover our tail?
	if(our_tail.clothing_image_icon && icon_state)
		var/tail_overrides = icon_states(our_tail.clothing_image_icon, 1)
		if (islist(tail_overrides) && (icon_state in tail_overrides))
			human_tail_image = our_tail.clothing_image_icon
			src.tail_standing.overlays += human_tail_image
			src.tail_standing_oversuit.overlays += human_tail_image

	else
		human_tail_image = our_tail.tail_image_1
		src.tail_standing.overlays += human_tail_image

		human_tail_image = our_tail.tail_image_2 // maybe our tail has multiple parts, like lizards
		src.tail_standing.overlays += human_tail_image

		human_tail_image = our_tail.tail_image_oversuit // oversuit tail, shown when facing north, for more seeable tails
		src.tail_standing_oversuit.overlays += human_tail_image // handles over suit

	src.UpdateOverlays(src.tail_standing, "tail", 1, 1) // i blame pali for giving me this power
	src.UpdateOverlays(src.tail_standing_oversuit, "tail_oversuit", 1, 1)
	src.UpdateOverlays(src.detail_standing_oversuit, "detail_oversuit", 1, 1)

/mob/living/carbon/human/update_face()
	..()
	if (!src.bioHolder)
		return // fuck u

	UpdateOverlays(null, "hair_one", 1, 1)
	UpdateOverlays(null, "hair_two", 1, 1)
	UpdateOverlays(null, "hair_three", 1, 1)

	UpdateOverlays(null, "hair_special_one", 1, 1)
	UpdateOverlays(null, "hair_special_two", 1, 1)
	UpdateOverlays(null, "hair_special_three", 1, 1)

	var/seal_hair = ((src.wear_suit && src.wear_suit.over_hair) || (src.head && src.head.seal_hair) || (src.wear_suit && src.wear_suit.body_parts_covered & HEAD))
	var/obj/item/organ/head/my_head
	if (src?.organHolder?.head)
		var/datum/appearanceHolder/AHH = src.bioHolder?.mobAppearance
		my_head = src.organHolder.head
		var/y_to_offset = AHH.customization_first_offset_y

		src.image_eyes = my_head.head_image_eyes
		if (src.image_eyes)
			src.image_eyes.pixel_y = AHH.e_offset_y
			src.image_eyes.color = AHH.e_color
		UpdateOverlays(image_eyes, "eyes", 1, 1)
		//Previously we shoved all the hair images into the overlays of two images (one for normal hair and one for special) 'cause of identical vars
		//But now we need hairstyle-specific layering so RIP to that approach and time to do things manually
		src.image_cust_one = my_head.head_image_cust_one
		src.image_cust_one?.pixel_y = y_to_offset
		src.image_cust_two = my_head.head_image_cust_two
		src.image_cust_two?.pixel_y = y_to_offset
		src.image_cust_three = my_head.head_image_cust_three
		src.image_cust_three?.pixel_y = y_to_offset

		src.image_special_one = my_head.head_image_special_one
		src.image_special_one?.pixel_y = y_to_offset
		src.image_special_two = my_head.head_image_special_two
		src.image_special_two?.pixel_y = y_to_offset
		src.image_special_three = my_head.head_image_special_three
		src.image_special_three?.pixel_y = y_to_offset

		if(!seal_hair)
			if (AHH.mob_appearance_flags & HAS_HUMAN_HAIR || src.hair_override)
				UpdateOverlays(image_cust_one, "hair_one", 1, 1)
				UpdateOverlays(image_cust_two, "hair_two", 1, 1)
				UpdateOverlays(image_cust_three, "hair_three", 1, 1)
			else
				UpdateOverlays(null, "hair_one", 1, 1)
				UpdateOverlays(null, "hair_two", 1, 1)
				UpdateOverlays(null, "hair_three", 1, 1)

			if (AHH.mob_appearance_flags & HAS_SPECIAL_HAIR || src.special_hair_override)
				UpdateOverlays(image_special_one, "hair_special_one", 1, 1)
				UpdateOverlays(image_special_two, "hair_special_two", 1, 1)
				UpdateOverlays(image_special_three, "hair_special_three", 1, 1)
			else
				UpdateOverlays(null, "hair_special_one", 1, 1)
				UpdateOverlays(null, "hair_special_two", 1, 1)
				UpdateOverlays(null, "hair_special_three", 1, 1)
		else
			UpdateOverlays(null, "hair_one", 1, 1)
			UpdateOverlays(null, "hair_two", 1, 1)
			UpdateOverlays(null, "hair_three", 1, 1)

			UpdateOverlays(null, "hair_special_one", 1, 1)
			UpdateOverlays(null, "hair_special_two", 1, 1)
			UpdateOverlays(null, "hair_special_three", 1, 1)
	else
		UpdateOverlays(null, "hair_one", 1, 1)
		UpdateOverlays(null, "hair_two", 1, 1)
		UpdateOverlays(null, "hair_three", 1, 1)

		UpdateOverlays(null, "hair_special_one", 1, 1)
		UpdateOverlays(null, "hair_special_two", 1, 1)
		UpdateOverlays(null, "hair_special_three", 1, 1)

		UpdateOverlays(null, "eyes", 1, 1)


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
		else if (istype(src:mutantrace, /datum/mutantrace/lizard))
			src.fire_standing = SafeGetOverlayImage("fire", 'icons/mob/lizard.dmi', istate, MOB_EFFECT_LAYER)
		else if (istype(src:mutantrace, /datum/mutantrace/werewolf))
			src.fire_standing = SafeGetOverlayImage("fire", 'icons/mob/werewolf.dmi', istate, MOB_EFFECT_LAYER)
		else if (istype(src:mutantrace, /datum/mutantrace/abomination))
			src.fire_standing = SafeGetOverlayImage("fire", 'icons/mob/abomination.dmi', istate, MOB_EFFECT_LAYER)
		else
			src.fire_standing = SafeGetOverlayImage("fire", 'icons/mob/human.dmi', istate, MOB_EFFECT_LAYER)

		//make them light up!
		add_simple_light("burning", list(255,110,135,255/2 + (round(0.5 + (getStatusDuration("burning")/ 10) / 150, 0.1))*255/2 ))
	else
		src.fire_standing = null
		remove_simple_light("burning")

	UpdateOverlays(src.fire_standing, "fire", 0, 1)

/mob/living/carbon/human/update_inhands()

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
					if (I.color)
						I.inhand_image.color = I.color
					else if (I.inhand_color)
						I.inhand_image.color = I.inhand_color
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
					if (I.color)
						I.inhand_image.color = I.color
					else if (I.inhand_color)
						I.inhand_image.color = I.inhand_color
					I.inhand_image.pixel_x = 0
					I.inhand_image.pixel_y = hand_offset
					i_r_hand = I.inhand_image


			if (src.limbs.l_arm && src.l_hand)
				if (!istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item) && isitem(src.l_hand))
					var/obj/item/I = src.l_hand
					if (!I.inhand_image)
						I.inhand_image = image(I.inhand_image_icon, "", MOB_INHAND_LAYER)
					I.inhand_image.icon_state = I.item_state ? I.item_state + "-L" : (I.icon_state ? I.icon_state + "-L" : "L")
					if (I.color)
						I.inhand_image.color = I.color
					else if (I.inhand_color)
						I.inhand_image.color = I.inhand_color
					I.inhand_image.pixel_x = 0
					I.inhand_image.pixel_y = hand_offset
					i_l_hand = I.inhand_image


	UpdateOverlays(i_r_hand, "i_r_hand")
	UpdateOverlays(i_l_hand, "i_l_hand")

/mob/living/carbon/human/proc/update_hair_layer()
	if ((src.wear_suit && src.wear_suit.over_hair) || (src.head && src.head.seal_hair) || (src.wear_suit && src.wear_suit.body_parts_covered & HEAD))
		src.image_cust_one?.layer = MOB_HAIR_LAYER1
		src.image_cust_two?.layer = MOB_HAIR_LAYER1
		src.image_cust_three?.layer = MOB_HAIR_LAYER1
	else
		src.image_cust_one?.layer = src.bioHolder.mobAppearance.customization_first.default_layer
		src.image_cust_two?.layer = src.bioHolder.mobAppearance.customization_second.default_layer
		src.image_cust_three?.layer = src.bioHolder.mobAppearance.customization_third.default_layer


var/list/update_body_limbs = list("r_leg" = "stump_leg_right", "l_leg" = "stump_leg_left", "r_arm" = "stump_arm_right", "l_arm" = "stump_arm_left")

/mob/living/carbon/human/update_body()
	..()

	var/datum/appearanceHolder/AHOLD = null
	if (src?.bioHolder?.mobAppearance)
		AHOLD = src.bioHolder.mobAppearance
	else	// otherwise you're gonna explode into a shower of runtimes
		return

	if (AHOLD.mob_appearance_flags & USES_STATIC_ICON) // here's a picture of a fucked up human
		src.body_standing = image(AHOLD.body_icon, AHOLD.body_icon_state, MOB_LIMB_LAYER) // this picture is you
		src.hands_standing = image('icons/mob/human.dmi', "blank", MOB_HAND_LAYER1)

	else
		var/file
		if (!src.decomp_stage)
			file = AHOLD.body_icon
		else
			file = 'icons/mob/human_decomp.dmi'


		src.body_standing = SafeGetOverlayImage("body", file, "blank", MOB_LIMB_LAYER) // image('icons/mob/human.dmi', "blank", MOB_LIMB_LAYER)
		src.body_standing.overlays.len = 0
		src.hands_standing = SafeGetOverlayImage("hands", file, "blank", MOB_HAND_LAYER1) //image('icons/mob/human.dmi', "blank", MOB_HAND_LAYER1)
		src.hands_standing.overlays.len = 0
		src.tail_standing = SafeGetOverlayImage("tail", 'icons/mob/human.dmi', "blank", MOB_TAIL_LAYER1)
		src.tail_standing.overlays.len = 0
		src.tail_standing_oversuit = SafeGetOverlayImage("tail_oversuit", 'icons/mob/human.dmi', "blank", MOB_OVERSUIT_LAYER1)
		src.tail_standing_oversuit.overlays.len = 0
		src.detail_standing_oversuit = SafeGetOverlayImage("detail_oversuit", 'icons/mob/human.dmi', "blank", MOB_OVERSUIT_LAYER2)
		src.detail_standing_oversuit.overlays.len = 0

		var/eye_offset = AHOLD.e_offset_y // Monkey need human eyes to see good
		var/body_offset = AHOLD.mob_body_offset // Monkey need human arms to hug good
		var/leg_offset = AHOLD.mob_leg_offset
		var/arm_offset = AHOLD.mob_arm_offset
		var/head_offset = AHOLD.mob_head_offset

		// if the image data can be stored in the thing it's trying to draw, store it there
		// that way, we can make the thing look like the thing without a bunch of dynamic guesswork
		if (AHOLD.mob_appearance_flags & BUILT_FROM_PIECES) // Everyone who isnt a static_icon
			human_image.icon = AHOLD.body_icon
			human_image.layer = MOB_LIMB_LAYER // why was this never defined before
			var/gender_t = null
			if (AHOLD.mob_appearance_flags & NOT_DIMORPHIC) // Most mutants arent dimorphic
				if (AHOLD.mob_appearance_flags & TORSO_HAS_SKINTONE)
					gender_t = "s" // s for skintone I guess
				else
					gender_t = "m" // and i doubt they ever will be
			else
				gender_t = src.gender == FEMALE ? "f" : "m"

			var/skin_tone = "#FFFFFF" // #FFFFFF preserves color of base sprites
			if(AHOLD.mob_appearance_flags & HAS_HUMAN_SKINTONE)
				skin_tone = AHOLD.s_tone
			human_image.color = skin_tone
			human_decomp_image.color = skin_tone

			if (!src.decomp_stage)
				human_image.icon_state = "chest_[gender_t]"
				var/chest_color_before = skin_tone
				if(AHOLD.mob_appearance_flags & TORSO_HAS_SKINTONE) // Torso is supposed to be skintoned, even if everything else isnt?
					human_image.color = AHOLD.s_tone	// Apply their normal skin-tone to the chest if that's what its supposed to be
				src.body_standing.overlays += human_image
				human_image.icon_state = "groin_[gender_t]"
				src.body_standing.overlays += human_image
				human_image.color = chest_color_before

				// all this shit goes on the torso anyway
				if(AHOLD.mob_appearance_flags & HAS_EXTRA_DETAILS)
					human_image = image(AHOLD.mob_detail_1_icon, AHOLD.mob_detail_1_state, MOB_BODYDETAIL_LAYER1)
					switch(AHOLD.mob_detail_1_color_ref)
						if(CUST_1)
							human_image.color = AHOLD.customization_first_color
						if(CUST_2)
							human_image.color = AHOLD.customization_second_color
						if(CUST_3)
							human_image.color = AHOLD.customization_third_color
						else
							human_image.color = "#FFFFFF"
					src.body_standing.overlays += human_image

				if(AHOLD.mob_appearance_flags & HAS_OVERSUIT_DETAILS)	// need more oversuits? Make more of these!
					human_detail_image = image(AHOLD.mob_oversuit_1_icon, AHOLD.mob_oversuit_1_state, layer = MOB_OVERSUIT_LAYER1)
					switch(AHOLD.mob_oversuit_1_color_ref)
						if(CUST_1)
							human_detail_image.color = AHOLD.customization_first_color
						if(CUST_2)
							human_detail_image.color = AHOLD.customization_second_color
						if(CUST_3)
							human_detail_image.color = AHOLD.customization_third_color
						else
							human_detail_image.color = "#FFFFFF"
					src.detail_standing_oversuit.overlays += human_detail_image
					UpdateOverlays(src.detail_standing_oversuit, "detail_oversuit")
				else // ^^ up here because peoples' bodies turn invisible if it down there with the rest of em
					UpdateOverlays(null, "detail_oversuit")

				if (src.organHolder?.head && !(AHOLD.mob_appearance_flags & HAS_NO_HEAD))
					var/obj/item/organ/head/our_head = src.organHolder.head
					human_head_image = our_head.head_image // head data is stored in the head
					human_head_image?.pixel_y = head_offset // head position is stored in the body
					src.body_standing.overlays += human_head_image

				if (src.organHolder?.tail)
					update_tail_clothing()
				else
					UpdateOverlays(null, "tail")
					UpdateOverlays(null, "tail_oversuit")

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
					var/armleg_offset = (name == "r_arm" || name == "l_arm") ? arm_offset : leg_offset
					if (limb)

						var/image/limb_pic = limb.getMobIcon(0, src.decomp_stage)	// The limb, not the hand/foot
						var/limb_skin_tone = "#FFFFFF"	// So we dont stomp on any limbs that arent supposed to be colorful
						if (limb.skintoned && limb.skin_tone)	// Get the limb's stored skin tone, if its skintoned and has a skin_tone
							limb_skin_tone = limb.skin_tone	// So the limb's hand/foot gets the color too, when/if we get there
						if(limb_pic)
							limb_pic.color = limb_skin_tone
							limb_pic.pixel_y = armleg_offset
							src.body_standing.overlays += limb_pic

						var/hand_icon_s = limb.getHandIconState(0, src.decomp_stage)

						var/part_icon_s = limb.getPartIconState(0, src.decomp_stage)

						var/handlimb_icon = limb.getAttachmentIcon(src.decomp_stage)

						if (limb.decomp_affected && src.decomp_stage)
							if (hand_icon_s) //isicon
								if (istext(hand_icon_s))
									if (limb.skintoned)
										var/oldlayer = human_decomp_image.layer // ugh
										human_decomp_image.layer = MOB_HAND_LAYER1
										human_decomp_image.icon_state = hand_icon_s
										human_decomp_image.pixel_y = armleg_offset
										src.hands_standing.layer = MOB_HAND_LAYER1
										src.hands_standing.overlays += human_decomp_image
										if(limb.handfoot_overlay_1)
											human_decomp_image.icon = limb.handfoot_overlay_1?.icon
											human_decomp_image.icon_state = limb.handfoot_overlay_1?.icon_state
											human_decomp_image.color = limb.handfoot_overlay_1?.color
											human_decomp_image.layer = MOB_BODYDETAIL_LAYER2
											human_decomp_image.pixel_y = armleg_offset
											src.body_standing.overlays += human_decomp_image
										human_decomp_image.layer = oldlayer
									else
										var/oldlayer = human_untoned_decomp_image.layer // ugh
										human_untoned_decomp_image.layer = MOB_HAND_LAYER1
										human_untoned_decomp_image.icon_state = hand_icon_s
										human_untoned_decomp_image.pixel_y = armleg_offset
										src.hands_standing.layer = MOB_HAND_LAYER1
										src.hands_standing.overlays += human_untoned_decomp_image
										if(limb.handfoot_overlay_1)
											human_untoned_decomp_image.icon = limb.handfoot_overlay_1?.icon
											human_untoned_decomp_image.icon_state = limb.handfoot_overlay_1?.icon_state
											human_untoned_decomp_image.color = limb.handfoot_overlay_1?.color
											human_untoned_decomp_image.layer = MOB_BODYDETAIL_LAYER2
											human_untoned_decomp_image.pixel_y = armleg_offset
											src.body_standing.overlays += human_untoned_decomp_image
										human_untoned_decomp_image.layer = oldlayer
								else
									var/image/I = hand_icon_s
									I.layer = MOB_HAND_LAYER1
									I.pixel_y = armleg_offset
									if (limb.skintoned)
										I.color = human_decomp_image.color
									src.hands_standing.layer = MOB_HAND_LAYER1
									src.hands_standing.overlays += I
									if(limb.handfoot_overlay_1)
										I = limb.handfoot_overlay_1
										I.layer = MOB_BODYDETAIL_LAYER2
										I.pixel_y = armleg_offset
										if (limb.skintoned)
											I.color = human_decomp_image.color
										src.body_standing.overlays += I

							if (part_icon_s)
								if (istext(part_icon_s))
									if (limb.skintoned)
										human_decomp_image.icon_state = part_icon_s
										human_decomp_image.pixel_y = armleg_offset
										var/oldlayer
										if (sleeveless && (limb.slot == "l_arm" || limb.slot == "r_arm"))
											oldlayer = human_decomp_image.layer // ugh
											human_decomp_image.layer = MOB_HAND_LAYER1
										src.body_standing.overlays += human_decomp_image
										if(limb.handfoot_overlay_1)
											human_untoned_decomp_image.icon = limb.handfoot_overlay_1?.icon
											human_untoned_decomp_image.icon_state = limb.handfoot_overlay_1?.icon_state
											human_untoned_decomp_image.color = limb.handfoot_overlay_1?.color
											human_untoned_decomp_image.layer = MOB_BODYDETAIL_LAYER2
											human_untoned_decomp_image.pixel_y = armleg_offset
											src.body_standing.overlays += human_untoned_decomp_image
										if (oldlayer)
											human_untoned_decomp_image.layer = oldlayer
									else
										human_untoned_decomp_image.icon_state = part_icon_s
										var/oldlayer
										if (sleeveless && (limb.slot == "l_arm" || limb.slot == "r_arm"))
											oldlayer = human_untoned_decomp_image.layer // ugh
											human_untoned_decomp_image.layer = MOB_HAND_LAYER1
										src.body_standing.overlays += human_untoned_decomp_image
										if(limb.handfoot_overlay_1)
											human_untoned_decomp_image.icon = limb.handfoot_overlay_1?.icon
											human_untoned_decomp_image.icon_state = limb.handfoot_overlay_1?.icon_state
											human_untoned_decomp_image.color = limb.handfoot_overlay_1?.color
											human_untoned_decomp_image.layer = MOB_BODYDETAIL_LAYER2
											human_untoned_decomp_image.pixel_y = armleg_offset
											src.body_standing.overlays += human_untoned_decomp_image
										if (oldlayer)
											human_untoned_decomp_image.layer = oldlayer
								else
									var/image/I = part_icon_s
									I.layer = MOB_HAND_LAYER1
									if (limb.skintoned)
										I.color = human_decomp_image.color
									src.body_standing.overlays += I
									if(limb.handfoot_overlay_1)
										I = limb.handfoot_overlay_1
										I.layer = MOB_BODYDETAIL_LAYER2
										I.pixel_y = armleg_offset
										if (limb.skintoned)
											I.color = human_decomp_image.color
										src.body_standing.overlays += I

						else
							if (hand_icon_s)
								if (istext(hand_icon_s))
									var/oldlayer = human_image.layer // ugh
									human_image.layer = MOB_HAND_LAYER1
									human_image.icon = handlimb_icon
									human_image.icon_state = hand_icon_s
									human_image.color = limb_skin_tone
									human_image.pixel_y = armleg_offset
									src.hands_standing.layer = MOB_HAND_LAYER1
									src.hands_standing.overlays += human_image
									if(limb.handfoot_overlay_1)
										human_image.icon = limb.handfoot_overlay_1?.icon
										human_image.icon_state = limb.handfoot_overlay_1?.icon_state
										human_image.color = limb.handfoot_overlay_1?.color
										human_image.layer = MOB_BODYDETAIL_LAYER2
										src.body_standing.overlays += human_image
									human_image.layer = oldlayer

								else
									var/image/I = hand_icon_s
									I.layer = MOB_HAND_LAYER1
									if(!limb.no_icon)
										I.icon = handlimb_icon
										I.icon_state = hand_icon_s
									I.color = limb_skin_tone
									I.pixel_y = armleg_offset
									src.hands_standing.layer = MOB_HAND_LAYER1
									src.hands_standing.overlays += I
									if(limb.handfoot_overlay_1)
										I = limb.handfoot_overlay_1
										I.layer = MOB_BODYDETAIL_LAYER2
										I.pixel_y = armleg_offset
										if (limb.skintoned)
											I.color = human_decomp_image.color
										src.body_standing.overlays += I

							if (part_icon_s)
								if (istext(part_icon_s))
									human_image.icon = limb.partIcon
									human_image.icon_state = part_icon_s
									human_image.color = limb_skin_tone
									human_image.pixel_y = armleg_offset
									var/oldlayer = human_image.layer
									human_image.layer = MOB_LIMB_LAYER
									src.body_standing.overlays += human_image
									if(limb.handfoot_overlay_1)
										human_image.icon = limb.handfoot_overlay_1?.icon
										human_image.icon_state = limb.handfoot_overlay_1?.icon_state
										human_image.color = limb.handfoot_overlay_1?.color
										human_image.layer = MOB_BODYDETAIL_LAYER2
										src.body_standing.overlays += human_image
									human_image.layer = oldlayer
								else
									var/image/I = part_icon_s
									I.layer = MOB_HAND_LAYER1
									I.color = limb_skin_tone
									I.pixel_y = armleg_offset
									src.body_standing.overlays += I
									if(limb.handfoot_overlay_1)
										I = limb.handfoot_overlay_1
										I.layer = MOB_BODYDETAIL_LAYER2
										src.body_standing.overlays += I

					else	// Handles stumps
						var/stump = update_body_limbs[name]
						if (src.decomp_stage)
							var/decomp = "_decomp[src.decomp_stage]"
							human_decomp_image.icon = file
							human_decomp_image.icon_state = "[stump][decomp]"
							human_decomp_image.pixel_y = armleg_offset
							src.body_standing.overlays += human_decomp_image
						else
							human_image.icon = file
							human_image.icon_state = "[stump]"
							human_image.pixel_y = armleg_offset
							var/old_skintone = human_image.color
							if(AHOLD.mob_appearance_flags & TORSO_HAS_SKINTONE && (stump == "stump_arm_right" || stump == "stump_arm_left")) // Arm stumps look odd if the torso is skintoned, but they arent
								human_image.color = AHOLD.s_tone	// Apply their normal skin-tone to the stumps if their torso is supposed to be skin-toned
							src.body_standing.overlays += human_image
							human_image.color = old_skintone

			human_image.color = "#fff"
			human_image.pixel_y = 0

			if (src.organHolder?.heart)
				if (src.organHolder.heart.robotic)
					heart_image.icon_state = "roboheart"
					heart_image.pixel_y = body_offset
					src.body_standing.overlays += heart_image

				if (src.organHolder.heart.emagged)
					heart_emagged_image.layer = FLOAT_LAYER
					heart_emagged_image.pixel_y = body_offset
					heart_emagged_image.icon_state = "roboheart_emagged"
					src.body_standing.overlays += heart_emagged_image

				if (src.organHolder.heart.synthetic)
					heart_image.icon_state = "synthheart"
					heart_image.pixel_y = body_offset
					src.body_standing.overlays += heart_image

				if (!isnull(src.organHolder.heart.body_image))
					heart_image.icon_state = src.organHolder.heart.body_image
					heart_image.pixel_y = body_offset
					src.body_standing.overlays += heart_image

			if (src.decomp_stage < DECOMP_STAGE_HIGHLY_DECAYED && ((AHOLD.underwear && AHOLD.mob_appearance_flags & WEARS_UNDERPANTS) || src.underpants_override)) // no more bikini werewolves
				undies_image.icon_state = underwear_styles[AHOLD.underwear]
				undies_image.color = AHOLD.u_color
				undies_image.pixel_y = body_offset
				src.body_standing.overlays += undies_image

			if (src.bandaged.len > 0)
				for (var/part in src.bandaged)
					bandage_image.icon_state = "bandage-[part]"
					bandage_image.pixel_y = body_offset
					src.body_standing.overlays += bandage_image

			if (src.spiders)
				spider_image.icon_state = "spiders"
				spider_image.pixel_y = body_offset
				src.body_standing.overlays += spider_image

			if (src.makeup && src.makeup_color)
				makeup_image.icon_state = "lipstick[src.makeup]" // 1 if normal, 2 if you kinda jacked up your application
				makeup_image.color = src.makeup_color
				makeup_image.pixel_y = eye_offset
				src.body_standing.overlays += makeup_image

			if (src.juggling())
				juggle_image.icon_state = "juggle"
				juggle_image.pixel_y = body_offset
				src.body_standing.overlays += juggle_image

	if (src.bioHolder)
		src.bioHolder.OnMobDraw()
	//Also forcing the updates since the overlays may have been modified on the images
	src.UpdateOverlays(src.body_standing, "body", 1, 1)
	src.UpdateOverlays(src.hands_standing, "hands", 1, 1)
	src.UpdateOverlays(src.tail_standing, "tail", 1, 1) // i blame pali for giving me this power
	src.UpdateOverlays(src.tail_standing_oversuit, "tail_oversuit", 1, 1)
	src.UpdateOverlays(src.detail_standing_oversuit, "detail_oversuit", 1, 1)


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
	if (HO && organHolder?.head)
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
		if (head_damage && organHolder?.head)
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
