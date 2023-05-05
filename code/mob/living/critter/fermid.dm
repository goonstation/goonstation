///////////////////////////////////////////////
// FERMID LIMBS (basically tweaked bee limbs)
///////////////////////////////////////////////

/datum/limb/small_critter/fermid // can hold slightly larger things than base small critter
	max_wclass = W_CLASS_NORMAL
	actions = list("jabs", "prods", "pokes", "taps")
	sound_attack = 'sound/impact_sounds/Flesh_Stab_1.ogg'

/datum/limb/mouth/fermid
	var/list/bite_adjectives = list("vicious","vengeful","violent")
	sound_attack = 'sound/impact_sounds/Flesh_Tear_1.ogg'

	harm(mob/target, var/mob/user)
		if (!user || !target)
			return 0
		if (!target.melee_attack_test(user))
			return
		src.custom_msg = "<b><span class='combat'>[user] bites [target] with [his_or_her(user)] [pick(src.bite_adjectives)] mandibles!</span></b>"
		..()

///////////////////////////////////////////////
// FERMID
///////////////////////////////////////////////

/mob/living/critter/fermid
	name = "fermid"
	real_name = "fermid"
	desc = "Extremely hostile asteroid-dwelling bugs. Best to avoid them wherever possible."
	icon_state = "fermid"
	icon_state_dead = "fermid-dead"
	speechverb_say = "clicks"
	speechverb_exclaim = "clacks"
	speechverb_ask = "chitters"
	speechverb_gasp = "rattles"
	speechverb_stammer = "click-clacks"
	butcherable = TRUE
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	hand_count = 3
	reagent_capacity = 100
	health_brute = 25
	health_brute_vuln = 1
	health_burn = 25
	health_burn_vuln = 0.1
	is_npc = TRUE
	ai_type = /datum/aiHolder/wanderer_aggressive
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	add_abilities = list(/datum/targetable/critter/bite/fermid_bite, /datum/targetable/critter/sting/fermid)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth/fermid
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mandibles"
		HH.can_hold_items = FALSE

		HH = hands[2]
		HH.limb = new /datum/limb/small_critter/fermid
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"
		HH.name = "left foot"
		HH.limb_name = "foot"

		HH = hands[3]
		HH.limb = new /datum/limb/small_critter/fermid
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handr"
		HH.name = "right foot"
		HH.limb_name = "foot"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","hiss","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> chitters!"
			if ("snap","clack","click","clak")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/items/Scissor.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='alert'><b>[src]</b> claks!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","hiss","chitter")
				return 2
			if ("snap","clack","click","clak")
				return 3
		return ..()

	critter_ability_attack(var/mob/target)
		var/datum/targetable/critter/sting = src.abilityHolder.getAbility(/datum/targetable/critter/sting/fermid)
		var/datum/targetable/critter/bite = src.abilityHolder.getAbility(/datum/targetable/critter/bite/fermid_bite)
		if (!sting.disabled && sting.cooldowncheck())
			sting.handleCast(target)
			return TRUE
		else if (!bite.disabled && bite.cooldowncheck())
			bite.handleCast(target)
			return TRUE

	critter_basic_attack(mob/target)
		if(prob(30))
			src.swap_hand()
		return ..()

	death()
		src.can_lie = FALSE
		src.reagents.add_reagent("atropine", 50, null)
		src.reagents.add_reagent("haloperidol", 50, null)
		return ..()

/mob/living/critter/fermid/polymorph
	desc = "Extremely hostile asteroid-dwelling bugs. This one looks particularly annoyed about something."
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 0.1
	add_abilities = list(/datum/targetable/critter/bite/fermid_bite, /datum/targetable/critter/sting/fermid/polymorph, /datum/targetable/critter/slam/polymorph)
	is_npc = FALSE // Typically is a crewmember

///////////////////////////////////////////////
///////////////////////////////////////////////
// STUPID GIMMICKRY BY CIRR BELOW HERE
///////////////////////////////////////////////
///////////////////////////////////////////////

///////////////////////////////////////////////
// FERMID WORKER
///////////////////////////////////////////////
// /mob/living/critter/fermid/worker

///////////////////////////////////////////////
// FERMID QUEEN
///////////////////////////////////////////////
// /mob/living/critter/fermid/queen

///////////////////////////////////////////////
// FERMID GRUB
///////////////////////////////////////////////
// /mob/living/critter/fermid/grub

///////////////////////////////////////////////
// FERMID EGG
///////////////////////////////////////////////
