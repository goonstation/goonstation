var/list/snd_macho_rage = list('sound/voice/macho/macho_alert13.ogg', 'sound/voice/macho/macho_alert16.ogg', 'sound/voice/macho/macho_alert24.ogg',\
'sound/voice/macho/macho_become_alert54.ogg', 'sound/voice/macho/macho_become_alert56.ogg', 'sound/voice/macho/macho_rage_55.ogg', 'sound/voice/macho/macho_shout07.ogg',\
'sound/voice/macho/macho_rage_58.ogg', 'sound/voice/macho/macho_rage_61.ogg', 'sound/voice/macho/macho_rage_64.ogg', 'sound/voice/macho/macho_rage_68.ogg',\
'sound/voice/macho/macho_rage_71.ogg', 'sound/voice/macho/macho_rage_72.ogg', 'sound/voice/macho/macho_rage_73.ogg', 'sound/voice/macho/macho_rage_78.ogg',\
'sound/voice/macho/macho_rage_79.ogg', 'sound/voice/macho/macho_rage_80.ogg', 'sound/voice/macho/macho_rage_81.ogg', 'sound/voice/macho/macho_rage_54.ogg',\
'sound/voice/macho/macho_rage_55.ogg')

var/list/snd_macho_idle = list('sound/voice/macho/macho_alert16.ogg', 'sound/voice/macho/macho_alert22.ogg',\
'sound/voice/macho/macho_breathing01.ogg', 'sound/voice/macho/macho_breathing13.ogg', 'sound/voice/macho/macho_breathing18.ogg',\
'sound/voice/macho/macho_idle_breath_01.ogg', 'sound/voice/macho/macho_mumbling04.ogg', 'sound/voice/macho/macho_moan03.ogg',\
'sound/voice/macho/macho_mumbling05.ogg', 'sound/voice/macho/macho_mumbling07.ogg', 'sound/voice/macho/macho_shout08.ogg')

