// accepts any number of arguments in form of paths to items to drop
// when component's parent dies (defined by signal being sent on death), items are spawned at their feet along with a message describing the dropped items
// component removes itself after triggering and dropping the items
// duplicate components' items are added to the old component's list

/datum/component/drop_loot_on_death
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/items_to_drop

	// something.AddComponent(/datum/component/drop_loot_on_death, /obj/item/sword)
/datum/component/drop_loot_on_death/proc/drop_loot()
	var/atom/dead_parent = parent
	var/turf_to_drop_on = get_turf(dead_parent)
	var/dropped_item_type = items_to_drop[1]
	var/dropped_item = new dropped_item_type(turf_to_drop_on)
	var/dropped_items_string = "\a [dropped_item]"
	var/items_length = length(items_to_drop)
	for(var/i = 2, i <= items_length, i++)
		dropped_item_type = items_to_drop[i]
		dropped_item = new dropped_item_type(turf_to_drop_on)
		if(i == items_length)
			dropped_items_string += " and \a [dropped_item]"
		else
			dropped_items_string += ", \a [dropped_item]"

	dead_parent.visible_message("<span class='notice'>As [dead_parent] falls, they leave behind [dropped_items_string].</span>")

	RemoveComponent()

/datum/component/drop_loot_on_death/Initialize(...)
	if (length(args))
		src.items_to_drop = args.Copy()
	else
		return COMPONENT_INCOMPATIBLE

	if (ismob(parent))
		RegisterSignal(parent, list(COMSIG_MOB_DEATH), .proc/drop_loot)
	else if (iscritter(parent))
		RegisterSignal(parent, list(COMSIG_OBJ_CRITTER_DEATH), .proc/drop_loot)
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/drop_loot_on_death/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_DEATH, COMSIG_OBJ_CRITTER_DEATH))
	. = ..()

/datum/component/drop_loot_on_death/InheritComponent(datum/component/drop_loot_on_death/C, i_am_original)
	if(C)
		src.items_to_drop.Add(C.items_to_drop)
	else
		var/list/items_to_add = args.Copy(3)
		src.items_to_drop.Add(items_to_add)
