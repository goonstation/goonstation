// Simple buff for the staff. Maybe it's less of a wasted spell slot now (Convair880).
/datum/targetable/spell/summon_staff
	name = "Summon Staff of Cthulhu"
	desc = "Returns the staff to your active hand."
	icon_state = "staff"
	targeted = 0
	cooldown = 600
	requires_robes = 1
	voice_grim = 'sound/voice/wizard/StaffGrim.ogg'
	voice_fem = 'sound/voice/wizard/StaffFem.ogg'
	//voice_other = 'sound/voice/wizard/notdoneyet.ogg'
	maptext_colors = list("#b320c3", "#5a1d8a")


	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		// Ability holder only checks for M.stat and wizard power, we need more than that here.
		if (M.getStatusDuration("stunned") > 0 || M.getStatusDuration("knockdown") || M.getStatusDuration("unconscious") > 0 || !isalive(M) || M.restrained())
			boutput(M, SPAN_ALERT("Not when you're incapacitated or restrained."))
			return 1

		var/list/staves = list()
		var/we_hold_it = FALSE
		for_by_tcl(S, /obj/item/staff/cthulhu)
			if (M.mind && M.mind.key == S.wizard_key)
				if (S == M.find_in_hand(S))
					we_hold_it = TRUE
					continue
				if (!(S in staves))
					staves["[S.name] #[staves.len + 1] [ismob(S.loc) ? "carried by [S.loc.name]" : "at [get_area(S)]"]"] += S

		if (!we_hold_it)
			if(!istype(get_area(M), /area/sim/gunsim)) // Avoid dead chat spam
				M.say("KOHM HEIRE", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
			..()

		switch (staves.len)
			if (-INFINITY to 0)
				if (we_hold_it)
					boutput(M, SPAN_ALERT("You're already holding your staff."))
					return 1 // No cooldown.
				else
					boutput(M, SPAN_ALERT("You summon a new staff to your hands."))
					var/obj/item/staff/cthulhu/C = new /obj/item/staff/cthulhu(get_turf(M))
					if(!isvirtual(M))
						C.wizard_key = M.mind?.key
					M.put_in_hand_or_drop(C)
					return 0

			if (1)
				var/obj/item/staff/cthulhu/S2
				for (var/C in staves)
					S2 = staves[C]
					break

				if (!S2 || !istype(S2))
					boutput(M, SPAN_ALERT("You were unable to summon your staff."))
					return 0

				S2.send_staff_to_target_mob(M)

			// There could be multiple, I suppose.
			if (2 to INFINITY)
				var/t1 = input("Please select a staff to summon", "Target Selection", null, null) as null|anything in staves
				if (!t1)
					return 1

				var/obj/item/staff/cthulhu/S3 = staves[t1]

				if (!M || !ismob(M))
					return 0
				if (!S3 || !istype(S3))
					boutput(M, SPAN_ALERT("You were unable to summon your staff."))
					return 0
				if (!isliving(M) || !M.mind || !iswizard(M))
					boutput(M, SPAN_ALERT("You seem to have lost all magical abilities."))
					return 0
				if (M.wizard_castcheck(src) == 0)
					return 0 // Has own user feedback.
				if (M.getStatusDuration("stunned") > 0 || M.getStatusDuration("knockdown") || M.getStatusDuration("unconscious") > 0 || !isalive(M) || M.restrained())
					boutput(M, SPAN_ALERT("Not when you're incapacitated or restrained."))
					return 0
				if (M.mind.key != S3.wizard_key)
					boutput(M, SPAN_ALERT("You were unable to summon your staff."))
					return 0

				S3.send_staff_to_target_mob(M)

		return 0

/datum/targetable/spell/summon_thunder_staff
	name = "Summon and Recharge Staff of Thunder"
	desc = "Returns the staff to your active hand and restores its charges."
	icon_state = "staff_thunder"
	targeted = 0
	cooldown = 20 SECONDS
	requires_robes = 1
	maptext_colors = list("#ebb02b", "#fcf574", "#ebb02b", "#fcf574", "#ebf0f2")

	cast(mob/target)
		var/mob/living/M = holder?.owner
		if (!ismob(M))
			return 1
		if (!can_act(M))
			boutput(M, "<span class='alert'Not when you're incapacitated or restrained.")
			return 1

		if(!istype(get_area(M), /area/sim/gunsim)) // Avoid dead chat spam
			M.say("KUH, ABAH'RAH", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		var/list/staves = list()
		var/we_hold_it = FALSE
		for_by_tcl(S, /obj/item/staff/thunder)
			if (M.mind?.key == S.wizard_key)
				if (S == M.find_in_hand(S))
					we_hold_it = TRUE
					continue
				if (!(S in staves))
					staves["[S.name] #[length(staves) + 1] [ismob(S.loc) ? "carried by [S.loc.name]" : "at [get_area(S)]"]"] += S

		switch (length(staves))
			if (0)
				if (we_hold_it)
					for (var/obj/item/staff/thunder/T in M.contents)
						T.recharge_thunder()
					boutput(M, "<span class='alert'You charge your staff in your hand.")
					return 0
				else
					boutput(M, "<span class='alert'You summon a new staff to your hands.")
					var/obj/item/staff/thunder/C = new /obj/item/staff/thunder(get_turf(M))
					if(!isvirtual(M))
						C.wizard_key = M.mind?.key
					M.put_in_hand_or_drop(C)
					return 0

			if (1)
				var/obj/item/staff/thunder/staff
				for (var/C in staves)
					staff = staves[C]
					break

				if (!staff || !istype(staff))
					boutput(M, "<span class='alert'You were unable to summon your staff.")
					return 0

				residual_spark(staff.loc)
				staff.send_staff_to_target_mob(M)
				staff.recharge_thunder()


			if (2 to INFINITY)
				var/t1 = tgui_input_list(M, "Please select a staff to summon", "Target Selection", staves)
				if (!t1)
					return 1

				var/obj/item/staff/thunder/staff = staves[t1]

				if (!M)
					return 0
				if (!istype(staff))
					boutput(M, "<span class='alert'You were unable to summon your staff.")
					return 0
				if (!can_act(M))
					boutput(M, "<span class='alert'Not when you're incapacitated or restrained.")
					return 0
				if (M.mind.key != staff.wizard_key)
					boutput(M, "<span class='alert'You were unable to summon your staff.")
					return 0

				residual_spark(staff.loc)
				staff.send_staff_to_target_mob(M)
				staff.recharge_thunder()

		return 0
