// Riot computer but reflavored for the Cairngorm

/obj/machinery/computer/battlecruiser_podbay
	name = "podbay authorization"
	icon_state = "drawbr"
	desc = "Controls access to the podbay. Use this when your team is ready to go."
	density = FALSE
	/// How many authentications are needed to release the shielding on the podbay. Set the first time someone clicks this.
	var/auth_need
	var/list/authorized

	light_r = 1
	light_g = 0.3
	light_b = 0.3

	/// Whether or not the podbay on the Cairngorm is authorized.
	var/authed = FALSE
	/// How long until we take matters into our own hands.
	var/auth_delay = 10 MINUTES

	New()
		..()

	initialize()
		SPAWN(auth_delay)
			authorize() // If they haven't done it before auth_delay, do it for em
		..()

	disposing()
		..()

	proc/authorize()
		if(src.authed)
			return

		logTheThing(LOG_STATION, usr, "authorized Cairngorm podbay access")
		src.authed = TRUE
		src.ClearSpecificOverlays("screen_image")
		src.icon_state = "drawbr-alert"
		src.UpdateIcon()

		for_by_tcl(forcefield, /obj/forcefield/battlecruiser)
			qdel(forcefield)

		SPAWN(0.5 SECONDS)
			var/operative_mobs = list()
			for (var/datum/antagonist/operative as anything in (get_all_antagonists(ROLE_NUKEOP) + get_all_antagonists(ROLE_NUKEOP_COMMANDER)))
				operative_mobs += operative.owner.current
			boutput(operative_mobs,"<b>The podbay has been authorized. You may now leave the Cairngorm using your pods!</b>",forceScroll=TRUE)
			playsound_global(operative_mobs, 'sound/vox/pods.ogg', 50, vary=FALSE)
			sleep(1 SECONDS)
			playsound_global(operative_mobs, 'sound/vox/authorized.ogg', 50, vary=FALSE)

	proc/print_auth_needed(var/mob/author)
		if (author)
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[author.real_name]'s request accepted. [src.auth_need - length(src.authorized)] authorizations needed until Podbay is opened.\"</span></span>", 2)
		else
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[src.auth_need - length(src.authorized)] authorizations needed until Podbay is opened.\"</span></span>", 2)


/obj/machinery/computer/battlecruiser_podbay/attack_hand(mob/user)
	if (ishuman(user))
		return src.Attackby(null,user)
	..()

/// Changes auth_need to how many operatives should be used to auth. If 1 or 0, auths automatically
/obj/machinery/computer/battlecruiser_podbay/proc/determine_auth()
	var/operative_count = length(get_all_antagonists(ROLE_NUKEOP) + get_all_antagonists(ROLE_NUKEOP_COMMANDER))
	var/required = round(operative_count * 0.5)
	if (required < 2)
		authorize()
	src.auth_need = required

// This should happen no matter WHAT and I don't think people holding an RPG trying to auth podbay should shoot
/obj/machinery/computer/battlecruiser_podbay/attackby(var/obj/item/W, var/mob/user)
	if(!auth_need)
		determine_auth()
		if (authed)
			src.authorized += user
			return
	if (!user)
		return
	if (authed)
		boutput(user,"The podbay has already been authorized.")
		return

	src.add_fingerprint(user)
	if (!src.authorized)
		src.authorized = list()

	var/choice = tgui_alert(user, "Would you like to authorize access to the podbay? [src.auth_need - length(src.authorized)] authorization\s are still needed.\nWARNING: This CANNOT be undone!", "Podbay Auth", list("Yes", "No"))
	if(BOUNDS_DIST(user, src) > 0 || src.authed)
		return
	if (choice == "Yes")
		if (user in src.authorized)
			boutput(user, "You have already authorized! [src.auth_need - length(src.authorized)] authorizations from others are still needed.")
			return
		src.authorized += user
		if (length(src.authorized) < auth_need)
			logTheThing(LOG_STATION, user?.real_name, "added an approval for podbay access. [length(src.authorized)] total approvals.")
			print_auth_needed(user)
		else
			authorize()

/obj/forcefield/battlecruiser
	name = "podbay barrier"
	desc = "An impenetrable forcefield designed to make you wait. It is controlled by an authorization computer."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "shieldw"
	color = "#FF6666"

	New()
		START_TRACKING
		..()

	disposing()
		STOP_TRACKING
		..()
