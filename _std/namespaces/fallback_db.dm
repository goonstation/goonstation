// Fallback database access for when the API is down. This is a read-only database that is cached on the server itself

CREATE_NAMESPACE(FALLBACK_DB)

ADD_TO_NAMESPACE(FALLBACK_DB)(proc/open(path, expected_server, expected_group, max_age_seconds = 900))
#ifndef LIVE_SERVER
	max_age_seconds = INFINITY
#endif
	if(!fexists(path))
		throw "Fallback file missing"
	var/list/response = json_decode(rustg_sqlite_open(path, RUSTG_SQLITE_READ_ONLY, RUSTG_SQLITE_ROWS_ASSOC))
	if (response["status"] != "ok")
		throw "Fallback file could not be opened"
	var/handle = response["handle"]
	try
		FALLBACK_DB.rows(handle, "PRAGMA query_only = ON")
		FALLBACK_DB.rows(handle, "BEGIN")
		var/list/rows = FALLBACK_DB.rows(handle, {"
			SELECT schema_version, server_id, server_group_id,
				   strftime('%s', 'now') - strftime('%s', snapshot_at) AS age_seconds
			FROM export_metadata
		"})
		if(rows.len != 1)
			throw "Invalid fallback metadata"
		var/list/meta = rows[1]
		if(meta["schema_version"] != 1 || meta["server_id"] != expected_server)
			throw "Wrong fallback schema or server"
		if(meta["server_group_id"] != expected_group)
			throw "Wrong fallback server group"
		var/age = meta["age_seconds"]
		if(isnull(age) || age < 0 || age > max_age_seconds)
			throw "Fallback snapshot age rejected"
	catch(var/error)
		rustg_sqlite_close(handle)
		throw error
	return handle

ADD_TO_NAMESPACE(FALLBACK_DB)(proc/rows(handle, sql, list/parameters = null))
	var/response = json_decode(rustg_sqlite_query_blocking(handle, sql, parameters))
	if (response["status"] != "ok")
		throw "Fallback SQLite query failed"
	var/list/rows = response["rows"]
	return rows

ADD_TO_NAMESPACE(FALLBACK_DB)(proc/close(handle))
	rustg_sqlite_close(handle)
