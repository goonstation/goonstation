/mob/living/critter/skeleton_commander
	name = "skeleton commander"
	desc = "A bulky skeleton here to encourage his friends."
	density = 1
	hand_count = 2
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	icon_state = "scuttlebot"
	var/health_brute = 80
	var/health_brute_vuln = 0.7
	var/health_burn = 80
	var/health_burn_vuln = 0.3
	var/mob/wraith/master = null

	New(var/turf/T, var/mob/wraith/M = null)
		..(T)
		if(M != null)
			src.master = M

			if (isnull(M.summons))
				M.summons = list()
			M.summons += src

		abilityHolder.addAbility(/datum/targetable/critter/skeleton_commander/rally)
		abilityHolder.addAbility(/datum/targetable/wrestler/strike)
		abilityHolder.addAbility(/datum/targetable/critter/skeleton_commander/summon_lesser_skeleton)
		src.add_stam_mod_max("slow", STAMINA_MAX / 0.5)	//We are always slow and cant sprint fast.

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
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.suffix = "-L"
		HH.icon_state = "handl"
		HH.limb_name = "left arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"
