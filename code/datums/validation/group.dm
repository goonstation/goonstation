/datum/validation/group
	var/list/datum/validation/item/items

	var/validated = FALSE
	var/has_errors = FALSE
	var/list/datum/validation/error/errors = list()

	proc/SetValue(key, value)
		var/datum/validation/item/item = src.items[key]

		var/validated = item?.SetValue(value)
		src.validated = validated && src.validated ? TRUE : FALSE

		. = src.validated

	proc/Validate()
		for(var/key in src.items)
			var/datum/validation/item/item = src.items[key]
			if (item.validated && item.has_errors == FALSE)
				// Skip the validation step if nothing has changed
				continue

			item.Validate()

		for(var/key in src.items)
			var/datum/validation/item/item = src.items[key]
			src.errors += item.errors


		if (length(src.errors) > 0)
			src.has_errors = TRUE

		. = src.has_errors
