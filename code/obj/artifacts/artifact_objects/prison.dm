/obj/artifact/prison
	name = "artifact imprisoner"
	associated_datum = /datum/artifact/prison

/datum/artifact/prison
	associated_object = /obj/artifact/prison
	type_name = "Prison"
	rarity_weight = 350
	min_triggers = 2
	max_triggers = 2
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	react_xray = list(15,90,90,11,"HOLLOW")
	touch_descriptors = list("You seem to have a little difficulty taking your hand off its surface.")
	var/mob/living/prisoner = null
	var/imprison_time = 0

	New()
		..()
		imprison_time = rand(5 SECONDS, 2 MINUTES)

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!user)
			return
		if (prisoner)
			return
		if (isliving(user))
			O.visible_message("<span class='alert'><b>[O]</b> suddenly pulls [user.name] inside and slams shut!</span>")
			user.set_loc(O)
			O.ArtifactFaultUsed(user)
			prisoner = user
			SPAWN_DBG(imprison_time)
				if (!O.disposed) //ZeWaka: Fix for null.contents
					O.ArtifactDeactivated()

	effect_deactivate(obj/O)
		if (..())
			return
		for(var/obj/I in O.contents)
			I.set_loc(get_turf(O))
		if (prisoner?.loc == O)
			prisoner.set_loc(get_turf(O))
			O.visible_message("<span class='alert'><b>[O]</b> releases [prisoner.name] and shuts down!</span>")
		else
			O.visible_message("<span class='alert'><b>[O]</b> shuts down strangely!</span>")
		prisoner = null
