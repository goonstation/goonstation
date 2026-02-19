/mob/living/critter/plasmaspore
	name = "plasma spore"
	desc = "A barely intelligent colony of organisms. Very volatile."
	density = 1
	icon_state = "spore"
	custom_gib_handler = /proc/gibs
	hand_count = 0
	can_throw = 0
	blood_id = "plasma"

	faction = list(FACTION_BOTANY)

	death(var/gibbed)
		. = ..()
		src.visible_message("<b>[src]</b> ruptures and explodes!")
		var/turf/T = get_turf(src.loc)
		if(T)
			T.hotspot_expose(700,125)
			explosion(src, T, -1, -1, 2, 3)
		ghostize()
		qdel(src)

	setup_healths()
		add_hh_flesh(1, 1)
		add_hh_flesh_burn(1, 1)
