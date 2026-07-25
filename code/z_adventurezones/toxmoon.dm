///////////////////////////////////////////////////////////////////////////////////////////////////////////
/////// contents:
/////// --------
/////// terrain
/////// areas
/////// rad pools
/////// rad monsters
/////// rad monster critter abilities
/////// boss spawner
/////// boss
////////////////////////////////
///////////////////////////////////////

///////////////////

/turf/unsimulated/floor/setpieces/toxmoon
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

	irradiated
		radgas = 100
		nitrogen = 0
		oxygen = 0

		New()
			..()
			var/image/fallout_overlay = image('icons/effects/tile_effects.dmi', "rad_particles")
			AddOverlays(fallout_overlay, "fallout")

		plating
			name = "plating"
			icon_state = "plating"
			step_material = "step_plating"
			intact = 0
			layer = PLATING_LAYER

		catwalk
			name = "catwalk support"
			icon_state = "catwalk"
			allows_vehicles = 1
			step_priority = STEP_PRIORITY_MED
			can_burn = FALSE
			can_break = FALSE

		fall
			name = "ominious drop"
			icon_state = "void_gray"
			step_priority = STEP_PRIORITY_MED
			can_burn = FALSE
			can_break = FALSE

			var/falltarget = LANDMARK_FALL_TOX_REACTOR

			New()
				src.AddComponent(/datum/component/pitfall/target_landmark/enter_triggering,\
					BruteDamageMax = 50,\
					FallTime = 0 SECONDS,\
					TargetLandmark = src.falltarget)
				..()

			lake
				falltarget = LANDMARK_FALL_TOX_LAKE

/turf/unsimulated/floor/setpieces/toxmoon/radpool
	name = "radioactive goop"
	desc = "The water test says this needs more chlorine."
	icon = 'icons/turf/floors.dmi'
	icon_state = "wastewaterfloor"

	can_replace_with_stuff = TRUE
	can_burn = FALSE
	can_break = FALSE

	var/radStrength = 75
	var/neutron = FALSE // no neutron shit, unless you want to make a especially vile subtype

	New()
		..()
		set_dir(pick(NORTH, SOUTH))
		src.add_simple_light("rad", list(0, 0.8 * 255, 0.3 * 255, 0.8 * 255))

	Entered(atom/movable/O, atom/old_loc)
		var/mult = 1
		..()
		if(!(isnull(old_loc) || O.anchored == ANCHORED_ALWAYS))
			return_if_overlay_or_effect(O)

			if (istype(O, /obj/projectile) || istype(O, /obj/arrival_missile))
				return

			if (isintangible(O))
				return

			if (iscritter(O))
				var/obj/critter/C = O
				if (C.flying)
					return

			if (istype(O, /obj/machinery/vehicle))
				var/obj/machinery/vehicle/V = O
				if(istype(V.movement_controller, /datum/movement_controller/pod) && V.get_part(POD_PART_ENGINE)?.active)
					return

			if (check_target_immunity(O, TRUE))
				return

			if(ismobcritter(O))
				if HAS_ATOM_PROPERTY(O, PROP_MOB_GOOPIMMUNE)
					return

			if (isliving(O) && !ON_COOLDOWN(src, "goop_hurty", 0.5 SECONDS))
				var/mob/living/M = O
				M.take_radiation_dose(mult * (neutron ? 1 SIEVERTS: 0.6 SIEVERTS) * (radStrength/100), TRUE)
				M.changeStatus("slowed", 3 SECONDS)
				var/other_damage = rand(1,3)
				if (other_damage == 1)
					boutput(M, "You feel a piece of debris in the pool cut against you!")
					take_bleeding_damage(M, null, rand(10,20) * mult, DAMAGE_STAB)
				if (other_damage == 2)
					boutput(M, "You feel the corrosive goop singe you!")
					random_burn_damage(M, rand(10,20) * mult)
				if (other_damage == 3)
					boutput(M, "You feel bile seep across your skin.")
					if(M == /mob/living/carbon/human)
						M.take_toxin_damage(rand(10,20))
			return

	fall
		var/falltarget = LANDMARK_FALL_TOX_SEWER

		New()
			..()
			src.AddComponent(/datum/component/pitfall/target_landmark,\
				BruteDamageMax = 20,\
				FallTime = 0 SECONDS,\
				TargetLandmark = src.falltarget)
			..()

