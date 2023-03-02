/mob/living/critter/brullbar
	name = "brullbar"
	real_name = "brullbar"
	desc = "Oh god."
	density = 1
	icon_state = "brullbar"
	icon_state_dead = "brullbar"
	custom_gib_handler = /proc/gibs
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	blood_id = "beff"
	burning_suffix = "humanoid"
	skinresult = /obj/item/material_piece/cloth/brullbarhide
	max_skins = 3
	health_brute = 50
	health_brute_vuln = 0.6
	health_burn = 50
	health_burn_vuln = 1.3
	ai_type = /datum/aiHolder/brullbar
	is_npc = TRUE
	left_arm = /obj/item/parts/human_parts/arm/left/brullbar
	right_arm = /obj/item/parts/human_parts/arm/right/brullbar
	var/is_king = FALSE

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (!isdead(src))
			retaliate()
			return ..()
		if (issawingtool(W))
			var/datum/handHolder/HH
			if (user.zone_sel.selecting == "l_arm")
				HH = hands[1]
				if (!HH.limb)
					boutput(user, ("<span class='alert'><B> [src] has no left arm! </B></span>"))
					return
				actions.start(new/datum/action/bar/icon/critter_arm_removal(src, "left"), user)
			else if (user.zone_sel.selecting == "r_arm")
				HH = hands[2]
				if (!HH.limb)
					boutput(user, ("<span class='alert'><B> [src] has no right arm! </B></span>"))
					return
				actions.start(new/datum/action/bar/icon/critter_arm_removal(src, "right"), user)
			else return ..()

	attack_hand(var/mob/user as mob)
		if (user.a_intent != INTENT_HELP) // pets only or you get the claws, but you would get those anyway so...
			retaliate(user)
		..()

	on_pet()
		if (..())
			return TRUE
		if (prob(20) && !ON_COOLDOWN(src, "playsound", 3 SECONDS))
			playsound(src.loc, 'sound/voice/animal/brullbar_laugh.ogg', 60, 1)
			src.visible_message("<span class='alert'><b>[src] laughs!</b></span>", 1)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/brullbar_roar.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b><span class='alert'>[src] howls!</span></b>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/suit(src)
		equipment += new /datum/equipmentHolder/ears(src)
		equipment += new /datum/equipmentHolder/head(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = (is_king ? new /datum/limb/brullbar/king : new /datum/limb/brullbar)
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left [is_king ? "king" : "" ] brullbar arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = (is_king ? new /datum/limb/brullbar/king : new /datum/limb/brullbar)
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right [is_king ? "king" : "" ] brullbar arm"

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/fadeout/brullbar)
		abilityHolder.addAbility(/datum/targetable/critter/tackle)
		abilityHolder.addAbility(/datum/targetable/critter/frenzy)
		if (src.is_king) // kings are built like tanks
			src.add_stam_mod_max("brullbar", 100)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_BODY, "brullbar", 20)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_BODY_MAX, "brullbar", 20)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "brullbar", 50)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "brullbar", 50)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "brullbar", 10)
		else // normal ones are still strong
			src.add_stam_mod_max("brullbar", 40)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "brullbar", 20)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "brullbar", 20)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)

	seek_target(var/range = 9)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isdead(C)) continue
			if (isintangible(C)) continue //don't attack what you can't touch
			if (istype(C, /mob/living/critter/brullbar)) continue //don't kill other brullbars
			if (ishuman(C))
				var/mob/living/carbon/human/H = C
				if(!is_king && iswerewolf(H))
					src.visible_message("<span class='alert'><b>[src] backs away in fear!</b></span>")
					step_away(src, H, 15)
					src.set_dir(get_dir(src, H))
					continue
			. += C

		if (length(.) && prob(10))
			playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 75, 1)
			src.visible_message("<span class='alert'><B>[src]</B> roars!</span>")

	seek_scavenge_target(var/range = 9)
		. = list()
		for (var/mob/living/M in view(range, get_turf(src)))
			if (!isdead(M)) continue // eat everything yum
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.decomp_stage >= 3 || H.bioHolder?.HasEffect("husk")) continue //is dead, isn't a skeleton, isn't a grody husk
			. += M

	critter_attack(var/mob/target)
		var/datum/targetable/critter/frenzy = src.abilityHolder.getAbility(/datum/targetable/critter/frenzy)
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (!tackle.disabled && tackle.cooldowncheck() && prob(20) && !is_incapacitated(target))
			tackle.handleCast(target) // no return to wack people with the frenzy after the tackle sometimes
		if (!frenzy.disabled && frenzy.cooldowncheck() && prob(40))
			frenzy.handleCast(target)
		else if (issilicon(target))
			fuck_up_silicons(target)
		else
			return ..()

	critter_scavenge(var/mob/target)
		if (prob(30))
			src.visible_message("<span class='alert'><b>[src] devours [target]! Holy shit!</b></span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
			if (ishuman(target)) new /obj/decal/fakeobjects/skeleton(target.loc)
			target.ghostize()
			target.gib()
			return
		else
			src.visible_message("<span class='alert'<b>[src] bites a chunk out of [target]!</b></span>")
			playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1)
			for(var/damage_type in src.healthlist)
				var/datum/healthHolder/hh = src.healthlist[damage_type]
				hh.HealDamage(10)
			return

	can_critter_attack()
		var/datum/targetable/critter/fadeout = src.abilityHolder.getAbility(/datum/targetable/critter/fadeout/brullbar)
		var/datum/targetable/critter/frenzy = src.abilityHolder.getAbility(/datum/targetable/critter/frenzy)
		return can_act(src,TRUE) && !frenzy.disabled || !fadeout.disabled // so they can't attack you while frenzying or while invisible (kinda)

	proc/retaliate(var/mob/living/attacker) // somewhat stolen from sawfly behaviour, no beating on a confused brullbar
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (!istype(attacker, /mob/living/critter/brullbar) || (attacker.health < 0))
			if (prob(50) && !tackle.disabled && tackle.cooldowncheck() && !isdead(src))
				src.visible_message("<span class='alert'><b>[src] lunges at [attacker]!</b></span>")
				playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 50, 1)
				tackle.handleCast(attacker)
				ai.interrupt()

	proc/fuck_up_silicons(var/mob/living/silicon/silicon) // taken from orginal object critter behaviour scream
		if (isrobot(silicon) && !ON_COOLDOWN(src, "brullbar_messup_silicon", 30 SECONDS))
			var/mob/living/silicon/robot/BORG = silicon
			if (BORG.part_head.ropart_get_damage_percentage() >= 85)
				src.visible_message("<span class='alert'><B>[src] grabs [BORG.name]'s head and wrenches it right off!</B></span>")
				playsound(src.loc, 'sound/voice/animal/brullbar_laugh.ogg', 50, 1)
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
				BORG.compborg_lose_limb(BORG.part_head)
			else
				src.visible_message("<span class='alert'><B>[src] pounds on [BORG.name]'s head furiously!</B></span>")
				playsound(src.loc, 'sound/voice/animal/brullbar_scream.ogg', 60, 1)
				playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
				BORG.part_head.ropart_take_damage(rand(20,40),0)
		else
			src.visible_message("<span class='alert'><B>[src] smashes [silicon] furiously!</B></span>")
			playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
			random_brute_damage(silicon, 15, 0)

	proc/go_invis()
		var/datum/targetable/critter/fadeout = src.abilityHolder.getAbility(/datum/targetable/critter/fadeout/brullbar)
		if (!fadeout.disabled && fadeout.cooldowncheck())
			fadeout.handleCast(src)

	update_dead_icon()
		var/datum/handHolder/HH = hands[1]
		. = "brullbar"
		if (!HH.limb)
			. += "-l"
		HH = hands[2]
		if (!HH.limb)
			. += "-r"
		icon_state = .

	death()
		..()
		if (is_king) return // king has his own death noises, spooky
		playsound(src.loc, 'sound/voice/animal/brullbar_cry.ogg', 50, 1)

/mob/living/critter/brullbar/king
	name = "brullbar king"
	real_name = "brullbar king"
	desc = "You should run."
	icon_state = "brullbarking"
	icon_state_dead = "brullbarking"
	skinresult = /obj/item/material_piece/cloth/kingbrullbarhide
	max_skins = 5
	health_brute = 250
	health_brute_vuln = 0.7
	health_burn = 250
	health_burn_vuln = 1.4
	is_king = TRUE
	left_arm = /obj/item/parts/human_parts/arm/left/brullbar/king
	right_arm = /obj/item/parts/human_parts/arm/right/brullbar/king

	death()
		..()
		playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 60, 1)
		playsound(src.loc, 'sound/voice/animal/brullbar_cry.ogg', 60, 1)

/mob/living/critter/brullbar/strong //orginal health for admin spawns
	health_brute = 100
	health_brute_vuln = 0.7
	health_burn = 100
	health_burn_vuln = 1.4

////////////////
////// e-egg?
///////////////

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/brullbar
	name = "brullbar egg"
	desc = "They lay eggs?!"
	critter_type = /mob/living/critter/brullbar
	warm_count = 100
	critter_reagent = "ice"
