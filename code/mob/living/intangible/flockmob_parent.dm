// FLOCK INTANGIBLE MOB PARENT
// for shared things, like references to flocks and vision modes and general intangibility and swapping into drones

/// The relay is under construction
#define STAGE_UNBUILT 0
/// The relay has been built
#define STAGE_BUILT 1
/// The relay is about to transmit the Signal
#define STAGE_CRITICAL 2
/// The relay either transmitted the Signal, or was otherwise destroyed
#define STAGE_DESTROYED 3

/mob/living/intangible/flock
	name = "caw"
	desc = "please report this to a coder you shouldn't see this"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "flockmind"

	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = ANCHORED
	use_stamina = 0//no puff tomfuckery
	respect_view_tint_settings = TRUE
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	var/compute = 0
	var/tmp/datum/flock/flock = null
	var/wear_id = null // to prevent runtimes from AIs tracking down radio signals

	var/afk_counter = 0
	var/turf/previous_turf = null

	var/datum/hud/flock_intangible/custom_hud = /datum/hud/flock_intangible
	var/hud

/mob/living/intangible/flock/New()
	..()
	src.appearance_flags |= NO_CLIENT_COLOR
	src.blend_mode = BLEND_ADD
	APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_FLOCK)
	APPLY_ATOM_PROPERTY(src, PROP_MOB_AI_UNTRACKABLE, src)
	src.see_invisible = INVIS_FLOCK
	src.see_in_dark = SEE_DARK_FULL
	/// funk that color matrix up, my friend
	src.apply_color_matrix(COLOR_MATRIX_FLOCKMIND, COLOR_MATRIX_FLOCKMIND_LABEL, TRUE)
	//src.render_special.set_centerlight_icon("flockvision", "#09a68c", BLEND_OVERLAY, PLANE_FLOCKVISION, alpha=196)
	//src.render_special.set_widescreen_fill(color="#09a68c", plane=PLANE_FLOCKVISION, alpha=196)
	src.previous_turf = get_turf(src)
	src.hud = new custom_hud(src)
	src.attach_hud(src.hud)

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


/mob/living/intangible/flock/Move(NewLoc, direct)
	if (istype(NewLoc, /turf/cordon))
		return FALSE
	..()

/mob/living/intangible/flock/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	if (!src.flock.z_level_check(src))
		src.emote("scream")
		if (length(src.flock.units[/mob/living/critter/flock/drone]))
			boutput(src, SPAN_ALERT("You feel your consciousness weakening as you are ripped further from your drones, you retreat back to them to save yourself!"))
			var/mob/living/critter/flock/unit = pick(src.flock.units[/mob/living/critter/flock/drone])
			src.set_loc(get_turf(unit))
		else
			boutput(src, SPAN_ALERT("You feel your consciousness weakening as you are ripped further from your entrypoint, you retreat back to it to save yourself!"))
			src.set_loc(pick_landmark(LANDMARK_OBSERVER, locate(150,150, Z_LEVEL_STATION)))

	if (src.flock?.relay_finished)
		return TRUE
	if (get_turf(src) == src.previous_turf)
		src.afk_counter += parent.schedule_interval
	else
		src.afk_counter = 0
		src.previous_turf = get_turf(src)

/mob/living/intangible/flock/death(datum/controller/process/mobs/parent)
	var/datum/abilityHolder/flockmind/AH = src.abilityHolder
	if (AH.drone_controller.drone)
		AH.drone_controller.cast(AH.drone_controller.drone, FALSE)
	..()

/mob/living/intangible/flock/is_spacefaring() return 1
/mob/living/intangible/flock/say_understands() return 1
/mob/living/intangible/flock/can_use_hands() return 0

/mob/living/intangible/flock/movement_delay()
	if (src.client && src.client.check_key(KEY_RUN))
		return 0.4 + movement_delay_modifier
	else
		return 0.75 + movement_delay_modifier

/mob/living/intangible/flock/Move(NewLoc, direct)
	src.set_dir(get_dir(src, NewLoc))
	..()

/mob/living/intangible/flock/attack_hand(mob/user)
	switch(user.a_intent)
		if(INTENT_HELP)
			user.visible_message(SPAN_NOTICE("[user] waves at [src.name]."), SPAN_NOTICE("You wave at [src.name]."))
		if(INTENT_DISARM)
			user.visible_message(SPAN_ALERT("[user] tries to shove [src.name], but their hand goes right through."),
				SPAN_ALERT("You try to shove [src.name] but they're intangible! You just push air!"))
			if(prob(5))
				user.visible_message("<span class='alert bold'>[user] tries to shove [src.name], but overbalances and falls over!</span>",
				"<span class='alert bold'>You try to shove [src.name] too forcefully and topple over!</span>")
				user.changeStatus("knockdown", 2 SECONDS)
		if(INTENT_GRAB)
			user.visible_message(SPAN_ALERT("[user] tries to grab [src.name], but they're only a trick of light!"),
				SPAN_ALERT("You try to grab [src.name] but they're intangible! It's like trying to pull a cloud!"))
		if(INTENT_HARM)
			user.visible_message(SPAN_ALERT("[user] tries to smack [src.name], but the blow connects with nothing!"),
				SPAN_ALERT("You try to smack [src.name] but they're intangible! Nothing can be achieved this way!"))

