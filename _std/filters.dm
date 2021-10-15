
/**
* @file
* @copyright 2020
* @author actioninja  (https://github.com/actioninja )
* @license MIT
*/

/atom/var/list/list/filter_data

/atom/proc/add_filter(name, priority, list/filter_params)
	LAZYLISTINIT(src.filter_data)
	filter_params["priority"] = priority
	src.filter_data[name] = filter_params
	update_filters()

/atom/proc/transition_filter(name, time, list/new_params, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return

	var/list/old_filter_data = filter_data[name]

	var/list/params = old_filter_data.Copy()
	for(var/thing in new_params)
		params[thing] = new_params[thing]

	animate(filter, new_params, time = time, easing = easing, loop = loop)
	for(var/param in params)
		filter_data[name][param] = params[param]

/atom/proc/remove_filter(name_or_names)
	if(!filter_data)
		return

	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/atom/proc/get_filter(name)
	if(filter_data && filter_data[name])
		var/i = filter_data.Find(name)
		. = filters[i]

/atom/proc/update_filters()
	filters = null
	//need to reorder based on priority
	for(var/i = 1; i <= length(filter_data); i++)
		for(var/j = i+1; j <= length(filter_data); j++)
			if(filter_data[filter_data[i]]["priority"] > filter_data[filter_data[j]]["priority"])
				filter_data.Swap(i, j)
	for(var/filter in filter_data)
		var/list/params = filter_data[filter].Copy()
		//Ommit priority as that is just used for ordering filters for desired effect
		params -= "priority"
		filters += filter(arglist(params))
	return

/atom/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return

	filter_data[name]["priority"] = new_priority
	update_filters()

/atom/proc/clear_filters()
	filter_data = null
	filters = null
