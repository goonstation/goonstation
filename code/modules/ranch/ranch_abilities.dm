// Shared Ranch Abilities

// Fire Breath
// Magic Missile
// Mime Cage
// Medusa
// Cluwne Mask

/datum/targetable/critter/fire_breath
	name = "Fire Breath"
	desc = "Huff and puff, and burn their house down!"
	icon_state = "template"
	targeted = 1
	target_anything = 1
	var/max_fire_range = 3
	cooldown = 10 SECONDS
	var/temp = 1200

	cast(atom/target)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		var/list/affected_turfs = getline(holder.owner, T)
		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] breathes fire!</b>"))
		playsound(holder.owner.loc, 'sound/effects/mag_fireballlaunch.ogg', 50, 0)
		var/turf/currentturf
		var/turf/previousturf
		for(var/turf/F in affected_turfs)
			previousturf = currentturf
			currentturf = F
			if(currentturf.density || istype(currentturf, /turf/space))
				break
			if(previousturf && LinkBlocked(previousturf, currentturf))
				break
			if (F == get_turf(holder.owner))
				continue
			if (get_dist(holder.owner,F) > max_fire_range)
				continue
			fireflash(F,0.5,temp)

/datum/targetable/critter/cluwnemask
	name = "Cluwne Mask"
	desc = "Share your Pain"
	icon_state = "template"
	targeted = 1
	target_anything = 1
	max_range = 3
	cooldown = 10 SECONDS
	var/temp = 1200

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living/carbon/human) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to share your pain with there."))
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to share your pain with."))
			return 1

		var/mob/living/carbon/human/H = target
		if(istype(H))
			logTheThing(LOG_COMBAT, src.holder.owner, "[constructTarget(H)] is cluwned by Cluwne Mask at [log_loc(H)]")
			if(H.wear_mask)
				if(istype(H.wear_mask,/obj/item/clothing/mask/cursedclown_hat))
					return
				var/obj/item/I = H.wear_mask
				H.u_equip(I)
				I.set_loc(H.loc)
			holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] sobs uncontrollaby, sharing its pain with [target]!</b>"))
			var/obj/item/clothing/mask/cursedclown_hat/C = new()
			C.infectious = TRUE
			H.force_equip(C, SLOT_WEAR_MASK)
			playsound(get_turf(H), pick('sound/voice/cluwnelaugh1.ogg','sound/voice/cluwnelaugh2.ogg','sound/voice/cluwnelaugh3.ogg'), 35, 0, 0, max(0.7, min(1.4, 1.0 + (30 - H.bioHolder.age)/50)))

/datum/targetable/critter/magic_missile
	name = "Magic Missile"
	desc = "Attacks a nearby foe with a stunning projectile."
	icon_state = "template"
	targeted = 1
	cooldown = 30

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living/carbon/human) in target
		var/mob/M = target
		if(istype(M))
			holder.owner.say("BUK BAGAWK!")
			playsound(holder.owner.loc, 'sound/effects/mag_magmislaunch.ogg', 25, 1, -1)
			SPAWN(0)
				var/obj/overlay/A = new /obj/overlay(holder.owner.loc)
				A.icon_state = "magicm"
				A.icon = 'icons/obj/wizard.dmi'
				A.name = "a magic missile"
				A.anchored = 0
				A.set_density(0)
				A.layer = EFFECTS_LAYER_1
				A.flags |= TABLEPASS
				//A.sd_SetLuminosity(3)
				//A.sd_SetColor(0.7, 0, 0.7)
				var/i
				for(i=0, i<20, i++)
					var/obj/overlay/B = new /obj/overlay(A.loc)
					B.icon_state = "magicmd"
					B.icon = 'icons/obj/wizard.dmi'
					B.name = "trail"
					B.anchored = 1
					B.set_density(0)
					B.layer = EFFECTS_LAYER_BASE
					SPAWN(0.5 SECONDS)
						qdel(B)
					step_to(A,M,0)
					if (get_dist(A,M) == 0)
						M.changeStatus("knockdown", 1 SECOND)
						M.force_laydown_standup()
						boutput(M, SPAN_NOTICE("The magic missile SLAMS into you!"))
						M.visible_message(SPAN_ALERT("[M] is struck by a magic missile!"))
						playsound(M.loc, 'sound/effects/mag_magmisimpact.ogg', 25, 1, -1)
						M.TakeDamage("chest", 0, 10, 0, DAMAGE_BURN)
						random_brute_damage(M, 5)
						M.lastattacker = get_weakref(holder.owner)
						M.lastattackertime = world.time
						qdel(A)
						return
					sleep(0.6 SECONDS)
				qdel(A)

