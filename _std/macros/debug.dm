//debug message macros
#define DEBUG_MESSAGE(x) if (debug_messages) message_coders(x)
#define DEBUG_MESSAGE_VARDBG(x,d) if (debug_messages) message_coders_vardbg(x,d)

///Wrapper to let us runtime without killing the current proc, since CRASH only kills the exact proc it was called from
/proc/stack_trace(var/thing_to_crash)
	CRASH(thing_to_crash)

/datum/proc/AdminAddComponent(...)
	_AddComponent(args)

proc/dm_dump(var/x)
	var/datum/dm_dumper/dumper = new
	. = list()
	dumper.dm_dump(x, ., list())
	if(dumper.steps_limit <= 0)
		return null
	. = jointext(., "\n")

/datum/dm_dumper
	var/list/known_refs = list()
	var/list/tmp_vars = list()
	var/steps_limit = 3000

	proc/make_var(name)
		name = ckey(name)
		. = name
		var/i = 2
		while(. in tmp_vars)
			. = "[name][i++]"
		tmp_vars[.] = 1

	proc/image_constructor(image/img)
		var/list/cargs = list()
		var/i = 0
		var/n_args = 0
		for(var/var_name in list("icon", "loc", "icon_state", "layer", "dir"))
			i++
			var/var_value = img.vars[var_name]
			cargs += src.dm_dump(var_value, list(), list(), return_main=TRUE)
			if(var_value != initial(img.vars[var_name]))
				n_args = i
		cargs.Cut(n_args)
		return "image([jointext(cargs, ", ")])"

	proc/dm_dump(var/x, list/lines, list/path, return_main=FALSE, new_params=null, no_path_on_main=FALSE, can_use_ref=TRUE)
		if(--steps_limit <= 0)
			return
		var/val = null
		if(!return_main)
			lines.Add(null)
		var/reserved_index = return_main ? null : length(lines)
		var/refx = ref(x)
		var/is_ref = islist(x) || istype(x, /datum) || istype(x, /client)
		var/found_ref = (refx in known_refs) && can_use_ref
		if(!found_ref && is_ref)
			known_refs[refx] = length(path) ? jointext(path, "") : "src"
		if(found_ref)
			val = known_refs[refx]
		else if(istext(x))
			val = "\"[x]\""
		else if(isnum(x))
			val = "[x]"
		else if(isfile(x) || isicon(x))
			val = "'[x]'"
		else if(istype(x, /generator))
			val = "[x]"
		else if(isnull(x))
			val = "null"
		else if(istype(x, /matrix))
			var/matrix/mat = x
			if(mat.is_identity())
				val = "matrix()"
			else
				val = "matrix([mat.a], [mat.b], [mat.c], [mat.d], [mat.e], [mat.f])"
		else if(islist(x))
			var/list/listbits = list()
			var/index = 0
			var/special_list = !startswith(refx, @"[0xf")
			for(var/key in x)
				index++
				var/value = (isnum(key) || special_list) ? null : x[key]
				path += "\[[index]\]"
				var/key_str = src.dm_dump(key, lines, path, return_main=TRUE)
				var/str = key_str
				list_pop(path)
				if(!isnull(value))
					path += "\[[key_str]\]"
					if(!istext(key) && !isnum(key))
						str = "([str])"
					str = "[str] = [src.dm_dump(value, lines, path, return_main=TRUE)]"
					list_pop(path)
				listbits += str
			val = "list([jointext(listbits, ", ")])"
		else if(ispath(x))
			val = "[x]"
		else if(startswith(refx, @"[0x3a")) // appearance, overlays elements, underlays elements etc.
			return
		else
			var/datum/D = x
			if(new_params)
				val = "new [D.type]([new_params])"
			else if(D.type == /image)
				val = image_constructor(D)
			else if(isatom(D))
				var/atom/A = D
				if(!isnull(A.loc) && (ref(A.loc) in known_refs))
					val = "new [D.type]([known_refs[ref(A.loc)]])"
				else
					val = "new [D.type]"
			else
				val = "new [D.type]"
			if(isatom(D))
				var/atom/A = D
				for(var/atom/thing in A)
					var/added_line_index = length(lines) + 1
					var/list/typepath_bits = splittext("[thing.type]", "/")
					var/tmp_var = make_var(typepath_bits[length(typepath_bits)])
					src.dm_dump(thing, lines, list(tmp_var))
					lines[added_line_index] = "var[thing.type]/[lines[added_line_index]]"
			for(var/var_name in D.vars)
				var/var_value = D.vars[var_name]
				if(var_value == initial(D.vars[var_name]))
					continue
				if(D.type == /image && (var_name in list("icon", "loc", "icon_state", "layer", "dir")))
					continue
				var/var_skip_set = FALSE
				switch(var_name)
					if("transform")
						if(isatom(D) || istype(D, /image))
							var/matrix/M = var_value
							if(istype(M) && M.is_identity())
								continue
					if("filters")
						continue
					if("loc", "vis_locs", "overlays", "underlays")
						continue
					if("contents")
						if(istype(D, /image))
							continue // why the heck does /image have a contents list???
						if(isatom(D))
							continue
					if("vis_flags")
						if(isnull(initial(D.vars[var_name])) && var_value == 0)
							continue
					if("vis_contents")
						if(length(var_value) == 0)
							continue
					if("overlay_refs")
						// TODO sort by index
						if(isatom(D))
							for(var/key in var_value)
								var/image/overlay = var_value[key][2]
								var/tmp_var_name = src.make_var(key)
								var/list/image_lines = list()
								var/image_creation_str = src.dm_dump(overlay, image_lines, list(tmp_var_name), return_main=TRUE)
								var/image_str = null
								if(!length(image_lines))
									image_str = image_creation_str
									tmp_vars -= tmp_var_name
								else
									lines += "var/[tmp_var_name] = [image_creation_str]"
									lines += image_lines
									image_str = tmp_var_name
								lines += "[jointext(path, "") || "src"].UpdateOverlays([image_str], \"[key]\")"
							continue
					if("filter_data")
						if(isatom(D))
							for(var/name in var_value)
								var/list/params = var_value[name]
								var/priority = params["priority"]
								params = params.Copy()
								params.Remove("priority")
								lines += {"[jointext(path, "") || "src"].add_filter("[name]", [priority], [src.dm_dump(params, list(), list(), return_main=TRUE, can_use_ref=FALSE)])"}
							continue
					if("datum_components", "comp_lookup")
						continue // TODO
					if("special")
						if(istype(D, /obj/item))
							var/datum/item_special/special = var_value
							if(special.type != /datum/item_special/simple)
								lines += "[jointext(path, "") || "src"].setItemSpecial([special.type])"
							var_skip_set = TRUE
					if("reagents")
						if(isatom(D))
							var/datum/reagents/reagents = var_value
							lines += {"[jointext(path, "") || "src"].create_reagents([reagents.maximum_volume])"}
							var_skip_set = TRUE
				if(!issaved(D.vars[var_name]) && var_name != "particles")
					continue
				if(!length(path))
					path += "[var_name]"
				else
					path += ".[var_name]"
				src.dm_dump(var_value, lines, path, return_main=var_skip_set)
				list_pop(path)

		if(return_main)
			. = val
		else if(no_path_on_main)
			lines[reserved_index] = val
		else
			lines[reserved_index] = "[jointext(path, "") || "src"] = [val]"


