/obj/machinery/computer/riotgear
	name = "Armory Authorization"
	icon_state = "drawbr0"
	density = 0
	var/auth_need = 3.0
	var/list/authorized
	var/list/authorized_registered
	desc = "Use this computer to authorize security access to the Armory. You need an ID with security access to do so."

	lr = 1
	lg = 0.3
	lb = 0.3

	var/authed = 0
	var/area/armory_area

	initialize()
		armory_area = get_area_by_type(/area/station/ai_monitored/armory)
		if (!armory_area || armory_area.contents.len <= 1)
			armory_area = get_area_by_type(/area/station/security/armory)

		/*for (var/obj/machinery/door/airlock/D in armory_area)
			if (D.has_access(access_maxsec))
				D.no_access = 1
		*/
		..()


	proc/authorize()
		command_announcement("<br><b><span class='alert'>Armory weapons access has been authorized for all security personnel.</span></b>", "Security Level Increased", "sound/misc/announcement_1.ogg")
		authed = 1
		icon_state = "drawbr-alert"

		src.authorized = null
		src.authorized_registered = null

		for (var/obj/machinery/door/airlock/D in armory_area)
			if (D.has_access(access_maxsec))
				D.req_access = list(access_security)
				//D.no_access = 0
			LAGCHECK(LAG_REALTIME)

		if (armory_area)
			for(var/obj/O in armory_area)
				if (istype(O,/obj/storage/secure/crate))
					O.req_access = list(access_security)
				else if (istype(O,/obj/machinery/vending))
					O.req_access = list(access_security)

				LAGCHECK(LAG_REALTIME)


	proc/print_auth_needed(var/mob/author)
		if (author)
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[author] request accepted. [src.auth_need - src.authorized.len] authorizations needed until Armory is opened.\"</span></span>", 2)
		else
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[src.auth_need - src.authorized.len] authorizations needed until Armory is opened.\"</span></span>", 2)


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
	if (!istype(W, /obj/item/card/id))
		boutput(user, "No ID given.")
		return ..()

	if (!W:access) //no access
		boutput(user, "The access level of [W] is not high enough.")
		return

	var/list/cardaccess = W:access
	if(!istype(cardaccess, /list) || !cardaccess.len) //no access
		boutput(user, "The access level of [W] is not high enough.")
		return

	if(!(access_security in W:access)) //doesn't have this access
		boutput(user, "The access level of [W] is not high enough.")
		return

	if (!src.authorized)
		src.authorized = list()
		src.authorized_registered = list()

	var/choice = alert(user, text("Would you like to (un)authorize access to riot gear? [] authorization\s are still needed.", src.auth_need - src.authorized.len), "Armory Auth", "Authorize", "Repeal")
	if(get_dist(user, src) > 1) return
	switch(choice)
		if("Authorize")
			if (user in src.authorized)
				boutput(user, "You have already authorized! [src.auth_need - src.authorized.len] authorizations from others are still needed.")
				return
			if (W:registered in src.authorized_registered)
				boutput(user, "This ID has already issued an authorization! [src.auth_need - src.authorized.len] authorizations from others are still needed.")
				return
			if (access_maxsec in W:access)
				authorize()
				return

			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.bioHolder.Uid in src.authorized)
					boutput(user, "You have already authorized - fingerprints on file! [src.auth_need - src.authorized.len] authorizations from others are still needed.")
					return
				src.authorized += H.bioHolder.Uid
			else
				src.authorized += user //authorize by USER, not by registered ID. prevent the captain from printing out 3 unique ID cards and getting in by themselves.
			src.authorized_registered += W:registered

			if (src.authorized.len < auth_need)
				print_auth_needed(user)
			else
				authorize()

		if("Repeal")

			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				src.authorized -= H.bioHolder.Uid
			else
				src.authorized -= user
			src.authorized_registered -= W:registered

			print_auth_needed(user)