/datum/targetable/critter/ice_burst
	name = "Ice Burst"
	desc = "Attacks a nearby foe with a freezing projectile."
	icon_state = "template"
	targeted = 1
	cooldown = 30

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living/carbon/human) in target
		var/mob/M = target
		if(istype(M))
			holder.owner.say("BUK BAGAWK!")
			playsound(holder.owner.loc, 'sound/effects/mag_iceburstlaunch.ogg', 25, 1, -1)
			SPAWN(0)
				var/obj/overlay/A = new /obj/overlay( holder.owner.loc )
				A.icon_state = "icem"
				A.icon = 'icons/obj/wizard.dmi'
				A.name = "ice bolt"
				A.anchored = 0
				A.set_density(0)
				A.layer = MOB_EFFECT_LAYER
				//A.sd_SetLuminosity(3)
				//A.sd_SetColor(0, 0.1, 0.8)
				var/i
				for(i=0, i<20, i++)
					if (!locate(/obj/decal/icefloor) in A.loc)
						var/obj/decal/icefloor/B = new /obj/decal/icefloor(A.loc)
						//B.sd_SetLuminosity(1)
						//B.sd_SetColor(0, 0.1, 0.8)
						SPAWN(20 SECONDS)
							qdel (B)
					step_to(A,M,0)
					if (GET_DIST(A,M) == 0)
						boutput(M, SPAN_NOTICE("You are chilled by a burst of magical ice!"))
						M.visible_message(SPAN_ALERT("[M] is struck by magical ice!"))
						playsound(holder.owner.loc, 'sound/effects/mag_iceburstimpact.ogg', 25, 1, -1)
						M.bodytemperature = 0
						M.lastattacker = get_weakref(holder.owner)
						M.lastattackertime = world.time
						qdel(A)
						if(prob(40))
							M.visible_message(SPAN_ALERT("[M] is frozen solid!"))
							new /obj/icecube(M.loc, M)
						return
					sleep(0.5 SECONDS)
				qdel(A)

/datum/targetable/critter/fireball/chicken
	cast(atom/target)
		holder.owner.say("BUK BAGAWK!")
		. = ..()


/datum/targetable/critter/medusa
	name = "Medusa Squirt"
	desc = "Squirts medusa into the eyes of your enemy."
	icon_state = "template"
	targeted = 1
	cooldown = 60

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living/) in target
		var/mob/living/L = target
		if(istype(L))
			holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] squirts some kind of venom out of their eyes at [target]!</b>"))
			boutput(L,SPAN_ALERT("<b>Oh god! Your eyes!</b>"))
			L.take_eye_damage(5, 5)
			L.contract_disease(/datum/ailment/disease/medusa, null, null, 1)

/datum/targetable/critter/mime_cage
	name = "Invisible Cage"
	desc = "Temporarily turns a turf into an invisible cage."
	icon_state = "template"
	targeted = 1
	cooldown = 5
	var/obj/mime_cage/my_cage = null
	var/cage_lifetime = 10 SECONDS
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return 1

		var/turf/T = get_turf(target)

		if(T)
			if(my_cage)
				qdel(my_cage)
			holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] points at [T] threateningly!</b>"))
			blink(T)
			my_cage = new/obj/mime_cage(T,cage_lifetime)

/obj/mime_cage
	name = null
	desc = null
	icon = null
	icon_state = null
	anchored = 1
	density = 1
	event_handler_flags = USE_FLUID_ENTER
	object_flags = HAS_DIRECTIONAL_BLOCKING
	var/lifetime = 10 SECONDS

	New(loc, var/life_time)
		. = ..()
		src.set_dir(15)
		if(life_time)
			lifetime = life_time
		SPAWN(lifetime)
			qdel(src)

	Cross(atom/movable/O as mob|obj)
		if (O == null)
			return 0
		if (dir & get_dir(loc, O))
			return !density
		return 1

	Uncross(atom/movable/O, do_bump=TRUE)
		if (dir & get_dir(O.loc, O.movement_newloc))
			. = 0
		else
			. = 1
		UNCROSS_BUMP_CHECK(O)

/datum/targetable/critter/bee_teleport/non_bee
	do_buzz = 0

/datum/targetable/vampire/glare/cockatrice
	preferred_holder_type = /datum/abilityHolder/critter
