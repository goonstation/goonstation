/datum/validation_group
	var/list/datum/validation_item/items

	var/validated = FALSE
	var/has_errors = FALSE
	var/list/datum/validation_error/errors = list()

	proc/set_value(var/key, var/value)
		var/datum/validation_item/item = src.items[key]

		var/validated = item?.set_value(value)
		src.validated = validated && src.validated ? TRUE : FALSE

		. = src.validated

	proc/set_values(var/list/values)
		for(var/key in values)
			src.set_value(key, values[key])

	proc/validate()
		src.errors = list()

		for(var/key in src.items)
			var/datum/validation_item/item = src.items[key]
			if (item.validated && item.has_errors == FALSE)
				// Skip the validation step if nothing has changed
				continue

			item.validate()

		for(var/key in src.items)
			var/datum/validation_item/item = src.items[key]
			for (var/datum/validation_error/E in item.errors)
				E.key = key
			src.errors += item.errors

		if (length(src.errors) > 0)
			src.has_errors = TRUE

		. = src.has_errors
