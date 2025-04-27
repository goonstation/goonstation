/mob
	density = 1
	layer = MOB_LAYER
	animate_movement = 2
	soundproofing = 10

	flags = FLUID_SUBMERGE

	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE | LONG_GLIDE

	var/tmp/datum/mind/mind
	var/mob/boutput_relay_mob = null

	var/datacore_id = null

	var/datum/abilityHolder/abilityHolder = null
	var/datum/bioHolder/bioHolder = null
	var/datum/appearanceHolder/AH_we_spawned_with = null	// Used to colorize things that need to be colorized before the player notices they aren't

	var/targeting_ability = null

	var/last_move_trigger = 0

	var/atom/movable/screen/internals = null
	var/atom/movable/screen/stamina_bar/stamina_bar = null

	var/robot_talk_understand = 0

	var/respect_view_tint_settings = FALSE
	var/list/active_color_matrix = null
	var/list/color_matrices = null

	var/last_resist = 0

	//var/atom/movable/screen/zone_sel/zone_sel = null
	var/datum/hud/zone_sel/zone_sel = null
	var/atom/movable/name_tag/name_tag
	var/atom/atom_hovered_over = null

	var/custom_gib_handler = null
	var/obj/decal/cleanable/custom_vomit_type = /obj/decal/cleanable/vomit

	var/list/mob/dead/target_observer/observers = null

	var/emote_allowed = 1
	var/last_emote_time = 0
	var/last_emote_wait = 0
	var/emotes_on_cooldown = FALSE
	var/computer_id = null
	var/datum/weakref/lastattacker = null
	var/datum/weakref/lastattacked = null //tell us whether or not to use Combat or Default click delays depending on whether this var was set.
	var/lastattackertime = 0
	var/other_mobs = null
	var/memory = ""
	var/atom/movable/pulling = null
	var/stat = STAT_ALIVE
	var/next_click = 0
	var/transforming = null
	var/hand = 0
	var/eye_blind = null
	var/eye_blurry = null
	var/eye_damage = null
	var/ear_deaf = null
	var/ear_damage = null
	var/ear_disability = null
	var/stuttering = null
	var/real_name = null
	var/blinded = null
	var/disfigured = FALSE
	var/vdisfigured = FALSE
	var/druggy = 0
	var/sleeping = 0
	var/lying = 0
	var/lying_old = 0
	var/can_lie = 0
	var/canmove = 1
	var/incrit = 0
	var/timeofdeath = 0
	var/fakeloss = 0
	var/fakedead = 0
	var/health = 100
	var/max_health = 100
	var/bodytemperature = T0C + 37
	var/base_body_temp = T0C + 37
	var/temp_tolerance = 15 // iterations between each temperature state
	var/thermoregulation_mult = 0.025 // how quickly the body's temperature tries to correct itself, higher = faster
	var/innate_temp_resistance = 0.16  // how good the body is at resisting environmental temperature, lower = more resistant
	var/dizziness = 0
	var/is_dizzy = 0
	var/is_jittery = 0
	var/is_zombie = 0
	var/jitteriness = 0
	var/charges = 0
	var/nutrition = 100
	var/losebreath = 0
	var/intent = null
	var/a_intent = "help"
	var/m_intent = "run"
	var/lastKnownIP = null
	var/obj/stool/buckled = null
	var/obj/item/handcuffs/handcuffs = null
	var/obj/item/l_hand = null
	var/obj/item/r_hand = null
	var/obj/item/back = null
	var/obj/item/tank/internal = null
	var/obj/item/clothing/mask/wear_mask = null
	var/obj/item/clothing/ears/ears = null
	var/network_device = null
	var/Vnetwork = null
	var/lastDamageIconUpdate
	var/say_language = "english"
	var/literate = 1 // im liturit i kin reed an riet

	var/list/movement_modifiers = list()

	var/misstep_chance = 0

	var/datum/hud/storage/s_active

	var/respawning = 0

	var/list/obj/item/grab/grabbed_by = null

	var/datum/traitHolder/traitHolder = null

	var/inertia_dir = 0
	var/footstep = 1

	var/music_lastplayed = "null"

	var/deathhunted = null

	var/job = null

	/// For assigning mobs various factions, see factions.dm for definitions
	var/faction = list()

	var/nodamage = 0

	var/spellshield = 0

	var/voice_name = "unidentifiable voice"
	var/voice_message = null
	var/oldname = null
	var/mob/oldmob = null
	var/datum/mind/oldmind = null
	var/mob/dead/observer/ghost = null
	var/attack_alert = 0 // should we message admins when attacking another player?
	var/suicide_alert = 0 // should we message admins when dying/dead?

	var/speechverb_say = "says"
	var/speechverb_ask = "asks"
	var/speechverb_exclaim = "exclaims"
	var/speechverb_stammer = "stammers"
	var/speechverb_gasp = "gasps"
	var/speech_void = 0
	var/now_pushing = null //temp. var used for bump()
	var/atom/movable/pushing = null //Keep track of something we may be pushing for speed reductions (GC Woes)
	var/singing = 0 // true when last thing living mob said was sung, i.e. prefixed with "%""

	var/movement_delay_modifier = 0 //Always applied.
	var/restrain_time = 0 //we are restrained ; time at which we will be freed.  (using timeofday)

//Disease stuff
	var/list/resistances = null
	var/list/ailments = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/atom/eye = null
	var/eye_pixel_x = 0
	var/eye_pixel_y = 0
	var/loc_pixel_x = 0
	var/loc_pixel_y = 0

	var/icon/cursor = null

	var/list/datum/hud/huds = null

	var/tmp/client/last_client // actually the current client, used by Logout due to BYOND
	var/last_ckey
	var/logout_at = null
	var/joined_date = null
	mat_changename = 0
	mat_changedesc = 0

	//Used for combat melee messages (e.g. "Foo punches Bar!")
	var/punchMessage = "punches"
	var/kickMessage = "kicks"

	var/datum/hud/render_special/render_special

	// does not allow non-admins to observe them voluntarily
	var/unobservable = 0

	var/mob_flags = 0
	var/skipped_mobs_list = 0
	var/click_delay = DEFAULT_CLICK_DELAY
	var/combat_click_delay = COMBAT_CLICK_DELAY

	var/last_cubed = 0

	var/datum/movement_controller/override_movement_controller = null

	var/dir_locked = FALSE


	var/last_move_dir = null

	/// Type path for the ai holder. Set to have the aiHolder instantiated on New()
	var/ai_type = null
	/// AI controller for this mob - only active if is_npc is TRUE, in which case it's called by the mobAI loop at a frequency depending on mob flags
	var/datum/aiHolder/ai = null
	///Do we add the special "Toggle AI" ability to this mob?
	var/use_ai_toggle = TRUE
	/// used for load balancing mob_ai ticks
	var/ai_tick_schedule = null

	var/last_pulled_time = 0

	/// stores total accumulated radiation dose
	var/radiation_dose = 0
	/// natural decay of radiation exposure
	var/radiation_dose_decay = 0.02 //at this rate, assuming no lag, it will take 40 life ticks, or ~80 seconds to recover naturally from 1st stage radiation posioning,
	/// last time this mob got dosed with radiation
	var/last_radiation_dose_time = 0
	/// set to observed mob if you're currently observing a mob, otherwise null
	var/mob/observing = null
	/// A list of emotes that trigger a special action for this mob
	var/list/trigger_emotes = null
	/// If TRUE then this mob won't be fully stunned by stamina stuns
	var/no_stamina_stuns = FALSE
	///A flag set temporarily when a mob is being forced to say something, used to avoid HORRIBLE SPAGHETTI in say logging. I'm sorry okay.
	var/being_controlled = FALSE
	///Lazy inited list of custom vomit behaviours from reagents, organs etc.
	var/list/datum/vomit_behavior/vomit_behaviors = null

	/// if this mob can interface with pod context menu by left clicking
	var/can_interface_with_pods = TRUE

//obj/item/setTwoHanded calls this if the item is inside a mob to enable the mob to handle UI and hand updates as the item changes to or from 2-hand
/mob/proc/updateTwoHanded(var/obj/item/I, var/twoHanded = 1)
	return 0 //0=couldnt do it(other hand full etc), 1=worked just fine.

// mob procs
/mob/New(loc, datum/appearanceHolder/AH_passthru)	// I swear Adhara is the reason half my code even comes close to working
	src.AH_we_spawned_with = AH_passthru
	src.loc = loc
	grabbed_by = new
	resistances = new
	ailments = new
	huds = new
	render_special = new
	traitHolder = new(src)


	if (!src.bioHolder)
		src.bioHolder = new /datum/bioHolder(src)
		src.initializeBioholder()
	attach_hud(render_special)

	if(src.ai_type)
		src.ai = new src.ai_type(src)

	var/turf/T = get_turf(src)
	var/area/AR = get_area(src)
	if(isnull(T) || T.z <= Z_LEVEL_STATION || AR.active)
		mobs.Add(src)
	else if(!(src.mob_flags & LIGHTWEIGHT_AI_MOB) && (!src.ai || !src.ai.exclude_from_mobs_list))
		skipped_mobs_list |= SKIPPED_MOBS_LIST
		LAZYLISTADDUNIQUE(AR.mobs_not_in_global_mobs_list, src)

	src.lastattacked = get_weakref(src) //idk but it fixes bug
	render_target = "\ref[src]"
	src.chat_text = new(null, src)

	src.name_tag = new
	src.update_name_tag()
	src.vis_contents += src.name_tag
	START_TRACKING
	. = ..()

/// do you want your mob to have custom hairstyles and stuff? don't use spawns but set all of those properties here
/mob/proc/initializeBioholder()
	SHOULD_CALL_PARENT(TRUE)
	src.bioHolder?.mobAppearance.gender = src.gender
	return

/mob/proc/is_spacefaring()
	return 0

/mob/Move(a, b, flag)
	if (src.buckled?.anchored && istype(src.buckled))
		return

	var/orig_dir = src.dir

	//for item specials
	if (src.restrain_time > TIME)
		return

	if (src.buckled && istype(src.buckled))
		var/glide_size = src.glide_size
		src.buckled.Move(a, b, flag)
		src.buckled.glide_size = glide_size // dumb hack
	else
		. = ..()

	src.contextActionsOnMove()

	src.update_grab_loc()

	if (src.s_active && !(s_active.master?.linked_item in src))
		src.detach_hud(src.s_active)
		src.s_active = null

	if(src.dir_locked && src.dir != orig_dir)
		src.dir = orig_dir

/mob/proc/update_grab_loc()
	//robust grab : keep em close
	for (var/obj/item/grab/G in equipped_list(check_for_magtractor = 0))
		if (G.state < GRAB_AGGRESSIVE) continue
		if (BOUNDS_DIST(src, G.affecting) > 0)
			qdel(G)
			continue
		if (G.affecting.buckled) continue
		G.affecting.animate_movement = SYNC_STEPS
		G.affecting.glide_size = src.glide_size
		G.set_affected_loc()
		G.affecting.glide_size = src.glide_size

/mob/disposing()
	STOP_TRACKING

	qdel(src.name_tag)
	src.name_tag = null

	if(src.skipped_mobs_list)
		skipped_mobs_list = 0
		var/area/AR = get_area(src)
		AR?.mobs_not_in_global_mobs_list?.Remove(src)

	qdel(chat_text)
	chat_text = null

	// this looks sketchy, but ghostize is fairly safe- we check for an existing ghost or NPC status, and only make a new ghost if we need to
	src.ghost = src.ghostize()
	if (src.ghost?.corpse == src)
		src.ghost.corpse = null

	for(var/mob/dead/target_observer/TO in observers)
		LAZYLISTREMOVE(observers, TO)
		TO.ghostize()

	for(var/mob/m in src) //aieyes, other terrible code
		if(m.observing == src)
			m.stopObserving()
		else
			m.set_loc(src.loc)
			m.ghostize()

	if (traitHolder)
		traitHolder.removeAll()
		traitHolder.owner = null
	traitHolder = null

	if (bioHolder)
		bioHolder.dispose()
		bioHolder.owner = null
		bioHolder = null

	for (var/datum/hud/H in huds)
		for (var/atom/movable/screen/hud/S in H.objects)
			if (S:master == src)
				S:master = null
//KYLE: KEELIN, LOOK. Something like this? I dunno, it's so slow too:
		// for (var/atom/movable/screen/S in H.objects)
		// 	if (istype(S, /atom/movable/screen/hud))
		// 		if (S:master == src)
		// 			S:master = null
		// 	else if (istype(S, /atom/movable/screen/statusEffect))
		// 		src.delStatus(S:ownerStatus)

		//if (islist(H.objects)) //possibly causing bug where gibbed persons UI persistss on ghosts
		//	H.objects.len = 0
		detach_hud(H)
		H.mobs -= src


	if (src.abilityHolder)
		src.abilityHolder.dispose()
		src.abilityHolder = null

	if (src.targeting_ability)
		src.targeting_ability = null

	if(src.item_abilities)
		src.item_abilities:len = 0
		src.item_abilities = null

	if (zone_sel)
		if (zone_sel.master == src)
			zone_sel.master = null
	zone_sel = null

	if(src.contextLayout)
		src.contextLayout.dispose()
		src.contextLayout = null

	if (src.buckled)
		src.buckled.buckled_guy = null

	for(var/obj/item/grab/G in src.grabbed_by)
		qdel(G)

	mobs.Remove(src)

	if (src.ai)
		qdel(ai)
		ai = null

	mind = null
	ckey = null
	client = null
	internals = null
	buckled = null
	handcuffs = null
	l_hand = null
	r_hand = null
	back = null
	internal = null
	s_active = null
	wear_mask = null
	ears = null
	grabbed_by = null
	oldmob = null
	oldmind = null
	ghost = null
	resistances = null
	ailments = null
	cooldowns = null
	lastattacked = null
	lastattacker = null
	health_update_queue -= src

	for(var/x in src)
		qdel(x)
	if(hasvar(src, "hud")) // ew
		qdel(src.vars["hud"])
		src.vars["hud"] = null

	..()

