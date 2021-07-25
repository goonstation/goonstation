/*Building mats/debris vacuum + tile layer for engineers
 *AFAIK there's not really a dm file dedicated to engineering items, so in its own little thing it goes.
 *
 *Close to the ore scoop in functionality but it's actually ore pieces that handle the heavy lifting for those,
 *and I'm not adding HasEntered to 6 different items for this thing.
 *Also somewhat distant from the janitor vacuum functionally, as this one doesn't do smoke and that one doesn't auto-pickup,
 *but they could maybe be merged somehow.
 */

obj/item/engivac
	name = "engineering materiel vacuum"
	desc = "A tool that sucks up debris and building materials into an inserted toolbox. It is also capable of automatically laying floor tiles on plating."
	icon = 'icons/obj/items/device.dmi' //haha temporary sprotes
	icon_state = "engivac"
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
	//IDK if we want these to make fixing broken tiles as easy as walking around with a crowbar out so here's a var for it
	var/also_replace_broken = TRUE

	//The stack of tiles within the toolbox that we're currently drawing from wrt auto-placing
	var/obj/item/tile/current_stack


///
///				SPRITE-ALTERING PROCS
///

obj/item/engivac/proc/update_icon()
	underlays = null
	toolbox_img.icon_state = held_toolbox ? held_toolbox.icon_state : null
	underlays += toolbox_img
	//UpdateOverlays(toolbox_img, "box")


///Change worn sprite depending on slot
obj/item/engivac/equipped(var/mob/user, var/slot)
	..()

///
///				OVERRIDES FOR COMMON PROCS
///

obj/item/engivac/New(var/spawnbox = null)
	..()
	toolbox_img = image('icons/obj/items/storage.dmi', "",layer = (src.layer - 0.1)) //where the toolbox sprites are
	if (ispath(spawnbox, /obj/item/storage/toolbox))
		held_toolbox = new spawnbox
		toolbox_col = held_toolbox.icon_state
		update_icon()
	rebuild_collection_list()


obj/item/engivac/disposing()
	if (held_toolbox)
		held_toolbox = get_turf(src)
		held_toolbox = null
	toolbox_img = null
	current_stack = null
	underlays = null
	..()


//You can't pick stuff up off windows for some reason without first dragging said stuff off first, so this is a bit of QOL for repair cleanup.
obj/item/engivac/afterattack(atom/target, mob/user as mob)
	if (istype(target, /obj/window))
		if (find_crud_on_turf(get_turf(target)))
			playsound(get_turf(src), "sound/effects/suck.ogg", 20, TRUE, 0, 1.5)
			boutput(user, "<span class='notice'>\The [name] sucks up some stuff stuck behind the window somehow.</span>")


obj/item/engivac/attackby(obj/item/I as obj, mob/user as mob)
	if (istype(I, /obj/item/storage/toolbox) && !held_toolbox)
		user.u_equip(I)
		held_toolbox = I
		I.set_loc(src)
		toolbox_col = held_toolbox.icon_state
		update_icon()
		return
	..()


obj/item/engivac/attack_hand(mob/living/user as mob)
	if (user.find_in_hand(src) && held_toolbox)
		if (user.put_in_hand(held_toolbox))
			held_toolbox = null
			placing_tiles = FALSE
			current_stack = null
			toolbox_col = ""
			update_icon()
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
	var/input = input(usr,"Select option:","Option") in options
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
			update_icon()

/*
obj/item/engivac/dropped(mob/living/user)
	..()
	if (islist(user.move_laying))
		user.move_laying -= src
	else
		user.move_laying = null
*/

obj/item/engivac/move_callback(mob/M, turf/source, turf/target)
	. = ..()
	//I'm here to collect stuff
	find_crud_on_turf(target)

	//and place tiles,
	if (!placing_tiles)
		return

	if (!current_stack)
		if (!scan_for_floortiles()) //...and I'm all out of tiles
			placing_tiles = FALSE
			tooltip_rebuild = 1
			playsound(get_turf(src), "sound/machines/buzz-sigh.ogg", 50, 0)
			boutput(M, "<span class='alert'>\The [name] does not have any floor tiles left, and deactivates the auto-placing.</span>")
			return
	if (istype(target, /turf/simulated/floor))
		var/turf/simulated/floor/tile_target = target
		if (tile_target.intact && (also_replace_broken && !(tile_target.broken || tile_target.burnt))) //Does this need replacing?
			return

		tile_target.attackby(current_stack,M)

		if (current_stack.pooled) //This stack just ran out
			current_stack = null


obj/item/engivac/get_desc(dist)
	if (dist <= 2) //List settings
		. += "<br>It is set to [collect_buildmats ? "collect" : "leave"] building materials and [collect_debris ? "collect" : "leave"] debris."
		. += "<br>It is currently [placing_tiles? "" : "not "]automatically placing floor tiles."
	return

///
///				VAC SPECIFIC HELPER PROCS
///

///Find stuff on a turf and try to grab it. Returns 1 if it manages to find and collect at least 1 thing (for use in the afterattack code)
obj/item/engivac/proc/find_crud_on_turf(turf/target_turf)
	if (!islist(currently_collecting)) //both categories toggled off
		return 0
	if (!held_toolbox) //lol
		return 0
	var/did_something = FALSE
	for (var/obj/item/floor_item in target_turf)
		for(var/sometype in currently_collecting)
			if(istype(floor_item, sometype))
				if (attempt_fill(floor_item))
					did_something = TRUE //congratulations
				break
		//if (!(floor_item.type in currently_collecting))
		//	continue

	return did_something


///Returns 1 if we fit the target thing (or some of the thing if it's a stack of stuff) into the toolbox.
obj/item/engivac/proc/attempt_fill(obj/item/target)
	if (!target)
		return 0
	if (get_dist(target, src) > 1) //I'm sure smartasses will find a way
		return 0
	var/succeeded = FALSE
	var/list/toolbox_contents = held_toolbox.get_contents()
	for (var/obj/item/thingy as anything in toolbox_contents) //This loop is trying to stack target onto similar stacks in the toolbox
		if (!istype(thingy, target.type))
			continue
		var/prev_amount = target.amount
		target.stack_item(thingy)
		if (target.amount < prev_amount)
			succeeded = TRUE
		if (target.pooled)
			break
	if (!target.pooled) //If we get to here we've still got some left on the stack
		if (held_toolbox.check_can_hold(target) > 0) //meaning:target can fit. check_can_hold returns 0 or lower for various errors
			held_toolbox.add_contents(target)
			succeeded = TRUE
	return succeeded


///Sets current_stack to the first stack of floortiles we find in the toolbox, or null otherwise. Returns 1 or 0 respectively.
obj/item/engivac/proc/scan_for_floortiles()
	if (!held_toolbox) //lol
		return 0
	var/list/toolbox_contents = held_toolbox.get_contents()
	for (var/i=1, i <= toolbox_contents.len, i++)
		if (!istype(toolbox_contents[i], /obj/item/tile))
			if (i = toolbox_contents.len)
				current_stack = null
			continue
		current_stack = toolbox_contents[i]
		return 1
	return 0


obj/item/engivac/proc/rebuild_collection_list()
	currently_collecting = null
	if (collect_buildmats)
		currently_collecting += buildmats_2_collect
	if (collect_debris)
		currently_collecting += debris_2_collect
