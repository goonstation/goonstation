
/datum/validation/constrait
	proc/Validate(/datum/validation/item/item)
		. = TRUE

	string

		min_length
			var/min_length

			New(min_length)
				..()
				src.min_length = min_length

			Validate(/datum/validation/item/item)
				if (length(item.value) < src.min_length)
					return new /datum/validation/error("[item.name] is shorter than [src.min_length] characters")

		max_length
			var/max_length

			New(max_length)
				..()
				src.max_length = max_length

			Validate(/datum/validation/item/item)
				if (length(item.value) > src.max_length)
					return new /datum/validation/error("[item.name] is longer than [src.max_length] characters")