/mob/Login()
	if (isnull(src.client))
		return
		// Guests that get deleted, is how
		// stack_trace("mob/Login called without a client for mob [identify_object(src)]. What?")
	if(isnull(src.client.tg_layout))
		src.client.tg_layout = winget( src.client, "menu.tg_layout", "is-checked" ) == "true"
	src.client.set_layout(src.client.tg_layout)
	if(src.skipped_mobs_list)
		var/area/AR = get_area(src)
		AR?.mobs_not_in_global_mobs_list?.Remove(src)
	if(src.skipped_mobs_list & SKIPPED_MOBS_LIST && !(src.mob_flags & LIGHTWEIGHT_AI_MOB))
		skipped_mobs_list &= ~SKIPPED_MOBS_LIST
		global.mobs |= src
	if(src.skipped_mobs_list & SKIPPED_AI_MOBS_LIST)
		skipped_mobs_list &= ~SKIPPED_AI_MOBS_LIST
		global.ai_mobs |= src
	if(src.skipped_mobs_list & SKIPPED_STAMINA_MOBS)
		OTHER_START_TRACKING_CAT(src, TR_CAT_STAMINA_MOBS)
		src.skipped_mobs_list &= ~SKIPPED_STAMINA_MOBS

	if(!src.last_ckey)
		SPAWN(0)
			var/area/AR = get_area(src)
			AR?.wake_critters(src)

	src.last_ckey = src.ckey

	src.last_client = src.client
	src.apply_camera(src.client)
	src.update_cursor()
	if(src.client.preferences)
		src.reset_keymap()

	src.client.mouse_pointer_icon = src.cursor

	src.lastKnownIP = src.client.address
	src.computer_id = src.client.computer_id

	world.update_status()

	src.sight |= SEE_SELF | SEE_BLACKNESS

	..()

	if (src.client)
		for (var/datum/hud/hud in src.huds)
			hud.add_client(src.client)

		src.addOverlaysClient(src.client)  //ov1

	src.emote_allowed = 1

	if (!src.mind)
		src.mind = new (src)

	if (src.mind)
		if (!src.mind.ckey)
			src.mind.ckey = src.ckey
		if (!src.mind.key)
			src.mind.key = src.key

	if (isobj(src.loc))
		var/obj/O = src.loc
		if (istype(O))
			O.client_login(src)

	src.move_dir = 0

	src.need_update_item_abilities = 1

	var/atom/illumplane = client.get_plane( PLANE_LIGHTING )
	if (illumplane) //Wire: Fix for Cannot modify null.alpha
		illumplane.alpha = 255

	src.client?.set_color(length(src.active_color_matrix) ? src.active_color_matrix : COLOR_MATRIX_IDENTITY, src.respect_view_tint_settings)

	SEND_SIGNAL(src, COMSIG_MOB_LOGIN)
	if (src.client)
		SEND_SIGNAL(src.client, COMSIG_CLIENT_LOGIN, src)

/mob/Logout()

	//logTheThing(LOG_DIARY, src, "logged out", "access") <- sometimes shits itself and has been known to out traitors. Disabling for now.
	SEND_SIGNAL(src, COMSIG_MOB_LOGOUT)
	if (src.last_client)
		SEND_SIGNAL(src.last_client, COMSIG_CLIENT_LOGOUT, src)

	tgui_process?.on_logout(src)

	if (src.last_client && !src.key) // lets see if not removing the HUD from disconnecting players helps with the crashes
		for (var/datum/hud/hud in src.huds)
			hud.remove_client(src.last_client)

	src.move_dir = 0

	..()

	. = 1

/mob/proc/deliver_move_trigger(ev)
	return

/mob/proc/onMouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
	return

/mob/proc/onMouseDown(object,location,control,params)
	return

/mob/proc/onMouseUp(object,location,control,params)
	return

/mob/bump(atom/A)
	if (src.now_pushing)
		return

	var/atom/movable/AM = A

	if(istype(AM, /mob/dead/target_observer) || istype(src, /mob/dead/target_observer))
		return
	src.now_pushing = 1

	if(isturf(A))
		if((A.reagents?.get_reagent_amount("flubber") + src.reagents?.get_reagent_amount("flubber") > 0) || src.hasStatus("sugar_rush") || A.hasStatus("sugar_rush"))
			if(!ON_COOLDOWN(src, "flubber_bounce", 0.1 SECONDS) || src.hasStatus("sugar_rush"))
				src.now_pushing = 0
				var/atom/source = A
				src.visible_message(SPAN_ALERT("<B>[src]</B> bounces off [A]!"))
				playsound(source, 'sound/misc/boing/6.ogg', 100, TRUE)
				var/throw_dir = turn(get_dir(A, src),rand(-1,1)*45)
				src.throw_at(get_edge_cheap(source, throw_dir),  20, 3)
				logTheThing(LOG_COMBAT, src, "with reagents [log_reagents(src)] is flubber bounced [dir2text(throw_dir)] due to impact with turf [log_object(A)] [log_reagents(A)] at [log_loc(src)].")

				return

	if (ismob(AM))
		var/mob/tmob = AM
		if (ishuman(tmob))
			if(isliving(src) && src.density)
				var/mob/living/L = src
				L.viral_transmission(AM,"Contact",1)

			if ((tmob.bioHolder?.HasEffect("magnets_pos") && src.bioHolder?.HasEffect("magnets_pos")) || (tmob.bioHolder?.HasEffect("magnets_neg") && src.bioHolder?.HasEffect("magnets_neg")))
				//prevent ping-pong loops by deactivating for a second, as they can crash the server under some circumstances
				var/datum/bioEffect/hidden/magnetic/tmob_effect = tmob.bioHolder.GetEffect("magnets_pos")
				if(tmob_effect == null) tmob_effect = tmob.bioHolder.GetEffect("magnets_neg")

				var/datum/bioEffect/hidden/magnetic/src_effect = src.bioHolder.GetEffect("magnets_pos")
				if(src_effect == null) src_effect = src.bioHolder.GetEffect("magnets_neg")

				if(src_effect.active != 0 && tmob_effect.active != 0 && src_effect.charge > 0 && tmob_effect.charge > 0)
					src_effect.deactivate(10)
					src_effect.update_charge(-1)
					tmob_effect.deactivate(10)
					tmob_effect.update_charge(-1)
					//spatial interdictor: mitigate biomagnetic discharges
					if (tmob.hasStatus("spatial_protection"))
						src.visible_message(SPAN_ALERT("<B>[src]</B> and <B>[tmob]</B>'s magnetic fields briefly flare, then fade."))
						var/atom/source = get_turf(tmob)
						playsound(source, 'sound/impact_sounds/Energy_Hit_1.ogg', 30, TRUE)
						return
					// like repels - bump them away from each other
					src.now_pushing = 0
					var/atom/source = get_turf(tmob)
					src.visible_message(SPAN_ALERT("<B>[src]</B> and <B>[tmob]</B>'s identical magnetic fields repel each other!"))
					playsound(source, 'sound/impact_sounds/Energy_Hit_1.ogg', 100, TRUE)
					tmob.throw_at(get_edge_cheap(source, get_dir(src, tmob)),  20, 3)
					src.throw_at(get_edge_cheap(source, get_dir(tmob, src)),  20, 3)
					return
			var/flubber = FALSE
			if(tmob.reagents?.get_reagent_amount("flubber") + src.reagents?.get_reagent_amount("flubber") > 0)
				flubber = TRUE
			if((flubber || src.hasStatus("sugar_rush") || tmob.hasStatus("sugar_rush")))


				src.now_pushing = 0
				if(ON_COOLDOWN(src, "flubber_bounce", 0.1 SECONDS) || ON_COOLDOWN(tmob, "flubber_bounce", 0.1 SECONDS))
					return

				var/atom/source = get_turf(tmob)
				src.visible_message(SPAN_ALERT("<B>[src]</B> and <B>[tmob]</B> bounce off each other!"))
				playsound(source, 'sound/misc/boing/6.ogg', 100, TRUE)
				var/target_dir = get_dir(src, tmob)
				var/src_dir = get_dir(tmob, src)
				tmob.throw_at(get_edge_cheap(source, target_dir),  20, 3)
				src.throw_at(get_edge_cheap(source, src_dir),  20, 3)
				if((!ON_COOLDOWN(src, "flubber_damage", 2 SECONDS) || !ON_COOLDOWN(tmob, "flubber_damage", 2 SECONDS)) && flubber)
					random_brute_damage(tmob, 7, TRUE)
					random_brute_damage(src, 7, TRUE)
				logTheThing(LOG_COMBAT, src, "with reagents [log_reagents(src.reagents)] is flubber bounced [dir2text(src_dir)] due to impact with mob [log_object(tmob)] [log_reagents(tmob.reagents)] at [log_loc(src)].")
				logTheThing(LOG_COMBAT, tmob, "with reagents [log_reagents(tmob.reagents)] is flubber bounced [dir2text(target_dir)] due to impact with mob [log_object(src)] [log_reagents(src.reagents)] at [log_loc(tmob)].")

				return
			if ((!tmob.now_pushing && !src.now_pushing) && (tmob.bioHolder?.HasEffect("magnets_pos") && src.bioHolder?.HasEffect("magnets_neg")) || (tmob.bioHolder?.HasEffect("magnets_neg") && src.bioHolder?.HasEffect("magnets_pos")))
				//prevent ping-pong loops by deactivating for a second, as they can crash the server under some circumstances
				var/datum/bioEffect/hidden/magnetic/tmob_effect = tmob.bioHolder.GetEffect("magnets_pos")
				if(tmob_effect == null) tmob_effect = tmob.bioHolder.GetEffect("magnets_neg")

				var/datum/bioEffect/hidden/magnetic/src_effect = src.bioHolder.GetEffect("magnets_pos")
				if(src_effect == null) src_effect = src.bioHolder.GetEffect("magnets_neg")

				if(src_effect.active != 0 && tmob_effect.active != 0 && src_effect.charge > 0 && tmob_effect.charge > 0)
					var/throw_charge = (src_effect.charge + tmob_effect.charge)*2
					src_effect.deactivate(10)
					src_effect.update_charge(-src_effect.charge)
					tmob_effect.deactivate(10)
					tmob_effect.update_charge(-tmob_effect.charge)
					//spatial interdictor: mitigate biomagnetic discharges

					if (tmob.hasStatus("spatial_protection"))
						src.visible_message(SPAN_ALERT("<B>[src]</B> and <B>[tmob]</B>'s magnetic fields briefly flare, then fade."))
						var/atom/source = get_turf(tmob)
						playsound(source, 'sound/impact_sounds/Energy_Hit_1.ogg', 30, TRUE)
						return
					// opposite attracts - fling everything nearby at these dumbasses
					src.now_pushing = 1
					tmob.now_pushing = 1
					src.visible_message(SPAN_ALERT("<B>[src]</B> and <B>[tmob]</B>'s opposite magnetic fields cause a minor magnetic blowout!"))
					//src.bioHolder.RemoveEffect("magnets_pos")
					//src.bioHolder.RemoveEffect("magnets_neg")
					var/atom/source = get_turf(tmob)
					new/obj/decal/implo(source)
					var/list/sfloors = list()
					for (var/turf/T in view(5, src))
						if (!T.density)
							sfloors += T
					var/arcs = 8
					while (arcs > 0 && length(sfloors))
						arcs--
						var/turf/Q = pick(sfloors)
						arcFlashTurf(src, Q, 3000)
						sfloors -= Q
					playsound(source, 'sound/effects/suck.ogg', 100, TRUE)
					for(var/atom/movable/M in view(5, source))
						if(M.anchored || M == source) continue
						if(throw_charge > 0)
							throw_charge--
						else
							break
						M.throw_at(source, 20, 3)
						LAGCHECK(LAG_MED)
					SPAWN(5 SECONDS)
						src.now_pushing = 0
						if (tmob) //Wire: Fix for: Cannot modify null.now_pushing
							tmob.now_pushing = 0

		if (!issilicon(AM) && !issilicon(src))
			var/flubber = FALSE
			if(tmob.reagents?.get_reagent_amount("flubber") + src.reagents?.get_reagent_amount("flubber") > 0)
				flubber = TRUE
			if((flubber || src.hasStatus("sugar_rush") || tmob.hasStatus("sugar_rush")))


				src.now_pushing = 0
				if(ON_COOLDOWN(src, "flubber_bounce", 0.1 SECONDS) || ON_COOLDOWN(tmob, "flubber_bounce", 0.1 SECONDS))
					return

				var/atom/source = get_turf(tmob)
				src.visible_message(SPAN_ALERT("<B>[src]</B> and <B>[tmob]</B> bounce off each other!"))
				playsound(source, 'sound/misc/boing/6.ogg', 100, TRUE)
				var/target_dir = get_dir(src, tmob)
				var/src_dir = get_dir(tmob, src)
				tmob.throw_at(get_edge_cheap(source, target_dir),  20, 3)
				src.throw_at(get_edge_cheap(source, src_dir),  20, 3)
				if((!ON_COOLDOWN(src, "flubber_damage", 2 SECONDS) || !ON_COOLDOWN(tmob, "flubber_damage", 2 SECONDS)) && flubber)
					random_brute_damage(tmob, 7, TRUE)
					random_brute_damage(src, 7, TRUE)
				logTheThing(LOG_COMBAT, src, "with reagents [log_reagents(src.reagents)] is flubber bounced [dir2text(src_dir)] due to impact with mob [log_object(tmob)] [log_reagents(tmob.reagents)] at [log_loc(src)].")
				logTheThing(LOG_COMBAT, tmob, "with reagents [log_reagents(tmob.reagents)] is flubber bounced [dir2text(target_dir)] due to impact with mob [log_object(src)] [log_reagents(src.reagents)] at [log_loc(tmob)].")

				return

			else if (tmob.a_intent == "help" && src.a_intent == "help" \
				&& tmob.canmove && src.canmove \
				&& !tmob.buckled?.anchored && !src.buckled?.anchored \
				&& !src.throwing && !tmob.throwing \
				&& !(src.pulling && src.pulling.density) && !(tmob.pulling && tmob.pulling.density)) // mutual brohugs all around!
				var/turf/oldloc = src.loc
				var/turf/newloc = tmob.loc
				if(!oldloc.Enter(tmob) || !newloc.Enter(src))
					src.now_pushing = 0
					return
				for(var/atom/movable/obstacle in oldloc)
					if(!ismob(obstacle) && !obstacle.Cross(tmob))
						src.now_pushing = 0
						return
				for(var/atom/movable/obstacle in newloc)
					if(!ismob(obstacle) && !obstacle.Cross(src))
						src.now_pushing = 0
						return

				src.set_loc(newloc)
				tmob.set_loc(oldloc)

				if (istype(tmob.loc, /turf/space))
					logTheThing(LOG_COMBAT, src, "trades places with (Help Intent) [constructTarget(tmob,"combat")], pushing them into space.")
				else if (locate(/atom/movable/hotspot) in tmob.loc)
					logTheThing(LOG_COMBAT, src, "trades places with (Help Intent) [constructTarget(tmob,"combat")], pushing them into a fire.")
				deliver_move_trigger("swap")
				tmob.deliver_move_trigger("swap")
				tmob.update_grab_loc()
				src.now_pushing = 0

				return


	..()

	src.now_pushing = 0
	if (istype(AM, /atom/movable) && !AM.anchored)
		src.pushing = AM

		src.now_pushing = 1
		var/t = get_dir(src, AM)
		var/old_loc = src.loc
		AM.animate_movement = SYNC_STEPS
		AM.glide_size = src.glide_size
		step(AM, t)

		if (isliving(AM))
			var/mob/victim = AM
			deliver_move_trigger("bump")
			victim.deliver_move_trigger("bump")
			var/was_in_space = istype(victim.loc, /turf/space)
			var/was_in_fire = locate(/atom/movable/hotspot) in victim.loc
			if (victim.buckled && !victim.buckled.anchored)
				step(victim.buckled, t)
			if (!was_in_space && istype(victim.loc, /turf/space))
				logTheThing(LOG_COMBAT, src, "pushes [constructTarget(victim,"combat")] into space.")
			else if (!was_in_fire && (locate(/atom/movable/hotspot) in victim.loc))
				logTheThing(LOG_COMBAT, src, "pushes [constructTarget(victim,"combat")] into a fire.")

		step(src,t)
		AM.OnMove(src)
		//src.OnMove(src) //dont do this here - this bump() is called from a process_move which sould be calling onmove for us already
		AM.glide_size = src.glide_size

		//// MBC : I did this. this SUCKS. (pulling behavior is only applied in process_move... and step() doesn't trigger process_move nor is there anyway to override the step() behavior
		// so yeah, i copy+pasted this from process_move.
		if (old_loc != src.loc) //causes infinite pull loop without these checks. lol
			var/list/pulling = list()
			if ((BOUNDS_DIST(old_loc, src.pulling) > 0 && BOUNDS_DIST(src, src.pulling) > 0) || src.pulling == src) // fucks sake
				src.remove_pulling()
				//hud.update_pulling() // FIXME
			else
				pulling += src.pulling
			for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
				pulling += G.affecting
			for (var/atom/movable/pulled in pulling)
				if (GET_DIST(src, pulled) == 0) // if we're moving onto the same tile as what we're pulling, don't pull
					continue
				if (pulled == src || pulled == AM)
					continue
				if (!isturf(pulled.loc) || pulled.anchored)
					src.now_pushing = null
					continue // whoops
				pulled.animate_movement = SYNC_STEPS
				pulled.glide_size = src.glide_size
				step(pulled, get_dir(pulled, old_loc))
				pulled.glide_size = src.glide_size
				pulled.OnMove(src)
		////////////////////////////////////// end suck
		src.now_pushing = null


