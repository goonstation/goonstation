/obj/fakeobjects/sec_tv
	name = "broken million dollar flatscreen teevee"
	desc = "It's a broken million dollar flatscreen teevee."
	icon = 'icons/obj/sec_TV.dmi'
	icon_state = "wall-monitor-fake"
	// icon = 'icons/obj/clothing/item_glasses.dmi'

/proc/backup_scores()
	message_admins ("[usr] - [usr?.client] backed up jobxp scores.")
	var/backup_text = world.GetScores(hub_path=config.medal_hub, hub_password=config.medal_password)
	var/file_name = "data/scores_backup_[world.realtime].txt"
	var/file_backup=text2file(backup_text, file_name)
	usr << file_name
	logTheThing( "debug", usr, null, "Backed up scores: [backup_text]" )
