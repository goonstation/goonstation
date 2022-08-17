/*
	These are fallback procs for all API functions that require it
	This means that if the central server dies, this can pick up and do it's thang
	Currently only bans exist here
*/

/proc/checkBanApiFallback(data)
	var/database/db = new("data/localBans.db")

	//Construct sql field search
	var/searchSql = ""
	var/list/prepared = new()
	for (var/key in data)
		if (key == "ckey" || key == "ip" || key == "compID")
			var/param = data[key]
			if (param)
				searchSql += "[key] = ? OR "
				prepared.Add(param)

	searchSql = copytext(searchSql, 1, -4) //Remove the trailing ' OR '
	var/sql = "SELECT * FROM bans WHERE removed = 0 AND ([searchSql]) ORDER BY id DESC"

	var/list/queryList = new()
	queryList.Add(sql)
	queryList += prepared
	var/database/query/q = new(queryList)

	var/list/returnData = new()

	if(!q.Execute(db))
		returnData["error"] = "Unable to query database: \[[q.Error()]\] [q.ErrorMsg()]"
		return returnData

	var/count = 1
	while(q.NextRow())
		var/list/current = new()
		var/list/row = q.GetRowData()
		for (var/key in row)
			current[key] = row[key]
		returnData["[count]"] = current
		count++

	if (count == 1) //None found, tell the bans proc thus. yes i know 1 is weird for none, shush
		returnData["none"] = "No results found"
		return returnData

	return returnData


/proc/clearTempBansApiFallback()
	var/database/db = new("data/localBans.db")

	var/cminutes = (world.realtime / 10) / 60
	var/sql = "UPDATE bans SET removed = 1 WHERE (timestamp > 0 AND ? >= timestamp) AND removed = 0"

	var/list/queryList = new()
	queryList.Add(sql)
	queryList.Add(cminutes)
	var/database/query/q = new(queryList)

	var/list/returnData = new()

	if(!q.Execute(db))
		returnData["error"] = "Unable to query database: \[[q.Error()]\] [q.ErrorMsg()]"
		return returnData

	var/count = q.RowsAffected()

	returnData["cleared"] = count
	return returnData


/proc/addBanApiFallback(data)
	var/database/db = new("data/localBans.db")

	//Check we dont already have this ban
	var/sql = "SELECT * FROM bans WHERE ckey = ? AND compID = ? AND ip = ? AND removed = 0"
	var/list/prepared = new()
	prepared.Add(data["ckey"])
	prepared.Add(data["compID"])
	prepared.Add(data["ip"])

	var/list/queryList = new()
	queryList.Add(sql)
	queryList += prepared
	var/database/query/q = new(queryList)

	var/list/returnData = new()

	if(!q.Execute(db))
		returnData["error"] = "Unable to query database: \[[q.Error()]\] [q.ErrorMsg()]"
		return returnData

	var/count = 0
	while(q.NextRow())
		count++
		break

	if (count)
		returnData["showAdmins"] = 1
		returnData["error"] = "Ban already exists for: Ckey: [data["ckey"]], compID: [data["compID"]] and IP: [data["ip"]]"
		return returnData

	//Add the ban
	var/sql2 = "INSERT INTO bans (ckey, compID, ip, reason, akey, timestamp, previous, chain) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
	var/list/prepared2 = new()
	prepared2.Add(data["ckey"])
	prepared2.Add(data["compID"])
	prepared2.Add(data["ip"])
	prepared2.Add(data["reason"])
	prepared2.Add(data["akey"])
	prepared2.Add(data["timestamp"])
	prepared2.Add(data["previous"])
	prepared2.Add(data["chain"])

	var/list/queryList2 = new()
	queryList2.Add(sql2)
	queryList2 += prepared2
	var/database/query/q2 = new(queryList2)

	if(!q2.Execute(db))
		returnData["error"] = "Unable to query database: \[[q.Error()]\] [q.ErrorMsg()]"
		return returnData

	returnData["1"] = data
	data["type"] = "add"
	writeToBanLog(data)
	return returnData


