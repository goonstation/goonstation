//miscellaneous surplus objects
//Contents:
//loadout spawners
//prefab plasmaglass/wood spear
//surplus medical beaker
//surplus deployment computer and teleporter

/obj/surplusopspawner //borrowing attributes from the random objects spawner
	name = "surplus spawner"
	icon = 'icons/obj/objects.dmi'
	icon_state = "itemspawn"
	density = 0
	anchored = 1.0
	invisibility = INVIS_ALWAYS
	layer = 99

	New()
		..()
		qdel(src)

/obj/surplusopspawner/loadout_shortgun_spawner
	name = "shortgun loadout spawner"

	New()

		new /obj/random_item_spawner/surplus/shortgun(src.loc)
		new /obj/random_item_spawner/surplus/melee(src.loc)
		new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
		..()

/obj/random_item_spawner/surplus/melee/withcredits
	New()

		SPAWN(1 DECI SECOND)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
		..()
/obj/item/reagent_containers/glass/beaker/large/surplusmedical
	name = "Doctor Schmidt's Super Mega Restoration Jungle Juice"
	desc = "A beaker containing a supposed panacea. It smells weird and the glass feels sticky."
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


	New()
		for_by_tcl(D, /obj/submachine/surplusopdeployer)
			src.ourportal = D //connect to portal
		..()



//account for both empty and full hand authorizations
	attackby(var/obj/item/W, var/mob/user)
		authaction(user)
		..()
	attack_hand(mob/user)
		authaction(user)
		..()
// what goes down when you try to auth- stolen from armory code
	proc/authaction(var/mob/user)

		if (!user)
			return
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


				if (src.authorized.len < auth_need)
					print_auth_needed(user)
				else
					authorize()

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

/obj/submachine/surplusopdeployer
	icon = 'icons/obj/teleporter.dmi'
	icon_state = "syndtele"
	name = "Old portal ring"
	desc = "An outdated and unstable portal ring model, locked in to a preset location."
	density = TRUE
	var/active = FALSE //can we go yet?

	Bumped(atom/movable/M as mob|obj)
		if(active)
			do_teleport(M, pick_landmark(LANDMARK_LATEJOIN)) //put them at the latejoin for now- CHANGE THIS LATER

