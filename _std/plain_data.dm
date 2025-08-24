/**
 * Data type for storing just data, without any procs or other fanciness. Meant to be used instead of deeply nested lists for e.g. TGUI ui_data.
 *
 * Subtype this type and declare vars on the subtype. By contract all vars on the subtype must be either plain_data or a list or some primitive type
 * (number, text, null).
 */
/plain_data

#define _PROCESS_VALUE(value, where_error) \
	if(istype(value, /plain_data)) { \
		var/plain_data/value_plain_data = value; \
		value = value_plain_data.to_list(); \
	} else if(islist(value)) { \
		value = normalize_plain_data_list(value); \
	} else if(!isnum(value) && !istext(value) && !isnull(value)) { \
		CRASH("Unsupported non-trivial value '[value]' in [where_error]"); \
	}

/**
 * Returns a list with all the data in this plain_data. The list is normalized, i.e. all plain_data values are converted to lists, recursively.
 */
/plain_data/proc/to_list()
	RETURN_TYPE(/list)
	. = list()
	// turns out we are still a subtyle of /datum despite the path
	var/static/list/var_blacklist = list("tag", "tgui_shared_states", "datum_components", "comp_lookup", "weakref", "disposed", "qdeled", "signal_procs")
	for(var/var_name in src.vars)
		if(!issaved(src.vars[var_name]) || (var_name in var_blacklist))
			continue
		var/value = src.vars[var_name]
		_PROCESS_VALUE(value, "[src.type]")
		.[var_name] = value

/**
 * Recursively normalizes a list of plain_data and primitive values. Plain_data values are converted to lists, recursively.
 */
proc/normalize_plain_data_list(list/L, plain_data/parent_data=null)
	. = list()
	for(var/key in L)
		if(isnum(key))
			. += key
			continue
		var/value = L[key]
		var/is_associated = !isnull(value)
		if(is_associated)
			if(isnull(key))
				CRASH("Null key in a list in [parent_data?.type || "???"]. This would get json-serialized to string \"null\" which is likely not what you wanted.")
			if(!istext(key))
				CRASH("Non-text key in a list in [parent_data?.type || "???"].")
			_PROCESS_VALUE(value, " an associated value of a list in [parent_data?.type || "???"]")
			.[key] = value
		else
			_PROCESS_VALUE(key, " a non-associated value of a list in [parent_data?.type || "???"]")
			if(islist(key))
				. += list(key)
			else
				. += key

#undef _PROCESS_VALUE

/**
 * Returns a json string with all the data in this plain_data.
 */
/plain_data/proc/to_json()
	. = json_encode(src.to_list())

