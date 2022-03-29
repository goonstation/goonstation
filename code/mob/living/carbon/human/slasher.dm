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

		src.equip_new_if_possible(/obj/item/clothing/shoes/slasher_shoes/noslip, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/color/unremovable, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/suit/apron/slasher, slot_wear_suit)
		src.equip_new_if_possible(/obj/item/clothing/mask/gas/emergency/unremovable, slot_wear_mask)
		src.equip_new_if_possible(/obj/item/clothing/gloves/black/slasher, slot_gloves)

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
		src.bioHolder.mobAppearance.customization_first = new /datum/customization_style/none //pesky hair
		src.bioHolder.mobAppearance.customization_second = new /datum/customization_style/none
		src.bioHolder.mobAppearance.customization_third = new /datum/customization_style/none
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
					boutput(src, __red("You seem unable to become incorporeal here."))
					return
				var/obj/overlay/O1 = new /obj/overlay/darkness_field(T, 4 SECONDS, radius = 4, max_alpha = 250)
				var/obj/overlay/O2 = new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 4 SECONDS, radius = 4, max_alpha = 250)
				SPAWN(1.5 SECONDS)
					src.setStatus("incorporeal", duration = INFINITE_STATUS)
					src.set_density(FALSE)
					src.visible_message("<span class='alert'>[src] disappears!</span>")
					APPLY_ATOM_PROPERTY(src, PROP_MOB_NEVER_DENSE, src)
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
					REMOVE_ATOM_PROPERTY(src, PROP_MOB_NEVER_DENSE, src)
					REMOVE_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, src)
					REMOVE_ATOM_PROPERTY(src, PROP_MOB_NOCLIP, src)
					src.alpha = 254
					src.see_invisible = INVIS_NONE
					src.visible_message("<span class='alert'>[src] appears out of the shadows!</span>")
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

			if (M.hasStatus("stunned") || M.hasStatus("weakened") || M.hasStatus("paralysis") || !isalive(M) || M.restrained())
				boutput(M, __red("Not when you're incapacitated, restrained, or incorporeal."))
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
						boutput(M, __red("You're already holding your machete."))
						return TRUE
					else
						boutput(M, __red("You summon a new machete to your hands."))
						var/obj/item/slasher_machete/N = new /obj/item/slasher_machete(get_turf(M))
						N.slasher_key = M.mind?.key
						M.put_in_hand_or_drop(N)
						return FALSE

				if (1)
					var/obj/item/slasher_machete/W = machetes[machetes[1]]

					if (!istype(W))
						boutput(M, __red("You are unable to summon your machete."))
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
						boutput(M, __red("You are unable to summon your machete."))
						return TRUE
					if (M.hasStatus("stunned") || M.hasStatus("weakened") || M.hasStatus("paralysis") || !isalive(M) || M.restrained())
						boutput(M, __red("Not when you're incapacitated, restrained, or incorporeal."))
						return TRUE
					if (M.mind.key != K2.slasher_key)
						boutput(M, __red("You are unable to summon your machete."))
						return TRUE

					src.send_machete_to_target(K2)

			return FALSE

		///Actually sending the machete to the Slasher if one exists already
		send_machete_to_target(obj/item/I)
			if(!istype(I))
				return

			I.visible_message("<span class='alert'><b>The [I.name] is suddenly warped away!</b></span>")
			elecflash(I)

			if(ismob(src.loc))
				src.u_equip(I)
			if(istype(I.loc, /obj/item/storage))
				var/obj/item/storage/S = I.loc
				var/datum/hud/storage/H = S.hud
				H.remove_object(I)
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
				boutput(M, __red("<span class='notice'>You notice that your legs are feeling a bit stiff.</span>"))
				M.change_misstep_chance(30)
				if(prob(33))
					M.emote("faint")
					M.setStatus("weakened", max(M.getStatusDuration("weakened"), 4 SECONDS))
				else
					M.emote("tremble")
				sleep(20 SECONDS)
				boutput(M, __red("<span class='notice'>You feel like you can't control your legs!</span>"))
				if(prob(50))
					M.emote("shudder")
					M.setStatus("weakened", max(M.getStatusDuration("weakened"), 1 SECONDS))
					M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 1 SECONDS))
					M.force_laydown_standup()
				else
					M.emote("faint")
					M.setStatus("weakened", max(M.getStatusDuration("weakened"), 8 SECONDS))
				M.change_misstep_chance(40)
				sleep(10 SECONDS)
				M.change_misstep_chance(-70)
				boutput(M, __red("<span class='notice'>You collapse!</span>"))
				M.emote("scream")
				M.emote("faint")
				M.setStatus("weakened", max(M.getStatusDuration("weakened"), 8 SECONDS))
				M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 8 SECONDS))
				sleep(8 SECONDS)

				var/turf/T = get_turf(M)
				var/obj/overlay/O1 = new /obj/overlay/darkness_field(T, 3 SECONDS, radius = 3, max_alpha = 220)
				var/obj/overlay/O2 = new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 3 SECONDS, radius = 3, max_alpha = 220)
				M.visible_message("<span class='alert'>A brown apron and gas mask form out of the shadows on [M]!</span>")
				M.drop_from_slot(M.wear_mask)
				M.drop_from_slot(M.wear_suit)
				M.drop_from_slot(M.shoes)
				M.drop_from_slot(M.head)
				sleep(2) //just gotta make sure everything drops
				M.equip_new_if_possible(/obj/item/clothing/mask/gas/emergency/unremovable, M.slot_wear_mask)
				M.equip_new_if_possible(/obj/item/clothing/suit/apron/slasher, M.slot_wear_suit)
				M.equip_new_if_possible(/obj/item/clothing/shoes/slasher_shoes/noslip, M.slot_shoes)
				M.equip_new_if_possible(/obj/item/clothing/under/color/unremovable, M.slot_w_uniform)
				M.equip_new_if_possible(/obj/item/slasher_machete/possessed, M.slot_r_hand)
				M.equip_new_if_possible(/obj/item/clothing/gloves/black/slasher, M.slot_gloves)
				if(!W.hasStatus("incorporeal"))
					W.incorporealize()
				SPAWN(3.5 SECONDS)
					if(O1) //sanity check for it breaking sometime
						qdel(O1)
					if(O2)
						qdel(O2)

				APPLY_ATOM_PROPERTY(M, PROP_MOB_NO_SELF_HARM, src)
				playsound(M, "sound/effects/ghost.ogg", 45, 0)
				var/mob/dead/observer/O = M.ghostize()
				if(!O)
					boutput(src, "<span class='bold' style='color:red'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 101</span>")
					remove_equipment(M)
					return
				if (O.mind)
					O.Browse(grabResource("html/slasher_possession.html"),"window=slasher_possession;size=600x440;title=Slasher Possession")
					boutput(O, "<span class='bold' style='color:red;font-size:150%'>You have been temporarily removed from your body!</span>")
				if(!src.mind || !O.mind)
					src.visible_message("<span class='bold' style='color:red'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 102</span>")
					remove_equipment(M)
					return
				src.mind.transfer_to(M)
				var/mob/dead/target_observer/slasher_ghost/WG = O.insert_slasher_observer(M)
				if(!WG)
					boutput(src, "<span class='bold' style='color:red'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 103</span>")
					remove_equipment(M)
					M.mind.transfer_to(src)
					return
				WG.mind.dnr = TRUE
				WG.verbs -= list(/mob/verb/setdnr)
				M.setStatus("possessed", duration = 45 SECONDS)
				sleep(45 SECONDS)
				if(!WG.mind || !M.mind)
					src.visible_message("<span class='bold' style='color:red'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 104</span>")
					remove_equipment(M)
					return
				if(!M.loc) //M got gibbed
					var/mob/M2 = ckey_to_mob(src.slasher_key)
					M2.mind.transfer_to(src) //the slasher's alive again at least
				if(!src.loc) //src got gibbed
					return //well you're dead now, soz
				M.mind.transfer_to(src)
				sleep(5 DECI SECONDS)
				WG.mind.dnr = FALSE
				WG.verbs += list(/mob/verb/setdnr)
				playsound(M, "sound/effects/ghost2.ogg", 50, 0)
				if(!WG || !M)
					src.visible_message("<span class='bold' style='color:red'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 105</span>")
					if(M)
						remove_equipment(M)
					return
				if(!WG.mind || !src.mind)
					src.visible_message("<span class='bold' style='color:red'>Something fucked up! Aborting possession, please let #imcoder know. Error Code: 106</span>")
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
				P.visible_message("<span class='alert'><b>\The [P] crumbles into ash!</b></span>")
				M.u_equip(P)
				qdel(P)
			for(var/obj/item/clothing/mask/gas/emergency/unremovable/U in M)
				M.u_equip(U)
				qdel(U)
			M.equip_new_if_possible(/obj/item/clothing/under/color, M.slot_w_uniform)
			M.equip_new_if_possible(/obj/item/clothing/mask/gas/emergency/postpossession, M.slot_wear_mask)
			M.equip_new_if_possible(/obj/item/clothing/suit/apron/slasher/postpossession, M.slot_wear_suit)
			M.equip_new_if_possible(/obj/item/clothing/gloves/black, M.slot_gloves)
			M.equip_new_if_possible(/obj/item/clothing/shoes/slasher_shoes, M.slot_shoes)

		///heals a bunch of bad things the Slasher can get hit with, but not all
		regenerate()
			var/turf/T = get_turf(src)
			var/obj/overlay/O1 = new /obj/overlay/darkness_field(T, 2 SECONDS, radius = 3, max_alpha = 160)
			var/obj/overlay/O2 = new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 2 SECONDS, radius = 3, max_alpha = 160)
			playsound(src, "sound/machines/ArtifactEld1.ogg", 60, 0)
			if(src.hasStatus("handcuffed"))
				src.visible_message("<span class='alert'>[src]'s wrists dissolve into the shadows, making the handcuffs vanish!</span>")
				src.handcuffs.destroy_handcuffs(src)
			SPAWN(5 DECI SECONDS)
				src.losebreath = 0
				src.delStatus("paralysis")
				src.delStatus("stunned")
				src.delStatus("weakened")
				src.HealDamage("All", 100, 100)
				src.add_stamina(200)
				src.take_brain_damage(-INFINITY)
				src.visible_message("<span class='alert'>[src] appears to partially dissolve into the shadows, but then reforms!</span>")
				repair_bleeding_damage(src, 100, 5)
				SPAWN(3 SECONDS)
					if(O1) //sanity check for it breaking sometime
						qdel(O1)
					if(O2)
						qdel(O2)

		///Actionbar handler for stealing a dead body's soul.
		soulStealSetup(mob/living/carbon/human/M)
			boutput(src, "<span class='alert'>You begin stealing [M]'s soul.</span>")
			SETUP_GENERIC_ACTIONBAR(src, null, 3 SECONDS, /mob/living/carbon/human/slasher/proc/soulSteal, M, src.icon, src.icon_state,\
	 		"Something barely visible seems to come out of [M]'s mouth, which then is absorbed into [src]'s body!", null)

		///Steal a dead body's soul, provided they have a full one, and get more machete damage
		soulSteal(mob/living/carbon/human/M, soul_remove = TRUE)
			var/mob/living/W = src
			boutput(src, "<span class='alert'>You steal [M]'s soul!</span>")
			playsound(src, "sound/voice/wraith/wraithpossesobject.ogg", 60, 0)
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
			src.visible_message("<span class='alert'>[src] begins emitting a dark aura.</span>")
			var/image/overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
			overlay_image.color = "#1a1102"
			src.UpdateOverlays(overlay_image, "slasher_aura")
			playsound(src, "sound/effects/ghostlaugh.ogg", 40, 0)
			SPAWN(2 SECONDS)
				src.UpdateOverlays(null, "slasher_aura")
				for(var/mob/living/M in oview(4, src))
					if((M != src) && !M?.traitHolder?.hasTrait("training_chaplain"))
						boutput(M, "<span class='notice'>Your legs feel a bit stiff!</span>")
						M.setStatus("slowed", 8 SECONDS) //stagger has a 5s cap, changed to slow

		///Trail some dried blood I guess?
		blood_trail()
			if(!src.last_btype || !src.last_bdna)
				src.last_btype = src.blood_type
				src.last_bdna = src.blood_DNA
			if(!src.trailing_blood)
				src.tracked_blood = list("bDNA" = src.last_bdna, "btype" = src.last_btype, "count" = INFINITY)
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