// I moved the log entries from human.dm to make them global (Convair880).
/mob/ex_act(severity, last_touched)
	SEND_SIGNAL(src, COMSIG_MOB_EX_ACT, severity)
	logTheThing(LOG_COMBAT, src, "is hit by an explosion (Severity: [severity]) at [log_loc(src)]. Explosion source last touched by [last_touched]")
	return

/mob/proc/projCanHit(datum/projectile/P)
	return 1

/mob/proc/attach_hud(datum/hud/hud)
	if (!(hud in huds))
		huds += hud
		hud.mobs += src
		if (src.client)
			hud.add_client(src.client)

/mob/proc/detach_hud(datum/hud/hud)
	if (!hud) // Can happen if someone dies instantly when entering a z level (i.e. singulo)
		return

	if (src?.huds) //Wire note: Fix for runtime error: bad list
		huds -= hud

	hud.mobs -= src
	if (src.client)
		hud.remove_client(src.client)

/mob/proc/set_eye(atom/new_eye, new_pixel_x = 0, new_pixel_y = 0)
	src.eye = new_eye
	src.eye_pixel_x = new_pixel_x
	src.eye_pixel_y = new_pixel_y
	src.update_camera()

/mob/set_loc(atom/new_loc, new_pixel_x = 0, new_pixel_y = 0)
	if(istype(src.loc, /obj/machinery/vehicle/) && src.loc != new_loc)
		var/obj/machinery/vehicle/V = src.loc
		V.eject(src)

	. = ..(new_loc)
	src.loc_pixel_x = new_pixel_x
	src.loc_pixel_y = new_pixel_y
	src.update_camera()

	walk(src,0) //cancel any walk movements

/mob/proc/update_camera()
	if (src.client)
		apply_camera(src.client)

/mob/proc/apply_camera(client/C)
	if (!C)
		stack_trace("mob/apply_camera called without a client for mob [identify_object(src)], something likely went wrong during mind transfer.")
	if (src.eye)
		C.eye = src.eye
		C.pixel_x = src.eye_pixel_x
		C.pixel_y = src.eye_pixel_y
	else
		C.eye = src
		C.pixel_x = src.loc_pixel_x
		C.pixel_y = src.loc_pixel_y

/mob/proc/can_strip(mob/M)
	if(check_target_immunity(M, 1, src))
		return 0
	return 1

/mob/proc/set_cursor(icon/cursor)
	src.cursor = cursor
	if (src.client)
		src.client.mouse_pointer_icon = cursor

/mob/proc/update_cursor()
	if (client)
		if (src.targeting_ability)
			src.set_cursor(cursors_selection[client.preferences.target_cursor])
			return
		if (src.client.admin_intent)
			src.set_cursor('icons/cursors/admin.dmi')
			return
	src.set_cursor(null)

/// used to set the a_intent var of a mob
/mob/proc/set_a_intent(intent)
	SHOULD_CALL_PARENT(TRUE)
	if (!intent)
		return
	if(SEND_SIGNAL(src, COMSIG_MOB_SET_A_INTENT, intent))
		return
	src.a_intent = intent
	if (src.equipped()?.item_function_flags & USE_INTENT_SWITCH_TRIGGER)
		src.equipped().intent_switch_trigger(src)

// medals

/mob/proc/revoke_medal(title)
	src.mind.get_player().clear_medal(title)

/mob/proc/unlock_medal(title, announce=FALSE)
	set waitfor = 0
	if (!src.client)
		return
	src.mind.get_player().unlock_medal(title, announce)

/mob/proc/has_medal(medal) //This is not spawned because of return values. Make sure the proc that uses it uses spawn or you lock up everything.
	LAGCHECK(LAG_HIGH)
#ifdef SHUT_UP_AND_GIVE_ME_MEDAL_STUFF
	return TRUE
#else
	return src.mind.get_player().has_medal(medal)
#endif

/mob/verb/list_medals()
	set name = "Medals"

	if (IsGuestKey(src.key))
		boutput(src, SPAN_ALERT("Sorry, you are a guest and cannot have medals."))
		return

	boutput(src, SPAN_HINT("Retrieving your medal information..."))

	SPAWN(0)
		var/list/output = list()
		var/datum/player/player = src.mind.get_player()
		var/list/medals = player.get_all_medals()

		if (isnull(medals))
			output += SPAN_ALERT("Sorry, could not retrieve your medal information.")
			return

		medals = medals["data"]
		if (length(medals) == 0)
			boutput(src, "<b>You don't have any medals.</b>")
			return

		output += "<b>Medals:</b>"
		for (var/medal in medals)
			output += "&emsp;[medal["medal"]["title"]]"
		output += "<b>You have [length(medals)] medal\s.</b>"
		output += {"<br><a href="[goonhub_href("/players/[player.id]")]" target="_blank">Medal Details</a>"}
		tgui_message(src, output.Join("<br>"), "Medals")

/mob/verb/setdnr()
	set name = "Set DNR"
	set desc = "Set yourself as Do Not Resuscitate."
	if(isadmin(src))
		src.mind.get_player()?.dnr = !src.mind.get_player()?.dnr
		boutput(src, SPAN_ALERT("DNR status [src.mind.get_player()?.dnr ? "set" : "removed"]!"))
	else
		var/confirm = tgui_alert(src, "Set yourself as Do Not Resuscitate (WARNING: This is one-use only and will prevent you from being revived in any manner excluding certain antagonist abilities)", "Set Do Not Resuscitate", list("Yes", "Cancel"))
		if (confirm != "Yes")
			return
		if (!src.mind)
			tgui_alert(src, "There was an error setting this status. Perhaps you are a ghost?", "Error")
			return
	//So that players can leave their team and spectate. Since normal dying get's you instantly cloned.
#if defined(MAP_OVERRIDE_POD_WARS)
		if (isliving(src) && !isdead(src))
			var/double_confirm = tgui_alert(src, "Setting DNR here will kill you and remove you from your team. Do you still want to set DNR?", "Set Do Not Resuscitate", list("Yes", "No"))
			if (double_confirm != "Yes")
				return
			src.death()
		src.verbs -= list(/mob/verb/setdnr)
		src.mind.get_player()?.dnr = TRUE
		boutput(src, SPAN_ALERT("DNR status set!"))
		boutput(src, SPAN_ALERT("You've been removed from your team for desertion!"))
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			mode.team_NT.members -= src.mind
			mode.team_SY.members -= src.mind
			message_admins("[src]([src.ckey]) just set DNR and was removed from their team. which was probably [src.mind.special_role]!")
#else

		src.verbs -= list(/mob/verb/setdnr)
		src.mind.get_player()?.dnr = TRUE
		boutput(src, SPAN_ALERT("DNR status set!"))
#endif

/mob/proc/unequip_all(var/delete_stuff=0, atom/drop_loc = null)
	var/list/obj/item/to_unequip = src.get_unequippable()
	if(length(to_unequip))
		for (var/obj/item/W in to_unequip)
			src.remove_item(W)
			if (W)
				W.set_loc(drop_loc || src.loc)
				W.dropped(src)
				W.layer = initial(W.layer)
			if(delete_stuff)
				qdel(W)

/mob/proc/unequip_random(var/delete_stuff=0)
	var/list/obj/item/to_unequip = get_unequippable()
	if(length(to_unequip))
		var/obj/item/I = pick(to_unequip)
		src.remove_item(I)
		if (I)
			I.set_loc(src.loc)
			I.dropped(src)
			I.layer = initial(I.layer)

		if(delete_stuff)
			qdel(I)
		else
			return I

/mob/dead/unequip_all(var/delete_stuff=0)
	new/obj/item/reagent_containers/food/snacks/ectoplasm(src.loc)

/mob/proc/get_unequippable()
	return

/mob/living/get_unequippable()
	var/list/obj/item/LI = list()

	for (var/obj/item/W in src)
		if (istype(W, /obj/item/parts) && W:holder == src)
			continue

		if(istype(W, /obj/item/implant))
			continue

		if (src.organHolder)
			if (istype(W, /obj/item/organ/chest) && src.organHolder.chest == W)
				continue
			if (istype(W, /obj/item/organ/head) && src.organHolder.head == W)
				continue
			if (istype(W, /obj/item/skull) && src.organHolder.skull == W)
				continue
			if (istype(W, /obj/item/organ/brain) && src.organHolder.brain == W)
				continue
			if (istype(W, /obj/item/organ/eye) && (src.organHolder.left_eye == W || src.organHolder.right_eye == W))
				continue
			if (istype(W, /obj/item/organ/heart) && src.organHolder.heart == W)
				continue
			if (istype(W, /obj/item/organ/lung) && (src.organHolder.left_lung == W || src.organHolder.right_lung == W))
				continue
			if (istype(W, /obj/item/clothing/head/butt) && src.organHolder.butt == W)
				continue
			if (istype(W, /obj/item/organ/liver) && src.organHolder.liver == W)
				continue
			if (istype(W, /obj/item/organ/kidney) && (src.organHolder.left_kidney == W || src.organHolder.right_kidney == W))
				continue
			if (istype(W, /obj/item/organ/stomach) && src.organHolder.stomach == W)
				continue
			if (istype(W, /obj/item/organ/intestines) && src.organHolder.intestines == W)
				continue
			if (istype(W, /obj/item/organ/spleen) && src.organHolder.spleen == W)
				continue
			if (istype(W, /obj/item/organ/pancreas) && src.organHolder.pancreas == W)
				continue
			if (istype(W, /obj/item/organ/appendix) && src.organHolder.appendix == W)
				continue
			if (istype(W, /obj/item/organ/tail) && src.organHolder.tail == W)
				continue

		if (istype(W, /obj/item/reagent_containers/food/snacks/bite))
			continue

		LI += W
	.= LI

/mob/proc/movement_delay(var/atom/move_target = 0)
	.= 2 + movement_delay_modifier
	if (src.pushing)
		. *= max(src.pushing.p_class, 1)

/mob/proc/Life(datum/controller/process/mobs/parent)
	SHOULD_CALL_PARENT(TRUE)
	return

// for mobs without organs
/mob/proc/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
	hit_twitch(src)
	src.health -= max(0, brute)
	src.health -= max(0, (src.bioHolder?.HasEffect("fire_resist") > 1) ? burn/2 : burn)

/mob/proc/TakeDamageAccountArmor(zone, brute, burn, tox, damage_type)
	TakeDamage(zone, brute - get_melee_protection(zone,damage_type), burn - get_melee_protection(zone,damage_type))

/mob/proc/HealDamage(zone, brute, burn, tox)
	health += max(0, brute)
	health += max(0, burn)
	health += max(0, tox)
	health = min(max_health, health)

/// Which mob is pulling this movable currently
/atom/movable/var/mob/pulled_by = null

/mob/proc/set_pulling(atom/movable/A)
	if(A == src)
		return

	var/atom/movable/wasPulling = src.pulling
	if(wasPulling)
		src.remove_pulling()
		if(wasPulling == A)
			return

	if(!can_reach(src, A) || src.restrained())
		return

	if(istype(A, /obj/stool))
		var/obj/stool/C = A
		if(C?.buckled_guy == src)
			return

	src.pulling = A
	A.pulled_by = src

	//robust grab : a dirty DIRTY trick on mbc's part. When I am being chokeholded by someone, redirect pulls to the captor.
	//this is so much simpler than pulling the victim and invoking movment on the captor through that chain of events.
	if (ishuman(src.pulling))
		var/mob/living/carbon/human/H = src.pulling
		if (length(H.grabbed_by))
			for (var/obj/item/grab/G in src.grabbed_by)
				if (G.state < GRAB_AGGRESSIVE) continue
				src.pulling = G.assailant
				G.assailant.pulled_by = src

	pull_particle(src,pulling)

/mob/proc/remove_pulling()
	if(src.pulling)
		src.pulling.pulled_by = null
	src.pulling = null

// less icon caching maybe?!

#define FACE 1
#define BODY 2
#define CLOTHING 4
#define DAMAGE 8
#define VALID_REBUILD_FLAGS (FACE | BODY | CLOTHING | DAMAGE)
/mob/var/icon_rebuild_flag = 0

/mob/proc/update_icons_if_needed()
	if (icon_rebuild_flag & (~VALID_REBUILD_FLAGS))
		var/what_the_fuck = icon_rebuild_flag
		src.icon_rebuild_flag &= VALID_REBUILD_FLAGS
		CRASH("[src] started to update its icons with an invalid flag setting of [what_the_fuck]! Fucked up, man.")

	if (icon_rebuild_flag & FACE)
		update_face()

	if (icon_rebuild_flag & BODY)
		update_body()

	if (icon_rebuild_flag & CLOTHING)
		update_clothing()

	if (icon_rebuild_flag & DAMAGE)
		UpdateDamageIcon()

	if (icon_rebuild_flag & (~VALID_REBUILD_FLAGS))
		var/what_the_fuck = icon_rebuild_flag
		src.icon_rebuild_flag &= VALID_REBUILD_FLAGS
		CRASH("[src] updated its icons and now its flags are [what_the_fuck]! THAT'S STILL FUCKING WRONG.")


/mob/proc/set_clothing_icon_dirty()
	icon_rebuild_flag |= CLOTHING

/mob/proc/update_clothing()
	icon_rebuild_flag &= ~CLOTHING

/mob/proc/set_body_icon_dirty()
	icon_rebuild_flag |= BODY

/mob/proc/update_body()
	icon_rebuild_flag &= ~BODY

/mob/proc/UpdateDamage()
	SHOULD_CALL_PARENT(TRUE)
	var/prev_health = src.health
	updatehealth()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_DAMAGE, prev_health)

/mob/proc/set_damage_icon_dirty()
	icon_rebuild_flag |= DAMAGE

/mob/proc/UpdateDamageIcon()
	if (lastDamageIconUpdate && !(world.time - lastDamageIconUpdate))
		return
	lastDamageIconUpdate = world.time
	icon_rebuild_flag &= ~DAMAGE

/mob/proc/set_face_icon_dirty()
	icon_rebuild_flag |= FACE

/mob/proc/update_face()
	icon_rebuild_flag &= ~FACE

#undef VALID_REBUILD_FLAGS
#undef FACE
#undef BODY
#undef CLOTHING
#undef DAMAGE

