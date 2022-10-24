// living

/mob/living
	event_handler_flags = USE_FLUID_ENTER  | IS_FARTABLE
	var/spell_soulguard = 0		//0 = none, 1 = normal_soulgruard, 2 = wizard_ring_soulguard

	// this is a read only variable. do not set it directly.
	// use set_burning or update_burning instead.
	// the value means how on fire is the mob, from 0 to 100

	var/datum/hud/vision/vision

	//AI Vars

	var/ai_busy = 0
	var/ai_laststep = 0
	var/ai_state = 0
	var/ai_threatened = 0
	var/ai_movedelay = 6
	var/ai_lastaction = 0
	var/ai_actiondelay = 10
	var/ai_pounced = 0
	var/ai_attacked = 0
	var/ai_frustration = 0
	var/ai_throw = 0
	var/ai_attackadmins = 1
	var/ai_attacknpc = 1
	var/ai_useitems = 1
	var/ai_suicidal = 0 //Will it attack itself?
	var/ai_active = 0


	var/mob/living/ai_target = null
	var/list/mob/living/ai_target_old = list()
	var/is_npc = 0

	var/move_laying = null
	var/has_typing_indicator = FALSE
	var/static/mutable_appearance/speech_bubble = living_speech_bubble
	var/static/mutable_appearance/sleep_bubble = mutable_appearance('icons/mob/mob.dmi', "sleep")
	var/image/static_image = null
	var/static_type_override = null
	var/icon/default_static_icon = null // set to an icon and that's what the static will generate from
	var/in_point_mode = 0
	var/butt_op_stage = 0.0 // sigh
	var/dna_to_absorb = 10

	var/canspeak = 1

	var/datum/organHolder/organHolder = null //Not all living mobs will use organholder. Instantiate on New() if you want one.

	var/list/stomach_process = list() //digesting foods
	var/list/skin_process = list() //digesting patches

	var/sound_burp = 'sound/voice/burp.ogg'
	var/sound_scream = 'sound/voice/screams/robot_scream.ogg' // for silicon mobs
	//var/sound_scream = 'sound/voice/screams/male_scream.ogg'
	//var/sound_femalescream = 'sound/voice/screams/female_scream.ogg'
	var/sound_flip1 = 'sound/machines/whistlealert.ogg' // for silicon mobs
	var/sound_flip2 = 'sound/machines/whistlebeep.ogg' // for silicon mobs
	var/sound_fart = 'sound/voice/farts/poo2.ogg'
	var/sound_snap = 'sound/impact_sounds/Generic_Snap_1.ogg'
	var/sound_fingersnap = 'sound/effects/fingersnap.ogg'
	var/sound_gasp = 'sound/voice/gasps/gasp.ogg'
	var/voice_type = "1"
	var/last_voice_sound = 0
	var/speechbubble_enabled = 1
	var/speechpopupstyle = null
	var/isFlying = 0 // for player controled flying critters

	var/caneat = 1
	var/candrink = 1

	var/canbegrabbed = 1
	var/grabresistmessage = null //Format: target.visible_message("<span class='alert'><B>[src] tries to grab [target], [target.grabresistmessage]</B></span>")

//#ifdef MAP_OVERRIDE_DESTINY
	var/hibernating = 0 // if they're stored in the cryotron, Life() gets skipped
//#endif

	var/throws_can_hit_me = 1

	var/last_heard_name = null
	var/last_chat_color = null

	var/list/random_emotes

	var/list/implant = list()
	var/list/implant_images = list()

	var/stance = "normal"

	var/special_sprint = SPRINT_NORMAL
	var/next_step_delay = 0
	var/next_sprint_boost = 0
	var/sustained_moves = 0

	var/metabolizes = 1

	var/can_bleed = 1
	var/blood_id = null
	var/blood_volume = 500
	var/blood_pressure = null
	var/blood_color = DEFAULT_BLOOD_COLOR
	var/bleeding = 0
	var/bleeding_internal = 0
	var/blood_absorption_rate = 1 // amount of blood to absorb from the reagent holder per Life()
	var/list/bandaged = list()
	var/being_staunched = 0 // is someone currently putting pressure on their wounds?

	var/co2overloadtime = null
	var/temperature_resistance = T0C+75

	var/use_stamina = 1
	var/stamina = STAMINA_MAX
	var/stamina_max = STAMINA_MAX
	var/stamina_regen = STAMINA_REGEN
	var/stamina_crit_chance = STAMINA_CRIT_CHANCE
	var/list/stamina_mods_regen = list()
	var/list/stamina_mods_max = list()

	var/list/stomach_contents = list()

	var/last_sleep = 0 //used for sleep_bubble

	can_lie = 1

	var/const/singing_prefix = "%"

/mob/living/New(loc, datum/appearanceHolder/AH_passthru, datum/preferences/init_preferences, ignore_randomizer=FALSE)
	..()
	init_preferences?.copy_to(src, usr, ignore_randomizer, skip_post_new_stuff=TRUE)
	vision = new()
	src.attach_hud(vision)
	if (can_bleed)
		src.ensure_bp_list()

	if (src.use_stamina)
		src.stamina_bar = new(src)
		//stamina bar gets added to the hud in subtypes human and critter... im sorry.
		//eventual hud merger pls

	SPAWN(0)
		src.get_static_image()
		sleep_bubble.appearance_flags = RESET_TRANSFORM
		if(!ishuman(src))
			init_preferences?.apply_post_new_stuff(src)


/mob/living/flash(duration)
	vision.flash(duration)

/mob/living/disposing()
	ai_target = null
	ai_target_old.len = 0
	move_laying = null

	if(stamina_bar)
		for (var/datum/hud/thishud in huds)
			thishud.remove_object(stamina_bar)
		stamina_bar = null

	for (var/atom/A as anything in stomach_process)
		qdel(A)
	for (var/atom/A as anything in skin_process)
		qdel(A)
	stomach_process = null
	skin_process = null

	for(var/mob/living/intangible/aieye/E in src.contents)
		E.cancel_camera()

	if (src.static_image)
		mob_static_icons.Remove(src.static_image)
		src.static_image = null

	if(src.ai_active)
		ai_mobs.Remove(src)
	..()

