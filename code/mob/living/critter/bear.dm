/mob/living/critter/bear
	name = "space bear"
	desc = "WOORGHHH"
	icon = 'icons/mob/critter/humanoid/bear.dmi'
	icon_state = "abear"
	icon_state_dead = "abear-dead"
	custom_gib_handler = /proc/gibs
	hand_count = 2
	can_throw = FALSE
	can_grab = TRUE
	can_disarm = TRUE
	blood_id = "methamphetamine"
	burning_suffix = "humanoid"
	skinresult = /obj/item/material_piece/cloth/leather
	max_skins = 2
	health_brute = 50
	health_brute_vuln = 0.85
	health_burn = 50
	health_burn_vuln = 1.25
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/aggressive/scavenger
	is_npc = TRUE
	left_arm = /obj/item/parts/human_parts/arm/left/bear
	right_arm = /obj/item/parts/human_parts/arm/right/bear
	add_abilities = list(/datum/targetable/critter/tackle)
	no_stamina_stuns = TRUE
	var/droparms = TRUE

	on_pet(mob/user)
		if (..())
			return TRUE
		user.unlock_medal("Bear Hug", 1) //new method to get since obesity is removed

	attackby(obj/item/W, mob/living/user)
		if (!isdead(src))
			return ..()
		if (issawingtool(W) && src.droparms)
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

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/MEraaargh.ogg', 70, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("<b>[src] roars!</b>")
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
		HH.limb = new /datum/limb/bear
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left bear arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/bear
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right bear arm"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src) // lives in dark places
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/spacebear, src) // bit faster than your average critter (meth)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "bear", 50) // METH
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "bear", 50)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "bear", 3)
		src.add_stam_mod_max("bear", 50)

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (!tackle.disabled && tackle.cooldowncheck())
			tackle.handleCast(target)
			return TRUE

	critter_basic_attack(mob/target)
		if(!ON_COOLDOWN(src, "bear_scream", 3 SECONDS))
			src.visible_message(SPAN_ALERT("<b>[src] roars!</b>"))
			if(istype(src, /mob/living/critter/bear/care))
				playsound(src.loc, 'sound/voice/babynoise.ogg', 40, 0)
			else
				playsound(src.loc, 'sound/voice/MEraaargh.ogg', 40, 0)
		return ..()

	critter_scavenge(var/mob/target)
		src.visible_message("<span class='alert'<b>[src] nibbles [target]!</b></span>")
		playsound(src.loc, 'sound/items/eatfood.ogg', 20, 1)
		src.HealDamage("All", 4, 4)
		return ..()

	update_dead_icon()
		var/datum/handHolder/HH = hands[1]
		. = "abear-dead"
		if (!HH.limb)
			. += "-l"
		HH = hands[2]
		if (!HH.limb)
			. += "-r"
		icon_state = .

/mob/living/critter/bear/care
	name = "space carebear"
	desc = "I love you!"
	icon_state = "carebear"
	icon_state_dead = "carebear-dead"
	droparms = FALSE

	New()
		..()
		src.name = pick("Lovealot Bear", "Stuffums", "World Destroyer", "Pookie", "Colonel Sanders", "Hugbeast", "Lovely Bear", "HUG ME", "Empathy Bear", "Steve", "Mr. Pants", "wonk")
		src.real_name = src.name

