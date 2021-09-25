/mob/living/carbon/human/slasher
	real_name = "The Slasher"
	var/trailing_blood = FALSE
	///Used for handling multiple Slashers & their machetes.
	var/slasher_ckey

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

		src.see_in_dark = SEE_DARK_FULL
		src.sight |= SEE_SELF
		src.see_invisible = 16
		src.bioHolder.AddEffect("breathless", 0, 0, 0, 1)
		src.bioHolder.AddEffect("food_rad_resist", 0, 0, 0, 1)
		src.bioHolder.AddEffect("detox", 0, 0, 0, 1)
		src.add_stun_resist_mod("slasher_stun_resistance", 75)
		slasher_ckey = src.ckey
		START_TRACKING

	Life()
		var/turf/T = get_turf(src)
		if(!src.density && T && isrestrictedz(T.z))
			src.delStatus("incorporeal")
			src.set_density(1)
			REMOVE_MOB_PROPERTY(src, PROP_INVISIBILITY, src)
			REMOVE_MOB_PROPERTY(src, PROP_NEVER_DENSE, src)
			REMOVE_MOB_PROPERTY(src, PROP_NO_MOVEMENT_PUFFS, src)
			src.alpha = 254
			src.see_invisible = 0
			src.nodamage = FALSE
			src.client.flying = 0
			src.gib() //not taking any risks here with noclip
		else if((!src.density && T.z == 3) || (!src.density && T.z == 5))
			src.corporealize() //we can afford to be less stringent on these

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
			if(src.density)
				if(T && isrestrictedz(T.z))
					boutput(src, __red("You seem unable to become incorporeal here."))
					return
				if((T && T.z == 3) || (T && T.z == 5))
					boutput(src, __red("You seem unable to become incorporeal here."))
					return
				new /obj/overlay/darkness_field(T, 4 SECONDS, radius = 4, max_alpha = 250)
				new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 4 SECONDS, radius = 4, max_alpha = 250)
				sleep(15 DECI SECONDS)
				src.setStatus("incorporeal", duration = INFINITE_STATUS)
				src.set_density(0)
				src.visible_message("<span class='alert'>[src] disappears!</span>")
				APPLY_MOB_PROPERTY(src, PROP_NEVER_DENSE, src)
				APPLY_MOB_PROPERTY(src, PROP_INVISIBILITY, src, INVIS_GHOST)
				APPLY_MOB_PROPERTY(src, PROP_NO_MOVEMENT_PUFFS, src)
				src.nodamage = TRUE
				src.alpha = 160
				src.see_invisible = 16
				src.client.flying = 1

		///undo `incorporealize()`
		corporealize()
			if(!src.density)
				var/turf/T = get_turf(src)
				new /obj/overlay/darkness_field(T, 4 SECONDS, radius = 4, max_alpha = 250)
				new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 4 SECONDS, radius = 4, max_alpha = 250)
				sleep(15 DECI SECONDS)
				src.delStatus("incorporeal")
				src.set_density(1)
				REMOVE_MOB_PROPERTY(src, PROP_INVISIBILITY, src)
				REMOVE_MOB_PROPERTY(src, PROP_NEVER_DENSE, src)
				REMOVE_MOB_PROPERTY(src, PROP_NO_MOVEMENT_PUFFS, src)
				src.alpha = 254
				src.see_invisible = 0
				src.visible_message("<span class='alert'>[src] appears out of the shadows!</span>")
				src.nodamage = FALSE
				src.client.flying = 0

		///Trail some dried blood I guess?
		blood_trail()
			if(src.trailing_blood == FALSE)
				src.tracked_blood = list("bDNA" = src.blood_DNA, "btype" = src.blood_type, "count" = INFINITY)
				src.track_blood()
				trailing_blood = TRUE
			else
				src.tracked_blood = list("bDNA" = src.blood_DNA, "btype" = src.blood_type, "count" = 0)
				trailing_blood = FALSE

		///Handles creating a machete/the circumstances where we DON'T summon it
		summon_machete()
			var/list/machetes = list()
			var/we_hold_it = 0
			var/mob/living/M = src

			if (!M)
				return 1

			if (M.getStatusDuration("stunned") > 0 || M.getStatusDuration("weakened") || M.getStatusDuration("paralysis") > 0 || !isalive(M) || M.restrained())
				boutput(M, __red("Not when you're incapacitated, restrained, or incorporeal."))
				return 1

			for_by_tcl(K, /obj/item/slasher_machete)
				if (M.mind && M.mind.key == K.slasher_key)
					if (K == M.find_in_hand(K))
						we_hold_it = 1
						continue
					if (!(K in machetes))
						machetes["[K.name] #[length(machetes) + 1] [ismob(K.loc) ? "carried by [K.loc.name]" : "at [get_area(K)]"]"] += K

			switch (length(machetes))
				if (-INFINITY to 0)
					if (we_hold_it != 0)
						boutput(M, __red("You're already holding your machete."))
						return 1
					else
						boutput(M, __red("You summon a new machete to your hands."))
						var/obj/item/slasher_machete/N = new /obj/item/slasher_machete(get_turf(M))
						N.slasher_key = M.mind?.key
						M.put_in_hand_or_drop(N)
						return 0

				if (1)
					var/obj/item/slasher_machete/W
					for (var/C in machetes)
						W = machetes[C]
						break

					if (!W || !istype(W))
						boutput(M, __red("You are unable to summon your machete."))
						return 0

					src.send_machete_to_target(W)

				// There could be multiple, i guess
				if (2 to INFINITY)
					var/t1 = input("Please select a machete to summon", "Target Selection", null, null) as null|anything in machetes
					if (!t1)
						return 1

					var/obj/item/slasher_machete/K2 = machetes[t1]

					if (!M || !ismob(M) || !isliving(M || !M.mind))
						return 0
					if (!K2 || !istype(K2))
						boutput(M, __red("You are unable to summon your machete."))
						return 0
					if (M.getStatusDuration("stunned") > 0 || M.getStatusDuration("weakened") || M.getStatusDuration("paralysis") > 0 || !isalive(M) || M.restrained())
						boutput(M, __red("Not when you're incapacitated, restrained, or incorporeal."))
						return 0
					if (M.mind.key != K2.slasher_key)
						boutput(M, __red("You are unable to summon your machete."))
						return 0

					src.send_machete_to_target(K2)

			return 0

		///Actually sending the machete to the Slasher if one exists already
		send_machete_to_target(var/obj/item/I)
			if(!src || !istype(src) || !I || !istype(I))
				return
			if(ismob(locate(I)))
				var/mob/M = locate(I)
				I.set_loc(locate(M))
				sleep(5 DECI SECONDS)

			I.visible_message("<span class='alert'><b>The [I.name] is suddenly warped away!</b></span>")
			elecflash(I)

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
				src.show_text("Machete summoned successfully. You can find it on the floor at your current location.", "blue")
			else
				src.show_text("Machete summoned successfully. You can find it in your hand.", "blue")
			return

		take_control(var/mob/living/carbon/human/M)
			var/mob/living/carbon/human/slasher/W = src
			if(!src || !istype(src) || !M || !istype(M))
				return

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
			new /obj/overlay/darkness_field(T, 3 SECONDS, radius = 3, max_alpha = 220)
			new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 3 SECONDS, radius = 3, max_alpha = 220)
			M.visible_message("<span class='alert'>A brown apron and gas mask form out of the shadows on [M]!</span>")
			M.drop_from_slot(M.slot_wear_mask)
			M.drop_from_slot(M.slot_wear_suit)
			M.drop_from_slot(M.slot_shoes)
			M.equip_new_if_possible(/obj/item/clothing/mask/gas/emergency/unremovable, M.slot_wear_mask)
			M.equip_new_if_possible(/obj/item/clothing/suit/apron/slasher, M.slot_wear_suit)
			M.equip_new_if_possible(/obj/item/clothing/shoes/slasher_shoes/noslip, M.slot_shoes)
			M.equip_new_if_possible(/obj/item/clothing/under/color/unremovable, M.slot_w_uniform)
			M.equip_new_if_possible(/obj/item/slasher_machete/possessed, M.slot_r_hand)
			M.equip_new_if_possible(/obj/item/clothing/gloves/black/slasher, M.slot_gloves)
			if(src.density)
				W.incorporealize()
				W.client.flying = 0

			//var/datum/mind/m_mind = M.mind //didn't work, try again later
			var/mob/dead/observer/O = M.ghostize()
			if (O.mind)
				O.Browse(grabResource("html/slasher_possession.html"),"window=slasher_possession;size=600x440;title=Slasher Possession")
			boutput(O, "<span class='bold' style='color:red;font-size:150%'>You have been temporarily removed from your body!</span>")
			usr.mind.swap_with(M)
			var/mob/dead/target_observer/slasher_ghost/WG = O.insert_slasher_observer(M)
			WG.mind.dnr = 1
			WG.verbs -= list(/mob/verb/setdnr)
			sleep(45 SECONDS)
			M.mind.swap_with(usr)
			sleep(5 DECI SECONDS)
			WG.mind.dnr = 0
			WG.verbs += list(/mob/verb/setdnr)
			if(locate(M))
				WG.mind.transfer_to(M)


			for(var/obj/item/clothing/suit/apron/slasher/A in M)
				qdel(A)
			for(var/obj/item/clothing/gloves/black/slasher/G in M)
				qdel(G)
			for(var/obj/item/clothing/shoes/slasher_shoes/B in M)
				qdel(B)
			for(var/obj/item/slasher_machete/possessed/P in M)
				P.visible_message("<span class='alert'><b>The [P.name] crumbles into ash!</b></span>")
				qdel(P)
			for(var/obj/item/clothing/mask/gas/emergency/unremovable/U in M)
				qdel(U)
			M.equip_new_if_possible(/obj/item/clothing/under/color, M.slot_w_uniform)
			M.equip_new_if_possible(/obj/item/clothing/mask/gas/emergency/postpossession, M.slot_wear_mask)
			M.equip_new_if_possible(/obj/item/clothing/suit/apron/slasher/postpossession, M.slot_wear_suit)
			M.equip_new_if_possible(/obj/item/clothing/gloves/black, M.slot_gloves)
			M.equip_new_if_possible(/obj/item/clothing/shoes/slasher_shoes, M.slot_shoes)

		///`fullheal()` but with some extra flavor and readding detox
		regenerate()
			playsound(src, 'sound/machines/ArtifactEld1.ogg', 60, 0)
			if(src.hasStatus("handcuffed"))
				src.visible_message("<span class='alert'>[src]'s wrists dissolve into the shadows, dropping the handcuffs to the ground!</span>")
			sleep(5 DECI SECONDS)
			src.full_heal() //this won't turn out badly
			src.visible_message("<span class='alert'>[src] appears to partially dissolve into the shadows, but then reforms!</span>")
			src.bioHolder.AddEffect("detox", 0, 0, 0, 1) //full_heal gets rid of this

		///Actionbar handler for stealing a dead body's soul.
		soulStealSetup(var/mob/living/carbon/human/M)
			boutput(usr, "<span class='alert'>You begin stealing [M]'s soul.</span>")
			SETUP_GENERIC_ACTIONBAR(src, null, 3 SECONDS, /mob/living/carbon/human/slasher/proc/soulSteal, M, src.icon, src.icon_state,\
	 		"Something barely visible seems to come out of [M]'s mouth, which then is absorbed into [src]'s body!", null)

		///Steal a dead body's soul, provided they have a full one, and get more machete damage
		soulSteal(var/mob/living/carbon/human/M)
			var/mob/living/W = src
			boutput(src, "<span class='alert'>You steal [M]'s soul!</span>")
			playsound(src, "sound/voice/wraith/wraithpossesobject.ogg", 60, 0)
			if(M.mind)
				M.mind.soul = 0
			for_by_tcl(K, /obj/item/slasher_machete)
				if (W.mind && W.mind.key == K.slasher_key)
					K.force = K.force + 2.5
					K.throwforce = K.throwforce + 2.5
					K.tooltip_rebuild = 1

		///Easy ability to open a door if your target's behind, like, one
		openDoors()
			for(var/obj/machinery/door/G in oview(3, src))
				SPAWN_DBG(1 DECI SECOND)
				G.open()

		///Crowd control ability to stop people from running as easily, applies stagger
		staggerNearby()
			src.visible_message("<span class='alert'>[src] begins emitting a dark aura.</span>")
			sleep(3 SECONDS)
			for(var/mob/living/M in oview(4, src))
				if(!(M == src))
					boutput(M, "<span class='notice'>Your legs feel a bit stiff!</span>")
					M.setStatus("staggered", 8 SECONDS)

		///Gives the Slasher their abilities
		addAllAbilities()
			src.addAbility(/datum/targetable/slasher/help)
			src.addAbility(/datum/targetable/slasher/incorporeal)
			src.addAbility(/datum/targetable/slasher/corporeal)
			src.addAbility(/datum/targetable/slasher/soulsteal)
			src.addAbility(/datum/targetable/slasher/blood_trail)
			src.addAbility(/datum/targetable/slasher/summon_machete)
			src.addAbility(/datum/targetable/slasher/take_control)
			src.addAbility(/datum/targetable/slasher/regenerate)
			src.addAbility(/datum/targetable/slasher/open_doors)
			src.addAbility(/datum/targetable/slasher/stagger)

		updateButtons()
			abilityHolder.updateButtons()

