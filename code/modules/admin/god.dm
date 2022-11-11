var/list/god_list = list()
var/god_name = ""
var/can_pray = 0

/client/proc/become_god(godName as text)
	set name = "Become God"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set desc = "(\"godly name\") Enter a godly name. (Type nothing for a random name)"

	if(!(usr.client in god_list))
		if(!length(god_list))
			if(!godName)
				switch(alert("Do you want the god name to be randomly picked?",,"Yes","No"))
					if("Yes")
						god_name = pick("Ahomana", "Ashie", "Barak", "Boanerges", "Chequa", "Dalogdog", "Enlil", "Guntur", "Haokah", "Heng", "Hino", "Indra", "Kaminari", "Keme", "Keneunlogy", "Lei", "Mekkhala", "Michikinaqua", "Nariko", "Ninurta", "Orko", "Ouxouiga", "Perun", "Pikne", "Potojchi", "Raamah", "Raamiah", "Rai", "Raicho", "Seth", "Sogbo", "Summanus", "Susanoo", "Taima", "Tama", "Taran", "Tarant", "Tarleton", "Terrill", "Taryn", "Tesup", "Tora", "Torborg", "Tormaigh", "Ukko", "Wagion", "Wakinyan", "Waukheon")
					if("No")
						boutput(usr, "Then please enter a god name!")
						return
			else:
				god_name = godName

			boutput(world, "<h2 class='alert'><font color='red'>KNEEL, MORTALS! '[god_name]' LIVES!</font></h2>")
			playsound_global(world, 'sound/effects/thunder.ogg', 80)
			boutput(world, "<span class='notice'>You may now pray in the Chapel.</span>")
			boutput(usr, "You have become a god.")

			can_pray = 1
		else
			boutput(usr, "There is already a god, but you can now listen to prayers!")

		god_list += usr.client

	else
		boutput(usr, "You are already a god!")

/client/proc/revoke_god()
	set name = "Revoke God"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)

	if(usr.client in god_list)
		god_list -= usr.client

		if(!length(god_list))
			boutput(world, "<h2 class='alert'><font color='red'>YOU MORTALS HAVE A GOD NO MORE</font></h2>")
			playsound_global(world, 'sound/effects/thunder.ogg', 80)
			boutput(world, "<span class='notice'>You cannot pray anymore</span>")

			can_pray = 0

		boutput(usr, "You are a god no more!")

/client/proc/check_gods()
	set name = "Check Gods"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)

	if(!length(god_list))
		boutput(usr, "There are no gods.")
	else
		boutput(usr, "The gods are:")

		for (var/client/C in god_list)
			boutput(usr, "	[C.key]")

/mob/living/verb/pray(message as text)
	set name = "Pray"
	set desc="(\"message\") Pray to the gods!"

	if(!can_pray)
		boutput(usr, "There are no gods willing to listen to you.")
		return

	if(!istype(usr.loc.loc, /area/chapel))
		boutput(usr, "You must be in the chapel to pray!")
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	boutput(usr, "You pray to [god_name]!")

	for(var/god in god_list)
		boutput(god, "<span class='notice'><B>PRAYER [usr.name]/[usr.key]</B>: [message]</span>")
