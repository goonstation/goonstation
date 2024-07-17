/obj/fakeobject/sec_tv
	name = "broken million dollar flatscreen teevee"
	desc = "It's a broken million dollar flatscreen teevee."
	icon = 'icons/obj/sec_TV.dmi'
	icon_state = "wall-monitor-fake"
	// icon = 'icons/obj/clothing/item_glasses.dmi'

/proc/backup_scores()
	message_admins ("[usr] - [usr?.client] backed up jobxp scores.")
	var/backup_text = world.GetScores()
	var/file_name = "data/scores_backup_[world.realtime].txt"
	text2file(backup_text, file_name)
	usr << file_name
	logTheThing(LOG_DEBUG, usr, "Backed up scores: [backup_text]")
