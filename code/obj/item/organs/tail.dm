/obj/item/organ/tail
	name = "tail"
	organ_name = "tail"
	organ_holder_name = "tail"
	organ_holder_location = "chest"	// chest-ish
	organ_holder_required_op_stage = 11.0
	edible = 0	// dont eat pant
	organ_image_icon = 'icons/effects/genetics.dmi'
	var/icon_piece_1 = null	// For setting up the icon if its in multiple pieces
	var/icon_piece_2 = null
	var/failure_ability = "clumsy"	// The organ failure ability associated with this organ.
	var/human_getting_monkeytail = 0	// If a human's getting a monkey tail
	var/monkey_getting_humantail = 0	// If a monkey's getting a human tail

	//Assembles the tail organ item sprite icon thing from multiple separate iconstates
	//Used when a tail organ has a bunch of different colors its supposed to be
	proc/update_tail_icon()
		if (!src.icon_piece_1 && !src.icon_piece_2)
			return	// Nothing really there to update
		src.overlays.len = 0

		if (src.icon_piece_1)
			var/image/organ_piece_1 = image(src.icon, src.icon_piece_1)
			organ_piece_1.color = src.organ_color_1
			src.overlays += organ_piece_1

		if (src.icon_piece_2)
			var/image/organ_piece_2 = image(src.icon, src.icon_piece_2)
			organ_piece_2.color = src.organ_color_2
			src.overlays += organ_piece_2

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Overrides parent function to handle special case for tails. */
		var/mob/living/carbon/human/H = M

		var/attachment_successful = 0
		var/boned = 0	// Tailbones just kind of pop into place

		if (src.type == /obj/item/organ/tail/monkey && !ismonkey(H))	// If we are trying to attach a monkey tail to a non-monkey
			src.human_getting_monkeytail = 1
			src.monkey_getting_humantail = 0
		else if(src.type != /obj/item/organ/tail/monkey && ismonkey(H))	// If we are trying to attach a non-monkey tail to a monkey
			src.human_getting_monkeytail = 0
			src.monkey_getting_humantail = 1
		else	// Tail is going to someone with a natively compatible butt-height
			src.human_getting_monkeytail = 0
			src.monkey_getting_humantail = 0

		if (!H.organHolder.tail && istype(H.mutantrace, /datum/mutantrace/skeleton))
			attachment_successful = 1 // Just slap that tailbone in place, its fine
			boned = 1	// No need to sew it up

			var/fluff = pick("slap", "shove", "place", "press", "jam")

			if(istype(src, /obj/item/organ/tail/bone))
				H.tri_message("<span class='alert'><b>[user]</b> [fluff][fluff == "press" ? "es" : "s"] the coccygeal coruna of [src] onto the apex of [H == user ? "[his_or_her(H)]" : "[H]'s"] sacrum![prob(1) ? " The tailbone wiggles happily." : ""]</span>",\
				user, "<span class='alert'>You [fluff] the coccygeal coruna of [src] onto the apex of [H == user ? "your" : "[H]'s"] sacrum![prob(1) ? " The tailbone wiggles happily." : ""]</span>",\
				H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][H == user && fluff == "press" ? "es" : "s"] the coccygeal coruna of [src] onto the apex of your sacrum![prob(1) ? " Your tailbone wiggles happily." : ""]</span>")
			else	// Any other tail
				H.tri_message("<span class='alert'><b>[user]</b> [fluff][fluff == "press" ? "es" : "s"] [src] onto the apex of [H == user ? "[his_or_her(H)]" : "[H]'s"] sacrum!</span>",\
				user, "<span class='alert'>You [fluff] [src] onto the apex of [H == user ? "your" : "[H]'s"] sacrum!</span>",\
				H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][H == user && fluff == "press" ? "es" : "s"] [src] onto the apex of your sacrum!</span>")

		else if (!H.organHolder.tail && H.organHolder.chest.op_stage >= 11.0 && src.can_attach_organ(H, user))
			attachment_successful = 1

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span class='alert'><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] up against [H == user ? "[his_or_her(H)]" : "[H]'s"] sacrum!</span>",\
			user, "<span class='alert'>You [fluff] [src] up against [user == H ? "your" : "[H]'s"] sacrum!</span>",\
			H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] up against your sacrum!</span>")

		if (attachment_successful)
			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "tail", 3.0)
			if (boned)
				H.organHolder.tail.op_stage = 0.0
			else
				H.organHolder.tail.op_stage = 11.0
			H.update_body()
			H.bioHolder.RemoveEffect(src.failure_ability)
			return 1

		return 0

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (src.get_damage() >= FAIL_DAMAGE && src.donor.mob_flags & SHOULD_HAVE_A_TAIL && !ischangeling(src.donor)) // Humans dont need tails to not be clumsy idiots
			donor.bioHolder.AddEffect(src.failure_ability, 0, 0, 0, 1)
		return 1

	on_removal()
		if (src.failure_ability && src.donor.mob_flags & SHOULD_HAVE_A_TAIL && !ischangeling(src.donor))
			src.donor.bioHolder.AddEffect(src.failure_ability, 0, 0, 0, 1)

	on_broken(var/mult = 1)
		if(prob(2) && src.donor.mutantrace)
			src.donor.change_misstep_chance(10)
			src.donor.bioHolder.AddEffect(failure_ability)

	proc/make_it_colorful()
		var/mob/living/carbon/human/M = src.donor
		if (M && ishuman(M))	// Get the colors here so they dont change later, ie reattached on someone else
			var/datum/appearanceHolder/aH = M.bioHolder.mobAppearance
			src.organ_color_1 = organ_fix_colors(aH.customization_first_color)
			src.organ_color_2 = organ_fix_colors(aH.customization_second_color)
		else	// Just throw some colors in there or something
			src.organ_color_1 = rgb(rand(50,190), rand(50,190), rand(50,190))
			src.organ_color_2 = rgb(rand(50,190), rand(50,190), rand(50,190))

		// Colorize (and build) organ item
		src.update_tail_icon()