/mob/living/intangible/flock/attackby(obj/item/W, mob/user)
	switch(user.a_intent)
		if(INTENT_HARM)
			user.visible_message(SPAN_ALERT("[user] tries to hit [src.name] with [W], pointlessly."), SPAN_NOTICE("You try to hit [src.name] with [W] but it just passes through."))
		else
			user.visible_message(SPAN_NOTICE("[user] waves [W] at [src.name]."), SPAN_NOTICE("You wave [W] at [src]."))

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
	src.visible_message(SPAN_ALERT("[src] is not a ghost, and is therefore unaffected by [P]!"),SPAN_NOTICE("You feel a little [pick("less", "more")] [pick("fuzzy", "spooky", "glowy", "flappy", "bouncy")]."))

/mob/living/intangible/flock/proc/select_drone(mob/living/critter/flock/drone/drone)
	var/datum/abilityHolder/flockmind/holder = src.abilityHolder
	holder.drone_controller.drone = drone
	drone.selected_by = src
	drone.AddComponent(/datum/component/flock_ping/selected)
	src.targeting_ability = holder.drone_controller
	src.update_cursor()

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
				boutput(src, SPAN_ALERT("This drone is receiving a command!"))
				return
			src.select_drone(flockdrone)
			return
	//moved from flock_structure_ghost for interfering with ability targeting
	else if (istype(target, /obj/flock_structure/ghost))
		var/obj/flock_structure/ghost/tealprint = target
		var/typeinfo/obj/flock_structure/info = get_type_typeinfo(tealprint.building)
		if (!info.cancellable)
			return
		if (!tealprint.fake && tgui_alert(usr, "Cancel tealprint construction?", "Tealprint", list("Yes", "No")) == "Yes")
			tealprint.cancelBuild()
		return

	else if (istype(target, /obj/machinery/door/feather))
		var/obj/machinery/door/feather/door = target
		if (door.density)
			door.open()
		else
			door.close()
		return

	src.examine_verb(target) //default to examine

/mob/living/intangible/flock/say_quote(var/text)
	var/speechverb = pick("sings", "clicks", "whistles", "intones", "transmits", "submits", "uploads")
	return "[speechverb], \"[text]\""

/mob/living/intangible/flock/get_heard_name(just_name_itself=FALSE)
	if (just_name_itself)
		return src.real_name
	return "<span class='name' data-ctx='\ref[src.mind]'>[src.real_name]</span>"

/mob/living/intangible/flock/say(message, involuntary = 0)
	if (!message || message == "" || stat)
		return
	if (src.client && src.client.ismuted())
		boutput(src, "You are currently muted and may not speak.")
		return
	SEND_SIGNAL(src, COMSIG_MOB_SAY, message)
	if (dd_hasprefix(message, "*"))
		return src.emote(copytext(message, 2),1)

	if (isdead(src))
		message = trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		return src.say_dead(message)

	message = trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	logTheThing(LOG_DIARY, src, ": [message]", "say")

	var/prefixAndMessage = separate_radio_prefix_and_message(message)
	message = prefixAndMessage[2]

	flock_speak(src, message, src.flock)

/mob/living/intangible/flock/get_tracked_examine_atoms()
	return ..() + src.flock.structures

// why this isn't further up the tree i have no idea
/mob/living/intangible/flock/emote(var/act, var/voluntary = 0)
	..()
	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		act = copytext(act, 1, t1)

	var/message = ""
	var/m_type = 0
	switch (lowertext(act))
		if ("flip")
			if (src.emote_check(voluntary, 50))
				message = SPAN_EMOTE("<b>[src]</B> does a flip!")
				m_type = 1
				animate_spin(src, pick("L", "R"), 1, 0)
		if ("scream", "caw")
			if (src.emote_check(voluntary, 50))
				message = SPAN_EMOTE("<b>[src]</B> caws!")
				m_type = 2
				playsound(src, 'sound/misc/flockmind/flockmind_caw.ogg', 60, TRUE, channel=VOLUME_CHANNEL_EMOTE)

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
/mob/living/intangible/flock/Topic(href, href_list)
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

/// Relay HUD icon for flockminds and player-controlled flockdrones to show progress towards objective
/atom/movable/screen/hud/relay
	name = "Relay Progress"
	desc = ""
	icon = 'icons/mob/flock_ui.dmi'
	icon_state = "structure-relay"
	screen_loc = "NORTH, EAST-1"
	alpha = 0

/// Update everything about the icon and description
/atom/movable/screen/hud/relay/proc/update_value(new_stage = null, new_alpha = null, new_desc = null)
	if (new_desc)
		src.desc = new_desc
	if (new_alpha)
		src.alpha = new_alpha
	if (!new_stage)
		return

	switch (new_stage)
		if (STAGE_BUILT)
			src.icon_state = "structure-relay-glow"
			src.alpha = 255
		if (STAGE_CRITICAL)
			src.icon_state = "structure-relay-glow"
			src.alpha = 255
			var/image/sparks = new(src.icon, icon_state = "structure-relay-sparks")
			src.overlays += sparks
		if (STAGE_DESTROYED)
			qdel(src)
	src.UpdateIcon()

/atom/movable/screen/hud/relay/MouseEntered(location, control, params)
	if (src.alpha < 50)
		return // if you can't see the icon why bother
	src.update_value()
	usr.client.tooltipHolder.showHover(src, list(
		"params" = params,
		"title" = src.name,
		"content" = (src.desc ? src.desc : null),
		"theme" = "flock"
	))

/// Back of the relay HUD icon
/atom/movable/screen/hud/relay_back
	name = ""
	desc = ""
	icon = 'icons/mob/flock_ui.dmi'
	icon_state = "template-full"
	screen_loc = "NORTH, EAST-1"

#undef STAGE_UNBUILT
#undef STAGE_BUILT
#undef STAGE_CRITICAL
#undef STAGE_DESTROYED