/datum/abilityHolder/slasher
	usesPoints = FALSE
	regenRate = 0
	tabName = "Abilities"
	cast_while_dead = FALSE

ABSTRACT_TYPE(/datum/targetable/slasher)
/datum/targetable/slasher
	icon = 'icons/mob/slasher.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/slasher

/datum/targetable/slasher/incorporeal
	name = "Incorporealize"
	desc = "Become a ghost, capable of moving through walls."
	icon_state = "incorporealize"
	targeted = FALSE
	cooldown = 20 SECONDS

	cast()
		if(..())
			return TRUE

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		if(W.hasStatus("incorporeal"))
			boutput(src.holder.owner, __red("<span class='alert'>You must be corporeal to use this ability.</span>"))
			return TRUE
		else
			if(src.holder.owner.client)
				for (var/mob/living/L in view(src.holder.owner.client.view, src.holder.owner))
					if (isalive(L) && L.sight_check(1) && L.ckey != src.holder.owner.ckey)
						boutput(src.holder.owner, __red("<span class='alert'>You can only use that when nobody can see you!</span>"))
						return TRUE
		return W.incorporealize()

/datum/targetable/slasher/corporeal
	name = "Corporealize"
	desc = "Manifest your being, allowing you to interact with the world."
	icon_state = "corporealize"
	targeted = FALSE
	cooldown = 20 SECONDS

	cast()
		if(..())
			return TRUE

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		if(!W.hasStatus("incorporeal"))
			boutput(src.holder.owner, __red("<span class='alert'>You must be incorporeal to use this ability.</span>"))
			return TRUE
		else
			return W.corporealize()

