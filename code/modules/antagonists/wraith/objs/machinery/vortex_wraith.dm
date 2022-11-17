/obj/machinery/wraith/vortex_wraith
	name = "Summoning portal"
	icon = 'icons/obj/wraith_objects.dmi'
	icon_state = "harbinger_circle_inact"
	desc = "It hums and thrums as you stare at it. Dark shadows weave in and out of sight within."
	anchored = 1
	density = 0
	_health = 35
	var/list/obj/critter/critter_list = list()
	var/list/obj/critter/strong_critter_list = list()
	var/mob_value_cap = 2	//Total allowed point value of all linked mobs
	var/next_spawn = null
	var/total_mob_value = 0	//Total point value of all linked mobs
	var/mob/living/intangible/wraith/master = null
	var/datum/light/light
	var/datum/light/portal_light
	var/list/obj/critter/level_0_mobs = list(/obj/critter/crunched)
	var/list/obj/critter/level_1_mobs = list(/obj/critter/ancient_repairbot/security)
	var/list/obj/critter/level_2_mobs = list(/obj/critter/crunched)
	var/list/obj/critter/level_3_mobs = list(/obj/critter/ancient_repairbot/security)
	/*
	var/list/obj/critter/default_mobs = list(/obj/critter/crunched,	//Useful for random mode or when we dont have a mob_type on spawn
								/obj/critter/ancient_thing,
								/obj/critter/ancient_repairbot/security,
								/obj/critter/mechmonstrositycrawler,
								/obj/critter/shade,
								/obj/critter/bat/buff,
								/obj/critter/lion,
								/obj/critter/wraithskeleton,
								/obj/critter/bear,
								/obj/critter/brullbar,
								/obj/critter/gunbot/heavy)
	*/
	var/spawn_rate = 40 SECONDS
	var/spawn_radius = 2
	var/last_upgrade = null
	var/summon_power = 0
	var/upgrade_count = 0
	var/upgrade_cost = 30
	var/max_health = 30
	var/portal_level = 0
	var/active = TRUE

	New()
		src.visible_message("<span class='alert'>A [src] appears into view, some shadows coalesce within!</b></span>")
		light = new /datum/light/point
		light.set_brightness(0.1)
		light.set_color(150, 40, 40)
		light.attach(src)
		light.enable()
		START_TRACKING
		next_spawn = TIME + 15 SECONDS
		..()

	process()
		if (src.next_spawn < TIME)	//Spawn timer is up
			for (var/obj/critter/M in critter_list)	//Check for dead mobs and adjust cap
				if ((M?.health <= 0) || (!M?.loc) || M.qdeled)	//We have a mob in the list, but it's dead or missing...
					src.total_mob_value --
					critter_list -= M
			for (var/obj/critter/M in strong_critter_list)
				if ((M?.health <= 0) || (!M?.loc) || M.qdeled)	//We have a mob in the list, but it's dead or missing...
					src.total_mob_value -= 2
					strong_critter_list -= M
			var/list/eligible_turf = list()
			var/turf/chosen_turf = null
			// Prioritize spawning next to humans
			for_by_tcl(H, /mob/living/carbon/human)
				if (isnpc(H)) continue
				if (!IN_RANGE(H, src, src.spawn_radius)) continue
				if (src.portal_level >= 2)
					H.setStatus("portal_weakness", 30 SECONDS)
				if (isdead(H))
					if (src.portal_level >= 3 && get_dist(H, src) == 0 && H.decomp_stage >= DECOMP_STAGE_SKELETONIZED)
						actions.start(new/datum/action/bar/icon/portal_rebirth(src, H), src)
					else
						continue
				var/list/turfs = block(locate(max(H.x - 1, 0), max(H.y - 1, 0), H.z), locate(min(H.x + 1, world.maxx), min(H.y + 1, world.maxy), H.z))
				for (var/turf/simulated/floor/floor in turfs)
					if (src.portal_level >= 1 && prob(2))
						floor.ReplaceWith(/turf/unsimulated/floor/void, FALSE, TRUE, FALSE, TRUE)
					eligible_turf += floor
			if (!length(eligible_turf))	//No spot to spawn near a human, or no human in range, lets try to find a regular turf instead
				for (var/turf/simulated/floor/floor in block(locate(max(src.x - src.spawn_radius, 0), max(src.y - src.spawn_radius, 0), src.z), locate(min(src.x + src.spawn_radius, world.maxx), min(src.y + src.spawn_radius, world.maxy), src.z)))
					eligible_turf += floor
					if (src.portal_level >= 1 && prob(1))
						floor.ReplaceWith(/turf/unsimulated/floor/void, FALSE, TRUE, FALSE, TRUE)
			if (!length(eligible_turf))
				src.visible_message("<span class='alert'><b>[src] sputters and crackles, it seems it couldnt find a spot to summon something!</b></span>")
				src.next_spawn = TIME + src.spawn_rate
				return 1
			if (src.active)
				chosen_turf = pick(eligible_turf)
				var/obj/decal/harbinger_portal/portal = new /obj/decal/harbinger_portal
				portal.set_loc(chosen_turf)
				portal.alpha = 0
				animate(portal, alpha=255, time=1 SECONDS)
				portal_light = new /datum/light/point
				portal_light.set_brightness(0.1)
				portal_light.set_color(150, 40, 40)
				portal_light.attach(portal)
				portal_light.enable()
				playsound(chosen_turf, 'sound/effects/flameswoosh.ogg' , 80, 1)
				SPAWN(3 SECOND)
					animate(portal, alpha=0, time=2 SECONDS)
					SPAWN(2 SECOND)
						qdel(portal_light)
						qdel(portal)
					var/obj/mob_to_spawn = null
					if (((src.summon_power < 3) && (src.total_mob_value ++ <= src.mob_value_cap)) || ((src.summon_power >= 3) && ((src.total_mob_value + 2) <= src.mob_value_cap)))
						switch(src.summon_power)
							if (0)
								mob_to_spawn = pick(src.level_0_mobs)
							if (1)
								mob_to_spawn = pick(src.level_1_mobs)
							if (2)
								mob_to_spawn = pick(src.level_2_mobs)
							if (3)
								mob_to_spawn = pick(src.level_3_mobs)
						var/obj/minion = new mob_to_spawn(chosen_turf)
						//Higher minions take more room
						if (src.summon_power >= 3)
							src.total_mob_value ++
							src.strong_critter_list += minion
						else
							src.critter_list += minion
						src.total_mob_value ++
						minion.alpha = 0
						animate(minion, alpha=255, time = 2 SECONDS)
						minion.visible_message("<span class='alert'><b>[minion] emerges from the [src]!</b></span>")
					else
						src.visible_message("<span class='alert'><b>[src] opens a portal but nothing crosses through it. Looks like it has reached capacity!</b></span>")
			src.next_spawn = TIME + src.spawn_rate

	attackby(obj/item/P as obj, mob/living/user as mob)
		src._health -= P.force
		attack_particle(user,src)
		user.lastattacked = src
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		if(src._health <= 0)
			if (src.master != null)
				src.master.linked_portal = null
			deleteLinkedCritters()
			qdel(src)

	onDestroy()
		. = ..()
		if (src.master != null)
			src.master.linked_portal = null
		deleteLinkedCritters()

	disposing()
		if (src.master != null)
			src.master.linked_portal = null
			var/datum/targetable/ability = src.master.abilityHolder.getAbility(/datum/targetable/wraithAbility/create_summon_portal)
			ability.doCooldown()
		deleteLinkedCritters()
		STOP_TRACKING
		. = ..()

	attack_hand(mob/user)
		return

	proc/deleteLinkedCritters()
		for (var/obj/critter/C in src.critter_list)
			animate(C, alpha=0, time=2 SECONDS)
			SPAWN(2 SECOND)
				qdel(C)
