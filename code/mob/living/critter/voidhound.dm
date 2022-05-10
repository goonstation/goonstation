//Quick, stealthy, squishy assassin
//Take the heat off of the wraith by attracting attention

/mob/living/critter/voidhound
	name = "Voidhound"
	desc = "Todo"
	density = 1
	hand_count = 1
	can_help = 1
	can_throw = 1
	can_grab = 0
	can_disarm = 1
	icon_state = "scuttlebot"
	var/health_brute = 30
	var/health_brute_vuln = 0.7
	var/health_burn = 30
	var/health_burn_vuln = 1
	var/mob/wraith/master = null

	New(var/turf/T, var/mob/wraith/M = null)
		..(T)
		if(M != null)
			src.master = M

			if (isnull(M.summons))
				M.summons = list()
			M.summons += src
		abilityHolder.addAbility(/datum/targetable/critter/voidhound/cloak)
		abilityHolder.addAbility(/datum/targetable/critter/voidhount/rushdown)
		abilityHolder.addAbility(/datum/targetable/critter/slam)

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
