//CONTENTS
//User shell


//User shell program
//Allows execution of various mainframe programs, as well as some scripting and a set of built-in commands.
/datum/computer/file/mainframe_program/shell
	name = "Msh"
	size = 8
	executable = 0
	var/tmp/piping = 0
	var/tmp/pipetemp = ""

	var/tmp/scriptline = 0
	var/tmp/list/shscript
	var/tmp/list/scriptvars
	var/tmp/scriptstat = 0
	var/tmp/script_iteration = 0

	var/tmp/list/stack = list()
	var/tmp/previous_pipeout
	var/tmp/suppress_out = 0

	var/tmp/scriptprocess = 0	//ID of child shell handling a script.

	var/setup_helprec_name = "help"
	var/setup_max_piped_commands = 16

#define SCRIPT_IF_TRUE		1
#define SCRIPT_IN_LOOP		2
#define SCRIPT_IN_PROCESS	4
#define MAX_SCRIPT_COMPLEXITY 2048
#define MAX_SCRIPT_ITERATIONS 128
#define MAX_STACK_DEPTH 128

#define EVAL_BOOL_TRUE 1
#define EVAL_BOOL_FALSE 0
#define ERR_STACK_OVER -1
#define ERR_STACK_UNDER -2
#define ERR_UNDEFINED -3

	initialize(list/supplied_config)
		if(..() || !useracc)
			return

		previous_pipeout = null

		piping = 0
		suppress_out = 0
		pipetemp = ""
		scriptline = 0
		if (istype(supplied_config) && length(supplied_config) >= 3)
			script_iteration = supplied_config[1]
			scriptvars = supplied_config[2]
			shscript = supplied_config[3]
		else
			script_iteration = 0

		scriptstat = 0
		if (!istype(scriptvars))
			scriptvars = list()

		if (!istype(shscript))
			shscript = list()

		if (useracc.user_file && !script_iteration)
			if(!read_user_field("name"))
				write_user_field("name", useracc.user_name)
			useracc.user_file.fields["curpath"] = "/home/usr[read_user_field("name")]"

		if (!script_iteration)
			message_user("[read_user_field("name")]@DWAINE - [time2text(world.realtime, "hh:mm MM/DD/53")]|nType \"help\" for command listing.", "multiline")

		process()
		return

	process()
		if (..() || !useracc)
			return

		if (script_iteration)
			script_process()
		return


	input_text(var/text)