/mob/living/death(gibbed)
	#define VALID_MOB(M) (!isVRghost(M) && !isghostcritter(M) && !inafterlife(M))
	src.remove_ailments()
	if (src.key) statlog_death(src, gibbed)
	if (src.client && ticker.round_elapsed_ticks >= 12000 && VALID_MOB(src))
		var/num_players = 0
		for(var/client/C)
			if (!C.mob) continue
			var/mob/player = C.mob
			if (!isdead(player) && VALID_MOB(player))
				num_players++

		if (num_players <= 5 && master_mode != "battle_royale")
			if (!emergency_shuttle.online && current_state != GAME_STATE_FINISHED && ticker.mode.crew_shortage_enabled)
				if (emergency_shuttle.incall())
					boutput(world, "<span class='notice'><B>Alert: The emergency shuttle has been called.</B></span>")
					boutput(world, "<span class='notice'>- - - <b>Reason:</b> Crew shortages and fatalities.</span>")
					boutput(world, "<span class='notice'><B>It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.</B></span>")
	#undef VALID_MOB

	// Active if XMAS or manually toggled.
	if (deathConfettiActive)
		src.deathConfetti()

	var/youdied = "You have died!"
	if (prob(1))
		if (gibbed)
			youdied = pick("Cleanup on aisle 5", "What a mess...", "Nice and creamy", "Salsa con [src.real_name]", "Someone get the janitor!", "Gib and let gib", "Rest In Pieces", "Chunky!", "Quite a concept, being everywhere at once!", "Splat!")
		else
			youdied = pick("Congratulations on your recent death!", "Welp, so much for that.", "You are dead. Not big surprise.", "You are no longer alive.", "haha you died loser.", "R.I.P. [src.real_name]", "well, shit.", "Better luck next time.", "MISSING: Life, 100 credit reward", "w a s t e d", "Lost to the Zone", "Your Story Has Ended...", "Game over, man!")

	boutput(src, {"
	<div style="border: 3px solid red; padding: 3px;">
		<div style="background: black; padding: 0.1em; color: #f33; text-align: center; font-size: 150%; font-weight: bold;">
			[youdied]
		</div>
		<div style=" text-align: center;">
			[!gibbed ? {"
				<a href="byond://winset?command=Ghost" style="display: inline-block; font-size: 130%; font-weight: bold;">Become a Ghost</a>
				<br><em style="color: #666; font-size: 75%;">You can also use the "<a href="byond://winset?command=Ghost" style="font-family: 'Consolas', monospace;">Ghost</a>" command to observe.</em><br><br>
			"} : ""]
		<strong>You may be revived if someone clones you.</strong>
		<br>Otherwise, you'll have to wait for the next round.
		<br>
		<br>There's still plenty to do, even while dead!
		<br><strong><a href='byond://winset?command=Afterlife-Bar'>Visit the Afterlife Bar</a> &bull; <a href='byond://winset?command=Enter-VR'>Enter Virtual Reality</a>
			<br><a href='byond://winset?command=Enter-Ghostdrone-Queue'>Become a Ghost Drone</a> &bull; <a href='byond://winset?command=Respawn-as-Animal'>Become a Critter</a></strong>
		</div>
	</div>
		"})

	return ..(gibbed)

/mob/living/verb/afterlife_bar()
	set src = usr
	set hidden = TRUE
	set name = "Afterlife Bar"
	if(isdead(src))
		var/mob/dead/observer/ghost = src.ghostize()
		usr = ghost
		ghost.go_to_deadbar()
	else
		boutput(usr, "<span class='alert'>You are not dead yet!</span>")

/mob/living/verb/enter_ghostdrone_queue()
	set src = usr
	set hidden = TRUE
	set name = "Enter Ghostdrone Queue"
	if(isdead(src))
		var/mob/dead/observer/ghost = src.ghostize()
		usr = ghost
		ghost.enter_ghostdrone_queue()
	else
		boutput(usr, "<span class='alert'>You are not dead yet!</span>")

/mob/living/verb/enter_vr()
	set src = usr
	set hidden = TRUE
	set name = "Enter VR"
	if(isdead(src))
		var/mob/dead/observer/ghost = src.ghostize()
		usr = ghost
		ghost.go_to_vr()
	else
		boutput(usr, "<span class='alert'>You are not dead yet!</span>")

/mob/living/verb/respawn_as_animal()
	set src = usr
	set hidden = TRUE
	set name = "Respawn as Animal"
	if(isdead(src))
		var/mob/dead/observer/ghost = src.ghostize()
		usr = ghost
		ghost.respawn_as_animal()
	else
		boutput(usr, "<span class='alert'>You are not dead yet!</span>")

/mob/living/Logout()
	. = ..()
	src.UpdateOverlays(null, "speech_bubble")

/mob/living/Login()
	..()
	// If...
	// living
	// and not (in the afterlife, and not in hell)
	// and not a vr ghost
	// and not a ghost critter
	// and not a ghost drone
	// and not a living object (probably soulsteel)
	// ...then remove respawn candidate.
	if (!isdead(src) \
		&& !(istype(get_area(src), /area/afterlife) && !istype(get_area(src), /area/afterlife/hell)) \
		&& !isVRghost(src) \
		&& !isghostcritter(src) \
		&& !isghostdrone(src) \
		&& !islivingobject(src) \
	)
		respawn_controller.unsubscribeRespawnee(src.ckey)

/mob/living/Life(datum/controller/process/mobs/parent)
//#ifdef MAP_OVERRIDE_DESTINY
	if (hibernating)
		if (istype(src.loc, /obj/cryotron))
			if (!stat)
				setunconscious(src)
			return 1
		else
			hibernating = 0
//#endif
	if (..(parent))
		return 1
	return

/mob/living/update_camera()
	for (var/mob/dead/target_observer/observer in observers)
		if (observer.client)
			src.apply_camera(observer.client)
	..()

/mob/living/attach_hud(datum/hud/hud)
	for (var/mob/dead/target_observer/observer in observers)
		observer.attach_hud(hud)
	return ..()

/mob/living/detach_hud(datum/hud/hud)
	if (observers.len) //Wire note: Attempted fix for BUG: Bad ref (f:410976) in IncRefCount(DM living.dm:132)
		for (var/mob/dead/target_observer/observer in observers)
			observer.detach_hud(hud)
	return ..()

/mob/living/projCanHit(datum/projectile/P)
	if (!P) return 0
	if (!src.lying || GET_COOLDOWN(src, "lying_bullet_dodge_cheese") || (src:lying && prob(P.hit_ground_chance))) return 1
	return 0

/mob/living/proc/hand_attack(atom/target, params, location, control, origParams)
	target.Attackhand(src, params, location, control, origParams)

/mob/living/proc/hand_range_attack(atom/target, params, location, control, origParams)
	.= 0
	var/datum/limb/L = src.equipped_limb()
	if (L)
		.= L.attack_range(target,src,params)
		if (.)
			src.lastattacked = src

/mob/living/proc/weapon_attack(atom/target, obj/item/W, reach, params)
	var/usingInner = 0
	if (W.useInnerItem && W.contents.len > 0)
		var/obj/item/held = W.holding
		if (!held)
			held = pick(W.contents)
		if (held && !istype(held, /obj/ability_button))
			W = held
			usingInner = 1

	if (reach)
		target.Attackby(W, src, params)
	if (W && (equipped() == W || usingInner))
		var/pixelable = isturf(target)
		if (!pixelable)
			if (istype(target, /atom/movable) && isturf(target:loc))
				pixelable = 1
		if (pixelable)
			if (!W.pixelaction(target, params, src, reach))
				if (W)
					W.AfterAttack(target, src, reach, params)
		else if (!pixelable && W)
			W.AfterAttack(target, src, reach, params)

/mob/living/onMouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
	if (!src.restrained() && !is_incapacitated(src))
		var/obj/item/W = src.equipped()
		if (W) //nah dude, don't typecheck. just assume that mobs can only hold items, this proc gets called a fuckload
			W.onMouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
	return

/* nothing currently uses needOnMouseMove, so im commenting this out.
/mob/living/onMouseMove(object,location,control,params)
	var/obj/item/W = src.equipped()
	if(W.needOnMouseMove)
		if (!src.stat && !src.restrained() && !src.getStatusDuration("weakened") && !src.getStatusDuration("paralysis") && !src.getStatusDuration("stunned"))
			if (W && istype(W))
				W.onMouseMove(object,location,control,params)
	return
*/
/mob/living/onMouseDown(object,location,control,params)
	if (!src.restrained() && !is_incapacitated(src))
		var/obj/item/W = src.equipped()
		if (W && istype(W))
			W.onMouseDown(object,location,control,params)

/mob/living/onMouseUp(object,location,control,params)
	if (!src.restrained() && !is_incapacitated(src))
		var/obj/item/W = src.equipped()
		if (W && istype(W))
			W.onMouseUp(object,location,control,params)

/mob/living/MouseDrop_T(atom/dropped, mob/dropping_user)
	if(in_interact_range(src, dropping_user) && in_interact_range(dropped, dropping_user))
		if (istype(dropped, /obj/item/organ/) || istype(dropped, /obj/item/clothing/head/butt/) || istype(dropped, /obj/item/skull/))
			// because butts are clothing you're born with, and skull primarily exist to reenact hamlet... for some insane reason
			var/obj/item/organ/dropping_organ = dropped
			var/success = dropping_organ.attach_organ(src, dropping_user)
			if (success)
				return
		else if (istype(dropped, /obj/item/parts))
			if (istype(dropped, /obj/item/parts/human_parts/) || istype(dropped, /obj/item/parts/artifact_parts))
				var/obj/item/parts/dropping_limb = dropped
				dropping_limb.attach(src, dropping_user)
			else if (istype(dropped, /obj/item/parts/robot_parts/arm/) || istype(dropped, /obj/item/parts/robot_parts/leg/))
				var/obj/item/parts/robot_parts/dropping_limb = dropped
				dropping_limb.attack(src, dropping_user) // Attaching robot parts to humans is a bit complicated so we're going to be lazy and re-use attack.
	return ..()

/mob/living/hotkey(name)
	switch (name)
		if ("SHIFT")//bEGIN A SPRINT
			if (!src.client.tg_controls)
				start_sprint()
		if ("SPACE")
			if (src.client.tg_controls)
				start_sprint()
		if ("resist")
			src.resist()
		if ("rest")
			if (can_lie)
				if(src.ai_active && !src.hasStatus("resting"))
					src.show_text("You feel too restless to do that!", "red")
				else
					src.hasStatus("resting") ? src.delStatus("resting") : src.setStatus("resting", INFINITE_STATUS)
					src.force_laydown_standup()
		if ("togglepoint")
			src.toggle_point_mode()
		if ("say_radio")
			src.say_radio()
		else
			. = ..()

//gross are we tg or something with all of these /s
// i'd like to hear your suggestion for better searching for procs!!! - cirr
/mob/living/Click(location,control,params)
	if(istype(usr, /mob/dead/observer) && usr.client && !usr.client.keys_modifier && !usr:in_point_mode)
		var/mob/dead/observer/O = usr
#ifdef HALLOWEEN
		//when spooking, clicking on a mob doesn't put us in them.
		var/datum/abilityHolder/ghost_observer/GH = O:abilityHolder
		if (GH.spooking)
			return ..()
#endif
		O.insert_observer(src)
	else
		. = ..()

/mob/living/click(atom/target, params, location, control)
	. = ..()
	if (. == 100)
		return 100

	if (params["middle"])
		src.swap_hand()
		return

	if (location != "map")
		if (src.hibernating && istype(src.loc, /obj/cryotron))
			var/obj/cryotron/cryo = src.loc
			if (cryo.exit_prompt(src))
				return

		if (src.client && src.client.check_key(KEY_EXAMINE))
			src.examine_verb(target)
			return

		if (src.in_point_mode || (src.client && src.client.check_key(KEY_POINT)))
			src.point_at(target, text2num(params["icon-x"]), text2num(params["icon-y"]))
			if (src.in_point_mode)
				src.toggle_point_mode()
			return

	if (src.restrained())
		if (src.hasStatus("handcuffed"))
			boutput(src, "<span class='alert'>You are handcuffed! Use Resist to attempt removal.</span>")
		return

	actions.interrupt(src, INTERRUPT_ACT)

	if (!src.stat && !is_incapacitated(src))
		var/obj/item/equipped = src.equipped()
		var/use_delay = (target.flags & CLICK_DELAY_IN_CONTENTS || !(target in src.contents)) && !istype(target,/atom/movable/screen) && (!disable_next_click || ismob(target) || (target && target.flags & USEDELAY) || (equipped && equipped.flags & USEDELAY))
		var/grace_penalty = 0
		if ((target == equipped || use_delay) && world.time < src.next_click) // if we ignore next_click on attack_self we get... instachoking, so let's not do that
			var/time_left = src.next_click - world.time
			// since we're essentially encouraging players to click as soon as they possibly can, and how clicking strongly depends on lag, having a strong cutoff feels like bullshit
			// the grace window gives people a small amount of leeway without increasing the overall click rate by much
			if (time_left > CLICK_GRACE_WINDOW || (equipped && (equipped.flags & EXTRADELAY))) // also let's not enable this for guns.
				return time_left
			else
				grace_penalty = time_left

		if (target == equipped)
			equipped.AttackSelf(src)
			if(equipped.flags & ATTACK_SELF_DELAY)
				src.next_click = world.time + (equipped ? equipped.click_delay : src.click_delay)
		else if (params["ctrl"])
			var/atom/movable/movable = target
			if (istype(movable))
				movable.pull(src)

				if (mob_flags & AT_GUNPOINT)
					for(var/obj/item/grab/gunpoint/G in grabbed_by)
						G.shoot()

				.= 0
				return
		else
			var/reach = can_reach(src, target)
			if (src.pre_attack_modify())
				equipped = src.equipped() //might have changed from successful modify
			if (reach || (equipped && equipped.special) || (equipped && (equipped.flags & EXTRADELAY))) //Fuck you, magic number prickjerk //MBC : added bit to get weapon_attack->pixelaction to work for itemspecial
				if (use_delay)
					src.next_click = world.time + (equipped ? equipped.click_delay : src.click_delay)

				if (src.invisibility > INVIS_NONE && (isturf(target) || (target != src && isturf(target.loc)))) // dont want to check for a cloaker every click if we're not invisible
					SEND_SIGNAL(src, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)

				if (equipped)
					weapon_attack(target, equipped, reach, params)
				else
					hand_attack(target, params, location, control)

				//If lastattacked was set, this must be a combat action!! Use combat click delay ||  the other condition is whether a special attack was just triggered.
				if ((lastattacked != null && (src.lastattacked == target || src.lastattacked == equipped || src.lastattacked == src) && use_delay) || (equipped && equipped.special && equipped.special.last_use >= world.time - src.click_delay))
					src.next_click = world.time + (equipped ? max(equipped.click_delay,src.combat_click_delay) : src.combat_click_delay)
					src.lastattacked = null

			else if (!equipped)
				hand_range_attack(target, params, location, control)

				if (lastattacked != null && (src.lastattacked == target || src.lastattacked == equipped || src.lastattacked == src) && use_delay)
					src.next_click = world.time + src.combat_click_delay
					src.lastattacked = null

		//Don't think I need the above, this should work here.
		if (istype(src.loc, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/ship = src.loc
			if (ship.sensors)
				if (ship.sensors.active)
					var/obj/machinery/vehicle/target_pod = target
					if (src.loc != target_pod && istype(target_pod))
						ship.sensors.end_tracking()
						ship.sensors.quick_obtain_target(target_pod)
				else
					if (istype(target, /obj/machinery/vehicle))
						boutput(src, "<span class='alert'>Sensors are inactive, unable to target craft!</span>")


		if (src.next_click >= world.time) // since some of these attack functions go wild with modifying next_click, we implement the clicking grace window with a penalty instead of changing how next_click is set
			src.next_click += grace_penalty

/mob/living/proc/pre_attack_modify()
	. = 0
	var/obj/item/grab/block/G = src.check_block()
	if (G)
		qdel(G)
		. = 1

/mob/living/update_cursor()
	..()
	if (src.client)
		if (src.in_point_mode || src.client.check_key(KEY_POINT))
			src.set_cursor('icons/cursors/point.dmi')
			return

		if (src.client.check_key(KEY_EXAMINE))
			src.set_cursor('icons/cursors/examine.dmi')
			return

		if (src.client.check_key(KEY_PULL))
			src.set_cursor('icons/cursors/pull.dmi')
			return

/mob/living/key_down(key)
	if (key == "alt" || key == "ctrl" || key == "shift")
		update_cursor()

/mob/living/key_up(key)
	if (key == "alt" || key == "ctrl" || key == "shift")
		update_cursor()

/mob/living/proc/toggle_point_mode(var/force_off = 0)
	if (force_off)
		src.in_point_mode = 0
		src.update_cursor()
		return
	src.in_point_mode = !(src.in_point_mode)
	src.update_cursor()

/mob/living/point_at(var/atom/target, var/pixel_x, var/pixel_y)
	if (!isturf(src.loc) || !isalive(src) || src.restrained())
		return

	if (isghostcritter(src))
		return

	if (src.reagents && src.reagents.has_reagent("capulettium_plus"))
		src.show_text("You are completely paralysed and can't point!", "red")
		return

	if (istype(target, /obj/decal/point))
		return

	var/obj/item/gun/G = src.equipped()
	if(!istype(G) || !ismob(target))
		src.visible_message("<span class='emote'><b>[src]</b> points to [target].</span>")
	else
		src.visible_message("<span style='font-weight:bold;color:#f00;font-size:120%;'>[src] points \the [G] at [target]!</span>")
	if (!ON_COOLDOWN(src, "point", 0.5 SECONDS))
		make_point(target, pixel_x=pixel_x, pixel_y=pixel_y, color=src.bioHolder.mobAppearance.customization_first_color, pointer=src)


/mob/living/proc/set_burning(var/new_value)
	setStatus("burning", new_value SECONDS)

/mob/living/proc/update_burning(var/change)
	changeStatus("burning", change SECONDS)

/mob/living/proc/update_burning_icon(var/force_remove = 0)
	return

/mob/living/proc/get_equipped_ore_scoop()
	. = null

/mob/living/proc/talk_into_equipment(var/mode, var/messages, var/param, var/lang_id)
	switch (mode)
		if ("headset")
			if (src.ears)
				src.ears.talk_into(src, messages, param, src.real_name, lang_id)
			else if (ishuman(src))
				var/mob/living/carbon/human/H = src
				if(isskeleton(H) && !H.organHolder.head)
					var/datum/mutantrace/skeleton/S = H.mutantrace
					if(S.head_tracker != null)
						S.head_tracker.ears?.talk_into(src, messages, param, src.real_name, lang_id)

		if ("secure headset")
			if (src.ears)
				src.ears.talk_into(src, messages, param, src.real_name, lang_id)
			else if (ishuman(src))
				var/mob/living/carbon/human/H = src
				if(isskeleton(H) && !H.organHolder.head)
					var/datum/mutantrace/skeleton/S = H.mutantrace
					if(S.head_tracker != null)
						S.head_tracker.ears?.talk_into(src, messages, param, src.real_name, lang_id)

		if ("right hand")
			if (src.r_hand && src.organHolder.head)
				src.r_hand.talk_into(src, messages, param, src.real_name, lang_id)
			else
				src.emote("handpuppet")

		if ("left hand")
			if (src.l_hand && src.organHolder.head)
				src.l_hand.talk_into(src, messages, param, src.real_name, lang_id)
			else
				src.emote("handpuppet")

/// returns true if first letter of things that person says should be capitalized
/mob/living/proc/capitalize_speech()
	if (!client)
		return FALSE
	if (!client.preferences)
		return FALSE
	. = src.client.preferences.auto_capitalization

/// special behavior for AIs to make sure it still works in eyecam form
/mob/living/silicon/ai/capitalize_speech()
	if (!client)
		if (src?.eyecam?.client?.preferences)
			return src.eyecam.client.preferences.auto_capitalization
	. = ..()

/mob/living/say(var/message, ignore_stamina_winded, var/unique_maptext_style, var/maptext_animation_colors)
	message = strip_html(trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)))

	if (!message)
		return

	// Zam note: this is horrible
	if (forced_desussification)
		// "Surely this goes somewhere else, right, Zam?"
		// maybe? i guess?
		// i mean, i don't care. i'm stoned and i have commit rights
		// and this is 100% a joke. it'll probably get refactored into
		// something reasonable later if people like it.
		//
		// when you think about it, github is like amogus
		// if it finds dead code, it calls an emergeny meeting!
		if (phrase_log.is_sussy(message))
			// var/turf/T = get_turf(src)
			// var/turf/M = locate(T.x, max(world.maxy, T.y + 8), T.z)
			arcFlash(src, src, 5000)

	if (reverse_mode) message = reverse_text(message)

	logTheThing(LOG_DIARY, src, ": [message]", "say")

#ifdef DATALOGGER
	// Jewel's attempted fix for: null.ScanText()
	if (game_stats)
		game_stats.ScanText(message)
#endif

	if (src.client && src.client.ismuted())
		boutput(src, "You are currently muted and may not speak.")
		return

	if(!src.canspeak)
		boutput(src, "<span class='alert'>You can not speak!</span>")
		return

	if (isdead(src))
		if (dd_hasprefix(message, "*")) // no dead emote spam
			return
		return src.say_dead(message)

	if(src.z == 2 && istype(get_area(src),/area/afterlife)) //check zlevel before doing istype
		if (dd_hasprefix(message, ":d"))
			message = trim(copytext(message, 3, MAX_MESSAGE_LEN))
			return src.say_dead(message)

	// wtf?
	if (src.stat)
		return

	// emotes
	if (dd_hasprefix(message, "*") && !src.stat)
		return src.emote(copytext(message, 2),1)

	// Mute disability
	if (src.bioHolder && src.bioHolder.HasEffect("mute"))
		boutput(src, "<span class='alert'>You seem to be unable to speak.</span>")
		return

	if (src.wear_mask && src.wear_mask.is_muzzle)
		boutput(src, "<span class='alert'>Your muzzle prevents you from speaking.</span>")
		return

	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		// If theres no oxygen
		if (H.oxyloss > 10 || H.losebreath >= 4 || H.hasStatus("muted") || (H.reagents?.has_reagent("capulettium_plus") && H.hasStatus("resting"))) // Perfluorodecalin cap - normal life() depletion - buffer.
			H.whisper(message, forced=TRUE)
			return

	message = trim(message)

	// check for singing prefix before radio prefix
	message = check_singing_prefix(message)

	message = say_decorate(message)

	var/italics = 0
	var/forced_language = null
	var/message_range = null
	var/message_mode = null
	var/secure_headset_mode = null
	var/skip_open_mics_in_range = 0 // For any radios or intercoms that happen to be in range.

	if (prob(50) && src.get_brain_damage() >= 60)
		if (ishuman(src))
			message_mode = "headset"
	// Special message handling
	else if (copytext(message, 1, 2) == ";")
		message_mode = "headset"
		message = copytext(message, 2)

	else if ((length(message) >= 2) && (copytext(message,1,2) == ":"))
		switch (lowertext( copytext(message,2,4) ))
			if ("rh")
				message_mode = "right hand"
				message = copytext(message, 4)

			if ("lh")
				message_mode = "left hand"
				message = copytext(message, 4)

		/*else if (copytext(message, 1, 3) == ":w")
			message_mode = "whisper"
			message = copytext(message, 3)*/

			if ("in")
				message_mode = "intercom"
				message = copytext(message, 4)

			else
				// AI radios. See further down in this proc (Convair880).
				if (isAI(src))
					switch (lowertext(copytext(message, 2, 3))) // One vs. two letter prefix.
						if ("1")
							message_mode = "internal 1"
							message = copytext(message, 3)

						if ("2")
							message_mode = "internal 2"
							message = copytext(message, 3)

						if ("3")
							message_mode = "monitor"
							var/end = 3
							if (!lowertext(copytext(message,3,4) == " "))
								end = 4
								secure_headset_mode = lowertext(copytext(message,3,end)) //why did i do this to the players
							message = copytext(message, end)
						else // Chances are they're using a regular radio prefix instead of a 2 letter one
							if (!lowertext(copytext(message,2,3) == " ")) // (This makes the :3 prefixes obsolete but fuck em they mess players up)
								message_mode = "monitor"
								secure_headset_mode = lowertext(copytext(message,2,3))
							message = copytext(message, 3)

				else
					if (ishuman(src) || ismobcritter(src) || isrobot(src) || isshell(src)) // this is shit
						message_mode = "secure headset"
						secure_headset_mode = lowertext(copytext(message,2,3))
					message = copytext(message, 3)

	forced_language = get_special_language(secure_headset_mode)

	message = trim(message)

	// check for singing prefix after radio prefix
	if (!singing)
		message = check_singing_prefix(message)
	if (singing)
		// Scots can only sing Danny Boy
		if (src.bioHolder?.HasEffect("accent_scots"))
			var/scots = src.bioHolder.GetEffect("accent_scots")
			if (istype(scots, /datum/bioEffect/speech/scots))
				var/datum/bioEffect/speech/scots/S = scots
				S.danny_index = (S.danny_index % 16) + 1
				var/lyrics = dd_file2list("strings/danny.txt")
				message = lyrics[S.danny_index]

	if (!message)
		return

	if(src.capitalize_speech())
		message = capitalize(message)

	if (src.voice_type && world.time > last_voice_sound + 8)
		var/VT = voice_type
		var/ending = copytext(message, length(message))

		switch (message_mode)
			if ("headset", "secure headset", "right hand", "left hand", "intercom")
				VT = "radio"
				ending = 0

		if (singing || (src.bioHolder?.HasEffect("elvis")))
			if (src.get_brain_damage() >= 60 || src.bioHolder?.HasEffect("unintelligable") || src.hasStatus("drunk"))
				singing |= BAD_SINGING
				speech_bubble.icon_state = "notebad"
			else
				speech_bubble.icon_state = "note"
				if (ending == "!" || (src.bioHolder?.HasEffect("loud_voice")))
					singing |= LOUD_SINGING
					speech_bubble.icon_state = "notebad"
				else if (src.bioHolder?.HasEffect("quiet_voice"))
					singing |= SOFT_SINGING
			playsound(src, sounds_speak["[VT]"],  55, 0.01, 8, src.get_age_pitch_for_talk(), ignore_flag = SOUND_SPEECH)
		else if (ending == "?")
			playsound(src, sounds_speak["[VT]?"], 55, 0.01, 8, src.get_age_pitch_for_talk(), ignore_flag = SOUND_SPEECH)
			speech_bubble.icon_state = "?"
		else if (ending == "!")
			playsound(src, sounds_speak["[VT]!"], 55, 0.01, 8, src.get_age_pitch_for_talk(), ignore_flag = SOUND_SPEECH)
			speech_bubble.icon_state = "!"
		else
			playsound(src, sounds_speak["[VT]"],  55, 0.01, 8, src.get_age_pitch_for_talk(), ignore_flag = SOUND_SPEECH)
			speech_bubble.icon_state = "speech"

		last_voice_sound = world.time
	else
		speech_bubble.icon_state = "speech"

	if ((isrobot(src) || isAI(src)) && singing)
		speech_bubble.icon_state = "noterobot"
		if (copytext(message, length(message)) == "!")
			singing |= LOUD_SINGING

	if (text2num(message)) //mbc : check mob.dmi for the icons
		var/n = round(text2num(message),1)
		if ((n >= 0 && n <= 20) || n == 420)
			speech_bubble.icon_state = "[n]"

	if(src.client)
		if(singing)
			phrase_log.log_phrase("sing", message)
		else if(message_mode)
			phrase_log.log_phrase("radio", message)
		else
			phrase_log.log_phrase("say", message)

	if (src.stuttering)
		message = stutter(message)

	if (src.get_brain_damage() >= 60)
		message = replacetext(message, "is ", "am ")
		message = replacetext(message, "are ", "am ")
		message = replacetext(message, "i ", "me ")
		message = replacetext(message, "have ", "am ")
		message = replacetext(message, "youre ", "your ")
		message = replacetext(message, "you're ", "your ")
		message = replacetext(message, "attack ", "kill ")
		message = replacetext(message, "hurt", " kill")
		message = replacetext(message, "acquire ", "get ")
		message = replacetext(message, "attempt ", "try ")
		message = replacetext(message, "attention ", "help ")
		message = replacetext(message, "attempt ", "try ")
		message = replacetext(message, "grief", "grife")
		message = replacetext(message, "her ", "she ")
		message = replacetext(message, "him ", "he ")
		message = replacetext(message, "heal", "fix")
		message = replacetext(message, "repair ", "fix")
		message = replacetext(message, "heal ", "fix")
		message = replacetext(message, "space", "spess")
		message = replacetext(message, "clown", "honky man")
		message = replacetext(message, "cluwne", "bad honky man")
		message = replacetext(message, "traitor", "bad guy")
		message = replacetext(message, "spy", "bad guy")
		message = replacetext(message, "operative", "bad guy")
		message = replacetext(message, "nukie", "bad guy")
		message = replacetext(message, "vampire", "bad guy")
		message = replacetext(message, "wrestler", "bad guy")
		message = replacetext(message, "alien", "allen")
		message = replacetext(message, "changeling", "alien")
		message = replacetext(message, "pain", "hurt")
		message = replacetext(message, "damage", "hurt")
		message = replacetext(message, "they", "them")

		if (prob(20))
			if(prob(25))
				message = uppertext(message)
				message = "[message][stutter(pick("!", "!!", "!!!"))]"
			if(!src.stuttering && prob(8))
				message = stutter(message)

	show_speech_bubble(speech_bubble)

	//Blobchat handling
	if (src.mob_flags & SPEECH_BLOB)
		message = html_encode(src.say_quote(message))
		var/rendered = "<span class='game blobsay'>"
		rendered += "<span class='prefix'>BLOB:</span> "
		rendered += "<span class='name text-normal' data-ctx='\ref[src.mind]'>[src.get_heard_name()]</span> "
		rendered += "<span class='message'>[message]</span>"
		rendered += "</span>"


		for (var/client/C)
			if (!C.mob) continue
			if (istype(C.mob, /mob/new_player))
				continue

			if ((isblob(C.mob) || (C.holder && C.deadchat && !C.player_mode)))
				var/thisR = rendered
				if ((C.mob.mob_flags & MOB_HEARS_ALL || C.holder) && src.mind)
					thisR = "<span class='adminHearing' data-ctx='[C.chatOutput.ctxFlag]'>[rendered]</span>"
				C.mob.show_message(thisR, 2)

		return

	var/list/messages = process_language(message, forced_language)
	var/lang_id = get_language_id(forced_language)

	// Do they have a phone?
	var/obj/item/equipped_talk_thing = src.equipped()
	if(equipped_talk_thing && equipped_talk_thing.flags & TALK_INTO_HAND && !message_mode)
		equipped_talk_thing.talk_into(src, messages, secure_headset_mode, src.real_name, lang_id)
	switch (message_mode)
		if ("headset", "secure headset", "right hand", "left hand")
			talk_into_equipment(message_mode, messages, secure_headset_mode, lang_id)
			message_range = 1
			italics = 1

		//Might put this back if people are used to the old system.
		/*if ("whisper")
			message_range = 1
			italics = 1*/

		// Added shortcuts for the AI mainframe radios. All the relevant vars are already defined here, and
		// I didn't want to have to reinvent the wheel in silicon.dm (Convair880).
		if ("internal 1", "internal 2", "monitor")
			var/mob/living/silicon/ai/A
			var/obj/item/device/radio/R1
			var/obj/item/device/radio/R2
			var/obj/item/device/radio/R3

			if (isAI(src))
				A = src
			else if (issilicon(src))
				var/mob/living/silicon/S = src
				if (S.dependent && S.mainframe && isAI(S.mainframe)) // AI-controlled robot.
					A = S.mainframe

			if (A && isAI(A))
				if (A.radio1 && istype(A.radio1, /obj/item/device/radio/))
					R1 = A.radio1
				if (A.radio2 && istype(A.radio2, /obj/item/device/radio/))
					R2 = A.radio2
				if (A.radio3 && istype(A.radio3, /obj/item/device/radio/))
					R3 = A.radio3

			switch (message_mode)
				if ("internal 1")
					if (R1 && !(A.stat || A.hasStatus(list("stunned", "weakened")))) // Mainframe may be stunned when the shell isn't.
						R1.talk_into(src, messages, null, A.name, lang_id)
						italics = 1
						skip_open_mics_in_range = 1 // First AI intercom broadcasts everything by default.
						//DEBUG_MESSAGE("AI radio #1 triggered. Message: [message]")
					else
						src.show_text("Mainframe radio inoperable or unavailable.", "red")
				if ("internal 2")
					if (R2 && !(A.stat || A.hasStatus(list("stunned", "weakened"))))
						R2.talk_into(src, messages, null, A.name, lang_id)
						italics = 1
						skip_open_mics_in_range = 1
						//DEBUG_MESSAGE("AI radio #2 triggered. Message: [message]")
					else
						src.show_text("Mainframe radio inoperable or unavailable.", "red")
				if ("monitor")
					if (R3 && !(A.stat || A.hasStatus(list("stunned", "weakened"))))
						R3.talk_into(src, messages, secure_headset_mode, A.name, lang_id)
						italics = 1
						skip_open_mics_in_range = 1
						//DEBUG_MESSAGE("AI radio #3 triggered. Message: [message]")
					else
						src.show_text("Mainframe radio inoperable or unavailable.", "red")

		if ("intercom")
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, messages, null, src.real_name, lang_id)

			message_range = 1
			italics = 1

	var/heardname = src.real_name

	var/is_decapitated_skeleton = ishuman(src) && isskeleton(src) && !src.organHolder.head

	if (!skip_open_mics_in_range && !is_decapitated_skeleton)
		src.send_hear_talks(message_range, messages, heardname, lang_id)

	var/list/listening = list()
	var/list/olocs = list()
	var/atom/say_location = src
	var/thickness = 0
	if (is_decapitated_skeleton)	//Decapitated skeletons speak from their heads
		var/mob/living/carbon/human/H = src
		var/datum/mutantrace/skeleton/S = H.mutantrace
		if (S.head_tracker)
			say_location = S.head_tracker
	if (isturf(say_location.loc))
		listening = all_hearers(message_range, say_location)
	else
		olocs = obj_loc_chain(src)
		if(olocs.len > 0) // fix runtime list index out of bounds when loc is null (IT CAN HAPPEN, APPARENTLY)
			for (var/atom/movable/AM in olocs)
				thickness += AM.soundproofing
			listening = all_hearers(message_range, olocs[olocs.len])


	listening |= src


	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/mob/M as anything in listening)
		if(M.mob_flags & MOB_HEARS_ALL)
			continue
		else if (M.say_understands(src, forced_language))
			heard_a[M] = 1
		else
			heard_b[M] = 1

	var/list/processed = list()

	var/image/chat_maptext/chat_text = null
	if (!message_range && speechpopups && src.chat_text)
		//new /obj/maptext_junk/speech(src, msg = messages[1], style = src.speechpopupstyle) // sorry, Zamu
		if(!last_heard_name || src.get_heard_name() != src.last_heard_name)
			var/num = hex2num(copytext(md5(src.get_heard_name()), 1, 7))
			src.last_chat_color = hsv2rgb(num % 360, (num / 360) % 10 + 18, num / 360 / 10 % 15 + 85)
			src.last_heard_name = src.get_heard_name()

		var/turf/T = get_turf(say_location)
		for(var/i = 0; i < 2; i++) T = get_step(T, WEST)
		for(var/i = 0; i < 5; i++)
			for(var/mob/living/L in T)
				if(L != src)
					for(var/image/chat_maptext/I in L.chat_text?.lines)
						I.bump_up()
			T = get_step(T, EAST)

		var/singing_italics = singing ? " font-style: italic;" : ""
		var/maptext_color
		if (singing)
			if (isAI(src) || isrobot(src))
				maptext_color = "#84d6d6"
			else
				maptext_color ="#D8BFD8"
		else
			maptext_color = src.last_chat_color

		if(unique_maptext_style)
			chat_text = make_chat_maptext(say_location, messages[1], "color: [maptext_color];" + unique_maptext_style + singing_italics)
		else
			chat_text = make_chat_maptext(say_location, messages[1], "color: [maptext_color];" + src.speechpopupstyle + singing_italics)

		if(maptext_animation_colors)
			oscillate_colors(chat_text, maptext_animation_colors)

		if(chat_text)
			chat_text.measure(src.client)
			for(var/image/chat_maptext/I in src.chat_text.lines)
				if(I != chat_text)
					I.bump_up(chat_text.measured_height)

	var/rendered = null
	if (length(heard_a))
		processed = saylist(messages[1], heard_a, olocs, thickness, italics, processed, assoc_maptext = chat_text)

	if (length(heard_b))
		processed = saylist(messages[2], heard_b, olocs, thickness, italics, processed, 1)

	message = src.say_quote(messages[1])


	if (italics)
		message = "<i>[message]</i>"

	rendered = "<span class='game say'>[src.get_heard_name()] <span class='message'>[message]</span></span>"
	if(src.mob_flags & SPEECH_REVERSE)
		rendered = "<span style='-ms-transform: rotate(180deg)'>[rendered]</span>"

	var/viewrange = 0
	var/list/hearers = hearers(say_location)
	for (var/client/C)
		var/mob/M = C.mob

		if (!M || M.z == 2 && istype(M, /mob/new_player))
			continue

		//Hello welcome to the world's most awful if
		if (( \
			M.mob_flags & MOB_HEARS_ALL || \
			(iswraith(M) && !M.density) || \
			(istype(M, /mob/zoldorf)) || \
			(isintangible(M) && (M in hearers)) || \
			( \
				(!isturf(say_location.loc) && say_location.loc == M.loc) && \
				!(M in heard_a) && \
				!istype(M, /mob/dead/target_observer) && \
				M != src \
			) \
		))

			var/thisR = rendered
			if (src.mind && M.client.chatOutput && (M.mob_flags & MOB_HEARS_ALL || M.client.holder))
				thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.ctxFlag]'>[rendered]</span>"

			if (isobserver(M)) //if a ghooooost (dead) (and online)
				viewrange = (((istext(C.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) - 1) / 2)
				if (M.client.preferences.local_deadchat || iswraith(M)) //only listening locally (or a wraith)? w/e man dont bold dat
					//if (M in range(M.client.view, src))
					if (GET_DIST(M,say_location) <= viewrange)
						M.show_message(thisR, 2, assoc_maptext = chat_text)
				else
					//if (M in range(M.client.view, src)) //you're not just listening locally and the message is nearby? sweet! bold that sucka brosef
					if (GET_DIST(M,say_location) <= viewrange) //you're not just listening locally and the message is nearby? sweet! bold that sucka brosef
						M.show_message("<span class='bold'>[thisR]</span>", 2, assoc_maptext = chat_text) //awwwww yeeeeeah lookat dat bold
					else
						M.show_message(thisR, 2, assoc_maptext = chat_text)
			else if(istype(M, /mob/zoldorf))
				viewrange = (((istext(C.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) - 1) / 2)
				if (GET_DIST(M,say_location) <= viewrange)
					if((!istype(M.loc,/obj/machinery/playerzoldorf))&&(!istype(M.loc,/mob))&&(M.invisibility == INVIS_GHOST))
						M.show_message(thisR, 2, assoc_maptext = chat_text)
				else
					M.show_message(thisR, 2, assoc_maptext = chat_text)
			else
				M.show_message(thisR, 2, assoc_maptext = chat_text)

/mob/living/proc/say_decorate(message)
	return message

// helper proooocs

/mob/proc/send_hear_talks(var/message_range, var/messages, var/heardname, var/lang_id)	//helper to send hear_talk to all mob, obj, and turf
	for (var/atom/A as anything in all_view(message_range, src))
		A.hear_talk(src,messages,heardname,lang_id)

/mob/proc/get_heard_name()
	. = "<span class='name' data-ctx='\ref[src.mind]'>[src.name]</span>"


/mob/proc/move_callback_trigger(var/obj/move_laying, var/turf/NewLoc, var/oldloc, direct)
	if (move_laying)
		if((direct & (NORTH|SOUTH)) && (direct & (EAST|WEST)))//MBC : work around the diagonal bug that we don't understand : if((direct & (NORTH|SOUTH)) && (direct & (EAST|WEST)))
			for (var/d in cardinal)
				if (direct & d)
					var/nloc = get_step(oldloc, d)
					move_laying.move_callback(src, oldloc, nloc)
					oldloc = nloc
		else
			move_laying.move_callback(src, oldloc, NewLoc)

/mob/living/Move(var/turf/NewLoc, direct)
	var/oldloc = loc
	. = ..()
	if (isturf(oldloc) && isturf(loc) && move_laying)
		var/list/equippedlist = src.equipped_list()
		if (length(equippedlist))
			var/move_callback_happened = 0
			for (var/I in equippedlist)
				if (I == move_laying)
					move_callback_trigger(move_laying, NewLoc, oldloc, direct)
					move_callback_happened = 1
				else if (islist(move_laying))
					for (var/M in move_laying)
						if (I == M)
							move_callback_trigger(M, NewLoc, oldloc, direct)
							move_callback_happened = 1
			if (!move_callback_happened)
				move_laying = null
		else
			move_laying = null

/mob/living/change_misstep_chance(var/amount)
	if (..())
		return

	src.misstep_chance = clamp(misstep_chance + amount, 0, 100)

/mob/living/proc/get_static_image()
	if (src.disposed)
		return
	if (!islist(default_mob_static_icons))
		return
	if (src.static_image)
		mob_static_icons.Remove(src.static_image)
	var/checkpath = src.static_type_override ? src.static_type_override : src.type
	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		if (istype(H.mutantrace))
			checkpath = H.mutantrace.type
	if (ispath(checkpath))
		var/generate_static = 1
		if (checkpath in default_mob_static_icons)
			if (istype(default_mob_static_icons[checkpath], /image))
				src.static_image = image(default_mob_static_icons[checkpath])
				src.static_image.override = 1
				src.static_image.loc = src
				src.static_image.plane = PLANE_LIGHTING
				mob_static_icons.Add(src.static_image)
				generate_static = 0
		if (generate_static)
			if (ispath(checkpath, /datum/mutantrace) && ishuman(src))
				var/mob/living/carbon/human/H = src
				if (H.mutantrace)
					src.static_image = getTexturedImage(icon(H.mutantrace.icon, H.mutantrace.icon_state), "static", ICON_OVERLAY)
			else
				src.static_image = getTexturedImage(src.default_static_icon ? src.default_static_icon : icon(src.icon, src.icon_state), "static", ICON_OVERLAY)
			if (src.static_image)
				default_mob_static_icons[checkpath] = image(src.static_image)
				src.static_image.override = 1
				src.static_image.loc = src
				src.static_image.plane = PLANE_LIGHTING
				mob_static_icons.Add(src.static_image)
		return src.static_image

/proc/check_static_defaults()
	if (!islist(default_mob_static_icons))
		DEBUG_MESSAGE("default_mob_static_icons is not a list")
		return
	for (var/Type in default_mob_static_icons)
		var/image/i = default_mob_static_icons[Type]
		if (i)
			DEBUG_MESSAGE(bicon(i) + "\ref[i][Type]")

var/global/icon/human_static_base_idiocy_bullshit_crap = icon('icons/mob/human.dmi', "body_m")


/mob/living/verb/give_item()
	set name = "Give Item"
	set src in view(1)
	set category = "Local"

	SPAWN(0.7 SECONDS) //secret spawn delay, so you can't spam this during combat for a free "stun"
		if (usr && isliving(usr) && !issilicon(usr) && BOUNDS_DIST(src, usr) == 0)
			var/mob/living/L = usr
			L.give_to(src)

/mob/living/proc/give_to(var/mob/living/M)
	if (!M)
		return

#ifdef TWITCH_BOT_ALLOWED
	if (IS_TWITCH_CONTROLLED(M))
		return
#endif

	var/message = null

	var/obj/item/thing = src.equipped()
	if (!thing)
		if (src.l_hand)
			thing = src.l_hand
		else if (src.r_hand)
			thing = src.r_hand
		if (!thing)
			return

	// Prevent attempting to pass item arms
	if (thing == src.l_hand)
		if (ishuman(src))
			var/mob/living/carbon/human/H = src
			if (!(H.has_hand(1)))
				if (!(H.has_hand(0)))
					return
				else
					thing = src.r_hand
	if (thing == src.r_hand)
		if (ishuman(src))
			var/mob/living/carbon/human/H = src
			if (!(H.has_hand(0)))
				if (!(H.has_hand(1)))
					return
				else
					thing = src.l_hand
	if (!thing)
		return
	//passing grab theoretically could be a mechanic but needs some annoying fixed - swapping around assailant and item grab handling an stuff probably
	if(istype(thing,/obj/item/grab))
		return

	if (thing.c_flags & HAS_GRAB_EQUIP)
		return

	if (thing)

		if (M.client && tgui_alert(M, "[src] offers [his_or_her(src)] [thing] to you. Do you accept it?", "Accept given [thing]", list("Yes", "No"), timeout = 10 SECONDS) == "Yes" || M.ai_active)
			if (!thing || !M || !(BOUNDS_DIST(src, M) == 0) || thing.loc != src || src.restrained())
				return
			src.u_equip(thing)
			if (src.bioHolder && src.bioHolder.HasEffect("clumsy") && prob(50))
				message = "<B>[src]</B> tries to hand [thing] to [M], but [src] drops it!"
				thing.set_loc(src.loc)
				JOB_XP(src, "Clown", 2)
			else if (M.bioHolder && M.bioHolder.HasEffect("clumsy") && prob(50))
				message = "<B>[src]</B> tries to hand [thing] to [M], but [M] drops it!"
				thing.set_loc(M.loc)
			else if (M.put_in_hand(thing))
				message = "<B>[src]</B> hands [thing] to [M]."
				if(istype(thing,/obj/item/toy/diploma))
					var/obj/item/toy/diploma/D = thing
					if(!D.receiver && D.redeemer == src.ckey)
						M.unlock_medal( "Unlike the director, I went to college", 1 )
						D.receiver = M.ckey
						D.desc += " Awarded by the esteemed clown professor [src.name] to [M.name] at [o_clock_time()]."
			else
				src.put_in_hand_or_drop(thing)
				if (M.has_any_hands())
					message = "<B>[src]</B> tries to hand [thing] to [M], but [M]'s hands are full!"
				else
					message = "<B>[src]</B> tries to hand [thing] to [M], but [M] doesn't have any hands!"
		else
			message = "<B>[src]</B> tries to hand [thing] to [M], but [M] declines."

	src.visible_message("<span class='subtle'>[message]</span>")

//Phyvo: Resist generalization. For when humans can break or remove shackles/cuffs, see daughter proc in humans.dm
/mob/living/proc/resist()
	if (!isalive(src)) //can't resist when dead or unconscious
		return

	if (src.last_resist > world.time)
		return
	src.last_resist = world.time + 20

	if (isobj(src.loc))
		var/obj/container = src.loc
		if (container.mob_resist_inside(src))
			return TRUE //cancel further resist code if needed

	if (src.getStatusDuration("burning"))
		if (!actions.hasAction(src, "fire_roll"))
			src.last_resist = world.time + 25
			actions.start(new/datum/action/fire_roll(), src)
		else
			return

	var/turf/T = get_turf(src)
	if (T.active_liquid && src.lying)
		T.active_liquid.Crossed(src)
		src.visible_message("<span class='alert'>[src] splashes around in [T.active_liquid]!</b></span>", "<span class='notice'>You splash around in [T.active_liquid].</span>")

	if (!src.restrained() && isalive(src)) //isalive returns false for both dead and unconcious, which is what we want
		var/struggled_grab = 0
		if (!is_incapacitated(src))
			if(length(src.grabbed_by) > 0)
				for (var/obj/item/grab/G in src.grabbed_by)
					G.do_resist()
					struggled_grab = TRUE
			else
				if(src.pulled_by)
					for (var/mob/O in AIviewers(src, null))
						O.show_message(text("<span class='alert'>[] resists []'s pulling!</span>", src, src.pulled_by), 1, group = "resist")
					src.pulled_by.remove_pulling()
					struggled_grab = TRUE
		else
			for (var/obj/item/grab/G in src.grabbed_by)
				if (G.stunned_targets_can_break())
					G.do_resist()
					struggled_grab = TRUE

		if (!src.grabbed_by || !length(src.grabbed_by) && !struggled_grab)
			if (src.buckled)
				src.buckled.Attackhand(src)
				src.force_laydown_standup() //safety because buckle code is a mess
				if (src.targeting_ability == src.chair_flip_ability) //fuCKKK
					src.targeting_ability = null
					src.update_cursor()
			else
				if (!src.getStatusDuration("burning"))
					if (src.grab_block())
						src.last_resist = world.time + COMBAT_BLOCK_DELAY
					else
						for (var/mob/O in AIviewers(src, null))
							O.show_message(text("<span class='alert'><B>[] resists!</B></span>", src), 1, group = "resist")

	return 0

/mob/living/set_loc(var/newloc as turf|mob|obj in world)
	var/atom/oldloc = src.loc
	. = ..()
	if(src && !src.disposed && src.loc && (!istype(src.loc, /turf) || !istype(oldloc, /turf)))
		if(src.chat_text?.vis_locs?.len)
			var/atom/movable/AM = src.chat_text.vis_locs[1]
			AM.vis_contents -= src.chat_text
		if(istype(src.loc, /turf))
			src.vis_contents += src.chat_text
		else
			var/atom/movable/A = src
			while(!isnull(A) && !istype(A.loc, /turf) && !istype(A.loc, /obj/disposalholder)) A = A.loc
			A?.vis_contents += src.chat_text

/mob/living/proc/empty_hands()
	. = 0

/mob/living/proc/update_lying()
	if (src.lying != src.lying_old)
		src.lying_old = src.lying
		src.animate_lying(src.lying)
		src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying

/mob/living/proc/animate_lying(lying)
	animate_rest(src, !lying)


/mob/living/attack_hand(mob/living/M, params, location, control)
	if (!M || !src) //Apparently M could be a meatcube and this causes HELLA runtimes.
		return

	if (!ticker)
		boutput(M, "You cannot interact with other people before the game has started.")
		return

	M.lastattacked = src

	attack_particle(M,src)

	if (M.a_intent != INTENT_HELP)
		actions.interrupt(src, INTERRUPT_ATTACKED)
		src.was_harmed(M, intent = M.a_intent)

		if (M.mob_flags & AT_GUNPOINT)
			for(var/obj/item/grab/gunpoint/G in M.grabbed_by)
				G.shoot()

	var/obj/item/clothing/gloves/gloves
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		gloves = H.gloves
	else
		gloves = null
		//Todo: get critter gloves if they have a slot. also clean this up in general...

	if (gloves?.material)
		gloves.material.triggerOnAttack(gloves, M, src)
	for (var/atom/A in src)
		if (A.material)
			A.material.triggerOnAttacked(A, M, src, gloves)

	M.viral_transmission(src,"Contact",1)

	switch(M.a_intent)
		if (INTENT_HELP)
			var/datum/limb/L = M.equipped_limb()
			if (!L)
				return
			L.help(src, M)

		if (INTENT_DISARM)
			if (M.is_mentally_dominated_by(src))
				boutput(M, "<span class='alert'>You cannot harm your master!</span>")
				return

			var/datum/limb/L = M.equipped_limb()
			if (!L)
				return
			L.disarm(src, M)

		if (INTENT_GRAB)
			if (M == src)
				M.grab_self()
				return
			if (src.parry_or_dodge(M))
				return
			var/datum/limb/L = M.equipped_limb()
			if (!L)
				return
			L.grab(src, M)
			message_admin_on_attack(M, "grabs")

		if (INTENT_HARM)
			if (M.is_mentally_dominated_by(src))
				boutput(M, "<span class='alert'>You cannot harm your master!</span>")
				return

			if (M != src)
				attack_twitch(M)
			M.violate_hippocratic_oath()
			message_admin_on_attack(M, "punches")
			/*
			// instant kills are kinda boring. itd be fun to make it do more damage or smth, but
			// as it is: no
			if (src.shrunk == 2)
				M.visible_message("<span class='alert'>[M] squashes [src] like a bug.</span>")
				src.gib()
				return
			*/
			if (gloves?.activeweapon)
				gloves.special_attack(src, M)
				return

			if (src.parry_or_dodge(M))
				return

			M.melee_attack(src)

	return

/mob/living/OnMove(source = null)
	var/turf/NewLoc = get_turf(src)
	var/steps = 1
	if (src.use_stamina)
		if (move_dir & (move_dir-1))
			steps *= DIAG_MOVE_DELAY_MULT

		if (world.time < src.next_move + SUSTAINED_RUN_GRACE)
			if(move_dir & last_move_dir)
				if (sustained_moves < SUSTAINED_RUN_REQ+1 && sustained_moves + steps >= SUSTAINED_RUN_REQ+1 && !HAS_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS))
					sprint_particle_small(src,get_step(NewLoc,turn(move_dir,180)),move_dir)
					playsound(src.loc, 'sound/effects/sprint_puff.ogg', 9, 1,extrarange = -25, pitch=2.5)
				sustained_moves += steps
			else
				if (sustained_moves >= SUSTAINED_RUN_REQ+1 && !isFlying && !HAS_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS))
					sprint_particle_small(src,get_step(NewLoc,turn(move_dir,180)),turn(move_dir,180))
					playsound(src.loc, 'sound/effects/sprint_puff.ogg', 9, 1,extrarange = -25, pitch=2.8)
				else if (move_dir == turn(last_move_dir,180) && !isFlying)
					if(!HAS_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS))
						sprint_particle_tiny(src,get_step(NewLoc,turn(move_dir,180)),turn(move_dir,180))
						playsound(src.loc, 'sound/effects/sprint_puff.ogg', 9, 1,extrarange = -25, pitch=2.9)
					if(src.bioHolder.HasEffect("magnets_pos") || src.bioHolder.HasEffect("magnets_neg"))
						var/datum/bioEffect/hidden/magnetic/src_effect = src.bioHolder.GetEffect("magnets_pos")
						if(src_effect == null) src_effect = src.bioHolder.GetEffect("magnets_neg")
						if(src_effect.update_charge(1))
							playsound(src, "sound/effects/sparks[rand(1,6)].ogg", 25, 1,extrarange = -25)


				sustained_moves = 0
		else
			sustained_moves = 0

	// Call movement traits
	if(src.traitHolder)
		for(var/id in src.traitHolder.moveTraits)
			var/datum/trait/O = src.traitHolder.moveTraits[id]
			O.onMove(src)

	..()

