/datum/map_correctness_check/area_contents/telescience
	check_name = "Telescience Contents Check"
	only_check_on = null
	target_areas = list(
		/area/station/science/teleporter,
	)
	expected_contents = list(
		// Equipment
		CONTENTS_EQ(/obj/machinery/networked/telepad, 1),
		CONTENTS_EQ(/obj/machinery/networked/teleconsole, 1),
		CONTENTS_EQ(/obj/spawner/disk_rack_lrt, 1),
		CONTENTS_EQ(/obj/machinery/computer/telescope, 1)
	)
