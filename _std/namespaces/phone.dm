CREATE_NAMESPACE(PHONE)

/// All phones should always be listed here, regardless of if they're able to be called or not
/// Most of the values here do not need to be stored locally, as they're accessed from the directory
ADD_TO_NAMESPACE(PHONE)(var/list/directory = list())
/* Structure. Order irrelevant.
phone_id = list(
	PHONE_PARENT = ref,
	PHONE_UNLISTED = bool,
	PHONE_CAN_Z = bool,
	PHONE_CATEGORY = string,
	PHONE_COLOR = color (hex),
	PHONE_NETWORKS = bitfield)
*/

ADD_TO_NAMESPACE(PHONE)(var/list/template = list(
	PHONE_PARENT = null,
	PHONE_UNLISTED = null,
	PHONE_CAN_Z = null,
	PHONE_CATEGORY = null,
	PHONE_COLOR = null,
	PHONE_NETWORKS = null,
	PHONE_Z_LEVEL = null))

/// Returns one of the named variables all phones should have
/// Target may be either a ref or a phone_id
/// You could also just index PHONE.directory if you want, but this is a little cleaner
ADD_TO_NAMESPACE(PHONE)(proc/get_var(var/target, var/var2get))
	if(istype(target, /datum))
		var/list/return_list = list()
		var/datum/datum_target = target
		SEND_SIGNAL(datum_target, COMSIG_PHONE_GET_NAME, return_list)
		target = return_list[PHONE_NAME]
		if(isnull(target))
			return // we probably got called on something that's not a phone
	if(var2get == PHONE_NAME)
		return target
	return PHONE.directory[target][var2get]

/// Sets the specified value for a given phone in PHONE.directory
ADD_TO_NAMESPACE(PHONE)(proc/set_var(var/target, var/var2set, var/new_value, var/suppress_updates = FALSE))
	var/datum/datum_target = null
	if(istype(target, /datum))
		var/list/return_list = list()
		datum_target = target
		SEND_SIGNAL(datum_target, COMSIG_PHONE_GET_NAME, return_list)
		target = return_list[PHONE_NAME]
		if(isnull(target))
			return // we probably got called on something that's not a phone
	if(!(target in PHONE.directory))
		PHONE.directory[target] = PHONE.template.Copy()
	PHONE.directory[target][var2set] = new_value
	if(suppress_updates)
		return
	if(!datum_target)
		datum_target = PHONE.get_var(target, PHONE_PARENT)
	else
		target = PHONE.get_var(datum_target, PHONE_NAME)
	SEND_SIGNAL(datum_target, COMSIG_PHONE_INFO_UPDATED, target)

ADD_TO_NAMESPACE(PHONE)(proc/z_check(var/phone_1, var/phone_2))
	. = FALSE
	if(!istype(phone_1, /datum))
		phone_1 = PHONE.directory[phone_1][PHONE_PARENT]
	var/datum/datum_phone_1 = phone_1
	if(!istype(phone_2, /datum))
		phone_2 = PHONE.directory[phone_2][PHONE_PARENT]
	var/datum/datum_phone_2 = phone_2

	if(PHONE.get_var(datum_phone_1, PHONE_CAN_Z) && PHONE.get_var(datum_phone_2, PHONE_CAN_Z))
		return TRUE

	var/z1 = PHONE.get_var(datum_phone_1, PHONE_Z_LEVEL)
	var/z2 = PHONE.get_var(datum_phone_2, PHONE_Z_LEVEL)

	if((z1 == z2) || (z1 == 0) || (z2 == 0))
		return TRUE

/// Returns a valid unique phone name/id, optionally auto-generated if name is left null
/// Controller components always use this when setting their name with set_var()
ADD_TO_NAMESPACE(PHONE)(proc/name_handler(var/datum/controller_parent, var/name))
	// Generate a name for the phone.
	var/temp_name = "phone"
	if (isnull(name))
		if(isatom(controller_parent))
			var/atom/parent_atom = controller_parent
			temp_name = parent_atom.name
			var/area/location = get_area(parent_atom)
			if ((temp_name == parent_atom::name) && location)
				temp_name = location.name
		name = temp_name
	temp_name = name // gonna reuse this variable in a sec
	var/safe_name_found = FALSE
	var/name_counter = 1
	var/match_found = FALSE
	while (!safe_name_found)
		match_found = FALSE
		for (var/phone_id in PHONE.directory)
			if (phone_id == temp_name)
				match_found = TRUE
				temp_name = name + " [name_counter]"
				name_counter++
				break
		if(!match_found)
			safe_name_found = TRUE
			name = temp_name
	return name

