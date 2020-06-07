// for retrieving files from the cache by name, initialization may be laggy

var/global/list/file_cache

proc/rebuild_file_cache()
	file_cache = list()
	for(var/i = 0 to 16 ** 6)
		var/addr = num2text(i, 0, 16)
		switch(length(addr))
			if(1)
				addr = "\[0xc00000[addr]\]"
			if(2)
				addr = "\[0xc0000[addr]\]"
			if(3)
				addr = "\[0xc000[addr]\]"
			if(4)
				addr = "\[0xc00[addr]\]"
			if(5)
				addr = "\[0xc0[addr]\]"
			if(6)
				addr = "\[0xc[addr]\]"
		var/cached_file = locate(addr)
		if(!cached_file)
			return
		file_cache["[cached_file]"] = cached_file

proc/get_cached_file(name)
	if(!file_cache)
		rebuild_file_cache()
	return file_cache[name]