/mob/living/carbon/human/machoman
	var/list/macho_arena_turfs // NOTE: remove this and the clean_up_arena_turfs proc on the mob if we get around to getting rid of the macho verbs
	var/pseudo = FALSE

	New(loc, pseudo)
		..()
		src.gender = MALE
		src.real_name = pick("M", "m") + pick("a", "ah", "ae") + pick("ch", "tch", "tz") + pick("o", "oh", "oe") + " " + pick("M","m") + pick("a","ae","e") + pick("n","nn")

		if (pseudo)
			src.pseudo = pseudo

		if (!src.reagents)
			src.create_reagents(1000)

		src.changeStatus("stimulants", 15 MINUTES)

		src.equip_new_if_possible(/obj/item/clothing/shoes/macho, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/clothing/under/gimmick/macho, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/suit/armor/vest/macho, SLOT_WEAR_SUIT)
		src.equip_new_if_possible(/obj/item/clothing/glasses/macho, SLOT_GLASSES)
		src.equip_new_if_possible(/obj/item/clothing/head/helmet/macho, SLOT_HEAD)
		src.equip_new_if_possible(/obj/item/storage/belt/macho_belt, SLOT_BELT)
		src.equip_new_if_possible(/obj/item/device/radio/headset, SLOT_EARS)

		if(!src.pseudo)
			for (var/datum/targetable/macho/A as() in concrete_typesof(/datum/targetable/macho))
				src.abilityHolder.addAbility(A)

		else
			src.abilityHolder.addAbility(/datum/targetable/macho/macho_heal)
			var/list/dangerousVerbs = list(\
				/mob/living/carbon/human/machoman/verb/macho_offense,\
				/mob/living/carbon/human/machoman/verb/macho_defense,\
				/mob/living/carbon/human/machoman/verb/macho_normal,\
				/mob/living/carbon/human/machoman/verb/macho_grasp,\
				/mob/living/carbon/human/machoman/verb/macho_headcrunch,\
				/mob/living/carbon/human/machoman/verb/macho_chestcrunch,\
				/mob/living/carbon/human/machoman/verb/macho_leap,\
				/mob/living/carbon/human/machoman/verb/macho_rend,\
				/mob/living/carbon/human/machoman/verb/macho_touch,\
				/mob/living/carbon/human/machoman/verb/macho_piledriver,\
				/mob/living/carbon/human/machoman/verb/macho_superthrow,\
				/mob/living/carbon/human/machoman/verb/macho_soulsteal,\
				/mob/living/carbon/human/machoman/verb/macho_stare,\
				/mob/living/carbon/human/machoman/verb/macho_heartpunch,\
				/mob/living/carbon/human/machoman/verb/macho_summon_arena,\
				/mob/living/carbon/human/machoman/verb/macho_slimjim_snap)
			src.verbs -= dangerousVerbs

		src.abilityHolder.updateButtons()

	disposing()
		. = ..()
		if (macho_arena_turfs)
			src.clean_up_arena_turfs(src.macho_arena_turfs) // cleans up the macho_arena_turfs reference while animating the arena disappearing

	initializeBioholder()
		src.bioHolder.mobAppearance.customizations["hair_bottom"].style = new /datum/customization_style/hair/long/dreads
		src.bioHolder.mobAppearance.customizations["hair_middle"].style =  new /datum/customization_style/beard/fullbeard
		. = ..()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if (!src.stat && prob(6))
			src.visible_message("<b>[src]</b> mutters to himself.")
			playsound(src.loc, pick(snd_macho_idle), 50, 0, 0, src.get_age_pitch())

	show_inv(mob/user)
		if (src.stance == "defensive")
			macho_parry(user)
			return
		..()
		return

	attack_hand(mob/user)
		if (src.stance == "defensive")
			src.visible_message(SPAN_ALERT("<B>[user] attempts to attack [src]!</B>"))
			playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, 1)
			SPAWN(0.2 SECONDS)
				macho_parry(user)
			return
		..()
		return

	attackby(obj/item/W, mob/user)
		if (src.stance == "defensive")
			src.visible_message(SPAN_ALERT("<B>[user] swings at [src] with the [W.name]!</B>"))
			playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, 1)
			sleep(0.2 SECONDS)
			macho_parry(user, W)
			return
		..()
		return

	bump(atom/movable/AM)
		if (src.stance == "offensive")
			if ( src.now_pushing)
				return
			now_pushing = 1
			if (ismob(AM))
				var/mob/M = AM
				boutput(src, SPAN_ALERT("<B>You power-clothesline [M]!</B>"))
				for (var/mob/C in oviewers(src))
					shake_camera(C, 8, 24)
					C.show_message(SPAN_ALERT("<B>[src] clotheslines [M] into oblivion!</B>"), 1)
				M.changeStatus("stunned", 8 SECONDS)
				M.changeStatus("knockdown", 5 SECONDS)
				var/turf/target = get_edge_target_turf(src, src.dir)
				M.throw_at(target, 10, 2)
				playsound(src.loc, "swing_hit", 40, 1)
			else if (isobj(AM))
				var/obj/O = AM
				if (O.density)
					playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
					if (istype(O, /obj/machinery/door))
						var/obj/machinery/door/D = O
						if (D.open())
							boutput(src, SPAN_ALERT("<B>You forcefully kick open [D]!</B>"))
							for (var/mob/C in oviewers(D))
								shake_camera(C, 8, 24)
								C.show_message(SPAN_ALERT("<B>[src] forcefully kicks open [D]!</B>"), 1)
						else
							boutput(src, SPAN_ALERT("<B>You forcefully kick [D]!</B>"))
							for (var/mob/C in oviewers(src))
								shake_camera(C, 8, 24)
								C.show_message(SPAN_ALERT("<B>[src] forcefully kicks [D]!</B>"), 1)
							if (prob(33))
								qdel(D)
					else if(O.anchored != 2)
						boutput(src, SPAN_ALERT("<B>You crash into [O]!</B>"))
						for (var/mob/C in oviewers(src))
							shake_camera(C, 8, 24)
							C.show_message(SPAN_ALERT("<B>[src] crashes into [O]!</B>"), 1)
						if ((istype(O, /obj/window) && !istype(O, /obj/window/auto/reinforced/indestructible)) || istype(O, /obj/mesh/grille) || istype(O, /obj/machinery/door) || istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
							qdel(O)
						else
							var/turf/target = get_edge_target_turf(src, src.dir)
							O.throw_at(target, 10, 2)
			now_pushing = 0
		else
			..()
			return

	proc/macho_parry(mob/M, obj/item/W)
		if (M)
			src.set_dir(get_dir(src, M))
			if (W)
				W.cant_self_remove = 0
				W.set_loc(src)
				M.u_equip(W)
				W.layer = HUD_LAYER
				src.put_in_hand_or_drop(W)
				src.visible_message(SPAN_ALERT("<B>[src] grabs the [W.name] out of [M]'s hands, shoving [M] to the ground!</B>"))
			else
				src.visible_message(SPAN_ALERT("<B>[src] parries [M]'s attack, knocking them to the ground!</B>"))
			M.changeStatus("knockdown", 10 SECONDS)
			playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 65, 1)
			SPAWN(2 SECONDS)
				playsound(src.loc, pick(snd_macho_rage), 60, 0, 0, src.get_age_pitch())
		return

	// Verbs

	verb/macho_offense()
		set name = "Stance - Offensive"
		set desc = "Take an offensive stance and tackle people in your way"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			src.stance = "offensive"

	verb/macho_defense()
		set name = "Stance - Defensive"
		set desc = "Take a defensive stance and counter any attackers"
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			src.stance = "defensive"

	verb/macho_normal()
		set name = "Stance - Normal"
		set desc = "We all know this stance is for boxing the hell out of dudes."
		set category = "Macho Moves"
		if (!src.stat && !src.transforming)
			src.stance = "normal"

	verb/macho_grasp()
		set name = "Macho Grasp"
		set desc = "Instantly grab someone in a headlock"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_grasp/macho_grasp = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_grasp)
		if (macho_grasp)
			var/mob/M = usr
			M.targeting_ability = macho_grasp
			M.update_cursor()

	verb/macho_headcrunch()
		set name = "Grapple - Headcruncher"
		set desc = "Pulverize the head of a dude you grabbed"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_grasp/macho_headcrunch/macho_headcrunch = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_grasp/macho_headcrunch)
		if (macho_headcrunch)
			macho_headcrunch.cast()

	verb/macho_chestcrunch()
		set name = "Grapple - Ribcracker"
		set desc = "Pulverize the ribcage of a dude you grabbed"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_chestcrunch/macho_chestcrunch = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_chestcrunch)
		if (macho_chestcrunch)
			macho_chestcrunch.cast()

	verb/macho_leap()
		set name = "Macho Leap"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_leap/macho_leap = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_leap)
		if (macho_leap)
			macho_leap.cast()

	verb/macho_rend()
		set name = "Macho Rend"
		set desc = "Tears a target limb from limb"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_rend/macho_rend = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_rend)
		if (macho_rend)
			macho_rend.cast()

	verb/macho_summon_arena()
		set name = "Macho Arena"
		set desc = "Summon a wrestling ring."
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_summon_arena/macho_arena = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_summon_arena)
		if (macho_arena)
			macho_arena.cast()

	proc/clean_up_arena_turfs(var/list/arena_turfs_to_cleanup) // if we get to removing the verbs, remove this and the arena_turfs var on the mob too
		src.macho_arena_turfs = null
		for (var/obj/decal/boxingrope/F in arena_turfs_to_cleanup)
			SPAWN(0)
				leaving_animation(F)
				qdel(F)
		for (var/obj/stool/chair/boxingrope_corner/F in arena_turfs_to_cleanup)
			SPAWN(0)
				leaving_animation(F)
				qdel(F)

	verb/macho_slimjim_snap()
		set name = "Macho Slim-Jim Snap"
		set desc = "Snaps a target into a slim jim."
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_slimjim_snap/macho_slimjim_snap = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_slimjim_snap)
		if (macho_slimjim_snap)
			macho_slimjim_snap.cast()

	verb/macho_touch()
		set name = "Macho Touch"
		set desc = "Transmutes a living target into gold"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_touch/macho_touch = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_touch)
		if (macho_touch)
			macho_touch.cast()

	verb/macho_piledriver()
		set name = "Atomic Piledriver"
		set desc = "Piledrive a target"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_piledriver/macho_piledriver = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_piledriver)
		if (macho_piledriver)
			macho_piledriver.cast()

	verb/macho_superthrow()
		set name = "Macho Throw"
		set desc = "Throw someone super hard"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_superthrow/macho_superthrow = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_superthrow)
		if (macho_superthrow)
			macho_superthrow.cast()

	verb/macho_soulsteal()
		set name = "Macho Soul Steal"
		set desc = "Steals a target's soul to restore health"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_soulsteal/macho_soulsteal = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_soulsteal)
		if (macho_soulsteal)
			macho_soulsteal.cast()

	verb/macho_heal()
		set name = "Macho Healing"
		set desc = "Sacrifice your health to heal someone else"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_heal/macho_heal = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_heal)
		if (macho_heal)
			macho_heal.cast()

	verb/macho_stare()
		set name = "Macho Stare"
		set desc = "Stares deeply at a victim, causing them to explode"
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_stare/macho_stare = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_stare)
		if (macho_stare)
			macho_stare.cast()

	verb/macho_heartpunch()
		set name = "Macho Heartpunch"
		set desc = "Punches a guy's heart. Right out of their body."
		set category = "Macho Moves"

		var/datum/targetable/macho/macho_heartpunch/macho_heartpunch = usr.abilityHolder.getAbility(/datum/targetable/macho/macho_heartpunch)
		if (macho_heartpunch)
			var/mob/M = usr
			M.targeting_ability = macho_heartpunch
			M.update_cursor()

	emote(var/act, var/emoteTarget = null)
		switch(act)
			if ("scream")
				if (src.pseudo)
					..()
				else
					playsound(src.loc, pick(snd_macho_rage), 75, 0, 0, src.get_age_pitch())
					src.visible_message(SPAN_ALERT("<b>[src] yells out a battle cry!</b>"))
			else
				..()

