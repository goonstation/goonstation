/mob/living/critter/nascent
	name = "nascent voidling"
	real_name = "nascent voidling"
	desc = "Oh god."
	density = 1
	icon_state = "abear"
	hand_count = 0
	var/health_brute = 50
	var/health_brute_vuln = 0.5
	var/health_burn = 50
	var/health_burn_vuln = 0.7
	var/mob/wraith/master = null

	New()
		..()
		//Let us spawn as stuff
		abilityHolder.addAbility(/datum/targetable/critter/nascent/become_spiker)
		abilityHolder.addAbility(/datum/targetable/critter/nascent/become_voidhound)
		abilityHolder.addAbility(/datum/targetable/critter/nascent/become_commander)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
