// Fallback database access for when the API is down. This is a read-only database that is cached on the server itself

CREATE_NAMESPACE(FALLBACK_DB)

ADD_TO_NAMESPACE(FALLBACK_DB)(proc/open(path, expected_server, expected_group, max_age_seconds = 900))
    if(!fexists(path))
        throw "Fallback file missing"
    var/database/db = new(path)
    try
        if(db.Error())
            throw "Fallback file could not be opened"
        FALLBACK_DB.rows(db, "PRAGMA query_only = ON")
        FALLBACK_DB.rows(db, "BEGIN")
        var/list/rows = FALLBACK_DB.rows(db, {"
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
        db.Close()
        throw error
    return db

ADD_TO_NAMESPACE(FALLBACK_DB)(proc/rows(database/db, sql, list/parameters = null))
    var/list/query_args = list(sql)
    if(parameters)
        query_args.Add(parameters)
    var/database/query/query = new(arglist(query_args))
    if(!query.Execute(db))
        query.Close()
        throw "Fallback SQLite query failed"
    var/list/rows = list()
    while(query.NextRow())
        rows += list(query.GetRowData())
    if(query.Error())
        query.Close()
        throw "Fallback SQLite read failed"
    query.Close()
    return rows
