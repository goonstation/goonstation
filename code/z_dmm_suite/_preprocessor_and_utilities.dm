

//-- Notes to developer for future versions ------------------------------------
/*
Reader:
	Optimize by only loading attributes for each model once.
		Not sure how that would interact with new lists (map editor allows lists as attribute values)

Writer:
	Maps cannot save newlines in string variable values!
	Movable Atoms can have paths in their contents!
	Instances of /Area from the map editor
	cacheFiles

Both:
	Use the coordinates provided by the DMM format (1,1,1) = {""} to determine map loading locationg.
	Why didn't I do this in the first place? Like, really, why? I knew this existed... so I must have
	had a reason to go with map comments, right?
*/

//#define DIAG(X) world << {"<span style="color:red">[__FILE__]:[__LINE__]:: [X]</span>"};

//client/Center() world.Reboot()

//-- Preprocessor --------------------------------------------------------------

// moved to _dmm_suite.dm


//-- Text / List Utilities - From Forum_account.Text ---------------------------

dmm_suite
	var/debug_id

	New(debug_id=null)
		..()
		src.debug_id = debug_id

	proc/text2list(splitString, delimiter)
		#ifdef DEBUG
		ASSERT(istext(splitString))
		ASSERT(istext(delimiter))
		ASSERT(delimiter)
		#endif
		var delimiterLength = length(delimiter)
		var pos = findtextEx(splitString, delimiter)
		var start = 1
		. = list()
		while(pos > 0)
			. += copytext(splitString, start, pos)
			start = pos + delimiterLength
			pos = findtextEx(splitString, delimiter, start)
		. += copytext(splitString, start)
