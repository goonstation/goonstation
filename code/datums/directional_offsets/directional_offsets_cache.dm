var/datum/directional_offsets_cache/directional_offsets_cache = new()

/datum/directional_offsets_cache
	var/list/list/datum/directional_offsets/directional_offsets_by_id = null

/datum/directional_offsets_cache/New()
	. = ..()

	src.directional_offsets_by_id = list()
	for (var/T in concrete_typesof(/datum/directional_offsets))
		var/datum/directional_offsets/offsets = new T()
		src.directional_offsets_by_id[offsets.id] ||= list()
		src.directional_offsets_by_id[offsets.id] += offsets

	for (var/id in src.directional_offsets_by_id)
		sortList(src.directional_offsets_by_id[id], GLOBAL_PROC_REF(cmp_directional_offsets))


/proc/cmp_directional_offsets(datum/directional_offsets/a, datum/directional_offsets/b)
	. = b.priority - a.priority
	. ||= cmp_text_asc(ref(a), ref(b))
