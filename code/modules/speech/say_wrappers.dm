/client/proc/blobsay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "blobsay"
	set hidden = TRUE
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!src.mob || src.player_mode)
		return

	src.mob.say(msg, flags = SAYFLAG_ADMIN_MESSAGE | SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_BLOB))

	logTheThing(LOG_ADMIN, src, "BLOBSAY: [msg]")
	logTheThing(LOG_DIARY, src, "BLOBSAY: [msg]", "admin")


/client/proc/dronesay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "dronesay"
	set hidden = TRUE
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!src.mob || src.player_mode)
		return

	src.mob.say(msg, flags = SAYFLAG_ADMIN_MESSAGE | SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_GHOSTDRONE))

	logTheThing(LOG_ADMIN, src, "DRONESAY: [msg]")
	logTheThing(LOG_DIARY, src, "DRONESAY: [msg]", "admin")


/client/proc/dsay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "dsay"
	set hidden = TRUE
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!src.mob || src.player_mode)
		return

	src.mob.say(msg, flags = SAYFLAG_ADMIN_MESSAGE | SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_DEAD))

	logTheThing(LOG_ADMIN, src, "DSAY: [msg]")
	logTheThing(LOG_DIARY, src, "DSAY: [msg]", "admin")


/client/proc/flocksay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "flocksay"
	set hidden = TRUE
	ADMIN_ONLY

	if (!src.mob || src.player_mode)
		return

	src.mob.say(msg, flags = SAYFLAG_ADMIN_MESSAGE | SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_GLOBAL_FLOCK))

	logTheThing(LOG_ADMIN, src, "FLOCKSAY: [msg]")
	logTheThing(LOG_DIARY, src, "FLOCKSAY: [msg]", "admin")


/client/proc/hivesay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "hivesay"
	set hidden = TRUE
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!src.mob || src.player_mode)
		return

	src.mob.say(msg, flags = SAYFLAG_ADMIN_MESSAGE | SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_GLOBAL_HIVEMIND))

	logTheThing(LOG_ADMIN, src, "HIVESAY: [msg]")
	logTheThing(LOG_DIARY, src, "HIVESAY: [msg]", "admin")


/client/proc/kudzusay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "kudzusay"
	set hidden = TRUE
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!src.mob || src.player_mode)
		return

	src.mob.say(msg, flags = SAYFLAG_ADMIN_MESSAGE | SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_KUDZU))

	logTheThing(LOG_ADMIN, src, "KUDZUSAY: [msg]")
	logTheThing(LOG_DIARY, src, "KUDZUSAY: [msg]", "admin")


/client/proc/marsay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "marsay"
	set hidden = TRUE
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!src.mob || src.player_mode)
		return

	src.mob.say(msg, flags = SAYFLAG_ADMIN_MESSAGE | SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_MARTIAN))

	logTheThing(LOG_ADMIN, src, "MARSAY: [msg]")
	logTheThing(LOG_DIARY, src, "MARSAY: [msg]", "admin")


/client/proc/silisay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "silisay"
	set hidden = TRUE
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!src.mob || src.player_mode)
		return

	src.mob.say(msg, flags = SAYFLAG_ADMIN_MESSAGE | SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_SILICON))

	logTheThing(LOG_ADMIN, src, "SILISAY: [msg]")
	logTheThing(LOG_DIARY, src, "SILISAY: [msg]", "admin")


/client/proc/thrallsay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "thrallsay"
	set hidden = TRUE
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!src.mob || src.player_mode)
		return

	src.mob.say(msg, flags = SAYFLAG_ADMIN_MESSAGE | SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_GLOBAL_THRALL))

	logTheThing(LOG_ADMIN, src, "THRALLSAY: [msg]")
	logTheThing(LOG_DIARY, src, "THRALLSAY: [msg]", "admin")
