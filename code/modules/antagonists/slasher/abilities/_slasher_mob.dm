/mob/living/carbon/human/slasher
	real_name = "The Slasher"
	var/trailing_blood = FALSE
	var/slasher_key
	var/last_bdna = null
	var/last_btype = null

	New(loc)
		..()
		src.gender = MALE
		src.abilityHolder = new /datum/abilityHolder/slasher(src)
		src.addAllAbilities()

		src.equip_new_if_possible(/obj/item/clothing/shoes/slasher_shoes/noslip, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/clothing/under/color/unremovable, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/suit/apron/slasher, SLOT_WEAR_SUIT)
		src.equip_new_if_possible(/obj/item/clothing/mask/gas/emergency/unremovable, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/gloves/black/slasher, SLOT_GLOVES)

		src.see_invisible = INVIS_GHOST
		src.bioHolder.AddEffect("breathless", 0, 0, 0, 1)
		src.bioHolder.AddEffect("rad_resist", 0, 0, 0, 1)
		src.bioHolder.AddEffect("detox", 0, 0, 0, 1)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "slasher_stun_resistance", 80)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "slasher_stun_resistance", 80)
		START_TRACKING
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_SELF_HARM, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_AI_UNTRACKABLE, src)

	Life()
		..()
		if(src.hasStatus("incorporeal") && inrestrictedz(src))
			src.corporealize()
			src.set_loc(pick_landmark(LANDMARK_PESTSTART))
		else if(src.hasStatus("incorporeal") && !inonstationz(src)) //inonstationz() covers z2/z4 as well but that's covered in the first if
			src.corporealize() //we can afford to be less stringent on these
		if(prob(10))
			for (var/obj/machinery/light/L in view(5, src))
				if (L.status == LIGHT_BROKEN || L.status == LIGHT_BURNED || L.status == LIGHT_EMPTY)
					continue
				if(prob(50))
					L.broken()

	initializeBioholder()
		src.bioHolder.mobAppearance.customizations["hair_bottom"].style = new /datum/customization_style/none //pesky hair
		src.bioHolder.mobAppearance.customizations["hair_middle"].style =  new /datum/customization_style/none
		src.bioHolder.mobAppearance.customizations["hair_top"].style =  new /datum/customization_style/none
		. = ..()

	disposing()
		STOP_TRACKING
		..()


	proc
		///Go invisible, get noclip, be unable to interact with the world
		incorporealize()
			var/turf/T = get_turf(src)
			if(!src.hasStatus("incorporeal"))
				if(!inonstationz(src))
					boutput(src, SPAN_ALERT("You seem unable to become incorporeal here."))
					return
				var/obj/overlay/O1 = new /obj/overlay/darkness_field(T, 4 SECONDS, radius = 4, max_alpha = 250)
				var/obj/overlay/O2 = new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 4 SECONDS, radius = 4, max_alpha = 250)
				SPAWN(1.5 SECONDS)
					src.setStatus("incorporeal", duration = INFINITE_STATUS)
					src.set_density(FALSE)
					src.visible_message(SPAN_ALERT("[src] disappears!"))
					APPLY_ATOM_PROPERTY(src, PROP_ATOM_NEVER_DENSE, src)
					APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_GHOST)
					APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, src)
					APPLY_ATOM_PROPERTY(src, PROP_MOB_NOCLIP, src)
					src.nodamage = TRUE
					src.alpha = 160
					src.see_invisible = INVIS_GHOST
					SPAWN(3 SECONDS)
						if(O1) //sanity check for it breaking sometime
							qdel(O1)
						if(O2)
							qdel(O2)

		///undo `incorporealize()`
		corporealize()
			if(src.hasStatus("incorporeal"))
				var/turf/T = get_turf(src)
				var/obj/overlay/O1 = new /obj/overlay/darkness_field(T, 4 SECONDS, radius = 4, max_alpha = 250)
				var/obj/overlay/O2 = new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 4 SECONDS, radius = 4, max_alpha = 250)
				SPAWN(1.5 SECONDS)
					src.delStatus("incorporeal")
					src.set_density(TRUE)
					REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
					REMOVE_ATOM_PROPERTY(src, PROP_ATOM_NEVER_DENSE, src)
					REMOVE_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, src)
					REMOVE_ATOM_PROPERTY(src, PROP_MOB_NOCLIP, src)
					src.alpha = 254
					src.see_invisible = INVIS_NONE
					src.visible_message(SPAN_ALERT("[src] appears out of the shadows!"))
					src.nodamage = FALSE
					SPAWN(3 SECONDS)
						if(O1) //sanity check for it breaking sometime
							qdel(O1)
						if(O2)
							qdel(O2)


		///Handles creating a machete/the circumstances where we DON'T summon it
		summon_machete()
			var/list/machetes = list()
			var/we_hold_it = FALSE
			var/mob/living/M = src

			if (M.hasStatus("stunned") || M.hasStatus("knockdown") || M.hasStatus("unconscious") || !isalive(M) || M.restrained())
				boutput(M, SPAN_ALERT("Not when you're incapacitated, restrained, or incorporeal."))
				return TRUE

			for_by_tcl(K, /obj/item/slasher_machete)
				if (M.mind && M.mind.key == K.slasher_key)
					if (K == M.find_in_hand(K))
						we_hold_it = TRUE
						continue
					if (!(K in machetes))
						machetes["[K.name] #[length(machetes) + 1] [ismob(K.loc) ? "carried by [K.loc.name]" : "at [get_area(K)]"]"] += K

			switch (length(machetes))
				if (-INFINITY to 0)
					if (we_hold_it)
						boutput(M, SPAN_ALERT("You're already holding your machete."))
						return TRUE
					else
						boutput(M, SPAN_ALERT("You summon a new machete to your hands."))
						var/obj/item/slasher_machete/N = new /obj/item/slasher_machete(get_turf(M))
						N.slasher_key = M.mind?.key
						M.put_in_hand_or_drop(N)
						return FALSE

				if (1)
					var/obj/item/slasher_machete/W = machetes[machetes[1]]

					if (!istype(W))
						boutput(M, SPAN_ALERT("You are unable to summon your machete."))
						return TRUE

					src.send_machete_to_target(W)

				// There could be multiple, i guess
				if (2 to INFINITY)
					var/t1 = input("Please select a machete to summon", "Target Selection", null, null) as null|anything in machetes
					if (!t1)
						return TRUE

					var/obj/item/slasher_machete/K2 = machetes[t1]

					if (!M || !ismob(M) || !isliving(M) || !M.mind)
						return TRUE
					if (!istype(K2))
						boutput(M, SPAN_ALERT("You are unable to summon your machete."))
						return TRUE
					if (M.hasStatus("stunned") || M.hasStatus("knockdown") || M.hasStatus("unconscious") || !isalive(M) || M.restrained())
						boutput(M, SPAN_ALERT("Not when you're incapacitated, restrained, or incorporeal."))
						return TRUE
					if (M.mind.key != K2.slasher_key)
						boutput(M, SPAN_ALERT("You are unable to summon your machete."))
						return TRUE

					src.send_machete_to_target(K2)

			return FALSE

		///Actually sending the machete to the Slasher if one exists already
		send_machete_to_target(obj/item/I)
			if(!istype(I))
				return

			I.visible_message(SPAN_ALERT("<b>The [I.name] is suddenly warped away!</b>"))
			elecflash(I)

			if(ismob(src.loc))
				src.u_equip(I)
			I.stored?.transfer_stored_item(I, get_turf(I))
			if(istype(I.loc, /mob/living))
				var/mob/living/L = I.loc
				L.drop_item(I)
			I.set_loc(get_turf(src))
			if(!src.put_in_hand(I))
				src.show_text("Machete summoned successfully. You can find it on the floor at your current location.", "blue")
			else
				src.show_text("Machete summoned successfully. You can find it in your hand.", "blue")
			return

		take_control(mob/living/carbon/human/M)
			var/mob/living/carbon/human/slasher/W = src
			slasher_key = src.ckey
			if(!istype(M))
				return
			SPAWN(0)
				src.setStatus("possessing", duration = 38 SECONDS)
				boutput(M, SPAN_ALERT("[SPAN_NOTICE("You notice that your legs are feeling a bit stiff.")]"))
				M.change_misstep_chance(30)
				if(prob(33))
					M.emote("faint")
					M.setStatusMin("knockdown", 4 SECONDS)
				else
					M.emote("tremble")
				sleep(20 SECONDS)
				boutput(M, SPAN_ALERT("[SPAN_NOTICE("You feel like you can't control your legs!")]"))
				if(prob(50))
					M.emote("shudder")
					M.setStatusMin("knockdown", 1 SECONDS)
					M.setStatusMin("unconscious", 1 SECONDS)
					M.force_laydown_standup()
				else
					M.emote("faint")
					M.setStatusMin("knockdown", 8 SECONDS)
				M.change_misstep_chance(40)
				sleep(10 SECONDS)
				M.change_misstep_chance(-70)
				boutput(M, SPAN_ALERT("[SPAN_NOTICE("You collapse!")]"))
				M.emote("scream")
				M.emote("faint")
				M.setStatusMin("knockdown", 8 SECONDS)
				M.setStatusMin("unconscious", 8 SECONDS)
				sleep(8 SECONDS)

				var/turf/T = get_turf(M)
				var/obj/overlay/O1 = new /obj/overlay/darkness_field(T, 3 SECONDS, radius = 3, max_alpha = 220)
				var/obj/overlay/O2 = new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 3 SECONDS, radius = 3, max_alpha = 220)
				M.visible_message(SPAN_ALERT("A brown apron and gas mask form out of the shadows on [M]!"))
				M.drop_from_slot(M.wear_mask)
				M.drop_from_slot(M.wear_suit)
				M.drop_from_slot(M.shoes)
				M.drop_from_slot(M.head)
				sleep(2) //just gotta make sure everything drops
				M.equip_new_if_possible(/obj/item/clothing/mask/gas/emergency/unremovable, SLOT_WEAR_MASK)
				M.equip_new_if_possible(/obj/item/clothing/suit/apron/slasher, SLOT_WEAR_SUIT)
				M.equip_new_if_possible(/obj/item/clothing/shoes/slasher_shoes/noslip, SLOT_SHOES)
				M.equip_new_if_possible(/obj/item/clothing/under/color/unremovable, SLOT_W_UNIFORM)
				M.equip_new_if_possible(/obj/item/slasher_machete/possessed, SLOT_R_HAND)
				M.equip_new_if_possible(/obj/item/clothing/gloves/black/slasher, SLOT_GLOVES)
				if(!W.hasStatus("incorporeal"))
					W.incorporealize()
				SPAWN(3.5 SECONDS)
					if(O1) //sanity check for it breaking sometime
						qdel(O1)
					if(O2)
						qdel(O2)

				APPLY_ATOM_PROPERTY(M, PROP_MOB_NO_SELF_HARM, src)
				playsound(M, 'sound/effects/ghost.ogg', 45, FALSE)
				var/mob/dead/observer/O = M.ghostize()
				if(!O)
					boutput(src, "<span class='bold' class='alert'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 101</span>")
					remove_equipment(M)
					return
				if (O.mind)
					O.show_antag_popup("slasher_possession", FALSE)
					boutput(O, "<span class='bold' style='color:red;font-size:150%'>You have been temporarily removed from your body!</span>")
				if(!src.mind || !O.mind)
					src.visible_message("<span class='bold' class='alert'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 102</span>")
					remove_equipment(M)
					return
				src.mind.transfer_to(M)
				var/mob/dead/target_observer/slasher_ghost/WG = O.insert_slasher_observer(M)
				if(!WG)
					boutput(src, "<span class='bold' class='alert'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 103</span>")
					remove_equipment(M)
					M.mind.transfer_to(src)
					return
				WG.verbs -= list(/mob/verb/setdnr)
				M.setStatus("possessed", duration = 45 SECONDS)
				sleep(45 SECONDS)
				if(!WG.mind || !M.mind)
					src.visible_message("<span class='bold' class='alert'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 104</span>")
					remove_equipment(M)
					return
				if(!M.loc) //M got gibbed
					var/mob/M2 = ckey_to_mob(src.slasher_key)
					M2.mind.transfer_to(src) //the slasher's alive again at least
				if(!src.loc) //src got gibbed
					return //well you're dead now, soz
				M.mind.transfer_to(src)
				sleep(5 DECI SECONDS)
				WG.verbs += list(/mob/verb/setdnr)
				playsound(M, 'sound/effects/ghost2.ogg', 50, FALSE)
				if(!WG || !M)
					src.visible_message("<span class='bold' class='alert'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 105</span>")
					if(M)
						remove_equipment(M)
					return
				if(!WG.mind || !src.mind)
					src.visible_message("<span class='bold' class='alert'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 106</span>")
					remove_equipment(M)
					return
				WG.mind.transfer_to(M)
				REMOVE_ATOM_PROPERTY(M, PROP_MOB_NO_SELF_HARM, src)
				qdel(WG)
				remove_equipment(M)

		///removes equipment from slasher/possessed/whoever
		remove_equipment(mob/living/carbon/human/M)
			for(var/obj/item/clothing/suit/apron/slasher/A in M)
				M.u_equip(A)
				qdel(A)
			for(var/obj/item/clothing/gloves/black/slasher/G in M)
				M.u_equip(G)
				qdel(G)
			for(var/obj/item/clothing/shoes/slasher_shoes/B in M)
				M.u_equip(B)
				qdel(B)
			for(var/obj/item/slasher_machete/possessed/P in M)
				P.visible_message(SPAN_ALERT("<b>\The [P] crumbles into ash!</b>"))
				M.u_equip(P)
				qdel(P)
			for(var/obj/item/clothing/mask/gas/emergency/unremovable/U in M)
				M.u_equip(U)
				qdel(U)
			M.equip_new_if_possible(/obj/item/clothing/under/color, SLOT_W_UNIFORM)
			M.equip_new_if_possible(/obj/item/clothing/mask/gas/emergency/postpossession, SLOT_WEAR_MASK)
			M.equip_new_if_possible(/obj/item/clothing/suit/apron/slasher/postpossession, SLOT_WEAR_SUIT)
			M.equip_new_if_possible(/obj/item/clothing/gloves/black, SLOT_GLOVES)
			M.equip_new_if_possible(/obj/item/clothing/shoes/slasher_shoes, SLOT_SHOES)

		///heals a bunch of bad things the Slasher can get hit with, but not all
		regenerate()
			var/turf/T = get_turf(src)
			var/obj/overlay/O1 = new /obj/overlay/darkness_field(T, 2 SECONDS, radius = 3, max_alpha = 160)
			var/obj/overlay/O2 = new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 2 SECONDS, radius = 3, max_alpha = 160)
			playsound(src, 'sound/machines/ArtifactEld1.ogg', 60, FALSE)
			if(src.hasStatus("handcuffed"))
				src.visible_message(SPAN_ALERT("[src]'s wrists dissolve into the shadows, making the handcuffs vanish!"))
				src.handcuffs.destroy_handcuffs(src)
			SPAWN(5 DECI SECONDS)
				src.losebreath = 0
				src.remove_stuns()
				src.HealDamage("All", 100, 100)
				src.add_stamina(200)
				src.take_brain_damage(-INFINITY)
				src.visible_message(SPAN_ALERT("[src] appears to partially dissolve into the shadows, but then reforms!"))
				repair_bleeding_damage(src, 100, 5)
				SPAWN(3 SECONDS)
					if(O1) //sanity check for it breaking sometime
						qdel(O1)
					if(O2)
						qdel(O2)

		///Actionbar handler for stealing a dead body's soul.
		soulStealSetup(mob/living/carbon/human/M)
			boutput(src, SPAN_ALERT("You begin stealing [M]'s soul."))
			SETUP_GENERIC_ACTIONBAR(src, null, 3 SECONDS, /mob/living/carbon/human/slasher/proc/soulSteal, M, src.icon, src.icon_state,\
	 		"Something barely visible seems to come out of [M]'s mouth, which then is absorbed into [src]'s body!", null)

		///Steal a dead body's soul, provided they have a full one, and get more machete damage
		soulSteal(mob/living/carbon/human/M, soul_remove = TRUE)
			var/mob/living/W = src
			boutput(src, SPAN_ALERT("You steal [M]'s soul!"))
			playsound(src, 'sound/voice/wraith/wraithpossesobject.ogg', 60, FALSE)
			if(soul_remove)
				M.mind?.soul = 0
			M.setStatus("soulstolen", INFINITE_STATUS)
			for_by_tcl(K, /obj/item/slasher_machete)
				if (W.mind && W.mind.key == K.slasher_key)
					K.force = K.force + 2.5
					K.throwforce = K.throwforce + 2.5
					K.tooltip_rebuild = TRUE

		///Crowd control ability to stop people from running as easily, applies stagger
		staggerNearby()
			src.visible_message(SPAN_ALERT("[src] begins emitting a dark aura."))
			var/image/overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
			overlay_image.color = "#1a1102"
			src.UpdateOverlays(overlay_image, "slasher_aura")
			playsound(src, 'sound/effects/ghostlaugh.ogg', 40, FALSE)
			SPAWN(2 SECONDS)
				src.UpdateOverlays(null, "slasher_aura")
				for(var/mob/living/M in oview(4, src))
					if((M != src) && !M?.traitHolder?.hasTrait("training_chaplain"))
						boutput(M, SPAN_NOTICE("Your legs feel a bit stiff!"))
						M.setStatus("slowed", 8 SECONDS) //stagger has a 5s cap, changed to slow

		///Trail some dried blood I guess?
		blood_trail()
			if(!src.last_btype || !src.last_bdna)
				src.last_btype = src.blood_type
				src.last_bdna = src.blood_DNA
			if(!src.trailing_blood)
				src.tracked_blood = list("bDNA" = src.last_bdna, "btype" = src.last_btype, "count" = INFINITY, "sample_reagent" = src.blood_id)
				src.track_blood()
				trailing_blood = TRUE
				APPLY_ATOM_PROPERTY(src, PROP_MOB_BLOOD_TRACKING_ALWAYS, src)
			else
				REMOVE_ATOM_PROPERTY(src, PROP_MOB_BLOOD_TRACKING_ALWAYS, src)
				src.tracked_blood = null
				trailing_blood = FALSE

		///Gives the Slasher their abilities
		addAllAbilities()
			src.addAbility(/datum/targetable/slasher/help)
			src.addAbility(/datum/targetable/slasher/incorporeal)
			src.addAbility(/datum/targetable/slasher/corporeal)
			src.addAbility(/datum/targetable/slasher/blood_trail)
			src.addAbility(/datum/targetable/slasher/soulsteal)
			src.addAbility(/datum/targetable/slasher/summon_machete)
			src.addAbility(/datum/targetable/slasher/take_control)
			src.addAbility(/datum/targetable/slasher/regenerate)
			src.addAbility(/datum/targetable/slasher/stagger)

		updateButtons()
			abilityHolder.updateButtons()