/obj/fakeobject/sewagedrain
	name = "sewage drain"
	desc = "A sewage drain in the middle of a lake. It seems to be lacking grilles to stop people from falling in."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "sewage_drain"
	anchored = 1

// areas


/area/toxmoon
	name = "Facility Sigma Disposal Site"
	icon_state = "green"

/area/toxmoon/depot
	name = "Facility Sigma Waste Depot"

/area/toxmoon/cave
	name = "Acid Lake Cavern"

/area/toxmoon/plant
	irradiated = 0.2
	permarads = 1
	prevent_radiation_overlay = TRUE

/area/toxmoon/sewer
	name = "Fatuus Sewer"

/area/toxmoon/plant/exterior
	name = "Facility Sigma Waste Site"
	ambient_light = rgb(180, 150, 150)
	sound_group = "swamp_heights"

/area/toxmoon/plant/entrance
	name = "Geisel Radiofabrik Decommisioned Power Plant - Entrance"
	ambient_light = rgb(180, 150, 150)
	sound_group = "swamp_heights"

/area/toxmoon/plant/upper
	name = "Geisel Radiofabrik Decommisioned Power Plant - Upper Level"
	irradiated = 0.4

/area/toxmoon/plant/lake
	name = "Geisel Radiofabrik Decommisioned Power Plant - Lake Area"
	ambient_light = rgb(180, 150, 150)
	sound_group = "swamp_heights"

/area/toxmoon/plant/lower
	name = "Geisel Radiofabrik Decommisioned Power Plant - Lower Level"
	irradiated = 0.6

/area/toxmoon/plant/controls
	name = "Geisel Radiofabrik Decommisioned Power Plant - Control Room"
	irradiated = 0.8

/area/toxmoon/plant/reactor
	name = "Geisel Radiofabrik Decommisioned Power Plant - Reactor"
	ambient_light = rgb(82, 238, 34)
	irradiated = 1.5

