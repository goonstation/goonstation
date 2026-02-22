/datum/targetable/flockmindAbility/createStructure
	name = "Place Tealprint"
	desc = "Create a structure tealprint for your drones to construct onto."
	icon_state = "fabstructure"
	cooldown = 0
	targeted = 0

/datum/targetable/flockmindAbility/createStructure/cast()
	var/turf/simulated/floor/feather/T = get_turf(holder.owner)
	if(!istype(T))
		boutput(holder.get_controlling_mob(), SPAN_ALERT("You aren't above a flocktile."))//todo maybe make this flock themed?
		return TRUE
	if (T.broken)
		boutput(holder.get_controlling_mob(), SPAN_ALERT("The flocktile you're above is broken!"))
		return TRUE
	if(locate(/obj/flock_structure/ghost) in T)
		boutput(holder.get_controlling_mob(), SPAN_ALERT("A tealprint has already been scheduled here!"))
		return TRUE
	if(locate(/obj/flock_structure) in T)
		boutput(holder.get_controlling_mob(), SPAN_ALERT("There is already a flock structure on this flocktile!"))
		return TRUE
	. = ..()
	var/list/friendlyNames = list()
	var/mob/living/intangible/flock/flockmind/F = holder.owner
	if (!length(F.flock.unlockableStructures))
		logTheThing(LOG_DEBUG, src.holder, "Flockmind place tealprint ability triggered with empty unlocked structures list. THIS SHOULD NOT HAPPEN.")
	for(var/datum/unlockable_flock_structure/ufs as anything in F.flock.unlockableStructures)
		if(ufs.check_unlocked())
			friendlyNames[ufs.tealprint_purchase_name] = ufs


	//todo: replace with FANCY tgui/chui window with WHEELS and ICONS and stuff!

	var/structurewanted = tgui_input_list(holder.get_controlling_mob(), "Select which structure you would like to create. Compute" + \
		" maintenance costs are provided in parentheses", "Tealprint selection", friendlyNames, theme = "flock")

	if (!structurewanted)
		boutput(holder.get_controlling_mob(), SPAN_ALERT("No tealprint selected."))
		return TRUE
	var/datum/unlockable_flock_structure/ufs = friendlyNames[structurewanted]
	var/obj/flock_structure/structurewantedtype = ufs.structType //this is a mildly cursed abuse of type paths, where you can cast a type path to a typed var to get access to its members
	if (!src.tutorial_check(FLOCK_ACTION_TEALPRINT_PLACE, structurewantedtype))
		return TRUE
	if(structurewantedtype)
		logTheThing(LOG_STATION, holder.owner, "queues a [initial(structurewantedtype.flock_id)] tealprint ([log_loc(T)])")
		return F.createstructure(structurewantedtype, initial(structurewantedtype.resourcecost))

/datum/targetable/flockmindAbility/createStructure/logCast(atom/target)
	return
