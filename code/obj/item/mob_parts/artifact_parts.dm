ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/artifact_part)

/obj/item/mob_part/humanoid_part/artifact_part
	flags = FPRINT | TABLEPASS
	accepts_normal_human_overlays = FALSE
	limb_is_unnatural = TRUE
	kind_of_limb = LIMB_ARTIFACT
	show_on_examine = TRUE
	var/artifact_type = null

	New(atom/new_holder)
		..()

		if (ishuman(new_holder))
			SPAWN(0.1 SECONDS) // required for abilities to be applied
				src.on_attach()

	delete()
		src.on_remove()
		..()

	remove(show_message)
		src.on_remove()
		return ..()

	sever(mob/user)
		src.on_remove()
		return ..()

	attach(mob/living/carbon/human/attachee, mob/attacher)
		if (..())
			src.on_attach()

	proc/on_attach()
		return ishuman(src.holder)

	proc/on_remove()
		return ishuman(src.holder)

ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/artifact_part/eldritch)
/obj/item/mob_part/humanoid_part/artifact_part/eldritch
	item_state = "eldritch-limb"
	artifact_type = "eldritch"
	limb_icon_suffix = "eldritch"

	New(atom/new_holder)
		..()
		src.cut_messages = list("slowly cuts through", "slowly cut through")
		src.saw_messages = list("gradually saws through", "gradually saw through")
		src.limb_material = list("twisted sinew","dark ivory","shriveling tendons")

ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/artifact_part/eldritch/arm)
/obj/item/mob_part/humanoid_part/artifact_part/eldritch/arm
	limb_type = /datum/limb/eldritch
	can_hold_items = TRUE

	New(atom/new_holder)
		..()
		src.name = pick("vile", "threatening", "intimidating") + " [src.side]" + " claw"

	left
		name = "eldritch left arm"
		slot = "l_arm"
		side = "left"
		icon_state = "arm-eldritch-L"
	right
		name = "eldritch right arm"
		slot = "r_arm"
		side = "right"
		icon_state = "arm-eldritch-R"


ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/artifact_part/eldritch/leg)
/obj/item/mob_part/humanoid_part/artifact_part/eldritch/leg

	New()
		..()
		src.name = pick("vile", "threatening", "scary") + " [src.side]" + " leg"

	on_attach()
		if (!..())
			return
		var/mob/living/carbon/human/H = holder
		H.update_clothing()
		if (istype(H.limbs.get_limb("l_leg"), /obj/item/mob_part/humanoid_part/artifact_part/eldritch/leg/left) && istype(H.limbs.get_limb("r_leg"), /obj/item/mob_part/humanoid_part/artifact_part/eldritch/leg/right))
			src.holder.addAbility(/datum/targetable/artifact_limb_ability/eldritch_run)

	on_remove()
		if (!..())
			return
		src.holder.removeAbility(/datum/targetable/artifact_limb_ability/eldritch_run)

	left
		name = "eldritch left leg"
		slot = "l_leg"
		side = "left"
		step_image_state = "footprintsL"
		icon_state = "leg-eldritch-L"

	right
		name = "eldritch right leg"
		slot = "r_leg"
		side = "right"
		step_image_state = "footprintsR"
		icon_state = "leg-eldritch-R"

ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/artifact_part/martian)
/obj/item/mob_part/humanoid_part/artifact_part/martian
	item_state = "martian-limb"
	artifact_type = "martian"
	limb_icon_suffix = "martian"

	New(atom/new_holder)
		..()
		src.cut_messages = list("swiftly cuts through", "swiftly cut through")
		src.saw_messages = list("easily saws through", "easily saw through")
		src.limb_material = list("woven tendrils","denser tentacles","wriggling strands")

ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/artifact_part/martian/arm)
/obj/item/mob_part/humanoid_part/artifact_part/martian/arm
	can_hold_items = TRUE

	New(atom/new_holder)
		..()
		src.name = pick("entwined", "jittery", "soft") + " [src.side]" + " tentacles"

	on_attach()
		if (!..())
			return
		var/mob/living/carbon/human/H = holder
		if (istype(H.limbs.get_limb("l_arm"), /obj/item/mob_part/humanoid_part/artifact_part/martian/arm/left) && istype(H.limbs.get_limb("r_arm"), /obj/item/mob_part/humanoid_part/artifact_part/martian/arm/right))
			src.holder.addAbility(/datum/targetable/artifact_limb_ability/martian_pull)

	on_remove()
		if (!..())
			return
		src.holder.removeAbility(/datum/targetable/artifact_limb_ability/martian_pull)

	left
		name = "martian left arm"
		slot = "l_arm"
		side = "left"
		icon_state = "arm-martian-L"
		hand_layer_icon_state = "l_hand_martian"

	right
		name = "martian right arm"
		slot = "r_arm"
		side = "right"
		icon_state = "arm-martian-R"
		hand_layer_icon_state = "r_hand_martian"

ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/artifact_part/martian/leg)
/obj/item/mob_part/humanoid_part/artifact_part/martian/leg

	New()
		..()
		src.name = pick("entwined", "jittery", "pulsing") + " [src.side]" + " leg"

	left
		name = "martian left leg"
		slot = "l_leg"
		side = "left"
		step_image_state = "footprintsL"
		icon_state = "leg-martian-L"
		movement_modifier = /datum/movement_modifier/martian_legs/left

	right
		name = "martian right leg"
		slot = "r_leg"
		side = "right"
		step_image_state = "footprintsR"
		icon_state = "leg-martian-R"
		movement_modifier = /datum/movement_modifier/martian_legs/right

ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/artifact_part/precursor)
/obj/item/mob_part/humanoid_part/artifact_part/precursor
	item_state = "precursor-limb"
	artifact_type = "precursor"
	limb_icon_suffix = "precursor"

	New(atom/new_holder)
		..()
		src.cut_messages = list("roughly cuts through", "roughly cut through")
		src.saw_messages = list("messily saws through", "messily saw through")
		src.limb_material = list("smooth metal","shifting doodads","integral supports")

ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/artifact_part/precursor/arm)
/obj/item/mob_part/humanoid_part/artifact_part/precursor/arm
	can_hold_items = TRUE

	New(atom/new_holder)
		..()
		src.name = pick("ancient", "old", "humming") + " [src.side]" + " device"

	on_attach()
		if (!..())
			return
		var/mob/living/carbon/human/H = holder
		if (istype(H.limbs.get_limb("l_arm"), /obj/item/mob_part/humanoid_part/artifact_part/precursor/arm/left) && istype(H.limbs.get_limb("r_arm"), /obj/item/mob_part/humanoid_part/artifact_part/precursor/arm/right))
			src.holder.addAbility(/datum/targetable/artifact_limb_ability/precursor_heal)

	on_remove()
		if (!..())
			return
		src.holder.removeAbility(/datum/targetable/artifact_limb_ability/precursor_heal)

	left
		name = "precursor left arm"
		slot = "l_arm"
		side = "left"
		icon_state = "arm-precursor-L"
		hand_layer_icon_state = "l_hand_precursor"

	right
		name = "precursor right arm"
		slot = "r_arm"
		side = "right"
		icon_state = "arm-precursor-R"
		hand_layer_icon_state = "r_hand_martian"

ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/artifact_part/precursor/leg)
/obj/item/mob_part/humanoid_part/artifact_part/precursor/leg

	New()
		..()
		src.name =  pick("ancient", "old", "clunky") + " [src.side]" + " leg"

	on_attach()
		if (!..())
			return
		if (src.side == "left")
			RegisterSignal(src.holder, COMSIG_MOVABLE_MOVED, PROC_REF(precursor_move_L))
		else
			RegisterSignal(src.holder, COMSIG_MOVABLE_MOVED, PROC_REF(precursor_move_R))

	on_remove()
		if (!..())
			return
		UnregisterSignal(src.holder, COMSIG_MOVABLE_MOVED)

	proc/precursor_move_L(mob/living/carbon/human/H, oldLoc, direction)
		if (H.lying)
			return

		var/turf/T = get_turf(oldLoc)

		var/image/I = image('icons/obj/artifacts/artifactLimbs.dmi', icon_state = "footprints-L", layer = DECAL_LAYER, dir = H.dir)
		T.UpdateOverlays(I, "precursorfootprints-L-[ref(I)]")
		SPAWN(1 SECOND)
			T.UpdateOverlays(null, "precursorfootprints-L-[ref(I)]")

	proc/precursor_move_R(mob/living/carbon/human/H, oldLoc, direction)
		if (H.lying)
			return

		var/turf/T = get_turf(oldLoc)

		var/image/I = image('icons/obj/artifacts/artifactLimbs.dmi', icon_state = "footprints-R", layer = DECAL_LAYER, dir = H.dir)
		T.UpdateOverlays(I, "precursorfootprints-R-[ref(I)]")
		SPAWN(1 SECOND)
			T.UpdateOverlays(null, "precursorfootprints-R-[ref(I)]")

	left
		name = "precursor left leg"
		slot = "l_leg"
		side = "left"
		step_image_state = "footprintsL"
		icon_state = "leg-precursor-L"
		hand_layer_icon_state = "leg-precursor-L-attached"

	right
		name = "precursor right leg"
		slot = "r_leg"
		side = "right"
		step_image_state = "footprintsR"
		icon_state = "leg-precursor-R"
		hand_layer_icon_state = "leg-precursor-R-attached"