/*
/obj/machinery/wraith/vortex_wraith/ui_state(mob/user)
	. = tgui_physical_state
*/
/obj/machinery/wraith/vortex_wraith/ui_status(mob/user, datum/ui_state/state)
	if(IN_RANGE(user, src, 8))
		. = tgui_broken_state.can_use_topic(src, user)

/obj/machinery/wraith/vortex_wraith/ui_data(mob/user)
	. = list(
		"spawnrate" = (src.spawn_rate / 10),
		"spawnrange" = src.spawn_radius,
		"mob_value_cap" = src.mob_value_cap,
		"_health" = src._health,
		"maxhealth" = src.max_health,
		"summon_power" = src.summon_power,
		"upgrade_cost" = src.upgrade_cost,
		"active" = src.active
	)

/obj/machinery/wraith/vortex_wraith/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VortexWraith")
		ui.open()

/obj/machinery/wraith/vortex_wraith/ui_act(action, params)
	. = ..()
	if (.)
		return
	if (!istype(usr, /mob/living/intangible/wraith))
		boutput(usr, "<span class='alert'>You shouldn't be seeing this! Dial 1-800 coder.</span>")
		. = TRUE
		return
	else
		var/datum/abilityHolder/wraith/AH = usr.abilityHolder
		switch(action)
			if ("up_spawnrate")
				if (TIME < src.last_upgrade)
					boutput(usr, "<span class='alert'>You just upgraded your portal. Give it a minute.</span>")
					. = TRUE
					return
				else if (AH.points < src.upgrade_cost)
					boutput(usr, "<span class='alert'>You do not have enough points to upgrade that!</span>")
					. = TRUE
					return
				else
					if (src.spawn_rate <= 25 SECONDS)
						boutput(usr, "<span class='notice'>Maximum spawn rate already achieved!</span>")
						. = TRUE
						return
					else
						src.spawn_rate -= 3 SECONDS
						src.last_upgrade = TIME + 15 SECONDS
						src.upgrade_count ++
						AH.points -= src.upgrade_cost
						src.upgrade_cost += 40
			if ("up_spawnrange")
				if (TIME < src.last_upgrade)
					boutput(usr, "<span class='alert'>You just upgraded your portal. Give it a minute.</span>")
					. = TRUE
					return
				else if (AH.points < src.upgrade_cost)
					boutput(usr, "<span class='alert'>You do not have enough points to upgrade that!</span>")
					. = TRUE
					return
				else
					if (src.spawn_radius >= 10)
						boutput(usr, "<span class='notice'>Maximum spawn range already achieved!</span>")
						. = TRUE
						return
					else
						src.spawn_radius ++
						src.last_upgrade = TIME + 15 SECONDS
						src.upgrade_count ++
						AH.points -= src.upgrade_cost
						src.upgrade_cost += 40
			if ("up_summoncap")
				if (TIME < src.last_upgrade)
					boutput(usr, "<span class='alert'>You just upgraded your portal. Give it a minute.</span>")
					. = TRUE
					return
				else if (AH.points < src.upgrade_cost)
					boutput(usr, "<span class='alert'>You do not have enough points to upgrade that!</span>")
					. = TRUE
					return
				else
					if (src.mob_value_cap >= 8)
						boutput(usr, "<span class='notice'>Maximum minion amount already achieved!</span>")
						. = TRUE
						return
					else
						src.mob_value_cap ++
						src.last_upgrade = TIME + 15 SECONDS
						src.upgrade_count ++
						AH.points -= src.upgrade_cost
						src.upgrade_cost += 40
			if ("up_portalhealth")
				if (TIME < src.last_upgrade)
					boutput(usr, "<span class='alert'>You just upgraded your portal. Give it a minute.</span>")
					. = TRUE
					return
				else if (AH.points < src.upgrade_cost)
					boutput(usr, "<span class='alert'>You do not have enough points to upgrade that!</span>")
					. = TRUE
					return
				else
					if (src.max_health >= 110)
						boutput(usr, "<span class='notice'>Maximum portal health already achieved!</span>")
						. = TRUE
						return
					else
						src._health += 15
						src.max_health += 15
						src.last_upgrade = TIME + 15 SECONDS
						src.upgrade_count ++
						AH.points -= src.upgrade_cost
						src.upgrade_cost += 40
			if ("up_summonpower")
				if (TIME < src.last_upgrade)
					boutput(usr, "<span class='alert'>You just upgraded your portal. Give it a minute.</span>")
					. = TRUE
					return
				else if (AH.points < src.upgrade_cost)
					boutput(usr, "<span class='alert'>You do not have enough points to upgrade that!</span>")
					. = TRUE
					return
				else
					if (src.summon_power >= 4)
						boutput(usr, "<span class='notice'>Maximum minion power already achieved!</span>")
						. = TRUE
						return
					else
						src.summon_power ++
						src.last_upgrade = TIME + 15 SECONDS
						src.upgrade_count ++
						AH.points -= src.upgrade_cost
						src.upgrade_cost += 40
			if ("portalheal")
				if (AH.points >= src.upgrade_cost)
					if (src._health == src.max_health)
						boutput(usr, "<span class='alert'>Your portal isn't damaged!</span>")
						. = TRUE
						return
					else if ((src._health + 30) > src.max_health)
						src._health = src.max_health
					else
						src._health += 30
					AH.points -= src.upgrade_cost
					. = TRUE
					return
				else
					boutput(usr, "<span class='alert'>You do not have enough points to upgrade that!</span>")
					. = TRUE
					return
			if ("destroy_portal")
				var/choice = tgui_alert(usr, "Are you sure you wish to destroy your own portal?", "Destruction", list("Yes", "No"))
				if (!choice || choice == "No")
					return TRUE
				if (choice == "Yes")
					qdel(src)
					boutput(usr, "<span class='notice'>You destroy your own portal.</span>")
					. = TRUE
					return
			if ("kill_summons")
				var/choice = tgui_alert(usr, "Are you sure you wish to kill all currently portal summoned creatures?", "Cleansing", list("Yes", "No"))
				if (!choice || choice == "No")
					return TRUE
				if (choice == "Yes")
					src.deleteLinkedCritters()
					boutput(usr, "<span class='notice'>You send back every creature to the void.</span>")
					. = TRUE
					return
			if ("toggle_active")
				src.active = !src.active
				if (src.active)
					src.visible_message("<span class='alert'>The portal ignites with terrible intent! The shadows within angrily try to break out!</span>")
				else
					src.visible_message("<span class='alert'>The portal appears to settle down, the shadows inside flowing slowly.</span>")
		if (src.upgrade_count == 3)
			src.icon_state = "harbinger_circle_2"
			boutput(usr, "<span class='alert'><b>Your influence grows! The portal begins to spread the void and crackles with energy!</b></span>")
			src.portal_level = 1
			for (var/obj/machinery/light/L in range(5, src))
				if (L.status == 2 || L.status == 1)
					continue
				L.broken()
		else if (src.upgrade_count == 10)
			src.icon_state = "harbinger_circle_4"
			boutput(usr, "<span class='alert'><b>Humans <i>COWER</i> before your might! Your portal emits a weakening aura!</b></span>")
			src.portal_level = 2
		else if (src.upgrade_count == 20)
			src.icon_state = "harbinger_circle_5"
			boutput(usr, "<span class='alert'><b>Your portal reaches it's full power! Skeletonized corpses laid directly on top of it will serve as fuel for a powerful summon!</b></span>")
			src.portal_level = 3
		. = TRUE

