

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

	proc/list2text(list/l, d = "")
		#ifdef DEBUG
		ASSERT(istype(l))
		#endif
		if(d)
			if(l.len <= 10)
				return "[(l.len >= 1) ? l[1] : ""][(l.len > 1) ? d : ""][(l.len >= 2) ? l[2] : ""][(l.len > 2) ? d : ""][(l.len >= 3) ? l[3] : ""][(l.len > 3) ? d : ""][(l.len >= 4) ? l[4] : ""][(l.len > 4) ? d : ""][(l.len >= 5) ? l[5] : ""][(l.len > 5) ? d : ""][(l.len >= 6) ? l[6] : ""][(l.len > 6) ? d : ""][(l.len >= 7) ? l[7] : ""][(l.len > 7) ? d : ""][(l.len >= 8) ? l[8] : ""][(l.len > 8) ? d : ""][(l.len >= 9) ? l[9] : ""][(l.len > 9) ? d : ""][(l.len >= 10) ? l[10] : ""][(l.len > 10) ? d : ""]"
			else if(l.len <= 20)
				var/list/remainder = l.Copy(11)
				return "[l[1]][d][l[2]][d][l[3]][d][l[4]][d][l[5]][d][l[6]][d][l[7]][d][l[8]][d][l[9]][d][l[10]][d][list2text(remainder, d)]"
			else if(l.len <= 40)
				var/list/remainder = l.Copy(21)
				return "[l[1]][d][l[2]][d][l[3]][d][l[4]][d][l[5]][d][l[6]][d][l[7]][d][l[8]][d][l[9]][d][l[10]][d][l[11]][d][l[12]][d][l[13]][d][l[14]][d][l[15]][d][l[16]][d][l[17]][d][l[18]][d][l[19]][d][l[20]][d][list2text(remainder, d)]"
			else if(l.len <= 80)
				var/list/remainder = l.Copy(41)
				return "[l[1]][d][l[2]][d][l[3]][d][l[4]][d][l[5]][d][l[6]][d][l[7]][d][l[8]][d][l[9]][d][l[10]][d][l[11]][d][l[12]][d][l[13]][d][l[14]][d][l[15]][d][l[16]][d][l[17]][d][l[18]][d][l[19]][d][l[20]][d][l[21]][d][l[22]][d][l[23]][d][l[24]][d][l[25]][d][l[26]][d][l[27]][d][l[28]][d][l[29]][d][l[30]][d][l[31]][d][l[32]][d][l[33]][d][l[34]][d][l[35]][d][l[36]][d][l[37]][d][l[38]][d][l[39]][d][l[40]][d][list2text(remainder, d)]"
			else if(l.len <= 160)
				var/list/remainder = l.Copy(81)
				return "[l[1]][d][l[2]][d][l[3]][d][l[4]][d][l[5]][d][l[6]][d][l[7]][d][l[8]][d][l[9]][d][l[10]][d][l[11]][d][l[12]][d][l[13]][d][l[14]][d][l[15]][d][l[16]][d][l[17]][d][l[18]][d][l[19]][d][l[20]][d][l[21]][d][l[22]][d][l[23]][d][l[24]][d][l[25]][d][l[26]][d][l[27]][d][l[28]][d][l[29]][d][l[30]][d][l[31]][d][l[32]][d][l[33]][d][l[34]][d][l[35]][d][l[36]][d][l[37]][d][l[38]][d][l[39]][d][l[40]][d][l[41]][d][l[42]][d][l[43]][d][l[44]][d][l[45]][d][l[46]][d][l[47]][d][l[48]][d][l[49]][d][l[50]][d][l[51]][d][l[52]][d][l[53]][d][l[54]][d][l[55]][d][l[56]][d][l[57]][d][l[58]][d][l[59]][d][l[60]][d][l[61]][d][l[62]][d][l[63]][d][l[64]][d][l[65]][d][l[66]][d][l[67]][d][l[68]][d][l[69]][d][l[70]][d][l[71]][d][l[72]][d][l[73]][d][l[74]][d][l[75]][d][l[76]][d][l[77]][d][l[78]][d][l[79]][d][l[80]][d][list2text(remainder, d)]"
			else
				var/list/remainder = l.Copy(161)
				return "[l[1]][d][l[2]][d][l[3]][d][l[4]][d][l[5]][d][l[6]][d][l[7]][d][l[8]][d][l[9]][d][l[10]][d][l[11]][d][l[12]][d][l[13]][d][l[14]][d][l[15]][d][l[16]][d][l[17]][d][l[18]][d][l[19]][d][l[20]][d][l[21]][d][l[22]][d][l[23]][d][l[24]][d][l[25]][d][l[26]][d][l[27]][d][l[28]][d][l[29]][d][l[30]][d][l[31]][d][l[32]][d][l[33]][d][l[34]][d][l[35]][d][l[36]][d][l[37]][d][l[38]][d][l[39]][d][l[40]][d][l[41]][d][l[42]][d][l[43]][d][l[44]][d][l[45]][d][l[46]][d][l[47]][d][l[48]][d][l[49]][d][l[50]][d][l[51]][d][l[52]][d][l[53]][d][l[54]][d][l[55]][d][l[56]][d][l[57]][d][l[58]][d][l[59]][d][l[60]][d][l[61]][d][l[62]][d][l[63]][d][l[64]][d][l[65]][d][l[66]][d][l[67]][d][l[68]][d][l[69]][d][l[70]][d][l[71]][d][l[72]][d][l[73]][d][l[74]][d][l[75]][d][l[76]][d][l[77]][d][l[78]][d][l[79]][d][l[80]][d][l[81]][d][l[82]][d][l[83]][d][l[84]][d][l[85]][d][l[86]][d][l[87]][d][l[88]][d][l[89]][d][l[90]][d][l[91]][d][l[92]][d][l[93]][d][l[94]][d][l[95]][d][l[96]][d][l[97]][d][l[98]][d][l[99]][d][l[100]][d][l[101]][d][l[102]][d][l[103]][d][l[104]][d][l[105]][d][l[106]][d][l[107]][d][l[108]][d][l[109]][d][l[110]][d][l[111]][d][l[112]][d][l[113]][d][l[114]][d][l[115]][d][l[116]][d][l[117]][d][l[118]][d][l[119]][d][l[120]][d][l[121]][d][l[122]][d][l[123]][d][l[124]][d][l[125]][d][l[126]][d][l[127]][d][l[128]][d][l[129]][d][l[130]][d][l[131]][d][l[132]][d][l[133]][d][l[134]][d][l[135]][d][l[136]][d][l[137]][d][l[138]][d][l[139]][d][l[140]][d][l[141]][d][l[142]][d][l[143]][d][l[144]][d][l[145]][d][l[146]][d][l[147]][d][l[148]][d][l[149]][d][l[150]][d][l[151]][d][l[152]][d][l[153]][d][l[154]][d][l[155]][d][l[156]][d][l[157]][d][l[158]][d][l[159]][d][l[160]][d][list2text(remainder, d)]"
		else
			if(l.len <= 10)
				return "[(l.len >= 1) ? l[1] : ""][(l.len >= 2) ? l[2] : ""][(l.len >= 3) ? l[3] : ""][(l.len >= 4) ? l[4] : ""][(l.len >= 5) ? l[5] : ""][(l.len >= 6) ? l[6] : ""][(l.len >= 7) ? l[7] : ""][(l.len >= 8) ? l[8] : ""][(l.len >= 9) ? l[9] : ""][(l.len >= 10) ? l[10] : ""]"
			else if(l.len <= 20)
				var/list/remainder = l.Copy(11)
				return "[l[1]][l[2]][l[3]][l[4]][l[5]][l[6]][l[7]][l[8]][l[9]][l[10]][list2text(remainder)]"
			else if(l.len <= 40)
				var/list/remainder = l.Copy(21)
				return "[l[1]][l[2]][l[3]][l[4]][l[5]][l[6]][l[7]][l[8]][l[9]][l[10]][l[11]][l[12]][l[13]][l[14]][l[15]][l[16]][l[17]][l[18]][l[19]][l[20]][list2text(remainder)]"
			else if(l.len <= 80)
				var/list/remainder = l.Copy(41)
				return "[l[1]][l[2]][l[3]][l[4]][l[5]][l[6]][l[7]][l[8]][l[9]][l[10]][l[11]][l[12]][l[13]][l[14]][l[15]][l[16]][l[17]][l[18]][l[19]][l[20]][l[21]][l[22]][l[23]][l[24]][l[25]][l[26]][l[27]][l[28]][l[29]][l[30]][l[31]][l[32]][l[33]][l[34]][l[35]][l[36]][l[37]][l[38]][l[39]][l[40]][list2text(remainder)]"
			else if(l.len <= 160)
				var/list/remainder = l.Copy(81)
				return "[l[1]][l[2]][l[3]][l[4]][l[5]][l[6]][l[7]][l[8]][l[9]][l[10]][l[11]][l[12]][l[13]][l[14]][l[15]][l[16]][l[17]][l[18]][l[19]][l[20]][l[21]][l[22]][l[23]][l[24]][l[25]][l[26]][l[27]][l[28]][l[29]][l[30]][l[31]][l[32]][l[33]][l[34]][l[35]][l[36]][l[37]][l[38]][l[39]][l[40]][l[41]][l[42]][l[43]][l[44]][l[45]][l[46]][l[47]][l[48]][l[49]][l[50]][l[51]][l[52]][l[53]][l[54]][l[55]][l[56]][l[57]][l[58]][l[59]][l[60]][l[61]][l[62]][l[63]][l[64]][l[65]][l[66]][l[67]][l[68]][l[69]][l[70]][l[71]][l[72]][l[73]][l[74]][l[75]][l[76]][l[77]][l[78]][l[79]][l[80]][list2text(remainder)]"
			else
				var/list/remainder = l.Copy(161)
				return "[l[1]][l[2]][l[3]][l[4]][l[5]][l[6]][l[7]][l[8]][l[9]][l[10]][l[11]][l[12]][l[13]][l[14]][l[15]][l[16]][l[17]][l[18]][l[19]][l[20]][l[21]][l[22]][l[23]][l[24]][l[25]][l[26]][l[27]][l[28]][l[29]][l[30]][l[31]][l[32]][l[33]][l[34]][l[35]][l[36]][l[37]][l[38]][l[39]][l[40]][l[41]][l[42]][l[43]][l[44]][l[45]][l[46]][l[47]][l[48]][l[49]][l[50]][l[51]][l[52]][l[53]][l[54]][l[55]][l[56]][l[57]][l[58]][l[59]][l[60]][l[61]][l[62]][l[63]][l[64]][l[65]][l[66]][l[67]][l[68]][l[69]][l[70]][l[71]][l[72]][l[73]][l[74]][l[75]][l[76]][l[77]][l[78]][l[79]][l[80]][l[81]][l[82]][l[83]][l[84]][l[85]][l[86]][l[87]][l[88]][l[89]][l[90]][l[91]][l[92]][l[93]][l[94]][l[95]][l[96]][l[97]][l[98]][l[99]][l[100]][l[101]][l[102]][l[103]][l[104]][l[105]][l[106]][l[107]][l[108]][l[109]][l[110]][l[111]][l[112]][l[113]][l[114]][l[115]][l[116]][l[117]][l[118]][l[119]][l[120]][l[121]][l[122]][l[123]][l[124]][l[125]][l[126]][l[127]][l[128]][l[129]][l[130]][l[131]][l[132]][l[133]][l[134]][l[135]][l[136]][l[137]][l[138]][l[139]][l[140]][l[141]][l[142]][l[143]][l[144]][l[145]][l[146]][l[147]][l[148]][l[149]][l[150]][l[151]][l[152]][l[153]][l[154]][l[155]][l[156]][l[157]][l[158]][l[159]][l[160]][list2text(remainder)]"
