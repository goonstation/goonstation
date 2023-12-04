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
		src.custom_msg = SPAN_COMBAT("<b>[user] bites [target] with [his_or_her(user)] [pick(src.bite_adjectives)] mandibles!</b>")
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
	butcherable = BUTCHER_ALLOWED
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
	ai_type = /datum/aiHolder/aggressive
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	add_abilities = list(/datum/targetable/critter/bite/fermid_bite, /datum/targetable/critter/sting/fermid)
	no_stamina_stuns = TRUE

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 80) // They live in asteroids so they should be resistant

	is_spacefaring()
		return TRUE

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
					playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> chitters!"
			if ("snap","clack","click","clak")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/items/Scissor.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("<b>[src]</b> claks!")
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

///////////////////////////////////////////////
// ROCK WORM
///////////////////////////////////////////////

/mob/living/critter/rockworm
	name = "rock worm"
	real_name = "rock worm"
	desc = "Tough lithovoric worms."
	icon_state = "rockworm"
	icon_state_dead = "rockworm-dead"
	hand_count = 1
	can_throw = FALSE
	can_grab = FALSE
	can_disarm = FALSE
	health_brute = 40
	health_brute_vuln = 1
	health_burn = 40
	health_burn_vuln = 0.1
	ai_type = /datum/aiHolder/rockworm
	is_npc = TRUE
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_ONCE
	add_abilities = list(/datum/targetable/critter/vomit_ore)
	var/tamed = FALSE
	var/seek_ore = TRUE
	var/eaten = 0
	var/const/rocks_per_gem = 10

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 80) // They live in asteroids so they should be resistant
		AddComponent(/datum/component/consume/can_eat_raw_materials, FALSE)

	is_spacefaring()
		return TRUE

	on_pet(mob/user)
		if (..())
			return 1
		if (src.tamed && src.ai?.enabled)
			if (src.seek_ore)
				src.seek_ore = FALSE
				src.visible_message(SPAN_NOTICE("[user] pats [src] on the back. It won't seek ores now!"))
			else
				src.seek_ore = TRUE
				src.visible_message(SPAN_NOTICE("[user] shakes [src] to awaken its hunger!"))

	attackby(obj/item/I, mob/M)
		if(istype(I, /obj/item/raw_material) && !isdead(src))
			if((istype(I, /obj/item/raw_material/shard)) || (istype(I, /obj/item/raw_material/scrap_metal)))
				src.visible_message("[M] tries to feed [src] but they won't take it!")
				return
			if (src.tamed)
				src.visible_message("[M] tries to feed [src] but they seem full...")
				return
			if(prob(40))
				src.tamed = TRUE
				src.ai_retaliates = FALSE
				src.visible_message("[src] enjoyed the [I] and seems more docile!")
				src.emote("burp")
			src.aftereat()
			I.Eat(src, src)
			return
		..()

	seek_food_target(var/range = 5)
		. = list()
		for (var/obj/item/raw_material/ore in view(range, get_turf(src)))
			if (istype(ore, /obj/item/raw_material/shard)) continue
			if (istype(ore, /obj/item/raw_material/scrap_metal)) continue
			if (!(istype(ore, /obj/item/raw_material/rock)) && prob(30)) continue // can eat not rocks with lower chance
			. += ore

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_brute_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = FALSE

	proc/aftereat()
		var/datum/targetable/critter/vomit_ore/vomit = src.abilityHolder.getAbility(/datum/targetable/critter/vomit_ore)
		var/max_dist = 4
		src.eaten++
		if (src.eaten >= src.rocks_per_gem && src.ai?.enabled)
			for(var/turf/T in view(max_dist, src))
				if(!is_blocked_turf(T))
					if (!vomit.disabled && vomit.cooldowncheck())
						vomit.handleCast(T)
					break

/mob/living/critter/rockworm/gary
	name = "Gary the rockworm"
