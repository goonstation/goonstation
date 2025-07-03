/obj/artifact/prison
	name = "artifact imprisoner"
	associated_datum = /datum/artifact/prison

/datum/artifact/prison
	associated_object = /obj/artifact/prison
	type_name = "Prison"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	min_triggers = 2
	max_triggers = 2
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	react_xray = list(15,90,90,11,"HOLLOW")
	touch_descriptors = list("You seem to have a little difficulty taking your hand off its surface.")
	combine_flags = ARTIFACT_ACCEPTS_ANY_COMBINE
	var/mob/living/prisoner = null
	var/living = FALSE
	var/imprison_time = 0

	New()
		..()
		imprison_time = rand(5 SECONDS, 2 MINUTES)
		if (prob(10))
			living = TRUE

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!user)
			return
		if (prisoner)
			return
		if (isliving(user))
			if (length(user.grabbed_by) > 0)
				for (var/obj/item/grab/grab in user.grabbed_by)
					grab.assailant.u_equip(grab)
			O.visible_message(SPAN_ALERT("<b>[O]</b> suddenly pulls [user.name] inside and slams shut!"))
			if (src.living)
				new /mob/living/object/artifact(O.loc, O, user)
			else
				user.set_loc(O)
			O.ArtifactFaultUsed(user)
			prisoner = user
			SPAWN(imprison_time)
				if (!O.disposed) //ZeWaka: Fix for null.contents
					O.ArtifactDeactivated()

	effect_deactivate(obj/O)
		if (..())
			return
		if (living && istype(O.loc, /mob/living/object))
			var/mob/living/object/mob = O.loc
			mob.visible_message(SPAN_ALERT("[prisoner.name] is ejected from [mob] and regains control of their body."))
			mob.death(FALSE)
		if (prisoner?.loc == O)
			prisoner.set_loc(get_turf(O))
			O.visible_message(SPAN_ALERT("<b>[O]</b> releases [prisoner.name] and shuts down!"))
		else
			O.visible_message(SPAN_ALERT("<b>[O]</b> shuts down strangely!"))
		for(var/atom/movable/I in (O.contents-O.vis_contents))
			I.set_loc(get_turf(O))
		prisoner = null

/mob/living/object/artifact

	New()
		..()
		qdel(src.hud) // no escape!!!

	click(atom/target, params)
		if (target == src) // no recursive living objects ty
			return
		..()
