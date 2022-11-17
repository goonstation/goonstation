/*Building mats/debris vacuum + tile layer for engineers
 *AFAIK there's not really a dm file dedicated to engineering items, so in its own little thing it goes.
 *
 *Close to the ore scoop in functionality but it's actually ore pieces that handle the heavy lifting for those,
 *and I'm not adding HasEntered to 6 different items for this thing.
 *Also somewhat distant from the janitor vacuum functionally, as this one doesn't do smoke and that one doesn't auto-pickup,
 *but they could maybe be merged somehow.
 */
#define ENGIVAC_MISC_ITEM_LIMIT 2 //How much non-listed crap a toolbox can have before the engivac rejects it.

obj/item/engivac
	name = "engineering materiel vacuum"
	desc = "A tool that sucks up debris and building materials into an inserted toolbox. It is also capable of automatically laying floor tiles on plating."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "engivac"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "engivac_"
	flags = ONBELT | ONBACK //engis & mechs will want to keep their toolbelts on with this, most other crew their backpacks. Hope this doesn't break stuff.
	w_class = W_CLASS_BULKY

	//Stuff relating to the particular toolbox we have installed
	var/obj/item/storage/toolbox/held_toolbox = null
	var/toolbox_col = "" //suffix for worn/inhands
	var/image/toolbox_img

	//currently_collecting is what's currently eligible for being sucked up, made up of the two other lists
	var/list/buildmats_2_collect = list(/obj/item/tile, /obj/item/rods, /obj/item/sheet, /obj/item/cable_coil)
	var/list/debris_2_collect = list(/obj/item/raw_material/scrap_metal, /obj/item/raw_material/shard)
	var/list/currently_collecting

	//Vacuum settings
	var/collect_buildmats = TRUE
	var/collect_debris = TRUE
	var/placing_tiles = FALSE

	//The stack of tiles within the toolbox that we're currently drawing from wrt auto-placing
	var/obj/item/tile/current_stack


///
///				SPRITE-ALTERING PROCS
///

obj/item/engivac/update_icon(mob/M = null)
	item_state = "engivac_" + (held_toolbox ? held_toolbox.icon_state : "")
	wear_state = item_state
	underlays = null
	toolbox_img.icon_state = held_toolbox ? held_toolbox.icon_state : null
	underlays += toolbox_img
	if (M)
		M.update_inhands()
		M.update_clothing()


///Change worn sprite depending on slot
obj/item/engivac/equipped(var/mob/user, var/slot)
	..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_move)
	if (slot == SLOT_BACK)
		wear_image = image('icons/mob/clothing/back.dmi')
	if (slot == SLOT_BELT)
		wear_image = image('icons/mob/clothing/belt.dmi')
	UpdateIcon(user)


///
///				OVERRIDES FOR COMMON PROCS
///

obj/item/engivac/New(var/spawnbox = null)
	..()
	toolbox_img = image('icons/obj/items/storage.dmi', "") //where the toolbox sprites are
	if (ispath(spawnbox, /obj/item/storage/toolbox))
		held_toolbox = new spawnbox
		UpdateIcon()
	rebuild_collection_list()


obj/item/engivac/disposing()
	if (held_toolbox)
		held_toolbox.set_loc(get_turf(src))
		held_toolbox = null
	toolbox_img = null
	current_stack = null
	underlays = null
	..()

obj/item/engivac/dropped(var/mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	..()



//Manually cleaning up turfs (for corners you can't walk into)
obj/item/engivac/afterattack(atom/target)
	if (!target)
		return
	find_crud_on_turf(isturf(target) ? target : get_turf(target))


obj/item/engivac/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/storage/toolbox) && !held_toolbox)
		if (!toolbox_contents_check(I))
			if(!ON_COOLDOWN(src, "rejectsound", 2 SECONDS))
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
			boutput(user, "<span class='alert'>This toolbox has too many unrecognised things in it, and the vacuum rejects it.</span>")
			return
		user.u_equip(I)
		held_toolbox = I
		I.set_loc(src)
		UpdateIcon(user)
		var/obj/item/storage/toolbox/toolbox = I
		if(user.s_active == toolbox.hud)
			user.detach_hud(user.s_active)
		return
	..()


obj/item/engivac/attack_hand(mob/living/user)
	if (user.find_in_hand(src) && held_toolbox)
		if (user.put_in_hand(held_toolbox))
			held_toolbox = null
			placing_tiles = FALSE
			current_stack = null
			toolbox_col = ""
			UpdateIcon(user)
			return
	..()
	//copy-pasted from mounted defibs ewww
	if (islist(user.move_laying) && !(src in user.move_laying))
		user.move_laying += src
	else
		if (user.move_laying)
			user.move_laying = list(user.move_laying, src)
		else
			user.move_laying = list(src)


