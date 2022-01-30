TYPEINFO(/datum/component/biodegradable)
	initialization_args = list()

/datum/component/biodegradable
/datum/component/biodegradable/Initialize()
	if(!istype(parent, /obj))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_REAGENT_CHANGE, .proc/biodegrade)

/datum/component/biodegradable/proc/biodegrade(source)
	var/obj/O = parent
	if(O.reagents?.total_volume <= 0)
		O.setStatus("acid", 1 SECOND, list("do_color" = FALSE, "message" = " biodegrades instantly.[prob(95) ? "": " DO NOT QUESTION THIS."]"))