/mob/living/critter/microman
	name = "Micro Man"
	desc = "All the macho madness you'd ever need, shrunk down to pocket size."
	icon = 'icons/mob/critter/humanoid/microman.dmi'
	icon_state = "microman"
	is_npc = TRUE
	ai_type = /datum/aiHolder/aggressive
	can_lie = FALSE
	butcherable = BUTCHER_NOT_ALLOWED
	health_brute = 25
	health_burn = 25
	health_brute_vuln = 1
	health_burn_vuln = 1
	hand_count = 1
	add_abilities = list(/datum/targetable/critter/weak_tackle)
	ai_attacks_per_ability = 1
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	use_stamina = FALSE

	New()
		. = ..()
		if (prob(50))
			playsound(src.loc, pick(snd_macho_rage), 50, 1, 0, 1.75)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	// microman does teensy damage, just enough to reliably punch through armor
	calculate_melee_attack(mob/target, base_damage_low, base_damage_high, extra_damage, stamina_damage_mult, can_crit, can_punch, can_kick, datum/limb/limb)
		. = ..(target, 2, 3, extra_damage, stamina_damage_mult, can_crit, can_punch, can_kick, limb)

	critter_attack(mob/target)
		. = ..()
		playsound(src.loc, "swing_hit", 30, 0)
		if (prob(10))
			playsound(src.loc, pick(snd_macho_rage), 50, 1, 0, 1.75)

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/weak_tackle/pounce = src.abilityHolder.getAbility(/datum/targetable/critter/weak_tackle)
		if(pounce && !pounce.disabled && pounce.cooldowncheck())
			pounce.handleCast(target)
			if (prob(50))
				playsound(src.loc, pick(snd_macho_rage), 50, 1, 0, 1.75)
			return TRUE

	valid_target(mob/living/C)
		if (is_incapacitated(C)) return FALSE
		return ..()

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if (prob(10))
			playsound(src.loc, pick(snd_macho_idle), 50, 1, 0, 1.75)

	death(gibbed, do_drop_equipment)
		if(!gibbed)
			src.visible_message("[src] explodes in a shower of meat!")
			return src.gib()
		. = ..()

