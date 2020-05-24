/obj/machinery/computer/riotgear
	name = "Armory Authorization"
	icon_state = "drawbr0"
	var/auth_need = 3.0
	var/list/authorized
	desc = "Use this computer to authorize security access to the Armory. You need an ID with security access to do so."

	lr = 1
	lg = 0.3
	lb = 0.3

	var/authed = 0

	initialize()
		for (var/obj/machinery/door/airlock/D in doors)
			if (D.has_access(access_maxsec))
				D.no_access = 1
		..()


	proc/authorize()
		command_announcement("<br><b><span class='alert'>Armory weapons access has been authorized for all security personnel.</span></b>", "Security Level Increased", "sound/misc/announcement_1.ogg")
		authed = 1
		icon_state = "drawbr-alert"
		for (var/obj/machinery/door/airlock/D in doors)
			if (D.has_access(access_maxsec))
				D.req_access = list(access_security)
				D.no_access = 0
			LAGCHECK(LAG_REALTIME)


	proc/print_auth_needed()
		for (var/mob/O in hearers(src, null))
			O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[src.auth_need - src.authorized.len] authorizations needed until shuttle is launched early.\"</span></span>", 2)


/obj/machinery/computer/riotgear/attack_hand(mob/user as mob)
	if (ishuman(user))
		return src.attackby(user:wear_id, user)
	..()

//kinda copy paste from shuttle auth :)
/obj/machinery/computer/riotgear/attackby(var/obj/item/W as obj, var/mob/user as mob)
	interact_particle(user,src)
	if(status & (BROKEN|NOPOWER))
		return ..()
	if (!user)
		return ..()
	if(authed)
		boutput(user, "Armory has already been authorized!")
		return

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

	if(!(access_security in W:access)) //doesn't have this access
		boutput(user, "The access level of [W:registered]\'s card is not high enough. ")
		return 0

	if (!src.authorized)
		src.authorized = list()


	var/choice = alert(user, text("Would you like to (un)authorize access to riot gear? [] authorization\s are still needed.", src.auth_need - src.authorized.len), "Authorize", "Repeal")
	if(get_dist(user, src) > 1) return
	switch(choice)
		if("Authorize")
			if (!W:registered)
				boutput(user, "ERROR : ID is not registered in any crewmember's name!")
			if (W:registered in src.authorized)
				boutput(user, "You have already authorized! [] authorization\s from others are still needed.")

			src.authorized += W:registered
			if (access_maxsec in W:access)
				authorize()
				src.authorized = null

			if (src.authorized.len < auth_need)
				print_auth_needed()
			else
				authorize()
				src.authorized = null

		if("Repeal")
			src.authorized -= W:registered
			print_auth_needed()