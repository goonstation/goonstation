/mob/living/critter/brullbar
	name = "brullbar"
	desc = "Oh god."
	density = 1
	icon = 'icons/mob/critter/humanoid/brullbar.dmi'
	icon_state = "brullbar"
	icon_state_dead = "brullbar-dead"
	custom_gib_handler = /proc/gibs
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	blood_id = "beff"
	burning_suffix = "humanoid"
	skinresult = /obj/item/material_piece/cloth/brullbarhide
	max_skins = 3
	health_brute = 50
	health_brute_vuln = 0.6
	health_burn = 50
	health_burn_vuln = 1.3
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/brullbar
	is_npc = TRUE
	left_arm = /obj/item/parts/human_parts/arm/left/brullbar
	right_arm = /obj/item/parts/human_parts/arm/right/brullbar
	add_abilities = list(/datum/targetable/critter/fadeout/brullbar, /datum/targetable/critter/tackle, /datum/targetable/critter/frenzy)
	no_stamina_stuns = TRUE
	var/is_king = FALSE
	var/limbpath = /datum/limb/brullbar
	var/frenzypath = /datum/targetable/critter/frenzy

	faction = list(FACTION_ICEMOON)

	attackby(obj/item/W, mob/living/user)
		if (!isdead(src))
			return ..()
		if (issawingtool(W))
			var/datum/handHolder/HH
			if (user.zone_sel.selecting == "l_arm")
				HH = hands[1]
				if (!HH.limb)
					boutput(user, (SPAN_ALERT("<B> [src] has no left arm! </B>")))
					return
				actions.start(new/datum/action/bar/icon/critter_arm_removal(src, "left"), user)
			else if (user.zone_sel.selecting == "r_arm")
				HH = hands[2]
				if (!HH.limb)
					boutput(user, (SPAN_ALERT("<B> [src] has no right arm! </B>")))
					return
				actions.start(new/datum/action/bar/icon/critter_arm_removal(src, "right"), user)
			else return ..()

	on_pet()
		if (..())
			return TRUE
		if (prob(20) && !ON_COOLDOWN(src, "playsound", 3 SECONDS))
			playsound(src.loc, 'sound/voice/animal/brullbar_laugh.ogg', 60, 1)
			src.visible_message(SPAN_ALERT("<b>[src] laughs!</b>"))

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/brullbar_roar.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("<b>[src] howls!</b>")
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
		HH.limb = new src.limbpath
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left [is_king ? "king" : "" ] brullbar arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new src.limbpath
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right [is_king ? "king" : "" ] brullbar arm"

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
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

	valid_target(mob/living/C)
		if (istype(C, /mob/living/critter/brullbar)) return FALSE //don't kill other brullbars
		if (ishuman(C))
			var/mob/living/carbon/human/H = C
			if(!is_king && iswerewolf(H))
				src.visible_message(SPAN_ALERT("<b>[src] backs away in fear!</b>"))
				step_away(src, H, 15)
				src.set_dir(get_dir(src, H))
				return FALSE
		return ..()

	seek_target(var/range = 9)
		. = ..()

		if (length(.) && prob(10))
			playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 75, 1)
			src.visible_message(SPAN_ALERT("<B>[src]</B> roars!"))

	seek_scavenge_target(var/range = 9)
		. = list()
		for (var/mob/living/M in view(range, get_turf(src)))
			if (!isdead(M)) continue // eat everything yum
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.decomp_stage >= 3 || H.bioHolder?.HasEffect("husk")) continue //is dead, isn't a skeleton, isn't a grody husk
			. += M

	critter_ability_attack(var/mob/target)
		var/datum/targetable/critter/frenzy = src.abilityHolder.getAbility(src.frenzypath)
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (!tackle.disabled && tackle.cooldowncheck() && !is_incapacitated(target) && prob(30))
			tackle.handleCast(target) // no return to wack people with the frenzy after the tackle sometimes
			src.ai_attack_count = src.ai_attacks_per_ability //brullbars get to be evil and frenzy right away
			. = TRUE
		if (!frenzy.disabled && frenzy.cooldowncheck() && is_incapacitated(target) && prob(30))
			frenzy.handleCast(target)
			. = TRUE

	critter_basic_attack(mob/target)
		if (issilicon(target))
			fuck_up_silicons(target)
			return TRUE
		else
			return ..()

	critter_scavenge(var/mob/target)
		if (prob(30))
			src.visible_message(SPAN_ALERT("<b>[src] devours [target]! Holy shit!</b>"))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
			if (ishuman(target)) new /obj/fakeobject/skeleton(target.loc)
			target.ghostize()
			target.gib()
			return
		else
			src.visible_message("<span class='alert'<b>[src] bites a chunk out of [target]!</b></span>")
			playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1)
			src.HealDamage("All", 8, 4)
			return

	can_critter_attack()
		var/datum/targetable/critter/frenzy = src.abilityHolder.getAbility(src.frenzypath)
		var/datum/targetable/critter/fadeout = src.abilityHolder.getAbility(/datum/targetable/critter/fadeout/brullbar)
		return ..() && (!frenzy.disabled && !fadeout.disabled) // so they can't attack you while frenzying or while invisible (kinda)

	proc/fuck_up_silicons(var/mob/living/silicon/silicon) // modified orginal object critter behaviour scream
		if (isrobot(silicon) && !ON_COOLDOWN(src, "brullbar_messup_cyborg", 30 SECONDS))
			var/mob/living/silicon/robot/cyborg = silicon
			if (cyborg.part_head.ropart_get_damage_percentage() >= 85)
				src.visible_message(SPAN_ALERT("<B>[src] grabs [cyborg.name]'s head and wrenches it right off!</B>"))
				playsound(src.loc, 'sound/voice/animal/brullbar_laugh.ogg', 50, 1)
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
				cyborg.compborg_lose_limb(cyborg.part_head)
			else
				src.visible_message(SPAN_ALERT("<B>[src] pounds on [cyborg.name]'s head furiously!</B>"))
				playsound(src.loc, 'sound/voice/animal/brullbar_scream.ogg', 60, 1)
				playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
				cyborg.part_head.ropart_take_damage(rand(20,40),0)
		else
			src.visible_message(SPAN_ALERT("<B>[src] smashes [silicon] furiously!</B>"))
			playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
			random_brute_damage(silicon, 15, 0)

	proc/go_invis()
		var/datum/targetable/critter/fadeout = src.abilityHolder.getAbility(/datum/targetable/critter/fadeout/brullbar)
		if (!fadeout.disabled && fadeout.cooldowncheck())
			fadeout.handleCast(src)

	update_dead_icon()
		var/datum/handHolder/HH = hands[1]
		. = "brullbar-dead"
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
	desc = "You should run."
	icon_state = "brullbarking"
	icon_state_dead = "brullbarking-dead"
	skinresult = /obj/item/material_piece/cloth/kingbrullbarhide
	max_skins = 5
	health_brute = 250
	health_brute_vuln = 0.7
	health_burn = 250
	health_burn_vuln = 1.4
	left_arm = /obj/item/parts/human_parts/arm/left/brullbar/king
	right_arm = /obj/item/parts/human_parts/arm/right/brullbar/king
	add_abilities = list(/datum/targetable/critter/fadeout/brullbar, /datum/targetable/critter/tackle, /datum/targetable/critter/frenzy/king)
	is_king = TRUE
	limbpath = /datum/limb/brullbar/king
	frenzypath = /datum/targetable/critter/frenzy/king

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
