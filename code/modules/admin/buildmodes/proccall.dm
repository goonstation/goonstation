/datum/buildmode/proccall
	name = "Proc Call (single)"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set proc details<br>
Left Mouse Button on turf/mob/obj      = Call proc on target<br>
Right Mouse Button                     = Show current proc settings (depending on how many arguments you have defined this could be laggy, be careful!)<br>
Hold down CTRL, ALT or SHIFT to modify, call or view proc bound to those keys.<br>
***********************************************************"}
	icon_state = "buildmode3"
	admin_level = LEVEL_CODER

	// no modifier key held down
	var/procname_n = null
	var/targeted_n = 1
	var/tmp/list/listargs_n = null

	// ctrl held down
	var/procname_c = null
	var/targeted_c = 1
	var/tmp/list/listargs_c = null

	// alt held down
	var/procname_a = null
	var/targeted_a = 1
	var/tmp/list/listargs_a = null

	// shift held down
	var/procname_s = null
	var/targeted_s = 1
	var/tmp/list/listargs_s = null

	click_mode_right(var/ctrl, var/alt, var/shift)
		var/istargeted = 1
		switch (alert("Proc owned by obj? Yes to call proc on what you click on, No to call global proc", "Global Proc[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]", "Yes", "No", "Cancel"))
			if ("Cancel")
				return
			if ("No")
				istargeted = 0

		var/newpn = input("Enter proc name[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]:", "Proc Name[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]", ctrl ? procname_c : alt ? procname_a : shift ? procname_s : procname_n) as text|null
		if (!newpn)
			return
		var/nargs = holder.owner.get_proccall_arglist()
		if (ctrl)
			procname_c = newpn
			targeted_c = istargeted
			listargs_c = nargs
		else if (alt)
			procname_a = newpn
			targeted_a = istargeted
			listargs_a = nargs
		else if (shift)
			procname_s = newpn
			targeted_s = istargeted
			listargs_s = nargs
		else
			procname_n = newpn
			targeted_n = istargeted
			listargs_n = nargs

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		var/proc2call = null
		var/targeted = 0
		var/list/args2use = null

		if (ctrl)
			if (!procname_c)
				boutput(usr, "<span class='alert'>No proc defined for CTRL! Please right click the buildmode button with CTRL held down to enter a proc.</span>")
				return
			proc2call = procname_c
			targeted = targeted_c
			args2use = listargs_c

		else if (alt)
			if (!procname_a)
				boutput(usr, "<span class='alert'>No proc defined for ALT! Please right click the buildmode button with ALT held down to enter a proc.</span>")
				return
			proc2call = procname_a
			targeted = targeted_a
			args2use = listargs_a

		else if (shift)
			if (!procname_s)
				boutput(usr, "<span class='alert'>No proc defined for SHIFT! Please right click the buildmode button with SHIFT held down to enter a proc.</span>")
				return
			proc2call = procname_s
			targeted = targeted_s
			args2use = listargs_s

		else
			if (!procname_n)
				boutput(usr, "<span class='alert'>No proc defined! Please right click the buildmode button to enter a proc.</span>")
				return
			proc2call = procname_n
			targeted = targeted_n
			args2use = listargs_n

		if (!proc2call) // just in case?
			return

		try
			var/returnval = null
			if (targeted)
				boutput(usr, "<span class='notice'>Calling '[proc2call]' with [islist(args2use) ? args2use.len : "0"] arguments on '[object]'</span>")
				if (islist(args2use) && length(args2use))
					returnval = call(object,proc2call)(arglist(args2use))
				else
					returnval = call(object,proc2call)()
				blink(get_turf(object))
			else
				boutput(usr, "<span class='notice'>Calling '[proc2call]' with [islist(args2use) ? args2use.len : "0"] arguments</span>")
				if (islist(args2use) && length(args2use))
					returnval = call(proc2call)(arglist(args2use))
				else
					returnval = call(proc2call)()
			boutput(usr, "<span class='notice'>Proc returned:</span> [!isnull(returnval) ? returnval : "null"]")
		catch(var/exception/e)
			world.log << "[usr.key] called a bad proc in buildmode and this can probably be ignored! ([e] on [e.file]:[e.line])"
			boutput(usr, "<span class='alert'>Proc returned: [e] ([e.file]:[e.line])</span>")

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		var/info2print = "<span class='notice'>***********************************************************</span>"
		var/modkey = null
		var/proc2list = null
		var/targeted = 0
		var/list/args2list = null

		if (ctrl)
			if (procname_c)
				modkey = "CTRL"
				proc2list = procname_c
				targeted = targeted_c
				args2list = listargs_c

		else if (alt)
			if (procname_a)
				modkey = "ALT"
				proc2list = procname_a
				targeted = targeted_a
				args2list = listargs_a

		else if (shift)
			if (procname_s)
				modkey = "SHIFT"
				proc2list = procname_s
				targeted = targeted_s
				args2list = listargs_s

		else
			if (procname_n)
				proc2list = procname_n
				targeted = targeted_n
				args2list = listargs_n

		if (proc2list)
			info2print += "<br><span class='notice'>Modifier key: [modkey ? modkey : "None"]</span>"
			info2print += "<br><span class='notice'>Proc name: [proc2list]</span>"
			info2print += "<br><span class='notice'>Global: [targeted ? "NO" : "YES"] (will [targeted ? null : " not"]be called on the clicked target)</span>"
			if (islist(args2list) && length(args2list))
				var/argnum = 0
				for (var/thing in args2list)
					argnum++
					info2print += "<br><span class='notice'>Arg#[argnum]:</span> [thing]"
			else
				info2print += "<br>No arguments defined."
		else
			info2print += "<br><span class='alert'>No proc defined[modkey ? " for [modkey]" : null]! Please right click the buildmode button[modkey ? " with [modkey] held down" : null] to enter a proc.</span>"

		info2print += "<br><span class='notice'>***********************************************************</span>"
		boutput(usr, info2print)
