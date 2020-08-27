//eventually move this to some sort of _std/procs folder

/proc/hasvar(var/datum/A, var/varname)
	if(!A)
		return 0
	return !!A.vars.Find(varname)
