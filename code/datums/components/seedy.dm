



/**
  * Makes a [/obj/item] hold a seed data so it can be used on a plantpot
  */
/datum/component/seedy
	var/datum/plantgenes/DNA
	var/datum/plant/planttype
	var/generation

/datum/component/seedy/Initialize(datum/plantgenes/DNA, datum/plant/planttype, generation)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.DNA = DNA
	src.planttype = planttype
	src.generation = generation

	RegisterSignal(src.parent, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(on_pre_attack))

/datum/component/seedy/UnregisterFromParent()
	. = ..()
	UnregisterSignal(src.parent, COMSIG_ITEM_ATTACKBY_PRE)

/datum/component/seedy/disposing()
	qdel(src.DNA)
	qdel(src.planttype)
	. = ..()

/datum/component/seedy/proc/generate_seed()
	var/obj/item/seed/SEED = HYPgenerateseedcopy(src.DNA, src.planttype, src.generation)
	return SEED

/datum/component/seedy/proc/on_pre_attack(var/atom/affected_parent, var/atom/target, var/mob/user, var/damage)
	if(istype(target, /obj/machinery/plantpot))
		var/obj/machinery/plantpot/POT = target
		// Planting a seed in the tray.
		if(POT.current)
			boutput(user, SPAN_ALERT("Something is already in that tray."))
			return TRUE

		user.visible_message(SPAN_NOTICE("[user] plants a seed in the [POT]."))
		user.u_equip(affected_parent)

		var/obj/item/seed/SEED = src.generate_seed()
		SEED.set_loc(target)
		if(SEED.planttype)
			logTheThing(LOG_STATION, user, "plants a [SEED.planttype?.name] [SEED.planttype?.type] (reagents: [json_encode(HYPget_assoc_reagents(SEED.planttype, SEED.plantgenes))]) seed at [log_loc(POT)].")
			POT.HYPnewplant(SEED)
			if(!(user in POT.contributors))
				POT.contributors += user
		else
			boutput(user, SPAN_ALERT("You plant the seed, but nothing happens."))
			qdel(SEED)
		qdel(src.parent)
		return TRUE

