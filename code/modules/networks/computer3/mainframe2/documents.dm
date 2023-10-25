//CONTENTS:
//DWAINE system help file
//Guardbot readme
//Guardbot demo patrol script file
//Guardbot demo bodyguard script file
//Guardbot demo configuration file
//Artifact research readme


/*
 *	Help record - Individual entries accessed by shell "help" command.  "index" entry generated programmatically.
 */
/datum/computer/file/record/dwaine_help
	name = "help"

	New()
		..()
		src.fields["basics1"] = "DWAINE is a multi-user Unix-like operating system produced by Thinktronic Data Systems.  The primary user interface is through a text-based terminal shell.|nApplications may be invoked simply by typing their filename, followed by a list of arguments if necessary.  A set of primary commands, those covering basic system tasks (Such as ls and cd), are made available to all users regardless of location in the filesystem.  Otherwise, applications must be in the user's current working directory to run."
		src.fields["basics2"] = "Directory navigation is accomplished primarily through the ls and cd commands.|nLS, an abbreviation of \"list\" will list the contents of the current directory.  The argument -l will cause it to also display extended file information and hidden files.|nCD, or \"change directory\" will set the current directory to the provided path, if valid.  A filepath takes a form such as \"/mnt/drive0\"  Paths starting with / descend from the root directory  \"..\" refers to the directory one level up from the current, while \".\" refers to the current directory.|nEx: \"cd ../hams\" would specify a directory named ham with the same parent as the current working one."
		src.fields["basics3"] = "DWAINE is, primarily, a networked system.  All devices, from user terminals to lineprinters and tape drives, are connected remotely to the central mainframe.  Devices that interact with files, such as drives or printers, may appear as part of the filesystem as a sub-directory of /mnt.|nFor example, the contents of tape databank \"Main\" would appear within /mnt/main and applications and other files could be accessed by setting it to your working directory with \"cd /mnt/main\""
		src.fields["basics4"] = "Application software is often bundled with a \"readme\" file of some sort, which can be viewed with the CAT command.|nEx: \"cat readme\" will view the contents of a readme file in the user's working directory."
		src.fields["ls"] = "View contents of a directory.  If no filepath is supplied, the working directory will be listed.|nExpanded file information, as well as hidden files, may be viewed through use of the -l argument.|nUsage: ls \[-l] \[filepath]"
		src.fields["cd"] = "Change working directory to the filepath supplied as argument.|nUsage: cd \"filepath\""
		src.fields["cat"] = "Combine the contents of one or more data files and print result to current output (Default output would be the user terminal). Use with executable files is inadvisable.|nUsage: cat \"filepath\" \[filepath...]"
		src.fields["echo"] = "Print text to current stream. Stream defaults to standard output (User terminal screen) if not piping.|nIf piping, output is passed on. If the piping target is not an executable, an attempt will be made to write to that file.|nUsage: echo \"text\" OR echo \"text\" | pipe_file_name"
		src.fields["eval"] = "Evaluate an expression.  Stack based with RPN input--the operation is expressed following the inputs, like \"1 2 +\" will result in 3.|nInput values are placed in order in a \"stack,\" with most recent input on top and first input on the bottom.  Values are taken back off the stack from the top down.  Operations act on the top 1 or 2 values on the stack, usually removing them and placing the result as the new top.|nValid operations are +, -, *, /, %, for arithmetic operations.|neq (equal), neq (not equal), gt (greater than), ge (greater or equal), lt (less than), le (less or equal) for comparison operations,|nAnd, Or, Not, and Xor for logical operations.|nThe operator DUP will copy the top value on the stack without removing anything from the stack.|nText surrounded by apostrophes will be interpreted as a string.  Variables may be set by pushing the desired value to the stack and then using the TO operator and a variable name.  For example, \"5 to HAMDAD\" would create a variable with the name HAMDAD and value 5.|nThere are also four file checking operators: d, e, f, and x.  Each take a filepath string from the top of the stack and leave a boolean value in its place.  d leaves a true if the path is to a folder, x is true if the path is to an executable, f is true if the path is to a file, and e is true if the path is to anything at all."
		src.fields["unset"] = "Un-sets an environment variable that had previously been set with \"eval\".|nUsage (clear all variables): \"unset\"|nUsage (clear var1, var2): \"unset var1 var2\" "
		src.fields["who"] = "Print list of current users to current output.|nUsage: who"
		src.fields["mesg"] = "Control acceptance of messages sent by other users.|nUsage mesg \"(y/n)\""
		src.fields["talk"] = "Send a message to another current user.|nUsage talk \"user name or user terminal ID\" \"message\""
		src.fields["cp"] = "Copy datafile to a new location. If new filepath specifies only a directory, the copy will retain original name.|nUsage: cp \"target filepath\" \"new filepath\""
		src.fields["mv"] = "Move datafile to a new location. If new filepath specifies only a directory, the file will retain original name.|nUsage: mv \"target filepath\" \"new filepath\""
		src.fields["rm"] = "Delete datafile or directory. Use of -r switch required for directory deletion. -i switch enables confirmation prompt, while -f suppresses this and error messages.|nUsage: rm \"target filepath\""
		src.fields["su"] = "Assume superuser status. An authorized ID must be provided.|nUsage: \"su\""
		src.fields["mkdir"] = "Create a directory or set of directories with the provided paths.|nUsage: mkdir \[filepath...]"
		src.fields["chmod"] = "Change the permissions of a file. File permissions take the form of three octal digits in the order of: owner, group, any user.|nBit one (The least significant bit) of each field controls modify access, bit two controls write access, and the third bit controls read access.|nUsage: chmod \"access value, i.e 777\" \"filename\""
		src.fields["chown"] = "Change the owner and/or group of a file. System operator status required to invoke.|nUsage: chown \[exact username]:\[group ID] \"filename\""
		src.fields["mount"] = "Mount device driver file space to filesystem. System operator status required to invoke.|nUsage: mount \"device net ID\" \"mountpoint name (Name for folder in /mnt)\""
		src.fields["grep"] = "Processes text line by line and prints any lines which match a specified pattern. |nOptions: please use all options in a single argument.|n -i  : Ignore case distinctions in both the PATTERN and the input files.|n -o  : Print only the matched parts of a matching line.|n -s  : Suppress error messages about unreadable files.|n -r  : Read all files under each directory. |nUsage: \"grep \[OPTIONS] PATTERN \[FILE...]\"|nExample usage: |n    grep -sr r*gum /mnt/control/readme /mnt/control"
		src.fields["scnt"] = "Scan network for unconnected peripheral devices, and then automatically connect to them. System operator status required to invoke.|nSpecific net IDs may be provided as arguments to connect to them directly. |nUsage: \"scnt\""
		src.fields["logoff"] = "Log out current user and ready system to accept new login.|nUsage: \"logoff\""

		src.fields["index"] = "Usage: help \"topic\"|nValid Topics: [english_list(src.fields, "None")]"

