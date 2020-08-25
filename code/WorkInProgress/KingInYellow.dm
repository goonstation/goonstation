/obj/item/clothing/mask/pallid
	name = "The Pallid Mask"
	desc = "..."
	icon_state = "pallid_mask"

/proc/get_oov_tile(var/atom) //Get a tile that is *just* outside the view of a given atom.
	var/list/viewl = oview(10, atom)
	for(var/atom/A in viewl) //List of visible turfs.
		if(!isturf(A)) viewl -= A

	var/list/rangel = orange(10, atom)
	for(var/atom/A2 in rangel) //List of all turfs.
		if(!isturf(A2)) rangel -= A2

	var/list/not_vis = viewl ^ rangel //List of all turfs that are NOT visible.
	var/list/valid = new/list()		//List of all turfs that are NOT visible that border a VISIBLE turf.

	for(var/turf/T in not_vis)
		for(var/dir in cardinal)
			if(get_step(T, dir) in viewl)
				if(is_free(T))
					var/atom/between = get_step(T, get_dir(T, atom))
					if(!between.opacity || 1) //this might limit it too much. check later
						valid += T
						break

	if(!valid.len) return null
	else return pick(valid)

/obj/kingyellow_vanish
	name = "Distortion"
	desc = ""
	density = 0
	anchored = 1
	layer = EFFECTS_LAYER_BASE
	var/image/effect = null

	New(var/atom/location, var/atom/trg)
		if(trg != null)
			set_loc(location)
			effect = image('icons/effects/effects.dmi', src, "ykingvanish", 4)
			trg << effect
			SPAWN_DBG(0.3 SECONDS)	qdel(src)
		else	qdel(src)


/obj/kingyellow_phantom
	name = "Strange Person"
	desc = "Who is that? They look extremely out-of-place."
	density = 0
	anchored = 1
	var/atom/target = null
	var/image/showimg = null
	var/created = null

	New(var/atom/location, var/atom/trg)
		set_loc(location)
		target = trg
		created = world.time
		showimg = image('icons/misc/critter.dmi', src, "kingyellow", 3)
		target << showimg
		src.dir = get_dir(src, target)
		SPAWN_DBG(0.5 SECONDS) update()

	attackby(obj/item/W as obj, mob/user as mob)
		vanish()

	attack_hand(mob/user as mob)
		vanish()

	proc/update()
		if(!target) vanish()
		if(!(src in view(7, target)) && (world.time - created) > 40) vanish()
		if(get_dist(src,target) <= 2) vanish()
		src.dir = get_dir(src, target)
		SPAWN_DBG(0.5 SECONDS) update()

	proc/vanish()
		new/obj/kingyellow_vanish(src.loc, target)
		SPAWN_DBG(0.3 SECONDS)	qdel(src)

/obj/item/book_kinginyellow
	name = "\"The King In Yellow\""
	desc = ""
	icon = 'icons/obj/writing.dmi'
	icon_state = "bookkiy"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	layer = OBJ_LAYER
	event_handler_flags = USE_FLUID_ENTER | IS_FARTABLE

	var/list/readers = list()
	var/atom/curr_phantom = null
	var/processing = 0

	New()
		BLOCK_BOOK
		return

	process()
		..()
		if(readers.len)
			var/mob/living/L = pick(readers)
			var/turf/oovTile = get_oov_tile(L)
			if(oovTile != null && curr_phantom == null)
				curr_phantom = new/obj/kingyellow_phantom(oovTile, L)

	get_desc(var/dist, mob/user)
		if (!lastTooltipContent)
			// Okay, so here's a gross hack for you:
			// This gets called when generating a tooltip, which effectively
			// adds the user to the reader list even if they didn't examine it.
			// There's no way to tell if a user is examining it legitimately or if
			// the game is generating a tooltip just in case they do, so
			// in the case of a tooltip not existing, just. pretend nothing happens
			// This may not work properly if you have tooltips off but whatever
			return "<br>?????"

		if (!issilicon(user))
			var/mob/living/carbon/reader = user
			if (!istype(reader))
				return

			. = list()
			if (readers.len && (reader in readers))
				. += "<br>You frantically read the play again..."
				. += "You feel as if you're about to faint."
				reader.drowsyness += 3
			else
				. += "<br>This appears to be an ancient book containing a play."
				. += "The first act tells of a city named Carcosa, and a mysterious \"King in Yellow\"."
				. += "The second act seems incomplete, but... it is horrifying."

				for (var/mob/M in readers)
					// I'm not sure what the point of this is -- it makes it so only one person
					// can be a target at a time, even though the code clearly handles more than one
					// and in this case it could just be a simple "last_reader" var with a single mob ref.
					// That being said I'm not sure what the intent was so I'm just making a note
					// and leaving it alone. vOv
					boutput(M, "<span class='alert'>You feel the irresistible urge to read the <em>The King In Yellow</em> again.</span>")
					readers -= M

				readers += reader
				if(!processing)
					processing_items.Add(src)
			return jointext(., "<br>")
		else
			. = "This ancient data storage medium appears to contain data used for entertainment purposes."

	custom_suicide = 1
	suicide_distance = 0
	suicide(var/mob/living/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (istype(user))
			if (!farting_allowed)
				return 0
			if (src.loc == user)
				user.u_equip(src)
				src.layer = initial(src.layer)
				src.set_loc(user.loc)
				return farty_doom(user)
		else
			return 0

	proc/farty_doom(var/mob/living/victim)
		if(istype(victim) && victim.loc == src.loc)
			victim.visible_message("<span class='alert'>[victim] farts on [src].<br><b>A mysterious force sucks [victim] into the book!!</b></span>")
			victim.emote("scream")
			victim.implode()
			return 1
		return 0
