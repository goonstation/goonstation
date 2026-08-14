/datum/map_correctness_check/area_contents/medical_director
	check_name = "Medical Director's Office Content Check"
	target_areas = list(/area/station/medical/head)

	expected_contents = list(
		// Generic head stuff
		CONTENTS_EQ(/obj/storage/secure/closet/command/medical_director, 1),
		CONTENTS_EQ(/obj/item/stamp/md, 1),
		CONTENTS_EQ(/obj/machinery/computer/card/department/medical, 1)
		CONTENTS_EQ(/obj/critter/bat/doctor, 1),
		CONTENTS_EQ(/obj/mapping_helper/mailtag/command_office/md, 1),

		// MD stuff
		CONTENTS_EQ(/obj/item/device/analyzer/healthanalyzer/upgraded, 1),
		CONTENTS_EQ(/obj/item/clothing/glasses/healthgoggles/upgraded, 1),
		CONTENTS_OR(
			CONTENTS_EQ(list(/obj/decal/poster/wallsign/framed_award/mdlicense)),
			CONTENTS_EQ(list(/obj/item/mdlicense)),
		)
	)
