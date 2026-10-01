/datum/record_field/number
	VAR_PROTECTED/lower = null
	VAR_PROTECTED/upper = null

/datum/record_field/number/New(name, value, lower, upper)
	if (isnum(lower))
		src.lower = lower
	if (isnum(upper))
		src.upper = upper

	. = ..()

/datum/record_field/number/validate(value)
	if (!isnum(value))
		return "Value \[[value]\] is not a number."

	if (!isnull(src.lower) && (value < src.lower))
		return "Value \[[value]\] less than lower bound \[[src.lower]\]."

	if (!isnull(src.upper) && (value > src.upper))
		return "Value \[[value]\] greater than upper bound \[[src.upper]\]."

/datum/record_field/number/input_load(datum/db_manager_menu/field_input/menu)
	var/has_lower = !isnull(src.lower) && (src.lower != -INFINITY)
	var/has_upper = !isnull(src.upper) && (src.upper != INFINITY)

	var/text = ""
	if (has_lower && has_upper)
		text = "Please enter a new value between [src.lower] and [src.upper]:"
	else if (has_lower)
		text = "Please enter a new value greater than or equal to [src.lower]:"
	else if (has_upper)
		text = "Please enter a new value less than or equal to [src.lower]:"
	else
		text = "Please enter a new value:"

	menu.parent.print_text(text)

/datum/record_field/number/input_text(datum/db_manager_menu/field_input/menu, text)
	var/command = global.text2num_safe(menu.parent.parse_string(text)[1])
	var/error = src.validate(command)
	if (istext(error))
		menu.parent.print_text("<b>Error:</b> [error]")
		return

	src.set_value(command)
	return TRUE