/datum/targetable/artifact_limb_ability
	icon = 'icons/mob/artifact_limb_abilities.dmi'
	icon_state = "template-eldritch"
	last_cast = 0
	target_anything = TRUE

/datum/targetable/artifact_limb_ability/eldritch_run
	name = "Blood sprint"
	desc = "For a short time, reduce the stamina cost of running at the cost of blood!"
	icon_state = "eldritch-blood-run"
	cooldown = 60 SECONDS

	cast(atom/target)
		playsound(get_turf(holder.owner), pick('sound/machines/ArtifactEld1.ogg', 'sound/machines/ArtifactEld2.ogg'), 50, 1)
		RegisterSignal(holder.owner, COMSIG_MOVABLE_MOVED, PROC_REF(eldritch_move))
		SPAWN(10 SECONDS)
			UnregisterSignal(holder.owner, COMSIG_MOVABLE_MOVED)

	proc/eldritch_move(mob/living/M, oldLoc, direction)
		if (M.client?.check_key(KEY_RUN))
			if (M.blood_volume >= 5)
				M.blood_volume -= 5
				M.add_stamina(STAMINA_COST_SPRINT)

/datum/targetable/artifact_limb_ability/martian_pull
	name = "Martian grapple"
	desc = "Use martian tentacles to pull yourself to a sizeable object, mob, or wall!"
	icon_state = "martian-pull"
	targeted = TRUE
	cooldown = 30 SECONDS

	cast(atom/target)
		var/dist = GET_DIST(holder.owner, target)
		if (dist > 6)
			boutput(holder.owner, SPAN_ALERT("The target is too far away!"))
			return TRUE
		if (dist <= 1)
			boutput(holder.owner, SPAN_ALERT("You're already next to the target!"))
			return TRUE
		if (isrestrictedz(holder.owner.z))
			boutput(holder.owner, SPAN_ALERT("This place is too dangerous for you to be using your tentacles!"))
			return TRUE
		if (!can_act(holder.owner))
			boutput(holder.owner, SPAN_ALERT("You can't use your tentacles at the moment!"))
			return TRUE
		if (holder.owner.z == Z_LEVEL_NULL)
			return TRUE

		var/atom/tentacle_end = new /obj/martian_tentacle_end_dummy(get_turf(target))
		var/list/tentacles = DrawLine(holder.owner, tentacle_end, /obj/line_obj/martian_tentacle, 'icons/obj/artifacts/artifactLimbs.dmi', "tentacle-whole", TRUE, TRUE, "tentacle-half-start", "tentacle-half-end")

		var/found_target = FALSE
		var/done_early = FALSE

		for(var/obj/tentacle as anything in tentacles)
			if (found_target || done_early)
				tentacle.invisibility = INVIS_ALWAYS_ISH
				continue

			var/turf/T = tentacle.loc
			dist = GET_DIST(holder.owner, T)

			if (T.density)
				if (dist <= 1)
					if (dist <= 0)
						continue
					if (dist == 1)
						tentacle.invisibility = INVIS_ALWAYS_ISH
						boutput(holder.owner, SPAN_ALERT("You're already next to [T]!"))
						done_early = TRUE
						continue
				boutput(holder.owner, SPAN_ALERT("You pull yourself to [T]."))
				holder.owner.set_loc(get_step(T, get_dir(T, holder.owner)))
				tentacle.icon_state = "tentacle-half-end"
				found_target = TRUE
				continue

			for (var/atom/A as anything in T)
				if (!A.density)
					continue
				if (dist <= 1)
					if (dist <= 0)
						break
					if (dist == 1)
						tentacle.invisibility = INVIS_ALWAYS_ISH
						boutput(holder.owner, SPAN_ALERT("You're already next to [A]!"))
						done_early = TRUE
						break
				boutput(holder.owner, SPAN_ALERT("You pull yourself to [A]."))
				holder.owner.set_loc(get_step(T, get_dir(T, holder.owner)))
				tentacle.icon_state = "tentacle-half-end"
				found_target = TRUE
				break

		if (!done_early)
			playsound(holder.owner, 'sound/impact_sounds/Generic_Snap_1.ogg', 40, 1)

		SPAWN(0.2 SECONDS)
			for (var/obj/tentacle as anything in tentacles)
				qdel(tentacle)
			qdel(tentacle_end)

		return !found_target

