/// GET /bans/check
/// Check
/datum/apiRoute/bans/check
	method = RUSTG_HTTP_METHOD_GET
	path = "/bans/check"
	queryParams = list("ckey", "comp_id", "ip", "player_id") // string, string, string, integer
	correct_response = /datum/apiModel/Tracked/Ban

/datum/apiRoute/bans/check/local_fallback(db_handle)
	var/player_ckey = src.queryParams["ckey"]
	var/comp_id = src.queryParams["comp_id"]
	var/ip = src.queryParams["ip"]
	if(!isnull(comp_id) && !istext(comp_id))
		throw "Computer ID must be text"
	comp_id = length(comp_id) ? comp_id : null
	ip = length(ip) ? ip : null
	if(!player_ckey && isnull(comp_id) && isnull(ip))
		throw "At least one ban identifier is required"
	var/list/rows = FALLBACK_DB.rows(db_handle, {"
		SELECT CAST(b.id AS TEXT) AS id, b.reason, b.requires_appeal,
			   b.expires_at, b.admin_ckey, b.admin_alias
		FROM bans AS b
		WHERE (b.expires_at IS NULL OR b.expires_at > datetime('now'))
		  AND EXISTS (
			SELECT 1 FROM ban_details AS d
			WHERE d.ban_id = b.id
			  AND (d.ckey = ? OR d.comp_id = ? OR d.ip = ?)
		  )
		ORDER BY b.id DESC LIMIT 1
	"}, list(player_ckey, comp_id, ip))
	if(!rows.len)
		return null
	var/list/ban = rows[1]
	ban["requires_appeal"] = !!ban["requires_appeal"]

	return ban
