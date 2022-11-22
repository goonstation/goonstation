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
		..()
		BLOCK_SETUP(BLOCK_BOOK)

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
				reader.changeStatus("drowsy", 15 SECONDS)
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
