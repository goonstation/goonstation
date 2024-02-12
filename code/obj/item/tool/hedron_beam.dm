TYPEINFO(/obj/item/mining_tool/hedron_beam)
	mats = list("MET-2"=15, "CON-1"=8, "claretine"=10, "koshmarite"=2 )

/obj/item/mining_tool/hedron_beam
	name = "\improper Hedron beam device"
	desc = "A prototype multifunctional industrial tool capable of rapidly switching between welding and mining modes."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "hedron-W"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	item_state = "gun"
	c_flags = ONBELT
	tool_flags = TOOL_WELDING
	force = 10
	dig_strength = 3
	digcost = 2
	cell_type = /obj/item/ammo/power_cell
	hitsound_charged = 'sound/items/Welder.ogg'
	hitsound_uncharged = 'sound/impact_sounds/Metal_Clang_3.ogg'

	proc/mode_toggle()
		if(src.status)
			set_icon_state("hedron-W")
			flick("hedron-MtoW", src)
			src.power_down()
		else
			set_icon_state("hedron-M")
			flick("hedron-WtoM", src)
			src.dig_strength = 3
			src.power_up()

	power_down() //separate for power depletion power-down
		src.dig_strength = 0
		..()

	attack_self(var/mob/user as mob)
		if (src.process_charges(0))
			if(GET_COOLDOWN(src, "depowered"))
				boutput(user, SPAN_ALERT("[src] mode-cycled recently and can't switch modes yet."))
				return
			boutput(user, SPAN_NOTICE("You switch [src] into [status ? "welding mode" : "mining mode"]."))
			playsound(user.loc, 'sound/items/putback_defib.ogg', 30, 1)
			src.mode_toggle()
		else
			boutput(user, SPAN_ALERT("No charge left in [src]. Cannot enter mining mode."))

	proc/try_weld(mob/user, var/fuel_amt = 2, var/use_amt = -1, var/noisy=TRUE, var/burn_eyes=FALSE)
		if (!src.status)
			if(use_amt == -1)
				use_amt = fuel_amt
			if (!src.process_charges(use_amt*5)) //no "fuel", no weld
				boutput(user, SPAN_NOTICE("Cannot weld - cell insufficiently charged."))
				return FALSE
			if(noisy)
				playsound(user.loc, list('sound/items/Welder.ogg', 'sound/items/Welder2.ogg')[noisy], 35, 1)
			return TRUE //welding, has "fuel"
		//in mining mode? no welding 4 u
		boutput(user, SPAN_NOTICE("[src] is in mining mode and can't currently weld."))
		return FALSE
