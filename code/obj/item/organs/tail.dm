/// Severed tail images go in 'icons/obj/surgery.dmi'
/// on-mob tail images are defined by organ_image_icon
/// both severed and on-mob tail icon_states are defined by just icon_state
/// try to keep the names the same, or everything breaks
/obj/item/organ/tail
	name = "tail"
	organ_name = "tail"
	organ_holder_name = "tail"
	organ_holder_location = "chest"	// chest-ish
	organ_holder_required_op_stage = 11
	edible = 1
	organ_image_icon = 'icons/mob/werewolf.dmi' // please keep your on-mob tail icon_states with the rest of your mob's sprites
	icon_state = "tail-wolf"
	made_from = "flesh"
	var/tail_num = TAIL_NONE
	var/colorful = FALSE /// if we need to colorize it
	var/multipart_icon = FALSE /// if we need to run update_tail_icon
	var/icon_piece_1 = null	// For setting up the icon if its in multiple pieces
	var/icon_piece_2 = null	// Only modifies the dropped icon
	var/failure_ability = "clumsy"	/// The organ failure ability associated with this organ.
	var/human_getting_monkeytail = FALSE	/// If a human's getting a monkey tail
	var/monkey_getting_humantail = FALSE	/// If a monkey's getting a human tail
	var/clothing_image_icon = null	/// if the tail has clothing sprites, set this to the appropriate icon
	// vv these get sent to update_body(). no sense having it calculate all this shit multiple times
	var/image/tail_image_1
	var/image/tail_image_2
	var/image/tail_image_oversuit

	New()
		..()
		if(src.colorful) // Set us some colors
			colorize_tail()
		else
			build_mob_tail_image()
			update_tail_icon()

	disposing()
		if(holder)
			on_removal()
			holder.tail = null
			holder.donor.update_body()
		. = ..()

	proc/colorize_tail(var/datum/appearanceHolder/AHL)
		if(src.colorful)
			if (AHL && istype(AHL, /datum/appearanceHolder))
				src.organ_color_1 = AHL.s_tone
				src.organ_color_2 = AHL.customization_second_color
				src.donor_AH = AHL
			else if (src.donor && ishuman(src.donor))	// Get the colors here so they dont change later, ie reattached on someone else
				src.organ_color_1 = fix_colors(src.donor_AH.customization_first_color)
				src.organ_color_2 = fix_colors(src.donor_AH.customization_second_color)
			else	// Just throw some colors in there or something
				src.organ_color_1 = rgb(rand(50,190), rand(50,190), rand(50,190))
				src.organ_color_2 = rgb(rand(50,190), rand(50,190), rand(50,190))
		build_mob_tail_image()
		update_tail_icon()

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Overrides parent function to handle special case for tails. */
		var/mob/living/carbon/human/H = M

		var/attachment_successful = 0
		var/boned = 0	// Tailbones just kind of pop into place

		if (src.type == /obj/item/organ/tail/monkey && !ismonkey(H))	// If we are trying to attach a monkey tail to a non-monkey
			src.human_getting_monkeytail = TRUE
			src.monkey_getting_humantail = FALSE
		else if(src.type != /obj/item/organ/tail/monkey && ismonkey(H))	// If we are trying to attach a non-monkey tail to a monkey
			src.human_getting_monkeytail = FALSE
			src.monkey_getting_humantail = TRUE
		else	// Tail is going to someone with a natively compatible butt-height
			src.human_getting_monkeytail = FALSE
			src.monkey_getting_humantail = FALSE

		if (!H.organHolder.tail && H.mob_flags & IS_BONEY)
			attachment_successful = 1 // Just slap that tailbone in place, its fine
			boned = 1	// No need to sew it up

			var/fluff = pick("slap", "shove", "place", "press", "jam")

			user.tri_message(H, "<span class='alert'><b>[user]</b> [fluff][fluff == "press" ? "es" : "s"] [src] onto the apex of [H == user ? "[his_or_her(H)]" : "[H]'s"] sacrum!</span>",\
				"<span class='alert'>You [fluff] [src] onto the apex of [H == user ? "your" : "[H]'s"] sacrum!</span>",\
				"<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][H == user && fluff == "press" ? "es" : "s"] [src] onto the apex of your sacrum!</span>")

		else if (!H.organHolder.tail && H.organHolder.chest.op_stage >= 11.0 && src.can_attach_organ(H, user))
			attachment_successful = 1

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			user.tri_message(H, "<span class='alert'><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] up against [H == user ? "[his_or_her(H)]" : "[H]'s"] sacrum!</span>",\
				"<span class='alert'>You [fluff] [src] up against [user == H ? "your" : "[H]'s"] sacrum!</span>",\
				"<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] up against your sacrum!</span>")

		if (attachment_successful)
			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "tail", 3.0)
			if (boned)
				H.organHolder.tail.op_stage = 0
			else
				H.organHolder.tail.op_stage = 11
			src.build_mob_tail_image()
			H.update_body()
			H.bioHolder.RemoveEffect(src.failure_ability)
			return 1

		return 0
	// Tail-loss clumsy-giving is handled in organ_holder's handle_missing
	on_life(var/mult = 1)
		if (!..())
			return 0
		if (src.get_damage() >= fail_damage && probmult(src.get_damage() * 0.2))
			src.breakme()
		return 1

	on_broken(var/mult = 1)
		if(src.get_damage() < fail_damage)
			src.unbreakme()
		if(ischangeling(src.holder.donor))
			return
		else if(src.failure_ability && src.holder?.donor?.mob_flags & SHOULD_HAVE_A_TAIL)
			if(src.holder?.donor?.reagents?.get_reagent_amount("ethanol") > 50) // Drunkenness counteracts un-tailedness
				src.holder?.donor?.bioHolder?.RemoveEffect(src.failure_ability)
			else
				src.holder?.donor?.change_misstep_chance(10)
				src.holder?.donor?.bioHolder?.AddEffect(src.failure_ability, 0, 0, 0, 1)

	unbreakme()
		if(..())
			src.holder?.donor?.bioHolder?.RemoveEffect(src.failure_ability)


	// builds the mob tail image, the one that gets displayed on the mob when attached
	proc/build_mob_tail_image() // lets mash em all into one image with overlays n shit, like the head, but on the ass
		var/humonkey = src.human_monkey_tail_interchange(src.organ_image_under_suit_1, src.human_getting_monkeytail, src.monkey_getting_humantail)
		var/image/tail_temp_image = image(icon=src.organ_image_icon, icon_state=humonkey, layer = MOB_TAIL_LAYER1)
		if (src.organ_color_1)
			tail_temp_image.color = src.organ_color_1
		src.tail_image_1 = tail_temp_image

		if(src.organ_image_under_suit_2)
			humonkey = src.human_monkey_tail_interchange(src.organ_image_under_suit_2, src.human_getting_monkeytail, src.monkey_getting_humantail)
			tail_temp_image = image(icon=src.organ_image_icon, icon_state=humonkey, layer = MOB_TAIL_LAYER2)
			if (src.organ_color_2)
				tail_temp_image.color = src.organ_color_2
			src.tail_image_2 = tail_temp_image

		if(src.organ_image_over_suit)
			humonkey = src.human_monkey_tail_interchange(src.organ_image_over_suit, src.human_getting_monkeytail, src.monkey_getting_humantail)
			tail_temp_image = image(icon=src.organ_image_icon, icon_state=humonkey, layer = MOB_OVERSUIT_LAYER1)
			if (src.organ_color_1)
				tail_temp_image.color = src.organ_color_1
			src.tail_image_oversuit = tail_temp_image

	proc/human_monkey_tail_interchange(var/tail_iconstate as text, var/human_getting_monkey_tail as num, var/monkey_getting_human_tail as num)
		if (!tail_iconstate || (human_getting_monkey_tail && monkey_getting_human_tail))
			logTheThing(LOG_DEBUG, usr, "([src])HumanMonkeyTailInterchange fucked up. tail_iconstate = [tail_iconstate], [human_getting_monkey_tail] && [monkey_getting_human_tail]. call lagg")
			return null	// Something went wrong
		if (!human_getting_monkey_tail && !monkey_getting_human_tail)	// tail's going to the right place
			return tail_iconstate	// Send it as-is
		var/output_this_string
		output_this_string = tail_iconstate + (human_getting_monkey_tail ? "-human" : "-monkey")
		return output_this_string

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


