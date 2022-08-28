/obj/surplusopspawner/
	name = "gungus spawner"
	icon = 'icons/obj/objects.dmi'
	icon_state = "itemspawn"
	density = 0
	anchored = 1.0
	invisibility = INVIS_ALWAYS
	layer = 99

/obj/surplusopspawner/loadout_shortgun_spawner
	name = "shortgun loadout spawner"

	New()
		..()
		SPAWN(1 DECI SECOND)
			new /obj/random_item_spawner/surplus/shortgun(src.loc)
			new /obj/random_item_spawner/surplus/melee(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			qdel(src)

/obj/random_item_spawner/surplus/melee/withcredits
	New()

		SPAWN(1 DECI SECOND)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
		..()
/obj/item/reagent_containers/glass/beaker/large/surplusmedical
	name = "Beaker- Jungle Juice"
	desc = "A beaker full of an odd-smelling medical cocktail."
	initial_reagents = list("ephedrine"=30, "saline"= 30, "synaptizine" = 30, "omnizine" = 9)

/obj/item/experimental/melee/spear/plaswood
	New()
		..()
		setHeadMaterial(getMaterial("plasmaglass"))
		setShaftMaterial(getMaterial("wood"))
		buildOverlays()


/obj/machinery/surplusopauth
	name = "Deployment Authorization Computer"
	desc = "A voting computer that allows three users to activate a certain portal frame."
	icon_state = "drawbr"
	icon = 'icons/obj/computer.dmi'
	density = 0

	var/obj/submachine/surplusopdeployer/ourportal = null
	var/auth_need = 3
	var/list/authorized
	var/list/authorized_registered = null

	var/authed = 0

	proc/authorize()
		if(src.authed)
			return

		ourportal.active = TRUE //FLIP THE LEVER, KRONK!
		ourportal.icon_state = "syndtele1"

	proc/print_auth_needed(var/mob/author)
		if (author)
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[author] request accepted. [src.auth_need - src.authorized.len] authorizations needed until teleporter is activated.\"</span></span>", 2)
		else
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[src.auth_need - src.authorized.len] authorizations needed until until teleporter is activated.\"</span></span>", 2)
	New()
		for_by_tcl(D, /obj/submachine/surplusopdeployer)
			src.ourportal = D //connect to portal
		..()
	attackby(var/obj/item/W, var/mob/user)

		if (!user)
			return

	//stolen from armory code
		if (!src.authorized)
			src.authorized = list()
			src.authorized_registered = list()

		var/choice = tgui_alert(user, "Would you like to authorize group deployment? [src.auth_need - length(src.authorized)] authorization\s are still needed.", "Armory Auth", list("Authorize"))
		if(BOUNDS_DIST(user, src) > 0 || src.authed)
			return
		src.add_fingerprint(user)
		if (!choice)
			return
		switch(choice)
			if("Authorize")
				if (user in src.authorized)
					boutput(user, "You have already authorized! [src.auth_need - src.authorized.len] authorizations from others are still needed.")
					return
				//we only want fingerprints to be able to count, since they don't have any access
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if (H.bioHolder.Uid in src.authorized)
						boutput(user, "You have already authorized - fingerprints on file! [src.auth_need - src.authorized.len] authorizations from others are still needed.")
						return
					src.authorized += H.bioHolder.Uid
				else
					src.authorized += user
				src.authorized_registered += W:registered

				if (src.authorized.len < auth_need)
					print_auth_needed(user)
				else
					authorize()