/mob/proc/death(gibbed = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_DEATH)
	//Traitor's dead! Oh no!
	if (src.mind && src.mind.special_role && !istype(get_area(src),/area/afterlife))
		message_admins(SPAN_ALERT("Antagonist [key_name(src)] ([src.mind.special_role]) died at [log_loc(src)]."))
	//if(src.mind && !gibbed)
	//	src.mind.death_icon = getFlatIcon(src,SOUTH) crew photo stuff
	if(src.mind && (src.mind.damned || src.mind.karma < -200))
		src.damn()
		return
	if (src.suicide_alert)
		message_attack("[key_name(src)] died shortly after spawning.")
		src.suicide_alert = 0
	if(src.ckey && !src.mind?.get_player()?.dnr)
		respawn_controller.subscribeNewRespawnee(src.ckey)
	//stop piloting pods or whatever
	src.override_movement_controller = null


/mob/proc/restrained()
	. = src.hasStatus("handcuffed")

/mob/proc/drop_from_slot(obj/item/item, turf/T, force_drop=FALSE)
	if (!item)
		return
	if (!(item in src.contents))
		return
	if (item.cant_drop && !force_drop)
		return
	if (item.cant_self_remove && src.l_hand != item && src.r_hand != item)
		return
	u_equip(item)
	src.set_clothing_icon_dirty()
	if (!T)
		T = src.loc
	if (item)
		item.set_loc(T)
		item.dropped(src)
		if (item)
			item.layer = initial(item.layer)

/mob/proc/drop_item(obj/item/W, grabs_first)
	.= 0
	if (!W) //only pass W if you KNOW that the mob has it
		W = src.equipped()
	if (istype(W))
		actions.interrupt(src, INTERRUPT_ACT)
		var/obj/item/magtractor/origW
		if (W.useInnerItem && length(W.contents) > 0)
			if (istype(W, /obj/item/magtractor))
				origW = W
			var/obj/item/held = W.holding
			if (!held)
				held = pick(W.contents)
			if (held && !istype(held, /obj/ability_button))
				W = held
		if (!istype(W) || W.cant_drop) return

		if (W.chokehold != null && grabs_first)
			W.drop_grab()
			return

		if (W && !W.qdeled)
			if (istype(src.loc, /obj/vehicle))
				var/obj/vehicle/V = src.loc
				if (V.can_eject_items)
					W.set_loc(get_turf(V))
				else
					W.set_loc(src.loc)
			else if (istype(src.loc, /obj/machinery/bot/mulebot))
				W.set_loc(get_turf(src.loc))
			else
				W.set_loc(src.loc)
			if (W)
				W.layer = initial(W.layer)

			u_equip(W)
			.= 1
		else
			u_equip(W)
			.= 0
		if (origW)
			origW.holding = null
			actions.stopId(/datum/action/magPickerHold, src)

//throw the dropped item
/mob/proc/drop_item_throw(obj/item/W)
	if(!W)
		W = src.equipped()
	if (src.drop_item(W))
		var/turf/T = get_edge_target_turf(src, pick(alldirs))
		W.throw_at(T,rand(0,5),1)

/mob/proc/drop_item_throw_dir(dir, obj/item/W)
	if(!W)
		W = src.equipped()
	if (src.drop_item(W))
		var/turf/T = get_edge_target_turf(src, dir)
		W.throw_at(T,7,1)

/mob/proc/remove_item(var/obj/O)
	if (O)
		u_equip(O)
		src.set_clothing_icon_dirty()

/mob/proc/equipped()
	RETURN_TYPE(/obj/item)
	if (issilicon(src))
		if (ishivebot(src)||isrobot(src))
			if (src:module_active)
				return src:module_active
	else
		if (src.hand)
			return src.l_hand
		else
			return src.r_hand
///Legally distinct from `equipped_list`, this gets all items from equipment slots and not hands!
/mob/proc/equipment_list()
	RETURN_TYPE(/list)
	return list()

/mob/living/critter/equipment_list()
	. = list()
	for (var/datum/equipmentHolder/holder as anything in src.equipment)
		if (holder.item)
			. += holder.item
	return .

/mob/living/carbon/human/equipment_list()
	. = list()
	for (var/obj/item/item in list(src.l_store, src.r_store, src.belt, src.back, src.wear_id, src.wear_mask, src.wear_suit, src.w_uniform, src.shoes, src.gloves, src.ears))
		. += item //using byond type filtering this can't be null here
	return .

/mob/proc/equipped_list(check_for_magtractor = 1)
	. = list()

	if (src.r_hand)
		. |= src.r_hand
		if (src.r_hand.chokehold)
			. |= src.r_hand.chokehold

	if (src.l_hand)
		. |= src.l_hand
		if (src.l_hand.chokehold)
			. |= src.l_hand.chokehold

	//handle mag tracktor
	if (check_for_magtractor)
		for (var/I in .)
			if (istype(I,/obj/item/magtractor))
				var/obj/item/magtractor/M = I
				if (M.holding)
					. |= M.holding
				. -= I

/mob/living/critter/equipped_list(check_for_magtractor = 1)
	.= ..()
	if (hands)
		for(var/datum/handHolder/H in hands)
			if (H.item)
				. |= H.item

/mob/living/silicon/equipped_list(check_for_magtractor = 1) //lool copy paste fix later
	.= 0
	if (ishivebot(src)||isrobot(src))
		if (src:module_active)
			.= list(src:module_active)
	else if (isghostdrone(src))
		var/mob/living/silicon/ghostdrone/D = src
		if (D.active_tool)
			.= list(D.active_tool)


	//handle mag tracktor
	if (check_for_magtractor)
		for (var/I in .)
			if (istype(I,/obj/item/magtractor))
				var/obj/item/magtractor/M = I
				.|= M.holding
				.-= I

/mob/proc/swap_hand()
	return

/mob/proc/u_equip(obj/item/W)
	if (W == src.r_hand)
		src.r_hand = null
	if (W == src.l_hand)
		src.l_hand = null

	if (W == src.handcuffs)
		src.handcuffs = null
		src.delStatus("handcuffed")
	else if (W == src.back)
		src.back = null
	else if (W == src.wear_mask)
		src.wear_mask = null

	if (src.client)
		src.client.screen -= W

	set_clothing_icon_dirty()

	W.dropped(src)

/// shortcut for the Notes - View verb
/mob/verb/notes_alias()
	set name = "Notes"
	set hidden = TRUE

	src.memory()

/mob/verb/memory()
	set name = "Notes - View"
	// drsingh for cannot execute null.show_memory
	if (isnull(mind))
		return

	mind.show_memory(src)

/mob/verb/add_memory()
	set name = "Notes - Modify"

	if (!src.mind)
		return

	if (mind.last_memory_time + 10 <= world.time)
		mind.last_memory_time = world.time

	var/notes = tgui_input_text(src, "Set your notes:", "Change notes", src.mind.cust_notes, MAX_MESSAGE_LEN, TRUE, allowEmpty = TRUE)
	if (!isnull(notes))
		src.mind.cust_notes = notes

// please note that this store_memory() vvv
// does not store memories in the notes
// it is named the same thing as the mind proc to store notes, but it does not store notes
/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(src.memory) == 0)
		src.memory += msg
	else
		src.memory += "<BR>[msg]"

	if (popup)
		src.memory()

/mob/proc/recite_miranda()
	set name = "Recite Miranda Rights"
	if (isnull(src.mind))
		return
	if(!ON_COOLDOWN(src, "recite_miranda", 10 SECONDS))
		var/miranda = src.mind.get_miranda()
		if (isnull(miranda))
			src.say_verb(DEFAULT_MIRANDA)
			return
		src.say_verb(miranda)

/mob/proc/add_miranda()
	set name = "Set Miranda Rights"
	if (isnull(src.mind))
		return
	if (src.mind.last_memory_time + 10 <= world.time) // leaving it using this var cause vOv
		src.mind.last_memory_time = world.time // why not?

		var/choice = tgui_alert(usr, "Edit Miranda's rights?", "Miranda Rights", list("Edit", "Reset", "Cancel"))
		switch(choice)
			if("Edit")
				var/new_rights = tgui_input_text(usr, "Change what you will say with the Say Miranda Rights verb.", "Set Miranda Rights", src.mind.get_miranda() || DEFAULT_MIRANDA)
				if (!new_rights || new_rights == src.mind.miranda)
					src.show_text("Miranda rights not changed.", "red")
					return

				new_rights = copytext(new_rights, 1, MAX_MESSAGE_LEN)
				new_rights = sanitize(strip_html(new_rights))

				src.mind.set_miranda(new_rights)

				logTheThing(LOG_TELEPATHY, src, "has set their miranda rights quote to: [src.mind.miranda]")
				src.show_text("Miranda rights set to \"[src.mind.miranda]\"", "blue")
			if("Reset")
				src.mind.set_miranda(null)
				logTheThing(LOG_TELEPATHY, src, "has reset their miranda rights.")
				src.show_text("Miranda rights reset.", "blue")

/mob/verb/abandon_mob()
	set name = "Respawn"

	if (!( abandon_allowed ))
		return

	if(!isobserver(usr) || !(ticker))
		boutput(usr, SPAN_NOTICE("<B>You must be a ghost to use this!</B>"))
		return

	logTheThing(LOG_DIARY, usr, "used abandon mob.", "game")

	var/mob/new_player/M = new()

	M.key = usr.client.key
	return

/mob/verb/show_preferences()
	set name = "Character Setup"
	set desc = "Displays the window to edit your character preferences"
	set category = "Commands"

	client.preferences.ShowChoices(src)

/mob/verb/cmd_rules()
	set name = "Rules"
	src << link("http://wiki.ss13.co/Rules")

/mob/verb/succumb()
	set hidden = 1

	if (src.health < 0)
		logTheThing(LOG_COMBAT, src, "succumbs to death.")
		boutput(src, SPAN_NOTICE("You have given up life and succumbed to death."))
		src.death()
		if (!src.suiciding)
			src.unlock_medal("Yield", 1)

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	src.set_eye(null)
	src.remove_dialogs()
	if (!isliving(src))
		src.sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF | SEE_BLACKNESS
	for (var/obj/ability_button/reset_view/console/ability in src.item_abilities)
		src.item_abilities -= ability
	src.need_update_item_abilities = 1
	src.update_item_abilities()

/mob/proc/show_credits()
	set name = "Show Credits"
	set desc = "Open the crew credits window"
	set category = "Commands"

	if (global.current_state < GAME_STATE_FINISHED)
		boutput(src, SPAN_NOTICE("The game hasn't finished yet!"))
		return

	global.ticker.get_credits().ui_interact(src)

/mob/Cross(atom/movable/mover)
	if (istype(mover, /obj/projectile))
		return !projCanHit(mover:proj_data)


	if (ismob(mover))
		var/mob/moving_mob = mover
		if ((src.other_mobs && moving_mob.other_mobs))
			return 1
		return (!mover.density || !src.density || src.lying)
	else
		return (!mover.density || !src.density || src.lying)

/mob/Crossed(atom/movable/AM)
	. = ..()
	if(ishuman(AM) && src.lying)
		var/mob/living/carbon/human/H = AM
		if(H.a_intent == "harm" && can_act(H, FALSE) && !H.lying && !ON_COOLDOWN(H, "free_kick_on_\ref[src]", H.trample_cooldown))
			H.melee_attack_normal(src, 0, 0, DAMAGE_BLUNT)

/mob/proc/update_inhands()

/mob/proc/has_any_hands()
	. = FALSE

/mob/proc/put_in_hand(obj/item/I, hand)
	. = 0

/mob/proc/can_hold_two_handed()
	. = FALSE

/mob/proc/get_damage()
	. = src.health

/mob/bullet_act(var/obj/projectile/P)
	var/damage = 0
	damage = round((P.power*P.proj_data.ks_ratio), 1.0)
	var/stun = 0
	stun = round((P.power*(1.0-P.proj_data.ks_ratio)), 1.0)

	src.material_trigger_on_bullet(src, P)

	switch(P.proj_data.damage_type)
		if (D_KINETIC)
			TakeDamage("All", damage, 0)
		if (D_PIERCING)
			TakeDamage("All", damage / 2, 0)
		if (D_SLASHING)
			TakeDamage("All", damage, 0)
		if (D_ENERGY)
			TakeDamage("All", 0, damage)
			if (prob(stun))
				src.changeStatus("unconscious", stun*1.5 SECONDS)
			else if (prob(90))
				src.changeStatus("stunned", stun*1.5 SECONDS)
			else
				src.changeStatus("knockdown", (stun/2)*1.5 SECONDS)
			src.set_clothing_icon_dirty()
		if (D_BURNING)
			TakeDamage("All", 0, damage)
		if (D_RADIOACTIVE)
			src.reagents?.add_reagent("radium", damage/4) //fuckit
			src.stuttering += stun
			src.changeStatus("drowsy", stun * 2 SECONDS)
		if (D_TOXIC)
			src.take_toxin_damage(damage)
	if (!P || !P.proj_data || !P.proj_data.silentshot)
		boutput(src, SPAN_ALERT("You are hit by the [P]!"))

	actions.interrupt(src, INTERRUPT_ATTACKED)
	return

//this is like, if I'm in a pod and the pod takes a hit. Should be electric shots and energy stuff
//maybe later create a new bullet or pass an existing bullet into bullet_act() so we dont have this weird proc here at all. Probably slower though
/mob/proc/bullet_act_indirect(var/obj/projectile/P)
	var/stun = 0
	stun = round((P.power*(1.0-P.proj_data.ks_ratio)), 1.0)

	stun *= 0.2 //mbc magic number stun multiplier wow

	src.material_trigger_on_bullet(src, P)

	switch(P.proj_data.damage_type)
		if (D_ENERGY)
			if (prob(stun))
				src.changeStatus("unconscious", stun*1.5 SECONDS)
			else if (prob(90))
				src.changeStatus("stunned", stun*1.5 SECONDS)
			else
				src.changeStatus("knockdown", (stun/2)*1.5 SECONDS)
			src.set_clothing_icon_dirty()
			src.show_text(SPAN_ALERT("You are shocked by the impact of [P]!"))
		if (D_RADIOACTIVE)
			src.stuttering += stun
			src.changeStatus("drowsy", stun / 5 SECONDS)
			src.show_text(SPAN_ALERT("You feel a wave of sickness as [P] impacts [src.loc]!"))


	actions.interrupt(src, INTERRUPT_ATTACKED)
	return

/mob/proc/can_use_hands()
	. = TRUE
	if (src.hasStatus("handcuffed"))
		return FALSE
	if (src.buckled && istype(src.buckled, /obj/stool/bed)) // buckling does not restrict hands
		return FALSE

/mob/proc/is_active()
	. = (0 >= usr.stat)

/mob/proc/is_heat_resistant()
	if(src.bioHolder && src.bioHolder.HasEffect("fire_resist") || src.bioHolder.HasEffect("thermal_resist") > 1)
		return TRUE
	if(src.nodamage)
		return TRUE
	return FALSE


/mob/proc/updatehealth()
	if (src.nodamage == 0)
		src.health = max_health - src.get_oxygen_deprivation() - src.get_toxin_damage() - src.get_burn_damage() - src.get_brute_damage()
		if (src.health < 0 && !src.incrit)
			src.incrit = 1
			logTheThing(LOG_COMBAT, src, "goes into crit [log_health(src)] at [log_loc(src)].")
		else if (src.incrit && src.health >= 0)
			src.incrit = 0
	else
		src.health = max_health
		setalive(src)

