/datum/validation/item
	var/name
	var/list/datum/validation/constrait/constraints
	var/value

	var/validated = FALSE
	var/has_errors = FALSE
	var/list/datum/validation/error/errors = list()

	New(var/name, var/list/datum/validation/constrait/constraints)
		..()
		src.name = name
		src.constraints = constraints

	proc/SetValue(value)
		if (src.value != value)
			src.value = value
			src.validated = FALSE

		. = src.validated

	proc/Validate()
		src.errors = list()

		for (var/datum/validation/constrait/constraint as anything in src.constraints)
			var/result = constraint.Validate(src)
			if (istype(result, /datum/validation/error))
				src.errors.Add(result)

		if (length(src.errors) > 0)
			src.has_errors = TRUE

		src.validated = TRUE

		. = src.has_errors
