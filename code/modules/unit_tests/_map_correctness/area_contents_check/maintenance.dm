/datum/map_correctness_check/area_contents/maint
	check_name = "Maintenance Contents Check"
	target_areas = list(/area/station/maintenance)
	expected_contents = list(
		CONTENTS_EQ(/obj/machinery/camera, 0)
	)
