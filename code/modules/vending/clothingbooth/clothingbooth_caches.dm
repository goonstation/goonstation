/// A verbose list containing every single parent item and its variants and detail types.
var/list/datum/clothingbooth_item/clothingbooth_stock_list = list()
/// Condensed information on the essential information concerning a given parent item.
var/list/list/clothingbooth_stock_ui_data = list()

/// Executed at runtime to generate the global lists `clothingbooth_stock_list` and `clothingbooth_stock_information`.
/proc/build_clothingbooth_caches()
	// Generate the verbose list of all the `clothingbooth_item` types, indexed by the name of the item datum
	var/list/datum/clothingbooth_item/items_buffer = list()
	for (var/clothingbooth_list_type in concrete_typesof(/datum/clothingbooth_item))
		var/datum/clothingbooth_item/current_item = new clothingbooth_list_type
		if (items_buffer[current_item.name])
			// TODO: complain
			continue
		items_buffer[current_item.name] += current_item
	global.clothingbooth_stock_list = items_buffer

	var/list/datum/clothingbooth_grouping/groupings_buffer = list()
	for (var/clothingbooth_grouping_type in concrete_typesof(/datum/clothingbooth_grouping))
		var/datum/clothingbooth_grouping/current_grouping = new clothingbooth_grouping_type
		groupings_buffer += current_grouping

	// Generate static UI data with associated nesting and derived data, to avoid regenerating
	var/list/list/ui_data_buffer = list()
	for (var/datum/clothingbooth_grouping/current_grouping as anything in groupings_buffer)
		if (isnull(current_grouping))
			// TODO: scream
			continue
		var/current_cost_min
		var/current_cost_max
		var/list/current_members = list()
		for (var/member_item_id in current_grouping.member_item_ids)
			var/datum/clothingbooth_item/current_member = global.clothingbooth_stock_list[member_item_id]
			if (isnull(current_member))
				// TODO: scream
				continue;
			var/current_variant_cost = current_member.cost
			if (!current_cost_min || (current_variant_cost < current_cost_min))
				current_cost_min = current_variant_cost
			if (!current_cost_max || (current_variant_cost > current_cost_max))
				current_cost_max = current_variant_cost
			current_members[member_item_id] = list(
				"item_id" = member_item_id,
				"name" = current_member.name
			)

		// Get an image for the group entry.
		// Current implementation: use first member item
		if (length(current_grouping.member_item_ids) == 0)
			// TODO: scream
			continue
		var/first_member_id = current_grouping.member_item_ids[1]
		var/datum/clothingbooth_item/icon_member = global.clothingbooth_stock_list[first_member_id]
		if (isnull(icon_member))
			// TODO: scream
			continue
		var/current_entry_atom_path = /obj/item/clothing/under/color/white
		var/obj/item/dummy_atom = current_entry_atom_path
		var/icon/dummy_icon = icon(initial(dummy_atom.icon), initial(dummy_atom.icon_state), frame = 1)
		var/current_group_image = icon2base64(dummy_icon)

		ui_data_buffer[current_grouping.name] = list(
			"costRange" = current_cost_min == current_cost_max ? current_cost_min : list(current_cost_min, current_cost_max),
			"icon64" = current_group_image, // TODO
			"id" = current_grouping.name,
			"lowerName" = lowertext(current_grouping.name),
			"members" = current_members,
			"name" = current_grouping.name,
			"slot" = current_grouping.slot,
		)

	global.clothingbooth_stock_ui_data = list(
		"itemLookups" = ui_data_buffer,
		"itemGroupings" = groupings_buffer
	)
