/// makes a sorta deep copy of a thing
#define SEMI_DEEP_COPY(x) ((isnum(x) || istext(x) || isnull(x) || isclient(x) || isicon(x) || isfile(x) || ispath(x)) ? (x) : semi_deep_copy(x))

// copy flags
#define COPY_SKIP_EXPLOITABLE (1<<0)
#define COPY_SHALLOW (1<<1)
#define COPY_SHALLOW_EXCEPT_FOR_LISTS (1<<2)

#define _SEMI_DEEP_COPY(x) ((isnum(x) || istext(x) || isnull(x) || isclient(x) || isicon(x) || isfile(x) || ispath(x)) ? (x) : semi_deep_copy(x, environment=environment, root=root, copy_flags=copy_flags))

// debugging
#define COPY_DEBUG
#ifdef COPY_DEBUG
var/global/list/copy_stack
var/global/list/longest_copy_stack
#endif

proc/semi_deep_copy(orig, new_arg=null, list/environment=null, root=null, copy_flags=0)
	if(((copy_flags & COPY_SHALLOW) || (copy_flags & COPY_SHALLOW_EXCEPT_FOR_LISTS && !islist(orig))) && !isnull(root))
		return orig
	if(isnum(orig) || istext(orig) || isnull(orig) || isclient(orig) || isicon(orig) || isfile(orig) || ispath(orig) || \
			istype(orig, /datum/chemical_reaction) || istype(orig, /datum/radio_frequency) || istype(orig, /datum/client_image_group) || \
			istype(orig, /datum/packet_network))
		return orig
	if(copy_flags & COPY_SKIP_EXPLOITABLE && (
			istype(orig, /obj/item/uplink) || istype(orig, /obj/item/spacebux) || istype(orig, /obj/item/chem_hint) || istype(orig, /obj/item/pixel_pass)))
		return null
	if(isnull(environment))
		root = orig
		environment = list()
		#ifdef COPY_DEBUG
		global.copy_stack = list()
		#endif
	if(orig in environment)
		return environment[orig]
	if(islist(orig))
		. = list()
		environment[orig] = .
		for(var/key in orig)
			#ifdef COPY_DEBUG
			global.copy_stack += "index"
			if(length(global.copy_stack) >= length(global.longest_copy_stack)) global.longest_copy_stack = global.copy_stack.Copy()
			#endif
			var/new_key = _SEMI_DEEP_COPY(key)
			#ifdef COPY_DEBUG
			global.copy_stack.len--
			#endif
			if(islist(new_key)) // += operator concatenates lists actually :///
				new_key = list(new_key)
			. += new_key
			if(!isnum(key) && !isnull(orig[key]))
				#ifdef COPY_DEBUG
				global.copy_stack += "[key]"
				if(length(global.copy_stack) >= length(global.longest_copy_stack)) global.longest_copy_stack = global.copy_stack.Copy()
				#endif
				.[new_key] = _SEMI_DEEP_COPY(orig[key])
				#ifdef COPY_DEBUG
				global.copy_stack.len--
				#endif
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
		result = new type(list(_SEMI_DEEP_COPY(orig_component.parent)))
	else if(istype(orig_datum, /datum/hud) && hasvar(orig_datum, "master"))
		var/datum/hud/orig_hud = orig
		result = new type(_SEMI_DEEP_COPY(orig_hud:master))
	else if(istype(orig_datum, /datum) && hasvar(orig_datum, "holder"))
		result = new type(_SEMI_DEEP_COPY(orig:holder))
	else
		result = new type
	environment[orig_datum] = result
	if(istype(result, /atom))
		var/atom/orig_atom = orig
		var/atom/result_atom = result
		for(var/atom/A in result_atom)
			qdel(A)
		result_atom.contents.Cut()
		#ifdef COPY_DEBUG
		global.copy_stack += "contents"
		if(length(global.copy_stack) >= length(global.longest_copy_stack)) global.longest_copy_stack = global.copy_stack.Copy()
		#endif
		for(var/atom/A in orig_atom)
			semi_deep_copy(A, result, environment, root, copy_flags)
		#ifdef COPY_DEBUG
		global.copy_stack.len--
		#endif
		if(!isarea(result))
			result_atom:vis_contents = null
			for(var/A in orig_atom:vis_contents)
				result_atom:vis_contents += _SEMI_DEEP_COPY(A)
		result_atom.appearance = orig_atom.appearance
	if(istype(result, /image))
		var/image/orig_image = orig
		var/image/result_image = result
		for(var/A in orig_image.vis_contents)
			result_image.vis_contents += _SEMI_DEEP_COPY(A)
		result_image.appearance = orig_image.appearance
	var/list/var_blacklist = list("vars", "contents", "overlays", "underlays", "locs", "type", "parent_type", "vis_contents", "vis_locs", "appearance", "mind", "clients", "color", "alpha", "blend_mode", "appearance_flags")
	var/list/mob_var_blacklist = list("ckey", "client", "key")
	for(var/var_name in orig_datum.vars)
		if(!issaved(orig_datum.vars[var_name]) || (var_name in var_blacklist) || ismob(result) && (var_name in mob_var_blacklist) || length(var_name) >= 6 && copytext(var_name, 1, 7) == "global")
			continue
		if(var_name == "filters") // idk if this works
			result.vars[var_name] = orig_datum.vars[var_name]
			continue
		#ifdef COPY_DEBUG
		global.copy_stack += var_name
		if(length(global.copy_stack) >= length(global.longest_copy_stack)) global.longest_copy_stack = global.copy_stack.Copy()
		#endif
		result.vars[var_name] = _SEMI_DEEP_COPY(orig_datum.vars[var_name])
		#ifdef COPY_DEBUG
		global.copy_stack.len--
		#endif
		if(var_name == "overlay_refs" && length(result.vars[var_name]))
			var/atom/result_atom = result
			result_atom.overlays = null
			var/list/overlays = list()
			overlays.len = length(result_atom.overlay_refs)
			for(var/key in result_atom.overlay_refs)
				var/list/overlay_ref = result_atom.overlay_refs[key]
				var/image/I = overlay_ref[2]
				if(overlay_ref[1] != 0 && overlay_ref[3] != 0 && istype(I, /image)) // someone was putting lists into overlays, wtf
					overlays[overlay_ref[1]] = I
				overlay_ref[3] = overlay_ref[3] == 0 ? 0 : "\ref[I.appearance]"
			result_atom.overlays = overlays
	if(ismob(orig_datum) && (orig_datum in ai_mobs)) // ugly hack, sorry
		ai_mobs |= result
	return result

#undef _SEMI_DEEP_COPY
