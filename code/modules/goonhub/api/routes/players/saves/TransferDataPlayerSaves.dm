
/// POST /players/saves/transfer-files
/// Transfer all save files from a player to another
/// WARNING: This overwrites all the saves for the target
/datum/apiRoute/players/saves/file/transfer
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/saves/transfer-files"
	body = /datum/apiBody/PlayerSavesTransferFiles
	correct_response = /datum/apiModel/Message

	buildBody(
		from_ckey,
		to_ckey
	)
		. = ..(args)