/datum/targetable/slasher/blood_trail
	name = "Blood Trail"
	desc = "Begin trailing blood behind you, to spook those who reside on station."
	icon_state = "trail_blood"
	targeted = FALSE
	cooldown = 5 SECONDS

	cast()
		if(..())
			return TRUE

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.blood_trail()

/datum/targetable/slasher/summon_machete
	name = "Summon Machete"
	desc = "Summon your machete to your active hand."
	icon_state = "summon_machete"
	targeted = FALSE
	cooldown = 15 SECONDS

	cast()
		if(..())
			return TRUE
		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.summon_machete()

/datum/targetable/slasher/take_control
	name = "Possess"
	desc = "Possess a target temporarily."
	icon_state = "slasher_possession"
	targeted = TRUE
	target_anything = TRUE
	cooldown = 3 MINUTES

	cast(atom/target)
		if (..())
			return TRUE

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			var/mob/living/carbon/human/slasher/W = src.holder.owner
			if(H?.traitHolder?.hasTrait("training_chaplain"))
				boutput(src.holder.owner, "<span class='alert'>You cannot possess a holy man!</span>")
				JOB_XP(H, "Chaplain", 2)
				return TRUE
			if(isdead(H))
				boutput(src.holder.owner, "<span class='alert'>You cannot possess a corpse.</span>")
				return TRUE
			if(H.client)
				boutput(src.holder.owner, "<b>You begin to possess [H].</b>")
				src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
				H.playsound_local(H.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
				return W.take_control(H)
			else
				boutput(src.holder.owner, "<b>The target must have a consciousness to be possessed.</b>")
				return TRUE
		else
			boutput(src.holder.owner, "<span class='alert'>You cannot possess a non-human.</span>")
			return TRUE

/datum/targetable/slasher/regenerate
	name = "Regenerate"
	desc = "Regenerate your body, and remove all restraints."
	icon_state = "regenerate"
	targeted = FALSE
	cooldown = 75 SECONDS

	cast()
		if(..())
			return TRUE

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.regenerate()

/datum/targetable/slasher/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "help"
	targeted = FALSE
	cooldown = 5 SECONDS
	helpable = FALSE
	special_screen_loc = "SOUTH,EAST"

	cast(atom/target)
		if (..())
			return TRUE
		if (holder.help_mode)
			holder.help_mode = FALSE
			boutput(holder.owner, "<span class='notice'><strong>Help Mode has been deactivated.</strong></span>")
		else
			holder.help_mode = TRUE
			boutput(holder.owner, "<span class='notice'><strong>Help Mode has been activated. To disable it, click on this button again.</strong></span>")
			boutput(holder.owner, "<span class='notice'>Hold down Shift, Ctrl or Alt while clicking the button to set it to that key.</span>")
			boutput(holder.owner, "<span class='notice'>You will then be able to use it freely by holding that button and left-clicking a tile.</span>")
			boutput(holder.owner, "<span class='notice'>Alternatively, you can click with your middle mouse button to use the ability on your current tile.</span>")
		src.object.icon_state = "help[holder.help_mode]"
		holder.updateButtons()

/datum/targetable/slasher/stagger
	name = "Stagger Area"
	desc = "Stagger everyone in a four tile radius of you for a short duration."
	icon_state = "stagger_group"
	targeted = FALSE
	cooldown = 35 SECONDS

	cast()
		if(..())
			return TRUE
		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.staggerNearby()

/datum/targetable/slasher/soulsteal
	name = "Soul Steal"
	desc = "Steal a corpse's soul, increasing the power of your machete."
	icon_state = "soul_steal"
	targeted = TRUE
	cooldown = 15 SECONDS

	cast(atom/target)
		if(..())
			return TRUE
		var/mob/living/carbon/human/slasher/W = src.holder.owner
		var/mob/living/carbon/human/M = target
		if(M?.traitHolder?.hasTrait("training_chaplain"))
			boutput(src.holder.owner, "<span class='alert'>You cannot claim the soul of a holy man!</span>")
			JOB_XP(src.holder.owner, "Chaplain", 2)
			return TRUE
		if(isdead(M))
			if(ishuman(M) && M.hasStatus("soulstolen"))
				if (get_dist(W, M) > 1)
					boutput(src.holder.owner, "<span class='alert'>You must be closer in order to steal [M]'s soul.</span>")
					return TRUE
				else
					return W.soulStealSetup(M, TRUE)
			else if(ishuman(M) && (M.mind && M.mind.soul >= 100))
				if (get_dist(W, M) > 1)
					boutput(src.holder.owner, "<span class='alert'>You must be closer in order to steal [M]'s soul.</span>")
					return TRUE
				else
					return W.soulStealSetup(M, FALSE)
			else
				boutput(src.holder.owner, "<span class='alert'>[M]'s soul is inadequate for your purposes.</span>")
				return TRUE
		else
			boutput(src.holder.owner, "<span class='alert'>Your target must be dead in order to steal their soul.</span>")
			return TRUE