/datum/abilityHolder/slasher
	usesPoints = 0
	regenRate = 0
	tabName = "Abilities"
	cast_while_dead = 0

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
	targeted = 0
	cooldown = 30 SECONDS

	cast()
		if(..())
			return 1

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		if(!W.density)
			boutput(usr, __red("<span class='alert'>You must be corporeal to use this ability.</span>"))
			return 1
		else
			if(usr.client)
				for (var/mob/living/L in view(usr.client.view, usr))
					if (isalive(L) && L.sight_check(1) && L.ckey != usr.ckey)
						boutput(usr, __red("<span class='alert'>You can only use that when nobody can see you!</span>"))
						return 1
		return W.incorporealize()

/datum/targetable/slasher/corporeal
	name = "Corporealize"
	desc = "Manifest your being, allowing you to interact with the world."
	icon_state = "corporealize"
	targeted = 0
	cooldown = 30 SECONDS

	cast()
		if(..())
			return 1

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		if(W.density)
			boutput(usr, __red("<span class='alert'>You must be incorporeal to use this ability.</span>"))
			return 1
		else
			return W.corporealize()

/datum/targetable/slasher/blood_trail
	name = "Blood Trail"
	desc = "Begin trailing blood behind you, to spook those who reside on station."
	icon_state = "trail_blood"
	targeted = 0
	cooldown = 5 SECONDS

	cast()
		if(..())
			return 1

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.blood_trail()

