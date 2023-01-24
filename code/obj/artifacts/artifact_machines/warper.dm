/obj/machinery/artifact/warper
	name = "artifact warper"
	associated_datum = /datum/artifact/warper

/datum/artifact/warper
	associated_object = /obj/machinery/artifact/warper
	type_name = "Warper"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 365
	validtypes = list("ancient","martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,/datum/artifact_trigger/heat)
	fault_blacklist = list(ITEM_ONLY_FAULTS,TOUCH_ONLY_FAULTS)
	activ_text = "suddenly starts warping space around it!"
	deact_text = "deactivates, and lays silent."
	react_xray = list(15,75,90,3,"ANOMALOUS")
	var/max_teleports
	var/teleports = 0 //how many times has the artifact moved
	var/grab_range //at what range can we "grab" living people
	var/teleport_range
	var/wormholer = FALSE // wormholes instead of random offsets
	post_setup()
		..()
		if (prob(25))
			wormholer = TRUE
		max_teleports = rand(1,6)
		grab_range = rand(2,5)
		if (!wormholer)
			teleport_range = rand(2,8) //latest: funny is kil

	effect_process(var/obj/O)
		if (..())
			return
		if (inrestrictedz(O)) // AZONE puzzle speedrun %Any
			O.ArtifactDeactivated()
			return
		var/turf/T = get_turf(O)
		if (teleports == max_teleports)
			O.ArtifactDeactivated()
			teleports = 0
			return
		else
			var/loc = (wormholer ? pick(random_floor_turfs) : get_offset_target_turf(T, rand(-teleport_range, teleport_range), rand(-teleport_range, teleport_range)) )
			playsound(O.loc, "warp", 50)
			for (var/mob/living/M in orange(grab_range,O))
				if (isintangible(M)) continue
				M.set_loc(get_offset_target_turf(loc, rand(-grab_range, grab_range), rand(-grab_range, grab_range)))
			O.set_loc(loc)
			teleports++
