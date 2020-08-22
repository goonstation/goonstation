/mob
	density = 1
	layer = MOB_LAYER
	animate_movement = 2
	soundproofing = 10

	flags = FPRINT | FLUID_SUBMERGE
	event_handler_flags = USE_CANPASS
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE | LONG_GLIDE

	var/datum/mind/mind

	var/datum/abilityHolder/abilityHolder = null
	var/datum/bioHolder/bioHolder = null

	var/targeting_ability = null

	var/last_move_trigger = 0

	var/obj/screen/internals = null
	var/obj/screen/stamina_bar/stamina_bar = null
	var/last_overlay_refresh = 1 // In relation to world time. Used for traitor/nuke ops overlays certain mobs can see.

	var/robot_talk_understand = 0

	var/list/obj/hallucination/hallucinations = null //can probably be on human

	var/last_resist = 0

	//var/obj/screen/zone_sel/zone_sel = null
	var/datum/hud/zone_sel/zone_sel = null

	var/obj/item/device/energy_shield/energy_shield = null

	var/custom_gib_handler = null
	var/obj/decal/cleanable/custom_vomit_type = /obj/decal/cleanable/vomit

	var/list/mob/dead/target_observer/observers = list()

	var/emote_allowed = 1
	var/last_emote_time = 0
	var/last_emote_wait = 0
	var/last_door_knock_time = 0 //anti door knock spam, now seperate from emote anti-spam
	var/computer_id = null
	var/lastattacker = null
	var/lastattacked = null //tell us whether or not to use Combat or Default click delays depending on whether this var was set.
	var/lastattackertime = 0
	var/other_mobs = null
	var/memory = ""
	var/atom/movable/pulling = null
	var/stat = 0.0
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
	var/druggy = 0
	var/sleeping = 0.0
	var/lying = 0.0
	var/lying_old = 0
	var/can_lie = 0
	var/canmove = 1.0
	var/timeofdeath = 0.0
	var/fakeloss = 0
	var/fakedead = 0
	var/cpr_time = 0
	var/health = 100
	var/max_health = 100
	var/bodytemperature = T0C + 37
	var/base_body_temp = T0C + 37
	var/temp_tolerance = 15 // iterations between each temperature state
	var/thermoregulation_mult = 0.025 // how quickly the body's temperature tries to correct itself, higher = faster
	var/innate_temp_resistance = 0.16  // how good the body is at resisting environmental temperature, lower = more resistant
	var/drowsyness = 0.0
	var/dizziness = 0
	var/is_dizzy = 0
	var/is_jittery = 0
	var/jitteriness = 0
	var/charges = 0.0
	var/urine = 0.0
	var/nutrition = 100
	var/losebreath = 0.0
	var/intent = null
	var/shakecamera = 0
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

	var/obj/hud/hud_used = null

	var/list/organs = null
	var/list/grabbed_by = null

	var/datum/traitHolder/traitHolder = null

	var/inertia_dir = 0
	var/footstep = 1

	var/music_lastplayed = "null"

	var/deathhunted = null

	var/job = null

	var/nodamage = 0

	var/spellshield = 0

	var/bomberman = 0

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
	var/now_pushing = null //temp. var used for Bump()
	var/atom/movable/pushing = null //Keep track of something we may be pushing for speed reductions (GC Woes)

	var/movement_delay_modifier = 0 //Always applied.
	var/apply_movement_delay_until = -1 //world.time at which our movement delay modifier expires
	var/restrain_time = 0 //we are restrained ; time at which we will be freed.  (using timeofday)

//Disease stuff
	var/list/resistances = null
	var/list/ailments = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/vamp_beingbitten = 0 // Are we being drained by a vampire?

	var/atom/eye = null
	var/eye_pixel_x = 0
	var/eye_pixel_y = 0
	var/loc_pixel_x = 0
	var/loc_pixel_y = 0

	var/icon/cursor = null

	var/list/datum/hud/huds = null

	var/client/last_client // actually the current client, used by Logout due to BYOND
	var/joined_date = null
	mat_changename = 0
	mat_changedesc = 0

	//Used for combat melee messages (e.g. "Foo punches Bar!")
	var/punchMessage = "punches"
	var/kickMessage = "kicks"

//#ifdef MAP_OVERRIDE_DESTINY
	var/last_cryotron_message = 0 // to stop relaymove spam  :I
//#endif

	var/datum/hud/render_special/render_special

	//var/shamecubed = 0

	// does not allow non-admins to observe them voluntarily
	var/unobservable = 0

	var/mob_flags = 0
	var/click_delay = DEFAULT_CLICK_DELAY
	var/combat_click_delay = COMBAT_CLICK_DELAY

	var/last_cubed = 0

	var/obj/use_movement_controller = null
	var/next_spammable_chem_reaction_time = 0
//start of needed for timestop
#if ASS_JAM
	var/paused = FALSE
	var/pausedbrute = 0
	var/pausedburn = 0
	var/pausedtox = 0
	var/pausedoxy = 0
	var/pausedbrain = 0
#endif
//end of needed for timestop
	var/dir_locked = FALSE

	var/list/cooldowns = null
	var/list/mob_properties

	var/last_move_dir = null

	var/datum/aiHolder/ai = null

	var/last_pulled_time = 0

//obj/item/setTwoHanded calls this if the item is inside a mob to enable the mob to handle UI and hand updates as the item changes to or from 2-hand
/mob/proc/updateTwoHanded(var/obj/item/I, var/twoHanded = 1)
	return 0 //0=couldnt do it(other hand full etc), 1=worked just fine.

// mob procs
/mob/New()
	hallucinations = new
	organs = new
	grabbed_by = new
	resistances = new
	ailments = new
	huds = new
	render_special = new
	traitHolder = new(src)
	cooldowns = new
	if (!src.bioHolder)
		src.bioHolder = new /datum/bioHolder ( src )
	attach_hud(render_special)
	. = ..()
	mobs.Add(src)
	src.lastattacked = src //idk but it fixes bug
	render_target = "\ref[src]"
	mob_properties = list()

/mob/proc/is_spacefaring()
	return 0

/mob/Move(a, b, flag)
	if (src.buckled && src.buckled.anchored)
		return

	//for item specials
	if (src.restrain_time > TIME)
		return

	if (src.buckled)
		var/glide_size = src.glide_size
		src.buckled.Move(a, b, flag)
		src.buckled.glide_size = glide_size // dumb hack
	else
		. = ..()

	src.closeContextActions()

	//robust grab : keep em close
	for (var/obj/item/grab/G in equipped_list(check_for_magtractor = 0))
		if (G.state < GRAB_NECK) continue
		if (get_dist(src,G.affecting) > 1)
			qdel(G)
			continue
		if (G.affecting.buckled) continue
		G.affecting.animate_movement = SYNC_STEPS
		G.affecting.glide_size = src.glide_size
		G.set_affected_loc()
		G.affecting.glide_size = src.glide_size

	if (src.s_active && !(s_active.master in src))
		src.detach_hud(src.s_active)
		src.s_active = null

/mob/disposing()
	for(var/mob/dead/target_observer/TO in observers)
		observers -= TO
		TO.ghostize()

	for(var/mob/m in src) //just in case...
		m.loc = src.loc
		m.ghostize()

	if (ghost && ghost.corpse == src)
		ghost.corpse = null

	if (traitHolder)
		traitHolder.removeAll()
		traitHolder.owner = null
	traitHolder = null

	if (bioHolder)
		bioHolder.dispose()
		bioHolder.owner = null
		bioHolder = null

	for (var/datum/hud/H in huds)
		for (var/obj/screen/hud/S in H.objects)
			if (S:master == src)
				S:master = null
