/mob/living/carbon/human/welder
	real_name = "The Welder"
	var/trailing_blood = FALSE

	New()
		..()
		src.gender = NEUTER
		src.abilityHolder = new /datum/abilityHolder/welder(src)
		src.addAllAbilities()

		src.equip_new_if_possible(/obj/item/clothing/shoes/black, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/color, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/suit/apron/welder, slot_wear_suit)
		src.equip_new_if_possible(/obj/item/clothing/head/helmet/welding/unremovable, slot_head)
		src.equip_new_if_possible(/obj/item/clothing/gloves/black/welder, slot_gloves)

		src.see_in_dark = SEE_DARK_FULL
		src.sight |= SEE_SELF
		src.see_invisible = 16

	Life()
		var/turf/T = get_turf(src)
		if(!src.density && T && isrestrictedz(T.z))
			src.gib() //not taking any risks here with noclip

	initializeBioholder()
		src.bioHolder.mobAppearance.customization_first = new /datum/customization_style/none //pesky hair
		src.bioHolder.mobAppearance.customization_second = new /datum/customization_style/none
		src.bioHolder.mobAppearance.customization_third = new /datum/customization_style/none
		. = ..()

	proc

		incorporealize()
			var/turf/T = get_turf(src)
			if(src.density)
				if (T && isrestrictedz(T.z))
					src.show_text("You can't seem to turn incorporeal here.", "red")
					return
				src.setStatus("incorporeal", duration = INFINITE_STATUS)
				src.set_density(0)
				src.visible_message("<span class='alert'>[src] disappears!</span>")
				APPLY_MOB_PROPERTY(src, PROP_NEVER_DENSE, src)
				APPLY_MOB_PROPERTY(src, PROP_INVISIBILITY, src, INVIS_GHOST)
				APPLY_MOB_PROPERTY(src, PROP_NO_MOVEMENT_PUFFS, src)
				src.alpha = 160
				src.see_invisible = 16
				src.client.flying = 1


		corporealize()
			if(!src.density)
				var/turf/T = get_turf(src)
				src.delStatus("incorporeal")
				src.set_density(1)
				REMOVE_MOB_PROPERTY(src, PROP_INVISIBILITY, src)
				REMOVE_MOB_PROPERTY(src, PROP_NEVER_DENSE, src)
				REMOVE_MOB_PROPERTY(src, PROP_NO_MOVEMENT_PUFFS, src)
				src.alpha = 254
				src.see_invisible = 0
				new /obj/overlay/darkness_field(T, 3, radius = 2, max_alpha = 200)
				new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 3, radius = 2, max_alpha = 200)
				src.visible_message("<span class='alert'>[src] appears out of the shadows!</span>")
				src.client.flying = 0

		blood_trail()
			if(src.trailing_blood == FALSE)
				src.tracked_blood = list("bDNA" = src.blood_DNA, "btype" = src.blood_type, "count" = INFINITY)
				src.track_blood()
				trailing_blood = TRUE
			else
				src.tracked_blood = list("bDNA" = src.blood_DNA, "btype" = src.blood_type, "count" = 0)
				trailing_blood = FALSE

		summon_knife()
			var/list/knives = list()
			var/we_hold_it = 0
			var/mob/living/M = src

			if (!M)
				return 1

			if (M.getStatusDuration("stunned") > 0 || M.getStatusDuration("weakened") || M.getStatusDuration("paralysis") > 0 || !isalive(M) || M.restrained())
				boutput(M, __red("Not when you're incapacitated or restrained."))
				return 1

			for_by_tcl(K, /obj/item/kitchen/utensil/knife/welder)
				if (M.mind && M.mind.key == K.welder_key)
					if (K == M.find_in_hand(K))
						we_hold_it = 1
						continue
					if (!(K in knives))
						knives["[K.name] #[length(knives) + 1] [ismob(K.loc) ? "carried by [K.loc.name]" : "at [get_area(K)]"]"] += K

			switch (length(knives))
				if (-INFINITY to 0)
					if (we_hold_it != 0)
						boutput(M, __red("You're already holding your knife."))
						return 1 // No cooldown.
					else
						boutput(M, __red("You summon a new knife to your hands."))
						var/obj/item/kitchen/utensil/knife/welder/N = new /obj/item/kitchen/utensil/knife/welder(get_turf(M))
						N.welder_key = M.mind?.key
						M.put_in_hand_or_drop(N)
						return 0

				if (1)
					var/obj/item/kitchen/utensil/knife/welder/W
					for (var/C in knives)
						W = knives[C]
						break

					if (!W || !istype(W))
						boutput(M, __red("You are unable to summon your knife."))
						return 0

					src.send_knife_to_target(W)

				// There could be multiple, I suppose.
				if (2 to INFINITY)
					var/t1 = input("Please select a knife to summon", "Target Selection", null, null) as null|anything in knives
					if (!t1)
						return 1

					var/obj/item/kitchen/utensil/knife/welder/K2 = knives[t1]

					if (!M || !ismob(M) || !isliving(M || !M.mind))
						return 0
					if (!K2 || !istype(K2))
						boutput(M, __red("You are unable to summon your knife."))
						return 0
					if (M.getStatusDuration("stunned") > 0 || M.getStatusDuration("weakened") || M.getStatusDuration("paralysis") > 0 || !isalive(M) || M.restrained())
						boutput(M, __red("Not when you're incapacitated, restrained, or incorporeal."))
						return 0
					if (M.mind.key != K2.welder_key)
						boutput(M, __red("You are unable to summon your knife."))
						return 0

					src.send_knife_to_target(K2)

			return 0

		send_knife_to_target(var/obj/item/I)
			if(!src || !istype(src) || !I || !istype(I))
				return

			src.visible_message("<span class='alert'><b>The [I.name] is suddenly warped away!</b></span>")
			//put some effect here

			if(ismob(locate(src)))
				src.u_equip(I)
			if(istype(locate(I), /obj/item/storage))
				var/obj/item/storage/S = locate(I)
				var/datum/hud/storage/H = S.hud
				H.remove_object(I)
			if(istype(locate(I), /mob/living))
				var/mob/living/L = locate(I)
				L.drop_item(I)
			I.set_loc(get_turf(src))
			if(!src.put_in_hand(I))
				src.show_text("Knife summoned successfully. You can find it on the floor at your current location.", "blue")
			else
				src.show_text("Knife summoned successfully. You can find it in your hand.", "blue")
			return

		take_control(var/mob/living/carbon/human/M)
			if(!src || !istype(src) || !M || !istype(M))
				return

			boutput(M, "<span class='notice'>You get a splitting headache!</span>")
			M.change_misstep_chance(20)
			if(prob(33))
				M.emote("faint")
				M.setStatus("weakened", max(M.getStatusDuration("weakened"), 4 SECONDS))
			else
				M.emote("tremble")
			sleep(20 SECONDS)
			boutput(M, "<span class='notice'>The headache is getting worse, you should probably lay down!</span>")
			if(prob(50))
				M.emote("shudder")
			else
				M.emote("faint")
				M.setStatus("weakened", max(M.getStatusDuration("weakened"), 8 SECONDS))
			M.change_misstep_chance(30)
			sleep(10 SECONDS)
			M.change_misstep_chance(-50)
			boutput(M, "<span class='notice'>Oh god...</span>")
			M.emote("scream")
			M.emote("faint")
			M.setStatus("weakened", max(M.getStatusDuration("weakened"), 10 SECONDS))
			M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 10 SECONDS))
			sleep(8 SECONDS)

			M.visible_message("<span class='alert'>A brown apron and welding mask form out of the shadows on [M]!</span>")
			M.drop_from_slot(M.slot_head)
			M.drop_from_slot(M.slot_wear_suit)
			M.equip_new_if_possible(/obj/item/clothing/head/helmet/welding/unremovable, M.slot_head)
			M.equip_new_if_possible(/obj/item/clothing/suit/apron/welder, M.slot_wear_suit)
			M.equip_new_if_possible(/obj/item/clothing/shoes/black, M.slot_shoes)
			M.equip_new_if_possible(/obj/item/clothing/under/color/unremovable, M.slot_w_uniform) //maybe replace with a boiler suit or something
			M.equip_new_if_possible(/obj/item/kitchen/utensil/knife/welder/possessed, M.slot_r_hand)
			M.equip_new_if_possible(/obj/item/clothing/gloves/black/welder, slot_gloves)
			src.set_density(0)
			APPLY_MOB_PROPERTY(src, PROP_NEVER_DENSE, src)
			APPLY_MOB_PROPERTY(src, PROP_INVISIBILITY, src, INVIS_GHOST)
			APPLY_MOB_PROPERTY(src, PROP_NO_MOVEMENT_PUFFS, src)
			src.alpha = 160

			var/mob/dead/O = M.ghostize()
			boutput(O, "<span class='bold' style='color:red;font-size:150%'>You have been temporarily removed from your body!</span><br><b>Humans, Cyborgs, and other living beings will appear only as static silhouettes, and you should avoid interacting with them.</b><br><br>You can speak to your fellow Ghostdrones by talking normally (default: push T). You can talk over deadchat with other ghosts by starting your message with ';'.")
			if (O.mind)
				O.Browse(grabResource("html/welder_possession.html"),"window=welder_possession;size=600x440;title=Welder Possession")
			usr.mind.swap_with(M)
			sleep(45 SECONDS)
			M.mind.swap_with(usr)
			sleep(5 DECI SECONDS)
			O.mind.transfer_to(M)


			for(var/obj/item/clothing/suit/apron/welder/A in M)
				qdel(A)
			for(var/obj/item/clothing/head/helmet/welding/unremovable/U in M)
				qdel(U)
			for(var/obj/item/clothing/gloves/black/welder/G in M)
				qdel(G)
			for(var/obj/item/kitchen/utensil/knife/welder/possessed/P in M)
				P.visible_message("<span class='alert'><b>The [P.name] crumbles into ash!</b></span>")
				qdel(P)
			M.equip_new_if_possible(/obj/item/clothing/head/helmet/welding/postpossession, M.slot_head)
			M.equip_new_if_possible(/obj/item/clothing/suit/apron/welder/postpossession, M.slot_wear_suit)
			M.equip_new_if_possible(/obj/item/clothing/gloves/black, slot_gloves)

		regenerate()
			src.full_heal() //this won't turn out badly

		addAllAbilities()
			src.addAbility(/datum/targetable/welder/incorporeal)
			src.addAbility(/datum/targetable/welder/corporeal)
			src.addAbility(/datum/targetable/welder/blood_trail)
			src.addAbility(/datum/targetable/welder/summon_knife)
			src.addAbility(/datum/targetable/welder/take_control)
			src.addAbility(/datum/targetable/welder/regenerate)

		updateButtons()
			abilityHolder.updateButtons()


