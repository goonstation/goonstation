/obj/item/reagent_containers/applicator
	name = "chemical applicator"
	desc = "Applies some units of a thing topically."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spacelipstick0"
	incompatible_with_chem_dispensers = TRUE
	rand_pos = 1
	flags = TABLEPASS | SUPPRESSATTACK
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	object_flags = NO_GHOSTCRITTER
	initial_volume = 30

	var/infinite = FALSE
	var/verbiage_user = "apply"
	var/verbiage_viewer = "applies"

	afterattack(atom/target, mob/user, reach, params)
		. = ..()
		user.lastattacked = get_weakref(target)
		if (!src.can_apply())
			return
		if (src.reagents?.total_volume || src.infinite)
			user.visible_message(
				SPAN_NOTICE("[user] [src.verbiage_viewer] some [src.reagents.get_master_reagent_name()] onto [target]."),
				SPAN_NOTICE("You [src.verbiage_user] some [src.reagents.get_master_reagent_name()] onto [target]."),
			)
			src.reagents.reaction(target, TOUCH, min(src.amount_per_transfer_from_this, src.reagents.total_volume), paramslist = list("nopenetrate"))
			if (!src.infinite)
				src.reagents.remove_any(src.amount_per_transfer_from_this)
			src.UpdateIcon()
		else
			boutput(user, SPAN_ALERT("[src] is empty!"))

	proc/can_apply()
		return TRUE

/obj/item/reagent_containers/applicator/stick
	icon_state = "spacelipstick0"
	var/open = FALSE
	var/image/image_stick = null

	New(loc, new_initial_reagents)
		. = ..()
		UpdateIcon()

	update_icon()
		src.icon_state = "spacelipstick[src.open]"
		if (src.open)
			ENSURE_IMAGE(src.image_stick, src.icon, "spacelipstick")
			src.image_stick.color = src.reagents.get_average_rgb()
			src.UpdateOverlays(src.image_stick, "stick")
		else
			src.UpdateOverlays(null, "stick")

	attack_self(var/mob/user)
		src.open = !src.open
		src.UpdateIcon()

	can_apply()
		return src.open

/obj/item/reagent_containers/applicator/stick/glue
	name = "glue stick"
	desc = "It's a stick. Of glue. Glue stick."
	initial_reagents = list("spaceglue" = 30)

/obj/item/reagent_containers/applicator/stick/glue/infinite
	name = "really big glue stick"
	desc = "It's a stick. Of glue. Glue stick. This one looks really long."
	infinite = TRUE

/obj/item/reagent_containers/applicator/brush
	icon_state = "makeup-brush"
	verbiage_user = "brush"
	verbiage_viewer = "brushes"

/obj/item/reagent_containers/applicator/brush/silver_nitrate
	name = "fingerprint duster"
	desc = "Helps reveal fingerprint fragments that can be recovered from gloveprints."
	amount_per_transfer_from_this = 1
	initial_reagents = list("silver_nitrate" = 30)

/obj/item/reagent_containers/applicator/condiment
	name = "shaker"
	desc = "A little bottle for shaking things onto other things."
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = "shaker"
	amount_per_transfer_from_this = 2

	afterattack(atom/target, mob/user, reach, params)
		if (istype(target, /obj/item/reagent_containers/food))
			src.reagents.trans_to(target, src.amount_per_transfer_from_this)
			user.visible_message(
				SPAN_NOTICE("[user] [src.verbiage_viewer] some [src.reagents.get_master_reagent_name()] onto [target]."),
				SPAN_NOTICE("You [src.verbiage_user] some [src.reagents.get_master_reagent_name()] onto [target]."),
			)
			return
		. = ..()

	attack(mob/target, mob/user, def_zone, is_special, params)
		if (src.reagents.total_volume <= 0)
			boutput(user, SPAN_ALERT("[src] is empty!"))
			return
		else
			return ..()


	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/reagent_containers/))
			var/my_reagent_id = src.reagents.get_master_reagent_id()
			if (I.reagents.has_reagent(my_reagent_id) && I.reagents.get_reagent_amount(my_reagent_id))
				var/amount_to_transfer = max(src.reagents.maximum_volume - src.reagents.total_volume, I.reagents.get_reagent_amount(my_reagent_id))
				boutput(user, SPAN_NOTICE("You refill [src]"))
				src.reagents.add_reagent(my_reagent_id, amount_to_transfer)
				I.reagents.remove_reagent(my_reagent_id, amount_to_transfer)
				return
			else
				user.show_text("There isn't enough [src.reagents.get_master_reagent_name()] in here to refill [src]!", "red")
				return
		else
			return ..()

