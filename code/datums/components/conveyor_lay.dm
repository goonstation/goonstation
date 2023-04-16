/// conveyor placing component
/datum/component/conveyorplacer
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/obj/machinery/conveyor/conveyors
	var/conv_id

TYPEINFO(/datum/component/conveyorplacer)
	initialization_args = list()

/datum/component/conveyorplacer/Initialize(var/list/obj/machinery/conveyor/conveyors, var/conv_id)
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/place_conveyors)
	src.conveyors = conveyors
	src.conv_id = conv_id

/datum/component/conveyorplacer/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/conveyorplacer/proc/place_conveyors(atom/movable/A, turf/oldLoc, direct)
	var/opposite_dir = turn(direct, 180)
	var/turf/newLoc = get_step(oldLoc, direct)


	var/obj/machinery/conveyor/oldC = locate(/obj/machinery/conveyor) in oldLoc
	var/obj/machinery/conveyor/newC = locate(/obj/machinery/conveyor) in newLoc

	if (!oldC)
		oldC = new /obj/machinery/conveyor(oldLoc)
		oldC.id = conv_id
		oldC.dir_out = opposite_dir
		src.conveyors |= oldC

	if (!newC)
		newC = new /obj/machinery/conveyor(newLoc)
		newC.id = conv_id
		newC.dir_in = direct
		src.conveyors |= newC

	if (oldC.id == conv_id)
		if (oldC.dir_out != direct)
			oldC.dir_in = direct
		oldC.update()

	if (newC.id == conv_id)
		if (newC.dir_in != opposite_dir)
			newC.dir_out = opposite_dir
		newC.update()

