// FLOCK INTANGIBLE MOB PARENT
// for shared things, like references to flocks and vision modes and general intangibility and swapping into drones

/mob/living/intangible/flock
	name = "caw"
	desc = "please report this to a coder you shouldn't see this"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "flockmind"

	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = 1
	use_stamina = 0//no puff tomfuckery
	respect_view_tint_settings = TRUE
	var/compute = 0
	var/datum/flock/flock = null
	var/wear_id = null // to prevent runtimes from AIs tracking down radio signals

	var/afk_counter = 0
	var/turf/previous_turf = null

/mob/living/intangible/flock/New()
	..()
	src.appearance_flags |= NO_CLIENT_COLOR
	src.blend_mode = BLEND_ADD
	APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_FLOCK)
	APPLY_ATOM_PROPERTY(src, PROP_MOB_AI_UNTRACKABLE, src)
	src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	src.see_invisible = INVIS_FLOCK
	src.see_in_dark = SEE_DARK_FULL
	/// funk that color matrix up, my friend
	src.apply_color_matrix(COLOR_MATRIX_FLOCKMIND, COLOR_MATRIX_FLOCKMIND_LABEL, TRUE)
	//src.render_special.set_centerlight_icon("flockvision", "#09a68c", BLEND_OVERLAY, PLANE_FLOCKVISION, alpha=196)
	//src.render_special.set_widescreen_fill(color="#09a68c", plane=PLANE_FLOCKVISION, alpha=196)
	src.previous_turf = get_turf(src)

/mob/living/intangible/flock/Login()
	..()
	src.flock?.showAnnotations(src)
	if(src.client)
		// where we're going we don't need shadows or light
		var/atom/plane = src.client.get_plane(PLANE_LIGHTING)
		if (plane)
			plane.alpha = 0
		plane = src.client.get_plane(PLANE_SELFILLUM)
		if (plane)
			plane.alpha = 0
		plane = src.client.get_plane(PLANE_FLOCKVISION)
		if (plane)
			plane.alpha = 255

/mob/living/intangible/flock/Logout()
	if(src.client)
		var/atom/plane = src.client.get_plane(PLANE_LIGHTING)
		if (plane)
			plane.alpha = 255
		plane = src.client.get_plane(PLANE_SELFILLUM)
		if (plane)
			plane.alpha = 255
		plane = src.client.get_plane(PLANE_FLOCKVISION)
		if (plane)
			plane.alpha = 0
	..()

/mob/living/intangible/flock/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	if (src.client)
		src.antagonist_overlay_refresh(0, 0)
	if (get_turf(src) == src.previous_turf)
		src.afk_counter += parent.schedule_interval
	else
		src.afk_counter = 0
		src.previous_turf = get_turf(src)

/mob/living/intangible/flock/death(datum/controller/process/mobs/parent)
	var/datum/abilityHolder/flockmind/AH = src.abilityHolder
	if (AH.drone_controller.drone)
		AH.drone_controller.cast(AH.drone_controller.drone)
		src.targeting_ability = null
	..()

/mob/living/intangible/flock/is_spacefaring() return 1
/mob/living/intangible/flock/say_understands() return 1
/mob/living/intangible/flock/can_use_hands() return 0

/mob/living/intangible/flock/movement_delay()
	if (src.client && src.client.check_key(KEY_RUN))
		return 0.4 + movement_delay_modifier
	else
		return 0.75 + movement_delay_modifier

/mob/living/intangible/flock/attack_hand(mob/user)
	switch(user.a_intent)
		if(INTENT_HELP)
			user.visible_message("<span class='notice'>[user] waves at [src.name].</span>", "<span class='notice'>You wave at [src.name].</span>")
		if(INTENT_DISARM)
			user.visible_message("<span class='alert'>[user] tries to shove [src.name], but their hand goes right through.</span>",
				"<span class='alert'>You try to shove [src.name] but they're intangible! You just push air!</span>")
			if(prob(5))
				user.visible_message("<span class='alert bold'>[user] tries to shove [src.name], but overbalances and falls over!</span>",
				"<span class='alert bold'>You try to shove [src.name] too forcefully and topple over!</span>")
				user.changeStatus("weakened", 2 SECONDS)
		if(INTENT_GRAB)
			user.visible_message("<span class='alert'>[user] tries to grab [src.name], but they're only a trick of light!</span>",
				"<span class='alert'>You try to grab [src.name] but they're intangible! It's like trying to pull a cloud!</span>")
		if(INTENT_HARM)
			user.visible_message("<span class='alert'>[user] tries to smack [src.name], but the blow connects with nothing!</span>",
				"<span class='alert'>You try to smack [src.name] but they're intangible! Nothing can be achieved this way!</span>")

/mob/living/intangible/flock/attackby(obj/item/W, mob/user)
	switch(user.a_intent)
		if(INTENT_HARM)
			user.visible_message("<span class='alert'>[user] tries to hit [src.name] with [W], pointlessly.</span>", "<span class='notice'>You try to hit [src.name] with [W] but it just passes through.</span>")
		else
			user.visible_message("<span class='notice'>[user] waves [W] at [src.name].</span>", "<span class='notice'>You wave [W] at [src].</span>")

