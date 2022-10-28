/// conveyor placing component
/datum/component/conveyorplacer
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/conv_id = ""
	var/list/obj/machinery/conveyor/conveyors = list()
	var/list/obj/machinery/conveyor_switch/switches = list()
	var/stop_proc
	var/mob/layperson

TYPEINFO(/datum/component/conveyorplacer)
	initialization_args = list()

/datum/component/conveyorplacer/Initialize(var/stopProc)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/i_parent = parent
	if(!ismob(i_parent.loc))
		return COMPONENT_INCOMPATIBLE
	layperson = i_parent.loc
	conv_id = ref(src)
	stop_proc = stopProc
	RegisterSignal(i_parent, COMSIG_ITEM_DROPPED, .proc/stop_laying)
	RegisterSignal(layperson, COMSIG_MOVABLE_MOVED, .proc/place_conveyors)
	RegisterSignal(i_parent, COMSIG_ITEM_AFTERATTACK, .proc/place_lever)

/datum/component/conveyorplacer/UnregisterFromParent()
	for (var/obj/machinery/conveyor/C in src.conveyors)
		C.linked_switches = src.switches
	for (var/obj/machinery/conveyor_switch/S in src.switches)
		S.conveyors = src.conveyors
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	UnregisterSignal(layperson, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)

/datum/component/conveyorplacer/proc/stop_laying()
	call(parent, stop_proc)()

/datum/component/conveyorplacer/proc/place_conveyors(atom/movable/A, turf/oldLoc, direct)
	var/opposite_dir = turn(direct, 180)
	var/turf/newLoc = get_step(oldLoc, direct)


	var/obj/machinery/conveyor/oldC = locate(/obj/machinery/conveyor) in oldLoc
	var/obj/machinery/conveyor/newC = locate(/obj/machinery/conveyor) in newLoc

	if (!oldC)
		oldC = new /obj/machinery/conveyor(oldLoc)
		oldC.dir2 = opposite_dir
		src.conveyors |= oldC

	if (!newC)
		newC = new /obj/machinery/conveyor(newLoc)
		newC.dir1 = direct
		src.conveyors |= newC

	if (oldC.dir2 != direct)
		oldC.dir1 = direct
	if (newC.dir1 != opposite_dir)
		newC.dir2 = opposite_dir

	oldC.update()
	newC.update()

/datum/component/conveyorplacer/proc/place_lever(obj/item/parent, turf/target, mob/user, reach, params)
	if (!istype(target))
		return
	var/obj/machinery/conveyor_switch/sw = new /obj/machinery/conveyor_switch(target)
	src.switches |= sw
