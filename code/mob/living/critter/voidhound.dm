/mob/living/critter/voidhound
	name = "voidhound"
	desc = "A strangely hat shaped robot looking to spy on your deepest secrets"
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
	var/mob/wraith/controller = null

	New()
		..()
		//Let us spawn as stuff
		abilityHolder.addAbility(/datum/targetable/critter/voidhound/cloak)
		abilityHolder.addAbility(/datum/targetable/critter/voidhount/rushdown)
		abilityHolder.addAbility(/datum/targetable/critter/slam)

	setup_hands()//Todo find a weaker arm
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/brullbar
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "claw"
		HH.limb_name = "claws"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
