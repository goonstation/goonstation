/datum/special_sprint
	///Disable regular sprinting behaviour
	var/overrides_sprint = FALSE
	var/no_sprint_boost = FALSE // For things that prevent sprinting speed, but don't prevent sprinting skills
	proc/can_sprint(mob/M)
		if (isliving(M))
			var/mob/living/owner = M
			if (owner.stamina < STAMINA_SPRINT)
				return
		return TRUE

	proc/do_sprint(mob/M)
		return

/datum/special_sprint/poof
	can_sprint(mob/M)
		if (!..())
			return
		if (!M || !ismob(M))
			return
		if (!isturf(M.loc))
			M.show_text("You can't seem to transform in here.", "red")
			return
		if (isdead(M))
			return
		if (!M.canmove)
			return
		if(isrestrictedz(M.loc.z))
			return
		return TRUE

/datum/special_sprint/poof/bat
	var/cloak = FALSE

	do_sprint(mob/M)
		if (M.traitHolder.hasTrait("slowstrider"))
			src.no_sprint_boost = TRUE
		new /obj/dummy/spell_batpoof(get_turf(M), M, src.cloak)

/datum/special_sprint/poof/bat/cloak
	cloak = TRUE

/datum/special_sprint/poof/fire
	do_sprint(mob/M)
		new /obj/dummy/spell_batpoof/firepoof(get_turf(M), M, 0)
