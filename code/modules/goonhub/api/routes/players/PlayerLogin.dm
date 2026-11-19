/// POST /players
/// Register a login for a player with associated details
/datum/apiRoute/players/login
	method = RUSTG_HTTP_METHOD_POST
	path = "/players"
	body = /datum/apiBody/players/login
	correct_response = /datum/apiModel/Tracked/Player

	buildBody(
		ckey,
		key,
		ip,
		comp_id,
		byond_major,
		byond_minor,
		round_id,
		server_id
	)
		. = ..(args)

/datum/apiRoute/players/login/local_fallback(db_handle)
	var/player_ckey = ckey(src.body.fields["ckey"])
	if(!length(player_ckey))
		throw "Player ckey is required"
	var/list/rows = FALLBACK_DB.rows(db_handle, {"
		SELECT EXISTS (
			SELECT 1 FROM player_mentors WHERE player_ckey = ?
		) AS is_mentor, EXISTS (
			SELECT 1 FROM player_hos WHERE player_ckey = ?
		) AS is_hos
	"}, list(player_ckey, player_ckey))
	var/list/flags = rows[1]
	flags["is_mentor"] = !!flags["is_mentor"]
	flags["is_hos"] = !!flags["is_hos"]
	return flags