//KYLE: KEELIN, LOOK. Something like this? I dunno, it's so slow too:
		// for (var/obj/screen/S in H.objects)
		// 	if (istype(S, /obj/screen/hud))
		// 		if (S:master == src)
		// 			S:master = null
		// 	else if (istype(S, /obj/screen/statusEffect))
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

	mobs.Remove(src)
	if (ai)
		qdel(ai)
		ai = null
	mind = null
	ckey = null
	client = null
	internals = null
	energy_shield = null
	hallucinations = null
	buckled = null
	handcuffs = null
	l_hand = null
	r_hand = null
	back = null
	internal = null
	s_active = null
	wear_mask = null
	ears = null
	organs = null
	grabbed_by = null
	oldmob = null
	oldmind = null
	ghost = null
	resistances = null
	ailments = null
	cooldowns = null
	lastattacked = null
	lastattacker = null
	..()

/mob/Login()
	// drsingh for cannot read null.address (still popping up though)
	if (!src || !src.client)
		return

	if (!src.client.chatOutput)
		//At least once, some dude has gotten here without a chatOutput datum. Fuck knows how.
		src.client.chatOutput = new /datum/chatOutput(src.client)

	if (!src.client.chatOutput.loaded)
		//Load custom chat
		src.client.chatOutput.start()

	//src.client.screen = null //ov1 - to make sure we don't keep overlays of our old mob. This is here since logout wont work - when logout is called client is already null
	src.client.setup_special_screens()

	src.last_client = src.client
	src.apply_camera(src.client)
	src.update_cursor()
	src.reset_keymap()

	src.client.mouse_pointer_icon = src.cursor

	logTheThing("diary", null, src, "Login: [constructTarget(src,"diary")] from [src.client.address]", "access")
	src.lastKnownIP = src.client.address
	src.computer_id = src.client.computer_id
	if (config.log_access)
		for (var/client/C)
			var/mob/M = C.mob
			if ((!M) || M == src || M.client == null)
				continue
			else if (M && M.client && M.client.address == src.client.address)
				if(!src.client.holder && !M.client.holder)
					logTheThing("admin", src, M, "has same IP address as [constructTarget(M,"admin")]")
					logTheThing("diary", src, M, "has same IP address as [constructTarget(M,"diary")]", "access")
					if (IP_alerts)
						message_admins("<span class='alert'><B>Notice: </B></span><span class='internal'>[key_name(src)] has the same IP address as [key_name(M)]</span>")
			else if (M && M.lastKnownIP && M.lastKnownIP == src.client.address && M.ckey != src.ckey && M.key)
				if(!src.client.holder && !M.client.holder)
					logTheThing("diary", src, M, "has same IP address as [constructTarget(M,"diary")] did ([constructTarget(M,"diary")] is no longer logged in).", "access")
					if (IP_alerts)
						message_admins("<span class='alert'><B>Notice: </B></span><span class='internal'>[key_name(src)] has the same IP address as [key_name(M)] did ([key_name(M)] is no longer logged in).</span>")
			if (M && M.client && M.client.computer_id == src.client.computer_id)
				logTheThing("admin", src, M, "has same computer ID as [constructTarget(M,"admin")]")
				logTheThing("diary", src, M, "has same computer ID as [constructTarget(M,"diary")]", "access")
				message_admins("<span class='alert'><B>Notice: </B></span><span class='internal'>[key_name(src)] has the same </span><span class='alert'><B>computer ID</B><font color='blue'> as [key_name(M)]</span>")
				SPAWN_DBG(0)
					if(M.lastKnownIP == src.client.address)
						alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
			else if (M && M.computer_id && M.computer_id == src.client.computer_id && M.ckey != src.ckey && M.key)
				logTheThing("diary", src, M, "has same computer ID as [constructTarget(M,"diary")] did ([constructTarget(M,"diary")] is no longer logged in).", null, "access")
				logTheThing("admin", M, null, "is no longer logged in.")
				message_admins("<span class='alert'><B>Notice: </B></span><span class='internal'>[key_name(src)] has the same </span><span class='alert'><B>computer ID</B></span><span class='internal'> as [key_name(M)] did ([key_name(M)] is no longer logged in).</span>")
				SPAWN_DBG(0)
					if(M.lastKnownIP == src.client.address)
						alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
/*  don't get me wrong this was awesome but it's leading to false positives now and we stopped caring about that guy
	var/evaderCheck = copytext(lastKnownIP,1, findtext(lastKnownIP, ".", 5))
	if (evaderCheck in list("174.50", "69.245", "71.228", "69.247", "71.203", "98.211", "68.53"))
		SPAWN_DBG(0)
			var/joinstring = "???"
			var/list/response = world.Export("http://www.byond.com/members/[src.ckey]?format=text")
			if (response && response["CONTENT"])
				var/result = html_encode(file2text(response["CONTENT"]))
				if (result)
					var/pos = findtext(result, "joined = ")
					joinstring = copytext(result, pos+14, pos+24)
			message_admins("<font color=red>Possible login by That Ban Evader Jerk: [key_name(src)] with IP \"[lastKnownIP]\" and computer ID \[[src.client.computer_id]]. (Regdate: [joinstring])</font>")
			logTheThing("admin", src, null, "Possible login by Ban Evader Jerk:. IP: [lastKnownIP], Computer ID: \[[src.client.computer_id]], Regdate: [joinstring]")
			logTheThing("diary", src, null, "Possible login by Ban Evader Jerk:. IP: [lastKnownIP], Computer ID: \[[src.client.computer_id]], Regdate: [joinstring]", "admin")
			if (!("[src.ckey]" in IRC_alerted_keys))
				IRC_alerted_keys += "[src.ckey]"
*/

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

	if (src.mind && !src.mind.key)
		src.mind.key = src.key

	if (isobj(src.loc))
		var/obj/O = src.loc
		if (istype(O))
			O.client_login(src)

	src.need_update_item_abilities = 1
	src.antagonist_overlay_refresh(1, 0)

	if (ass_day)
		ass_day_popup(src)

	var/atom/illumplane = client.get_plane( PLANE_LIGHTING )
	if (illumplane) //Wire: Fix for Cannot modify null.alpha
		illumplane.alpha = 255

	return

/mob/Logout()

	//logTheThing("diary", src, null, "logged out", "access") <- sometimes shits itself and has been known to out traitors. Disabling for now.

	tgui_process?.on_logout(src)

	if (src.last_client && !src.key) // lets see if not removing the HUD from disconnecting players helps with the crashes
		for (var/datum/hud/hud in src.huds)
			hud.remove_client(src.last_client)

	..()

	return 1

/mob/proc/deliver_move_trigger(ev)
	return

/mob/proc/onMouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
	return

/mob/proc/onMouseDown(object,location,control,params)
	return

/mob/proc/onMouseUp(object,location,control,params)
	return