/mob/living/Move(var/turf/NewLoc, direct)
	. = ..()
	if (. && move_dir && !(direct & move_dir) && src.use_stamina)
		if (sustained_moves >= SUSTAINED_RUN_REQ+1 && !HAS_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS))
			sprint_particle_small(src,get_step(NewLoc,turn(move_dir,180)),turn(move_dir,180))
			playsound(src.loc, 'sound/effects/sprint_puff.ogg', 9, 1,extrarange = -25, pitch=2.8)
		sustained_moves = 0



/mob/living/movement_delay(var/atom/move_target = 0, running = 0)
	var/base_speed = BASE_SPEED
	if (sustained_moves >= SUSTAINED_RUN_REQ)
		base_speed = BASE_SPEED_SUSTAINED

	. += base_speed
	. += movement_delay_modifier

	var/multiplier = 1 // applied before running multiplier
	var/health_deficiency_adjustment = 0
	var/maximum_slowdown = 100 // applied before pulling checks
	var/pushpull_multiplier = 1
	var/aquatic_movement = 0
	var/space_movement = 0
	var/mob_pull_multiplier = 1

	var/datum/movement_modifier/modifier
	for(var/type_or_instance in src.movement_modifiers)
		if (ispath(type_or_instance))
			modifier = movement_modifier_instances[type_or_instance]
		else
			modifier = type_or_instance

		if (modifier.ask_proc) // if we have to call a proc
			var/list/r = modifier.modifiers(src, move_target, running)
			. += r[1]
			multiplier *= r[2]

		// collect modifiers from the datum
		. += modifier.additive_slowdown
		multiplier *= modifier.multiplicative_slowdown
		health_deficiency_adjustment += modifier.health_deficiency_adjustment
		pushpull_multiplier *= modifier.pushpull_multiplier
		aquatic_movement += modifier.aquatic_movement
		space_movement += modifier.space_movement
		mob_pull_multiplier *= modifier.mob_pull_multiplier

		if (modifier.maximum_slowdown < maximum_slowdown)
			maximum_slowdown = modifier.maximum_slowdown

	if (m_intent == "walk")
		. += WALK_DELAY_ADD

	if (src.nodamage)
		return .

	var/health_deficiency = 0
	if (src.max_health > 0)
		health_deficiency = ((src.max_health-src.health)/src.max_health)*100 + health_deficiency_adjustment // cogwerks // let's treat this like pain
	else
		health_deficiency = (src.max_health-src.health) + health_deficiency_adjustment

	if (health_deficiency >= 30)
		. += (health_deficiency / 35)

	.= src.special_movedelay_mod(.,space_movement,aquatic_movement)

	. = min(., maximum_slowdown)

	if (pushpull_multiplier != 0) // if we're not completely ignoring pushing/pulling
		if (src.pulling)
			if (istype(src.pulling, /atom/movable) && !(src.is_hulk() || (src.bioHolder && src.bioHolder.HasEffect("strong"))))
				var/atom/movable/A = src.pulling
				// hi grayshift sorry grayshift
				if (GET_DIST(src,A) > 0 && GET_DIST(move_target,A) > 0) //i think this is mbc dist stuff for if we're actually stepping away and pulling the thing or not?
					if(pull_slowing)
						. *= max(A.p_class, 1)
					else
						if(istype(A,/obj/machinery/nuclearbomb)) //can't speed off super fast with the nuke, it's heavy
							. *= max(A.p_class, 1)
						// else, ignore p_class*/
						else if(ismob(A))
							var/mob/M = A
							//if they're lying, pull em slower, unless you have anext_move gang and they are in your gang.
							if(M.lying)
								if (src.mind?.gang && (src.mind.gang == M.mind?.gang))
									. *= 1		//do nothing
								else
									. *= lerp(1, max(A.p_class, 1), mob_pull_multiplier)
						else if(istype(A, /obj/storage))
							// if the storage object contains mobs, use its p_class (updated within storage to reflect containing mobs or not)
							if (locate(/mob) in A.contents)
								. *= lerp(1, max(A.p_class, 1), mob_pull_multiplier)
			. = lerp(1, . , pushpull_multiplier)


		if (src.pushing)
			. *= lerp(1, max(src.pushing.p_class, 1), pushpull_multiplier)

		for (var/obj/item/grab/G in src.equipped_list())
			var/mob/M = G.affecting
			if (isnull(M))
				continue //ZeWaka: If we have a null affecting, ex. someone jumped in lava when we were grabbing them

			if (G.state == GRAB_PASSIVE)
				if (GET_DIST(src,M) > 0 && GET_DIST(move_target,M) > 0) //pasted into living.dm pull slow as well (consider merge somehow)
					if(ismob(M) && M.lying)
						. *= lerp(1, max(M.p_class, 1), pushpull_multiplier)
			else
				. *= lerp(1, max(M.p_class, 1), pushpull_multiplier)

	. *= multiplier

	if (next_step_delay)
		. += next_step_delay
		next_step_delay = 0

	if (running)

		var/runScaling = src.lying ? SPRINT_SCALING_LYING : SPRINT_SCALING
		if (src.hasStatus(list("staggered","blocking")))
			runScaling = max(runScaling, SPRINT_SCALING_STAGGER)
		var/minSpeed = (1.0- runScaling * base_speed) / (1 - runScaling) // ensures sprinting with 1.2 tally drops it to 0.75
		if (pulling) minSpeed = base_speed // not so fast, fucko
		. = min(., minSpeed + (. - minSpeed) * runScaling) // i don't know what I'm doing, help

	var/turf/T = get_turf(src)
	if (T?.turf_flags & CAN_BE_SPACE_SAMPLE)
		. = max(., base_speed)


