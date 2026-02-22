/*
	If you are looking to add more items/groupings to the booth, please see `./clothingbooth.md` for a guide.
*/

/// Global list of `clothingbooth_grouping` datums, generated at runtime.
var/list/datum/clothingbooth_grouping/clothingbooth_catalogue = list()
/// Serialized version of `global.clothingbooth_catalogue` for sending to the clothingbooth's interface.
var/list/serialized_clothingbooth_catalogue = list()
/// Serialized list of used `clothingbooth_tag`s for sending to the clothingbooth's interface.
var/list/serialized_clothingbooth_tags = list()

/// Executed at runtime to generate the catalogue of `clothingbooth_grouping`s for the clothing booth.
/proc/build_clothingbooth_caches()
	// Generate the global `clothingbooth_grouping` datum list.
	var/list/datum/clothingbooth_grouping/groupings_buffer = list()
	for (var/clothingbooth_grouping_type in concrete_typesof(/datum/clothingbooth_grouping))
		var/datum/clothingbooth_grouping/current_grouping = new clothingbooth_grouping_type
		groupings_buffer[current_grouping.name] = current_grouping
	if (!length(groupings_buffer))
		CRASH("Tried to generate the global clothing booth catalogue, but the resulting output is empty!")
	global.clothingbooth_catalogue = groupings_buffer

	// Build serialized list, to avoid regenerating nested structures.
	var/list/serialized_catalogue_buffer = list()
	var/list/serialized_clothingbooth_tags_buffer = list()
	for (var/grouping_name as anything in global.clothingbooth_catalogue)
		var/datum/clothingbooth_grouping/grouping = global.clothingbooth_catalogue[grouping_name]
		// Serialize the items in each grouping.
		var/list/serialized_items = list()
		for (var/item_name as anything in grouping.clothingbooth_items)
			var/datum/clothingbooth_item/item = grouping.clothingbooth_items[item_name]
			serialized_items[item.name] = list(
				"name" = item.name,
				"cost" = item.cost,
				"swatch_background_color" = item.swatch_background_color,
				"swatch_foreground_color" = item.swatch_foreground_color,
				"swatch_foreground_shape" = item.swatch_foreground_shape,
			)

		// Serialize the tags in each grouping and send unique tags to the global list.
		var/list/serialized_grouping_tags = list()
		for (var/grouping_tag_name as anything in grouping.clothingbooth_grouping_tags)
			var/datum/clothingbooth_grouping_tag/grouping_tag = grouping.clothingbooth_grouping_tags[grouping_tag_name]
			serialized_grouping_tags += grouping_tag.name
			var/tag_match_found = FALSE
			for (var/serialized_clothingbooth_tag in serialized_clothingbooth_tags_buffer)
				if (serialized_clothingbooth_tag == grouping_tag.name)
					tag_match_found = TRUE
			if (!tag_match_found)
				serialized_clothingbooth_tags_buffer[grouping_tag.name] = list(
					"name" = grouping_tag.name,
					"color" = grouping_tag.color,
					"display_order" = grouping_tag.display_order,
				)
		var/list/serialized_grouping = list(
			"name" = grouping.name,
			"slot" = grouping.slot,
			"list_icon" = grouping.list_icon,
			"cost_min" = grouping.cost_min,
			"cost_max" = grouping.cost_max,
			"clothingbooth_items" = serialized_items,
			"grouping_tags" = serialized_grouping_tags,
		)
		serialized_catalogue_buffer[grouping.name] = serialized_grouping

	if (!length(serialized_catalogue_buffer))
		CRASH("Tried to serialize the global clothing booth catalogue, but the resulting output is empty!")
	if (!length(serialized_clothingbooth_tags_buffer))
		CRASH("Tried to serialize the global clothing booth tags list, but the resulting output is empty!")
	global.serialized_clothingbooth_catalogue = serialized_catalogue_buffer
	global.serialized_clothingbooth_tags = serialized_clothingbooth_tags_buffer

ABSTRACT_TYPE(/datum/clothingbooth_grouping)
/**
 *	## `clothingbooth_grouping` datum
 *
 * 	A `clothingbooth_grouping` is a group of `clothingbooth_item`s which are collated together through commonality in form, slot, or other attributes
 * 	where possible. These are displayed on the list of purchaseable items on the catalogue of the clothing booth.
 */
/datum/clothingbooth_grouping
	/// For singlet `clothingbooth_grouping`s, this should not be manually overridden.
	var/name = null
	/// As per `clothing.dm`. Used for filtering groupings by slot, generated at runtime. Do not manually override.
	var/slot = null
	/// Base64 representation of the `clothingbooth_grouping` to display on the catalogue. Generated at runtime from the first member of the
	/// grouping.
	var/list_icon = null
	/// Lowest cost value of the `clothingbooth_item`s in this grouping. Do not manually override.
	var/cost_min = null
	/// Highest cost value of the `clothingbooth_item`s in this grouping. Do not manually override.
	var/cost_max = null
	/// The list of `clothingbooth_item` types that populate this grouping. Will be displayed in the order that you manually write these!
	var/list/item_paths = list()
	/// The list of `clothingbooth_grouping_tag` types assigned to this grouping for additional categorisation. Can be of an arbitrary length.
	var/list/grouping_tags = list()
	/// List of `clothingbooth_item` datums, generated at runtime. Do not manually override.
	var/list/datum/clothingbooth_item/clothingbooth_items = list()
	/// List of `clothingbooth_grouping_tag` datums, generated at runtime. Do not manually override.
	var/list/datum/clothingbooth_grouping_tag/clothingbooth_grouping_tags = list()