/mob/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || src.now_pushing))
		return

	if(istype(AM, /mob/dead/target_observer) || istype(src, /mob/dead/target_observer))
		return
	src.now_pushing = 1

	if (ismob(AM))
		var/mob/tmob = AM
		if (ishuman(tmob))
			src:viral_transmission(AM,"Contact",1)

			if (tmob.bioHolder.HasEffect("fat"))
				if (prob(40) && !src.bioHolder.HasEffect("fat"))
					src.visible_message("<span class='alert'><B>[src] fails to push [tmob] out of the way.</B></span>")
					src.now_pushing = 0
					src.unlock_medal("That's no moon, that's a GOURMAND!", 1)
					deliver_move_trigger("bump")
					tmob.deliver_move_trigger("bump")
					return
			if ((tmob.bioHolder.HasEffect("magnets_pos") && src.bioHolder.HasEffect("magnets_pos")) || (tmob.bioHolder.HasEffect("magnets_neg") && src.bioHolder.HasEffect("magnets_neg")))
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
					// like repels - bimp them away from each other
					src.now_pushing = 0
					var/atom/source = get_turf(tmob)
					src.visible_message("<span class='alert'><B>[src]</B> and <B>[tmob]</B>'s identical magnetic fields repel each other!</span>")
					playsound(source, 'sound/impact_sounds/Energy_Hit_1.ogg', 100, 1)
					tmob.throw_at(get_edge_cheap(source, get_dir(src, tmob)),  20, 3)
					src.throw_at(get_edge_cheap(source, get_dir(tmob, src)),  20, 3)
					return
			if(tmob.reagents && tmob.reagents.get_reagent_amount("flubber") + src.reagents.get_reagent_amount("flubber") > 0)
				if(src.next_spammable_chem_reaction_time > world.time || tmob.next_spammable_chem_reaction_time > world.time)
					src.now_pushing = 0
					return
				src.next_spammable_chem_reaction_time = world.time + 1
				tmob.next_spammable_chem_reaction_time = world.time + 1
				src.now_pushing = 0
				var/atom/source = get_turf(tmob)
				src.visible_message("<span class='alert'><B>[src]</B> and <B>[tmob]</B>'s bounce off each other!</span>")
				playsound(source, 'sound/misc/boing/6.ogg', 100, 1)
				tmob.throw_at(get_edge_cheap(source, get_dir(src, tmob)),  20, 3)
				src.throw_at(get_edge_cheap(source, get_dir(tmob, src)),  20, 3)
				return
			if ((!tmob.now_pushing && !src.now_pushing) && (tmob.bioHolder.HasEffect("magnets_pos") && src.bioHolder.HasEffect("magnets_neg")) || (tmob.bioHolder.HasEffect("magnets_neg") && src.bioHolder.HasEffect("magnets_pos")))
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
					// opposite attracts - fling everything nearby at these dumbasses
					src.now_pushing = 1
					tmob.now_pushing = 1
					src.visible_message("<span class='alert'><B>[src]</B> and <B>[tmob]</B>'s opposite magnetic fields cause a minor magnetic blowout!</span>")
					//src.bioHolder.RemoveEffect("magnets_pos")
					//src.bioHolder.RemoveEffect("magnets_neg")
					var/atom/source = get_turf(tmob)
					new/obj/decal/implo(source)
					var/list/sfloors = list()
					for (var/turf/T in view(5, src))
						if (!T.density)
							sfloors += T
					var/arcs = 8
					while (arcs > 0 && sfloors.len)
						arcs--
						var/turf/Q = pick(sfloors)
						arcFlashTurf(src, Q, 3000)
						sfloors -= Q
					playsound(source, 'sound/effects/suck.ogg', 100, 1)
					for(var/atom/movable/M in view(5, source))
						if(M.anchored || M == source) continue
						if(throw_charge > 0)
							throw_charge--
						else
							break
						M.throw_at(source, 20, 3)
						LAGCHECK(LAG_MED)
					sleep(5 SECONDS)
					src.now_pushing = 0

					if (tmob) //Wire: Fix for: Cannot modify null.now_pushing
						tmob.now_pushing = 0

					return

		if (!issilicon(AM))
			if (tmob.a_intent == "help" && src.a_intent == "help" && tmob.canmove && src.canmove && !tmob.buckled && !src.buckled && !src.throwing && !tmob.throwing) // mutual brohugs all around!
				var/turf/oldloc = src.loc
				var/turf/newloc = tmob.loc

				src.set_loc(newloc)
				tmob.set_loc(oldloc)

				if (istype(tmob.loc, /turf/space))
					logTheThing("combat", src, tmob, "trades places with (Help Intent) [constructTarget(tmob,"combat")], pushing them into space.")
				else if (locate(/obj/hotspot) in tmob.loc)
					logTheThing("combat", src, tmob, "trades places with (Help Intent) [constructTarget(tmob,"combat")], pushing them into a fire.")
				deliver_move_trigger("swap")
				tmob.deliver_move_trigger("swap")
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
			if (victim.buckled && !victim.buckled.anchored)
				step(victim.buckled, t)
			if (istype(victim.loc, /turf/space))
				logTheThing("combat", src, victim, "pushes [constructTarget(victim,"combat")] into space.")
			else if (locate(/obj/hotspot) in victim.loc)
				logTheThing("combat", src, victim, "pushes [constructTarget(victim,"combat")] into a fire.")

		step(src,t)
		AM.OnMove(src)
		//src.OnMove(src) //dont do this here - this Bump() is called from a process_move which sould be calling onmove for us already
		AM.glide_size = src.glide_size

		//// MBC : I did this. this SUCKS. (pulling behavior is only applied in process_move... and step() doesn't trigger process_move nor is there anyway to override the step() behavior
		// so yeah, i copy+pasted this from process_move.
		if (old_loc != src.loc) //causes infinite pull loop without these checks. lol
			var/list/pulling = list()
			if ((get_dist(old_loc, src.pulling) > 1 && get_dist(src, src.pulling) > 1) || src.pulling == src) // fucks sake
				src.pulling = null
				//hud.update_pulling() // FIXME
			else
				pulling += src.pulling
			for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
				pulling += G.affecting
			for (var/atom/movable/A in pulling)
				if (get_dist(src, A) == 0) // if we're moving onto the same tile as what we're pulling, don't pull
					continue
				if (A == src || A == AM)
					continue
				if (!isturf(A.loc) || A.anchored)
					src.now_pushing = null
					continue // whoops
				A.animate_movement = SYNC_STEPS
				A.glide_size = src.glide_size
				step(A, get_dir(A, old_loc))
				A.glide_size = src.glide_size
				A.OnMove(src)
		////////////////////////////////////// end suck
		src.now_pushing = null


// I moved the log entries from human.dm to make them global (Convair880).
/mob/ex_act(severity, last_touched)
	logTheThing("combat", src, null, "is hit by an explosion (Severity: [severity]) at [log_loc(src)]. Explosion source last touched by [last_touched]")
	return

/mob/proc/projCanHit(datum/projectile/P)
	return 1

/mob/proc/attach_hud(datum/hud/hud)
	if (!huds.Find(hud))
		huds += hud
		hud.mobs += src
		if (src.client)
			hud.add_client(src.client)

/mob/proc/detach_hud(datum/hud/hud)
	if (src && src.huds) //Wire note: Fix for runtime error: bad list
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
	if (use_movement_controller && isobj(src.loc) && src.loc:get_movement_controller())
		use_movement_controller = null

	if(istype(src.loc, /obj/machinery/vehicle/) && src.loc != new_loc)
		var/obj/machinery/vehicle/V = src.loc
		V.eject(src)

	. = ..(new_loc)
	src.loc_pixel_x = new_pixel_x
	src.loc_pixel_y = new_pixel_y
	src.update_camera()

	if (isobj(src.loc))
		if(src.loc:get_movement_controller())
			use_movement_controller = src.loc

	walk(src,0) //cancel any walk movements

/mob/proc/update_camera()
	if (src.client)
		apply_camera(src.client)

/mob/proc/apply_camera(client/C)
	if (src.eye)
		C.eye = src.eye
		C.pixel_x = src.eye_pixel_x
		C.pixel_y = src.eye_pixel_y
	else
		C.eye = src
		C.pixel_x = src.loc_pixel_x
		C.pixel_y = src.loc_pixel_y

/mob/proc/can_strip(mob/M, showInv=0)
	if(!showInv && check_target_immunity(src, 0, M))
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

// medals
/mob/proc/revoke_medal(title, debug)
	if (!debug && (!src.client || !src.key))
		return
	else if (IsGuestKey(src.key))
		return
	else if (!config || !config.medal_hub || !config.medal_password)
		return

	return world.ClearMedal(title, key, config.medal_hub, config.medal_password)//revoking medals is probably a good idea to have be synchronous for the guarantee.

/mob/proc/unlock_medal(title, announce, debug)
	if (!debug && (!src.client || !src.key))
		return
	else if (IsGuestKey(src.key))
		return
	else if (!config || !config.medal_hub || !config.medal_password)
		return

	var/key = src.key
	SPAWN_DBG (0)
		var/list/unlocks = list()
		for(var/A in rewardDB)
			var/datum/achievementReward/D = rewardDB[A]
			if (D.required_medal == title)
				unlocks.Add(D)

		var/result = world.SetMedal(title, key, config.medal_hub, config.medal_password)

		if (result == 1)
			if (announce)
				boutput(world, "<span class=\"medal\">[key] earned the [title] medal.</span>")//src.client.stealth ? src.client.fakekey : << seems to be causing trouble
			else if (ismob(src) && src.client)
				boutput(src, "<span class=\"medal\">You earned the [title] medal.</span>")

			if (length(unlocks))
				for(var/datum/achievementReward/B in unlocks)
					boutput(src, "<span class=\"medal\"><FONT FACE=Arial SIZE=+1>You've unlocked a Reward : [B.title]!</FONT></span>")

		else if (isnull(result) && ismob(src) && src.client)
			return
