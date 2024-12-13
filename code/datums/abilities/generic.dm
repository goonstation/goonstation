/mob/var/datum/targetable/chairflip/chair_flip_ability = null

/mob/proc/start_chair_flip_targeting(var/extrarange = 0)
	if (src.abilityHolder)
		if (istype(src.abilityHolder,/datum/abilityHolder/composite))
			var/datum/abilityHolder/composite/C = src.abilityHolder
			if (!C.getHolder(/datum/abilityHolder/hidden))
				C.addHolder(/datum/abilityHolder/hidden)
		if (!chair_flip_ability)
			chair_flip_ability = src.abilityHolder.addAbility(/datum/targetable/chairflip)

		chair_flip_ability.extrarange = extrarange
		src.targeting_ability = chair_flip_ability
		src.update_cursor()

		playsound(src.loc, 'sound/effects/chair_step.ogg', 50, 1)

/mob/proc/end_chair_flip_targeting()
	src.targeting_ability = null
	src.update_cursor()
	if (src.chair_flip_ability)
		src.chair_flip_ability.extrarange = 0

/datum/abilityHolder/generic
	usesPoints = FALSE
	regenRate = 0

/datum/abilityHolder/hidden
	usesPoints = 0
	regenRate = 0
	topBarRendered = 0
	rendered = 0
	hidden = TRUE

/datum/targetable/chairflip
	name = "Chair Flip"
	desc = "Click to launch yourself off of a chair."
	//icon_state = "fireball"
	targeted = 1
	target_anything = 1
	cooldown = 1
	preferred_holder_type = /datum/abilityHolder/hidden
	icon = null
	icon_state = null
	var/extrarange = 0 //affects next flip only
	var/dist = 0

	proc/check_mutantrace(mob/user)
		if(isfrog(user))
			dist = 6 + extrarange
		else
			dist = 3 + extrarange

	flip_callback()
		var/mob/M = holder.owner
		var/turf/T = get_turf(M)
		check_mutantrace(M)
		while (T && dist > 0)
			T = get_step(T,M.dir)
			dist -= 1

		src.cast(T)

	cast(atom/target) //the effect is in throw_impact at the bottom of mob.dm
		..()

		var/mob/M = holder.owner
		logTheThing(LOG_COMBAT, M, "chairflips from [log_loc(M)], vector: ([target.x - M.x], [target.y - M.y]), dir: <i>[dir2text(get_dir(M, target))]</i>")
		check_mutantrace(M)
		if (GET_DIST(M,target) > dist)
			var/steps = 0
			var/turf/T = get_turf(M)
			while (steps < dist)
				T = get_step(T,get_dir(T,target))
				steps += 1

			target = T

		extrarange = 0


		if (istype(M.buckled,/obj/stool/chair))
			var/obj/stool/chair/C = M.buckled
			M.buckled.unbuckle()
			C.buckledIn = 0
			C.buckled_guy = null
		M.pixel_y = 0
		M.buckled = null
		reset_anchored(M)

		M.targeting_ability = null
		M.update_cursor()

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			H.on_chair = null

		playsound(M.loc, 'sound/effects/flip.ogg', 50, 1)
		M.throw_at(target, 10, 1, throw_type = THROW_CHAIRFLIP)


		if (!iswrestler(M) && M.traitHolder && !M.traitHolder.hasTrait("glasscannon"))
			M.remove_stamina(STAMINA_FLIP_COST)
			M.stamina_stun()

		//if (!M.reagents.has_reagent("fliptonium"))
			//animate_spin(src, prob(50) ? "L" : "R", 1, 0)


/mob/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	..()

	if (src.throwing & THROW_CHAIRFLIP)
		var/turf/T = locate(src.last_throw_x, src.last_throw_y, src.z)
		var/dist_traveled = GET_DIST(hit_atom,T)
		var/effect_mult = 1
		if (dist_traveled <=1)
			effect_mult = 0.6
		else if (dist_traveled >= 3)
			effect_mult = 1.5


		if (isliving(hit_atom))
			var/mob/living/M = hit_atom
			SEND_SIGNAL(src, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
			if (check_target_immunity(M, source = src))
				src.visible_message(SPAN_ALERT("<b>[src] bounces off [M] harmlessly!</b>"))
				return
			playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)

			logTheThing(LOG_COMBAT, src, "[src] chairflips into [constructTarget(M,"combat")], [log_loc(M)].")
			M.lastattacker = src
			M.lastattackertime = world.time

			if (iswrestler(src))
				if (prob(33))
					M.ex_act(3)
				else
					random_brute_damage(M, 20 * effect_mult)
					M.changeStatus("knockdown", 7 SECONDS * effect_mult)
					M.force_laydown_standup()
			else
				random_brute_damage(M, 10 * effect_mult)
				if (!M.hasStatus("knockdown"))
					M.changeStatus("knockdown", 4 SECONDS * effect_mult)
					M.force_laydown_standup()

				if (src.hasStatus("knockdown") && src.getStatusDuration("knockdown") < 3 SECONDS * effect_mult) //address race of thus throw_end() happening before this proc lands due to bump() timing
					src.setStatus("knockdown", 3 SECONDS * effect_mult)
				else
					src.changeStatus("knockdown", 3 SECONDS * effect_mult)
				src.force_laydown_standup()