/datum/clothingbooth_grouping/New()
	..()
	// Scream if any of these vars are overridden.
	if (src.list_icon || src.cost_min || src.cost_max || length(src.clothingbooth_items) || length(src.clothingbooth_grouping_tags))
		CRASH("A protected var in [src.name] has been overridden!")

	// Instantiate all the constituent `clothingbooth_item` types in `src.item_paths`, append them to `src.clothingbooth_items`
	var/last_item_slot // For checking if all the slots are the same.
	for (var/clothingbooth_item_type in src.item_paths)
		var/datum/clothingbooth_item/current_item = new clothingbooth_item_type
		// Concrete types only.
		if (IS_ABSTRACT(current_item))
			continue
		// Scream if something goes wrong.
		if (src.clothingbooth_items[current_item.name])
			CRASH("A clothingbooth_item with name [current_item.name] already exists within grouping [src.name]!")
		if (current_item.slot != last_item_slot && last_item_slot)
			CRASH("A clothingbooth_item with name [current_item.name] has a different slot defined than expected for grouping [src.name]!")
		last_item_slot = current_item.slot
		src.clothingbooth_items[current_item.name] = current_item
	for (var/clothingbooth_grouping_tag in src.grouping_tags)
		var/datum/clothingbooth_grouping_tag/current_tag = new clothingbooth_grouping_tag
		if (IS_ABSTRACT(current_tag))
			continue
		if (src.clothingbooth_grouping_tags[current_tag.name])
			CRASH("A clothingbooth_grouping_tag with name [current_tag.name] already exists within grouping [src.name]!")
		src.clothingbooth_grouping_tags[current_tag.name] = current_tag
	// Not needed after instantiation
	src.item_paths = null
	src.grouping_tags = null

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

ABSTRACT_TYPE(/datum/clothingbooth_item)
/**
 * 	# `clothingbooth_item` datum
 *
 * 	A purchaseable item from the clothing booth. These are the constituent parts of a broader `clothingbooth_grouping`, though such groupings may - as
 * 	part of the organisational scheme of the clothing booth - contain only one item.
 */
/datum/clothingbooth_item
	///	The name of the item as shown on swatch tooltips. If not overridden, this is generated at runtime. Generally only consider overriding when
	/// dealing with groupings of a length greater than one.
	var/name = null
	/// As per `clothing.dm`. The preview will try to equip this item in the provided slot, so it should match up!
	var/slot = SLOT_W_UNIFORM
	/// Cost of the given item in credits. Can vary across several members in a `clothingbooth_grouping`.
	var/cost = 1
	/// The type path of the actual item that is for purchase.
	var/item_path = /obj/item/clothing/under/color/white

	/// Hex representation of the swatch's primary swatch color. This must be manually overridden by all items if you don't want the hideous
	/// placeholder.
	var/swatch_background_color = "#ff00ff"
	/// This will be the color of the `swatch_foreground_shape` specified. Manually override if a `swatch_foreground_shape` is defined.
	var/swatch_foreground_color = "#000000"
	/// The name of the foreground shape to use, defined in `_std\defines\clothingbooth.dm`. Only necessary if differentiating between items within a
	/// parent `clothingbooth_grouping` cannot be done with background colors alone.
	var/swatch_foreground_shape = null

/datum/clothingbooth_item/New()
	..()
	var/obj/item/clothing/item = new src.item_path
	if (!src.name)
		var/list/name_buffer = list()
		var/list/split_name = splittext(initial(item.name), " ")
		for (var/i in 1 to length(split_name))
			name_buffer += capitalize(split_name[i])
		src.name = jointext(name_buffer, " ")
	src.cost = round(src.cost)

ABSTRACT_TYPE(/datum/clothingbooth_grouping_tag)
/**
 * 	# `clothingbooth_item_tag` datum
 *
 * 	Tags can be used to further sort `clothingbooth_grouping`s into more specific categorisations, such as by seasonality, formality, as a set that
 * 	is intended to be paired with items of another grouping, etc. An arbitrary number of these can be assigned to any given grouping to an extent that
 * 	is reasonable.
 */
/datum/clothingbooth_grouping_tag
	var/name = "Foo"
	var/color = null
	/// The higher the `display_order`, the lower the `clothingbooth_grouping_tag`s will be displayed (i.e., further right). Exists for the sake of
	///	a clear organizational hirearchy. Seasonal tags will be shown first, followed by formality, then set name, etc.
	var/display_order = 1
