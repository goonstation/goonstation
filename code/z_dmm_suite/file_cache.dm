// for retrieving files from the cache by name, initialization may be laggy

var/global/list/file_cache

proc/rebuild_file_cache()
	file_cache = list()
	for(var/i = 0 to 16 ** 6)
		var/addr = BUILD_ADDR("c", i) // c = cache
		var/cached_file = locate(addr)
		if(!cached_file)
			return
		file_cache["[cached_file]"] = cached_file

proc/get_cached_file(name)
	if(!file_cache)
		rebuild_file_cache()
	return file_cache[name]
