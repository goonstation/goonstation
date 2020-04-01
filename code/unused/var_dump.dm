/*

	var_dump

	Ported from PHP by Gazoot, March 2005.
	http://developer.byond.com/people/Gazoot

	What is it?
	===========
	var_dump is a flexible datum for dumping debug information. It handles pretty much everything,
	from integers to savefiles and even self-referencing objects.


	Quick start
	===========
	Run the demo to see the potential!

	After that, there are four pre-defined procs for you to get started straight away.
	Just put one of those in your code and you're set:

	var_dump(var1, var2, ...)			Dumps information about variables to the output window.
	var_dump_s(var1, var2, ...)			Dumps information, but only one level deep. Useful for quick debugs.
	browser_dump(var1, var2, ...)		Just like var_dump(), but outputs to the browser window.
	browser_dump_s(var1, var2, ...)		Just like var_dump_s(), but outputs to the browser window.


	Customizing the datum
	=====================
	So you want more control over the output? No problem, you can have it. The demo has a verb called "custom_dump"
	which will give you source code for different output formats. But here's how to do it manually:

	1) Create a var_dump object. There are a couple to choose from:

		var_dump/xhtml			output is XHTML 1.0 strict.
		var_dump/html			output is html, suitable for the byond output window.
		var_dump/text			output is plain text

	2) The constructor takes two arguments, depth and brief. (The brief type is only defined for convenience.)

			var/var_dump/xhtml/B = new(depth, brief)

		depth	Is how many levels down in the datums/lists to go before stopping. A mob might reference an obj, which
				references a list of turfs, which references many other objects. The default is 4, which should be
				more than enough. 0 is infinite depth, which can take a long time to process.
				(Sidenote: var_dump_s() uses 1 for depth.)

		brief	If set to 1, make a very brief dump. It skips datum vars completely. Useful for a quick overview
				of a more complex system like a big savefile.

	3) Call the Dump() or ListDump() function to create the output.

			var/output = B.Dump(var1, var2, ...)

		Or if you have your vars in a list:

			var
				mob/M = new
				list/L = list(M.name, M.loc)
				output = B.ListDump(L)

	4) Do with the output whatever you want.

			world << browse(output) 		// Let the whole world browse my data.
			text2file(output, "dump.txt")	// Save it to a file for later examination

	5) Put the above code in your own proc.

		When you are satisfied with the behaviour, make a proc with the above features, give it
		a short name, and you are ready to dump! Look at the pre-defined verbs starting on line 171
		in this file for examples how to do it.


	Next step up
	============
	For those really tough bugs, Deadrons Debugger could be your helping hand. It can be downloaded at:

		http://developer.byond.com/hub/Deadron/Debug


	Anything else?
	==============
	There is one more thing to know, when dumping a datum, the "vars" list won't be dumped. The reason is
	that vars is a list of the datum vars, which is used by var_dump to dump the datum! Even though self-
	referencing checks are made (vars["vars"] = vars), there's no point displaying the exact same
	information again.


	Bugs?
	=====
	So you found a bug? Impossible! Just kidding, please submit them at the forum:

		http://developer.byond.com/forums/Gazoot/var_dump/

	Suggestions and ideas for improving var_dump are also welcome at the forum!

	Thanks for using var_dump!

	/Gazoot


	Version history
	===============

	Version 13
		* Added a var, "deep_list_length" to the var_dump datum, which forces brief output of
		  datums in a list longer than that length.

	Version 12
		* Removed the brief datum. It is better to specify it as an argument in New() instead.
		* Rewrote the output functions for better handling of text.
		* Fixed some depth var bugs.

	Version 11
		* XHTML broke the output window display. There is now a var_dump/xhtml datum which should be
		  used when output should be to the browser. For normal window output, use var_dump/html.
		* Updated the predefined procs to use the new xhtml datum.
		* Updated the demo to include XHTML as well.

	Version 10
		* Html output is now valid XHTML 1.0 strict.
		* Fixed a typo in documentation.

	Version 9
		* Upgraded/modified documentation a bit.
		* Refactored the code for easier implementation of other output formats.
		* When dumping a client, it now says "client" instead of "datum".

	Version 8
		* Documented!

	Version 7
		* Savefile dump now available!
		* Added savefile test and lots of other stuff to the demo.
		* "brief" var added, to display no information about datums, just their name, type and reference.
		  It can be enabled in the var_dump constructor.
		* Added a brief datum to html and text output, for auto-enabling the brief var.
		  (/var_dump/html/brief for example)
		* Sorry, documentation has to wait until v.8. But now it's about the only thing to add.

	Version 6
		* Fixed a small bug in _datum() output.
		* The documentation have to wait until v.7. But hopefully that version will have savefile dumping as well.

	Version 5
		* Added many kinds of dumper datums (Thanks to YMIHere for the suggestion).
		  Until documentation is finished (v.6), look at the procs below to see how they work.

	Version 4
		* Improved the demo a bit more.
		* Moved everything into its own datum, "var_dumper".
		* Reflist is now used for all objects in browser mode, not only for each argument to var_dump().
		* Now all already referenced objects are linked to the original object.
		* Changed the display for associated lists from "=>" to "=", to be more similar to Byonds format.
		* Renamed "shallow" to "depth", to control how many levels to dump.

	Version 3
		* Added color for procs and verbs.
		* Every datum is now displayed with a reference.
		* browser_dump() and browser_dump_s() can now be used to display output in the browser window!
		  The advantage is that the object references are hyperlinked to the original object.
		  The first mob logging into the world will be the target for the browser output.
		  (Just remember to add . = ..() if you're overriding mob/Login().)

	Version 2
		* /client can now be dumped.
		* mob.verbs is now working.
		* Improved the demo.

*/

