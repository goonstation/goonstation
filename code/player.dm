//set stuff that has to persist between connections here.
/datum/player
	var
		key
		client/client

		mentor = 0
		see_mentor_pms = 1

		shamecubed = 0

	New(key)
		src.key = key
		src.tag = "player-[ckey(key)]"

		if (mentors.Find(ckey(key)))
			mentor = 1

/proc/find_player(key)
	var/datum/player/player = locate("player-[ckey(key)]")
	return player

/proc/make_player(key)
	var/datum/player/player = find_player(key) // just double check so that we don't get any dupes
	if (!player)
		player = new(key)
	return player
