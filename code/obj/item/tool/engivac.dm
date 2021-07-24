/*Building mats/debris vacuum + tile layer for engineers
 *AFAIK there's not really a dm file dedicated to engineering items, so in its own little thing it goes.
 *
 *Close to the ore scoop in functionality but it's actually ore pieces that handle the heavy lifting for those,
 *and I'm not adding HasEntered to 6 different items for this thing.
 *Also somewhat distant from the janitor vacuum functionally, what with the smoke.
 */

obj/item/engivac
	name = "engineering materiel vacuum"
	desc = "A tool that sucks up debris and building materials  It is also capable of automatically laying floor tiles on plating."
	icon = 'icons/obj/janitor.dmi' //haha temporary sprotes
	icon_state = "handvac"
	flags = ONBELT | ONBACK //engis & mechs will want to keep their toolbelts on with this, most other crew their backpacks. Hope this doesn't break stuff.

	var/obj/item/storage/toolbox/held_toolbox = null
	var/toolbox_col = "" //suffix for worn/inhands

	//currently_collecting is what's currently eligible for being sucked up, made up of the two other lists
	var/list/buildmats_2_collect = list()
	var/list/debris_2_collect = list()
	var/list/currently_collecting

	//Vacuum settings
	var/collect_buildmats = TRUE
	var/collect_debris = TRUE
	var/placing_tiles = FALSE


obj/item/engivac/New(var/spawnbox = null)
	..()
	if (ispath(spawnbox, /obj/item/storage/toolbox))
		held_toolbox = new spawnbox

//You can't pick stuff up off windows without first dragging said stuff off first, so this is a bit of QOL for repair cleanup.
obj/item/engivac/afterattack(atom/target, mob/user as mob)
	if (istype(target, /obj/window))
		var/found_anything = FALSE
		/*
		for (var/i=1, i <= connects_to.len, i++)
			// if the turf appears in our connection list AND isn't in our exceptions...
			if (istype(T, connects_to[i]) && !(T.type in connects_to_exceptions))
		*/

		for (var/obj/item/crud in (get_turf(target)))
			//if (type( ))

		if (found_anything)
			playsound(get_turf(src), "sound/effects/suck.ogg", 20, TRUE, 0, 1.5)
		//boutput(user, "<span class='notice'>\The [name] sucks up some stuff stuck behind the window.</span>")

obj/item/engivac/attackby(obj/item/I as obj, mob/user as mob)
	..()//adding toolbox

obj/item/engivac/attack_hand(mob/user as mob)
	..()//removing toolbox

obj/item/engivac/attack_self(mob/user)
	..()//changing settings, maybe also allow removing the toolbox tbh

obj/item/engivac/move_callback(mob/M, turf/source, turf/target)
	. = ..()
	//sucking up

obj/item/engivac/get_desc(dist)
	if (dist <= 2)
		//List settings
	return

obj/item/engivac/proc/find_crud_on_turf(turf/target_turf)
	return

///returns 1 if we fit the thing (or some of the thing if it's a stack of stuff) into the toolbox
obj/item/engivac/proc/attempt_suck(obj/item/target)
	if (!target || isnull(held_toolbox))
		return 0
	if (get_dist(target, src) > 1) //I'm sure smartasses will find a way
		return 0
	return 1

