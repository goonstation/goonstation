// Riot computer but reflavored for the Cairngorm
TYPEINFO(/obj/machinery/computer/battlecruiser_podbay)
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_SUBTLE)

/obj/machinery/computer/battlecruiser_podbay
	name = "podbay authorization"
	icon_state = "drawbr"
	desc = "Controls access to the podbay. Use this when your team is ready to go."
	density = FALSE
	speech_verb_say = "beeps"
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD

	/// How many authentications are needed to release the shielding on the podbay. Set the first time someone clicks this.
	var/auth_need
	/// A list of the mobs who authorized.
	var/list/authorized

	light_r = 1
	light_g = 0.3
	light_b = 0.3

	/// Whether or not the podbay on the Cairngorm is authorized.
	var/authed = FALSE

	New()
		START_TRACKING
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	initialize()
		..()

	disposing()
		STOP_TRACKING
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

/obj/machinery/computer/battlecruiser_podbay/proc/authorize()
	if (src.authed)
		return
	logTheThing(LOG_STATION, src, "Cairngorm podbay access was authorized.")
	src.authed = TRUE
	src.ClearSpecificOverlays("screen_image")
	src.icon_state = "drawbr-alert"
	src.UpdateIcon()

	for_by_tcl(forcefield, /obj/forcefield/battlecruiser)
		qdel(forcefield)

	SPAWN(0.5 SECONDS)
		var/list/operative_mobs = list()
		for (var/datum/antagonist/operative as anything in (get_all_antagonists(ROLE_NUKEOP) + get_all_antagonists(ROLE_NUKEOP_COMMANDER)))
			operative_mobs += operative.owner.current
		boutput(operative_mobs,"<b>The podbay has been authorized. You may now leave the Cairngorm using your pods!</b>",forceScroll=TRUE)
		playsound_global(operative_mobs, 'sound/vox/pods.ogg', 50, vary=FALSE)
		sleep(1 SECONDS)
		playsound_global(operative_mobs, 'sound/vox/authorized.ogg', 50, vary=FALSE)


/obj/machinery/computer/battlecruiser_podbay/attack_hand(mob/user)
	return src.Attackby(null,user)

// This should happen no matter WHAT and I don't think people holding an RPG trying to auth podbay should shoot
/obj/machinery/computer/battlecruiser_podbay/attackby(var/obj/item/W, var/mob/user)
	if (!user)
		return
	if (src.authed)
		boutput(user,"The podbay has already been authorized.")
		return
	if (!src.authorized)
		src.authorized = list()

	if (!src.auth_need)
		// Works to setup auth_need here but ideally this and the SPAWN delay for autoauth get done on some universal post_setup
		src.auth_need = round(0.5 * length(get_all_antagonists(ROLE_NUKEOP) + get_all_antagonists(ROLE_NUKEOP_COMMANDER)))
		if (src.auth_need < 1)
			authorize()
			boutput(user,"Low number of agents detected. Podbay authorization granted.")
			src.authorized += user
			return

	src.add_fingerprint(user)
	var/auths_required = src.auth_need - length(src.authorized)
	var/choice = tgui_alert(user, "Would you like to authorize access to the podbay? [auths_required] authorization[s_es(auths_required)] are still needed.\nWARNING: This CANNOT be undone!", "Podbay Auth", list("Yes", "No"))
	if (BOUNDS_DIST(user, src) > 0 || src.authed)
		return
	if (choice == "Yes")
		if (user in src.authorized)
			boutput(user, "You have already authorized! [auths_required] authorization[s_es(auths_required)] from others are still needed.")
			return
		src.authorized += user

		if (length(src.authorized) < src.auth_need)
			logTheThing(LOG_STATION, user.real_name, "added an approval for podbay access. [length(src.authorized)] total approval[s_es(length(src.authorized))].")
			auths_required -= 1
			src.say("[user.real_name]'s request accepted. [auths_required] authorization[s_es(auths_required)] needed until Podbay is opened.")
		else
			src.authorize()

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