/mob/throw_end(list/params, turf/thrown_from)
	if (src.throwing & THROW_CHAIRFLIP)
		src.changeStatus("knockdown", 2.8 SECONDS)
		src.force_laydown_standup()

	if (length(params) && params["stun"])
		if (src.getStatusDuration("knockdown") < params["stun"])
			src.setStatus("knockdown", params["stun"])
			src.force_laydown_standup()


/datum/targetable/ai_toggle
	name = "Toggle AI"
	desc = "Toggle the Mob AI allowing you to following along with the AI."
	targeted = FALSE
	cooldown = 0
	do_logs = FALSE

	onAttach(datum/abilityHolder/holder)
		. = ..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image('icons/obj/items/organs/brain.dmi', "brain1"), "brain_state")

	castcheck()
		. = isadmin(holder.owner)

	cast(atom/target)
		..()
		var/mob/living/M = holder.owner
		if (M.ai)
			if(M.ai.enabled)
				M.ai.disable()
				M.is_npc = FALSE
			else
				M.ai.enable()
				M.is_npc = TRUE
		else if( M.is_npc && ishuman(M) )
			var/mob/living/carbon/human/H = M
			H.ai_set_active(!H.ai_active)
		updateObject()

	updateObject()
		var/mob/living/M = holder.owner
		var/atom/movable/screen/ability/topBar/B = src.object
		var/image/I = B.SafeGetOverlayImage("brain_state", 'icons/obj/items/organs/brain.dmi', "brain1")
		if(M.ai?.enabled || M.ai_active)
			I.icon_state = "ai_brain"
		else
			I.icon_state = "brain1"

		B.UpdateOverlays(I, "brain_state")

	display_available()
		. = ..()
		if(.)
			. = isadmin(holder.owner)


/datum/targetable/camera_shoot
	name = "Camera Lasers"
	desc = "Makes nearby cameras shoot lasers at the target. Somehow."
	targeted = TRUE
	target_anything = 1
	cooldown = 1 SECOND
	var/current_projectile = new/datum/projectile/laser/eyebeams

	cast(atom/target)
		. = ..()
		var/turf/T = get_turf(target)
		for(var/obj/O in T.cameras)
			shoot_projectile_ST_pixel_spread(O, current_projectile, T)

/datum/targetable/crew_credits
	name = "Crew credits"
	desc = "Re-open the crew credits window."
	icon = 'icons/mob/ghost_observer_abilities.dmi'
	icon_state = "crew-credits"
	targeted = FALSE
	cooldown = 1 SECOND
	do_logs = FALSE

	cast(atom/target)
		. = ..()
		holder.owner.show_credits()

/datum/targetable/personal_summary
	name = "Personal summary"
	desc = "Re-open the personal summary window."
	icon = 'icons/mob/ghost_observer_abilities.dmi'
	icon_state = "personal-summary"
	targeted = FALSE
	cooldown = 1 SECOND
	do_logs = FALSE

	cast(atom/target)
		. = ..()
		holder.owner.mind.personal_summary?.ui_interact(holder.owner)

/datum/targetable/toggle_gang_victory_hud
	name = "Hide/show Winning Gang"
	desc = "Gang gang."
	icon = 'icons/mob/ghost_observer_abilities.dmi'
	icon_state = "gang-victory"
	targeted = FALSE
	cooldown = 1 SECOND
	do_logs = FALSE

	cast(atom/target)
		. = ..()
		var/datum/hud/gang_victory/victory_hud = get_singleton(/datum/hud/gang_victory)
		if (holder.owner.client in victory_hud.clients)
			victory_hud.remove_client(holder.owner.client)
		else
			victory_hud.add_client(holder.owner.client)

/datum/targetable/inspector_report
	name = "Inspector's Report"
	desc = "Re-open the inspector's report."
	icon = 'icons/mob/ghost_observer_abilities.dmi'
	icon_state = "inspector-report"
	targeted = FALSE
	cooldown = 1 SECOND
	do_logs = FALSE

	cast(atom/target)
		. = ..()
		holder.owner.show_inspector_report()

/datum/targetable/juggle
	name = "Juggle"
	desc = "Juggle anything."
	cooldown = 10 SECOND
	targeted = TRUE
	target_anything = TRUE
	var/empowered = FALSE

	cast(atom/movable/target)
		if (!ishuman(src.holder.owner))
			return
		if (!src.empowered && (target.anchored || target == src.holder.owner) || target.anchored == ANCHORED_ALWAYS)
			boutput(src.holder.owner, SPAN_ALERT("Your juggling abilities aren't quite enough to juggle that."))
			return
		. = ..()
		var/mob/living/carbon/human/human = src.holder.owner
		human.add_juggle(target)
