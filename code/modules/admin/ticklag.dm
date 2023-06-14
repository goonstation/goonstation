/client/proc/ticklag(number as null|num)
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Ticklag"
	set desc = "Ticklag"
	set hidden = 1
	ADMIN_ONLY

	if (src.holder.level < LEVEL_CODER)
		alert("You must be at least a Coder to modify ticklag.")
		return

	if (isnull(number))
		number = input(usr, "Please enter new ticklag value.", "Ticklag", world.tick_lag) as null|num
		if (isnull(number))
			return

	world.tick_lag = number
	logTheThing(LOG_ADMIN, src, "set tick_lag to [number]")
	logTheThing(LOG_DIARY, src.mob, "set tick_lag to [number]", "admin")
	message_admins("[key_name(usr)] modified world's tick_lag to [number]")
	return