/datum/action/bar/icon/portal_rebirth
	duration = 15 SECONDS
	id = "portal_rebirth"
	//icon = ''
	//icon_state = ""
	var/mob/living/carbon/human/target = null
	var/obj/machinery/wraith/vortex_wraith/the_portal = null

	New(var/obj/machinery/wraith/vortex_wraith/portal, var/mob/living/carbon/human/H)
		src.target = H
		src.the_portal = portal
		..()

	onStart()
		..()
		if (!src.the_portal || !src.target || (get_dist(src.the_portal, src.target) > 0))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.the_portal.visible_message("<span class='alert'><b>[src.the_portal] begins envelopping [src.target]'s in a bright glow!</b></span>")
		SPAWN(5 SECONDS)
			if (!src.the_portal || !src.target || (get_dist(src.the_portal, src.target) > 0))
				interrupt(INTERRUPT_ALWAYS)
				return
			src.target.update_burning(20)
			playsound(src.target, 'sound/effects/flameswoosh.ogg', 80)
			src.the_portal.visible_message("<span class='alert'><b>[src.the_portal] covers [src.target] in flames!</b></span>")

	onUpdate()
		..()
		if (!src.the_portal || !src.target || (get_dist(src.the_portal, src.target) > 0))
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		playsound(src.target, 'sound/effects/ritual.ogg', 80)
		src.target.firegib(FALSE)
		src.the_portal.visible_message("<span class='alert'><b>[src.target] is consumed by [src.the_portal]! A being arises from their ashes!</b></span>")
		..()