/obj/item/organ/tail/monkey
	name = "monkey tail"
	desc = "A long, slender tail."
	icon_state = "tail-monkey"
	organ_image_icon = 'icons/mob/monkey.dmi'
	clothing_image_icon = 'icons/mob/monkey/tail.dmi'
	tail_num = TAIL_MONKEY
	organ_image_under_suit_1 = "monkey_under_suit"
	organ_image_under_suit_2 = null
	organ_image_over_suit = "monkey_over_suit"

/obj/item/organ/tail/lizard
	name = "lizard tail"
	desc = "A long, scaled tail."
	icon_state = "tail-lizard"	// This is just the meat bit
	icon_piece_1 = "tail-lizard-detail-1"
	icon_piece_2 = "tail-lizard-detail-2"
	organ_image_icon = 'icons/mob/lizard.dmi'
	clothing_image_icon = 'icons/mob/lizard/tail.dmi'
	organ_image_under_suit_1 = "lizard_under_suit_1"
	organ_image_under_suit_2 = "lizard_under_suit_2"
	organ_image_over_suit = "lizard_over_suit"
	tail_num = TAIL_LIZARD
	colorful = TRUE
	multipart_icon = TRUE

/obj/item/organ/tail/cow
	name = "cow tail"
	desc = "A short, brush-like tail."
	icon_state = "tail-cow"
	organ_image_icon = 'icons/mob/cow.dmi'
	tail_num = TAIL_COW
	organ_image_under_suit_1 = "cow_under_suit"
	organ_image_under_suit_2 = null
	organ_image_over_suit = "cow_over_suit_1"	// just the tail, no nose

