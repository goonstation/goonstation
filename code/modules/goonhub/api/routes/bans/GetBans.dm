/// GET /bans
/// Get
/datum/apiRoute/bans/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/bans"
	queryParams = list("filters", "sort_by", "descending", "page", "per_page") // object, string, string, int, int
	correct_response = /datum/apiModel/Paginated/BanList

/datum/apiRoute/bans/get/local_fallback(db_handle)
	var/page = max(1, round(src.queryParams["page"]))
	var/page_size = max(1, min(100, round(src.queryParams["per_page"])))
	var/list/rows = FALLBACK_DB.rows(db_handle, {"
		SELECT CAST(id AS TEXT) AS id, reason, requires_appeal,
			   expires_at, admin_ckey, admin_alias
		FROM bans
		WHERE expires_at IS NULL OR expires_at > datetime('now')
		ORDER BY id DESC LIMIT ? OFFSET ?
	"}, list(page_size, (page - 1) * page_size))
	return rows[1]
