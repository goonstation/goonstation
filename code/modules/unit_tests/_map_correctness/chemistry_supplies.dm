/datum/map_correctness_check/chemistry_supplies
	check_name = "Chemistry Department Undersupply"

/datum/map_correctness_check/chemistry_supplies/run_check()
	. = list()

	var/basic_supplies = FALSE
	var/aux_supplies = FALSE
	var/orbital_shaker = FALSE

	for_by_tcl(table, /obj/table/reinforced/chemistry/auto)
		var/area/A = get_area(table)
		if (!istype(A, /area/station/science/chemistry))
			continue

		if(istype(table,/obj/table/reinforced/chemistry/auto/basicsup))
			basic_supplies = TRUE
		if(istype(table,/obj/table/reinforced/chemistry/auto/auxsup))
			aux_supplies = TRUE

	for_by_tcl(shaker, /obj/machinery/chem_shaker)
		var/area/A = get_area(shaker)
		if (!istype(A, /area/station/science/chemistry))
			continue

		orbital_shaker = TRUE

	if(!basic_supplies) . += "No basic supply lab counter"
	if(!aux_supplies) . += "No auxiliary supply lab counter"
	if(!orbital_shaker) . += "No orbital shaker"

SET_UP_CI_TRACKING(/obj/table/reinforced/chemistry/auto)
SET_UP_CI_TRACKING(/obj/machinery/chem_shaker)
