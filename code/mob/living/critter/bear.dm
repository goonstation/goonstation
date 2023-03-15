/mob/living/critter/bear
	name = "space bear"
	real_name = "space bear"
	desc = "Oh god."
	density = 1
	icon_state = "abear"
	icon_state_dead = "abear-dead"
	custom_gib_handler = /proc/gibs
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	blood_id = "methamphetamine"
	burning_suffix = "humanoid"
	health_brute = 75
	health_brute_vuln = 0.85
	health_burn = 75
	health_burn_vuln = 1.25
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/bear
	is_npc = TRUE
	left_arm = /obj/item/parts/human_parts/arm/left/bear
	right_arm = /obj/item/parts/human_parts/arm/right/bear

	on_pet(mob/user)
		if (..())
			return 1
		user.unlock_medal("Bear Hug", 1) //new method to get since obesity is removed

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (!isdead(src))
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

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/MEraaargh.ogg', 70, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b><span class='alert'>[src] roars!</span></b>"
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
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "bear", 50) // bear terminally on meth
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "bear", 50)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "bear", 5)
		abilityHolder.addAbility(/datum/targetable/critter/tackle)
		src.add_stam_mod_max("bear", 50)

	critter_attack(var/mob/target)
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (!tackle.disabled && tackle.cooldowncheck())
			tackle.handleCast(target)
		else
			playsound(src.loc, pick('sound/voice/MEraaargh.ogg'), 40, 0)
			return ..()

	update_dead_icon()
		var/datum/handHolder/HH = hands[1]
		. = "abear"
		if (!HH.limb)
			. += "-l"
		HH = hands[2]
		if (!HH.limb)
			. += "-r"
		icon_state = .