//this lets subtypes of living alter their movement delay WITHIN that big proc above - not before or after (which would fuck up the numbers greatly)
//note : subtypes should not call this parent
/mob/living/proc/special_movedelay_mod(delay,space_movement,aquatic_movement)
	.= delay
	if (src.lying)
		. += 14


/mob/living/critter/keys_changed(keys, changed)
	..()
	if (changed & KEY_RUN)
		if (hud && !HAS_ATOM_PROPERTY(src, PROP_MOB_CANTSPRINT))
			src.hud.set_sprint(keys & KEY_RUN)

/mob/living/carbon/human/keys_changed(keys, changed)
	..()
	if (changed & KEY_RUN)
		if (hud && !HAS_ATOM_PROPERTY(src, PROP_MOB_CANTSPRINT))
			src.hud.set_sprint(keys & KEY_RUN)

/mob/living/proc/start_sprint()
	if (HAS_ATOM_PROPERTY(src, PROP_MOB_CANTSPRINT))
		return
	if (special_sprint && src.client)
		if (special_sprint & SPRINT_BAT)
			spell_batpoof(src, cloak = 0)
		if (special_sprint & SPRINT_FIRE)
			spell_firepoof(src)
		if (special_sprint & SPRINT_BAT_CLOAKED)
			spell_batpoof(src, cloak = 1)
		if (special_sprint & SPRINT_SNIPER)
			begin_sniping()
		if (special_sprint & SPRINT_DESIGNATOR)
			begin_designating()
	else if (src.use_stamina)
		if (!next_step_delay && world.time >= next_sprint_boost)
			if (!(HAS_ATOM_PROPERTY(src, PROP_MOB_CANTMOVE) || GET_COOLDOWN(src, "lying_bullet_dodge_cheese") || GET_COOLDOWN(src, "unlying_speed_cheesy")))
				//if (src.hasStatus("blocking"))
				//	for (var/obj/item/grab/block/G in src.equipped_list(check_for_magtractor = 0)) //instant break blocks when we start a sprint
				//		qdel(G)

				var/last = src.loc
				var/force_puff = world.time < src.next_move + 0.5 SECONDS //assume we are still in a movement mindset even if we didnt change tiles

				next_step_delay = max(src.next_move - world.time,0) //slows us on the following step by the amount of movement we just skipped over with our instant-step
				src.next_move = world.time
				attempt_move(src)
				next_sprint_boost = world.time + max(src.next_move - world.time,BASE_SPEED) * 2

				if ((src.loc != last || force_puff) && !HAS_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS)) //ugly check to prevent stationary sprint weirds
					sprint_particle(src, last)
					if (!isFlying)
						playsound(src.loc, 'sound/effects/sprint_puff.ogg', 29, 1,extrarange = -4)