proc/var_dump()
	if(!args.len) return
	var/var_dump/html/D = new
	var/output = D.ListDump(args)
	boutput(world, output)

proc/var_dump_s()
	if(!args.len) return
	var/var_dump/html/D = new(1)
	var/output = D.ListDump(args)
	boutput(world, output)

proc/browser_dump()
	if(!args.len) return
	var/var_dump/xhtml/D = new
	var/output = D.ListDump(args)
	world << browse(output)

proc/browser_dump_s()
	if(!args.len) return
	var/var_dump/xhtml/D = new(1)
	var/output = D.ListDump(args)
	world << browse(output)

////////////////////////////////////////////////////////////

var_dump

	// depth = how many levels to go down recursive.
	// brief = if 1, display only datum name, type and reference, don't scan for vars in it.
	New(depth = 4, brief = 0)
		src.depth = depth
		src.brief = brief

		src.dump_output = ""

	var
		depth
		deep_list_length = 50

		brief
		dump_output

		list/_reflist

	proc/ListDump(list/Args)
		_reflist = new
		_dump(Args)
		_reflist = null
		return Output()

	proc/Dump()
		return ListDump(args)

	proc/Output()
		return src.dump_output

	proc/_islist(L)
		return (istype(L, /list))

	////////////////////////////////

	proc
		_header()
		_footer()

		_lineheader()
		_linefooter()

	proc/_listinfo(list/L)
		boutput(world, "_listinfo needs to be redefined in its own child class.")

	proc/_text(t, type = null, pos = 0, prefix = "")
		boutput(world, "_text needs to be redefined in its own child class.")

	proc/_datuminfo(datum/D, type, link = 0)
		boutput(world, "_datuminfo needs to be redefined in its own child class.")

	proc/_savefileinfo(savefile/S, link = 0)
		boutput(world, "_savefileinfo needs to be redefined in its own child class.")

	proc/_savefiledir(dir)
		boutput(world, "_savefiledir needs to be redefined in its own child class.")

	////////////////////////////////

	// Main output function, creates an output line.
	proc/_oneline(t, type = null, pos = 0, prefix = "")
		var/text = _text(t, type, prefix)
		src.dump_output += _lineheader(pos) + text + _linefooter()


	// The main loop, which will process all inputs and append header/footer.
	proc/_dump(list/Args)
		src.dump_output = _header()

		src.dump_output += _lineheader(0) + _linefooter()
		for(var/a in Args)
			_input(a)
			src.dump_output += _lineheader(0) + _linefooter()

		src.dump_output += _footer()


	// This proc takes care of all inputs and determines their type.
	proc/_input(a, pos = 0, prefix = "", depth = 0)

		if(istext(a)) _oneline("\"[a]\"", "string", pos, prefix)
		else if(isnum(a)) _oneline(a, "num", pos, prefix)
		else if(isicon(a)) _oneline("'[a]'", "icon", pos, prefix)
		else if(isnull(a)) _oneline("null", "null", pos, prefix)
		else if(isfile(a)) _oneline(a, "file", pos, prefix)
		else if(ispath(a)) _oneline(a, "path", pos, prefix)

		else if(istype(a, /datum) || isclient(a))
			// Test if datum already is referenced.
			if(a in _reflist)
				var/info = _datuminfo(a, _datumtype(a), 1)
				_oneline(info, "self", pos, prefix)
			else if(brief)
				var/info = _datuminfo(a, _datumtype(a))
				_oneline(info, null, pos, prefix)
			else
				_datum(a, pos, prefix, depth)

		else if(istype(a, /savefile))
			// Test if datum already is referenced.
			if(a in _reflist)
				var/info = _savefileinfo(a, 1)
				_oneline(info, "self", pos, prefix)
			else if(brief)
				var/info = _savefileinfo(a)
				_oneline(info, null, pos, prefix)
			else
				_savefile(a, pos, prefix, depth)

		else if(_islist(a)) _list(a, pos, prefix, depth)
		else _oneline("[a]()", "proc", pos, prefix) // Assume that default type is proc for now.


	proc/_savefile_dump(savefile/S, cur_dir, pos, depth)

		var
			a // Temp var for savefile content
			next_pos = pos

		S.cd = cur_dir
		S.eof = 0

		_oneline(_savefiledir(S.cd), null, next_pos)

		while(!S.eof)
			S >> a
			_input(a, next_pos+2, "", depth+1)

		for(var/d in S.dir)
			_savefile_dump(S, d, next_pos+2, depth+1)
			S.cd = ".."

	proc/_savefile(savefile/S, pos = 0, prefix = "", depth = 0)

		var/next_pos = pos

		if(prefix)
			_oneline("[prefix]", null, next_pos)
			next_pos += 2

		_oneline(_savefileinfo(S), null, next_pos)
		next_pos += 2

		_reflist += S

		_savefile_dump(S, "/", next_pos, depth+1)


	proc/_datum(datum/D, pos = 0, prefix = "", depth = 0)

		var
			info
			type = _datumtype(D)
			next_pos = pos

		if(prefix)
			_oneline("[prefix]", null, next_pos)
			next_pos += 2

		_oneline(_datuminfo(D, type), null, next_pos)
		next_pos += 2

		// Add datum to reference list
		_reflist += D

		//output = _text(info, null, pos, prefix)

		// Now start checking out the datum vars.
		var/list/varlist = D.vars.Copy()

		// Remove the vars list from /atom, since it's pretty much selfreferencing the atom.
		varlist.Remove("vars")

		prefix = ""

		for(var/V in varlist)
			prefix = "'[V]' = "

			if(D.vars[V] == D)
				_oneline("self", "self", next_pos, prefix)
			else if(src.depth && depth+1 >= src.depth && (istype(D.vars[V], /datum) || istype(D.vars[V], /client)))

				if(D.vars[V] in _reflist)
					info = _datuminfo(D.vars[V], type, 1)
				else
					info = _datuminfo(D.vars[V], type)

				_oneline(info, null, next_pos, prefix)
			else
				_input(D.vars[V], next_pos, prefix, depth+1)


	proc/_list(list/L, pos = 0, prefix = "", depth = 0)

		// Text, Typ, Position, Prefix

		var/next_pos = pos
		var
			deep = 0
			old_brief

		if(prefix)
			_oneline("[prefix]", null, next_pos)
			next_pos += 2

		_oneline(_listinfo(L), null, next_pos)
		next_pos += 2

		if(L.len > src.deep_list_length)
			old_brief = src.brief
			src.brief = 1
			deep = 1

		var/count = 1
		for(var/content in L)
			// Test for self-referencing
			if(content == L) _oneline("self", "self", next_pos, "'[count]' = ")
			else if(istext(content) && L[content] == L) _oneline("self", "self", next_pos, "'[content]' = ")

			else if(!istext(content))
				_input(content, next_pos, "[count] = ", depth+1)

			else
				_input(L[content], next_pos, "'[content]' = ", depth+1)

			count++

		if(deep)
			src.brief = old_brief

	proc/_datumtype(datum/D)

		// Extract the base type from the type path.
		var/slashpos = findtext("[D.type]", "/", 2)
		var/type = copytext("[D.type]", 2, slashpos)

		switch(type)
			if("area","turf","mob","obj","client","list") return type
			else return "datum"