/datum/abilityHolder/welder
	usesPoints = 0
	regenRate = 0
	tabName = "Abilities"
	cast_while_dead = 0

ABSTRACT_TYPE(/datum/targetable/welder)
/datum/targetable/welder
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "template" //change me
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/welder

/datum/targetable/welder/incorporeal
	name = "Incorporealize"
	desc = "Become a ghost, capable of moving through walls."
	icon_state = "template"
	targeted = 0
	cooldown = 30 SECONDS

	cast()
		if(..())
			return 1

		var/mob/living/carbon/human/welder/W = src.holder.owner
		if(usr.client)
			for (var/mob/living/L in view(usr.client.view, usr))
				if (isalive(L) && L.sight_check(1) && L.ckey != usr.ckey)
					usr.show_text("You can only use that when nobody can see you!", "red")
					return 1
		return W.incorporealize()

/datum/targetable/welder/corporeal
	name = "Corporealize"
	desc = "Manifest your being, allowing you to interact with the world."
	icon_state = "template"
	targeted = 0
	cooldown = 30 SECONDS

	cast()
		if(..())
			return 1

		var/mob/living/carbon/human/welder/W = src.holder.owner
		return W.corporealize()

/datum/targetable/welder/blood_trail
	name = "Blood Trail"
	desc = "Begin trailing blood behind you, for the spook value."
	icon_state = "template"
	targeted = 0
	cooldown = 5 SECONDS

	cast()
		if(..())
			return 1

		var/mob/living/carbon/human/welder/W = src.holder.owner
		return W.blood_trail()

