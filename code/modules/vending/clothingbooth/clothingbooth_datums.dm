/// Global list of `clothingbooth_grouping`s to display on the clothing booth's catalogue.
var/list/datum/clothingbooth_grouping/clothingbooth_catalogue = list()
var/list/serialized_clothingbooth_catalogue = list()

/// Executed at runtime to generate the catalogue of `clothingbooth_grouping`s for the clothing booth.
/proc/build_clothingbooth_caches()
	var/list/datum/clothingbooth_grouping/groupings_buffer = list()
	for (var/clothingbooth_grouping_type in concrete_typesof(/datum/clothingbooth_grouping))
		var/datum/clothingbooth_grouping/current_grouping = new clothingbooth_grouping_type
		groupings_buffer[current_grouping.name] = current_grouping
	global.clothingbooth_catalogue = groupings_buffer
	// build serialized list, to avoid regenerating nested structures
	for (var/grouping_name as anything in global.clothingbooth_catalogue)
		var/datum/clothingbooth_grouping/grouping = global.clothingbooth_catalogue[grouping_name]
		var/list/serialized_items = list()
		for (var/item_name as anything in grouping.clothingbooth_items)
			var/datum/clothingbooth_item/item = grouping.clothingbooth_items[item_name]
			serialized_items[item.name] = list(
				"name" = item.name,
				"cost" = item.cost,
				"swatch_background_colour" = item.swatch_background_colour
			)
		var/list/serialized_grouping = list(
			"name" = grouping.name,
			"slot" = grouping.slot,
			"list_icon" = grouping.list_icon,
			"cost_min" = grouping.cost_min,
			"cost_max" = grouping.cost_max,
			"clothingbooth_items" = serialized_items
		)
		serialized_clothingbooth_catalogue[grouping.name] = serialized_grouping

ABSTRACT_TYPE(/datum/clothingbooth_item)
/**
 * 	# `clothingbooth_item` datum
 *
 * 	A purchaseable item from the clothing booth. The items themselves are not displayed on the
 */
/datum/clothingbooth_item
	/**	The name of the item as shown on swatch tooltips. If not overridden, this is generated at runtime. Generally only consider overriding when
		dealing with groupings of a length greater than one.*/
	var/name = null
	/** As per `clothing.dm`. The preview will try to equip this item in the provided slot, so it should match up! */
	var/slot = SLOT_W_UNIFORM
	/** Cost of the given item in credits. Can vary across several members in a `clothingbooth_grouping`. */
	var/cost = 1
	/** The type path of the actual item that is for purchase. */
	var/item_path = /obj/item/clothing/under/color/white

	/** Hex representation of the swatch's primary swatch colour. This must be manually overridden by all items if you don't want the hideous
	  	placeholder. */
	var/swatch_background_colour = "#ff00ff"
	/** The name of the foreground shape to use, as per some list of CSS classes that I have yet to define. Only necessary if differentiating between
		items within a parent `clothingbooth_grouping` cannot be done with background colours alone. */
	var/swatch_foreground_shape = null
	/** This will be the colour of the `swatch_foreground_shape` specified. Manually override if a `swatch_foreground_shape` is defined. */
	var/swatch_foreground_colour = "#000000"

	New()
		..()
		var/obj/item/clothing/item = new src.item_path
		if (!src.name)
			var/list/name_buffer = list()
			var/list/split_name = splittext(initial(item.name), " ")
			for (var/i in 1 to length(split_name))
				name_buffer += capitalize(split_name[i]) // TODO: do front-end
			src.name = jointext(name_buffer, " ")
		src.cost = round(src.cost)

ABSTRACT_TYPE(/datum/clothingbooth_grouping)
/**
 *	## `clothingbooth_grouping` datum
 *
 * 	A `clothingbooth_grouping` is a group of `clothingbooth_item`s which are collated together through commonality in form, slot, or other attributes
 * 	where possible. These are displayed on the list of purchaseable items on the catalogue of the clothing booth.
 */
