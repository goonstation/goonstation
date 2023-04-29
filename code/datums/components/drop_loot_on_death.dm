// accepts a path or list of paths as arguments
// when component's parent dies (defined by signal being sent on death), item(s) are spawned at their feet along with a message describing the dropped items
// component removes itself after triggering and dropping the items
// duplicate components' item(s) are added to the old component's list

TYPEINFO(/datum/component/drop_loot_on_death)
	initialization_args = list(
		ARG_INFO("loot", DATA_INPUT_TYPE, "Path or list of paths for loot to drop on death")
	)
/datum/component/drop_loot_on_death
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/items_to_drop

/datum/component/drop_loot_on_death/Initialize(loot)
	. = ..()
	if (islist(loot) && length(loot))
		src.items_to_drop = loot
	else if (ispath(loot))
		src.items_to_drop = list(loot)
	else
		return COMPONENT_INCOMPATIBLE // no items to drop were provided, no point in adding the component

	if (ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/drop_loot)
	else if (iscritter(parent))
		RegisterSignal(parent, COMSIG_OBJ_CRITTER_DEATH, .proc/drop_loot)
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/drop_loot_on_death/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_DEATH, COMSIG_OBJ_CRITTER_DEATH))
	. = ..()

// if another duplicate component of this type is added, add its items to this one
/datum/component/drop_loot_on_death/InheritComponent(datum/component/drop_loot_on_death/C, i_am_original, _items)
	if(C?.items_to_drop)
		src.items_to_drop.Add(C.items_to_drop)
	else
		if (_items) // C(duplicate component) wasn't initialized, so we don't know if the raw argument _items is in proper format
			if (islist(_items) && length(_items))
				src.items_to_drop.Add(_items)
			else if (ispath(_items))
				src.items_to_drop.Add(_items)

/datum/component/drop_loot_on_death/proc/drop_loot()
	var/atom/dead_parent = parent
	var/turf_to_drop_on = get_turf(dead_parent)
	var/dropped_item_type = items_to_drop[1]
	var/dropped_item = new dropped_item_type(turf_to_drop_on)
	var/dropped_items_string = "\a [dropped_item]"
	var/items_length = length(items_to_drop)
	for (var/i = 2 to items_length)
		dropped_item_type = items_to_drop[i]
		dropped_item = new dropped_item_type(turf_to_drop_on)
		if(i == items_length)
			dropped_items_string += " and \a [dropped_item]"
		else
			dropped_items_string += ", \a [dropped_item]"

	dead_parent.visible_message("<span class='notice'>As [dead_parent] falls, they leave behind [dropped_items_string].</span>")

	RemoveComponent()
