/mob/living/critter/spore
	name = "plasma spore"
	desc = "A barely intelligent colony of organisms. Very volatile."
	icon_state = "spore"
	death_text = "%src% ruptures and explodes!"
	density = FALSE
	hand_count = 0
	can_help = FALSE
	can_throw = FALSE
	can_grab = FALSE
	density = 1
	butcherable = BUTCHER_NOT_ALLOWED
	is_npc = TRUE
	ai_retaliates = FALSE
	void_mindswappable = FALSE
	isFlying = TRUE
	flags = TABLEPASS

	health_brute = 1
	health_brute_vuln = 2
	health_burn = 1
	health_burn_vuln = 2
	ai_type = /datum/aiHolder/wanderer

	setup_healths()
		. = ..()
		src.add_hh_flesh(health_brute, health_brute_vuln)
		src.add_hh_flesh_burn(health_burn, health_burn_vuln)

	death(gibbed, do_drop_equipment)
		. = ..()
		var/turf/T = get_turf(src.loc)
		if(T)
			T.hotspot_expose(700,125)
			explosion(src, T, -1, -1, 2, 3)
		qdel (src)

	ex_act(severity)
		. = ..()
		src.death()

	bullet_act(obj/projectile/P)
		. = ..()
		src.death()