//////////////////////////////////////////////////

	text
		_text(t, type = null, prefix = "")
			return "[prefix][t]"

		_savefileinfo(savefile/S, link = 0)
			return "savefile([S.name]) \ref[S]"

		_savefiledir(dir)
			return dir

		_datuminfo(datum/D, type, link = 0)
			return "[type]([D.type]) \ref[D]"

		_lineheader(pos)
			var/spaces = ""
			while(pos--)
				spaces += " "

			return spaces

		_linefooter()
			return "<br>"

		_listinfo(list/L)
			return "list"

//////////////////////////////////////////////////

	html
		var/list/_colors = list("string" = "#BB00BB", "num" = "#00BB00", "null" = "#FF0000", "proc" = "#0000BB", \
								"icon" = "#0000FF", "path" = "#BBBB00", "self" = "#00BBBB", "file" = "#FF8C18")

		_savefileinfo(savefile/S, link = 0)
			var/output = "<strong>savefile</strong>([S.name])"
			var/valid_link = copytext("\ref[S]", 2, lentext("\ref[S]"))
			if(link)
				// Make link
				return output + " <a href='#[valid_link]'>\ref[S]</a>"
			else
				// Anchor
				return output + " <a name='[valid_link]'>\ref[S]</a>"

		_savefiledir(dir)
			return "<font color=#FF0000><strong>[dir]</strong></font>"

		_datuminfo(datum/D, type, link = 0)

			var/valid_link = copytext("\ref[D]", 2, lentext("\ref[D]"))

			if(link)
				// Make link
				return "<strong>[type]</strong>(<i>[D.type]</i>) <a href='#[valid_link]'>\ref[D]</a>"
			else
				// Anchor
				return "<strong>[type]</strong>(<i>[D.type]</i>) <a name='[valid_link]'>\ref[D]</a>"

		_text(t, type = null, prefix = "")

			var/color = "#000000"
			if(type) color = _colors[type]

			return "[prefix]<font color='[color]'>[t]</font>"

		_header()
			return "<br>"

		_footer()
			return "<br>"

		_lineheader(pos)

			var/spaces = ""
			while(pos--)
				spaces += "&nbsp;"

			return "<tt>[spaces]"

		_linefooter()
			return "</tt><br>"

		_listinfo(list/L)
			return "<strong>list</strong>"


	xhtml
		var/list/_colors = list("string" = "#BB00BB", "num" = "#00BB00", "null" = "#FF0000", "proc" = "#0000BB", \
								"icon" = "#0000FF", "path" = "#BBBB00", "self" = "#00BBBB", "file" = "#FF8C18")

		_savefileinfo(savefile/S, link = 0)
			var/output = "<strong>savefile</strong>([S.name])"
			var/valid_link = copytext("\ref[S]", 2, lentext("\ref[S]"))
			if(link)
				// Make link
				return output + " <a href='#[valid_link]'>\ref[S]</a>" + ascii2text(13) + ascii2text(10)
			else
				// Anchor
				return output + " <a name='[valid_link]'>\ref[S]</a>" + ascii2text(13) + ascii2text(10)

		_savefiledir(dir)
			return "<span style='color:#FF0000;'><strong>[dir]</strong></span>"

		_datuminfo(datum/D, type, link = 0)

			var/valid_link = copytext("\ref[D]", 2, lentext("\ref[D]"))

			if(link)
				// Make link
				return "<strong>[type]</strong>(<i>[D.type]</i>) <a href='#[valid_link]'>\ref[D]</a>" + ascii2text(13) + ascii2text(10)
			else
				// Anchor
				return "<strong>[type]</strong>(<i>[D.type]</i>) <a name='[valid_link]'>\ref[D]</a>" + ascii2text(13) + ascii2text(10)

		_text(t, type = null, prefix = "")

			var/color = ""
			if(type) color = " style='color:[_colors[type]];'"

			return "[prefix]<span[color]>[t]</span>"

		_header()
			var/linebreak = ascii2text(13) + ascii2text(10)
			return "\
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'>[linebreak]\
<html xmlns='http://www.w3.org/1999/xhtml' lang='en' xml:lang='en'>[linebreak]\
<head><title>var_dump output</title></head>[linebreak]\
<body><div style='font-family: courier new, courier, monotype; font-size:10pt;'>[linebreak]"

		_footer()
			var/linebreak = ascii2text(13) + ascii2text(10)
			return "[linebreak]</div></body></html>"

		_lineheader(pos)
			var/spaces = ""
			while(pos--)
				spaces += "&nbsp;"

			return spaces

		_linefooter()
			return "<br>" + ascii2text(13) + ascii2text(10)

		_listinfo(list/L)
			return "<strong>list</strong>"