//		boutput(world, "input_text([text], [script_iteration])")
		if(..() || !useracc)
			return 1

		var/list/subcommands = list()
		var/list/piped_list = command2list(text, "^", scriptvars, subcommands)//scripting ? scriptvars : null)
		piped_list.len = min(piped_list.len, setup_max_piped_commands)
		piping = length(piped_list)
		pipetemp = ""
		var/script_counter = 0
		//script_iteration = 0//reset stack each time someone types stuff

		while(piped_list.len && (script_counter < MAX_SCRIPT_COMPLEXITY))
			script_counter++
			text = piped_list[1]
			piped_list -= piped_list[1]
			piping--

			var/subPlace = findtext(text, "_sub")

			while (subPlace)

				var/subIndex = text2num_safe( copytext( text, subPlace+4, subPlace+5) )

				if (isnum(subIndex) && subIndex > 0 && subIndex <= subcommands.len)

					previous_pipeout = ""
					suppress_out = 1
					if (!input_text(subcommands[subIndex], 0))

						if (dd_hassuffix(previous_pipeout, "|n"))
							previous_pipeout = copytext(previous_pipeout, 1, -2)

						text = "[copytext(text, 1, subPlace)][previous_pipeout][copytext(text, subPlace+5)]"
						//boutput(world, " --> \"[text]\"")
						suppress_out = 0


					else
						suppress_out = 0
						return 1
				else
					return 1
				subPlace = findtext(text, "_sub")

			//var/list/command_list = parse_string(text, (script_iteration ? src.scriptvars : null))
			var/list/command_list = parse_string(text, src.scriptvars)
			var/command = lowertext(command_list[1])
			command_list.Cut(1,2) //Remove the command that we are now processing.
			while (!command && length(command_list))
				command = command_list[1]
				command_list.Cut(1,2)

			var/current = read_user_field("curpath")

			if (!dd_hassuffix(current, "/") && current != "/")
				current = "[current]/"

			if (execpath("/bin/[command]", current, command, command_list, script_iteration))
				continue

			else
				switch(execpath("[current][dd_hasprefix(command,"/") ? copytext(command, 1) : command]", current, command, command_list, script_iteration))
					if (1)
						continue
					if (2)
						message_user("Error: Unable to execute script.")
						return 1
					if (3)
						message_user("Error: Stack overflow.")
						return 1

				switch(lowertext(command))
					if ("eval")
						var/result = null
						var/pipe_result = (length(command_list) == 1)

						if (!command_list.len)
							continue

						if (stack)
							stack.len = 0
						else
							stack = list()

						switch (script_evaluate2(command_list, 0))
							if (0,1)
								if (stack.len)
									result = stack[stack.len]
								else
									result = 0


							if (ERR_STACK_OVER)
								message_user("Error: Stack overflow.")
								return 1

							if (ERR_STACK_UNDER)
								message_user("Error: Stack underflow.")
								return 1

							if (ERR_UNDEFINED)
								message_user("Error: Undefined result.")

								return 1

						if (piping && pipe_result)
							pipetemp = "[result]"

						else if (!script_iteration && !isnull(result))
							message_user("[result]")

						continue

					if ("goonsay")
						var/anger_text = null
						if (pipetemp)
							anger_text = pipetemp

						if(istype(command_list) && (length(command_list) > 0))
							anger_text += jointext(command_list, " ")

						if (piping && piped_list.len && (ckey(piped_list[1]) != "break") )
							pipetemp = anger_text
						else
							if (!anger_text)
								anger_text = "A clown? On a space station? what|n"
							else if (!dd_hassuffix(anger_text, "|n"))
								anger_text += "|n"
							message_user("[anger_text] __________|n(--\[ .]-\[ .] /|n(_______0__)", "multiline")
						continue


					if ("echo")
						var/echo_text = null
						if (pipetemp)
							echo_text = pipetemp

						var/add_newline = TRUE

						if(istype(command_list) && (length(command_list) > 0))
							if (command_list[1] == "-n")
								add_newline = FALSE
								command_list.Cut(1,2)
							echo_text += jointext(command_list, " ")

						if (piping && piped_list.len && (ckey(piped_list[1]) != "break") )
							pipetemp = echo_text
						else
							if (echo_text && add_newline && !dd_hassuffix(echo_text, "|n"))
								echo_text += "|n"
							message_user(echo_text, "multiline")

						continue

					//User identification & communication commands

					if ("who")
						var/whotext = null
						var/list/wholist = signal_program(1, list("command"=DWAINE_COMMAND_ULIST))

						if (istype(wholist))
							for (var/uid in wholist)
								whotext += "[uid]-[wholist[uid]]|n"
						else
							whotext = "Error: Unable to determine current users."

						if (piping)
							pipetemp = whotext
						else
							if (!whotext)
								whotext = "Error: Unable to determine current users."

							message_user(whotext, "multiline")
						continue

					if ("mesg")
						var/input = (command_list.len ? command_list[1] : null)
						if (pipetemp)
							input = pipetemp

						if (piping)
							if (input)
								switch (lowertext(input))
									if ("y")
										if (write_user_field("accept_msg","1"))
											pipetemp = "Now allowing messages."
										else
											pipetemp = "Error: Unable to write user configuration."
									if ("n")
										if (write_user_field("accept_msg","0"))
											pipetemp = "Now disallowing messages."
										else
											pipetemp = "Error: Unable to write user configuration."
									else
										pipetemp = "Error: Invalid argument for mesg (Must be \"y\" or \"n\")"
							else
								pipetemp = "is [read_user_field("accept_msg") == "1" ? "y" : "n"]"
						else
							if (input)
								switch (lowertext(input))
									if ("y")
										if (write_user_field("accept_msg","1"))
											message_user("Now allowing messages.")
										else
											message_user("Error: Unable to write user configuration.")
									if ("n")
										if (write_user_field("accept_msg","0"))
											message_user("Now disallowing messages.")
										else
											message_user("Error: Unable to write user configuration.")
									else
										message_user("Error: Invalid argument for mesg (Must be \"y\" or \"n\")")
							else
								message_user("is [read_user_field("accept_msg") == "1" ? "y" : "n"]")

						continue

					if ("talk")
						if (pipetemp)

							if(istype(command_list))
								command_list += splittext(pipetemp, " ")

						if (length(command_list) < 2)
							message_user("Error: Insufficient arguments for Talk (Requires Target ID and Message).")
							return 1

						var/targetUser = lowertext(command_list[1])
						command_list.Cut(1,2)

						switch (signal_program(1, list("command"=DWAINE_COMMAND_UMSG, "term"=targetUser, data=jointext(command_list, " "))))
							if (ESIG_SUCCESS)
								continue
							if (ESIG_NOTARGET)
								message_user("Error: Invalid Target ID")
								return 1
							if (ESIG_IOERR)
								if (piping)
									pipetemp = "Error: Message refused by Target."
								else
									message_user("Error: Message refused by Target.")
								continue
							else
								message_user("Error: Unexpected response from kernel.")
								return 1

						continue
					if ("cls", "clear")
						message_user("Screen cleared.", "clear")
						continue
					//SCRIPTING COMMANDS FOLLOW:
					//If - Evaluate an expression.  If true, set SCRIPT_IF_TRUE in scriptstat and continue piping
					//if false, unset SCRIPT_IF_TRUE and continue to the next line
					//if null (From an evaluation error or invalid input), halt the script
					if ("if")

						if (!command_list.len)
							return 1

						switch (script_evaluate2(command_list, 1))
							if (1)
								pipetemp = null
								scriptstat |= SCRIPT_IF_TRUE
								var/elsePosition = piped_list.Find("else")
								if (elsePosition)
									piped_list.Cut(elsePosition)
									piping = length(piped_list)
								continue //Continue processing any piped commands following this.
							if (0)
								scriptstat &= ~SCRIPT_IF_TRUE

								var/elsePosition = piped_list.Find("else")
								if (elsePosition)
									piped_list.Cut(1,elsePosition+1)
									piping = length(piped_list)
									pipetemp = null
									continue

								return 0 //Move to the next line of the script, dropping any following commands on this line.
							if (null)
								return 1

					if ("else")

						if (scriptstat & SCRIPT_IF_TRUE)
							return 0

						continue

					if ("while")
						if (!command_list.len || (scriptstat & SCRIPT_IN_LOOP))
							return 1

						switch (script_evaluate2(command_list, 1))
							if (1)
								scriptstat |= SCRIPT_IN_LOOP
								continue
							if (0)
								scriptstat &= ~SCRIPT_IN_LOOP
								return 0
							else
								return 1

					if ("break")
						return 1

					if ("sleep")
						if (!command_list.len)
							continue

						. = text2num_safe(command_list[1])
						if (!isnum(.) || . < 0)
							continue

						sleep(clamp(., 0, 30) SECONDS)
						continue

					if ("unset")
						if (!length(command_list))
							scriptvars = list()
							continue
						for (var/V in command_list)
							if (lowertext(ckeyEx(V)) in scriptvars)
								scriptvars -= lowertext(ckeyEx(V))
						continue

					if ("help", "man")
						var/datum/computer/file/record/helpRec = signal_program(1, list("command"=DWAINE_COMMAND_CONFGET,"fname"=setup_helprec_name))
						if (istype(helpRec))
							var/target_entry = "index"
							if (command_list.len && ckey(command_list[1]))
								target_entry = lowertext(command_list[1])

							if (target_entry in helpRec.fields)
								message_user("[capitalize(target_entry)]: [helpRec.fields[target_entry]]", "multiline")
							else
								message_user("Error: Unknown topic.")
						else
							message_user("Error: Help library missing or invalid.")

						continue

					if ("logout","logoff")
						message_user("Thank you for using DWAINE!", "clear")
						if (scriptprocess)
							signal_program(1, list("command"=DWAINE_COMMAND_TKILL,"target"=scriptprocess))
							scriptprocess = 0

						mainframe_prog_exit
						return 1

					else
						if (pipetemp)
							var/prefixroot = dd_hasprefix(command, "/")
							if (!prefixroot)
								command = "[current]" + ((dd_hassuffix(current, "/") || current == "/") ? null : "/") + command

							var/list/templist = splittext(command, "/")
							if (!templist.len)
								message_user("Syntax error.")
								break

							var/recname = null
							recname = copytext(templist[templist.len], 1, 16)
							while (dd_hasprefix(recname, " "))
								recname = copytext(recname, 2)
							templist.len--
							command = jointext(templist, "/")
							if (!recname)
								recname = "out"

							if ((prefixroot || !command) && !dd_hasprefix(command, "/"))
								command = "/[command]"

							//boutput(world, "here is the path: \"[command]\" and the name \"[recname]\"")
							var/datum/computer/file/record/rec = new /datum/computer/file/record(  )
							rec.fields = splittext(pipetemp, "|n")
							rec.name = recname
							rec.metadata["owner"] = read_user_field("name")
							rec.metadata["permission"] = COMP_ALLACC

							if (signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"=command, "append"=1), rec) != ESIG_SUCCESS)
								message_user("Unable to pipe stream to file.")
								//qdel(rec)
								rec.dispose()
								break

							continue


						message_user("Syntax error.")
						return 1

		//message_user("[dirpath]$ " + text)
		previous_pipeout += pipetemp
		return 0

	proc
		execpath(var/fpath, var/current, var/command, var/list/command_list, var/scripting=0)
//			boutput(world, "execpath([fpath], [current], [command], ,[scripting])")
			var/datum/computer/file/record/exec = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"=fpath))
			if (istype(exec, /datum/computer/file/mainframe_program))
				var/list/siglist = list("command"=DWAINE_COMMAND_TSPAWN, "passusr"=1, "path"=fpath)//"[current][command]")
				if (command_list.len)
					siglist["args"] = strip_html(jointext(command_list, " ")) + (pipetemp ? " [pipetemp]" : null)
				else if (pipetemp)
					siglist["args"] = pipetemp

				pipetemp = ""
				var/datum/computer/file/mainframe_program/toRun = signal_program(1, siglist)
				if (istype(toRun))
					scriptprocess = toRun.progid

				//qdel(siglist)
				return 1

			else if (istype(exec) && (!pipetemp || scripting) && exec.fields && (length(exec.fields) > 1) && dd_hasprefix(exec.fields[1], "#!")) //Maybe it's a shell script?

				if (script_iteration + 1 >= MAX_SCRIPT_ITERATIONS)
					return 3

				var/list/scriptvarsToPass = list("$"=src.progid,"su"=read_user_field("group") == 0)
				. = ""
				for (var/i = 1, i <= command_list.len && i <= 8, i++)
					scriptvarsToPass["arg[i-1]"] = command_list[i]
					. += "[. ? " " : null][command_list[i]]"

				scriptvarsToPass["*"] = .
				scriptvarsToPass["argc"] = length(command_list)

				var/list/childScript = script_format( exec.fields.Copy() )
				//boutput(world, "bloop script loaded, pip")

				scriptprocess = signal_program(1, list("command"=DWAINE_COMMAND_TFORK,"args"=list(script_iteration+1, scriptvarsToPass, childScript)))
				if (scriptprocess & ESIG_DATABIT)
					scriptprocess &= ~ESIG_DATABIT
					return 1

				scriptprocess = 0
				return 2

			return 0

		script_process()

			for (var/i = 1, i <= 5 && shscript.len, i++)
				if (src.input_text(shscript[1], script_iteration))
					message_user("Break at line [scriptline+1]")

					if (scriptprocess)
						signal_program(1, list("command"=DWAINE_COMMAND_TKILL,"target"=scriptprocess))
						scriptprocess = 0

					if (parent_id && pipetemp)
						message_user(pipetemp)

					mainframe_prog_exit
					return 1

				if (scriptstat & SCRIPT_IN_LOOP)
					scriptstat &= ~SCRIPT_IN_LOOP	//Turn off loop flag after the line is over
					continue

				if (shscript.len)
					shscript.Cut(1,2)

				scriptline++

			scriptline = (shscript.len) ? scriptline : 0
				//sleep(1 SECOND)
			if (!shscript.len && !scriptprocess)

//				if (scriptprocess)
//					signal_program(1, list("command"=DWAINE_COMMAND_TKILL,"target"=scriptprocess))
//					scriptprocess = 0


				if (parent_id && pipetemp)
					message_user(pipetemp)

				mainframe_prog_exit
				//scriptstat &= ~SCRIPT_IN_PROCESS
			return

		script_format(var/list/scriptlist)
			if (!scriptlist || length(scriptlist) < 2)
				return list()

			//The first line should just be #!, so...
			scriptlist.Cut(1,2) //Don't need to copy the whole shebang, ha ha get it??

			for (var/i = 1, i <= scriptlist.len, i++)
				//Check if it's a comment line...
				if (dd_hasprefix(trim_left(scriptlist[i]), "#"))
					scriptlist.Cut(i, i+1)
					i--
					continue
				scriptlist[i] = replacetext(scriptlist[i], "|", "^")

			return scriptlist

		//Something something immersion something something 32-bit signed someting fixed point something.
		script_clampvalue(var/clampnum)
			//return round( min( max(text2num_safe(clampnum), -2147483647), 2147483648) ) // good riddance
			return round( clamp(clampnum, -2147483647, 2147483600), 0.01 ) // 2147483648

		script_isNumResult(var/current, var/result)

			if (isnum(text2num_safe(current)) && isnum(text2num_safe(result)))
				return 1

			return 0

		script_evaluate2(var/list/command_stream, return_bool)

			stack.len = 0
			while (length(command_stream))
				var/current_command = command_stream[1]
				//boutput(world, "current_command = \[[current_command]]")
				command_stream.Cut(1,2)

				if (text2num_safe(current_command) != null)
					if (length(stack) > MAX_STACK_DEPTH)
						return ERR_STACK_OVER

					stack += script_clampvalue( text2num_safe(current_command) )
					continue

				var/result = null

				switch ( lowertext(current_command) )
					if ("+") //(1X 2X -- (1X + 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							result = text2num_safe(stack[stack.len]) + text2num_safe(stack[stack.len-1])
							stack[--stack.len] = script_clampvalue( result )

						else
							result = "[stack[stack.len-1] ][ stack[stack.len] ]"
							stack[--stack.len] = result

					if ("-") //(1X 2X -- (1X - 2X)
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							result = stack[stack.len-1] - stack[stack.len]
							stack[--stack.len] = script_clampvalue( result )

						else if (istext(stack[stack.len-1]) && isnum(stack[stack.len]))
							result = copytext(stack[stack.len-1], 1, max( length(stack[stack.len-1]) - stack[stack.len],   1) )
							stack[--stack.len] = result

						else
							return ERR_UNDEFINED

					if ("*") //(1X 2X -- (1X * 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							result = stack[stack.len-1] * stack[stack.len]
							stack[--stack.len] = script_clampvalue( result )

						else if (istext(stack[stack.len-1]) && isnum(stack[stack.len]))
							result = ""
							var/repeatCount = stack[stack.len]
							while (repeatCount-- > 0)
								result += "[stack[stack.len-1]]"

							stack[--stack.len] = copytext(result, 1, MAX_MESSAGE_LEN)

						else
							return ERR_UNDEFINED

					if ("/") //(1X 2X -- (1X / 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							if (stack[stack.len] == 0)
								return ERR_UNDEFINED

							result = stack[stack.len-1] / stack[stack.len]
							stack[--stack.len] = script_clampvalue( result )

						else if (istext(stack[stack.len]) && istext(stack[stack.len-1]))
							var/list/explodedString = splittext("[stack[stack.len-1]]", "[stack[stack.len]]")
							if (explodedString.len + length(stack) > MAX_STACK_DEPTH)
								return ERR_STACK_OVER

							stack.len -= 2
							stack += explodedString

						else
							return ERR_UNDEFINED

					if ("%")
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							if (stack[stack.len] == 0)
								return ERR_UNDEFINED

							result = stack[stack.len-1] % stack[stack.len]
							stack[--stack.len] = script_clampvalue( result )

						else
							return ERR_UNDEFINED

					if ("rand")
						if (length(stack) < 1)
							return ERR_STACK_UNDER
						result = script_clampvalue(rand(1, stack[stack.len]))
						stack[stack.len] = result

					if ("eq") //(1X 2X -- (1X == 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						result = stack[stack.len-1] == stack[stack.len]
						stack[--stack.len] = result

					if ("ne") //(1X 2X -- (1X != 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						result = stack[stack.len-1] != stack[stack.len]
						stack[--stack.len] = result

					if ("gt") //(1X 2X -- (1X > 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							result = stack[stack.len-1] > stack[stack.len]
							stack[--stack.len] = result

						else if (istext(stack[stack.len-1]) && isnum(stack[stack.len]))
							result = length(stack[stack.len-1]) > stack[stack.len]
							stack[--stack.len] = result

						else if (isnum(stack[stack.len-1]) && istext(stack[stack.len]))
							result = stack[stack.len-1] > length(stack[stack.len])
							stack[--stack.len] = result

						else
							result = length(stack[stack.len-1]) > length(stack[stack.len])
							stack[--stack.len] = result

					if ("ge") //(1X 2X -- (1X >= 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							result = stack[stack.len-1] >= stack[stack.len]
							stack[--stack.len] = result

						else if (istext(stack[stack.len-1]) && isnum(stack[stack.len]))
							result = length(stack[stack.len-1]) >= stack[stack.len]
							stack[--stack.len] = result

						else if (isnum(stack[stack.len-1]) && istext(stack[stack.len]))
							result = stack[stack.len-1] >= length(stack[stack.len])
							stack[--stack.len] = result

						else
							result = length(stack[stack.len-1]) >= length(stack[stack.len])
							stack[--stack.len] = result

					if ("lt") //(1X 2X -- (1X < 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							result = stack[stack.len-1] < stack[stack.len]
							stack[--stack.len] = result

						else if (istext(stack[stack.len-1]) && isnum(stack[stack.len]))
							result = length(stack[stack.len-1]) < stack[stack.len]
							stack[--stack.len] = result

						else if (isnum(stack[stack.len-1]) && istext(stack[stack.len]))
							result = stack[stack.len-1] < length(stack[stack.len])
							stack[--stack.len] = result

						else
							result = length(stack[stack.len-1]) < length(stack[stack.len])
							stack[--stack.len] = result

					if ("le") //(1X 2X -- (1X <= 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							result = stack[stack.len-1] <= stack[stack.len]
							stack[--stack.len] = result

						else if (istext(stack[stack.len-1]) && isnum(stack[stack.len]))
							result = length(stack[stack.len-1]) <= stack[stack.len]
							stack[--stack.len] = result

						else if (isnum(stack[stack.len-1]) && istext(stack[stack.len]))
							result = stack[stack.len-1] <= length(stack[stack.len])
							stack[--stack.len] = result

						else
							result = length(stack[stack.len-1]) <= length(stack[stack.len])
							stack[--stack.len] = result

					if ("and") //(1X 2X -- (1X && 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							result = script_clampvalue( stack[stack.len] & stack[stack.len-1] )

						else
							result = stack[stack.len] && stack[stack.len-1]

						stack[--stack.len] = result

					if ("or") //(1X 2X -- (1X || 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							result = script_clampvalue( stack[stack.len] | stack[stack.len-1] )

						else
							result = stack[stack.len] || stack[stack.len-1]

						stack[--stack.len] = result

					if ("not","!") //(1X -- (!1X))
						if (!stack.len)
							return ERR_STACK_UNDER

						if (isnum(stack[stack.len]))
							stack[stack.len] = ~stack[stack.len]

						else
							stack[stack.len] = !stack[stack.len]

					if ("xor","eor") //(1X 2X -- (1X ^ 2X))
						if (length(stack) < 2)
							return ERR_STACK_UNDER

						if (script_isNumResult(stack[stack.len], stack[stack.len-1]))
							result = stack[stack.len-1] ^ stack[stack.len]
							stack[--stack.len] = result

						else
							return ERR_UNDEFINED

					if ("dup")
						if (stack.len)
							stack.len++
							stack[stack.len] = stack[stack.len-1]

					if ("&#39;","'") // bodge alert, "'" added because this command doesnt seem to work at all
						var/newString
						while (command_stream.len)
							if (command_stream[1] == "\'" || command_stream[1] == "&#39;")
								command_stream.Cut(1,2)
								break
							else if (dd_hassuffix(command_stream[1], "&#39;"))
								if (newString)
									newString += " [copytext( command_stream[1],1,length(command_stream[1]-5) )]"

								else
									newString = "[copytext( command_stream[1],1,length(command_stream[1]-5) )]"

								command_stream.Cut(1,2)
								break

							else
								if (newString)
									newString += " [command_stream[1]]"

								else
									newString = "[command_stream[1]]"

								command_stream.Cut(1,2)

						if (newString)
							stack += newString

					if ("d","e","f","x")
						if (!stack.len)
							return ERR_STACK_UNDER

						. = stack[stack.len]
						if (!istext(.))
							return ERR_UNDEFINED

						. = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="[.]"))
						if (!istype(., /datum/computer))
							. = 0

						else if (cmptext(current_command, "d"))
							. = istype(., /datum/computer/folder)

						else if (cmptext(current_command, "x"))
							. = (istype(., /datum/computer/file/mainframe_program))// || (istype(., /datum/computer/file/record) && .:fields && .:fields[1] == "#!"))

						else if (cmptext(current_command, "f"))
							. = istype(., /datum/computer/file)

						else
							. = 1


						stack[stack.len] = .
						continue

					if (":")
						//todo
						continue

					if ("#") // gets how many information turdnuggets you have stored up
						stack.len++
						stack[stack.len]="[stack.len-1]"

					if ("del") //  removes the topmost item from the stack (most recently added)
						if (!stack.len)
							return ERR_STACK_UNDER
						stack.len--

					if ("value", "to") //Define/Set a variable value.
						if (!stack.len)
							return ERR_STACK_UNDER

						if (!command_stream.len)
							return ERR_UNDEFINED

						var/valueName = lowertext(ckeyEx(command_stream[1]))
						if (!valueName)
							return ERR_UNDEFINED

						scriptvars["[valueName]"] = stack[stack.len]
						stack.len--

					if (".s") // print the whole goddamn stack! stolen from forth, doesnt consume the stack.
						message_user("<[stack.len]>") // does not check if its in a script or not
						if(stack.len<1) 			  // piping "eval" to some other program and doing . or .s could be handy
							continue
						for(var/i = 1 to stack.len)
							message_user("[stack[i]]")
						message_user(" ") //honk.

					if (".") // print JUST the most recent stack item. also stolen from forth
						if(stack.len<1) // same as above, no script check "eval 3 2 . 4 | echo" -> "2" output
							return ERR_STACK_UNDER
						message_user("[stack[stack.len]]")
						stack.len-- //consume it, because thats what forth does

					else
						//boutput(world, "\[[lowertext(ckeyEx(current_command))]] in script vars?")
						if (lowertext(ckeyEx(current_command)) in scriptvars) //Lowertext(ckeyEx()) is equivalent to a ckey() that preserves underscores
							//boutput(world, "yes")
							result = scriptvars["[lowertext( ckeyEx(current_command) )]"]
							stack.len++
							stack[stack.len] = result

						else if (istext(current_command))
							stack += "[current_command]"

			//boutput(world, "STACK: [english_list(stack)]")
			if (return_bool)
				if (!stack.len)
					return EVAL_BOOL_FALSE
				return (stack[stack.len] ? EVAL_BOOL_TRUE : EVAL_BOOL_FALSE)

			return 0


	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/theFile)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		switch (data["command"])
			if (DWAINE_COMMAND_MSG_TERM)
				if (piping)
					pipetemp += data["data"]
				else
					return message_user(data["data"], data["render"])

			if (DWAINE_COMMAND_BREAK)
				if (shscript.len)
					message_user("Break at line [scriptline+1]")
					shscript.len = 0
					scriptline = 0
					//script_iteration = 1
					return

			if (DWAINE_COMMAND_TEXIT)
				//if (data["id"] == scriptprocess)
				//	scriptprocess = 0
				scriptprocess = 0

				return

			if (DWAINE_COMMAND_RECVFILE)
				//save to current dir.
				var/current_path = read_user_field("curpath")
				if (!current_path)
					return ESIG_GENERIC

				if (!istype(theFile))
					return ESIG_NOFILE

				return signal_program(1, list("command"=DWAINE_COMMAND_FWRITE, "path"=current_path,"replace"=1,"mkdir"=0), theFile)

		return

	message_user(var/msg, var/render=null)
		if (!useracc)
			return ESIG_NOTARGET

		if (suppress_out)

			if (dd_hassuffix(msg, "|n"))
				msg = copytext(msg, 1, -2)

			previous_pipeout += replacetext(msg, "|n", " ")

			return ESIG_SUCCESS

		previous_pipeout += msg
		if (render)
			return signal_program(parent_task.progid, list("command"=DWAINE_COMMAND_MSG_TERM, "data" = msg, "term" = useracc.user_id, "render" = render) )
		else
			return signal_program(parent_task.progid, list("command"=DWAINE_COMMAND_MSG_TERM, "data" = msg, "term" = useracc.user_id) )


#undef SCRIPT_IF_TRUE
#undef SCRIPT_IN_LOOP
#undef SCRIPT_IN_PROCESS
#undef MAX_SCRIPT_ITERATIONS
#undef MAX_SCRIPT_COMPLEXITY
#undef MAX_STACK_DEPTH
#undef ERR_STACK_OVER
#undef ERR_STACK_UNDER
#undef ERR_UNDEFINED