// cogwerks - fix for soulguard and revive
/mob/living/proc/remove_ailments()
	if (src.ailments)
		for (var/datum/ailment_data/disease/D in src.ailments)
			src.cure_disease(D)
		for (var/datum/ailment_data/malady/M in src.ailments)
			src.cure_disease(M)
		for(var/datum/ailment_data/addiction/A in src.ailments)
			src.ailments -= A
		for (var/datum/ailment_data/parasite/P in src.ailments)
			src.cure_disease(P)

/mob/living/proc/was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
	SHOULD_CALL_PARENT(TRUE)
	.= 0

//left this here to standardize into living later
/mob/living/critter/was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
	if (src.ai)
		src.ai.was_harmed(weapon,M)
		if(src.is_hibernating)
			if (src.registered_area)
				src.registered_area.wake_critters(M)
			else
				src.wake_from_hibernation()
	..()

/mob/living/bullet_act(var/obj/projectile/P)
	log_shot(P,src)
	if (ismob(P.shooter))
		var/mob/living/M = P.shooter
		if (P.name != "energy bolt" && M?.mind)
			M.mind.violated_hippocratic_oath = 1

	if (src.nodamage) return 0
	if (src.spellshield)
		src.visible_message("<span class='alert'>[src]'s shield deflects the shot!</span>")
		return 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			if (P.proj_data.damage_type == D_KINETIC)
				src.visible_message("<span class='alert'>[src]'s shield deflects the shot!</span>")
				return 0
			S.active = 0
			S.icon_state = "shield0"

	if (!P.was_pointblank && HAS_ATOM_PROPERTY(src, PROP_MOB_REFLECTPROT))
		var/obj/item/equipped = src.equipped()
		var/obj/projectile/Q = shoot_reflected_to_sender(P, src)
		if (!Q)
			CRASH("Failed to initialize reflected projectile from original projectile [P] ([P.type]) hitting mob [src] (src.type)")
		else
			P.die()
			src.visible_message("<span class='alert'>[src] reflects [Q.name] with [equipped]!</span>")
			playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg',80, 0.1, 0, 3)
		return 0

	if (P?.proj_data?.is_magical  && src?.traitHolder?.hasTrait("training_chaplain"))
		src.visible_message("<span class='alert'>A divine light absorbs the magical projectile!</span>")
		playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, 1)
		P.die()
		return 0

	if(src.material) src.material.triggerOnBullet(src, src, P)
	for (var/atom/A in src)
		if (A.material)
			if(src.material) src.material.triggerOnBullet(A, src, P)

	if (!P.proj_data)
		return 0


	for (var/mob/V in by_cat[TR_CAT_NERVOUS_MOBS])
		if (!IN_RANGE(src,V, 6))
			continue
		if(prob(8) && src)
			if(src != V)
				V.emote("scream")
				V.changeStatus("stunned", 2 SECONDS)