/obj/item/reagent_containers/applicator/condiment/shaker
	verbiage_user = "shake"
	verbiage_viewer = "shakes"

	proc/headwear_check(mob/user, mob/living/carbon/human/target)
		if ((target.head && target.head.c_flags & COVERSEYES) || (target.wear_mask && target.wear_mask.c_flags & COVERSEYES) || (target.glasses && target.glasses.c_flags & COVERSEYES))
			target.tri_message(user, SPAN_ALERT("<b>[user]</b> uselessly [src.verbiage_viewer]s some [src.reagents.get_master_reagent_name()] onto [target]'s headgear!"),\
				SPAN_ALERT("[target == user ? "You uselessly [src.verbiage_user]" : "[user] uselessly [src.verbiage_viewer]"] some [src.reagents.get_master_reagent_name()] onto your headgear! Okay then."),\
				SPAN_ALERT("You uselessly [src.verbiage_user] some [src.reagents.get_master_reagent_name()] onto [user == target ? "your" : "[target]'s"] headgear![user == target ? " Okay then." : null]"))
			return FALSE
		return TRUE

	salt
		name = "salt shaker"
		desc = "A little bottle for shaking things onto other things. It has some salt in it."
		icon_state = "shaker-salt"
		initial_reagents = list("salt" = 30)

		attack(mob/target, mob/user, def_zone, is_special, params)
			if (src.reagents.total_volume <= 0)
				boutput(user, SPAN_ALERT("[src] is empty!"))
				return
			if (ishuman(target))
				var/mob/living/carbon/human/H = target
				if (!src.headwear_check(user, H))
					return
				logTheThing(LOG_COMBAT, user, "uses [src] on [constructTarget(H, "combat")] at [log_loc(user)].")
				H.tri_message(user, SPAN_ALERT("<b>[user]</b> [src.verbiage_viewer] something into [H]'s eyes!"),\
					SPAN_ALERT("[H == user ? "You [src.verbiage_user]" : "[user] [src.verbiage_viewer]"] some salt into your eyes! <B>FUCK THAT STINGS!</B>"),\
					SPAN_ALERT("You [src.verbiage_user] some salt into [user == H ? "your" : "[H]'s"] eyes![user == H ? " <B>FUCK THAT STINGS!</B>" : null]"))
				random_brute_damage(user, 1)
				H.change_eye_blurry(rand(10, 16))
				H.take_eye_damage(rand(12, 16))
				src.reagents.remove_any(2)
			else if (istype(target, /mob/living/critter/small_animal/slug))
				target.visible_message(SPAN_ALERT("<b>[user]</b> [src.verbiage_viewer] some salt onto [target] and it shrivels up!"),\
				SPAN_ALERT("<b>OH GOD THE SALT [pick("IT BURNS","HOLY SHIT THAT HURTS","JESUS FUCK YOU'RE DYING")]![pick("","!","!!")]</b>"))
				target.TakeDamage(null, 15, 15)
				src.reagents.remove_any(2)
			else
				. = ..()

	pepper
		name = "pepper shaker"
		desc = "A little bottle for shaking things onto other things. It has some pepper in it."
		icon_state = "shaker-pepper"
		initial_reagents = list("pepper" = 30)

		attack(mob/target, mob/user, def_zone, is_special, params)
			if (src.reagents.total_volume <= 0)
				boutput(user, SPAN_ALERT("[src] is empty!"))
				return
			if (ishuman(target))
				var/mob/living/carbon/human/H = target
				if (!src.headwear_check(user, H))
					return
				H.tri_message(user, SPAN_ALERT("<b>[user]</b> [src.verbiage_viewer] something onto [H]'s nose!"),\
					SPAN_ALERT("[H == user ? "You [src.verbiage_user]" : "[user] [src.verbiage_viewer]"] some pepper onto your nose! <B>Why?!</B>"),\
					SPAN_ALERT("You [src.verbiage_user] some pepper onto [user == H ? "your" : "[H]'s"] nose![user == H ? " <B>Why?!</B>" : null]"))
				H.emote("sneeze")
				src.reagents.remove_any(2)
				for (var/i = 1, i <= 30, i++) // it was like this when i found it
					SPAWN(50*i)
						if (prob(20))
							H?.emote("sneeze")
				return
			else
				. = ..()

/obj/item/reagent_containers/applicator/condiment/bottle
	verbiage_user = "squirt"
	verbiage_viewer = "squirts"

	ketchup
		name = "ketchup bottle"
		desc = "A little bottle for putting condiments on stuff. It has some ketchup in it."
		icon_state = "bottle-ketchup"
		initial_reagents = list("ketchup" = 30)

	mustard
		name = "mustard bottle"
		desc = "A little bottle for putting condiments on stuff. It has some mustard in it."
		icon_state = "bottle-mustard"
		initial_reagents = list("mustard" = 30)

	barbecue
		name = "barbecue sauce bottle"
		desc = "A little bottle for putting condiments on stuff. It has some barbecue sauce in it."
		icon_state = "bottle-barbecue"
		initial_reagents = list("barbecue_sauce" = 30)

	hotsauce
		name = "hot sauce bottle"
		desc = "A little bottle for putting condiments on stuff. This one is dangerously spicy!"
		icon_state = "bottle-barbecue" // TODO: hot sauce bottle sprites
		initial_reagents = list("capsaicin" = 30)

		New(loc, new_initial_reagents)
			. = ..()
			src.name = "\improper [pick("Tabasco", "Sriracha", "Cholula", "Tapatío")] sauce bottle"
