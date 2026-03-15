/datum/map_correctness_check/area_contents/robotics
	check_name = "Robotics Contents Check"
	target_areas = list(
		/area/station/medical/robotics,
	)
	expected_contents = list(
		// Surgical Equipment
		CONTENTS_GT(/obj/machinery/optable, 0),
		CONTENTS_GT(/obj/machinery/computer/operating, 0),
		CONTENTS_GT(/obj/machinery/drainage, 0),
		CONTENTS_GT(/obj/machinery/sink, 0),
		// Robotics Equipment
		CONTENTS_GT(/obj/machinery/computer/robot_module_rewriter, 0),
		CONTENTS_GT(/obj/machinery/manufacturer/robotics, 0),
		CONTENTS_GT(/obj/machinery/portable_reclaimer, 0),
		CONTENTS_EQ(/obj/submachine/cargopad/robotics, 1),
		CONTENTS_GT(/obj/machinery/recharge_station, 1),
		CONTENTS_GT(/obj/machinery/cell_charger, 0),
		CONTENTS_GT(/obj/item/device/multitool, 0),
	)