/mob/living/critter/radthing
	name = "Inconceivable Goop Abomination"
	desc = "It'd seem like a regular undead with large amounts of corrosion if the goop within wasn't lashing out."
	icon = 'icons/mob/critter/humanoid/goopthings.dmi'
	icon_state = "goop"
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	hand_count = 2
	health_brute = 45
	health_brute_vuln = 1
	health_burn = 45
	health_burn_vuln = 1
	radiation_dose_decay = 1000
	is_npc = TRUE
	ai_type = /datum/aiHolder/aggressive
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	add_abilities = list(/datum/targetable/critter/acidpuke)
	blood_id = "radium"
	var/moan_sounds = list("sound/voice/Zgroan1.ogg", "sound/voice/Zgroan2.ogg", "sound/voice/Zgroan3.ogg", "sound/voice/Zgroan4.ogg")
	faction = list(FACTION_TOXMOON)

	New()
		..()
		remove_lifeprocess(/datum/lifeprocess/radiation)
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/zombie, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_GOOPIMMUNE, src.type)
		src.bioHolder.AddEffect("radioactive")

	critter_basic_attack(var/mob/target)
		if (src.equipped())
			src.drop_item()
		src.set_a_intent(INTENT_HARM)
		src.hand_attack(target)
		return TRUE

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, pick(src.moan_sounds) , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> moans!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_brute_vuln)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.ai?.enabled)
			if (prob(5))
				playsound(src, pick(src.moan_sounds), 25, 5)

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/acidpuke/puke = src.abilityHolder.getAbility(/datum/targetable/critter/acidpuke)
		src.set_dir(get_dir(src, target))

		if (!puke.disabled && puke.cooldowncheck() && prob(10))
			puke.handleCast(target)
			src.ai.move_away(target,1)
			return TRUE

	death(var/gibbed)
		if (!gibbed)
			src.unequip_all()
			src.gib()
		..()

	neutron
		health_brute = 65
		health_burn = 65
		icon_state = "goop_neutron"
		New()
			..()
			remove_lifeprocess(/datum/lifeprocess/radiation)
			APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/zombie, src)
			src.bioHolder.RemoveEffect("radioactive")
			src.bioHolder.AddEffect("n_radioactive")

	spitter
		icon_state = "spitter"
		ai_type = /datum/aiHolder/ranged
		add_abilities = list(/datum/targetable/critter/spit/low_cd)

		critter_ability_attack(mob/target)
			var/datum/targetable/critter/spit/low_cd/spit = src.abilityHolder.getAbility(/datum/targetable/critter/spit/low_cd)
			src.set_dir(get_dir(src, target))

			if (!spit.disabled && spit.cooldowncheck() && prob(10))
				spit.handleCast(target)
				src.ai.move_away(target,1)
				return TRUE

		setup_hands()
			..()
			var/datum/handHolder/HH = hands[1]
			HH.limb = new /datum/limb/gun/kinetic/spit
			HH.icon_state = "gun"
			HH.limb_name = "spitter arm"

/datum/targetable/critter/acidpuke // critter version
	name = "Acidic Mass Emesis"
	desc = "BLAAAAAAAARFGHHHHHGHH"
	icon_state = "bigpuke"
	targeted = TRUE
	var/puke_reagents = list("vomit" = 20, "gvomit" = 20, "pacid" = 10, "radium" = 5)

	cast(atom/target)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		var/list/line_turfs = getline(holder.owner, T)
		var/list/affected_turfs = list()
		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] horfs up a huge stream of puke!</b>"))
		logTheThing(LOG_COMBAT, src, "power-pukes [log_reagents(holder.owner)] at [log_loc(src)].")
		playsound(holder.owner, 'sound/misc/meat_plop.ogg', 50, 0)
		for (var/reagent_id in puke_reagents)
			holder.owner.reagents.add_reagent(reagent_id, puke_reagents[reagent_id])
		var/turf/currentturf
		var/turf/previousturf
		for(var/turf/F in	_turfs)
			previousturf = currentturf
			currentturf = F
			if(currentturf.density || istype(currentturf, /turf/space))
				break
			if(previousturf && LinkBlocked(previousturf, currentturf))
				break
			if (F == get_turf(holder.owner))
				continue
			affected_turfs += F
		for(var/turf/F in affected_turfs)
			holder.owner.reagents.reaction(F,TOUCH, holder.owner.reagents.total_volume/length(affected_turfs))
			for(var/mob/living/L in F.contents)
				holder.owner.reagents.reaction(L,TOUCH, holder.owner.reagents.total_volume/length(affected_turfs))
			for(var/obj/O in F.contents)
				holder.owner.reagents.reaction(O,TOUCH, holder.owner.reagents.total_volume/length(affected_turfs))
		holder.owner.reagents.clear_reagents()
		SEND_SIGNAL(holder.owner, COMSIG_MOB_VOMIT, 10)
		return 0