//			boutput(src, "<span class='alert'>You would have earned the [title] medal, but there was an error communicating with the BYOND hub.</span>")

/mob/proc/has_medal(var/medal) //This is not spawned because of return values. Make sure the proc that uses it uses spawn or you lock up everything.
	LAGCHECK(LAG_HIGH)

	if (IsGuestKey(src.key))
		return null
	else if (!config)
		return null
	else if (!config.medal_hub || !config.medal_password)
		return null

	var/result = world.GetMedal(medal, src.key, config.medal_hub, config.medal_password)
	return result

/mob/verb/list_medals()
	set name = "Medals"

	if (IsGuestKey(src.key))
		boutput(src, "<span class='alert'>Sorry, you are a guest and cannot have medals.</span>")
		return
	else if (!config)
		boutput(src, "<span class='alert'>Sorry, medal information is currently not available.</span>")
		return
	else if (!config.medal_hub || !config.medal_password)
		boutput(src, "<span class='alert'>Sorry, this server does not have medals enabled.</span>")
		return

	boutput(src, "Retrieving your medal information...")

	SPAWN_DBG(0)
		var/medals = world.GetMedal("", src.key, config.medal_hub, config.medal_password)

		if (isnull(medals))
			boutput(src, "<span class='alert'>Sorry, could not contact the BYOND hub for your medal information.</span>")
			return

		if (!medals)
			boutput(src, "<b>You don't have any medals.</b>")
			return

		medals = params2list(medals)
		medals = sortList(medals)

		boutput(src, "<b>Medals:</b>")
		for (var/medal in medals)
			boutput(src, "&emsp;[medal]")
		boutput(src, "<b>You have [length(medals)] medal\s.</b>")

/mob/verb/setdnr()
	set name = "Set DNR"
	set desc = "Set yourself as Do Not Resuscitate."
	var/confirm = alert("Set yourself as Do Not Resuscitate (WARNING: This is one-use only and will prevent you from being revived in any manner)", "Set Do Not Resuscitate", "Yes", "Cancel")
	if (confirm == "Cancel")
		return
	if (confirm == "Yes")
		if (src.mind)
			src.verbs -= list(/mob/verb/setdnr)
			src.mind.dnr = 1
			boutput(src, "<span class='alert'>DNR status set!</span>")
		else
			src << alert("There was an error setting this status. Perhaps you are a ghost?")
	return

/mob/proc/unequip_all(var/delete_stuff=0)
	var/list/obj/item/to_unequip = src.get_unequippable()
	if(to_unequip && to_unequip.len)
		for (var/obj/item/W in to_unequip)
			src.remove_item(W)
			if (W)
				W.set_loc(src.loc)
				W.dropped(src)
				W.layer = initial(W.layer)
			if(delete_stuff)
				qdel(W)

/mob/proc/unequip_random(var/delete_stuff=0)
	var/list/obj/item/to_unequip = get_unequippable()
	if(to_unequip && to_unequip.len)
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
	var/obj/ecto = new/obj/item/reagent_containers/food/snacks/ectoplasm
	ecto.loc = src.loc

/mob/proc/get_unequippable()
	return

/mob/living/get_unequippable()
	var/list/obj/item/LI = list()

	for (var/obj/item/W in src)
		if (istype(W, /obj/item/parts) && W:holder == src)
			continue

		if (istype(W, /obj/item/reagent_containers/food/snacks/bite))
			continue
		LI += W

	.= LI

/mob/living/carbon/human/get_unequippable()
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

		if (istype(W, /obj/item/reagent_containers/food/snacks/bite))
			continue

		LI += W
	.= LI

/mob/proc/findname(msg)
	for(var/mob/M in mobs)
		if (M.real_name == text("[]", msg))
			.= M
	.= 0

/mob/proc/movement_delay(var/atom/move_target = 0)
	.= 2 + movement_delay_modifier
	. *= max(src?.pushing.p_class, 1)

/mob/proc/Life(datum/controller/process/mobs/parent)
	return

// for mobs without organs
/mob/proc/TakeDamage(zone, brute, burn, tox, damage_type)
	hit_twitch(src)
#if ASS_JAM//pausing damage for timestop
	if(src.paused)
		src.pausedburn = max(0, src.pausedburn + burn)
		src.pausedbrute = max(0, src.pausedbrute + brute)
		return
#endif
	src.health -= max(0, brute)
	if (!is_heat_resistant())
		src.health -= max(0, burn)

/mob/proc/TakeDamageAccountArmor(zone, brute, burn, tox, damage_type)
	TakeDamage(zone, brute - get_melee_protection(zone,damage_type), burn - get_melee_protection(zone,damage_type))

/mob/proc/HealDamage(zone, brute, burn, tox)
	health += max(0, brute)
	health += max(0, burn)
	health += max(0, tox)
	health = min(max_health, health)

/mob/proc/set_pulling(atom/movable/A)
	if(A == src)
		return

	pulling = A

	//robust grab : a dirty DIRTY trick on mbc's part. When I am being chokeholded by someone, redirect pulls to the captor.
	//this is so much simpler than pulling the victim and invoking movment on the captor through that chain of events.
	if (ishuman(pulling))
		var/mob/living/carbon/human/H = pulling
		if (H.grabbed_by.len)
			for (var/obj/item/grab/G in src.grabbed_by)
				if (G.state < GRAB_NECK) continue
				pulling = G.assailant

	pull_particle(src,pulling)

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
	updatehealth()
	return

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

/mob/proc/death(gibbed)
	#ifdef COMSIG_MOB_DEATH
	SEND_SIGNAL(src, COMSIG_MOB_DEATH)
	#endif
	//Traitor's dead! Oh no!
	if (src.mind && src.mind.special_role && !istype(get_area(src),/area/afterlife))
		message_admins("<span class='alert'>Antagonist [key_name(src)] ([src.mind.special_role]) died at [log_loc(src)].</span>")
	//if(src.mind && !gibbed)
	//	src.mind.death_icon = getFlatIcon(src,SOUTH) crew photo stuff
	if(src.mind && (src.mind.damned || src.mind.karma < -200))
		src.damn()
		return
	if (src.suicide_alert)
		message_attack("[key_name(src)] died shortly after spawning.")
		src.suicide_alert = 0


	if(src.ckey)
		respawn_controller.subscribeNewRespawnee(src.ckey)

/mob/proc/restrained()
	if (src.hasStatus("handcuffed"))
		return 1

/mob/proc/drop_from_slot(obj/item/item, turf/T)
	if (!item)
		return
	if (!(item in src.contents))
		return
	if (item.cant_drop)
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
	T.Entered(item)
	return

/mob/proc/drop_item(obj/item/W)
	.= 0
	if (!W) //only pass W if you KNOW that the mob has it
		W = src.equipped()
	if (istype(W))
		var/obj/item/magtractor/origW
		if (W.useInnerItem && W.contents.len > 0)
			if (istype(W, /obj/item/magtractor))
				origW = W
			var/obj/item/held = W.holding
			if (!held)
				held = pick(W.contents)
			if (held && !istype(held, /obj/ability_button))
				W = held
		if (!istype(W) || W.cant_drop) return

		if (W && !W.qdeled)
			if (istype(src.loc, /obj/vehicle))
				var/obj/vehicle/V = src.loc
				if (V.throw_dropped_items_overboard == 1)
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
			actions.stopId("magpickerhold", src)

//throw the dropped item
/mob/proc/drop_item_throw()
	var/obj/item/W = src.equipped()
	if (src.drop_item())
		var/turf/T = get_edge_target_turf(src, pick(alldirs))
		W.throw_at(T,rand(0,5),1)