/datum/clothingbooth_grouping
	/** For singlet `clothingbooth_grouping`s, this should not be overridden. */
	var/name = null
	/** As per `clothing.dm`. Used for filtering groupings by slot, generated at runtime. Do not override. */
	var/slot = null
	/** Base64 representation of the `clothingbooth_grouping` to display on the catalogue. Generated at runtime from the first member of the
		grouping. */
	var/list_icon = null
	/** Lowest cost value of the `clothingbooth_item`s in this grouping. */
	var/cost_min = null
	/** Highest cost value of the `clothingbooth_item`s in this grouping. */
	var/cost_max = null
	/** The list of `clothingbooth_item` types that populate this grouping. Will be displayed in the order that you manually write these! */
	var/list/clothingbooth_item_type_paths = list()
	/** List of `clothingbooth_item` datums, generated at runtime. Do not override. */
	var/list/datum/clothingbooth_item/clothingbooth_items = list()
	var/list/datum/clothingbooth_grouping_tag/clothingbooth_grouping_tags = list()

	New()
		..()
		// Scream if any of these vars are overridden.
		var/overridden_var = null
		if (src.list_icon)
			overridden_var = "list_icon"
		if (src.cost_min)
			overridden_var = "cost_min"
		if (src.cost_max)
			overridden_var = "cost_max"
		if (length(src.clothingbooth_items))
			overridden_var = "clothingbooth_items"
		if (overridden_var)
			CRASH("[src.name]'s [overridden_var] var has been overridden by something, this shouldn't happen!")

		// Instantiate all the constituent `clothingbooth_item` types in `src.clothingbooth_item_type_paths`, append them to `src.clothingbooth_items`
		var/last_item_slot // For checking if all the slots are the same.
		for (var/clothingbooth_item_type in src.clothingbooth_item_type_paths)
			var/datum/clothingbooth_item/current_item = new clothingbooth_item_type
			// Concrete types only.
			if (IS_ABSTRACT(current_item))
				continue
			// Scream if something goes wrong.
			if (src.clothingbooth_items[current_item.name])
				CRASH("A clothingbooth_item with name [current_item.name] already exists within this grouping ([src.name])!")
			if (current_item.slot != last_item_slot && last_item_slot)
				CRASH("A clothingbooth_item with name [current_item.name] has a different slot defined than expected for this grouping ([src.name])!")
			last_item_slot = current_item.slot
			src.clothingbooth_items[current_item.name] = current_item
		// Not needed after instantiation
		src.clothingbooth_item_type_paths = null

		// Iterate over constituent `clothingbooth_item`s.
		for (var/current_item_index in src.clothingbooth_items)
			var/datum/clothingbooth_item/current_member = src.clothingbooth_items[current_item_index]
			// Determine maximum and minimum costs.
			var/current_item_cost = current_member.cost
			if (!src.cost_min || (current_item_cost < src.cost_min))
				src.cost_min = current_item_cost
			if (!src.cost_max || (current_item_cost > src.cost_max))
				src.cost_max = current_item_cost

		// Generate `src.list_icon` for display on the catalogue.
		var/datum/clothingbooth_item/first_clothingbooth_item = src.clothingbooth_items[src.clothingbooth_items[1]]
		var/list_icon_atom_path = first_clothingbooth_item?.item_path ? first_clothingbooth_item.item_path : /obj/item/clothing/under/color/white
		var/obj/item/dummy_atom = list_icon_atom_path
		var/icon/dummy_icon = icon(initial(dummy_atom.icon), initial(dummy_atom.icon_state), frame = 1)
		src.list_icon = icon2base64(dummy_icon)

		// If no name override for the group is specified, take it from the first item in the grouping.
		if (!src.name)
			src.name = first_clothingbooth_item.name
		src.slot = first_clothingbooth_item.slot

// i'll deal with you later you're not important
/**
 * 	# `clothingbooth_item_tag` datum
 */
ABSTRACT_TYPE(/datum/clothingbooth_grouping_tag)
/datum/clothingbooth_grouping_tag
	var/name = null
	var/colour = null
