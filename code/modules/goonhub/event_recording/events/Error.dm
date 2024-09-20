
/// Record an error
/datum/eventRecord/Error
	eventType = "error"
	body = /datum/eventRecordBody/Error

	send(
		name,
		file,
		line,
		desc,
		user,
		user_ckey,
		invalid
	)
		. = ..(args)

	buildAndSend(exception/E, user)
		var/invalid = !istype(E)
		var/mob/userMob
		if (ismob(user)) userMob = user

		src.send(
			invalid ? E : E.name,
			invalid ? null : E.file,
			invalid ? null : E.line,
			E.desc ? E.desc : null,
			user ? (userMob ? "[userMob]" : "[user]") : null,
			userMob ? userMob.ckey : null,
			invalid
		)