/datum/targetable/slasher/summon_machete
	name = "Summon Machete"
	desc = "Summon your machete to your active hand."
	icon_state = "summon_machete"
	targeted = 0
	cooldown = 15 SECONDS

	cast()
		if(..())
			return 1
		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.summon_machete()

/datum/targetable/slasher/take_control
	name = "Possess"
	desc = "Possess a target temporarily."
	icon_state = "slasher_possession"
	targeted = 1
	target_anything = 1
	cooldown = 3 MINUTES

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			var/mob/living/carbon/human/slasher/W = src.holder.owner
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

/datum/targetable/slasher/regenerate
	name = "Regenerate"
	desc = "Regenerate your body, and remove all restraints."
	icon_state = "regenerate"
	targeted = 0
	cooldown = 90 SECONDS

	cast()
		if(..())
			return 1

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.regenerate()

/datum/targetable/slasher/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "help"
	targeted = 0
	cooldown = 5 SECONDS
	helpable = 0
	special_screen_loc = "SOUTH,EAST"

	cast(atom/target)
		if (..())
			return 1
		if (holder.help_mode)
			holder.help_mode = 0
		else
			holder.help_mode = 1
			boutput(holder.owner, "<span class='notice'><strong>Help Mode has been activated  To disable it, click on this button again.</strong></span>")
			boutput(holder.owner, "<span class='notice'>Hold down Shift, Ctrl or Alt while clicking the button to set it to that key.</span>")
			boutput(holder.owner, "<span class='notice'>You will then be able to use it freely by holding that button and left-clicking a tile.</span>")
			boutput(holder.owner, "<span class='notice'>Alternatively, you can click with your middle mouse button to use the ability on your current tile.</span>")
		src.object.icon_state = "help[holder.help_mode]"
		holder.updateButtons()

