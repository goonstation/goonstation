/obj/item/organ/tail
	name = "tail"
	organ_name = "tail"
	organ_holder_name = "tail"
	organ_holder_location = "chest"	// Chest-ish
	organ_holder_required_op_stage = 3.0	// Cant just slap a tail on a human
	edible = 0	// dont eat pant
	var/icon_piece_1 = null	// For setting up the icon if its in multiple pieces
	var/icon_piece_2 = null

	proc/update_tail_icon()
		if (!src.icon_piece_1 && !src.icon_piece_2)
			return	// Nothing really there to update
		var/icon/tail_icon = null
		tail_icon = new /icon(src.icon, src.icon_state)

		if(!src.organ_color_1)
			src.organ_color_1 = rgb(rand(50,190), rand(50,190), rand(50,190))
		if(!src.organ_color_2)
			src.organ_color_2 = rgb(rand(50,190), rand(50,190), rand(50,190))

		if (src.icon_piece_1)
			var/icon/icon_1 = new /icon(src.icon, src.icon_piece_1)
			icon_1.Blend(src.organ_color_1, ICON_MULTIPLY)
			tail_icon.Blend(icon_1, ICON_OVERLAY)

		if (src.icon_piece_2)
			var/icon/icon_2 = new /icon(src.icon, src.icon_piece_2)
			icon_2.Blend(src.organ_color_2, ICON_MULTIPLY)
			tail_icon.Blend(icon_2, ICON_OVERLAY)

		src.icon = tail_icon

/obj/item/organ/tail/human	// some dummy tail that doesnt exist cus not everyone has a tail
	name = "human tail"
	desc = "Humans don't have tails... do they? They don't and you shouldn't be seeing this."
	organ_name = "tail"

	on_removal()
		qdel(src)	// Humans dont have tails!

/obj/item/organ/tail/monkey
	name = "monkey tail"
	desc = "A long, slender tail."
	icon_state = "tail-monkey"

	New()
		..()
		src.organ_image_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="monkey_under_suit", layer = MOB_LIMB_LAYER-0.3)
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = image('icons/effects/genetics.dmi', icon_state="monkey_over_suit", layer = MOB_LAYER_BASE+0.3)

/obj/item/organ/tail/lizard
	name = "lizard tail"
	desc = "A long, scaled tail."
	icon_state = "tail-lizard"	// This is just the meat bit
	icon_piece_1 = "tail-lizard-detail-1"
	icon_piece_2 = "tail-lizard-detail-2"
	edible = 1	// ew

	New()
		..()
		src.organ_image_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="lizard_under_suit_1", layer = MOB_LIMB_LAYER-0.3)
		src.organ_image_under_suit_2 = image('icons/effects/genetics.dmi', icon_state="lizard_under_suit_2", layer = MOB_LIMB_LAYER-0.25)
		src.organ_image_over_suit = image('icons/effects/genetics.dmi', icon_state="lizard_over_suit", layer = MOB_LAYER_BASE+0.3)
		// This tail accepts hairstyle colors!
		// If we dont have any colors, make some up
		if(!src.organ_color_1)
			src.organ_color_1 = rgb(rand(50,190), rand(50,190), rand(50,190))
		if(!organ_color_2)
			src.organ_color_2 = rgb(rand(50,190), rand(50,190), rand(50,190))
		// Apply those colors
		src.organ_image_under_suit_1.color = organ_color_1
		src.organ_image_under_suit_2.color = organ_color_2
		src.organ_image_over_suit.color = organ_color_1
		src.update_tail_icon()

/obj/item/organ/tail/cow
	name = "cow tail"
	desc = "A short, brush-like tail."
	icon_state = "tail-cow"

	New()
		..()
		src.organ_image_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="cow_under_suit", layer = MOB_LIMB_LAYER-0.3)
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = image('icons/effects/genetics.dmi', icon_state="cow_over_suit", layer = MOB_LAYER_BASE+0.3)

/obj/item/organ/tail/wolf
	name = "wolf tail"
	desc = "A long, fluffy tail."
	icon_state = "tail-wolf"

	New()
		..()
		src.organ_image_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="wolf_under_suit", layer = MOB_LIMB_LAYER-0.3)
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = image('icons/effects/genetics.dmi', icon_state="wolf_over_suit", layer = MOB_LAYER_BASE+0.3)

/obj/item/organ/tail/bone
	name = "tailbone"
	desc = "A short piece of bone."
	icon_state = "tail-bone"
	created_decal = null
	made_from = "bone"	// clak clak

	New()
		..()
		src.organ_image_under_suit_1 = null
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = null

/obj/item/organ/tail/seamonkey
	name = "seamonkey tail"
	desc = "A long, scaled tail."
	icon_state = "tail-seamonkey"

	New()
		..()
		src.organ_image_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="seamonkey_under_suit", layer = MOB_LIMB_LAYER-0.3)
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = image('icons/effects/genetics.dmi', icon_state="seamonkey_over_suit", layer = MOB_LAYER_BASE+0.3)

/obj/item/organ/tail/cat
	name = "cat tail"
	desc = "A long, furry tail."
	icon_state = "tail-cat"

	New()
		..()
		src.organ_image_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="cat_under_suit", layer = MOB_LIMB_LAYER-0.3)
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = image('icons/effects/genetics.dmi', icon_state="cat_over_suit", layer = MOB_LAYER_BASE+0.3)

/obj/item/organ/tail/roach
	name = "roach abdomen"
	desc = "A large insect behind."
	icon_state = "tail-roach"
	made_from = "chitin"

	New()
		..()
		src.organ_image_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="roach_under_suit", layer = MOB_LIMB_LAYER-0.3)
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = image('icons/effects/genetics.dmi', icon_state="roach_over_suit", layer = MOB_LAYER_BASE+0.3)