/obj/item/clothing/under/gimmick/macho
	name = "wrestling pants"
	desc = "Official pants of the Space Wrestling Federation."
	icon_state = "machopants"
	item_state = "machopants"

	random_color
		icon_state = "machopants_base"
		item_state = "machopants_base"

		New()
			..()
			src.color = random_saturated_hex_color(1)

/obj/item/clothing/suit/armor/vest/macho
	name = "tiger stripe vest"
	desc = "A flamboyant showman's vest."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "machovest"
	item_state = "machovest"

	attack_self(mob/user as mob)
		return

/obj/item/clothing/glasses/macho
	name = "Yellow Shades"
	desc = "A snazzy pair of shades."
	icon_state = "machoglasses"
	item_state = "glasses"
	wear_layer = MOB_GLASSES_LAYER2

/obj/item/clothing/head/helmet/macho
	name = "Macho Man Doo-Rag"
	desc = "'To my perfect friend' - signed, Mr. Perfect"
	icon_state = "machohat"

/obj/item/storage/belt/macho_belt
	name = "Championship Belt"
	desc = "Awarded to the best space wrestler of the year."
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "machobelt"
	item_state = "machobelt"
	flags = TABLEPASS | NOSPLASH
	c_flags = ONBELT

/obj/item/clothing/shoes/macho
	name = "Wrestling boots"
	desc = "Cool pair of boots."
	icon_state = "machoboots"