/mob/proc/drop_item_throw_dir(dir)
	var/obj/item/W = src.equipped()
	if (src.drop_item())
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

/mob/proc/equipped_list(check_for_magtractor = 1)
	. = list()

	if (src.r_hand)
		. += src.r_hand
		if (src.r_hand.chokehold)
			. += src.r_hand.chokehold

	if (src.l_hand)
		. += src.l_hand
		if (src.l_hand.chokehold)
			. += src.l_hand.chokehold

	//handle mag tracktor
	if (check_for_magtractor)
		for (var/I in .)
			if (istype(I,/obj/item/magtractor))
				var/obj/item/magtractor/M = I
				if (M.holding)
					.+= M.holding
				.-= I

/mob/living/critter/equipped_list(check_for_magtractor = 1)
	.= ..()
	if (hands)
		for(var/datum/handHolder/H in hands)
			if (H.item)
				.+= H.item

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
				.+= M.holding
				.-= I

/mob/proc/swap_hand()
	return

/mob/proc/u_equip(obj/item/W)

// I think this bit is handled by each method of dropping it, and it prevents dropping items in your hands and other procs using u_equip so I'll get rid of it for now.
//	if (hasvar(W,"cant_self_remove"))
//		if (W:cant_self_remove) return

	if (W == src.r_hand)
		src.r_hand = null
	if (W == src.l_hand)
		src.l_hand = null

	if (W == src.handcuffs)
		src.handcuffs = null
	else if (W == src.back)
		src.back = null
	else if (W == src.wear_mask)
		src.wear_mask = null

	if (src.client)
		src.client.screen -= W

	set_clothing_icon_dirty()

	W.dropped(src)

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]<br>", t)
		//Foreach goto(26)
	src.Browse(master)
	return
*/

/mob/verb/memory()
	set name = "Notes"
	// drsingh for cannot execute null.show_memory
	if (isnull(mind))
		return

	mind.show_memory(src)

/mob/verb/add_memory(msg as message)
	set name = "Add Note"

	if (mind.last_memory_time + 10 <= world.time)
		mind.last_memory_time = world.time

		msg = copytext(msg, 1, MAX_MESSAGE_LEN)
		msg = sanitize(msg)

		mind.store_memory(msg)

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
	if (isnull(src.mind.miranda))
		src.say_verb("You have the right to remain silent. Anything you say can and will be used against you in a NanoTrasen court of Space Law. You have the right to a rent-an-attorney. If you cannot afford one, a monkey in a suit and funny hat will be appointed to you.")
		return
	src.say_verb(src.mind.miranda)

/mob/proc/add_miranda()
	set name = "Set Miranda Rights"
	if (isnull(src.mind))
		return
	if (src.mind.last_memory_time + 10 <= world.time) // leaving it using this var cause vOv
		src.mind.last_memory_time = world.time // why not?

		if (isnull(src.mind.miranda))
			src.mind.set_miranda("You have the right to remain silent. Anything you say can and will be used against you in a NanoTrasen court of Space Law. You have the right to a rent-an-attorney. If you cannot afford one, a monkey in a suit and funny hat will be appointed to you.")

		src.mind.show_miranda(src)

		var/new_rights = input(usr, "Change what you will say with the Say Miranda Rights verb.", "Set Miranda Rights", src.mind.miranda) as null|text
		if (!new_rights || new_rights == src.mind.miranda)
			src.show_text("Miranda rights not changed.", "red")
			return

		new_rights = copytext(new_rights, 1, MAX_MESSAGE_LEN)
		new_rights = sanitize(strip_html(new_rights))

		src.mind.set_miranda(new_rights)

		logTheThing("telepathy", src, null, "has set their miranda rights quote to: [src.mind.miranda]")
		src.show_text("Miranda rights set to \"[src.mind.miranda]\"", "blue")

/mob/verb/abandon_mob()
	set name = "Respawn"

	if (!( abandon_allowed ))
		return

	if(!isobserver(usr) || !(ticker))
		boutput(usr, "<span class='notice'><B>You must be a ghost to use this!</B></span>")
		return

	logTheThing("diary", usr, null, "used abandon mob.", "game")

	var/mob/new_player/M = new()

	M.key = usr.client.key
	M.Login()
	return

/mob/verb/show_preferences()
	set name = "Character Setup"
	set desc = "Displays the window to edit your character preferences"
	set category = "Commands"

	client.preferences.ShowChoices(src)

/mob/verb/cmd_rules()
	set name = "Rules"
	// src.Browse(rules, "window=rules;size=480x320")
	src << browse(rules, "window=rules;size=480x320")

/mob/verb/succumb()
	set hidden = 1
/*
//prevent a
 if the person is infected with the headspider disease.
	for (var/datum/ailment/V in src.ailments)
		if (istype(V, /datum/ailment/parasite/headspider) || istype(V, /datum/ailment/parasite/alien_embryo))
			boutput(src, "You can't muster the willpower. Something is preventing you from doing it.")
			return
*/
//or if they are being drained of blood
	if (src.vamp_beingbitten)
		boutput(src, "You can't muster the willpower. Something is preventing you from doing it.")
		return

	if (src.health < 0)
		boutput(src, "<span class='notice'>You have given up life and succumbed to death.</span>")
		src.death()
		if (!src.suiciding)
			src.unlock_medal("Yield", 1)
		logTheThing("combat", src, null, "succumbs")

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	src.set_eye(null)
	src.remove_dialogs()
	if (!isliving(src))
		src.sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF | SEE_BLACKNESS

/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (air_group || (height==0)) return 1

	if (istype(mover, /obj/projectile))
		return !projCanHit(mover:proj_data)


	if (ismob(mover))
		var/mob/moving_mob = mover
		if ((src.other_mobs && moving_mob.other_mobs))
			return 1
		return (!mover.density || !src.density || src.lying)
	else
		return (!mover.density || !src.density || src.lying)

/mob/proc/update_inhands()

/mob/proc/put_in_hand(obj/item/I, hand)
	return 0

/mob/proc/get_damage()
	return src.health

/mob/bullet_act(var/obj/projectile/P)
	var/damage = 0
	damage = round((P.power*P.proj_data.ks_ratio), 1.0)
	var/stun = 0
	stun = round((P.power*(1.0-P.proj_data.ks_ratio)), 1.0)

	if(src.material) src.material.triggerOnBullet(src, src, P)

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
				src.changeStatus("paralysis", stun*15)
			else if (prob(90))
				src.changeStatus("stunned", stun*15)
			else
				src.changeStatus("weakened", (stun/2)*15)
			src.set_clothing_icon_dirty()
		if (D_BURNING)
			TakeDamage("All", 0, damage)
		if (D_RADIOACTIVE)
			src.changeStatus("radiation", (damage)*10)
			src.stuttering += stun
			src.drowsyness += stun
		if (D_TOXIC)
			src.take_toxin_damage(damage)
	if (!P || !P.proj_data || !P.proj_data.silentshot)
		src.visible_message("<span class='alert'>[src] is hit by the [P]!</span>")

	actions.interrupt(src, INTERRUPT_ATTACKED)
	return

//this is like, if I'm in a pod and the pod takes a hit. Should be electric shots and energy stuff
//maybe later create a new bullet or pass an existing bullet into bullet_act() so we dont have this weird proc here at all. Probably slower though
/mob/proc/bullet_act_indirect(var/obj/projectile/P)
	var/stun = 0
	stun = round((P.power*(1.0-P.proj_data.ks_ratio)), 1.0)

	stun *= 0.2 //mbc magic number stun multiplier wow

	if(src.material) src.material.triggerOnBullet(src, src, P)

	switch(P.proj_data.damage_type)
		if (D_ENERGY)
			if (prob(stun))
				src.changeStatus("paralysis", stun*15)
			else if (prob(90))
				src.changeStatus("stunned", stun*15)
			else
				src.changeStatus("weakened", (stun/2)*15)
			src.set_clothing_icon_dirty()
			src.show_text("<span class='alert'>You are shocked by the impact of [P]!</span>")
		if (D_RADIOACTIVE)
			src.stuttering += stun
			src.drowsyness += stun/10
			src.show_text("<span class='alert'>You feel a wave of sickness as [P] impacts [src.loc]!</span>")


	actions.interrupt(src, INTERRUPT_ATTACKED)
	return

