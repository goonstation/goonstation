/datum/validation_item
	var/name
	var/list/datum/validation_constraint/constraints
	var/value

	var/validated = FALSE
	var/has_errors = FALSE
	var/list/datum/validation_error/errors = list()

	New(var/name, var/list/datum/validation_constraint/constraints)
		..()
		src.name = name
		src.constraints = constraints

	proc/set_value(value)
		if (src.value != value)
			src.value = value
			src.validated = FALSE

		. = src.validated

	proc/validate()
		src.errors = list()

		for (var/datum/validation_constraint/constraint as anything in src.constraints)
			var/result = constraint.validate(src)
			if (istype(result, /datum/validation_error))
				src.errors.Add(result)

		if (length(src.errors) > 0)
			src.has_errors = TRUE

		src.validated = TRUE

		. = src.has_errors
