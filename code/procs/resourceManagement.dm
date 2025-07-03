
/*********************************
* GENERIC HELPERS FOR BOTH SYSTEMS
*********************************/

/proc/loadCdnManifest()
	if (!cdn) return list()
	if (rustg_file_exists("cdn-manifest.json"))
		var/manifestJson = file2text("cdn-manifest.json")
		if (rustg_json_is_valid(manifestJson))
			logTheThing(LOG_DEBUG, null, "Successfully loaded CDN manifest")
			return json_decode(manifestJson)
	logTheThing(LOG_DEBUG, null, "Failed to load CDN manifest")
	return list()


//Generates file paths for browser resources when used in html tags e.g. <img>
/proc/resource(file, group)
	if (!file) return
	if (cdn)
		if (cdnManifest[file]) file = cdnManifest[file]
		. = "[cdn]/[file]"
	else
		if (findtext(file, "{{resource")) //Got here via the dumb regex proc (local only)
			file = group
		if (findtext(file, "/"))
			var/list/parts = splittext(file, "/")
			file = parts[parts.len]
		. = file


//Returns the file contents for storage in memory or further processing during runtime (e.g. many html files)
/proc/grabResource(path, preventCache = 0)
	if (!path) return 0
	if (cdn && cdnManifest[path]) path = cdnManifest[path]

	Z_LOG_DEBUG("Resource/Grab", "[path]")
	var/file

	//File exists in cache, just return that
	if (!disableResourceCache && cachedResources[path])
		Z_LOG_DEBUG("Resource/Grab", "[path] - cache hit")
		file = cachedResources[path]
	//Not in cache, go grab it
	else
		if (cdn)
			Z_LOG_DEBUG("Resource/Grab", "[path] - requesting from CDN")

			//Actually get the file contents from the CDN
			var/datum/http_request/request = new()
			request.prepare(RUSTG_HTTP_METHOD_GET, "[cdn]/[path]", "", "")
			request.begin_async()
			UNTIL(request.is_complete())
			var/datum/http_response/response = request.into_response()

			if (response.errored || !response.body || response.status_code != 200)
				Z_LOG_ERROR("Resource/Grab", "[path] - failed to get from CDN")
				CRASH("CDN DEBUG: No file found for path: [path]")

			file = response.body

		else //No CDN, grab from local directory
			Z_LOG_DEBUG("Resource/Grab", "[path] - locally loaded, parsing")
			file = parseAssetLinks(file("browserassets/src/[path]"))

		Z_LOG_DEBUG("Resource/Grab", "[path] - complete")

		//Cache the file in memory if resource caching is globally enabled, and not disabled for this item
		if (!disableResourceCache && !preventCache)
			Z_LOG_DEBUG("Resource/Grab", "[path] - stored in cache")
			cachedResources[path] = file

	return file


/proc/debugResourceCacheItem(path)
	if (cachedResources[path])
		return html_encode(cachedResources[path])
	else
		return "Not found"


/client/proc/debugResourceCache()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Resource Cache"
	set hidden = 1
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/msg = "Resource cache contents:"
	for (var/r in cachedResources)
		msg += "<br>[r]"
	boutput(src, msg)


/client/proc/toggleResourceCache()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Resource Cache"
	set desc = "Enable or disable the resource cache system"
	ADMIN_ONLY
	SHOW_VERB_DESC

	disableResourceCache = !disableResourceCache
	boutput(usr, SPAN_NOTICE("Toggled the resource cache [disableResourceCache ? "off" : "on"]"))
	logTheThing(LOG_ADMIN, usr, "toggled the resource cache [disableResourceCache ? "off" : "on"]")
	logTheThing(LOG_DIARY, usr, "toggled the resource cache [disableResourceCache ? "off" : "on"]", "admin")
	message_admins("[key_name(usr)] toggled the resource cache [disableResourceCache ? "off" : "on"]")


/*********************************
* CDN PROCS FOR LIVE SERVERS
*********************************/

//aint shit

/*********************************
* PROCS FOR LOCAL SERVER FALLBACK
*********************************/


//Replace placeholder tags with the raw filename (minus any subdirs), only for localservers
/proc/doAssetParse(path)
	if (findtext(path, "/"))
		var/list/parts = splittext(path, "/")
		path = parts[parts.len]
	return path


//Converts placeholder tags to filepaths appropriate for local-hosting offline (absolute, no subdirs)
/proc/parseAssetLinks(file, path)
	if (!file) return 0

	//Get file extension
	if (path)
		var/list/parts = splittext(path, ".")
		var/ext = parts[length(parts)]
		ext = lowertext(ext)
		//Is this file a binary thing
		if (ext in list("jpg", "jpeg", "png", "svg", "bmp", "gif", "eot", "woff", "woff2", "ttf", "otf", "map", "mp4", "psd"))
			return 0
		// Is this file a bundled tgui file?
		if ((length(parts) > 2) && (parts[length(parts) - 1] in list("bundle", "hot-update")))
			return 0

	//Look for resource placeholder tags. {{resource("path/to/file")}}
	var/fileText = file
	if (isfile(file))
		fileText = file2text(file)
	if (fileText && findtext(fileText, "{{resource"))
		var/regex/R = new("\\{\\{resource\\(\"(.*?)\"\\)\\}\\}", "ig")
		fileText = R.Replace(fileText, /proc/resource) // This line specifically is /very/ slow

	return fileText


//Puts all files in a directory into a list
/proc/recursiveFileLoader(dir)
	for(var/i in flist(dir))
		if (copytext(i, -1) == "/") //Is Directory
			//Skip certain directories
			if (i == "unused/" || i == "html/" || i == "node_modules/" || i == "build/")
				continue
			else
				LAGCHECK(LAG_HIGH)
				recursiveFileLoader(dir + i)
		else //Is file
			if (dir == "browserassets/src/") //skip files in base dir (hardcoding dir name here because im lazy ok)
				continue
			else
				localResources["[dir][i]"] = file("[dir][i]")
				LAGCHECK(LAG_HIGH)


//#LongProcNames #yolo
/client/proc/loadResourcesFromList(list/rscList)
	var/i = 1
	for (var/r in rscList) //r is a file path
		var/fileRef = file(r)
		var/parsedFile = parseAssetLinks(fileRef, r)
		if (parsedFile) //file is text and has been parsed for filepaths
			var/newPath = "data/resources/[r]"
			if (copytext(newPath, -1) != "/" && fexists(newPath)) //"server" already has this file? apparently that causes ~problems~
				fdel(newPath)
			if (text2file(parsedFile, newPath)) //make a new file with the parsed text because byond fucking sucks at sending text as anything besides html
				src << browse_rsc(file(newPath), r)
			else
				world.log << "RESOURCE ERROR: Failed to convert text in '[r]' to a temporary file"
		else //file is binary just throw it at the client as is
			src << browse_rsc(fileRef, r)
		if(i++ % 100 == 0)
			sleep(1)


//A thing for coders locally testing to use (as they might be offline = can't reach the CDN)
/client/proc/loadResources()
	if (cdn || src.resourcesLoaded) return 0
	boutput(src, SPAN_NOTICE("<b>Resources are now loading, browser windows will open normally when complete.</b>"))

	src.loadResourcesFromList(localResources)

	var/s = {"<html>
			<head></head>
			<body>
			<script type="text/javascript">
				window.location='byond://?src=\ref[src];action=resourcePreloadComplete';
			</script>
			</body
			</html>
			"}

	src << browse(s, "window=resourcePreload;titlebar=0;size=1x1;can_close=0;can_resize=0;can_scroll=0;border=0")
	src.resourcesLoaded = 1
	return 1