/datum/targetable/welder/summon_knife
	name = "Summon Knife"
	desc = "Summon your knife to your active hand."
	icon_state = "template"
	targeted = 0
	cooldown = 15 SECONDS

	cast()
		if(..())
			return 1

		var/mob/living/carbon/human/welder/W = src.holder.owner
		return W.summon_knife()

/datum/targetable/welder/take_control
	name = "Possess"
	desc = "Possess a target temporarily."
	icon_state = "template"
	targeted = 1
	target_anything = 1
	cooldown = 3 MINUTES

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			var/mob/living/carbon/human/welder/W = src.holder.owner
			if(isdead(H))
				boutput(usr, "<span class='alert'>You cannot possess a corpse.</span>")
				return 1
			if(H.client)
				boutput(usr, "<b>You begin to possess [H].</b>")
				usr.playsound_local(usr.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
				H.playsound_local(H.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
				return W.take_control(H)
			else
				boutput(usr, "<b>The target must have a consciousness to be possessed.</b>")
				return 1
		else
			boutput(usr, "<span class='alert'>You cannot possess a non-human.</span>")
			return 1

/datum/targetable/welder/regenerate
	name = "Regenerate"
	desc = "Regenerate your body, and remove all restraints."
	icon_state = "template"
	targeted = 0
	cooldown = 90 SECONDS

	cast()
		if(..())
			return 1

		var/mob/living/carbon/human/welder/W = src.holder.owner
		return W.regenerate()
