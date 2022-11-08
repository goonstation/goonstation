//Quick, stealthy, squishy assassin
//Take the heat off of the wraith by attracting attention

/mob/living/critter/wraith/voidhound
	name = "voidhound"
	desc = "You probably shouldn't be staring at this thing."
	density = 1
	hand_count = 1
	can_help = 1
	can_throw = 1
	can_grab = 0
	can_disarm = 1
	custom_gib_handler = /proc/gibs
	icon = 'icons/mob/wraith_critters.dmi'
	icon_state = "voidhound"
	icon_state_dead = "dead_voidhound"
	health_brute = 40
	health_brute_vuln = 0.7
	health_burn = 40
	health_burn_vuln = 1
	var/mob/living/intangible/wraith/master = null
	var/cloaked = FALSE

	New(var/turf/T, var/mob/living/intangible/wraith/M = null)
		..(T)
		if(M != null)
			src.master = M

			if (isnull(M.summons))
				M.summons = list()
			M.summons += src
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/voidhound/cloak)
		abilityHolder.addAbility(/datum/targetable/critter/voidhount/rushdown)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "claw"
		HH.limb_name = "claws"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	attackby(obj/item/W as obj, mob/living/user as mob)
		if(cloaked)
			animate(src, alpha=255, time=1 SECONDS)
			cloaked = FALSE
			boutput(src, "<span class='alert'>We are under attack, our disguise fails.</span>")
		..()

	attack_hand(mob/user)
		if(cloaked)
			animate(src, alpha=255, time=1 SECONDS)
			cloaked = FALSE
			boutput(src, "<span class='alert'>We reappear</span>")
		..()

	Life()
		var/turf/local_turf = get_turf(src)
		if (local_turf.RL_GetBrightness() < 0.3 || src.cloaked)
			if ((src.health < (src.health_brute + src.health_burn)))
				for(var/damage_type in src.healthlist)
					var/datum/healthHolder/hh = src.healthlist[damage_type]
					hh.HealDamage(2)
			if (!HAS_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS))
				APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "voidhound_darkness", 5)
		else
			if (HAS_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS))
				REMOVE_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "voidhound_darkness")
		..()
