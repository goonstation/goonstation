
/// POST /remote-music
/// Queue a piece of music from youtube to be played in a given round
/datum/apiRoute/remoteMusic
	method = RUSTG_HTTP_METHOD_POST
	path = "/remote-music"
	body = /datum/apiBody/remoteMusic
	correct_response = /datum/apiModel/Message

	buildBody(
		video,
		round_id,
		game_admin_ckey
	)
	 . = ..(args)
