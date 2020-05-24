/obj/machinery/computer/riotgear
	name = "Riot Gear Authorization"
	icon_state = "drawbr0 "//drawbr-alert
	var/auth_need = 3.0
	var/list/authorized
	desc = "A computer that controls the movement of the nearby shuttle."

	lr = 0.6
	lg = 1
	lb = 0.1


//kinda copy paste from shuttle auth :)
/obj/machinery/computer/shuttle/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(status & (BROKEN|NOPOWER))
		return ..()
	if (!user)
		return ..()
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (!istype(W, /obj/item/card))
		return ..()



	if (!W:access) //no access
		boutput(user, "The access level of [W:registered]\'s card is not high enough. ")
		return

	var/list/cardaccess = W:access
	if(!istype(cardaccess, /list) || !cardaccess.len) //no access
		boutput(user, "The access level of [W:registered]\'s card is not high enough. ")
		return

	if(!(access_sec in W:access)) //doesn't have this access
		boutput(user, "The access level of [W:registered]\'s card is not high enough. ")
		return 0

	if(src.authorized && src.authorized.len >= src.auth_need)
		boutput(user, "Riot gear has already been opened!")
		return

	var/choice = alert(user, text("Would you like to (un)authorize access to riot gear? [] authorization\s are still needed.", src.auth_need - src.authorized.len), "Authorize", "Repeal")
	if(get_dist(user, src) > 1) return
	switch(choice)
		if("Authorize")
			if (!src.authorized)
				src.authorized = list()
			if (!W:registered)
				boutput(user, "ERROR : ID is not registered in any crewmember's name!")
			if (W:registered in src.authorized)
				boutput(user, "You have already authorized! [] authorization\s from others are still needed.")

			src.authorized += W:registered
			if (src.authorized.len < auth_need)
				boutput(world, text("<span class='notice'><B>Alert: [] authorizations needed until shuttle is launched early</B></span>", src.auth_need - src.authorized.len))
			else
				boutput(world, "<span class='notice'><B>Alert: Shuttle launch time shortened to 60 seconds!</B></span>")
				src.authorized = null

		if("Repeal")
			src.authorized -= W:registered
			boutput(world, text("<span class='notice'><B>Alert: [] authorizations needed until shuttle is launched early</B></span>", src.auth_need - src.authorized.len))
