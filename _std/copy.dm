
#define _SEMI_DEEP_COPY(x) ((isnum(x) || istext(x) || isnull(x) || isclient(x) || isicon(x) || isfile(x) || ispath(x)) ? (x) : semi_deep_copy(x, environment=environment, root=root))
#define SEMI_DEEP_COPY(x) ((isnum(x) || istext(x) || isnull(x) || isclient(x) || isicon(x) || isfile(x) || ispath(x)) ? (x) : semi_deep_copy(x))

proc/semi_deep_copy(orig, new_arg=null, list/environment=null, root=null)
	if(isnum(orig) || istext(orig) || isnull(orig) || isclient(orig) || isicon(orig) || isfile(orig) || ispath(orig) || \
			istype(orig, /datum/chemical_reaction))
		return orig
	if(isnull(environment))
		root = orig
		environment = list()
	if(orig in environment)
		return environment[orig]
	if(islist(orig))
		. = list()
		environment[orig] = .
		for(var/key in orig)
			var/new_key = _SEMI_DEEP_COPY(key)
			if(islist(new_key)) // += operator concatenates lists actually :///
				new_key = list(new_key)
			. += new_key
			if(!isnum(key) && !isnull(orig[key]))
				.[key] = _SEMI_DEEP_COPY(orig[key])
		return
	if(istype(orig, /atom) && !isarea(orig))
		var/atom/A = orig
		while(!isarea(A) && !isnull(A) && A != root)
			A = A.loc
		if(isarea(A)) // if the object is somewhere else in the world
			return orig // don't copy
	if(!istype(orig, /datum))
		return orig
	var/datum/orig_datum = orig
	var/type = orig_datum.type
	var/datum/result
	if(!isnull(new_arg))
		result = new type(new_arg)
	else if(istype(orig_datum, /atom))
		var/atom/orig_atom = orig
		result = new type(_SEMI_DEEP_COPY(orig_atom.loc))
	else if(istype(orig_datum, /datum/component))
		var/datum/component/orig_component = orig
		result = new type(list(orig_component.parent))
	else
		result = new type
	environment[orig_datum] = result
	if(istype(result, /atom))
		var/atom/orig_atom = orig
		var/atom/result_atom = result
		for(var/atom/A in orig_atom)
			semi_deep_copy(A, result, environment, root)
		if(!isarea(result))
			for(var/A in orig_atom:vis_contents)
				result_atom:vis_contents += semi_deep_copy(A, null, environment, root)
		result_atom.appearance = orig_atom.appearance
	if(istype(result, /image))
		var/image/orig_image = orig
		var/image/result_image = result
		for(var/A in orig_image.vis_contents)
			result_image.vis_contents += semi_deep_copy(A, null, environment, root)
		result_image.appearance = orig_image.appearance
	var/list/var_blacklist = list("vars", "contents", "overlays", "underlays", "locs", "type", "parent_type", "vis_contents", "vis_locs", "appearance")
	var/list/mob_var_blacklist = list("ckey", "client", "key")
	for(var/var_name in orig_datum.vars)
		if(!issaved(orig_datum.vars[var_name]) || (var_name in var_blacklist) || ismob(result) && (var_name in mob_var_blacklist))
			continue
		if(var_name == "filters") // idk if this works
			result.vars[var_name] = orig_datum.vars[var_name]
			continue
		result.vars[var_name] = _SEMI_DEEP_COPY(orig_datum.vars[var_name])
		if(var_name == "overlay_refs" && length(result.vars[var_name]))
			var/atom/result_atom = result
			result_atom.overlays = null
			var/list/overlays = list()
			overlays.len = result_atom.overlay_refs.len
			for(var/key in result_atom.overlay_refs)
				var/list/overlay_ref = result_atom.overlay_refs[key]
				var/image/I = overlay_ref[2]
				if(overlay_ref[1] != 0 && overlay_ref[3] != 0 && istype(I, /image)) // someone was putting lists into overlays, wtf
					overlays[overlay_ref[1]] = I
				overlay_ref[3] = overlay_ref[3] == 0 ? 0 : "\ref[I.appearance]"
			result_atom.overlays = overlays
	return result

#undef _SEMI_DEEP_COPY
