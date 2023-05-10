TYPEINFO(/obj/item/device/borg_linker)
	mats = list("CRY-1", "CON-2")

/obj/item/device/borg_linker
	name = "cyborg law linker"
	icon_state = "cyborg_linker"
	flags = FPRINT | TABLEPASS| CONDUCT
	c_flags = ONBELT
	force = 5
	w_class = W_CLASS_SMALL
	throwforce = 5
	throw_range = 15
	throw_speed = 3
	desc = "A device for connecting silicon beings to a law rack, setting restrictions on their behaviour."
	m_amt = 50
	g_amt = 20
	var/obj/machinery/lawrack/linked_rack = null

	attack_self(var/mob/user)
		if(src.linked_rack)
			var/area/A = get_area(src.linked_rack.loc)
			boutput(user,"Stored law rack at: "+A.name)
		else
			boutput(user, "No law rack connected.")

		if(src.linked_rack)
			var/raw = tgui_alert(user,"Do you want to clear the linked rack?", "Linker", list("Yes", "No"))
			if (raw == "Yes")
				src.linked_rack = null
		return