// might as well give a dumb gimmick reaction to the ectoplasmic destabiliser
/mob/living/intangible/flock/projCanHit(datum/projectile/P)
	return P.hits_ghosts

/mob/living/intangible/flock/Cross(atom/movable/mover)
	if (istype(mover, /obj/projectile))
		var/obj/projectile/proj = mover
		if (istype(proj.proj_data, /datum/projectile/energy_bolt_antighost))
			return 0
	return 1

/mob/living/intangible/flock/bullet_act(var/obj/projectile/P)
	// HAAAAA
	src.visible_message("<span class='alert'>[src] is not a ghost, and is therefore unaffected by [P]!</span>","<span class='notice'>You feel a little [pick("less", "more")] [pick("fuzzy", "spooky", "glowy", "flappy", "bouncy")].</span>")

/mob/living/intangible/flock/click(atom/target, params)
	if (targeting_ability)
		..()
		return

	if (GET_DIST(src, target) > 0)
		set_dir(get_dir(src, target))

	if (abilityHolder.click(target, params)) //check the abilityholder
		return

	if (params["alt"]) //explicit examine
		src.examine_verb(target)
		return

	if (istype(target, /mob/living/critter/flock/drone))
		var/mob/living/critter/flock/drone/flockdrone = target
		if (!isdead(flockdrone))
			if (flockdrone.selected_by || flockdrone.controller)
				boutput(src, "<span class='alert'>This drone is receiving a command!</span>")
				return
			flockdrone.selected_by = src
			var/datum/abilityHolder/flockmind/holder = src.abilityHolder
			holder.drone_controller.drone = flockdrone
			flockdrone.AddComponent(/datum/component/flock_ping/selected)
			src.targeting_ability = holder.drone_controller
			src.update_cursor()
			return
	//moved from flock_structure_ghost for interfering with ability targeting
	else if (istype(target, /obj/flock_structure/ghost))
		if (tgui_alert(usr, "Cancel tealprint construction?", "Tealprint", list("Yes", "No")) == "Yes")
			var/obj/flock_structure/ghost/tealprint = target
			tealprint.cancelBuild()
		return

	src.examine_verb(target) //default to examine

/mob/living/intangible/flock/say_quote(var/text)
	var/speechverb = pick("sings", "clicks", "whistles", "intones", "transmits", "submits", "uploads")
	return "[speechverb], \"[text]\""

/mob/living/intangible/flock/get_heard_name()
	return "<span class='name' data-ctx='\ref[src.mind]'>[src.real_name]</span>"

/mob/living/intangible/flock/say(message, involuntary = 0)
	if (!message || message == "" || stat)
		return
	if (src.client && src.client.ismuted())
		boutput(src, "You are currently muted and may not speak.")
		return

	if (dd_hasprefix(message, "*"))
		return src.emote(copytext(message, 2),1)

	if (isdead(src))
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		return src.say_dead(message)

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	logTheThing(LOG_DIARY, src, ": [message]", "say")

	var/prefixAndMessage = separate_radio_prefix_and_message(message)
	message = prefixAndMessage[2]

	flock_speak(src, message, src.flock)

/mob/living/intangible/flock/get_tracked_examine_atoms()
	return ..() + src.flock.structures

// why this isn't further up the tree i have no idea
/mob/living/intangible/flock/emote(var/act, var/voluntary = 0)

	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		act = copytext(act, 1, t1)

	var/message = ""
	var/m_type = 0
	switch (lowertext(act))
		if ("flip")
			if (src.emote_check(voluntary, 50))
				message = "<span class='emote'><b>[src]</B> does a flip!</span>"
				m_type = 1
				animate_spin(src, pick("L", "R"), 1, 0)
		if ("scream", "caw")
			if (src.emote_check(voluntary, 50))
				message = "<span class='emote'><b>[src]</B> caws!</span>"
				m_type = 2
				playsound(src, 'sound/misc/flockmind/flockmind_caw.ogg', 60, 1, channel=VOLUME_CHANNEL_EMOTE)

	if (message)
		logTheThing(LOG_SAY, src, "EMOTE: [message]")
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
		else if (!isturf(src.loc))
			var/atom/A = src.loc
			for (var/mob/O in A.contents)
				O.show_message(message, m_type)


/mob/living/intangible/flock/proc/createstructure(obj/flock_structure/structure_type, resources = 0)
	new /obj/flock_structure/ghost(get_turf(src), src.flock, structure_type, resources)

//compute - override if behaviour is weird
/mob/living/intangible/flock/proc/compute_provided()
	return src.compute

//moved from flockmind to allow traces to teleport
/mob/living/intangible/flock/flockmind/Topic(href, href_list)
	if(href_list["origin"])
		var/atom/movable/origin = locate(href_list["origin"])
		if(!QDELETED(origin))
			if (istype(origin, /mob/living/critter/flock/drone))
				var/mob/living/critter/flock/drone/flockdrone = origin
				if (flockdrone.flock != src.flock)
					return
			src.set_loc(get_turf(origin))
			if (href_list["ping"])
				origin.AddComponent(/datum/component/flock_ping)
