/datum/sandbox
	var/list/context = list()

/proc/icon_serializer(var/savefile/F, var/path, var/datum/sandbox/sandbox, var/icon, var/icon_state)
	var/iname = "[icon]" || "ref[copytext(ref(icon), 4, 11)]"
	// the ref bit is for procedurally generated icons
	F["[path].icon"] << iname
	F["[path].icon_state"] << icon_state
	if (!("icon" in sandbox.context))
		sandbox.context += "icon"
		sandbox.context["icon"] = list()
	if (!(iname in sandbox.context["icon"]))
		sandbox.context["icon"] += iname
		sandbox.context["icon"][iname] = icon
		F["ICONS.[iname]"] << icon

/datum/iconDeserializerData
	var/icon/icon
	var/icon_state

/proc/icon_deserializer(var/savefile/F, var/path, var/datum/sandbox/sandbox, var/defaultIcon, var/defaultState, var/grab_file_reference_from_rsc_cache = 0)
	var/iname
	var/datum/iconDeserializerData/IDS = new()
	IDS.icon = defaultIcon
	IDS.icon_state = defaultState
	F["[path].icon"] >> iname
	if (!fexists(iname))
		if ("[defaultIcon]" == iname) // fuck off byond fuck you
			F["[path].icon_state"] >> IDS.icon_state
		else
			if (!("icon_failures" in sandbox.context))
				sandbox.context += "icon_failures"
				sandbox.context["icon_failures"] = list("total" = 0)
			if (!(iname in sandbox.context["icon_failures"]))
				sandbox.context["icon_failures"] += iname
				sandbox.context["icon_failures"][iname] = 0
			sandbox.context["icon_failures"]["total"]++
			sandbox.context["icon_failures"][iname]++

			F["ICONS.[iname]"] >> IDS.icon
			if (!IDS.icon && usr)
				boutput(usr, "<span class='alert'>Fatal error: Saved copy of icon [iname] cannot be loaded. Local loading failed. Falling back to default icon.</span>")
			else if (IDS.icon)
				F["[path].icon_state"] >> IDS.icon_state
	else
		if (grab_file_reference_from_rsc_cache)
			IDS.icon = fcopy_rsc(iname)
		else
			IDS.icon = icon(file(iname))
		F["[path].icon_state"] >> IDS.icon_state
	return IDS

/proc/matrix_serializer(var/savefile/F, var/path, var/datum/sandbox/sandbox, var/name, var/matrix/mx)
	var/base = "[path].[name]"
	F["[base].a"] << mx.a
	F["[base].b"] << mx.b
	F["[base].c"] << mx.c
	F["[base].d"] << mx.d
	F["[base].e"] << mx.e
	F["[base].f"] << mx.f

/proc/matrix_deserializer(var/savefile/F, var/path, var/datum/sandbox/sandbox, var/name, var/matrix/defMx = matrix())
	var/a
	var/b
	var/c
	var/d
	var/e
	var/f

	var/base = "[path].[name]"
	F["[base].a"] >> a
	if (!a)
		return defMx
	F["[base].d"] >> d
	if (!d)
		return defMx
	F["[base].b"] >> b
	F["[base].c"] >> c
	F["[base].e"] >> e
	F["[base].f"] >> f
	return new /matrix(a,b,c,d,e,f)

