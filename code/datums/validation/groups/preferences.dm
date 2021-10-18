/datum/validation_group/preferences
	items = list(
		"nameFirst" = new /datum/validation_item("first name", list(
			new /datum/validation_constraint/min_length(2),
			new /datum/validation_constraint/max_length(16),
		)),
		"nameMiddle" = new /datum/validation_item("middle name", list(
			new /datum/validation_constraint/min_length(2),
			new /datum/validation_constraint/max_length(16),
		)),
		"nameLast" = new /datum/validation_item("last name", list(
			new /datum/validation_constraint/min_length(2),
			new /datum/validation_constraint/max_length(16),
		))
	)
