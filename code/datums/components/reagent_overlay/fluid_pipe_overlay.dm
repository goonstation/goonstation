/datum/component/reagent_overlay/fluid_pipe

/datum/component/reagent_overlay/fluid_pipe/register_signals()
	var/obj/fluid_pipe/pipe = src.parent
	src.RegisterSignal(pipe.network, COMSIG_ATOM_REAGENT_CHANGE, PROC_REF(update_reagent_overlay))

/datum/component/reagent_overlay/fluid_pipe/unregister_signals()
	var/obj/fluid_pipe/pipe = src.parent
	src.UnregisterSignal(pipe.network, COMSIG_ATOM_REAGENT_CHANGE)

/datum/component/reagent_overlay/fluid_pipe/get_reagents()
	var/obj/fluid_pipe/pipe = src.parent
	return pipe.network.reagents
