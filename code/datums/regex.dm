/**
 *	Unlike the standard regex `Replace` function, `ReplaceWithCallback` uses a callback datum to enable object procs to be
 *	called, allowing for the replacement proc to access variables on the parent object. The use of a callback datum also
 *	enables arguments to be passed to the replacement proc.
 */
/regex/proc/ReplaceWithCallback(string, datum/callback/callback, start = 1, end = 0)
	src.next = start
	callback.arguments ||= list()
	callback.arguments.Insert(1, null)

	while (src.Find(string, src.next, end))
		if (!src.match)
			continue

		callback.arguments[1] = src.match
		var/replacement_string = callback.Invoke()

		string = splicetext(string, src.index, src.next, replacement_string)
		src.next += (length(replacement_string) - length(src.match))

	return string
