ADMIN_INTERACT_PROCS(/obj/machinery/door/unpowered/blue, proc/revoke_door)
/obj/machinery/door/unpowered/blue
	icon = 'icons/obj/doors/newblue.dmi';
	name = "glowing edifice"
	desc = "You can faintly make out a pattern of fissures and glowing seams along the surface."
	icon_state = "door1"
	opacity = 1
	density = 1
	hardened = 1
	alpha = 0
	hitsound = 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg'
	var/friendly_object = null
	var/needs_precursor = FALSE
	var/locks_on_open = FALSE

	ex_act()
	blob_act()
	meteorhit()
	damage_heat()
	damage_corrosive()
	damage_piercing()
	damage_slashing()
	damage_blunt()

	New()
		. = ..()
		src.RemoveComponentsOfType(/datum/component/mechanics_holder)
		if(src.friendly_object || src.needs_precursor)
			src.locked = TRUE

		if(global.current_state < GAME_STATE_PREGAME)
			src.alpha = 255
		else
			animate(src, alpha = 255, time = 15, easing = SINE_EASING | EASE_OUT)
			SPAWN(18)
				var/turf/under_us = get_turf(src)
				under_us.ReplaceWith(/turf/unsimulated/floor/setpieces/bluefloor, force = 1)

	attack_hand(mob/user)
		if(src.locked && src.density)
			if(src.friendly_object)
				boutput(user,SPAN_ALERT("[src] makes an odd hum. It seems like it's expecting contact from something else..."))
			else if(src.needs_precursor && !ON_COOLDOWN(src, "smacksounde", 1 SECOND))
				boutput(user,SPAN_ALERT("[src] hums strangely in response to your touch. It feels like it's palpating the area..."))
				var/found_large = FALSE
				for (var/obj/O in orange(2,src))
					if(O.artifact && O.artifact.artitype.name == "precursor")
						found_large = TRUE
						break
				if(found_large)
					user.visible_message(SPAN_NOTICE("<B>[src] [pick("rings", "dings", "chimes","vibrates","oscillates")] [pick("faintly", "softly", "loudly", "weirdly", "scarily", "eerily")].</B>"))
					var/door_note = 'sound/musical_instruments/WeirdChime_0.ogg'
					playsound(src.loc, door_note, 60, 0)
					src.locked = FALSE
			else
				boutput(user,SPAN_ALERT("[src] doesn't respond to your touch."))
			return
		..()

	attackby(obj/item/W, mob/user)
		..()
		if(src.locked && !(src.locks_on_open && !src.density) && (src.friendly_object || src.needs_precursor))
			if(src.friendly_object && !istype(W,src.friendly_object))
				if (!ON_COOLDOWN(src, "smacksounde", 1 SECOND))
					user.visible_message(SPAN_ALERT("[src] sounds oddly hollow as it's struck."))
					playsound(src.loc, src.hitsound, 15, 0, pitch = 0.7)
				return
			else if(src.needs_precursor)
				if(!W.artifact || !W.artifact.artitype.name == "precursor")
					var/found_large = FALSE
					for (var/obj/O in orange(2,src))
						if(O.artifact && O.artifact.artitype.name == "precursor")
							found_large = TRUE
							break
					if (!found_large)
						if(!ON_COOLDOWN(src, "smacksounde", 1 SECOND))
							user.visible_message(SPAN_ALERT("[src] sounds oddly hollow as it's struck."))
							playsound(src.loc, src.hitsound, 15, 0, pitch = 0.7)
						return
			user.visible_message(SPAN_NOTICE("<B>[src] [pick("rings", "dings", "chimes","vibrates","oscillates")] [pick("faintly", "softly", "loudly", "weirdly", "scarily", "eerily")].</B>"))
			var/door_note = 'sound/musical_instruments/WeirdChime_0.ogg'
			playsound(src.loc, door_note, 60, 0)
			src.locked = FALSE

	vertical
		dir = 4

	autopuzzle
		locked = TRUE
		New()
			. = ..()
			START_TRACKING

		disposing()
			. = ..()
			STOP_TRACKING

	proc/revoke_door()
		locked = TRUE
		mouse_opacity = 0
		var/turf/under_us = get_turf(src)
		under_us.ReplaceWith(/turf/unsimulated/wall/auto/adventure/icemooninterior, force = 1)
		animate(src, alpha = 0, time = 15, easing = SINE_EASING | EASE_IN)
		SPAWN(20)
			qdel(src)

/obj/machinery/door/unpowered/blue/bumpopen(atom/movable/AM)
	if (ismob(AM) && (!AM:mind && !istype(AM,/mob/living/critter/shade/invader)))
		return
	. = ..()

/obj/machinery/door/unpowered/blue/open()
	if (src.locked)
		return

	. = ..()
	if(src.locks_on_open) src.locked = TRUE
	playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1)

/obj/machinery/door/unpowered/blue/close()
	if (src.locked && src.locks_on_open)
		return

	. = ..()
	playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1)