/datum/computer/file/record/pr6_readme
	name = "readme"

	New()
		..()
		src.fields = list("Readme for PR-6 Control Interface",
						  "Notice: Superuser access may be required to run prman application",
						  "Please ready authorized heads ID and type \"su\"",
						  "",
						  "A series of demo files have been supplied, as well as PR-6 task packages.",
						  "patrol_script takes one argument, the net id of the target bot.  It may be invoked by \"patrol_script (bot id)\"",
						  "guard_script takes two arguments, the net id of the target bot and the full name, with no spaces, of the person to protect.",
						  "demo_conf is a demonstration configuration file to set bodyguard tasks to guard \"John Doe\"",
						  "Valid PR-6 net ids may be listed via \"prman list\"",
						  "PR-6 units may be recalled via \"prman recall (id)\" The id may either correspond to the actual PR-6 unit or its last used dock.",
						  "If no arguments are supplied to prman, it will list valid commands.")

/datum/computer/file/record/patrol_script
	name = "patrol_script"

	New()
		..()
		src.fields = list("#!",
						  "#demonstration patrol script",
						  "#takes bot net id as argument",
						  "if $argc 1 lt | echo Error: No Net ID specified! | break",
						  "if $su 1 ne | echo Please authenticate (su) prior to invocation. | break",
						  //FUN NOTE; Why do we use /conf instead of just the local directory?
						  //"echo patrol=1|/conf/confpatrol",
						  //Because this file is, by default, on a tape drive.  The write time on secondary storage is such that
						  //"prman upload $arg0 secure -f /conf/confpatrol",
						  //by the time the file is visible, prman would've already looked and failed to find it.

						  "prman upload $arg0 secure patrol=1;",
						  "prman wake $arg0")

