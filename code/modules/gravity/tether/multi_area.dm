// Tethers for groups of areas that want gravity managed together
ABSTRACT_TYPE(/obj/machinery/gravity_tether/multi_area)
/obj/machinery/gravity_tether/multi_area
	// people can scan these to get single-area tethers
	mechanics_type_override = /obj/machinery/gravity_tether/current_area
	// TODO: Power balancing
	passive_wattage_per_g = 10 WATTS
	object_flags = NO_GHOSTCRITTER // not reprogrammable

	/// Base area typepath. Target should probably all share the same base area.
	var/base_area_typepath = null
	/// base area subtypes that this tether will not control
	var/list/base_area_exceptions = list()
	/// Additional area types, for outliers
	var/list/additional_area_types = list()

/obj/machinery/gravity_tether/multi_area/New()
	src.desc = " This one controls a decently sized area."
	. = ..()
	src.light.attach(src, 0.5, 1)
	src.light.set_brightness(0.7)
	src.light.set_color(255, 255, 255)

/obj/machinery/gravity_tether/multi_area/initialize()
	for (var/area/A in get_areas(src.base_area_typepath))
		var/valid = TRUE
		for (var/area_typepath in src.base_area_exceptions)
			if (A.type == area_typepath)
				valid=FALSE
				break
		if (valid)
			src.target_area_refs.Add(A)
	for (var/area_typepath in src.additional_area_types)
		var/area/area_to_add = get_area_by_type(area_typepath)
		if (istype(area_to_add))
			src.target_area_refs += area_to_add
	. = ..()

/obj/machinery/gravity_tether/proc/shake_affected()
	for (var/area/A in src.target_area_refs)
		for (var/mob/M in A)
			if (M.client)
				shake_camera(M, 5, 32, 0.2)

// near-station

// AI Satellite
/obj/machinery/gravity_tether/multi_area/ai_sat
	name = "AI Satellite gravity tether"
	req_access = list(access_heads)

	New()
		for (var/area_type in global.map_settings.ai_satellite_area_types)
			var/area/A = get_area_by_type(area_type)
			if (istype(A))
				src.target_area_refs += A
		. = ..()

// Syndicate Listening Post
/obj/machinery/gravity_tether/multi_area/listening_post
	name = "Listening Post gravity tether"
	req_access = list(access_syndicate_shuttle) // agent card
	base_area_typepath = /area/listeningpost
	base_area_exceptions = list(
		/area/listeningpost/solars,
		/area/listeningpost/comm_dish,
		/area/listeningpost/landing_bay,
	)

	// syndicate access has no name, so intercept that logic branch
	attackby(obj/item/I, mob/user)
		if (src.has_no_power())
			return ..()
		var/obj/item/card/id/id_card = get_id_card(I)
		if (istype(id_card))
			user.lastattacked = get_weakref(src)
			if (src.allowed(user))
				src.locked = !src.locked
				src.update_ma_tamper()
				src.update_ma_screen()
				src.UpdateIcon()
			else
				src.say("Syndicate access required to [src.locked ? "un" : ""]lock.", message_params=list("group"="\ref[src]_acc"))
			return
		return ..()

// per-map

// donut3 medical asylum
/obj/machinery/gravity_tether/multi_area/medical_asylum
	name = "Asylum gravity tether"
	req_access = list(access_medical_director)
	base_area_typepath = /area/station/medical/asylum
	additional_area_types = list(
		/area/station/crew_quarters/clown,
	)

// cogmap2/kondaru research outpost
/obj/machinery/gravity_tether/multi_area/research_outpost
	name = "Research Outpost gravity tether"
	req_access = list(access_research_director)
	base_area_typepath = /area/research_outpost


// donut2 research station
/obj/machinery/gravity_tether/multi_area/research_station
	name = "Reearch Station gravity tether"
	req_access = list(access_research_director)
	base_area_typepath = /area/station/science
	base_area_exceptions = list(/area/station/science/testchamber/bombchamber)
	additional_area_types = list(
		/area/station/crew_quarters/hor,
		/area/station/maintenance/scidisposal,
		/area/station/turret_protected/Zeta,
		/area/station/crew_quarters/observatory,
		/area/station/hangar/science,
	)


// asteroid field

// NT Mining outpost
/obj/machinery/gravity_tether/multi_area/mining_outpost
	name = "Mining Outpost gravity tether"
	base_area_typepath = /area/mining
	base_area_exceptions = list(
		/area/mining/mainasteroid,
		/area/mining/magnet
	)
	additional_area_types = list(/area/tech_outpost, /area/spyshack)


// debris field

// Space Diner
/obj/machinery/gravity_tether/multi_area/space_diner
	name = "Space Diner gravity tether"
	base_area_typepath = /area/diner
	base_area_exceptions = list(/area/diner/solar)

// NT Radio Ship
/obj/machinery/gravity_tether/multi_area/radio_ship
	name = "NSV Renanin gravity tether"
	base_area_typepath = /area/radiostation

// Derliect AI Sat
/obj/machinery/gravity_tether/multi_area/derelict_ai_sat
	name = "AI Satellite gravity tether"
	base_area_typepath = /area/derelict_ai_sat
	base_area_exceptions = list(/area/derelict_ai_sat/solar)

	New()
		. = ..()
		src.cell.charge = 0

// Hemera wreck
/obj/machinery/gravity_tether/multi_area/hermera
	name = "H7 gravity tether"
	base_area_typepath = /area/h7


// Azones
// TODO: Gravity is currently only recalculated on simulated tiles

// The Owlery
/obj/machinery/gravity_tether/multi_area/owlery
	name = "Owlery gravity tether"
	req_access = list(access_owlerymaint)
	base_area_typepath = /area/owlery
	base_area_exceptions = list(/area/owlery/solars)
