// Simple buff for the staff. Maybe it's less of a wasted spell slot now (Convair880).

/datum/targetable/spell/summon_staff
	name = "Summon Abstract staff"
	desc = "You shouldn't see me"
	icon_state = "staff_tele"
	targeted = 0
	cooldown = 20 SECONDS
	requires_robes = 1
	//the type of staff to be summoned
	var/staff_type = /obj/item/staff/cthulhu
	//If the staff has recharge mechanics, this will recharge it on cast.
	var/do_recharge = FALSE
	//Magical words to say
	var/spell_words = "SH'UOLD NO-T SEE"
	maptext_colors = list("#b320c3", "#5a1d8a")

	cast(mob/target)
		var/mob/living/M = holder?.owner
		if (!ismob(M))
			return 1
		if (!can_act(M))
			boutput(M, SPAN_ALERT("Not when you're incapacitated or restrained."))
			return 1

		if(!istype(get_area(M), /area/sim/gunsim)) // Avoid dead chat spam
			M.say((spell_words), flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		var/list/staves = list()
		var/we_hold_it = FALSE
		for (var/obj/item/staff/S as anything in by_type[src.staff_type])
			if (M.mind?.key != S.wizard_key)
				continue
			if (S == M.find_in_hand(S))
				we_hold_it = TRUE
				continue
			if (!(S in staves))
				staves["[S.name] #[length(staves) + 1] [ismob(S.loc) ? "carried by [S.loc.name]" : "at [get_area(S)]"]"] += S

		switch (length(staves))
			if (0)
				if (we_hold_it)
					if(!src.do_recharge)
						boutput(M, SPAN_ALERT("You're already holding your staff!"))
						return 1
					for (var/obj/item/staff/S in M.contents)
						if (istype(S, src.staff_type))
							S.recharge()
					boutput(M, SPAN_ALERT("You charge your staff in your hand."))
					return 0
				else
					boutput(M, SPAN_ALERT("You summon a new staff to your hands."))
					var/obj/item/staff/S = new src.staff_type(get_turf(M))
					if(!isvirtual(M))
						S.wizard_key = M.mind?.key
					M.put_in_hand_or_drop(S)
					return 0

			if (1)
				var/obj/item/staff/S
				for (var/staff in staves)
					S = staves[staff] // bruh
					break

				if (!S || !istype(S))
					boutput(M, SPAN_ALERT("You were unable to summon your staff."))
					return 0

				S.send_staff_to_target_mob(M)
				if(src.do_recharge)
					S.recharge()

			if (2 to INFINITY)
				var/t1 = tgui_input_list(M, "Please select a staff to summon", "Target Selection", staves)
				if (!t1)
					return 1

				var/obj/item/staff/S = staves[t1]

				if (!M || QDELETED(M))
					return 0
				if (!istype(S))
					boutput(M, SPAN_ALERT("You were unable to summon your staff."))
					return 0
				if (!can_act(M))
					boutput(M, SPAN_ALERT("Not when you're incapacitated or restrained."))
					return 0

				S.send_staff_to_target_mob(M)
				if(src.do_recharge)
					S.recharge()
		return 0

/datum/targetable/spell/summon_staff/cthulhu
	name = "Summon Staff of Cthulhu"
	desc = "Returns the staff to your active hand."
	icon_state = "staff"
	cooldown = 1 MINUTE
	voice_grim = 'sound/voice/wizard/StaffGrim.ogg'
	voice_fem = 'sound/voice/wizard/StaffFem.ogg'
	//voice_other = 'sound/voice/wizard/notdoneyet.ogg'
	staff_type = /obj/item/staff/cthulhu
	spell_words = "KOHM HEIRE"


/datum/targetable/spell/summon_staff/thunder
	name = "Summon and Recharge Staff of Thunder"
	desc = "Returns the staff to your active hand and restores its charges."
	icon_state = "staff_thunder"
	cooldown = 20 SECONDS
	maptext_colors = list("#ebb02b", "#fcf574", "#ebb02b", "#fcf574", "#ebf0f2")
	staff_type = /obj/item/staff/thunder
	spell_words = "KUH, ABAH'RAH"
	do_recharge = TRUE

/datum/targetable/spell/summon_staff/telekinetic
	name = "Summon and Recharge telekinetic staff"
	desc = "Returns the staff to your active hand and restores its charges."
	icon_state = "staff_tele"
	cooldown = 1 MINUTE
	maptext_colors = list("#2bc1eb", "#39c6c4", "#1597ae", "#a2f5f5", "#ebf0f2")
	staff_type = /obj/item/staff/telekinesis
	spell_words = "THRO, O'HERE"
	do_recharge = TRUE
