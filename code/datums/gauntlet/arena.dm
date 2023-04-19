/datum/arena
	var/allow_processing = 0

	proc/process()

	proc/tick()
		if (allow_processing)
			process()

/obj/literal_firewall
	name = "Firewall"
	desc = "Man, your port doesn't feel like it's allowed through there! If only there was a way to open it."
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	color = "#9C2A00"
	density = 1
	opacity = 1
	anchored = ANCHORED

	attackby(var/obj/item/W, var/mob/user)
		if (disposed)
			return
		if (istype(W, /obj/item/device/key/iridium))
			boutput(user, "<span class='notice'>iridium -c 'ufw allow 2323/stcp from ::1'</span>")
			qdel(src)
