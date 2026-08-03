/datum/map_correctness_check/area_contents/quartermasters
	check_name = "Quartermasters Contents Check"
	target_areas = list(
		/area/station/quartermaster,
		/area/station/hangar/qm,
		/area/station/crew_quarters/supplylobby
	)
	expected_contents = list(
		// Equipment
		CONTENTS_GT(/obj/machinery/manufacturer/general, 0),
		CONTENTS_GT(/obj/machinery/manufacturer/hangar, 0),
		CONTENTS_EQ(/obj/machinery/manufacturer/medical, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/robotics, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/mining, 1),
		CONTENTS_EQ(/obj/machinery/manufacturer/qm, 1),
		CONTENTS_GT(/obj/machinery/computer/supplycomp, 1),
		CONTENTS_EQ(/obj/machinery/computer/announcement/station/cargo, 1),
		CONTENTS_EQ(/obj/noticeboard/persistent/cargo, 1),
		CONTENTS_EQ(/obj/machinery/computer/chem_requester/science, 1),
		CONTENTS_EQ(/obj/submachine/cargopad/qm, 1),
		CONTENTS_EQ(/obj/machinery/disposal/mail/qm, 1),
		CONTENTS_GT(/obj/machinery/navbeacon/mule, 0),
		CONTENTS_GT(/obj/machinery/phone, 0),
		CONTENTS_GT(/obj/item/device/radio/intercom/cargo, 0),
		CONTENTS_GT(/obj/machinery/cashreg, 0),
		CONTENTS_GT(/obj/machinery/cell_charger, 0),
		CONTENTS_GT(/obj/machinery/computer/barcode, 0),
		// Supplies
		CONTENTS_GT(/obj/storage/secure/closet/engineering/cargo, 0),
		CONTENTS_GT(/obj/item/cargotele, 0),
	)
