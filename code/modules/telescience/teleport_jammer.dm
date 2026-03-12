TYPEINFO(/obj/machinery/telejam)
	mats = 9

/obj/machinery/telejam
	name = "teleportation jammer"
	desc = "Generates a force field interferes with teleportation devices."
	icon = 'icons/obj/shield_gen.dmi'
	icon_state = "meteor_gen"
	density = 1
	opacity = 0
	anchored = UNANCHORED
	var/obj/item/cell/PCEL = null
	var/coveropen = 0
	var/active = 0
	var/range = 3
	var/image/display_active = null
	var/image/display_battery = null
	var/image/display_panel = null
	var/battery_level = 3
	var/sound/sound_on = 'sound/effects/shielddown.ogg'
	var/sound/sound_off = 'sound/effects/shielddown2.ogg'
	var/sound/sound_battwarning = 'sound/machines/pod_alarm.ogg'

	New()
		PCEL = new /obj/item/cell/supercell(src)
		PCEL.charge = PCEL.maxcharge

		src.display_active = image('icons/obj/shield_gen.dmi', "")
		src.display_battery = image('icons/obj/shield_gen.dmi', "")
		src.display_panel = image('icons/obj/shield_gen.dmi', "")

		..()

	disposing()
		turn_off()
		if (PCEL)
			PCEL.dispose()
		PCEL = null
		display_active = null
		display_battery = null
		sound_on = null
		sound_off = null
		sound_battwarning = null

		REMOVE_ATOM_PROPERTY(src, PROP_ATOM_TELEPORT_JAMMER, src)
		..()

	get_desc(dist, mob/user)
		. = ..()
		if(user.client)
			var/charge_percentage = 0
			if (PCEL?.charge > 0 && PCEL.maxcharge > 0)
				charge_percentage = round((PCEL.charge/PCEL.maxcharge)*100)
				. += "It has [PCEL.charge]/[PCEL.maxcharge] ([charge_percentage]%) battery power left."
				. += "The jammer's range is [src.range] units of distance."
				. += "The unit will consume [5 * src.range] power a second."
			else
				. += "It seems to be missing a usable battery."

	process()
		if (src.active)
			if(!PCEL)
				turn_off()
				return
			PCEL.use(5 * src.range)

			var/charge_percentage = 0
			var/current_battery_level = 0
			if (PCEL?.charge > 0 && PCEL.maxcharge > 0)
				charge_percentage = round((PCEL.charge/PCEL.maxcharge)*100)
				switch(charge_percentage)
					if (75 to 100)
						current_battery_level = 3
					if (35 to 74)
						current_battery_level = 2
					else
						current_battery_level = 1

			if (current_battery_level != src.battery_level)
				src.battery_level = current_battery_level
				src.build_icon()
				if (src.battery_level == 1)
					playsound(src.loc, src.sound_battwarning, 50, 1)
					src.visible_message(SPAN_ALERT("<b>[src] emits a low battery alarm!</b>"))

			if (PCEL.charge < 0)
				src.visible_message("<b>[src]</b> runs out of power and shuts down.")
				src.turn_off()
				return

	attack_hand(mob/user)
		if (src.coveropen && src.PCEL)
			src.PCEL.set_loc(src.loc)
			src.PCEL = null
			boutput(user, "You remove the power cell.")
		else
			if (src.active)
				turn_off()
				src.visible_message("<b>[user.name]</b> powers down the [src].")
			else
				if (PCEL)
					if (PCEL.charge > 0)
						turn_on()
						src.visible_message("<b>[user.name]</b> powers up the [src].")
					else
						boutput(user, "[src]'s battery light flickers briefly.")
				else
					boutput(user, "Nothing happens.")
		build_icon()

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			src.coveropen = !src.coveropen
			src.visible_message("<b>[user.name]</b> [src.coveropen ? "opens" : "closes"] [src]'s cell cover.")

		if (istype(W,/obj/item/cell/) && src.coveropen && !src.PCEL)
			user.drop_item()
			W.set_loc(src)
			src.PCEL = W
			boutput(user, "You insert the power cell.")

		else
			..()

		build_icon()

	attack_ai(mob/user as mob)
		return attack_hand(user)

	proc/build_icon()
		src.overlays = null

		if (src.coveropen)
			if (istype(src.PCEL,/obj/item/cell/))
				src.display_panel.icon_state = "panel-batt"
			else
				src.display_panel.icon_state = "panel-nobatt"
			src.overlays += src.display_panel

		if (src.active)
			src.display_active.icon_state = "on"
			src.overlays += src.display_active
			if (istype(src.PCEL,/obj/item/cell))
				var/charge_percentage = null
				if (PCEL.charge > 0 && PCEL.maxcharge > 0)
					charge_percentage = round((PCEL.charge/PCEL.maxcharge)*100)
					switch(charge_percentage)
						if (75 to 100)
							src.display_battery.icon_state = "batt-3"
						if (35 to 74)
							src.display_battery.icon_state = "batt-2"
						else
							src.display_battery.icon_state = "batt-1"
				else
					src.display_battery.icon_state = "batt-3"
				src.overlays += src.display_battery

	proc/turn_on()
		if (!PCEL)
			return
		if (PCEL.charge < 0)
			return

		src.anchored = ANCHORED
		src.active = 1
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_TELEPORT_JAMMER, src, src.range)
		playsound(src.loc, src.sound_on, 50, 1)
		build_icon()

	proc/turn_off()
		src.anchored = UNANCHORED
		src.active = 0
		REMOVE_ATOM_PROPERTY(src, PROP_ATOM_TELEPORT_JAMMER, src)
		playsound(src.loc, src.sound_off, 50, 1)
		build_icon()

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.PCEL)
			src.PCEL = null

	active
		New()
			..()
			turn_on()