/obj/fakeobject/toxmoon_boss_reactor // cause the normal one barfs rads across cordons
	name = "Molten Reactor Core"
	desc = "A molten nuclear reactor core. It's still burning and smoking. Some engineers are gonna get fired for this." // nothin off, NOTHIN
	icon = 'icons/misc/nuclearreactor.dmi'
	icon_state = "reactor_destroyed"
	bound_width = 160
	bound_height = 160
	pixel_x = -64
	pixel_y = -64
	bound_x = -64
	bound_y = -64
	anchored = ANCHORED
	density = TRUE
	mat_changename = FALSE
	dir = EAST
	pixel_point = TRUE
	density = 0
	var/id = "toxmoon_boss"
	/// ref to the turf the reactor light is stored on, because you can't center simple lights
	VAR_PRIVATE/turf/_light_turf

	New()
		. = ..()
		src.AddComponent(/datum/component/radioactive, 10, FALSE, FALSE, 5)
		src.UpdateParticles(new/particles/nuke_overheat_smoke(get_turf(src)),"overheat_smoke")
		src._light_turf = get_turf(src)
		src._light_turf.add_medium_light("reactor_destroyed_light", list(255,0,0,255))

/obj/boss_spawn_marker
	icon = 'icons/misc/mark.dmi'
	icon_state = "ydn"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0
	var/id = "toxmoon_boss"

/obj/boss_spawn_trigger
	icon = 'icons/misc/mark.dmi'
	icon_state = "ydn"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0
	var/active = 0 // we don't just delete in case its a arena that resets instead of just being a one-off spawner
	var/id = "toxmoon_boss"
	var/boss_path = /mob/living/critter/noxia_abomination
	var/wait_area = /area/toxmoon/plant/controls
	Crossed(atom/movable/AM as mob|obj)
		if(!active && ismob(AM))
			active = TRUE
			var/mob/M = AM
			if(!M.mind)
				return
			boutput(M, SPAN_ALERT("Oh shit."))
			if(wait_area)
				for(var/WA in get_area_turfs(wait_area, TRUE)) //we can have the previous area checked for players before we trigger shit,
					for(var/mob/TM in get_turf(WA))			   //so it lessens the chance of a group getting split in and out a arena
						if(TM.mind)
							return
			for(var/obj/boss_spawn_trigger/T in world)
				if (T.id == src.id)
					T.active = TRUE
			for(var/obj/machinery/door/poddoor/P in by_type[/obj/machinery/door]) //robbed checkpoint bot code
				if (P.id == src.id)
					if (!P.density)
						SPAWN( 0 )
							P.close()
			for(var/obj/boss_spawn_marker/T in world)
				if (T.id == src.id)
					SpawnBoss(get_turf(T))
		..()

	proc/SpawnBoss(spawn_point = get_turf(src), height = 7, use_shadow=TRUE, boss_type=boss_path) //wowwie more ripped code
		logTheThing(LOG_COMBAT, src, "toxmoon boss summoned at [log_loc(src)].")
		src.anchored = ANCHORED_ALWAYS

		var/obj/boss = new boss_type(spawn_point)
		boss.anchored = ANCHORED_ALWAYS
		boss.pixel_y = 32 * height
		boss.alpha = 0
		boss.layer += 4
		boss.plane = PLANE_NOSHADOW_ABOVE
		animate(boss, alpha = 255, time = 0.9 SECONDS, flags = ANIMATION_PARALLEL)
		animate(boss, pixel_y = 0, easing = EASE_IN | QUAD_EASING, time = 1.84 SECONDS, flags = ANIMATION_PARALLEL)

		var/obj/effects/shadow
		if(use_shadow)
			shadow = new /obj/effects{
				icon='icons/effects/96x96.dmi';
				icon_state="circle";
				mouse_opacity = 0;
				color = "#000000";
				alpha = 0;
				transform = matrix(0.8, 0, 0, 0, 0.5, 0);
				pixel_x = -32;
				pixel_y = -32 - 7;
				anchored = ANCHORED_ALWAYS;
				plane = PLANE_NOSHADOW_BELOW
			}(get_turf(src))
			animate(spawn_point, alpha = 150, transform = matrix(0.25, 0, 0, 0, 0.17, 0), easing = EASE_IN | QUAD_EASING, time = 1.75 SECONDS, flags = ANIMATION_PARALLEL)

		playsound(get_turf(src), 'sound/effects/cartoon_fall.ogg', 50, FALSE)
		SPAWN(1.8 SECONDS)
			boss.anchored = boss_type == boss_type ? FALSE : initial(boss.anchored)
			boss.plane = initial(boss.plane)
			if(shadow)
				qdel(shadow)