/datum/computer/file/record/bodyguard_script
	name = "guard_script"

	New()
		..()
		src.fields = list("#!",
						  "#simple bodyguard script",
						  "#takes bot net id and spaceless target name as argument",
						  "#ex: guard_script 02000050 johndoe",
						  "if argc 2 lt | echo Error: No Net ID or target name specified! | break",
						  "if su 1 ne | echo Please authenticate (su) prior to invocation. | break",
						  //"echo name= | echo $arg1|/conf/confguard",
						  //"prman upload $arg0 bodyguard -f /conf/confguard",
						  "prman upload $arg0 bodyguard name= $arg1",
						  "prman wake $arg0")

/datum/computer/file/record/roomguard_script
	name = "roomguard_script"

	New()
		..()
		src.fields = list("#!",
						  "#Bot will only look for targets in the same area.",
						  "#takes bot net id as argument",
						  "if $argc 1 lt | echo Error: No Net ID specified! | break",
						  "if $su 1 ne | echo Please authenticate (su) prior to invocation. | break",
						  "prman upload $arg0 areaguard",
						  "prman wake $arg0")

/datum/computer/file/record/bodyguard_conf
	name = "demo_conf"

	New()
		..()
		src.fields = list("#demonstration of configuration file",
						  "#for bodyguard and secure tasks",
						  "name=john doe",
						  "#this is the name of the protected individual",
						  "",
						  "#this is for use with the secure task",
						  "patrol=1",
						  "",
						  "#prman upload bot_id bodyguard patrol=1",
						  "or",
						  "#prman upload bot_id bodyguard -f demo_conf")

// things to shorten artlab work
// so people misspell gptio less often

/datum/computer/file/record/artlab_activate
	name = "act"

	New()
		..()
		src.fields = list("#!",
						  "if $argc 1 lt | echo Error: Please specify equipment to activate! | break",
						  "gptio activate $arg0")

/datum/computer/file/record/artlab_deactivate
	name = "deact"

	New()
		..()
		src.fields = list("#!",
						  "if $argc 1 lt | echo Error: Please specify equipment to deactivate! | break",
						  "gptio deactivate $arg0")

/datum/computer/file/record/artlab_read
	name = "read"

	New()
		..()
		src.fields = list("#!",
						  "if $argc 1 lt | echo Error: Please specify equipment to read test results from! | break",
							"gptio read $arg0")

/datum/computer/file/record/artlab_info
	name = "info"

	New()
		..()
		src.fields = list("#!",
						  "if $argc 1 lt | echo Error: Please specify equipment to get information on! | break",
						  "gptio info $arg0")

/datum/computer/file/record/artlab_xray
	name = "xray"

	New()
		..()
		src.fields = list("#!",
						  "if $argc 1 lt | gptio peek xray radstrength",
						  "if $argc 1 ge | gptio poke xray radstrength $arg0")

/datum/computer/file/record/artlab_heater
	name = "temp"

	New()
		..()
		src.fields = list("#!",
						  "if $argc 1 lt | gptio peek heater temptarget",
						  "if $argc 1 ge | gptio poke heater temptarget $arg0")

/datum/computer/file/record/artlab_elecbox
	name = "elec"

	New()
		..()
		src.fields = list("#!",
						  "if $argc 1 lt | gptio peek elecbox voltage",
							"if $argc 1 lt | gptio peek elecbox amperage",
						  "if $argc 1 ge | gptio poke elecbox voltage $arg0",
							"if $argc 2 ge | gptio poke elecbox amperage $arg1")

/datum/computer/file/record/artlab_pitcher
	name = "pitcher"

	New()
		..()
		src.fields = list("#!",
						  "if $argc 1 lt | gptio peek pitcher power",
						  "if $argc 1 ge | gptio poke pitcher power $arg0")

/datum/computer/file/record/artlab_impactpad
	name = "stand"

	New()
		..()
		src.fields = list("#!",
						  "if $argc 1 lt | gptio peek impactpad stand",
						  "if $argc 1 ge | gptio poke impactpad stand $arg0")

/*
 *		Emails!!
 */

/proc/get_random_email_list()
	return strings("randomEmail.txt", "availableMail", 1)

/datum/computer/file/record/random_email

	New(mailName as text)
		..()
		src.name = "[copytext("\ref[src]", 4, 12)]GENERIC"
		if (mailName)
			src.fields = strings("randomEmail.txt", mailName, 1)