/datum/targetable/slasher/open_doors
	name = "Open Nearby Doors"
	desc = "Open doors within three tiles of you."
	icon_state = "open_doors"
	targeted = 0
	cooldown = 25 SECONDS

	cast()
		if(..())
			return 1
		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.openDoors()

/datum/targetable/slasher/stagger
	name = "Stagger Area"
	desc = "Stagger everyone in a four tile radius of you for a short duration."
	icon_state = "stagger_group"
	targeted = 0
	cooldown = 45 SECONDS

	cast()
		if(..())
			return 1
		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.staggerNearby()

/datum/targetable/slasher/soulsteal
	name = "Soul Steal"
	desc = "Steal a corpse's soul, increasing the power of your machete."
	icon_state = "soul_steal"
	targeted = 1
	cooldown = 15 SECONDS

	cast(atom/target)
		if(..())
			return 1
		var/mob/living/carbon/human/slasher/W = src.holder.owner
		var/mob/living/carbon/human/M = target
		if(isdead(M))
			if(ishuman(M) && M.mind && M.mind.soul >= 100)
				if (get_dist(W, M) > 1)
					boutput(usr, "<span class='alert'>You must be closer in order to steal [M]'s soul.</span>")
					return 1
				else
					return W.soulStealSetup(M)
			else
				boutput(usr, "<span class='alert'>[M]'s soul is inadequate for your purposes.</span>")
				return 1

		else
			boutput(usr, "<span class='alert'>Your target must be dead to steal their soul.</span>")
			return 1
