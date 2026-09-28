/obj/item/remote/chameleon
	name = "chameleon outfit remote"
	desc = "A remote control that allows you to change an entire set of chameleon clothes, all at once."
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	w_class = W_CLASS_SMALL
	HELP_MESSAGE_OVERRIDE({"Use the remote in hand to change the appearance of all chameleon clothing.
							Right click on a piece of chameleon clothing and use <b>"Change appearance"</b> to change the appearance of that specific piece.
							Use a piece of clothing on the corresponding chameleon clothing piece to add that appearance to the list of possible appearances.
							Use the remote in hand and select the <b>"New Outfit Set"</b> option to create a new set of clothing."})

	var/obj/item/storage/backpack/chameleon/connected_backpack = null
	var/obj/item/clothing/under/chameleon/connected_jumpsuit = null
	var/obj/item/clothing/head/chameleon/connected_hat = null
	var/obj/item/clothing/suit/chameleon/connected_suit = null
	var/obj/item/clothing/glasses/chameleon/connected_glasses = null
	var/obj/item/clothing/shoes/chameleon/connected_shoes = null
	var/obj/item/storage/belt/chameleon/connected_belt = null
	var/obj/item/clothing/gloves/chameleon/connected_gloves = null
	var/list/outfit_choices = list()

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_outfit_choices)))
			var/datum/chameleon_outfit_choices/P = new U
			src.outfit_choices += P
		return

	attack_self(mob/user)
		if (isliving(user))
			var/datum/chameleon_outfit_choices/which = tgui_input_list(user, "Change the chameleon outfit to which set?", "Chameleon Outfit Remote", outfit_choices)

			if(!which)
				return

			if (which.function == "delete_outfit")
				var/datum/chameleon_outfit_choices/outfit_to_delete = tgui_input_list(user, "Delete which chameleon outfit set?", "Chameleon Outfit Remote", outfit_choices)

				if(!outfit_to_delete)
					return
				if(outfit_to_delete.function)
					boutput(user, SPAN_ALERT("The chameleon outfit prevents you from deleting this function!"))
					return

				src.outfit_choices -= outfit_to_delete

				boutput(user, SPAN_NOTICE("Outfit set deleted!"))
				return

			if(which.function == "new_outfit")
				var/name = tgui_input_text(user, "Name of new outfit set:", "Chameleon Outfit Remote")
				if(!name)
					return
				for(var/datum/chameleon_outfit_choices/P in src.outfit_choices)
					if(P.name == name)
						boutput(user, SPAN_ALERT("That outfit set name is already saved in the chameleon outfit banks!"))
						return

				var/datum/chameleon_outfit_choices/P = new /datum/chameleon_outfit_choices(src)
				P.name = name
				if(connected_jumpsuit)
					P.jumpsuit_type = connected_jumpsuit.current_choice
				if(connected_hat)
					P.hat_type = connected_hat.current_choice
				if(connected_suit)
					P.suit_type = connected_suit.current_choice
				if(connected_glasses)
					P.glasses_type = connected_glasses.current_choice
				if(connected_shoes)
					P.shoes_type = connected_shoes.current_choice
				if(connected_gloves)
					P.gloves_type = connected_gloves.current_choice
				if(connected_belt)
					P.belt_type = connected_belt.current_choice
				if(connected_backpack)
					P.backpack_type = connected_backpack.current_choice
				src.outfit_choices += P

				boutput(user, SPAN_NOTICE("New outfit set created!"))
				return

			if(connected_jumpsuit || which.jumpsuit_type)
				connected_jumpsuit.change_outfit(which.jumpsuit_type)

			if(connected_hat || which.hat_type)
				connected_hat.change_outfit(which.hat_type)

			if(connected_suit || which.suit_type)
				connected_suit.change_outfit(which.suit_type)

			if(connected_glasses || which.glasses_type)
				connected_glasses.change_outfit(which.glasses_type)

			if(connected_shoes || which.shoes_type)
				connected_shoes.change_outfit(which.shoes_type)

			if(connected_gloves || which.gloves_type)
				connected_gloves.change_outfit(which.gloves_type)

			if(connected_belt || which.belt_type)
				connected_belt.change_outfit(which.belt_type)

			if(connected_backpack || which.backpack_type)
				connected_backpack.change_outfit(which.backpack_type)
