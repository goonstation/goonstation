
/// Checks if a filename is a directory in BYOND context (i.e. ends with /)
#define IS_DIR_FNAME(fname) (copytext(fname, length(fname), length(fname) + 1) == "/")

/// Gets the filaname from a filesystem path. Optionally strips extension too
proc/filename_from_path(path, strip_extension=FALSE)
	var/dirs = splittext(path, "/")
	. = dirs[length(dirs)]
	if(strip_extension)
		. = splittext(., ".")[1]

/// Lists all files recursively in a given dir, refer to builtin flist() for details
proc/recursive_flist(dir, list_folders=TRUE)
	if(!IS_DIR_FNAME(dir))
		dir += "/"
	. = list()
	var/list/stack = list(dir)
	while(length(stack))
		var/cur_dir = stack[length(stack)]
		stack.len--
		if(!IS_DIR_FNAME(cur_dir))
			continue
		var/list/cur_flist = flist(cur_dir)
		for(var/filename in cur_flist)
			if(!filename)
				continue
			var/filepath = cur_dir + filename
			if(IS_DIR_FNAME(filename))
				if(list_folders)
					. += filepath
				stack += filepath
			else
				. += filepath
