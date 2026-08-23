/mob/living/carbon/human/normal/tutorial_help
	New()
		. = ..()
		src.real_name = "The Clown You Help"
		src.equip_new_if_possible(/obj/item/clothing/mask/clown_hat/blue, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/clown/blue, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/clown_shoes/blue, SLOT_SHOES)
		var/obj/item/card/id/clown/clown_id = new()
		clown_id.registered = "The Clown You Help"
		clown_id.assignment = "Clown"
		clown_id.update_name()
		src.UpdateName()
		src.equip_if_possible(clown_id, SLOT_WEAR_ID)
		src.bioHolder?.AddEffect("accent_comic", innate = TRUE)

		SPAWN (0.3 SECONDS)
			src?.say("Owie! I broke my funny bone!")

/mob/living/carbon/human/normal/tutorial_disarm
	New()
		. = ..()
		src.real_name = "The Clown You Disarm"
		src.equip_new_if_possible(/obj/item/clothing/mask/clown_hat/yellow, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/clown/yellow, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/clown_shoes/yellow, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/instrument/bikehorn, SLOT_L_HAND)
		var/obj/item/card/id/clown/clown_id = new()
		clown_id.registered = "The Clown You Disarm"
		clown_id.assignment = "Clown"
		clown_id.update_name()
		src.UpdateName()
		src.equip_if_possible(clown_id, SLOT_WEAR_ID)
		src.bioHolder?.AddEffect("accent_comic", innate = TRUE)

		SPAWN (0.5 SECONDS)
			if (!QDELETED(src))
				src.say("We're gonna have a honkin' good time!")
		SPAWN (1 SECOND)
			if (!QDELETED(src))
				src.l_hand?.AttackSelf() // honk

/mob/living/carbon/human/normal/tutorial_grab
	New()
		. = ..()
		src.real_name = "The Clown You Grab"
		src.equip_new_if_possible(/obj/item/clothing/mask/clown_hat/purple, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/clown/purple, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/clown_shoes/purple, SLOT_SHOES)
		var/obj/item/card/id/clown/clown_id = new()
		clown_id.registered = "The Clown You Grab"
		clown_id.assignment = "Clown"
		clown_id.update_name()
		src.UpdateName()
		src.equip_if_possible(clown_id, SLOT_WEAR_ID)
		src.bioHolder?.AddEffect("accent_comic", innate = TRUE)
		src.bioHolder?.AddEffect("sims_stinky", innate = TRUE)

		SPAWN (0.7 SECONDS)
			if (!QDELETED(src))
				src.say("Do I smell funny?")

/// Newbee Tutorial mob; the clown you kill to Win the Tutorial
/mob/living/carbon/human/normal/tutorial_kill
	/// Owner of the tutorial, assigned in the step that spawns this mob
	var/mob/tutorial_owner

	New()
		. = ..()
		src.real_name = "The Clown You Kill"
		src.equip_new_if_possible(/obj/item/clothing/mask/clown_hat, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/clown, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/clown_shoes, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/storage/fanny/funny, SLOT_BELT)
		src.equip_new_if_possible(/obj/item/instrument/bikehorn, SLOT_L_HAND)
		src.equip_new_if_possible(/obj/item/bananapeel, SLOT_R_HAND)
		var/obj/item/card/id/clown/clown_id = new()
		clown_id.registered = "The Clown You Kill"
		clown_id.assignment = "Clown"
		clown_id.update_name()
		src.equip_if_possible(clown_id, SLOT_WEAR_ID)
		src.UpdateName()
		src.bioHolder?.AddEffect("accent_comic", innate = TRUE)
		src.AddComponent(/datum/component/health_maptext)

		SPAWN (0.2 SECONDS)
			if (!QDELETED(src))
				src.l_hand?.AttackSelf() // honk

		SPAWN (0.3 SECONDS)
			if (!QDELETED(src))
				src.say("Honk honk!")

		SPAWN (1.7 SECONDS)
			if (!QDELETED(src))
				src.l_hand?.AttackSelf() // honk

		SPAWN (2.8 SECONDS)
			if (!QDELETED(src))
				src.say("Was that banana a-peel-ing?")

	death(gibbed)
		if (tutorial_owner && istype(src.lastattacker?.deref(), /mob/living/critter/spider))
			src.tutorial_owner.unlock_medal("On My Own (Eight) Space Legs", TRUE)
		. = ..()