/mob/proc/can_use_hands()
	if (src.hasStatus("handcuffed"))
		return 0
	if (src.buckled && istype(src.buckled, /obj/stool/bed)) // buckling does not restrict hands
		return 0
	return 1

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/updatehealth()
	if (src.nodamage == 0)
		src.health = max_health - src.get_oxygen_deprivation() - src.get_toxin_damage() - src.get_burn_damage() - src.get_brute_damage()
	else
		src.health = max_health
		setalive(src)

/mob/proc/adjustBodyTemp(actual, desired, incrementboost, divisor)
	var/temperature = actual
	var/difference = abs(actual-desired)   // get difference
	var/increments = difference * divisor  //find how many increments apart they are
	var/change = increments*incrementboost // Get the amount to change by (x per increment)
	//change = change * 0.10

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

	// I removed the sending mob to observer_start part because ghostize() takes care of it

	src.death()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		src.ghostize()

	qdel(src)

/mob/proc/gib(give_medal, include_ejectables)
	if (istype(src, /mob/dead/observer))
		var/list/virus = src.ailments
		gibs(src.loc, virus)
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing("combat", src, null, "is gibbed at [log_loc(src)].")
	src.death(1)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101

	var/bdna = null // For forensics (Convair880).
	var/btype = null

	if (ishuman(src))
		if (src.bioHolder)
			bdna = src.bioHolder.Uid // Ditto (Convair880).
			btype = src.bioHolder.bloodType

		animation = new(src.loc)
		animation.master = src
		flick("gibbed", animation)

	if (src.client) // I feel like every player should be ghosted when they get gibbed
		var/mob/dead/observer/newmob = ghostize()
		newmob.corpse = null
		if (!isnull(newmob) && give_medal)
			newmob.unlock_medal("Gore Fest", 1)

	var/list/viral_list = list()
	for (var/datum/ailment_data/AD in src.ailments)
		viral_list += AD
	var/list/ejectables = list()
	if (!custom_gib_handler)
		if (iscarbon(src))
			ejectables = list_ejectables()
			if (bdna && btype)
				. = gibs(src.loc, viral_list, ejectables, bdna, btype) // For forensics (Convair880).
			else
				. = gibs(src.loc, viral_list, ejectables)
		else
			. = robogibs(src.loc, viral_list)
	else
		ejectables = list_ejectables()
		. = call(custom_gib_handler)(src.loc, viral_list, ejectables, bdna, btype)

	for(var/obj/item/implant/I in src) qdel(I)

	if (animation)
		animation.delaydispose()
	qdel(src)
	if( include_ejectables )
		. += ejectables
	//return .

