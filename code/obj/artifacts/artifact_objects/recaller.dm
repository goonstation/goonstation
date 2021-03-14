/obj/artifact/teleport_recaller
	name = "artifact recaller"
	associated_datum = /datum/artifact/recaller

/datum/artifact/recaller
	associated_object = /obj/artifact/teleport_recaller
	type_name = "Recaller"
	rarity_weight = 450
	validtypes = list("wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activated = 0
	react_xray = list(15,75,90,3,"ANOMALOUS")
	var/recall_delay = 10

	New()
		..()
		src.recall_delay = rand(2,600) // how long *10 it takes for the recall to happen
		src.recall_delay *= 10

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!user)
			return

		O.ArtifactFaultUsed(user)
		SPAWN_DBG(src.recall_delay)
			if (user && src.activated) //Wire note: Fix for Cannot execute null.visible message()
				user.visible_message("<span class='alert'><b>[user]</b> is suddenly pulled through space!</span>")
				playsound(user.loc, "sound/effects/mag_warp.ogg", 50, 1, -1)
				var/turf/T = get_turf(O)
				if (T)
					user.set_loc(T)
					O.ArtifactFaultUsed(user)