// Below originally from san7890 @ https://github.com/tgstation/tgstation/pull/68039

// Used by mapmerge2 to denote the existence of a merge conflict (or when it has to complete a "best intent" merge where it dumps the movable contents of an old key and a new key on the same tile).
// We define it explicitly here to ensure that it shows up on the highest possible plane (while giving off a verbose icon) to aide mappers in resolving these conflicts.
/// DO NOT USE THIS IN NORMAL MAPPING!!! Linters WILL fail.
/obj/merge_conflict_marker
	name = "Merge Conflict Marker - DO NOT USE"
	icon = 'icons/map-editing/mapping_helpers.dmi'
	icon_state = "merge_conflict_marker"
	desc = "If you are seeing this in-game: someone REALLY, REALLY, REALLY fucked up. They physically mapped in a fucking Merge Conflict Marker. What the shit."
	plane = PLANE_SCREEN_OVERLAYS

/// We REALLY do not want un-addressed merge conflicts in maps for an inexhaustible list of reasons. This should help ensure that this will not be missed in case linters fail to catch it for any reason what-so-ever.
/obj/merge_conflict_marker/New()
	. = ..()
	var/msg = "HEY, LISTEN!!! Merge Conflict Marker detected at [log_loc(src)]! Please manually address all potential merge conflicts!!!"
	boutput(world, "<span class='bold notice'>[msg],</span>")
	message_admins(msg)

/// For unit test support
/// *Only* run the test provided within the parentheses
/// This is useful for debugging when you want to reduce noise, but should never be pushed
/// Intended to be used in the manner of `TEST_FOCUS(/datum/unit_test/math)`
#define TEST_FOCUS(test_path) ##test_path { focus = TRUE; }