/mob/proc/elecgib()
	if (isobserver(src)) return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing("combat", src, null, "is electric-gibbed at [log_loc(src)].")
	src.death(1)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101



	if (ishuman(src))
		animation = new(src.loc)
		animation.master = src
		flick("elecgibbed", animation)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob.corpse = null

	if (!iscarbon(src))
		var/list/virus = src.ailments
		robogibs(src.loc, virus)

	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/firegib()
	if (isobserver(src)) return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing("combat", src, null, "is fire-gibbed at [log_loc(src)].")
	src.death(1)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101

	if (ishuman(src))
		animation = new(src.loc)
		animation.master = src
		flick("firegibbed", animation)
		for (var/obj/item/W in src)
			if (istype(W, /obj/item/clothing))
				var/obj/item/clothing/C = W
				C.stains += "singed"
				C.UpdateName()
		unequip_all()

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob.corpse = null

	if (!iscarbon(src))
		var/list/virus = src.ailments
		robogibs(src.loc, virus)

	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/partygib(give_medal)
	if (isobserver(src))
		var/list/virus = src.ailments
		partygibs(src.loc, virus)
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing("combat", src, null, "is party-gibbed at [log_loc(src)].")
	src.death(1)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101

	var/bdna = null // For forensics (Convair880).
	var/btype = null

	if (ishuman(src))
		if (src.bioHolder)
			bdna = src.bioHolder.Uid // Ditto (Convair880).
			btype = src.bioHolder.bloodType

		animation = new(src.loc)
		animation.master = src
		flick("gibbed", animation)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob.corpse = null

	var/list/virus = src.ailments

	if (bdna && btype)
		partygibs(src.loc, virus, bdna, btype) // For forensics (Convair880).
	else
		partygibs(src.loc, virus)

	playsound(src.loc, "sound/musical_instruments/Bikehorn_1.ogg", 100, 1)

	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/owlgib(give_medal, control_chance = 1)
	if (isobserver(src))
		var/list/virus = src.ailments
		gibs(src.loc, virus)
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	var/transfer_mind_to_owl = prob(control_chance)
	logTheThing("combat", src, null, "is owl-gibbed at [log_loc(src)].")
	src.death(1)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101

	var/bdna = null // For forensics (Convair880).
	var/btype = null

	if (ishuman(src))
		if (src.bioHolder)
			bdna = src.bioHolder.Uid // Ditto (Convair880).
			btype = src.bioHolder.bloodType

		animation = new(src.loc)
		animation.master = src
		flick("owlgibbed", animation)
		if (transfer_mind_to_owl)
			src.make_critter(/mob/living/critter/small_animal/bird/owl, src.loc)
		else
			var/obj/critter/owl/O = new /obj/critter/owl(src.loc)
			O.name = pick("Hooty Mc[src.real_name]", "Professor [src.real_name]", "Screechin' [src.real_name]")

	if (!transfer_mind_to_owl && (src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob.corpse = null

	var/list/virus = src.ailments

	if (bdna && btype)
		gibs(src.loc, virus, null, bdna, btype) // For forensics (Convair880).
	else
		gibs(src.loc, virus)

	playsound(src.loc, "sound/voice/animal/hoot.ogg", 100, 1)

	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/vaporize(give_medal, forbid_abberation)
	if (isobserver(src))
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	src.death(1)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	logTheThing("combat", src, null, "is vaporized at [log_loc(src)].")

	if (ishuman(src))
		animation = new(src.loc)
		animation.master = src
		flick("disintegrated", animation)

		if (prob(20))
			make_cleanable(/obj/decal/cleanable/ash, src.loc)

		if (!forbid_abberation && prob(50))
			new /obj/critter/aberration(src.loc)

	else
		gibs(src.loc)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob.corpse = null

	elecflash(src.loc,exclude_center = 0)

	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/implode(give_medal)
	if (isobserver(src)) return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing("combat", src, null, "imploded at [log_loc(src)].")
	src.death(1)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101

	if (ishuman(src))
		animation = new(src.loc)
		animation.master = src
		flick("implode", animation)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob.corpse = null

	playsound(src.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 100, 1)

	if (animation)
		animation.delaydispose()
	qdel(src)

/mob/proc/cluwnegib(var/duration = 30, var/anticheat = 0)
	if(isobserver(src)) return
	SPAWN_DBG(0) //multicluwne
		duration = clamp(duration, 10, 100)

	#ifdef DATALOGGER
		game_stats.Increment("violence")
	#endif
		logTheThing("combat", src, null, "is taken by the floor cluwne at [log_loc(src)].")
		src.transforming = 1
		src.canmove = 0
		src.anchored = 1
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
		playsound(the_turf, 'sound/ambience/industrial/AncientPowerPlant_Drone3.ogg', 70, 1)

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
		SPAWN_DBG(duration+5)
			src.death(1)
			var/mob/dead/observer/newmob = ghostize()
			newmob.corpse = null

			qdel(floorcluwne)
			qdel(src)

/mob/proc/buttgib(give_medal)
	if (isobserver(src)) return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif
	logTheThing("combat", src, null, "is butt-gibbed at [log_loc(src)].")
	src.death(1)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101

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
		flick("gibbed", animation)

	if ((src.mind || src.client) && !istype(src, /mob/living/carbon/human/npc))
		var/mob/dead/observer/newmob = ghostize()
		newmob.corpse = null

	var/list/virus = src.ailments
	var/list/ejectables = list_ejectables()

	for(var/i = 0, i < 16, i++)
		if(organHolder)
			ejectables.Add(new /obj/item/clothing/head/butt(src.loc, organHolder))
		else
			ejectables.Add(new /obj/item/clothing/head/butt/synth)

	if (bdna && btype)
		gibs(src.loc, virus, ejectables, bdna, btype)
	else
		gibs(src.loc, virus, ejectables)

	playsound(src.loc, "sound/voice/farts/superfart.ogg", 100, 1)
	var/turf/src_turf = get_turf(src)
	if(src_turf)
		src_turf.fluid_react_single("toxic_fart",50,airborne = 1)
		for(var/mob/living/L in range(src_turf, 6))
			shake_camera(L, 10, 5)

	if (animation)
		animation.delaydispose()
	qdel(src)

// Man, there's a lot of possible inventory spaces to store crap. This should get everything under normal circumstances.
// Well, it's hard to account for every possible matryoshka scenario (Convair880).
/mob/proc/get_all_items_on_mob()
	if (!src || !ismob(src))
		return 0

	var/list/L = list()
	L += src.contents // Item slots.

	for (var/obj/item/storage/S in src.contents) // Backpack, belt, briefcases etc.
		var/list/T1 = S.get_all_contents()
		for (var/obj/O1 in T1)
			if (!L.Find(O1)) L.Add(O1)

	for (var/obj/item/gift/G in src.contents)
		if (!L.Find(G.gift)) L += G.gift
		if (istype(G.gift, /obj/item/storage))
			var/obj/item/storage/S2 = G.gift
			var/list/T2 = S2.get_all_contents()
			for (var/obj/O2 in T2)
				if (!L.Find(O2)) L.Add(O2)

	for (var/obj/item/storage/backpack/BP in src.contents) // Backpack boxes etc.
		for (var/obj/item/storage/S3 in BP.contents)
			var/list/T3 = S3.get_all_contents()
			for (var/obj/O3 in T3)
				if (!L.Find(O3)) L.Add(O3)

		for (var/obj/item/gift/G2 in BP.contents)
			if (!L.Find(G2.gift)) L += G2.gift
			if (istype(G2.gift, /obj/item/storage))
				var/obj/item/storage/S4 = G2.gift
				var/list/T4 = S4.get_all_contents()
				for (var/obj/O4 in T4)
					if (!L.Find(O4)) L.Add(O4)

	for (var/obj/item/storage/belt/BL in src.contents) // Stealth storage in belts etc.
		for (var/obj/item/storage/S5 in BL.contents)
			var/list/T5 = S5.get_all_contents()
			for (var/obj/O5 in T5)
				if (!L.Find(O5)) L.Add(O5)

		for (var/obj/item/gift/G3 in BL.contents)
			if (!L.Find(G3.gift)) L += G3.gift
			if (istype(G3.gift, /obj/item/storage))
				var/obj/item/storage/S6 = G3.gift
				var/list/T6 = S6.get_all_contents()
				for (var/obj/O6 in T6)
					if (!L.Find(O6)) L.Add(O6)

	for (var/obj/item/storage/box/syndibox/SB in L) // For those "belt-in-stealth storage-in-backpack" situations.
		for (var/obj/item/storage/S7 in SB.contents)
			var/list/T7 = S7.get_all_contents()
			for (var/obj/O7 in T7)
				if (!L.Find(O7)) L.Add(O7)

		for (var/obj/item/gift/G4 in SB.contents)
			if (!L.Find(G4.gift)) L += G4.gift
			if (istype(G4.gift, /obj/item/storage))
				var/obj/item/storage/S8 = G4.gift
				var/list/T8 = S8.get_all_contents()
				for (var/obj/O8 in T8)
					if (!L.Find(O8)) L.Add(O8)

	return L

// Made these three procs use get_all_items_on_mob(). "Steal X" objective should work more reliably as a result (Convair880).
/mob/proc/check_contents_for(A, var/accept_subtypes = 0)
	if (!src || !ismob(src) || !A)
		return 0

	var/list/L = src.get_all_items_on_mob()
	if (L && L.len)
		for (var/obj/B in L)
			if (B.type == A || (accept_subtypes && istype(B, A)))
				return 1
	return 0

/mob/proc/check_contents_for_num(A, X, var/accept_subtypes = 0)
	if (!src || !ismob(src) || !A)
		return 0

	var/tally = 0
	var/list/L = src.get_all_items_on_mob()
	if (L && L.len)
		for (var/obj/B in L)
			if (B.type == A || (accept_subtypes && istype(B, A)))
				tally++

	if (tally >= X)
		return 1

	return 0

#define REFRESH "* Refresh list"
/mob/proc/print_contents(var/mob/output_target)
	if (!src || !ismob(src) || !output_target || !ismob(output_target))
		return

	var/list/L = src.get_all_items_on_mob()
	if (L && L.len)
		var/list/OL = list() // Sorted output list. Could definitely be improved, but is functional enough.
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

		OL = sortList(OL)

		selection:
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
			goto selection

		if (output_target.client)
			output_target.client.view_fingerprints(OL[IP])
			goto selection

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
		SPAWN_DBG(0)
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
	if (!ishuman(src)) // for the moment, only humans get dizzy
		return

	jitteriness = min(500, jitteriness + amount)	// store what will be new value
													// clamped to max 500
	if (jitteriness > 100 && !is_jittery)
		SPAWN_DBG(0)
			jittery_process()


// jittery process - shakes the mob's pixel offset randomly
// will terminate automatically when dizziness gets <100
// jitteriness decrements automatically in the mob's Life() proc.
/mob/proc/jittery_process()
	var/old_x = pixel_x
	var/old_y = pixel_y
	is_jittery = 1
	while(jitteriness > 100)
//		var/amplitude = jitteriness*(sin(jitteriness * 0.044 * world.time) + 1) / 70
//		pixel_x = amplitude * sin(0.008 * jitteriness * world.time)
//		pixel_y = amplitude * cos(0.008 * jitteriness * world.time)

		var/amplitude = min(4, jitteriness / 100)
		pixel_x = old_x + rand(-amplitude, amplitude)
		pixel_y = old_y + rand(-amplitude/3, amplitude/3)

		sleep(0.1 SECONDS)
	//endwhile - reset the pixel offsets to zero
	is_jittery = 0
	pixel_x = old_x
	pixel_y = old_y

/mob/onVarChanged(variable, oldval, newval)
	update_clothing()

/mob/proc/throw_impacted(var/atom/hit) //Called when mob hits something after being thrown.

	if (throw_traveled <= 410)
		if (!((src.throwing & THROW_CHAIRFLIP) && ismob(hit)))
			random_brute_damage(src, min((6 + (throw_traveled / 5)), (src.health - 5) < 0 ? src.health : (src.health - 5)))
			if (!src.hasStatus("weakened"))
				src.changeStatus("weakened", 2 SECONDS)
				src.force_laydown_standup()
	else
		if (src.gib_flag) return
		src.gib_flag = 1
		src.gib()

	return

/mob/proc/full_heal()
	src.HealDamage("All", 100000, 100000)
	src.drowsyness = 0
	src.stuttering = 0
	src.losebreath = 0
	src.delStatus("paralysis")
	src.delStatus("stunned")
	src.delStatus("weakened")
	src.delStatus("slowed")
	src.delStatus("burning")
	src.delStatus("radiation")
	src.change_eye_blurry(-INFINITY)
	src.take_eye_damage(-INFINITY)
	src.take_eye_damage(-INFINITY, 1)
	src.take_ear_damage(-INFINITY)
	src.take_ear_damage(-INFINITY, 1)
	src.take_brain_damage(-INFINITY)
	src.health = src.max_health
	src.buckled = null
	if (src.hasStatus("handcuffed"))
		src.handcuffs.destroy_handcuffs(src)
	src.bodytemperature = src.base_body_temp
	if (src.stat > 1)
		setalive(src)

/mob/proc/infected(var/datum/pathogen/P)
	return

/mob/proc/remission(var/datum/pathogen/P)
	return

/mob/proc/immunity(var/datum/pathogen/P)
	return

/mob/proc/cured(var/datum/pathogen/P)
	return

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
					SPAWN_DBG(10 SECONDS)
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

	src.eye_blurry = max(0, min(src.eye_blurry + amount, upper_cap))
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
				boutput(src, "<span class='alert'>Your ears ring a bit!</span>")
				eardeaf += rand(2, 3)

			if (15 to 24)
				boutput(src, "<span class='alert'>Your ears are really starting to hurt!</span>")
				eardeaf += src.ear_damage * 0.5

			if (25 to INFINITY)
				boutput(src, "<span class='alert'><b>Your ears ring very badly!</b></span>")

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
			boutput(src, "<span class='notice'>The ringing in your ears subsides enough to let you hear again.</span>")
		else if (eardeaf > 0 && deaf_bypass == 0 && suppress_message == 0)
			boutput(src, "<span class='alert'>The ringing overpowers your ability to hear momentarily.</span>")

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
			newname = input(src, "[what_you_are ? "You are \a [what_you_are]. " : null]Would you like to change your name to something else?", "Name Change", default_name ? default_name : src.real_name) as null|text
		if (!newname)
			return
		else
			newname = strip_html(newname, MOB_NAME_MAX_LENGTH, 1)
			if (!length(newname) || copytext(newname,1,2) == " ")
				src.show_text("That name was too short after removing bad characters from it. Please choose a different name.", "red")
				continue
			else
				if (force_instead || alert(src, "Use the name [newname]?", newname, "Yes", "No") == "Yes")
					var/datum/data/record/B = FindBankAccountByName(src.real_name)
					if (B && B.fields["name"])
						B.fields["name"] = newname
					for (var/obj/item/card/id/ID in src.contents)
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
					src.name = newname
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
		src.name = src.real_name

/mob/proc/set_mutantrace(var/mutantrace_type)
	return

/proc/random_name(var/gen = MALE)
	var/return_name
	if (gen == MALE)
		return_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
	else if (gen == FEMALE)
		return_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
	else
		return_name = capitalize(pick(first_names_male + first_names_female) + " " + capitalize(pick(last_names)))
	return return_name

/mob/OnMove(source = null)
	..()
	if(client && client.player && client.player.shamecubed)
		loc = client.player.shamecubed
		return

	if (waddle_walking)
		makeWaddle(src)

	last_move_dir = move_dir

	if (source && source != src) //we were moved by something that wasnt us
		last_pulled_time = world.time

/mob/proc/on_centcom()
	var mob_loc = src.loc
	if (isobj(src.loc))
		var/obj/O = src.loc
		mob_loc = O.loc

	var/turf/location = get_turf(mob_loc)
	if (!location)
		return 0

	var/area/check_area = location.loc
	if (istype(check_area, map_settings.escape_centcom))
		return 1

	return 0

/mob/proc/is_hulk()
	if (src.bioHolder && src.bioHolder.HasEffect("hulk"))
		return 1
	return 0

/mob/proc/update_equipped_modifiers()

// alright this is copy pasted a million times across the code, time for SOME unification - cirr
// no text description though, because it's all different everywhere
/mob/proc/vomit(var/nutrition=0, var/specialType=null)
	playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
	if(specialType)
		if(!locate(specialType) in src.loc)
			new specialType(src.loc)
	else
		if(!locate(custom_vomit_type) in src.loc)
			make_cleanable(custom_vomit_type,src.loc)

	src.nutrition -= nutrition

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
			boutput(src, "<span class='alert'>You can never escape.</span>")
		else // uhhhhh how did you get here. You didnt sin enough! Go back and try harder!
			return

	var/turf/reappear_turf = pick(get_area_turfs(/area/afterlife/hell/hellspawn))
	////////////////Set up the new body./////////////////

	var/mob/living/carbon/human/newbody = new()
	newbody.set_loc(reappear_turf)
	newbody.equip_new_if_possible(/obj/item/clothing/under/misc, newbody.slot_w_uniform)

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

	////////////Now play the degibbing animation and move them to the turf.////////////////

	var/atom/movable/overlay/animation = new(reappear_turf)
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	animation.icon_state = "ungibbed"
	src = null //Detach this, what if we get deleted before the animation ends??
	SPAWN_DBG(0.7 SECONDS) //Length of animation.
		newbody.set_loc(animation.loc)
		qdel(animation)
		newbody.anchored = 1 // Stop running into the lava every half second jeez!
		SPAWN_DBG(4 SECONDS)
			reset_anchored(newbody)
	return

/mob/proc/damn()
	if(!src.mind)
		return
	src.mind.damned = 1
	src.nodamage = 1
	var/duration = 30

	SPAWN_DBG(0) //multisatan
		logTheThing("combat", src, null, "is damned to hell from [log_loc(src)].")
		src.transforming = 1
		src.canmove = 0
		src.anchored = 1
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
		playsound(the_turf, 'sound/effects/damnation.ogg', 50, 1)

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
		SPAWN_DBG(duration+5)
			src.hell_respawn()
			qdel(satan)
	//END
	return

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
	if(allow_overflow)
		amount = max(1, min(src.mind.soul, amount)) // can't sell less than 1
	if (isdiabolical(src))
		boutput(src, "<span class='notice'>You collect souls, why would you want to sell yours?</span>")
		return 0
	if(istype(src, /mob/living/carbon/human) && src:unkillable) //shield of souls interaction
		boutput(src,"<span class='alert'><b>Your soul is shielded and cannot be sold!</b></span>")
		return 0
	if(amount > src.mind.soul)
		boutput(src, "<span class='alert'><b>You don't have enough of a soul to sell!</b></span>")
		return 0
	boutput(src, "<span class='alert'><b>You feel a portion of your soul rip away from your body!</b></span>")
	if(reduce_health)
		var/current_penalty = src.hasStatus("maxhealth-")?:change
		src.setStatus("maxhealth-", null, current_penalty - amount / 4 * 3)
	src.mind.soul -= amount

	if(src.mind.soul <= 0)
		total_souls_sold++
		total_souls_value++

	return 1

/mob/proc/get_id()
	if(istype(src.equipped(), /obj/item/card/id))
		return src.equipped()
	if(istype(src.equipped(), /obj/item/device/pda2))
		var/obj/item/device/pda2/pda = src.equipped()
		return pda.ID_card

// http://www.byond.com/forum/post/1326139&page=2
//MOB VERBS ARE FASTER THAN OBJ VERBS, ELIMINATE ALL OBJ VERBS WHERE U CAN
// ALSO EXCLUSIVE VERBS (LIKE ADMIN VERBS) ARE BAD FOR RCLICK TOO, TRY NOT TO USE THOSE OK

/mob/verb/point(atom/A as mob|obj|turf in view())
	set name = "Point"
	src.point_at(A)

/mob/proc/point_at(var/atom/target) //overriden by living and dead
	.=0

/mob/verb/pull_verb(atom/movable/A as mob|obj in view(1))
	set name = "Pull / Unpull"
	set category = "Local"

	if (src.pulling && src.pulling == A)
		unpull_particle(src,src.pulling)
		src.set_pulling(null)
	else
		A.pull()


/mob/verb/examine_verb(atom/A as mob|obj|turf in view())
	set name = "Examine"
	set category = "Local"
	var/list/result = A.examine(src)
	boutput(src, result.Join("\n"))


/mob/living/verb/interact_verb(obj/A as obj in view(1))
	set name = "Pick Up / Left Click"
	set category = "Local"
	A.interact(src)

/mob/living/verb/pickup_verb()
	set name = "Pick Up"
	set hidden = 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if (I.loc == get_turf(I))
			items += I
	if (items.len)
		var/atom/A = input(usr, "What do you want to pick up?") as anything in items
		A.interact(src)
