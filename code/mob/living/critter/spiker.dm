/mob/living/critter/spiker
	name = "spiker"
	desc = "A strangely hat shaped robot looking to spy on your deepest secrets"
	density = 1
	hand_count = 1
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	icon_state = "scuttlebot"
	var/health_brute = 30
	var/health_brute_vuln = 1
	var/health_burn = 30
	var/health_burn_vuln = 1
	var/mob/wraith/controller = null

	New()
		..()
		//Let us spawn as stuff
		abilityHolder.addAbility(/datum/targetable/critter/spiker/hook)
		abilityHolder.addAbility(/datum/targetable/critter/spiker/lash)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.name = "long range stun tentacles"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "tentacles"				// the icon state of the hand UI background
		HH.limb_name = "long range stun tentacles"					// name for the dummy holder
		HH.limb = new /datum/limb		// if not null, the special limb to use when attack_handing
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

/datum/projectile/special/tentacle
	name = "tentacle"
	dissipation_rate = 1
	dissipation_delay = 7
	icon_state = ""
	power = 1
	hit_ground_chance = 10
	ks_ratio = 1.0
	shot_sound = 'sound/misc/hastur/tentacle_hit.ogg'
	var/list/previous_line = list()

	on_hit(atom/hit, angle, var/obj/projectile/P)
		if (previous_line != null)
			for (var/obj/O in previous_line)
				qdel(O)
		if (ismob(hit))
			var/mob/M = hit
			if(hit == P.special_data["owner"]) return 1
			var/turf/destination = get_turf(P.special_data["owner"])
			if (destination)
				do_teleport(M, destination, 0, sparks=0) ///You will appear adjacent to Hastur.
				playsound(M, "sound/impact_sounds/Flesh_Stab_1.ogg", 50, 1)
				M.changeStatus("paralysis", 3 SECONDS)
				M.visible_message("<span class='alert'>[M] gets grabbed by a tentacle and dragged!</span>")

	on_launch(var/obj/projectile/P)
		..()
		if (!("owner" in P.special_data))
			P.die()
			return


	tick(var/obj/projectile/P)
		..()
		if (previous_line != null)
			for (var/obj/O in previous_line)
				qdel(O)
		previous_line = DrawLine(P.special_data["owner"], P, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"WholeTentacle",1,1,"HalfStartTentacle","HalfEndTentacle",OBJ_LAYER,1)