/obj/item/organ/tail/pug
	name = "pug tail"
	desc = "A rather stubby tail, covered in wiry hair."
	icon_state = "tail-pug"
	organ_image_icon = 'icons/mob/pug/fawn.dmi'
	tail_num = TAIL_PUG
	organ_image_under_suit_1 = "pug_under_suit"
	organ_image_under_suit_2 = null
	organ_image_over_suit = "pug_over_suit"

/obj/item/organ/tail/wolf
	name = "wolf tail"
	desc = "A long, fluffy tail."
	icon_state = "tail-wolf"
	organ_image_icon = 'icons/mob/werewolf.dmi'
	max_damage = 250	// Robust tail for a robust antag
	fail_damage = 240
	tail_num = TAIL_WEREWOLF
	organ_image_under_suit_1 = "wolf_under_suit"
	organ_image_under_suit_2 = null
	organ_image_over_suit = "wolf_over_suit"

/obj/item/organ/tail/monkey/seamonkey
	name = "seamonkey tail"
	desc = "A long, pink tail."
	icon_state = "tail-seamonkey"
	organ_image_icon = 'icons/mob/seamonkey.dmi'
	tail_num = TAIL_SEAMONKEY
	organ_image_under_suit_1 = "seamonkey_under_suit"
	organ_image_under_suit_2 = null
	organ_image_over_suit = "seamonkey_over_suit"

/obj/item/organ/tail/cat
	name = "cat tail"
	desc = "A long, furry tail."
	icon_state = "tail-cat"
	organ_image_icon = 'icons/mob/cat.dmi'
	tail_num = TAIL_CAT
	organ_image_under_suit_1 = "cat_under_suit"
	organ_image_under_suit_2 = null
	organ_image_over_suit = "cat_over_suit"

/obj/item/organ/tail/roach
	name = "roach abdomen"
	desc = "A large insect behind."
	icon_state = "tail-roach"
	organ_image_icon = 'icons/mob/roach.dmi'
	tail_num = TAIL_ROACH
	organ_image_under_suit_1 = "roach_under_suit"
	organ_image_under_suit_2 = null
	organ_image_over_suit = "roach_over_suit"
	colorful = TRUE

