/mob/living/critter/skeleton_commander
	name = "skeleton commander"
	desc = "A strangely hat shaped robot looking to spy on your deepest secrets"
	density = 1
	hand_count = 2
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	icon_state = "scuttlebot"
	var/health_brute = 80
	var/health_brute_vuln = 0.8
	var/health_burn = 80
	var/health_burn_vuln = 0.3
	var/mob/wraith/controller = null

	New()
		..()
		//Let us spawn as stuff
		abilityHolder.addAbility(/datum/targetable/critter/skeleton_commander/rally)
		abilityHolder.addAbility(/datum/targetable/wrestler/strike)
		abilityHolder.addAbility(/datum/targetable/critter/skeleton_commander/summon_lesser_skeleton)
		src.setStatus("weakcurse")

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		src.setStatus("slowed", 5 SECONDS)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right arm"
