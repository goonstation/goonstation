/mob/living/critter/scuttlebot
	name = "scuttlebot"
	desc = "A strangely hat shaped robot looking to spy on your deepest secrets"
	density = 0
	custom_gib_handler = /proc/gibs
	flags = TABLEPASS | DOORPASS
	hand_count = 1
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	icon_state = "mouse_white"
	var/health_brute = 25
	var/health_brute_vuln = 1
	var/health_burn = 25
	var/health_burn_vuln = 0.2
	var/connected_remote = null
	var/controller = null

	New()
		..()
		var/obj/item/clothing/glasses/scuttlebot_vr/R = new /obj/item/clothing/glasses/scuttlebot_vr(src.loc)
		connected_remote = R
		R.connected_scuttlebot = src

		abilityHolder.addAbility(/datum/targetable/critter/takepicture)
		abilityHolder.addAbility(/datum/targetable/critter/control_owner)
		abilityHolder.addAbility(/datum/targetable/critter/flash)

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

	attackby(obj/item/W, mob/M)
		if(istype(W, /obj/item/clothing/glasses/scuttlebot_vr))
			new /obj/item/clothing/head/det_hat/folded_scuttlebot(get_turf(src))
			qdel(W)
			qdel(src)
/*
	canRideMailchutes()
		return 1
*/