/// Adds a 20-length color matrix to the mob's list of color matrices
/// cmatrix is the color matrix (must be a 16-length list!), label is the string to be used for dupe checks and removal
/mob/proc/apply_color_matrix(list/cmatrix, label, animate = 0)
	if (!cmatrix || !label)
		return

	if(label in src.color_matrices) // Do we already have this matrix?
		return

	LAZYLISTADDASSOC(src.color_matrices, label, cmatrix)

	src.update_active_matrix(animate)

/// Removes whichever matrix is associated with the label. Must be a string!
/mob/proc/remove_color_matrix(label, animate = 0)
	if (!label || !length(src.color_matrices))
		return

	if(label == "all")
		LAZYLISTSETLEN(src.color_matrices, 0)
	else if(!(label in src.color_matrices)) // Do we have this matrix?
		return
	else
		LAZYLISTREMOVE(src.color_matrices, label)

	src.update_active_matrix(animate)

/// Multiplies all of the mob's color matrices together and puts the result into src.active_color_matrix
/// This matrix will be applied to the mob at the end of this proc, and any time the client logs in
/// If animate is present, animate the transition for that many DS
/mob/proc/update_active_matrix(animate = 0)
	if (!length(src.color_matrices))
		src.active_color_matrix = null
	else
		var/first_entry = src.color_matrices[1]
		if (length(src.color_matrices) == 1) // Just one matrix?
			src.active_color_matrix = src.color_matrices[first_entry]
		else
			var/list/color_matrix_2_apply = src.color_matrices[first_entry]
			for(var/cmatrix in src.color_matrices)
				if (cmatrix == first_entry)
					continue // dont multiply the first matrix by itself
				else
					color_matrix_2_apply = mult_color_matrix(color_matrix_2_apply, src.color_matrices[cmatrix])
			src.active_color_matrix = color_matrix_2_apply
	if (animate)
		src.client?.animate_color(src.active_color_matrix, animate, respect_view_tint_settings = src.respect_view_tint_settings)
	else
		src.client?.set_color(src.active_color_matrix, src.respect_view_tint_settings)

/mob/proc/adjustBodyTemp(actual, desired, incrementboost, divisor)
	var/temperature = actual
	var/difference = abs(actual-desired)   // get difference
	var/increments = difference * divisor  //find how many increments apart they are
	var/change = increments*incrementboost // Get the amount to change by (x per increment)
	//change = change * 0.1

	if (actual < desired) // Too cold
		temperature += change
		if (actual > desired)
			temperature = desired

	if (actual > desired) // Too hot
		temperature -= change
		if (actual < desired)
			temperature = desired

	return temperature


//Gets rid of the mob without all the messy fuss of a gib
/mob/proc/remove()
	if (istype(src, /mob/dead/observer) || istype(src, /mob/dead/target_observer))
		return

	src.death(TRUE)
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		src.ghostize()

	qdel(src)

/mob/proc/gib(give_medal, include_ejectables)
	if (istype(src, /mob/dead/observer))
		gibs(src.loc)
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing(LOG_COMBAT, src, "is gibbed at [log_loc(src)].")
	src.death(TRUE)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	var/bdna = null // For forensics (Convair880).
	var/btype = null

	if (ishuman(src))
		if (src.bioHolder)
			bdna = src.bioHolder.Uid // Ditto (Convair880).
			btype = src.bioHolder.bloodType

		animation = new(src.loc)
		animation.master = src
		FLICK("gibbed", animation)

	if (src.client) // I feel like every player should be ghosted when they get gibbed
		var/mob/dead/observer/newmob = ghostize()
		newmob?.corpse = null
		if (!isnull(newmob) && give_medal)
			newmob.unlock_medal("Gore Fest", 1)

	var/list/ejectables = list_ejectables()
	for(var/obj/item/organ/organ in ejectables)
		if(organ.donor == src)
			organ.on_removal()
	if (!custom_gib_handler)
		if (iscarbon(src) || (ismobcritter(src) & !isrobocritter(src)))
			if (bdna && btype)
				. = gibs(src.loc, ejectables, bdna, btype, source=src) // For forensics (Convair880).
			else
				. = gibs(src.loc, ejectables, source=src)
		else
			. = robogibs(src.loc)
	else
		. = call(custom_gib_handler)(src.loc, ejectables, bdna, btype)

	// splash our fluids around
	if(src.reagents && src.reagents.total_volume)
		var/list/obj/get_our_fluids_here = list()
		for(var/obj/O in (. + ejectables))
			if(istype(O, /obj/decal/cleanable))
				var/obj/decal/cleanable/decal = O
				if(!decal.can_fluid_absorb)
					continue
			else if(istype(O, /obj/item/organ/heart))
				; // heart can have a little reagents, as a treat
			else if(istype(O, /obj/item/reagent_containers))
				; // some of our fluids got into a beaker, oh no!
			else
				continue
			get_our_fluids_here += O
		get_our_fluids_here += get_turf(src)

		var/transfer_amount = src.reagents.total_volume / length(get_our_fluids_here)
		for(var/atom/A in get_our_fluids_here)
			if(isturf(A))
				var/turf/T = A
				T.fluid_react(src.reagents, src.reagents.total_volume, airborne=prob(10))
				continue
			if(istype(A, /obj/decal/cleanable)) // expand reagents
				if(isnull(A.reagents))
					A.create_reagents(transfer_amount)
				else if(A.reagents.maximum_volume - A.reagents.total_volume < transfer_amount)
					A.reagents.maximum_volume = A.reagents.total_volume + transfer_amount
			if(A.reagents)
				src.reagents.trans_to(A, transfer_amount)

	for(var/obj/item/implant/I in src) qdel(I)

	if (animation)
		animation.delaydispose()
	qdel(src)
	if( include_ejectables )
		. += ejectables

/mob/proc/elecgib()
	if (isobserver(src)) return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing(LOG_COMBAT, src, "is electric-gibbed at [log_loc(src)].")
	src.death(TRUE)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	var/col_r = 0.4
	var/col_g = 0.8
	var/col_b = 1
	var/brightness = 0.7
	var/height = 1
	var/datum/light/light
	var/light_type = /datum/light/point

	if (ishuman(src))
		animation = new(src.loc)
		animation.master = src
		FLICK("elecgibbed", animation)
		if(ispath(light_type))
			light = new light_type
			light.set_brightness(brightness)
			light.set_color(col_r, col_g, col_b)
			light.set_height(height)
			light.attach(animation)
			light.enable()
			SPAWN(1 SECOND)
				qdel(light)
	else if(src.custom_gib_handler)
		call(src.custom_gib_handler)(src.loc)
	else if(issilicon(src) || isrobocritter(src))
		robogibs(src.loc)
	else
		gibs(src.loc)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob?.corpse = null

	if (animation)
		animation.delaydispose()
	qdel(src)


/mob/proc/firegib(var/drop_equipment = TRUE)
	if (isobserver(src))
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing(LOG_COMBAT, src, "is fire-gibbed at [log_loc(src)].")
	src.death(TRUE)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = TRUE
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	if (ishuman(src))
		animation = new(src.loc)
		animation.master = src
		FLICK("firegibbed", animation)
		if (drop_equipment)
			for (var/obj/item/W in src)
				if (istype(W, /obj/item/clothing))
					var/obj/item/clothing/C = W
					C.add_stain(/datum/stain/singed)
			unequip_all()

	if (drop_equipment)
		if (isrobot(src) || isrobocritter(src))
			robogibs(src.loc)
		else
			gibs(src.loc)

	if (animation)
		animation.delaydispose()

	src.ghostize()
	qdel(src)

