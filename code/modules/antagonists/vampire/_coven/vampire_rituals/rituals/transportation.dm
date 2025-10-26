/datum/vampire_ritual/transportation
	name = "ritual of transportation"
	incantation_lines = list(
		"amice meus in periculo",
		"a luce fuge",
		"nobiscum in tenebris gaude",
	)
	// blood_cost = 50
	ritual_duration = 1 MINUTE

/datum/vampire_ritual/transportation/invoke(mob/caster)
	var/turf/T = get_turf(src.parent)
	var/coordinates = "<a href='byond://?src=\ref[src.parent];action=jump_to_coords;target=[T.x],[T.y],[T.z];end_time=[TIME + src.ritual_duration]' title='Jump to Coords'>[T.x], [T.y], [T.z]</a>"
	src.additional_completion_text = " at ([coordinates] in [T.loc])"
	return TRUE


/obj/decal/cleanable/vampire_ritual_circle/Topic(href, href_list)
	var/mob/M = usr
	if (!istype(M) || isdead(M) || !M.client || !M.mind?.get_antagonist(ROLE_COVEN_VAMPIRE))
		return

	if (text2num(href_list["end_time"]) < TIME)
		boutput(M, SPAN_ALERT("This invokation's time frame has passed."))
		return

	if ((href_list["action"] == "jump_to_coords"))
		var/list/coords = splittext(href_list["target"], ",")
		if (length(coords) < 3)
			return

		global.animate_shrinking_outline(M)

		SPAWN(1.5 SECONDS)
			var/turf/T = locate(text2num(coords[1]), text2num(coords[2]), text2num(coords[3]))
			M.set_loc(T)
			global.animate_expanding_outline(M)

			for (var/obj/item/grab/G in M.equipped_list(FALSE))
				if (G.state < GRAB_AGGRESSIVE)
					continue

				G.affecting?.set_loc(T)
