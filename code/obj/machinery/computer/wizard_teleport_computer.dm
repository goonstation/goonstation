/obj/machinery/computer/wizard_teleport_computer
	name = "Magix System V"
	desc = "An arcane artifact overflowing with teleportation magic. Running E-Knock 3.1: Sorceror's Edition"
	icon_state = "wizard"
	light_r = 0.6
	light_g = 1
	light_b = 0.1

/obj/machinery/computer/wizard_teleport_computer/attack_hand(var/mob/user)
	if(..())
		return

	if (!iswizard(user))
		user.show_text("The [src.name] doesn't respond to your inputs.", "red")
		return

	usr.teleportscroll(1, 2, src)