/mob/proc/partygib(give_medal)
	if (isobserver(src))
		partygibs(src.loc)
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing(LOG_COMBAT, src, "is party-gibbed at [log_loc(src)].")
	src.death(TRUE)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	var/bdna = null // For forensics (Convair880).
	var/btype = null

	if (ishuman(src))
		if (src.bioHolder)
			bdna = src.bioHolder.Uid // Ditto (Convair880).
			btype = src.bioHolder.bloodType

		animation = new(src.loc)
		animation.master = src
		FLICK("gibbed", animation)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob?.corpse = null

	if (bdna && btype)
		partygibs(src.loc, bdna, btype) // For forensics (Convair880).
	else
		partygibs(src.loc)

	playsound(src.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 100, 1)

	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/owlgib(give_medal, control_chance = 1)
	if (isobserver(src))
		gibs(src.loc)
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	var/transfer_mind_to_owl = prob(control_chance)
	logTheThing(LOG_COMBAT, src, "is owl-gibbed at [log_loc(src)].")
	src.death(TRUE)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	var/bdna = null // For forensics (Convair880).
	var/btype = null

	if (ishuman(src))
		if (src.bioHolder)
			bdna = src.bioHolder.Uid // Ditto (Convair880).
			btype = src.bioHolder.bloodType

		animation = new(src.loc)
		animation.master = src
		FLICK("owlgibbed", animation)
		if (transfer_mind_to_owl)
			src.make_critter(/mob/living/critter/small_animal/bird/owl, src.loc)
		else
			var/mob/living/critter/small_animal/bird/owl/owl = new /mob/living/critter/small_animal/bird/owl(src.loc)
			owl.name = pick("Hooty Mc [src.real_name]", "Professor [src.real_name]", "Screechin' [src.real_name]")

	if (!transfer_mind_to_owl && (src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob?.corpse = null

	if (bdna && btype)
		gibs(src.loc, null, bdna, btype) // For forensics (Convair880).
	else
		gibs(src.loc)

	playsound(src.loc, 'sound/voice/animal/hoot.ogg', 100, 1)

	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/vaporize(give_medal, forbid_abberation)
	if (isobserver(src))
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	src.death(TRUE)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)
	logTheThing(LOG_COMBAT, src, "is vaporized at [log_loc(src)].")

	if (ishuman(src))
		animation = new(src.loc)
		animation.master = src
		FLICK("disintegrated", animation)

		if (prob(20))
			make_cleanable(/obj/decal/cleanable/ash, src.loc)

		if (!forbid_abberation && prob(50))
			new /mob/living/critter/aberration(get_turf(src))

	else
		gibs(src.loc)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob?.corpse = null

	elecflash(src.loc,exclude_center = 0)

	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/implode(give_medal)
	if (isobserver(src)) return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing(LOG_COMBAT, src, "imploded at [log_loc(src)].")
	src.death(TRUE)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	if (ishuman(src))
		animation = new(src.loc)
		animation.master = src
		FLICK("implode", animation)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob?.corpse = null

	playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 100, 1)

	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/cluwnegib(var/duration = 30, var/anticheat = 0)
	if(isobserver(src)) return
	SPAWN(0) //multicluwne
		duration = clamp(duration, 10, 100)

	#ifdef DATALOGGER
		game_stats.Increment("violence")
	#endif
		logTheThing(LOG_COMBAT, src, "is taken by the floor cluwne at [log_loc(src)].")
		src.transforming = 1
		src.canmove = 0
		src.anchored = ANCHORED_ALWAYS
		src.mouse_opacity = 0

		var/mob/living/carbon/human/cluwne/floor/floorcluwne = null
		if(anticheat)
			floorcluwne = new /mob/living/carbon/human/cluwne/floor/anticheat
			// As much as I detest istype(src) checks, this is the simplest way to make sure the anticheat cluwne gets unkillable dudes too.
			if(istype(src, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = src
				H.unkillable = 0
		else
			floorcluwne = new /mob/living/carbon/human/cluwne/floor

		var/list/cardinals = list(NORTH, SOUTH, WEST, EAST)
		var/turf/the_turf = null
		while(!the_turf)
			if(cardinals.len)
				var/C = pick(cardinals)
				the_turf = get_step(src, C)
				if(the_turf.density)
					the_turf = null //Prefer floors
					cardinals -= C
			else
				the_turf = get_turf(src)
				break //Well, if we're at null we don't want an infinite loop

		if(!the_turf)
			src.gib()
			return
		src.show_text("<span style=\"font-weight:bold; font-style:italic; color:red; font-family:'Comic Sans MS', sans-serif; font-size:200%;\">It's coming!!!</span>")
		playsound(the_turf, 'sound/ambience/industrial/AncientPowerPlant_Drone3.ogg', 70, TRUE)

		floorcluwne.loc=the_turf //I actually do want to bypass Entered() and Exit() stuff now tyvm
		animate_slide(the_turf, 0, -24, duration)
		sleep(duration/2)
		if(!floorcluwne)
			animate_slide(the_turf, 0, 0, duration)
			src.gib()
			return
		floorcluwne.say("honk honk motherfucker")
		floorcluwne.point(src)
		sleep(duration/2)
		if(!floorcluwne)
			animate_slide(the_turf, 0, 0, duration)
			src.gib()
			return
		floorcluwne.visible_message("<span style='font-weight:bold; color:red;'>[floorcluwne] drags [src] beneath \the [the_turf]!</span>")
		playsound(floorcluwne.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 60, 2)
		src.set_loc(the_turf)
		src.layer=0
		src.plane = PLANE_UNDERFLOOR
		animate_slide(the_turf, 0, 0, duration)
		sleep(duration+5)
		src.death(TRUE)
		var/mob/dead/observer/newmob = ghostize()
		newmob?.corpse = null

		qdel(floorcluwne)
		qdel(src)

/mob/proc/buttgib(give_medal)
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing(LOG_COMBAT, src, "is butt-gibbed at [log_loc(src)].")
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	var/bdna = null
	var/btype = null
	var/datum/organHolder/organHolder = null

	if (ishuman(src))
		var/mob/living/carbon/human_src = src
		if (src.bioHolder)
			bdna = src.bioHolder.Uid
			btype = src.bioHolder.bloodType
		if (human_src.organHolder)
			organHolder = human_src.organHolder

		animation = new(src.loc)
		animation.master = src
		FLICK("gibbed", animation)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob?.corpse = null

	var/list/ejectables = list_ejectables()

	for (var/i = 0, i < 16, i++)
		var/obj/item/clothing/head/butt/the_butt
		if (organHolder)
			the_butt = new /obj/item/clothing/head/butt(src.loc, organHolder)
		else if (istype(src, /mob/living/silicon))
			the_butt = new /obj/item/clothing/head/butt/cyberbutt
		else if (istype(src, /mob/living/intangible/wraith) || istype(src, /mob/dead))
			the_butt = new /obj/item/clothing/head/butt
			the_butt.setMaterial(getMaterial("ectoplasm"), appearance = TRUE, setname = TRUE)
		else if (istype(src, /mob/living/intangible/blob_overmind))
			the_butt = new /obj/item/clothing/head/butt
			the_butt.setMaterial(getMaterial("blob"), appearance = TRUE, setname = TRUE)
		else
			the_butt = new /obj/item/clothing/head/butt/synth

		ejectables += (the_butt)

	if (bdna && btype)
		gibs(src.loc, ejectables, bdna, btype)
	else
		gibs(src.loc, ejectables)

	playsound(src.loc, 'sound/voice/farts/superfart.ogg', 100, 1, channel=VOLUME_CHANNEL_EMOTE)
	var/turf/src_turf = get_turf(src)
	if(src_turf)
		src_turf.fluid_react_single("toxic_fart",50,airborne = 1)
		for(var/mob/living/L in range(src_turf, 6))
			shake_camera(L, 10, 32)

	src.death(TRUE)
	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/flockbit_gib()
	src.visible_message("<span class='alert bold'>[src] is torn apart from the inside as some weird floaty thing rips its way out of their body! Holy fuck!!</span>")
	var/mob/living/critter/flock/bit/B = new()
	var/turf/T = get_turf(src)
	B.set_loc(T)
	make_cleanable(/obj/decal/cleanable/flockdrone_debris, T)
	src.gib()

/mob/proc/smite_gib()
	var/turf/T = get_turf(src)
	showlightning_bolt(T)
	playsound(T, 'sound/effects/lightning_strike.ogg', 50, TRUE)
	src.unequip_all()
	src.emote("scream")
	src.gib()

/mob/proc/anvilgib(height = 7, use_shadow=TRUE, anvil_type=/obj/table/anvil/gimmick)
	logTheThing(LOG_COMBAT, src, "is anvil-gibbed at [log_loc(src)].")
	src.transforming = TRUE
	APPLY_ATOM_PROPERTY(src, PROP_MOB_CANTMOVE, "anvilgib")
	src.anchored = ANCHORED_ALWAYS

	var/obj/anvil = new anvil_type(get_turf(src))
	anvil.anchored = ANCHORED_ALWAYS
	anvil.pixel_y = 32 * height
	anvil.alpha = 0
	anvil.layer += 4
	anvil.plane = PLANE_NOSHADOW_ABOVE
	animate(anvil, alpha = 255, time = 0.9 SECONDS, flags = ANIMATION_PARALLEL)
	animate(anvil, pixel_y = 0, easing = EASE_IN | QUAD_EASING, time = 1.84 SECONDS, flags = ANIMATION_PARALLEL)

	var/obj/effects/shadow
	if(use_shadow)
		shadow = new /obj/effects{
			icon='icons/effects/96x96.dmi';
			icon_state="circle";
			mouse_opacity = 0;
			color = "#000000";
			alpha = 0;
			transform = matrix(0.8, 0, 0, 0, 0.5, 0);
			pixel_x = -32;
			pixel_y = -32 - 7;
			anchored = ANCHORED_ALWAYS;
			plane = PLANE_NOSHADOW_BELOW
		}(get_turf(src))
		animate(shadow, alpha = 150, transform = matrix(0.25, 0, 0, 0, 0.17, 0), easing = EASE_IN | QUAD_EASING, time = 1.75 SECONDS, flags = ANIMATION_PARALLEL)

	playsound(get_turf(src), 'sound/effects/cartoon_fall.ogg', 50, FALSE)
	SPAWN(1.8 SECONDS)
		src.gib()
		anvil.anchored = anvil_type == anvil_type ? FALSE : initial(anvil.anchored)
		anvil.plane = initial(anvil.plane)
		if(shadow)
			qdel(shadow)

// Man, there's a lot of possible inventory spaces to store crap. This should get everything under normal circumstances.
// Well, it's hard to account for every possible matryoshka scenario (Convair880).
/mob/proc/get_all_items_on_mob()
	if (!src)
		return null

	. = list()
	. += src.contents // Item slots.

	for (var/atom/A as anything in src.contents)
		if (A.storage)
			. += A.storage.get_all_contents()

// Made these three procs use get_all_items_on_mob(). "Steal X" objective should work more reliably as a result (Convair880).
/mob/proc/check_contents_for(A, var/accept_subtypes = 0)
 . = FALSE
	if (!src || !A)
		return

	var/list/L = src.get_all_items_on_mob()
	if (length(L))
		for (var/obj/B in L)
			if (B.type == A || (accept_subtypes && istype(B, A)))
				return TRUE

/mob/proc/check_contents_for_num(A, X, var/accept_subtypes = 0)
	. = FALSE
	if (!src || !A)
		return

	var/tally = 0
	var/list/L = src.get_all_items_on_mob()
	if (length(L))
		for (var/obj/B in L)
			if (B.type == A || (accept_subtypes && istype(B, A)))
				tally++

	if (tally >= X)
		. = TRUE

#define REFRESH "* Refresh list"
/mob/proc/print_contents(var/mob/output_target)
	if (!src || !ismob(src) || !output_target || !ismob(output_target))
		return

	var/list/L = src.get_all_items_on_mob()
	if (length(L))
		/// Sorted output list. Could definitely be improved, but is functional enough.
		var/list/OL = list()
		var/list/O_names = list()
		var/list/O_namecount = list()

		OL.Add(REFRESH)

		for (var/obj/O in L)
			if (!OL.Find(O))
				var/N = O.name
				var/N2
				if (O.loc == src)
					N2 = "mob"
				else
					N2 = O.loc.name

				if (N in O_names)
					O_namecount[N]++
					N = text("[] #[]", N, O_namecount[N])
				else
					O_names.Add(N)
					O_namecount[N] = 1

				var/N3 = "[N2]: [N]"
				OL[N3] = O

		sortList(OL, /proc/cmp_text_asc)

		while(TRUE)
			var/IP = input(output_target, "Select item to view fingerprints, cancel to close window.", "[src]'s inventory") as null|anything in OL

			if (!IP || !output_target || !ismob(output_target))
				return

			if (!src || !ismob(src))
				output_target.show_text("Target mob doesn't exist anymore.", "red")
				return

			if (IP == REFRESH)
				src.print_contents(output_target)
				return

			if (isnull(OL[IP]) || !isobj(OL[IP]))
				output_target.show_text("Selected object reference is invalid (item deleted?). Try freshing the list.", "red")

			if (output_target.client)
				output_target.client.view_fingerprints(OL[IP])

	return
#undef REFRESH

// adds a dizziness amount to a mob
// use this rather than directly changing var/dizziness
// since this ensures that the dizzy_process proc is started
// currently only humans get dizzy

// value of dizziness ranges from 0 to 500
// below 100 is not dizzy

/mob/proc/make_dizzy(var/amount)
	if (!ishuman(src)) // for the moment, only humans get dizzy
		return

	dizziness = min(500, dizziness + amount)	// store what will be new value
													// clamped to max 500
	if (dizziness > 100 && !is_dizzy)
		SPAWN(0)
			dizzy_process()


// dizzy process - wiggles the client's pixel offset over time
// spawned from make_dizzy(), will terminate automatically when dizziness gets <100
// note dizziness decrements automatically in the mob's Life() proc.
/mob/proc/dizzy_process()
	is_dizzy = 1
	while(dizziness > 100)
		if (client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y = amplitude * cos(0.008 * dizziness * world.time)

		sleep(0.1 SECONDS)
	//endwhile - reset the pixel offsets to zero
	is_dizzy = 0
	if (client)
		client.pixel_x = 0
		client.pixel_y = 0

// jitteriness - copy+paste of dizziness

/mob/proc/make_jittery(var/amount)
	jitteriness = min(400, jitteriness + amount)	// store what will be new value
													// clamped to max 400
	if (jitteriness > 100 && !is_jittery)
		SPAWN(0)
			jittery_process()


// jittery process - shakes the mob's pixel offset randomly
// will terminate automatically when dizziness gets <100
// jitteriness decrements automatically in the mob's Life() proc.
/mob/proc/jittery_process()
	is_jittery = 1
	while(jitteriness > 100)
//		var/amplitude = jitteriness*(sin(jitteriness * 0.044 * world.time) + 1) / 70
//		pixel_x = amplitude * sin(0.008 * jitteriness * world.time)
//		pixel_y = amplitude * cos(0.008 * jitteriness * world.time)

		var/amplitude = min(4, jitteriness / 100)
		var/off_x = rand(-amplitude, amplitude)
		var/off_y = rand(-amplitude/3, amplitude/3)

		animate(src, pixel_x = off_x, pixel_y = off_y, easing = JUMP_EASING, time = 0.5, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
		animate(pixel_x = off_x*-1, pixel_y = off_y*-1, easing = JUMP_EASING, time = 0.5, flags = ANIMATION_RELATIVE)
		sleep(0.1 SECONDS)
	//endwhile - reset the pixel offsets to zero
	is_jittery = 0

/mob/onVarChanged(variable, oldval, newval)
	. = ..()
	update_clothing()
	if(variable == "real_name")
		src.UpdateName()

/mob/proc/throw_item(atom/target, list/params)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_THROW_ITEM, target, params)
	actions.interrupt(src, INTERRUPT_ACT)

/mob/proc/adjust_throw(datum/thrown_thing/thr)
	return

/mob/throw_impact(atom/hit, datum/thrown_thing/thr)
	if (thr.throw_type & THROW_PEEL_SLIP)
		var/stun_duration = ("peel_stun" in thr.params) ? thr.params["peel_stun"] : 3 SECONDS
		if(("slip_obj" in thr.params) && istype(thr.params["slip_obj"], /obj/item/device/pda2/clown))
			animate_peel_slip(src, stun_duration=stun_duration, T = 0.85 SECONDS, n_flips = 2, height = 24)
		else
			animate_peel_slip(src, stun_duration=stun_duration)
		if(!isturf(hit) || hit.density)
			random_brute_damage(src, min((6 + (thr?.get_throw_travelled() / 5)), (src.health - 5) < 0 ? src.health : (src.health - 5)))
		return ..()

	if(!isturf(hit) || hit.density)
		if (thr?.get_throw_travelled() <= 410)
			if (!((thr.throw_type & THROW_CHAIRFLIP) && ismob(hit)))
				random_brute_damage(src, min((6 + (thr?.get_throw_travelled() / 5)), (src.health - 5) < 0 ? src.health : (src.health - 5)))
				if (!src.hasStatus("knockdown") && !(thr.throw_type & THROW_BASEBALL))
					src.lastgasp()
					src.changeStatus("knockdown", 2 SECONDS)
					src.force_laydown_standup()
			if (thr.throw_type & THROW_GIB)
				src.gib()
		else
			src.gib()

	return ..()

/mob/proc/addAbility(var/abilityType)
	abilityHolder.addAbility(abilityType)

/mob/proc/removeAbility(var/abilityType)
	abilityHolder.removeAbility(abilityType)

/mob/proc/getAbility(var/abilityType)
	return abilityHolder?.getAbility(abilityType)


/mob/proc/full_heal()
	SHOULD_CALL_PARENT(TRUE)
	if(src.ghost?.mind)
		src.ghost.mind.transfer_to(src)
		if(isliving(src))
			var/mob/living/L = src
			L.is_npc = FALSE
		if(isobserver(src.ghost))
			qdel(src.ghost)

	src.HealDamage("All", INFINITY, INFINITY, INFINITY)
	src.stuttering = 0
	src.losebreath = 0
	src.delStatus("drowsy")
	src.remove_stuns()
	src.delStatus("slowed")
	src.delStatus("nausea")
	src.delStatus("burning")
	src.delStatus("radiation")
	src.delStatus("critical_condition")
	src.delStatus("recent_trauma")
	src.delStatus("muted")
	src.take_radiation_dose(-INFINITY)
	src.change_eye_blurry(-INFINITY)
	src.take_eye_damage(-INFINITY)
	src.take_eye_damage(-INFINITY, 1)
	src.take_ear_damage(-INFINITY)
	src.take_ear_damage(-INFINITY, 1)
	src.take_brain_damage(-INFINITY)
	src.health = src.max_health
	src.buckled = null
	src.disfigured = FALSE
	if (src.reagents)
		src.reagents.clear_reagents()
	if (src.hasStatus("handcuffed"))
		src.handcuffs.destroy_handcuffs(src)
	src.bodytemperature = src.base_body_temp
	if (isdead(src))
		setalive(src)
	src.update_body()

/// Attempt to bring a mob just out of crit without immediately dropping back into crit
/mob/proc/stabilize()
	SHOULD_CALL_PARENT(TRUE)
	src.losebreath = min(src.losebreath, 2)
	src.delStatus("burning")
	src.delStatus("radiation")
	src.take_radiation_dose(-INFINITY)
	src.change_eye_blurry(-INFINITY)
	src.take_eye_damage(-INFINITY)
	src.take_eye_damage(-INFINITY, 1)
	src.take_ear_damage(-INFINITY)
	src.take_ear_damage(-INFINITY, 1)
	src.take_brain_damage(-(max(src.get_brain_damage()-10, 0))) // leave them with up to 10 brain damage
	src.health = max(src.health, 10)
	src.update_body()

/mob/proc/shock(var/atom/origin, var/wattage, var/zone, var/stun_multiplier = 1, var/ignore_gloves = 0)
	return 0

/mob/proc/flash(duration)
	return 0

/mob/proc/take_brain_damage(var/amount)
	if (!isnum(amount) || amount == 0)
		return 1
	return 0

/mob/proc/take_toxin_damage(var/amount)
	if (!isnum(amount) || amount == 0)
		return 1
	health_update_queue |= src
	return 0

/mob/proc/take_oxygen_deprivation(var/amount)
	if (!isnum(amount) || amount == 0)
		return 1
	health_update_queue |= src
	return 0

/mob/proc/get_eye_damage(var/tempblind = 0)
	if (tempblind == 0)
		return src.eye_damage
	else
		return src.eye_blind

/mob/proc/take_eye_damage(var/amount, var/tempblind = 0)
	//Shamefully stolen from the welder
	// and then from a different proc, to bring this in line with the other damage procs
	//
	// Then I came along and integrated eye_blind handling (Convair880).

	if (!src || !ismob(src) || (!isnum(amount) || amount == 0))
		return 0

	var/eyeblind = 0
	if (tempblind == 0)
		src.eye_damage = max(0, src.eye_damage + amount)
	else
		eyeblind = amount

	// Modify eye_damage or eye_blind if prompted, but don't perform more than we absolutely have to.
	var/blind_bypass = 0
	if (src.bioHolder && src.bioHolder.HasEffect("blind"))
		blind_bypass = 1

	if (amount > 0 && tempblind == 0 && blind_bypass == 0) // so we don't enter the damage switch thing if we're healing damage
		switch (src.eye_damage)
			if (10 to 12)
				src.change_eye_blurry(rand(3,6))

			if (12 to 15)
				src.show_text("Your eyes hurt.", "red")
				src.change_eye_blurry(rand(6,9))

			if (15 to 25)
				src.show_text("Your eyes are really starting to hurt.", "red")
				src.change_eye_blurry(rand(12,16))

				if (prob(src.eye_damage - 15 + 1))
					src.show_text("Your eyes are badly damaged!", "red")
					eyeblind = 5
					src.change_eye_blurry(5)
					src.bioHolder.AddEffect("bad_eyesight")
					SPAWN(10 SECONDS)
						src.bioHolder.RemoveEffect("bad_eyesight")

			if (25 to INFINITY)
				src.show_text("<B>Your eyes hurt something fierce!</B>", "red")

				if (prob(src.eye_damage - 25 + 1))
					src.show_text("<b>You go blind!</b>", "red")
					src.bioHolder.AddEffect("blind")
				else
					src.change_eye_blurry(rand(12,16))

	if (eyeblind != 0)
		src.eye_blind = max(0, src.eye_blind + eyeblind)

	//DEBUG_MESSAGE("Eye damage applied: [amount]. Tempblind: [tempblind == 0 ? "N" : "Y"]")
	return 1

/mob/proc/get_eye_blurry()
	return src.eye_blurry

// Why not, I suppose. Wraps up the three major eye-related mob vars (Convair880).
/mob/proc/change_eye_blurry(var/amount, var/cap = 0)
	if (!src || !ismob(src) || (!isnum(amount) || amount == 0))
		return 0

	var/upper_cap_default = 150
	var/upper_cap = upper_cap_default
	if (cap && isnum(cap) && (cap > 0 && cap < upper_cap_default))
		if (src.get_eye_blurry() >= cap)
			return
		else
			upper_cap = cap

	src.eye_blurry = clamp(src.eye_blurry + amount, 0, upper_cap)
	//DEBUG_MESSAGE("Amount is [amount], new eye blurry is [src.eye_blurry], cap is [upper_cap]")
	return 1

/mob/proc/get_ear_damage(var/tempdeaf = 0)
	if (tempdeaf == 0)
		return src.ear_damage
	else
		return src.ear_deaf

// And here's the missing one for ear damage too (Convair880).
/mob/proc/take_ear_damage(var/amount, var/tempdeaf = 0)
	if (!src || !ismob(src) || (!isnum(amount) || amount == 0))
		return 0

	var/eardeaf = 0
	if (tempdeaf == 0)
		src.ear_damage = max(0, src.ear_damage + amount)
	else
		eardeaf = amount

	// Modify ear_damage or ear_deaf if prompted, but don't perform more than we absolutely have to.
	var/deaf_bypass = 0
	if (src.ear_disability)
		deaf_bypass = 1

	if (amount > 0 && tempdeaf == 0 && deaf_bypass == 0)
		switch (src.ear_damage)
			if (10 to 12)
				eardeaf += 1

			if (13 to 15)
				boutput(src, SPAN_ALERT("Your ears ring a bit!"))
				eardeaf += rand(2, 3)

			if (15 to 24)
				boutput(src, SPAN_ALERT("Your ears are really starting to hurt!"))
				eardeaf += src.ear_damage * 0.5

			if (25 to INFINITY)
				boutput(src, SPAN_ALERT("<b>Your ears ring very badly!</b>"))

				if (src.bioHolder && prob(src.ear_damage - 10 + 5))
					src.show_text("<b>You go deaf!</b>", "red")
					src.bioHolder.AddEffect("deaf")
				else
					eardeaf += src.ear_damage * 0.75

	if (eardeaf != 0)
		var/suppress_message = 0
		if (!src.get_ear_damage(1) && eardeaf < 0) // We don't have any temporary deafness to begin with and are told to heal it.
			suppress_message = 1
		if (src.get_ear_damage(1) && (src.get_ear_damage(1) + eardeaf) > 0) // We already have temporary deafness and are adding to it.
			suppress_message = 1

		src.ear_deaf = max(0, src.ear_deaf + eardeaf)

		if (src.ear_deaf == 0 && deaf_bypass == 0 && suppress_message == 0)
			boutput(src, SPAN_NOTICE("The ringing in your ears subsides enough to let you hear again."))
		else if (eardeaf > 0 && deaf_bypass == 0 && suppress_message == 0)
			boutput(src, SPAN_ALERT("The ringing overpowers your ability to hear momentarily."))

	//DEBUG_MESSAGE("Ear damage applied: [amount]. Tempdeaf: [tempdeaf == 0 ? "N" : "Y"]")
	return 1

// No natural healing can occur if ear damage is above this threshold. Didn't want to make it yet another mob parent var.
/mob/proc/get_ear_damage_natural_healing_threshold()
	return max(0, src.max_health / 4)

/mob/proc/lose_breath(var/amount)
	if (!isnum(amount) || amount == 0)
		return 1
	return 0

/mob/proc/change_misstep_chance(var/amount)
	if (!isnum(amount) || amount == 0)
		return 1
	return 0

/mob/proc/get_brain_damage()
	return 0

/mob/proc/get_brute_damage()
	return 0

/mob/proc/get_burn_damage()
	return 0

/mob/proc/get_toxin_damage()
	return 0

/mob/proc/get_oxygen_deprivation()
	return 0

///mob/proc/get_radiation()
//	return radiation

/mob/UpdateName()
	if (src.real_name)
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"
	else
		src.name = "[name_prefix(null, 1)][initial(src.name)][name_suffix(null, 1)]"
	src.update_name_tag()

/mob/proc/update_name_tag(name=null)
	if(isnull(src.name_tag))
		return
	if(isnull(name))
		name = src.name
	if(name == "Unknown")
		name = ""
	var/the_pos = findtext(name, " the")
	if(the_pos)
		name = copytext(name, 1, the_pos)
	if(name)
		src.name_tag.set_info_tag(he_or_she(src))
	else
		src.name_tag.set_info_tag("")
	src.name_tag.set_name(name, strip_parentheses=TRUE)

/mob/proc/get_tracked_examine_atoms()
	return mobs

/mob/get_examine_tag(mob/examiner)
	return src.name_tag

/mob/proc/protected_from_space()
	return 0

/mob/proc/list_ejectables()
	return list()

/mob/proc/get_valid_target_zones()
	return list()

/mob/proc/add_ability_holder(holder_type)
	if (abilityHolder && istype(abilityHolder, /datum/abilityHolder/composite))
		var/datum/abilityHolder/composite/C = abilityHolder
		C.addHolder(holder_type)
		return C.getHolder(holder_type)
	else if (abilityHolder)
		var/datum/abilityHolder/T = abilityHolder
		var/datum/abilityHolder/composite/C = new(src)
		C.holders = list(T)
		C.addHolder(holder_type)
		return C.getHolder(holder_type)
	else
		abilityHolder = new holder_type(src)
		return abilityHolder

/mob/proc/get_ability_holder(holder_type)
	if (abilityHolder && istype(abilityHolder, /datum/abilityHolder/composite))
		var/datum/abilityHolder/composite/C = abilityHolder
		return C.getHolder(holder_type)
	else if (abilityHolder && abilityHolder.type == holder_type)
		return abilityHolder
	return null

/mob/proc/remove_ability_holder(var/datum/abilityHolder/H)
	if (abilityHolder && istype(abilityHolder, /datum/abilityHolder/composite))
		var/datum/abilityHolder/composite/C = abilityHolder
		return C.removeHolder(H)
	else if (abilityHolder && abilityHolder == H)
		abilityHolder = null

/mob/proc/add_existing_ability_holder(var/datum/abilityHolder/H)
	if (H.owner != src)
		H.owner = src
	if (abilityHolder && istype(abilityHolder, /datum/abilityHolder/composite))
		var/datum/abilityHolder/composite/C = abilityHolder
		C.addHolderInstance(H)
		return H
	else if (abilityHolder)
		var/datum/abilityHolder/T = abilityHolder
		var/datum/abilityHolder/composite/C = new(src)
		C.holders = list(T, H)
		return H
	else
		abilityHolder = H
		return H

/mob/proc/on_reagent_react(var/datum/reagents/R, var/method = 1, var/react_volume = null)

/mob/proc/HealBleeding(var/amt)

/mob/proc/find_in_equipment(var/eqtype)
	return null

/mob/proc/get_slot_from_item(var/obj/item/I)
	return null

/mob/proc/is_in_hands(var/obj/O)
	return 0

/mob/proc/does_it_metabolize()
	return 0

/mob/proc/isBlindImmune()
	return 0

/mob/proc/canRideMailchutes()
	return 0

/mob/proc/isAIControlled()
	return 0

/mob/proc/choose_name(var/retries = 3, var/what_you_are = null, var/default_name = null, var/force_instead = 0)
	var/newname
	for (retries, retries > 0, retries--)
		if(force_instead)
			newname = default_name
		else
			newname = tgui_input_text(src, "[what_you_are ? "You are \a [what_you_are]. " : null]Would you like to change your name to something else?", "Name Change", default_name || src.real_name)
		if (!newname)
			return
		else
			newname = strip_html(newname, MOB_NAME_MAX_LENGTH, 1)
			newname = remove_bad_name_characters(newname)
			if (!length(newname) || copytext(newname,1,2) == " ")
				src.show_text("That name was too short after removing bad characters from it. Please choose a different name.", "red")
				continue
			else
				if (force_instead || tgui_alert(src, "Use the name [newname]?", newname, list("Yes", "No")) == "Yes")
					for (var/datum/record_database/DB in list(data_core.bank, data_core.security, data_core.general, data_core.medical))
						var/datum/db_record/R = DB.find_record("id", src.datacore_id)
						if (R)
							R["name"] = newname
							if (R["full_name"])
								R["full_name"] = newname
					for (var/obj/item/I in src.contents)
						var/obj/item/card/id/ID = get_id_card(I)
						if (!ID)
							if(length(I.contents)>0)
								for(var/obj/item/J in I.contents)
									var/obj/item/card/id/ID_maybe = get_id_card(J)
									if(!ID_maybe)
										continue
									if(ID_maybe && ID_maybe.registered == src.real_name)
										ID = ID_maybe
						if(ID)
							ID.registered = newname
							ID.update_name()
					for (var/obj/item/device/pda2/PDA in src.contents)
						PDA.registered = newname
						PDA.owner = newname
						PDA.name = "PDA-[newname]"
						if(PDA.ID_card)
							var/obj/item/card/id/ID = PDA.ID_card
							ID.registered = newname
							ID.update_name()
					src.real_name = newname
					src.UpdateName()
					return 1
				else
					continue
	if (!newname)
		if (default_name)
			src.real_name = default_name
		else if (src.client && src.client.preferences && src.client.preferences.real_name)
			src.real_name = src.client.preferences.real_name
		else
			src.real_name = random_name(src.gender)
		src.UpdateName()

/mob/proc/set_mutantrace(var/mutantrace_type)
	return

/proc/random_name(var/gen = MALE)
	var/return_name
	if (gen == MALE)
		return_name = capitalize(pick_string_autokey("names/first_male.txt") + " " + capitalize(pick_string_autokey("names/last.txt")))
	else if (gen == FEMALE)
		return_name = capitalize(pick_string_autokey("names/first_female.txt") + " " + capitalize(pick_string_autokey("names/last.txt")))
	else
		return_name = capitalize(pick_string_autokey("names/first_[prob(50)?"fe":""]male.txt") + " " + capitalize(pick_string_autokey("names/last.txt")))
	return return_name

/mob/OnMove(source = null)
	..()
	if(client?.player?.shamecubed)
		loc = client.player.shamecubed
		return

	if (waddle_walking)
		if(isdead(src) || is_incapacitated(src) || src.lying)
			return
		makeWaddle(src)

	last_move_dir = move_dir

	if (source && source != src) //we were moved by something that wasnt us
		last_pulled_time = world.time
		if ((istype(src.loc, /turf/space) || src.no_gravity) && ismob(source))
			var/mob/M = source
			src.inertia_dir = M.inertia_dir
	else
		if(src.pulled_by)
			src.pulled_by.remove_pulling()

/mob/proc/on_centcom()
	. = FALSE
	var/mob_loc = src.loc
	if (isobj(src.loc))
		var/obj/O = src.loc
		mob_loc = O.loc

	var/turf/location = get_turf(mob_loc)
	if (!location)
		return

	var/area/check_area = location.loc
	if (istype(check_area, map_settings.escape_centcom))
		. = TRUE

/mob/proc/is_hulk()
	. = FALSE
	if (src.bioHolder && src.bioHolder.HasAnyEffect(list("hulk", "hulk_hidden")))
		. = TRUE

/mob/proc/update_equipped_modifiers()
	var/datum/movement_modifier/equipment/equipment_proxy = locate() in src.movement_modifiers
	if (!equipment_proxy)
		equipment_proxy = new
		APPLY_MOVEMENT_MODIFIER(src, equipment_proxy, /obj/item)

	// reset the modifiers to defaults
	var/modifier = 1-GET_ATOM_PROPERTY(src, PROP_MOB_MOVESPEED_ASSIST)

	equipment_proxy.additive_slowdown = GET_ATOM_PROPERTY(src, PROP_MOB_EQUIPMENT_MOVESPEED)
	if(equipment_proxy.additive_slowdown > 0)
		equipment_proxy.additive_slowdown *= modifier
	equipment_proxy.space_movement = GET_ATOM_PROPERTY(src, PROP_MOB_EQUIPMENT_MOVESPEED_SPACE)
	if(equipment_proxy.space_movement > 0)
		equipment_proxy.space_movement *= modifier
	equipment_proxy.aquatic_movement = GET_ATOM_PROPERTY(src, PROP_MOB_EQUIPMENT_MOVESPEED_FLUID)
	if(equipment_proxy.aquatic_movement > 0)
		equipment_proxy.aquatic_movement *= modifier
		if(modifier == 0) // aquatic_movement requires a positive value to skip added fluid turf delay
			equipment_proxy.aquatic_movement += 0.01


/mob/proc/nauseate(stacks = 1)
	if (isalive(src))
		src.setStatus("nausea", INFINITE_STATUS, stacks)

// alright this is copy pasted a million times across the code, time for SOME unification - cirr
/mob/proc/vomit(var/nutrition=0, var/specialType=null, var/flavorMessage="[src] vomits!", var/selfMessage = null)
	SHOULD_CALL_PARENT(TRUE)
	. = TRUE
	if (HAS_ATOM_PROPERTY(src, PROP_MOB_CANNOT_VOMIT)) // Anti-emetics stop vomiting from occuring
		return 0
	SEND_SIGNAL(src, COMSIG_MOB_VOMIT, 1)
	if (!specialType && length(src.vomit_behaviors))
		var/datum/vomit_behavior/chosen = pick(src.vomit_behaviors)
		specialType = chosen.vomit(src)
	if (!specialType)
		src.visible_message(flavorMessage, selfMessage) //assume the special behavior handles the message
	playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
	if(specialType)
		if(!locate(specialType) in src.loc)
			var/atom/A = new specialType(src.loc)
			A.blood_DNA = src.bioHolder.Uid
	else
		if(!locate(custom_vomit_type) in src.loc)
			var/obj/decal/cleanable/vomit = make_cleanable(custom_vomit_type,src.loc)
			vomit.blood_DNA = src.bioHolder.Uid

	src.nutrition -= nutrition
	src.changeStatus("stunned", 2 SECONDS)
	src.change_misstep_chance(5)
	src.delStatus("nausea")

/mob/proc/add_vomit_behavior(type)
	LAZYLISTADDUNIQUE(src.vomit_behaviors, new type)

/mob/proc/remove_vomit_behavior(type)
	var/datum/vomit_behavior/behavior = locate(type) in src.vomit_behaviors
	LAZYLISTREMOVE(src.vomit_behaviors, behavior)

/mob/proc/accept_forcefeed(obj/item/item, mob/user, edibility_override) //just.. don't ask
	item.forcefeed(src, user, edibility_override)

/mob/proc/get_hand_pixel_x()
	.= 0
/mob/proc/get_hand_pixel_y()
	.= 0


/mob/proc/hell_respawn(var/datum/mind/newmind = null)
	if(!newmind)
		if(src.mind)
			newmind = src.mind
		else
			return
	if (src.mind)
		if(src.mind.damned)
			boutput(src, SPAN_ALERT("You can never escape."))
		else // uhhhhh how did you get here. You didnt sin enough! Go back and try harder!
			return

	var/turf/reappear_turf = pick(get_area_turfs(/area/afterlife/hell/hellspawn))
	////////////////Set up the new body./////////////////

	var/mob/living/carbon/human/newbody = new()
	newbody.set_loc(reappear_turf)
	newbody.equip_new_if_possible(/obj/item/clothing/under/misc/prisoner, SLOT_W_UNIFORM)

	newbody.real_name = src.real_name

	newbody.abilityHolder = src.abilityHolder
	if (newbody.abilityHolder)
		newbody.abilityHolder.transferOwnership(newbody)
	src.abilityHolder = null

	newbody.nodamage = 1

	if (src.bioHolder)
		newbody.bioHolder.CopyOther(src.bioHolder)

	if (src.mind) //Mind transfer also handles key transfer.
		src.mind.transfer_to(newbody)
	else //Oh welp, still need to move that key!
		newbody.key = src.key
	qdel(src)
	////////////Now play the degibbing animation and move them to the turf.////////////////

	var/atom/movable/overlay/animation = new(reappear_turf)
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	animation.icon_state = "ungibbed"
	src = null //Detach this, what if we get deleted before the animation ends??
	SPAWN(0.7 SECONDS) //Length of animation.
		newbody.set_loc(animation.loc)
		qdel(animation)
		newbody.anchored = ANCHORED_ALWAYS // Stop running into the lava every half second jeez!
		sleep(4 SECONDS)
		reset_anchored(newbody)

/mob/proc/damn()
	if(!src.mind)
		return
	src.mind.damned = 1
	src.nodamage = 1
	var/duration = 30

	SPAWN(0) //multisatan
		logTheThing(LOG_COMBAT, src, "is damned to hell from [log_loc(src)].")
		src.transforming = 1
		src.canmove = 0
		src.anchored = ANCHORED_ALWAYS
		src.mouse_opacity = 0

		var/mob/living/carbon/human/satan/satan = new /mob/living/carbon/human/satan

		var/list/cardinals = list(NORTH, SOUTH, WEST, EAST)
		var/turf/the_turf = null
		while(!the_turf)
			if(cardinals.len)
				var/C = pick(cardinals)
				the_turf = get_step(src, C)
				if(the_turf.density)
					the_turf = null //Prefer floors
					cardinals -= C
			else
				the_turf = get_turf(src)
				break //Well, if we're at null we don't want an infinite loop

		if(!the_turf)
			src.gib() // ghostize will handle the rest.
			return
		playsound(the_turf, 'sound/effects/damnation.ogg', 50, TRUE)

		satan.loc=the_turf //I actually do want to bypass Entered() and Exit() stuff now tyvm
		animate_slide(the_turf, 0, -24, duration)
		sleep(duration/2)
		if(!satan)
			return

		satan.say("Ah, [src.real_name]. I've been expecting you.")
		satan.point(src)
		sleep(duration/2)
		if(!satan)
			animate_slide(the_turf, 0, 0, duration)
			src.gib()
			return
		satan.visible_message("<span style='font-weight:bold; color:red;'>[satan] drags [src] off to hell!</span>")
		if(ishuman(src))
			src.unequip_all()
		src.set_loc(the_turf)
		src.layer = 0
		src.plane = PLANE_UNDERFLOOR
		animate_slide(the_turf, 0, 0, duration)
		src.emote("scream") // AAAAAAAAAAAA
		sleep(duration+5)
		src.hell_respawn()
		qdel(satan)

/mob/proc/un_damn()
	if(!src.mind)
		return
	src.mind.damned = 0
	src.ghostize()
	qdel(src)
	return

/mob/proc/get_random_equipped_thing_name() //FOR FLAVOR USE ONLY
	.= 0

/mob/proc/handle_stamina_updates()
	.= 0

/mob/proc/update_canmove()
	return

/*/mob/proc/glove_weaponcheck()
	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		if (H.gloves.activeweapon)
			return 1
		else
			return 0*/

/mob/proc/sell_soul(var/amount, var/reduce_health=1, var/allow_overflow=0)
	if(!src.mind)
		return 0
	if(isnpc(src))
		return 0
	if(allow_overflow)
		amount = clamp(src.mind.soul, 1, amount) // can't sell less than 1
	if (isdiabolical(src))
		boutput(src, SPAN_NOTICE("You collect souls, why would you want to sell yours?"))
		return 0
	if(istype(src, /mob/living/carbon/human) && src:unkillable) //shield of souls interaction
		boutput(src,SPAN_ALERT("<b>Your soul is shielded and cannot be sold!</b>"))
		return 0
	if(amount > src.mind.soul)
		boutput(src, SPAN_ALERT("<b>You don't have enough of a soul to sell!</b>"))
		return 0
	boutput(src, SPAN_ALERT("<b>You feel a portion of your soul rip away from your body!</b>"))
	if(reduce_health)
		var/current_penalty = src.hasStatus("maxhealth-")?:change
		src.setStatus("maxhealth-", null, current_penalty - amount / 4 * 3)
	src.mind.soul -= amount

	if(src.mind.soul <= 0)
		souladjust(1)
	return 1

/mob/proc/get_id(not_worn = FALSE)
	RETURN_TYPE(/obj/item/card/id)
	return get_id_card(src.equipped())

/mob/proc/add_karma(how_much)
	src.mind?.add_karma(how_much)
	// TODO add NPC karma

/mob/set_dir(var/new_dir)
	if (!src.dir_locked)
		..()
		src.update_directional_lights()

// http://www.byond.com/forum/post/1326139&page=2
//MOB VERBS ARE FASTER THAN OBJ VERBS, ELIMINATE ALL OBJ VERBS WHERE U CAN
// ALSO EXCLUSIVE VERBS (LIKE ADMIN VERBS) ARE BAD FOR RCLICK TOO, TRY NOT TO USE THOSE OK

/mob/verb/point(atom/A as mob|obj|turf in view(,usr))
	set name = "Point"
	src.point_at(A)

/mob/proc/point_at(var/atom/target, var/pixel_x, var/pixel_y) //overriden by living and dead
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_POINT, target)

/mob/verb/pull_verb(atom/movable/A as mob|obj in oview(1, usr))
	set name = "Pull / Unpull"
	set category = "Local"

	if (src.pulling && src.pulling == A)
		unpull_particle(src,src.pulling)
		src.set_pulling(null)
	else
		A.pull(src)


/mob/verb/examine_verb(atom/A as mob|obj|turf in view(,usr))
	set name = "Examine"
	set category = "Local"
	var/list/result = A.examine(src)
	SEND_SIGNAL(A, COMSIG_ATOM_EXAMINE, src, result)
	if(src.client?.preferences?.help_text_in_examine)
		var/help_examine = src.get_final_help_examine(A)
		if(help_examine)
			result += "<br>[SPAN_HELPMSG("[help_examine]")]"
	boutput(src, result.Join("\n"))

/mob/verb/global_help_verb() // (atom/A = null as null|mob|obj|turf in view(,usr))
	set name = "Help"
	set category = "Commands"
	set desc = "Shows you a help message on how to use an object."
	set popup_menu = FALSE

	// This has no arguments because I want it to be clickable directly from the Commands tab (to show the general help message) and when typed into
	// the command bar. If we gave this an argument it would always give you an ugly list of things you can see.
	// But we still do want arguments so we can use it from the right click menu etc.
	// It's sort of a mess, but it works. Trust me.
	var/atom/target = length(args) >= 1 ? args[1] : null

	if(target)
		var/success = src.help_examine(target)
		if(!success)
			boutput(src, SPAN_ALERT("Sadly \the [target] has no help message attached."))
	else
		boutput(src, {"<span class='helpmsg'>
			You can use this command by right clicking an object and selecting Help (not all objects support this).<br>
			You can also do that by alt+doubleclicking on that object.<br>
			If you are new here consider looking at the <a target='_blank' href='https://wiki.ss13.co/Getting_Started#Fundamentals'>quick-start guide</a> for help.<br>
			You can also press <b>F3</b> to ask the mentors for help.<br>
			For reporting rulebreaking or rules questions press <b>F1</b>.<br>
		</span>"})

/atom/verb/help_verb()
	set name = "Help"
	set category = "Local"
	set desc = "Shows you a help message on how to use an object."
	set popup_menu = FALSE // overriden to TRUE on things which have a help message
	set hidden = TRUE // ditto
	set src in view()

	var/success = usr.help_examine(src)
	if(!success)
		boutput(usr, SPAN_ALERT("Sadly \the [src] has no help message attached."))

/// Same as help_verb but this one except visible, added dynamically when requested by signals
/atom/proc/help_verb_dynamic()
	set name = "Help"
	set category = "Local"
	set desc = "Shows you a help message on how to use an object."
	set popup_menu = TRUE
	set hidden = FALSE
	set src in view()

	var/success = usr.help_examine(src)
	if(!success)
		boutput(usr, SPAN_ALERT("Sadly \the [src] has no help message attached."))

/mob/living/verb/interact_verb(atom/A as mob|obj|turf in oview(1, usr))
	set name = "Pick Up / Left Click"
	set category = "Local"

	if(src.client)
		src.client.Click(A, get_turf(A))

/mob/living/verb/pickup_verb()
	set name = "Pick Up"
	set hidden = 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if (I.loc == get_turf(I))
			items += I
	if (items.len)
		var/atom/A = input(usr, "What do you want to pick up?") as null|anything in items
		if (A)
			src.client?.Click(A, get_turf(A))

/mob/proc/can_eat(var/atom/A)
	return 1

/mob/proc/on_eat(var/atom/A)
	return

/mob/proc/can_drink(var/atom/A)
	return TRUE


// to check if someone is abusing cameras with stuff like artifacts, power gloves, etc
/mob/proc/in_real_view_range(var/turf/T)
	return src.client && IN_RANGE(T, src, WIDE_TILE_WIDTH)


/mob/MouseEntered(location, control, params)
	var/mob/M = usr
	M.atom_hovered_over = src
	if(M.client.check_key(KEY_EXAMINE))
		var/atom/movable/name_tag/hover_tag = src.get_examine_tag(M)
		hover_tag?.show_images(M.client, FALSE, TRUE)

/mob/MouseExited(location, control, params)
	var/mob/M = usr
	M.atom_hovered_over = null
	var/atom/movable/name_tag/hover_tag = src.get_examine_tag(M)
	hover_tag?.show_images(M.client, M.client.check_key(KEY_EXAMINE) && HAS_ATOM_PROPERTY(M, PROP_MOB_EXAMINE_ALL_NAMES) ? TRUE : FALSE, FALSE)

/mob/proc/get_pronouns()
	RETURN_TYPE(/datum/pronouns)
	if(isnull(.))
		. = src?.bioHolder?.mobAppearance?.pronouns
	if(isnull(.))
		switch(src.bioHolder?.mobAppearance?.gender || src.gender)
			if(MALE)
				. = get_singleton(/datum/pronouns/heHim)
			if(FEMALE)
				. = get_singleton(/datum/pronouns/sheHer)
			if(NEUTER)
				. = get_singleton(/datum/pronouns/itIts)
			else
				. = get_singleton(/datum/pronouns/theyThem)


/// absorb radiation dose in Sieverts (note 0.4Sv is enough to make someone sick. 2Sv is enough to make someone dead without treatment, 4Sv is enough to make them dead.)
/mob/proc/take_radiation_dose(Sv,internal=FALSE)
	if(check_target_immunity(src, TRUE))
		return
	var/rad_res = GET_ATOM_PROPERTY(src,PROP_MOB_RADPROT_INT) || 0 //atom prop can return null, we need it to default to 0
	if(!internal)
		rad_res += GET_ATOM_PROPERTY(src,PROP_MOB_RADPROT_EXT) || 0
	if(Sv > 0)
		if(isdead(src))
			return //no rads for the dead
		src.last_radiation_dose_time = TIME
		var/radres_mult = 1.0 - (tanh(0.02*rad_res)**2)
		src.radiation_dose += radres_mult*Sv
		SEND_SIGNAL(src, COMSIG_MOB_GEIGER_TICK, geiger_stage(Sv))
		. = radres_mult*Sv
	else
		src.radiation_dose = max(0, src.radiation_dose + Sv) //rad resistance shouldn't stop you healing
		. = Sv
	src.radiation_dose = clamp(src.radiation_dose, 0, 10 SIEVERTS) //put a cap on it

/// set_loc(mob) and set src.observing properly - use this to observe a mob, so it can be handled properly on deletion
/mob/proc/observeMob(mob/target)
	src.set_loc(target)
	src.observing = target

/// called when the observed mob is deleted, override for custom behaviour.
/mob/proc/stopObserving()
	src.set_loc(get_turf(src.observing))
	src.observing = null
	src.ghostize()

/// search for any radio device, starting with hands and then equipment
/// anything else is arbitrarily too deeply hidden and stowed away to get the signal
/// (more practically, they won't hear it)
/mob/proc/find_radio()
	if(istype(src.ears, /obj/item/device/radio))
		return src.ears
	. = src.find_type_in_hand(/obj/item/device/radio)
	if(!.)
		. = src.find_in_equipment(/obj/item/device/radio)

///Returns the default HUD of the mob, whatever that may be
/mob/proc/get_hud()
	return null

///like step_towards(), but respects move delay etc.
/mob/proc/step_towards_movedelay(atom/trg)
	var/move_dir_old = src.move_dir
	src.move_dir = get_dir(src, trg)
	src.process_move()
	src.move_dir = move_dir_old

//the stupid hack reflection zone (im sorry)

/mob/proc/addBioEffect(var/idToAdd, var/power = 0, var/timeleft = 0, var/do_stability = 1, var/magical = 0, var/safety = 0)
	src.bioHolder?.AddEffect(idToAdd, power, timeleft, do_stability, magical, safety)

/mob/proc/addTrait(id, datum/trait/trait_instance=null)
	src.traitHolder?.addTrait(id, trait_instance)

/mob/proc/add_antagonist(role_id, do_equip = TRUE, do_objectives = TRUE, do_relocate = TRUE, silent = FALSE, source = ANTAGONIST_SOURCE_OTHER, respect_mutual_exclusives = TRUE, do_pseudo = FALSE, do_vr = FALSE, late_setup = FALSE)
	src.mind?.add_antagonist(role_id, do_equip, do_objectives, do_relocate, silent, source, respect_mutual_exclusives, do_pseudo, do_vr, late_setup)

/mob/proc/inhale_ampoule(obj/item/reagent_containers/ampoule/amp, mob/user)
	if(user != src)
		user.visible_message(SPAN_ALERT("[user] forces [src] to inhale [amp]!"), SPAN_ALERT("You force [src] to inhale [amp]!"))
	logTheThing(LOG_COMBAT, user, "[user == src ? "inhales" : "makes [constructTarget(src,"combat")] inhale"] an ampoule [log_reagents(amp)] at [log_loc(user)].")
	amp.reagents.reaction(src, INGEST, 5, paramslist = list("inhaled"))
	amp.reagents.trans_to(src, 5)
	amp.expended = TRUE
	amp.icon_state = "amp-broken"
	playsound(user.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, TRUE)

/mob/proc/remove_stuns()
	src.delStatus("stunned")
	src.delStatus("knockdown")
	src.delStatus("unconscious")
	src.delStatus("paralysis")

/mob/proc/has_genetics()
	return FALSE

/mob/proc/get_genetic_traits()
	return list(0,0,0)

/mob/proc/get_fingertip_color()
	if (src.bioHolder?.mobAppearance)
		return src.bioHolder.mobAppearance.s_tone
	return "#042069"

/mob/proc/scald_temp()
	return src.base_body_temp + (src.temp_tolerance * 4)

/mob/proc/frostburn_temp()
	return src.base_body_temp - (src.temp_tolerance * 4)
