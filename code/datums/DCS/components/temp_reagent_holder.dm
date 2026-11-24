TYPEINFO(/datum/component/temp_reagent_holder)
	initialization_args = list(
		ARG_INFO("to_contain_reagents", DATA_INPUT_TYPE, "reagent datum the component should contain.")
	)

///This component handles the allocation of temporary reagent holders that you don't want to mingle with the parent atom's reagent holder.
///It's purpose is to handle delayed reactions for temporary application on turfs, e.g. flamethrowers on tiles.

/datum/component/temp_reagent_holder
	dupe_mode = COMPONENT_DUPE_ALLOWED //We want to have multiple differnt assembly types on an item for different processes that have to apply temporary chems
	var/datum/reagents/stored_reagents = null
	var/time_to_check = 0.5 SECONDS //the amount of time we wait until we remove it, if it has no reactions going
	var/delayed_check = FALSE //if time_to_check is running, we don't need to repeat the check interval

/datum/component/temp_reagent_holder/Initialize(var/datum/reagents/applied_reagents)
	if(!src.parent || !isatom(src.parent) || !applied_reagents)
		return COMPONENT_INCOMPATIBLE
	. = ..()
	src.stored_reagents = applied_reagents
	applied_reagents.my_atom = src.parent


/datum/component/temp_reagent_holder/RegisterWithParent()
	. = ..()
	RegisterSignal(src.stored_reagents, COMSIG_REAGENTS_PROCESSING_REACTIONS_CHANGE, PROC_REF(delay_check))
	RegisterSignal(src.stored_reagents, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(run_check))
	//we directly run the check in case the contents of the reagent holder never start reacting
	src.delay_check(src.stored_reagents)

/datum/component/temp_reagent_holder/UnregisterFromParent()
	. = ..()
	UnregisterSignal(src.stored_reagents, COMSIG_REAGENTS_PROCESSING_REACTIONS_CHANGE)
	UnregisterSignal(src.stored_reagents, COMSIG_PARENT_PRE_DISPOSING)
	if(src.stored_reagents)
		src.stored_reagents.clear_reagents()
		qdel(src.stored_reagents)

/datum/component/temp_reagent_holder/proc/delay_check(var/datum/reagents/changed_reagents)
	if(!src.delayed_check && changed_reagents.processing_reactions != 1)
		src.delayed_check = TRUE
		SPAWN(src.time_to_check)
			src.run_check()


/datum/component/temp_reagent_holder/proc/run_check()
	src.delayed_check = FALSE
	//if we have not done any reaction until now, or somehow our reagents were removed/qdeleted, we remove ourself
	if(!src.stored_reagents || src.stored_reagents.disposed || src.stored_reagents.qdeled || src.stored_reagents.processing_reactions != 1)
		src.RemoveComponent()
