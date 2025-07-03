/mob/living/critter/wraith/spiker
	name = "tentacle fiend"
	desc = "Standing still is probably not a good idea."
	density = 1
	hand_count = 1
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	icon = 'icons/mob/wraith_critters.dmi'
	icon_state_dead = "dead_spiker"
	icon_state = "spiker"
	custom_gib_handler = /proc/gibs
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 1
	name_generator_path = /datum/wraith_name_generator/wraith_summon/spiker
	///Are we currently escaping?
	var/shuffling = FALSE
	var/mob/living/intangible/wraith/master = null

	faction = list(FACTION_WRAITH)

	New(var/turf/T, var/mob/living/intangible/wraith/M = null)
		..(T)
		if(M != null)
			src.master = M

			if (isnull(M.summons))
				M.summons = list()
			M.summons += src
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/spiker/hook)
		abilityHolder.addAbility(/datum/targetable/critter/frenzy/spiker)
		abilityHolder.addAbility(/datum/targetable/critter/spiker/shuffle)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.name = "tentacles"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "tentacles"
		HH.limb_name = "tentacles"
		HH.limb = new /datum/limb/tentacle
		HH.can_hold_items = 1
		HH.can_attack = 1

	click(atom/target, params, location, control)
		if (src.shuffling)
			boutput(src, SPAN_NOTICE("You cannot interact with this while in this form!"))
			return
		else
			..()

	death(var/gibbed)
		if (src.master)
			src.master.summons -= src
			src.master = null
		return ..()

/datum/projectile/special/tentacle	//Get over here!
	name = "tentacle"
	dissipation_rate = 1
	dissipation_delay = 7
	icon_state = ""
	damage = 1
	hit_ground_chance = 0
	shot_sound = 'sound/misc/hastur/tentacle_hit.ogg'
	var/list/previous_line = list()
	//This whole line thing might be a bit inneficient and chuggy.
	on_hit(atom/hit, angle, var/obj/projectile/P)
		if (previous_line != null)	//Lets clean up the line
			for (var/obj/O in previous_line)
				qdel(O)
		if (ismob(hit))	//Drag them to us
			var/mob/M = hit
			if(hit == P.special_data["owner"]) return 1
			var/turf/destination = get_turf(P.special_data["owner"])
			if (destination)

				M.throw_at(destination, 10, 1)

				playsound(M, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, TRUE)
				M.TakeDamageAccountArmor("All", rand(3,4), 0, 0, DAMAGE_CUT)
				M.force_laydown_standup()
				M.changeStatus("unconscious", 5 SECONDS)
				M.visible_message(SPAN_ALERT("[M] gets grabbed by a tentacle and dragged!"))

		previous_line = drawLineObj(P.special_data["owner"], P, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"mid_tentacle",1,1,"start_tentacle","end_tentacle",OBJ_LAYER,1)
		SPAWN(1 DECI SECOND)	//Make it last a bit for impact
			for (var/obj/O in previous_line)
				qdel(O)
		qdel(P)


	on_launch(var/obj/projectile/P)
		..()
		if (!("owner" in P.special_data))
			P.die()
			return

	on_end(var/obj/projectile/P)	//Clean up behind us
		SPAWN(1 DECI SECOND)
			for (var/obj/O in previous_line)
				qdel(O)
		..()

	tick(var/obj/projectile/P)	//Trail the projectile
		..()
		if (previous_line != null)
			for (var/obj/O in previous_line)
				qdel(O)
		previous_line = drawLineObj(P.special_data["owner"], P, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"mid_tentacle",1,1,"start_tentacle","end_tentacle",OBJ_LAYER,1)