// ahhhh fuck this im just making every shot be a chest shot for now -drsingh
	var/damage = 0
	var/stun = 0 //HEY this doesnt actually stun. its the number to reduce stamina. gosh.
	if (P.proj_data)  //ZeWaka: Fix for null.ks_ratio
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)
		stun = round((P.power*(1.0-P.proj_data.ks_ratio)), 1.0)
	var/armor_msg = ""
	var/rangedprot_base = get_ranged_protection() //will be 1 unless overridden
	if (P.proj_data) //Wire: Fix for: Cannot read null.damage_type
		var/rangedprot_mod = max(rangedprot_base*(1-P.proj_data.armor_ignored),1)

		if (rangedprot_mod > 1)
			armor_msg = ", but your armor softens the hit!"
		else if(rangedprot_base > 1)
			armor_msg = ", but [P] pierces through your armor!"

		switch(P.proj_data.damage_type)
			if (D_KINETIC)
				if (stun > 0)
					src.remove_stamina(min(round(stun/rangedprot_mod, 0.5) * 30, 125)) //thanks to the odd scaling i have to cap this.
					src.stamina_stun()

				src.TakeDamage("chest", (damage/rangedprot_mod), 0, 0, P.proj_data.hit_type)
				if (isalive(src))
					lastgasp()

			if (D_PIERCING)
				if (stun > 0)
					src.remove_stamina(min(round(stun/rangedprot_mod) * 30, 125)) //thanks to the odd scaling i have to cap this.
					src.stamina_stun()

				src.TakeDamage("chest", damage/rangedprot_mod, 0, 0, P.proj_data.hit_type)
				if (isalive(src))
					lastgasp()

			if (D_SLASHING)
				if (stun > 0)
					src.remove_stamina(min(round(stun/rangedprot_mod) * 30, 125)) //thanks to the odd scaling i have to cap this.
					src.stamina_stun()

				if (rangedprot_mod > 1)
					src.TakeDamage("chest", (damage/rangedprot_mod), 0, 0, P.proj_data.hit_type)
				else
					src.TakeDamage("chest", (damage*2), 0, 0, P.proj_data.hit_type)

			if (D_ENERGY)
				if (stun > 0)
					src.do_disorient(clamp(stun*4, P.proj_data.power*(1-P.proj_data.ks_ratio)*2, stun+80), weakened = stun*2, stunned = stun*2, disorient = min(stun,  80), remove_stamina_below_zero = 0)
					src.emote("twitch_v")// for the above, flooring stam based off the power of the datum is intentional

				if (isalive(src)) lastgasp()

				if (src.stuttering < stun)
					src.stuttering = stun
				src.TakeDamage("chest", 0, (damage/rangedprot_mod), 0, P.proj_data.hit_type)

			if (D_BURNING)
				if (stun > 0)
					src.remove_stamina(min(round(stun/rangedprot_mod) * 30, 125)) //thanks to the odd scaling i have to cap this.
					src.stamina_stun()

				if (src.is_heat_resistant())
					// fire resistance should probably not let you get hurt by welders
					src.visible_message("<span class='alert'><b>[src] seems unaffected by fire!</b></span>")
					return 0
				src.TakeDamage("chest", 0, (damage/rangedprot_mod), 0, P.proj_data.hit_type)
				src.update_burning(damage/rangedprot_mod)

			if (D_RADIOACTIVE)
				if (stun > 0)
					src.remove_stamina(min(round(stun/rangedprot_mod) * 30, 125)) //thanks to the odd scaling i have to cap this.
					src.stamina_stun()

				src.reagents?.add_reagent("radium", damage/4) //fuckit
				var/orig_val = GET_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS)
				APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "projectile", -5)
				if(GET_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS) != orig_val)
					SPAWN(30 SECONDS)
						REMOVE_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "projectile")

			if (D_TOXIC)
				if (stun > 0)
					src.remove_stamina(min(round(stun/rangedprot_mod) * 30, 125)) //thanks to the odd scaling i have to cap this.
					src.stamina_stun()

				if (!P.reagents)
					src.take_toxin_damage(damage)

	if (!P.proj_data.silentshot)
		src.visible_message("<span class='alert'>[src] is hit by the [P.name]!</span>", "<span class='alert'>You are hit by the [P.name][armor_msg]!</span>")

	var/mob/M = null
	if (ismob(P.shooter))
		M = P.shooter
		src.lastattacker = M
		src.lastattackertime = world.time
	src.was_harmed(M)

	return 1