/proc/editBanApiFallback(data)
	var/database/db = new("data/localBans.db")

	//Add the ban
	var/sql = "UPDATE bans SET ckey = ?, compID = ?, ip = ?, reason = ?, akey = ?, timestamp = ? WHERE id = ?"
	var/list/prepared = new()
	prepared.Add(data["ckey"])
	prepared.Add(data["compID"])
	prepared.Add(data["ip"])
	prepared.Add(data["reason"])
	prepared.Add(data["akey"])
	prepared.Add(data["timestamp"])
	prepared.Add(data["id"])

	var/list/queryList = new()
	queryList.Add(sql)
	queryList += prepared
	var/database/query/q = new(queryList)

	var/list/returnData = new()

	if(!q.Execute(db))
		returnData["error"] = "Unable to query database: \[[q.Error()]\] [q.ErrorMsg()]"
		return returnData

	if (q.RowsAffected() == 0) //Oh no nothing was changed that's PRETTY FUCKIN WEIRD
		returnData["error"] = "Edit ban changed nothing for: Ckey: [data["ckey"]], compID: [data["compID"]] and IP: [data["ip"]]"
		return returnData

	returnData["1"] = data
	data["type"] = "edit"
	writeToBanLog(data)
	return returnData


/proc/deleteBanApiFallback(data)
	var/database/db = new("data/localBans.db")

	//Add the ban
	var/sql = "UPDATE bans SET removed = 1 WHERE id = ?"
	var/list/prepared = new()
	prepared.Add(data["id"])

	var/list/queryList = new()
	queryList.Add(sql)
	queryList += prepared
	var/database/query/q = new(queryList)

	var/list/returnData = new()

	if(!q.Execute(db))
		returnData["error"] = "Unable to query database: \[[q.Error()]\] [q.ErrorMsg()]"
		return returnData

	if (q.RowsAffected() == 0) //It wasn't removed that's also pretty fuckin weird
		returnData["error"] = "Delete ban removed nothing for ID: [data["id"]]"
		return returnData

	returnData["1"] = data
	data["type"] = "delete"
	writeToBanLog(data)
	return returnData


//Internal proc for the ban panel to search through bans
/proc/getBanApiFallback(searchCol="all", search="", order="DESC", offset=0, limit=10, sort="id", removed=0)

	var/database/db = new("data/localBans.db")

	//I COULD do field validation here but I really cannot be fucked

	//Get the matched rows
	var/list/prepArray = new()
	var/sql = "SELECT * FROM bans WHERE removed = [removed]"
	if (search && length(search) > 0)
		sql += " AND ("
		if (searchCol == "all")
			var/val = search
			sql += "ckey LIKE ? OR akey LIKE ? OR compID LIKE ? OR ip LIKE ? OR reason LIKE ?"
			var/pSearch = val+"%"
			prepArray.Add(pSearch, pSearch, pSearch, pSearch, pSearch) //this is so dumb
		else
			sql += searchCol + " LIKE ?"
			prepArray.Add(search+"%")
		sql += ")"

	sql += " ORDER BY "+sort+" "+order+" LIMIT "+limit
	var/list/queryList = new()
	queryList.Add(sql)
	queryList += prepArray
	var/database/query/q = new(queryList)

	if(!q.Execute(db))
		logTheThing(LOG_DEBUG, null, "<b>Local Callback Error</b> - callback failed in <b>getBanApiFallback</b> with message: <b>Unable to query database</b>: \[[q.Error()]\] [q.ErrorMsg()]")
		logTheThing(LOG_DIARY, null, "Local Callback Error - callback failed in getBanApiFallback with message: Unable to query database: \[[q.Error()]\] [q.ErrorMsg()]", "debug")
		return 0

	//We gotta put all our rows in a list so we can count them for pagination
	var/list/returnData = new()
	var/list/allRows = new()
	while(q.NextRow())
		var/list/row = q.GetRowData()
		allRows += list(row)

	var/totalBans = length(allRows)

	//Now we get the subset of the returned rows and format them correctly
	var/list/requested = allRows.Copy(offset, limit)
	var/count = 1
	for (var/key1 in requested)
		var/list/current = new()
		var/list/row = requested[count]
		for (var/key2 in row)
			current[key2] = row[key2]
		returnData["[count]"] = current
		count++

	returnData["total"] = totalBans
	returnData["cminutes"] = getWorldMins()
	returnData["callback"] = "updateBans"

	return json_encode(returnData)


/proc/uploadLocalBans(F as file)
	fcopy(F, "data/localBans.db")
