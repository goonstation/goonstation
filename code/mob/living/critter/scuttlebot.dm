/mob/living/critter/scuttlebot
	name = "scuttlebot"
	desc = "A strangely hat shaped robot looking to spy on your deepest secrets"
	density = 0
	custom_gib_handler = /proc/gibs
	hand_count = 1
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	var/unified_health = 20
	var/firevuln = 0.1
	var/brutevuln = 1

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/takepicture)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "claw"
		HH.limb_name = "claws"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	Cross(atom/mover)
		if (!src.density && istype(mover, /obj/projectile))
			return prob(50)
		else
			return ..()

	death(var/gibbed)
		..(gibbed, 0)
		if (!gibbed)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)
			src.audible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
			playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)
			elecflash(src, radius=1, power=3, exclude_center = 0)
			//ghostize()
			qdel(src)
		else
			make_cleanable(/obj/decal/cleanable/oil,src.loc)

/*
	canRideMailchutes()
		return 1
*/
