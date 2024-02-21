/var/create_mob_html = null
/datum/admins/proc/create_mob(var/mob/user)
	set background = 1
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = grabResource("html/admin/create_object.html")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	if (user) user.Browse(replacetext(create_mob_html, "/* ref src */", "\ref[src]"), "window=create_mob;size=530x550")

/var/create_object_html = null
/datum/admins/proc/create_object(var/mob/user)
	set background = 1
	if (!create_object_html)
		var/objectjs = null
		objectjs = jointext(typesof(/obj), ";")
		create_object_html = grabResource("html/admin/create_object.html")
		create_object_html = replacetext(create_object_html, "null /* object types */", "\"[objectjs]\"")

	if (user) user.Browse(replacetext(create_object_html, "/* ref src */", "\ref[src]"), "window=create_object;size=530x550")

/var/create_turf_html = null
/datum/admins/proc/create_turf(var/mob/user)
	set background = 1
	if (!create_turf_html)
		var/turfjs = null
		turfjs = jointext(typesof(/turf), ";")
		create_turf_html = grabResource("html/admin/create_object.html")
		create_turf_html = replacetext(create_turf_html, "null /* object types */", "\"[turfjs]\"")

	if (user) user.Browse(replacetext(create_turf_html, "/* ref src */", "\ref[src]"), "window=create_turf;size=530x550")