obj/item/engivac/attack_self(mob/user)
	..()
	var/list/options = list("Toggle collecting building materials", "Toggle collecting debris",held_toolbox ? "Toggle floor tile auto-placement" : null, held_toolbox ? "Remove Toolbox" : null)
	var/input = input(user,"Select option:","Option") in options
	switch(input)
		if ("Toggle collecting building materials")
			collect_buildmats = !collect_buildmats
			boutput(user, "<span class='notice'>\The [name] will now [collect_buildmats ? "collect" : "leave"] building materials.</span>")
			rebuild_collection_list()
			tooltip_rebuild = 1

		if ("Toggle collecting debris")
			collect_debris = !collect_debris
			boutput(user, "<span class='notice'>\The [name] will now [collect_debris ? "collect" : "leave"] debris.</span>")
			rebuild_collection_list()
			tooltip_rebuild = 1

		if ("Toggle floor tile auto-placement")
			placing_tiles = !placing_tiles
			boutput(user, "<span class='notice'>\The [name]'s tile auto-placement has been [placing_tiles ? "enabled" : "disabled"].</span>")
			tooltip_rebuild = 1

		if ("Remove Toolbox")
			user.put_in_hand_or_drop(held_toolbox)
			held_toolbox = null
			placing_tiles = FALSE
			current_stack = null
			toolbox_col = ""
			UpdateIcon(user)


obj/item/engivac/proc/on_move(mob/M, turf/source, dir)
	var/turf/target = (get_step(source,dir))
	//I'm here to collect stuff
	find_crud_on_turf(target)

	//and place tiles,
	if (!placing_tiles)
		return

	if (!current_stack)
		if (!scan_for_floortiles()) //...and I'm all out of tiles
			placing_tiles = FALSE
			tooltip_rebuild = 1
			playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
			boutput(M, "<span class='alert'>\The [name] does not have any floor tiles left, and deactivates auto-placing.</span>")
			return
	if (istype(target, /turf/simulated/floor))
		var/turf/simulated/floor/tile_target = target
		if (tile_target.intact && !(tile_target.broken || tile_target.burnt)) //Does this need replacing?
			return

		tile_target.attackby(current_stack,M)

		if (current_stack.disposed) //This stack just ran out
			current_stack = null


obj/item/engivac/get_desc(dist)
	if(held_toolbox)
		. += "<br>There's \a [held_toolbox] loaded in it."
	else
		. += "<br>It seems like you need to load an empty toolbox into it first."
	if (dist <= 2) //List settings
		. += "<br>It is set to [collect_buildmats ? "collect" : "leave"] building materials and [collect_debris ? "collect" : "leave"] debris."
		. += "<br>It is currently [placing_tiles? "" : "not "]automatically placing floor tiles."
	return

///
///				VAC SPECIFIC HELPER PROCS
///

///Find stuff on a turf and try to grab it. Returns TRUE if it manages to find and collect at least 1 thing
obj/item/engivac/proc/find_crud_on_turf(turf/target_turf)
	if (!islist(currently_collecting)) //both categories toggled off
		return FALSE
	if (!held_toolbox) //lol
		return FALSE
	var/did_something = FALSE
	for (var/obj/item/floor_item in target_turf)
		for(var/sometype in currently_collecting)
			if(istype(floor_item, sometype))
				if (attempt_fill(floor_item))
					did_something = TRUE //congratulations
				break

	return did_something


///Returns TRUE if we fit the target thing (or some of the thing if it's a stack of stuff) into the toolbox.
obj/item/engivac/proc/attempt_fill(obj/item/target)
	if (!target)
		return FALSE
	if (BOUNDS_DIST(target, src) > 0) //I'm sure smartasses will find a way
		return FALSE
	var/succeeded = FALSE
	var/list/toolbox_contents = held_toolbox.get_contents()
	for (var/obj/item/thingy as anything in toolbox_contents) //This loop is trying to stack target onto similar stacks in the toolbox
		if (!istype(thingy, target.type))
			continue
		var/prev_amount = target.amount
		thingy.stack_item(target)
		if (target.amount < prev_amount)
			succeeded = TRUE
		if (target.disposed)
			break
	if (!target.disposed) //If we get to here we've still got some left on the stack
		if (held_toolbox.check_can_hold(target) > 0) // target can fit. check_can_hold returns 0 or lower for various errors
			held_toolbox.add_contents(target)
			succeeded = TRUE
	return succeeded


///Sets current_stack to the first stack of floortiles we find in the toolbox, or null otherwise. Returns TRUE or FALSE respectively.
obj/item/engivac/proc/scan_for_floortiles()
	if (!held_toolbox) //lol
		return FALSE
	var/list/toolbox_contents = held_toolbox.get_contents()
	for (var/i=1, i <= toolbox_contents.len, i++)
		if (!istype(toolbox_contents[i], /obj/item/tile))
			if (i == toolbox_contents.len)
				current_stack = null
			continue
		current_stack = toolbox_contents[i]
		return TRUE
	return FALSE


obj/item/engivac/proc/rebuild_collection_list()
	currently_collecting = null
	if (collect_buildmats)
		currently_collecting += buildmats_2_collect
	if (collect_debris)
		currently_collecting += debris_2_collect

///Returns TRUE if the toolbox should be accepted and FALSE if it should not
obj/item/engivac/proc/toolbox_contents_check(obj/item/storage/toolbox/tocheck)
	if (!istype(tocheck))
		return FALSE
	var/list/toolbox_contents = tocheck.get_contents()
	var/strikes = 0
	var/in_list = FALSE
	for (var/obj/item/thingy as anything in toolbox_contents)
		for(var/sometype in (buildmats_2_collect + debris_2_collect))
			if(istype(thingy, sometype))
				in_list = TRUE
				break
		if (!in_list)
			strikes += 1
		in_list = FALSE
	if (strikes <= ENGIVAC_MISC_ITEM_LIMIT)
		return TRUE
	return FALSE

#undef ENGIVAC_MISC_ITEM_LIMIT