/obj/item/organ/tail/monkey
	name = "monkey tail"
	desc = "A long, slender tail."
	icon_state = "tail-monkey"
	edible = 0

	New()
		..()
		src.organ_image_under_suit_1 = "monkey_under_suit"
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = "monkey_over_suit"

/obj/item/organ/tail/lizard
	name = "lizard tail"
	desc = "A long, scaled tail."
	icon_state = "tail-lizard"	// This is just the meat bit
	icon_piece_1 = "tail-lizard-detail-1"
	icon_piece_2 = "tail-lizard-detail-2"
	edible = 1	// ew

	New()
		..()
		// This tail accepts hairstyle colors!
		src.organ_image_under_suit_1 = "lizard_under_suit_1"
		src.organ_image_under_suit_2 = "lizard_under_suit_2"
		src.organ_image_over_suit = "lizard_over_suit"
		make_it_colorful()

/obj/item/organ/tail/cow
	name = "cow tail"
	desc = "A short, brush-like tail."
	icon_state = "tail-cow"
	edible = 0

	New()
		..()
		src.organ_image_under_suit_1 = "cow_under_suit"
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = "cow_over_suit_1"

/obj/item/organ/tail/wolf
	name = "wolf tail"
	desc = "A long, fluffy tail."
	icon_state = "tail-wolf"
	MAX_DAMAGE = 250	// Robust tail for a robust antag
	FAIL_DAMAGE = 240
	edible = 0

	New()
		..()
		src.organ_image_under_suit_1 = "wolf_under_suit"
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = "wolf_over_suit"

/obj/item/organ/tail/bone
	name = "tailbone"
	desc = "A short piece of bone."
	icon_state = "tail-bone"
	created_decal = null
	made_from = "bone"	// clak clak
	created_decal = null	// just a piece of bone
	edible = 0

	New()
		..()
		src.organ_image_under_suit_1 = null
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = null

/obj/item/organ/tail/seamonkey
	name = "seamonkey tail"
	desc = "A long, scaled tail."
	icon_state = "tail-seamonkey"
	edible = 0

	New()
		..()
		src.organ_image_under_suit_1 = "seamonkey_under_suit"
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = "seamonkey_over_suit"

/obj/item/organ/tail/cat
	name = "cat tail"
	desc = "A long, furry tail."
	icon_state = "tail-cat"
	edible = 0

	New()
		..()
		src.organ_image_under_suit_1 = "cat_under_suit"
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = "cat_over_suit"

/obj/item/organ/tail/roach
	name = "roach abdomen"
	desc = "A large insect behind."
	icon_state = "tail-roach"
	made_from = "chitin"
	edible = 1 // ew

	New()
		..()
		src.organ_image_under_suit_1 = "roach_under_suit"
		src.organ_image_under_suit_2 = null
		src.organ_image_over_suit = "roach_over_suit"