/mob/living/attackby(obj/item/W, mob/M)
	var/oldbloss = get_brute_damage()
	var/oldfloss = get_burn_damage()
	..()
	var/newbloss = get_brute_damage()
	var/damage = ((newbloss - oldbloss) + (get_burn_damage() - oldfloss))
	if (reagents)
		reagents.physical_shock((newbloss - oldbloss) * 0.15)

	if ((damage > 0) || W.force)
		src.was_harmed(M, W)


/mob/living/shock(var/atom/origin, var/wattage, var/zone = "chest", var/stun_multiplier = 1, var/ignore_gloves = 0)
	if (!wattage)
		return 0
	if (check_target_immunity(src))
		return 0
	var/prot = 1

	var/mob/living/carbon/human/H = null //ughhh sort this out with proper inheritance later
	if (ishuman(src))
		H = src
		var/obj/item/clothing/gloves/G = H.gloves
		if (G && !ignore_gloves)
			prot = (G.hasProperty("conductivity") ? G.getProperty("conductivity") : 1)
		if (H.limbs.l_arm && !ignore_gloves)
			prot = min(prot,H.limbs.l_arm.siemens_coefficient)
		if (H.limbs.r_arm && !ignore_gloves)
			prot = min(prot,H.limbs.r_arm.siemens_coefficient)
		if (prot <= 0.29)
			return 0

	var/shock_damage = 0
	if (wattage > 7500)
		shock_damage = (max(rand(10,20), round(wattage * 0.00004)))*prot
	else if (wattage > 5000)
		shock_damage = 15 * prot
	else if (wattage > 2500)
		shock_damage = 5 * prot
	else
		shock_damage = 1 * prot

	if (H)
		for (var/uid in H.pathogens)
			var/datum/pathogen/P = H.pathogens[uid]
			shock_damage = P.onshocked(shock_damage, wattage)
			if (!shock_damage)
				return 0

	if (src.bioHolder.HasEffect("resist_electric_heal"))
		var/healing = 0
		healing = shock_damage / 3
		src.HealDamage("All", healing, healing)
		src.take_toxin_damage(0 - healing)
		boutput(src, "<span class='notice'>You absorb the electrical shock, healing your body!</span>")
		return 0
	else if (src.bioHolder.HasEffect("resist_electric"))
		boutput(src, "<span class='notice'>You feel electricity course through you harmlessly!</span>")
		return 0
	src.setStatus("defibbed", sqrt(shock_damage) SECONDS)
	switch(shock_damage)
		if (0 to 25)
			playsound(src.loc, 'sound/effects/electric_shock.ogg', 50, 1)
		if (26 to 59)
			playsound(src.loc, 'sound/effects/elec_bzzz.ogg', 50, 1)
		if (60 to 99)
			playsound(src.loc, 'sound/effects/elec_bigzap.ogg', 40, 1)  // begin the fun arcflash
			boutput(src, "<span class='alert'><b>[origin] discharges a violent arc of electricity!</b></span>")
			src.apply_flash(60, 0, 10)
			if (H)
				var/hair_type = pick(/datum/customization_style/hair/gimmick/xcom,/datum/customization_style/hair/gimmick/bart,/datum/customization_style/hair/gimmick/zapped)
				H.bioHolder.mobAppearance.customization_first = new hair_type
				H.set_face_icon_dirty()
		if (100 to INFINITY)  // cogwerks - here are the big fuckin murderflashes
			playsound(src.loc, 'sound/effects/elec_bigzap.ogg', 40, 1)
			playsound(src.loc, "explosion", 50, 1)
			src.flash(60)
			if (H)
				var/hair_type = pick(/datum/customization_style/hair/gimmick/xcom,/datum/customization_style/hair/gimmick/bart,/datum/customization_style/hair/gimmick/zapped)
				H.bioHolder.mobAppearance.customization_first = new hair_type
				H.set_face_icon_dirty()

			var/turf/T = get_turf(src)
			if (T)
				T.hotspot_expose(5000,125)
				explosion(origin, T, -1,-1,1,2)
			if (prob(20))
				boutput(src, "<span class='alert'><b>[origin] vaporizes you with a lethal arc of electricity!</b></span>")
				if (H?.shoes)
					H.drop_from_slot(H.shoes)
				make_cleanable(/obj/decal/cleanable/ash,src.loc)
				SPAWN(1 DECI SECOND)
					src.elecgib()
			else
				boutput(src, "<span class='alert'><b>[origin] blasts you with an arc flash!</b></span>")
				if (H?.shoes)
					H.drop_from_slot(H.shoes)
				var/atom/targetTurf = get_edge_target_turf(src, get_dir(src, get_step_away(src, origin)))
				src.throw_at(targetTurf, 200, 4)
	shock_cyberheart(shock_damage)
	TakeDamage(zone, 0, shock_damage, 0, DAMAGE_BURN)
	boutput(src, "<span class='alert'><B>You feel a [wattage > 7500 ? "powerful" : "slight"] shock course through your body!</B></span>")
	src.unlock_medal("HIGH VOLTAGE", 1)
	src.Virus_ShockCure(min(wattage / 500, 100))

	var/stun = (min((shock_damage/5), 12) * stun_multiplier)* 10
	src.do_disorient(100 * stun_multiplier + stun, weakened = stun, stunned = stun, disorient = stun + 40 * stun_multiplier, remove_stamina_below_zero = 1)

	return shock_damage

