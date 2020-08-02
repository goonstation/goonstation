/obj/item/organ/tail
	name = "tail"
	organ_name = "tail"
	organ_holder_name = "tail"
	organ_holder_location = "chest"	// Chest-ish
	organ_holder_required_op_stage = 3.0	// Cant just slap a tail on a human
	edible = 0	// dont eat pant

/obj/item/organ/tail/human	// some dummy tail that doesnt exist cus not everyone has a tail
	name = "human tail"
	desc = "Humans don't have tails... do they? They don't and you shouldn't be seeing this."
	organ_name = "tail"

	organ_detail_under_suit_1 = null
	organ_detail_under_suit_2 = null
	organ_detail_over_suit = null

	on_removal()
		qdel(src)	// Humans dont have tails!

/obj/item/organ/tail/monkey
	name = "monkey tail"
	desc = "A long, slender tail."
	icon_state = "tail-monkey"

	organ_detail_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="monkey_under_suit", layer = MOB_LIMB_LAYER+0.3)
	organ_detail_under_suit_2 = null
	organ_detail_over_suit = image('icons/effects/genetics.dmi', icon_state="monkey_over_suit", layer = MOB_LAYER_BASE+0.3)

/obj/item/organ/tail/lizard
	name = "lizard tail"
	desc = "A long, scaled tail."
	icon_state = "tail-lizard"
	edible = 1	// ew

	organ_detail_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="lizard_under_suit_1", layer = MOB_LIMB_LAYER+0.3)
	organ_detail_under_suit_2 = image('icons/effects/genetics.dmi', icon_state="lizard_under_suit_2", layer = MOB_LIMB_LAYER+0.4)
	organ_detail_over_suit = image('icons/effects/genetics.dmi', icon_state="lizard_over_suit", layer = MOB_LAYER_BASE+0.3)
	// This tail accepts hairstyle colors!
	// If we dont have any colors, make some up
	if(!organ_detail_1)
		organ_detail_1 = rgb(rand(50,190), rand(50,190), rand(50,190))
	if(!organ_detail_2)
		organ_detail_2 = rgb(rand(50,190), rand(50,190), rand(50,190))
	// Apply those colors
	organ_detail_under_suit_1.color = organ_detail_1
	organ_detail_under_suit_2.color = organ_detail_2
	organ_detail_over_suit.color = organ_detail_1


/obj/item/organ/tail/cow
	name = "cow tail"
	desc = "A short, brush-like tail."
	icon_state = "tail-cow"

	organ_detail_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="cow_under_suit", layer = MOB_LIMB_LAYER+0.3)
	organ_detail_under_suit_2 = null
	organ_detail_over_suit = image('icons/effects/genetics.dmi', icon_state="cow_over_suit", layer = MOB_LAYER_BASE+0.3)

/obj/item/organ/tail/wolf
	name = "wolf tail"
	desc = "A long, fluffy tail."
	icon_state = "tail-wolf"

	organ_detail_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="wolf_under_suit", layer = MOB_LIMB_LAYER+0.3)
	organ_detail_under_suit_2 = null
	organ_detail_over_suit = image('icons/effects/genetics.dmi', icon_state="wolf_over_suit", layer = MOB_LAYER_BASE+0.3)

/obj/item/organ/tail/bone
	name = "tailbone"
	desc = "A short piece of bone."
	icon_state = "tail-bone"
	created_decal = null
	made_from = "bone"	// clak clak

	organ_detail_under_suit_1 = null
	organ_detail_under_suit_2 = null
	organ_detail_over_suit = null

/obj/item/organ/tail/seamonkey
	name = "seamonkey tail"
	desc = "A long, scaled tail."
	icon_state = "tail-seamonkey"

	organ_detail_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="seamonkey_under_suit", layer = MOB_LIMB_LAYER+0.3)
	organ_detail_under_suit_2 = null
	organ_detail_over_suit = image('icons/effects/genetics.dmi', icon_state="seamonkey_over_suit", layer = MOB_LAYER_BASE+0.3)

/obj/item/organ/tail/cat
	name = "cat tail"
	desc = "A long, furry tail."
	icon_state = "tail-cat"

	organ_detail_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="cat_under_suit", layer = MOB_LIMB_LAYER+0.3)
	organ_detail_under_suit_2 = null
	organ_detail_over_suit = image('icons/effects/genetics.dmi', icon_state="cat_over_suit", layer = MOB_LAYER_BASE+0.3)

/obj/item/organ/tail/roach
	name = "roach abdomen"
	desc = "A large insect behind."
	icon_state = "tail-roach"
	made_from = "chitin"

	organ_detail_under_suit_1 = image('icons/effects/genetics.dmi', icon_state="roach_under_suit", layer = MOB_LIMB_LAYER+0.3)
	organ_detail_under_suit_2 = null
	organ_detail_over_suit = image('icons/effects/genetics.dmi', icon_state="roach_over_suit", layer = MOB_LAYER_BASE+0.3)
