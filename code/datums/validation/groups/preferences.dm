
// Preferences group:

/datum/validation/group/preferences
	items = list(
		"nameFirst" = new /datum/validation/item("first name", list(
			new /datum/validation/constrait/string/min_length(2),
			new /datum/validation/constrait/string/max_length(16),
		)),
		"nameMiddle" = new /datum/validation/item("middle name", list(
			new /datum/validation/constrait/string/min_length(2),
			new /datum/validation/constrait/string/max_length(16),
		)),
		"nameLast" = new /datum/validation/item("last name", list(
			new /datum/validation/constrait/string/min_length(2),
			new /datum/validation/constrait/string/max_length(16),
		))
	)