/obj/item/macho_coke
	name = "unmarked white bag"
	desc = "Contains columbian sugar."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "cokebag"
	item_state = "chefhat" // lol
	w_class = W_CLASS_TINY

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (istype(target, /mob/living/carbon/human/machoman))
			target.visible_message(SPAN_ALERT("[target] shoves [his_or_her(target)] face deep into [src] and breathes deeply!"))
			playsound(target.loc, 'sound/voice/macho/macho_breathing02.ogg', 50, 1)
			sleep(2.5 SECONDS)
			playsound(target.loc, 'sound/voice/macho/macho_freakout.ogg', 50, 1)
			target.visible_message(SPAN_ALERT("[target] appears visibly stronger!"))
			target.changeStatus("stimulants", 7.5 MINUTES)
			if (ishuman(target))
				var/mob/living/carbon/human/machoman/H = target
				H.HealDamage("All", 50, 50, 50)
				H.UpdateDamageIcon()
				H.bodytemperature = H.base_body_temp
		else
			target.visible_message(SPAN_ALERT("[target] shoves [his_or_her(target)] face deep into [src]!"))
			SPAWN(2.5 SECONDS)
			target.visible_message(SPAN_ALERT("[target]'s pupils dilate."))
			target.changeStatus("stunned", 10 SECONDS)

/obj/item/reagent_containers/food/snacks/slimjim
	name = "Space Jim"
	desc = "It's a stick of mechanically-separated mystery meat."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "slimjim"
	item_state = "stamp"
	heal_amt = 2
	bites_left = 5
	initial_volume = 50
	initial_reagents = list("capsaicin"=20,"porktonium"=30)

	attack(var/mob/M, var/mob/user, def_zone)
		if (istype(M, /mob/living/carbon/human/machoman) && M == user)
			playsound(user.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 75, 1)
			playsound(user.loc, 'sound/voice/macho/macho_slimjim.ogg', 60)
			for (var/mob/O in viewers(user))
				O.show_message(SPAN_ALERT("<B>[user] snaps into a Space Jim!!</B>"), 1)
			sleep(rand(10,20))
			var/turf/T = get_turf(M)
			playsound(user.loc, "explosion", 100, 1)
			SPAWN(0)
				var/obj/overlay/O = new/obj/overlay(T)
				O.anchored = ANCHORED
				O.name = "Explosion"
				O.layer = NOLIGHT_EFFECTS_LAYER_BASE
				O.pixel_x = -92
				O.pixel_y = -96
				O.icon = 'icons/effects/214x246.dmi'
				O.icon_state = "explosion"
				for (var/mob/N in viewers(user))
					shake_camera(N, 8, 24)
				sleep(3.5 SECONDS)
				qdel(O)
			SPAWN(0)
				var/obj/item/old_grenade/emp/temp_nade = new(user.loc)
				temp_nade.detonate()
			SPAWN(0)
				for (var/atom/A in range(user.loc, 4))
					if (ismob(A) && A != user)
						var/mob/N = A
						N.changeStatus("knockdown", 8 SECONDS)
						step_away(N, user)
						step_away(N, user)
					else if (isobj(A) || isturf(A))
						A.ex_act(3)
		else
			..()