///// Boss AI

/datum/aiHolder/noxia
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/ranged, list(src))

/datum/aiTask/prioritizer/critter/noxia/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/turf_attack, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/range_attack, list(src.holder, src))

//--------------------------------------------------------------------------------------------------------------------------------------------------//

/mob/living/critter/noxia_abomination
	name = "Writhing Abomination"
	desc = "Oh my god, what the fuck, how the fuck does something like this come to exist, like what the actual fuck, this is a affront to Darwinism."
	health_brute = 500
	health_brute_vuln = 0.2
	health_burn = 500
	health_burn_vuln = 0.6
	stamina = INFINITY // Don't want something hanging from the ceiling to go horizontal
	icon = 'icons/mob/critter/nonhuman/critter160x160.dmi'
	icon_state = "nabom"
	bound_width = 160
	bound_height = 160
	pixel_x = -64
	pixel_y = -128
	bound_x = -64
	isFlying = TRUE // on da ceilin
	event_handler_flags = IMMUNE_TRENCH_WARP
	anchored = TRUE
	ai_type = /datum/aiHolder/noxia
	var/entrance_id = "toxmoon_boss"
	var/exit_id = "toxmoon_loot"
	add_abilities = list(/datum/targetable/critter/spit/low_cd)

	New()
		..()
		remove_lifeprocess(/datum/lifeprocess/radiation)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_GOOPIMMUNE, src.type)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_CANTMOVE, src.type)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_CANTTURN, src.type)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_CANT_BE_PINNED, src.type)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_SELF_HARM, src.type)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_UNGRABBABLE, src.type)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_UNBUMPABLE, src.type)
		src.bioHolder.AddEffect("radioactive")


	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_brute_vuln)

	death(gibbed, do_drop_equipment)
		for(var/obj/machinery/door/poddoor/P in by_type[/obj/machinery/door]) //robbed checkpoint bot code
			if (P.id == src.entrance_id || src.exit_id)
				if (P.density)
					SPAWN( 0 )
						P.open()
		. = ..()

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/spit/low_cd/spit = src.abilityHolder.getAbility(/datum/targetable/critter/spit/low_cd)
		src.set_dir(get_dir(src, target))

		if (!spit.disabled && spit.cooldowncheck() && prob(10))
			spit.handleCast(target)
			return TRUE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/spit
		HH.icon_state = "gun"
		HH.limb_name = "spitter arm"


/datum/targetable/critter/aoe
	area_attack(var/mob/summoned_thing, var/drop_prob, var/range_num=14)
		for(var/turf/T in range(range_num))
			if(!src.loc && !rand(0,drop_prob))
				new summoned_thing(src.loc)

/datum/targetable/critter/aoe/backup_call
	var/backup_type = null
	if(src.area_attack)
		var/type_modifier = rand(1,10)
		if (type_modifier == 7 || 8)
			backup_type = /mob/living/critter/radthing
		else if (type_modifier == 9)
			backup_type = /mob/living/critter/radthing/spitter
		else if (type_modifier == 10)
			backup_type = /mob/living/critter/radthing/neutron
		else
			backup_type = /mob/living/critter/zombie/radiation
		area_attack(backup_type, 98)

/datum/targetable/critter/aoe/acid
	if(src.area_attack)
		area_attack(/obj/decal/acid_splash, 19) //1/10

/datum/targetable/critter/aoe/radiation

/obj/lead_rubble
	name = "batiline debris"
	desc = "Some radiation shielding that fell from a upper level. Might be useful if it doesn't fall apart first."