/mob/living/hitby(atom/movable/AM, datum/thrown_thing/thr)
	. = 'sound/impact_sounds/Generic_Hit_2.ogg'
	actions.interrupt(src, INTERRUPT_ATTACKED)
	if (src.can_bleed && isitem(AM))
		var/obj/item/I = AM
		if ((I.hit_type == DAMAGE_STAB && prob(20)) || (I.hit_type == DAMAGE_CUT && prob(40)))
			take_bleeding_damage(src, null, I.throwforce * 0.5, I.hit_type)
			. = 'sound/impact_sounds/Flesh_Stab_3.ogg'
			if(thr?.user)
				src.was_harmed(thr.user, AM)
	..()

/mob/living/proc/check_singing_prefix(var/message)
	if (isalive(src))
		if (dd_hasprefix(message, singing_prefix)) // check for "%"
			src.singing = NORMAL_SINGING
			return copytext(message, 2)
	src.singing = 0
	. =  message

// can stumble or flip while drunk
/mob/living/proc/can_drunk_act()
	if (!src.canmove || !isturf(src.loc))
		return FALSE
	if (length(src.grabbed_by))
		for (var/obj/item/grab/G in src.grabbed_by)
			if (istype(G, /obj/item/grab/block))
				continue
			if (G.state > GRAB_PASSIVE)
				return FALSE
	return !src.lying && !((length(src.grabbed_by) || src.pulled_by) && src.hasStatus("handcuffed"))

/mob/living/take_radiation_dose(Sv,internal=FALSE)
	if(!src.lifeprocesses[/datum/lifeprocess/radiation]) //if we don't have the radiation lifeprocess, we're immune, so don't send any messages or burn us
		return
	var/actual_dose = ..()
	if(actual_dose > 0.2 && !internal)
		src.TakeDamage("All",0,20*clamp(actual_dose/4.0, 0, 1)) //a 2Sv dose all at once will badly burn you
		if(!ON_COOLDOWN(src,"radiation_feel_message_burn",5 SECONDS))
			src.show_message("<span class='alert'>[pick("Your skin blisters!","It hurts!","Oh god, it burns!")]</span>") //definitely get a message for that
	else if((!src.radiation_dose || prob(10)) && !ON_COOLDOWN(src,"radiation_feel_message",10 SECONDS))
		src.show_message("<span class='alert'>[pick("Your skin prickles.","You taste iron.","You smell ozone.","You feel a wave of pins and needles.","Is it hot in here?")]</span>")
