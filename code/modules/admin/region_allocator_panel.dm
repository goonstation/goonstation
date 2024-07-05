/// admin panel front end for interacting with the region allocator system
/datum/region_allocator_panel

/datum/region_allocator_panel/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/region_allocator_panel/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/region_allocator_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "RegionAllocatorPanel")
		ui.open()

/datum/region_allocator_panel/ui_data(mob/user)
	var/region_data = list()
	for (var/datum/weakref/region_ref as anything in region_allocator.allocated_regions)
		var/datum/allocated_region/region = region_ref.deref()
		region_data += list(list(
			"ref" = ref(region_ref),
			"name" = region.name,
			"x" = region.bottom_left.x,
			"y" = region.bottom_left.y,
			"z" = region.bottom_left.z,
			"width" = region.width,
			"height" = region.height,
		))
	. = list("regions" = region_data)

/datum/region_allocator_panel/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	USR_ADMIN_ONLY
	switch (action)
		if ("customRegion")
			var/x = tgui_input_number(ui.user, "Enter the width", "Custom Region", 1, world.maxx - 2, 1)
			if (!x) return
			var/y = tgui_input_number(ui.user, "Enter the height", "Custom Region", 1, world.maxy - 2, 1)
			if (!y) return
			var/datum/allocated_region/region = region_allocator.allocate(x + 2, y + 2)
			if (!region) return
			region.clean_up()
			LAZYLISTADD(region_allocator.custom_admin_regions, region)
			. = TRUE
		if ("loadPrefab")
			var/prefab_type = tgui_input_list(ui.user, "Select a prefab type", "Load Prefab", concrete_typesof(/datum/mapPrefab))
			if (!prefab_type) return
			var/datum/mapPrefab/mapPrefab = get_singleton(prefab_type)
			var/datum/allocated_region/region = region_allocator.allocate(mapPrefab.prefabSizeX + 2, mapPrefab.prefabSizeY + 2, mapPrefab.name)
			if (!region) return
			region.clean_up()
			LAZYLISTADD(region_allocator.custom_admin_regions, region)
			mapPrefab.applyTo(locate(region.bottom_left.x + 1, region.bottom_left.y + 1, region.bottom_left.z))
			. = TRUE
		if ("loadFile")
			var/map_file = input(ui.user, "Select a map to load. Only TGM formatted map files are supported.", "Load File", null) as null|file
			var/map_data = file2text(map_file)
			if (!map_data) return
			var/x = get_tgm_maxx(map_data)
			var/y = get_tgm_maxy(map_data)
			if (!x || !y) return
			if ((x + 2) > world.maxx || (y + 2) > world.maxy) return
			var/datum/allocated_region/region = region_allocator.allocate(x + 2, y + 2, stringify_file_name(map_file, TRUE))
			if (!region) return
			region.clean_up()
			LAZYLISTADD(region_allocator.custom_admin_regions, region)
			var/dmm_suite/D = new/dmm_suite(debug_id = "region allocator panel - [ui.user.ckey]")
			D.read_map(map_data, region.bottom_left.x + 1, region.bottom_left.y + 1, region.bottom_left.z, flags = DMM_OVERWRITE_OBJS | DMM_OVERWRITE_MOBS | DMM_BESPOKE_AREAS)
			. = TRUE
		if ("removeRegion")
			var/datum/weakref/region_ref = locate(params["ref"]) in region_allocator.allocated_regions
			if (!region_ref)
				stack_trace("Region allocator panel failed to find ref [params["ref"]] in the list of allocated regions")
				return
			region_allocator.custom_admin_regions -= region_ref.deref()
			qdel(region_ref.deref())
			. = TRUE
		if ("gotoRegion")
			var/datum/weakref/region_ref = locate(params["ref"]) in region_allocator.allocated_regions
			if (!region_ref)
				stack_trace("Region allocator panel failed to find ref [params["ref"]] in the list of allocated regions")
				return
			var/datum/allocated_region/region = region_ref.deref()
			if (!region) return
			ui.user.set_loc(region.bottom_left)
		if ("gotoRegionCenter")
			var/datum/weakref/region_ref = locate(params["ref"]) in region_allocator.allocated_regions
			if (!region_ref)
				stack_trace("Region allocator panel failed to find ref [params["ref"]] in the list of allocated regions")
				return
			var/datum/allocated_region/region = region_ref.deref()
			if (!region) return
			ui.user.set_loc(region.get_center())