/obj/line_obj/martian_tentacle
	name = "Martian tentacle"
	desc = ""
	anchored = ANCHORED
	density = FALSE
	opacity = FALSE

/obj/martian_tentacle_end_dummy
	name = ""
	desc = ""
	anchored = ANCHORED
	density = FALSE
	opacity = FALSE
	invisibility = INVIS_ALWAYS_ISH

/datum/targetable/artifact_limb_ability/precursor_heal
	name = "Precursor heal"
	desc = "Use ancient power to heal a target of a heart attack, relieve an ailment, or remove any foreign material!"
	icon_state = "precursor-heal"
	targeted = TRUE
	cooldown = 120 SECONDS
	var/static/list/allowed_ailments = null
	// not counting maladies
	var/static/list/unhealable_ailments = list(/datum/ailment/disease/kuru, /datum/ailment/disease/gbs, /datum/ailment/disease/monkey_madness,
											/datum/ailment/disease/hootonium, /datum/ailment/disability/memetic_madness,
											/datum/ailment/disability/clumsy, /datum/ailment/disability/clumsy/cluwne,
											/datum/ailment/disease/cluwneing_around/cluwne, /datum/ailment/disease/teleportitis,
											/datum/ailment/disease/robotic_transformation, /datum/ailment/disease/corrupt_robotic_transformation,
											/datum/ailment/disease/good_robotic_transformation, /datum/ailment/disease/noheart,
											/datum/ailment/disease/kidney_failure/left, /datum/ailment/disease/kidney_failure/right,
											/datum/ailment/disease/liver_failure, /datum/ailment/disease/respiratory_failure/left,
											/datum/ailment/disease/respiratory_failure/right,
											/datum/ailment/parasite/headspider)

	New(datum/abilityHolder/holder)
		..()
		if (src.allowed_ailments)
			return
		src.allowed_ailments = list()
		for (var/ailment in typesof(/datum/ailment))
			src.allowed_ailments[ailment] = TRUE
		for (var/ailment in typesof(/datum/ailment/malady))
			src.allowed_ailments[ailment] = FALSE
		for (var/ailment in unhealable_ailments)
			src.allowed_ailments[ailment] = FALSE

	cast(atom/target)
		if (GET_DIST(holder.owner, target) > 1)
			boutput(holder.owner, SPAN_ALERT("The target is too far away!"))
			return TRUE
		if (!isliving(target) || issilicon(target) || isintangible(target) || islivingobject(target))
			boutput(holder.owner, SPAN_ALERT("Your power cannot be used on this target!"))
			return TRUE
		if (target == holder.owner)
			boutput(holder.owner, SPAN_ALERT("It could be dangerous using this power on yourself!"))
			return TRUE
		if (is_incapacitated(holder.owner))
			boutput(holder.owner, SPAN_ALERT("You can't use your power while incapacitated!"))
			return TRUE
		if (holder.owner.z == Z_LEVEL_NULL)
			return TRUE

		var/mob/living/M = target

		if (length(M.ailments))
			if (M.cure_disease_by_path(/datum/ailment/malady/flatline))
				boutput(holder.owner, SPAN_ALERT("You heal [M]'s heart attack!"))
				boutput(M, SPAN_NOTICE("The pain in your heart suddenly goes away!"))
				return

			for (var/datum/ailment_data/A as anything in M.ailments)
				if (A.master?.type && src.allowed_ailments[A.master.type] && M.cure_disease_by_path(A.master.type))
					boutput(holder.owner, SPAN_ALERT("You heal [M] of an ailment!"))
					boutput(M, SPAN_NOTICE("You suddenly feel a lot better!"))
					return

		if (length(M.implant) && (locate(/obj/item/implant/projectile) in M.implant))
			for (var/obj/item/implant/projectile/I in M.implant)
				I.on_remove(M)
				M.implant.Remove(I)
				I.set_loc(M.loc)
				// scatter on ground
				I.pixel_x = rand(-11, 8)
				I.pixel_y = rand(-9, -5)
			boutput(holder.owner, SPAN_ALERT("You pull foreign material out of [M]!"))
			boutput(M, SPAN_NOTICE("You feel some bad stuff fall out of your chest!"))
			return

		boutput(holder.owner, SPAN_ALERT("[M] has nothing wrong with [him_or_her(M)] that can be healed!"))
		return TRUE
