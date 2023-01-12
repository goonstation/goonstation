// Observer

/mob/dead/observer
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	plane = PLANE_NOSHADOW_ABOVE
	event_handler_flags =  IMMUNE_MANTA_PUSH | IMMUNE_SINGULARITY | USE_FLUID_ENTER | MOVE_NOCLIP
	density = 0
	canmove = 1
	blinded = 0
	anchored = 1	//  don't get pushed around
	var/observe_round = 0
	var/health_shown = 0
	var/arrest_shown = 0
	var/delete_on_logout = 1
	var/delete_on_logout_reset = 1
	var/obj/item/clothing/head/wig/wig = null
	var/in_point_mode = 0
	var/datum/hud/ghost_observer/hud
	var/auto_tgui_open = TRUE

	mob_flags = MOB_HEARS_ALL

/mob/dead/observer/disposing()
	corpse = null
	if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
		src.abilityHolder:remove_all_abilities()
		src.abilityHolder.dispose()
		src.abilityHolder = null
	if (hud)
		hud.dispose()
		hud = null

	..()

/mob/dead/observer/proc/toggle_point_mode(var/force_off = FALSE)
	if (force_off)
		src.in_point_mode = FALSE
	else
		src.in_point_mode = !(src.in_point_mode)
	src.update_cursor()

/mob/dead/observer/hotkey(name)
	switch (name)
		if ("togglepoint")
			src.toggle_point_mode()
		else
			. = ..()
/mob/dead/observer/update_cursor()
	..()
	if (src.client)
		if (src.in_point_mode || src.client.check_key(KEY_POINT))
			src.set_cursor('icons/cursors/point.dmi')
		else if (src.client.check_key(KEY_EXAMINE))
			src.set_cursor('icons/cursors/examine.dmi')
/mob/dead/observer/click(atom/target, params, location, control)

	if (src.in_point_mode || (src.client && src.client.check_key(KEY_POINT)))
		src.point_at(target, text2num(params["icon-x"]), text2num(params["icon-y"]))
		if (src.in_point_mode)
			src.toggle_point_mode()
		return
	if (ismob(target) && !src.client.check_key(KEY_EXAMINE))
		src.insert_observer(target)
		return

	return ..()

/mob/dead/observer/Login()
	..()
	if(src.client)
		src.updateOverlaysClient(src.client)
		src.updateButtons()
		src.hud.update_ability_hotbar()
	// ok so in logout we set your ghost to 101 invisibility.
	// in login we set it back to whatever it was. so you keep your ghost.
	// is there a better way to do this? probably. i dont care.
	// heres a thought: maybe ghostize() could look for your ghost or smth
	// and put you in it instead of just making a new one.
	// idk this codebase is an eldritch horror and i dont wanna try rn
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "clientless")


/mob/dead/observer/point_at(atom/target, var/pixel_x, var/pixel_y)
	if (!isturf(src.loc))
		return

	if (istype(target, /obj/decal/point))
		return


	src.visible_message("<span class='game deadsay'><span class='prefix'>DEAD:</span><b>[src]</b> points to [target].</span>")
	var/point_invisibility = src.invisibility
#ifdef HALLOWEEN
	if(prob(20))
		point_invisibility = INVIS_NONE
#endif
	if (!ON_COOLDOWN(src, "point", 0.5 SECONDS))
		make_point(target, pixel_x=pixel_x, pixel_y=pixel_y, color="#5c00e6", invisibility=point_invisibility, pointer=src)


#define GHOST_LUM	1		// ghost luminosity

/mob/dead/observer/proc/apply_looks_of(var/client/C)
	if (!C || !C.preferences)
		return
	var/datum/preferences/P = C.preferences

	if (!P.AH)
		return

	var/cust_one_state = P.AH.customization_first.id
	var/cust_two_state = P.AH.customization_second.id
	var/cust_three_state = P.AH.customization_third.id

	var/image/hair = image('icons/mob/human_hair.dmi', cust_one_state)
	hair.color = P.AH.customization_first_color
	hair.alpha = 192
	overlays += hair

	wig = new
	wig.mat_changename = 0
	var/datum/material/wigmat = getMaterial("ectofibre")
	wigmat.color = P.AH.customization_first_color
	wig.setMaterial(wigmat)
	wig.name = "ectofibre [name]'s hair"
	wig.icon = 'icons/mob/human_hair.dmi'
	wig.icon_state = cust_one_state
	wig.color = P.AH.customization_first_color
	wig.wear_image_icon = 'icons/mob/human_hair.dmi'
	wig.wear_image = image(wig.wear_image_icon, wig.icon_state)
	wig.wear_image.color = P.AH.customization_first_color


	var/image/beard = image('icons/mob/human_hair.dmi', cust_two_state)
	beard.color = P.AH.customization_second_color
	beard.alpha = 192
	overlays += beard

	var/image/detail = image('icons/mob/human_hair.dmi', cust_three_state)
	detail.color = P.AH.customization_third_color
	detail.alpha = 192
	overlays += detail

	if (!src.bioHolder) //For critter spawns
		var/datum/bioHolder/newbio = new/datum/bioHolder(src)
		newbio.mobAppearance.customization_first_color = hair.color
		newbio.mobAppearance.e_color = P.AH.e_color
		src.bioHolder = newbio


//#ifdef HALLOWEEN
/mob/dead/observer/Cross(atom/movable/mover)
	if (src.icon_state != "doubleghost" && istype(mover, /obj/projectile))
		var/obj/projectile/proj = mover
		if (proj.proj_data?.hits_ghosts)
			return 0
#ifdef HALLOWEEN
	if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
		var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
		if (GH.spooking)
			GH.stop_spooking()
#endif

	return 1

/mob/dead/observer/bullet_act(var/obj/projectile/P)
	if (src.icon_state == "doubleghost")
		return

#ifdef HALLOWEEN
	if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
		var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
		if (GH.spooking)
			GH.stop_spooking()
			//animate(src, )	explode?
			src.visible_message("<span class='alert'><b>[src] is busted! Maybe?!</b></span>","<span class='alert'>You are knocked out of your powerful state and feel dead again!</span>")
			log_shot(P,src)
			return
#endif

	src.icon_state = "doubleghost"
	src.visible_message("<span class='alert'><b>[src] is busted!</b></span>","<span class='alert'>You are demateralized into a state of further death!</span>")


	if (wig)
		wig.set_loc(src.loc)
	new /obj/item/reagent_containers/food/snacks/ectoplasm(get_turf(src))
	overlays.len = 0
	log_shot(P,src)


//#endif

/mob/dead/observer/Life(datum/controller/process/mobs/parent)
#ifdef HALLOWEEN
	if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
		var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
		GH.change_points(1)
		GH.points_since_last_tick = 0
		// src.abilityHolder.getAbility(/datum/targetable/ghost_observer/spooktober_hud).Stat()
#endif
	if (..(parent))
		return 1
	if (src.client && src.client.holder) //ov1
		// overlays
		//src.updateOverlaysClient(src.client)
		src.antagonist_overlay_refresh(0, 0) // Observer Life() only runs for admin ghosts (Convair880).

#ifdef TWITCH_BOT_ALLOWED
	if (IS_TWITCH_CONTROLLED(src))
		var/list/candidates = list()
		for(var/mob/M in mobs)
			if (M.client && isliving(M) && !M.unobservable)
				candidates += M
		if (candidates.len)
			SPAWN(5 SECONDS)
				src.insert_observer(pick(candidates))
#endif

	return

/mob/dead/observer/proc/updateButtons()
	if (abilityHolder)
		abilityHolder.updateButtons()
	else
		boutput(src, "ability buttons are broken call 1-800-CODER!!!")

/mob/dead/observer/New(mob/corpse)
	. = ..()
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, ghost_invisibility)
	APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
	src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	src.see_invisible = INVIS_SPOOKY
	src.see_in_dark = SEE_DARK_FULL
	animate_bumble(src) // floaty ghosts  c:
	src.verbs += /mob/dead/observer/proc/toggle_tgui_auto_open
	if (ismob(corpse))
		src.corpse = corpse
		src.set_loc(get_turf(corpse))
		src.real_name = corpse.real_name
		if (corpse.bioHolder?.mobAppearance)
			src.bioHolder.mobAppearance.CopyOther(corpse.bioHolder.mobAppearance)
		src.gender = src.bioHolder.mobAppearance.gender
		src.UpdateName()
		src.verbs += /mob/dead/observer/proc/reenter_corpse
	else
		stack_trace("Observer New() called with non-mob thing [identify_object(corpse)] (\ref [corpse]) as a corpse.")

	hud = new(src)
	src.attach_hud(hud)

	if (!abilityHolder)
		abilityHolder = new /datum/abilityHolder/ghost_observer(src)
		abilityHolder.owner = src

	updateButtons()
	if (render_special)
		render_special.set_centerlight_icon("nightvision", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))

	SPAWN(0.5 SECONDS)
		if (src.mind && istype(src.mind.purchased_bank_item, /datum/bank_purchaseable/golden_ghost))
			src.setMaterial(getMaterial("gold"))
//#ifdef HALLOWEEN
//	src.sd_SetLuminosity(GHOST_LUM) // comment all of these back out after hallowe'en
//#endif

/mob/living/verb/become_ghost()
	set src = usr
	set name = "Ghost"
	set category = "Commands"
	set desc = "Leave your lifeless body behind and become a ghost."

	if(!isdead(src))
		if (src.hibernating == 1)
			var/confirm = tgui_alert(src, "Are you sure you want to ghost? You won't be able to exit cryogenic storage, and will be an observer the rest of the round.", "Observe?", list("Yes", "No"))
			if(confirm == "Yes")
				respawn_controller.subscribeNewRespawnee(src.ckey)
				src.mind?.dnr = 1
				src.ghostize()
				qdel(src)
			else
				return
		else if(prob(5))
			src.show_text("You strain really hard. I mean, like, really, REALLY hard but you still can't become a ghost!", "blue")
		else
			src.show_text("You're not dead yet!", "red")
		return
	src.ghostize()



/mob/proc/ghostize()
	RETURN_TYPE(/mob/dead)
	// do nothing for NPCs
	if(src.key || src.client)

		if(src.mind && src.mind.damned) // Wow so much sin. Off to hell with you.
			INVOKE_ASYNC(src, /mob.proc/hell_respawn, src.mind)
			return null

		// step 1: either find a ghost or make one
		var/mob/dead/our_ghost = null

		// if we already have a ghost, just go get that instead
		if (src.ghost && !src.ghost.disposed)
			our_ghost = src.ghost
		// no existing ghost, make a new one
		else
			our_ghost = new/mob/dead/observer(src)
			our_ghost.bioHolder.CopyOther(src.bioHolder, copyActiveEffects = 0)
			if(!src.mouse_opacity)
				our_ghost.mouse_opacity = 0
				our_ghost.alpha = 0
			src.ghost = our_ghost

		var/turf/T = get_turf(src)
		if (T && (!isghostrestrictedz(T.z) || restricted_z_allowed(src, T) || (src.client?.holder && !src.client.holder.tempmin)))
			our_ghost.set_loc(T)
		else
			our_ghost.set_loc(pick_landmark(LANDMARK_OBSERVER, locate(150, 150, 1)))

		// step 2: make sure they actually make it to the ghost
		if (src.mind)
			src.mind.transfer_to(our_ghost)
		else
			our_ghost.key = src.key //they're probably logged out, set key so they're in the ghost when they get back

		if(istype(get_area(src),/area/afterlife))
			qdel(src)

		respawn_controller.subscribeNewRespawnee(our_ghost.ckey)
		var/datum/respawnee/respawnee = global.respawn_controller.respawnees[our_ghost.ckey]
		if(istype(respawnee) && istype(our_ghost, /mob/dead/observer)) // target observers don't have huds
			respawnee.update_time_display()
			//var/mob/dead/observer/our_observer = our_ghost
			//our_observer.hud?.get_join_other() // remind them of the other server

		our_ghost.update_item_abilities()
		return our_ghost
	return null

/mob/dead/observer/movement_delay()
#ifdef HALLOWEEN
	if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
		var/datum/abilityHolder/ghost_observer/GAH = src.abilityHolder
		if (GAH.spooking)
			return movement_delay_modifier + 1.5

	if (src?.client.check_key(KEY_RUN))
		return 0.4 + movement_delay_modifier
	else
		return 0.75 + movement_delay_modifier

#else
	if (src?.client.check_key(KEY_RUN))
		return 0.4 + movement_delay_modifier
	else
		return 0.75 + movement_delay_modifier

#endif

/mob/dead/observer/build_keybind_styles(client/C)
	..()
	C.apply_keybind("human")

	if (!C.preferences.use_wasd)
		C.apply_keybind("human_arrow")

	if (C.preferences.use_azerty)
		C.apply_keybind("human_azerty")

	if (C.tg_controls)
		C.apply_keybind("human_tg")
		if (C.preferences.use_azerty)
			C.apply_keybind("human_tg_azerty")

/mob/dead/observer/is_spacefaring()
	return 1

/mob/living/carbon/human/ghostize()
	var/mob/dead/observer/O = ..()
	if (!O)
		return null

	. = O

	if (glasses)
		var/image/glass = image(glasses.wear_image_icon, glasses.icon_state)
		glass.color = glasses.color
		glass.alpha = glasses.alpha * 0.75
		O.overlays += glass

	if (src.bioHolder) //Not necessary for ghost appearance, but this will be useful if the ghost decides to respawn as critter.
		var/image/hair = image('icons/mob/human_hair.dmi', src.bioHolder.mobAppearance.customization_first.id)
		hair.color = src.bioHolder.mobAppearance.customization_first_color
		hair.alpha = 192
		O.overlays += hair

		var/image/beard = image('icons/mob/human_hair.dmi', src.bioHolder.mobAppearance.customization_second.id)
		beard.color = src.bioHolder.mobAppearance.customization_second_color
		beard.alpha = 192
		O.overlays += beard

		var/image/detail = image('icons/mob/human_hair.dmi', src.bioHolder.mobAppearance.customization_third.id)
		detail.color = src.bioHolder.mobAppearance.customization_third_color
		detail.alpha = 192
		O.overlays += detail

		O.wig = new
		O.wig.mat_changename = 0
		var/datum/material/wigmat = getMaterial("ectofibre")
		wigmat.color = src.bioHolder.mobAppearance.customization_first_color
		O.wig.setMaterial(wigmat)
		O.wig.name = "[O.name]'s hair"
		O.wig.icon = 'icons/mob/human_hair.dmi'
		O.wig.icon_state = src.bioHolder.mobAppearance.customization_first.id
		O.wig.color = src.bioHolder.mobAppearance.customization_first_color
		O.wig.wear_image_icon = 'icons/mob/human_hair.dmi'
		O.wig.wear_image = image(O.wig.wear_image_icon, O.wig.icon_state)
		O.wig.wear_image.color = src.bioHolder.mobAppearance.customization_first_color


	return O

/mob/living/silicon/robot/ghostize()
	var/mob/dead/observer/O = ..()
	if (!O)
		return null

	O.icon_state = "borghost"
	return O

/mob/dead/observer/verb/show_health()
	set category = "Ghost"
	set name = "Toggle Health"
	if (!health_shown)
		health_shown = 1
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(src)
		boutput(src, "Health status toggled on.")
	else
		health_shown = 0
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(src)
		boutput(src, "Health status toggled off.")

/mob/dead/observer/verb/show_arrest()
	set category = "Ghost"
	set name = "Toggle Arrest Status"
	if (!arrest_shown)
		arrest_shown = 1
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(src)
		boutput(src, "Arrest status toggled on.")
	else
		arrest_shown = 0
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(src)
		boutput(src, "Arrest status toggled off.")

/mob/dead/observer/verb/ai_laws()
	set name = "AI Laws"
	set desc = "Displays the current AI laws. You must have DNR on to use this."
	set category = "Ghost"

	if(!mind || !mind.dnr)
		boutput( usr, "<span class='alert'>You must enable DNR to use this.</span>" )
		return

	if(!ticker || !ticker.ai_law_rack_manager)
		boutput( src, "Abort abort abort! No laws! No laws!!" )
		return

	boutput( src, ticker.ai_law_rack_manager.format_for_logs(round_end = TRUE) )


/mob/dead/observer/Logout()
	..()

	if(last_client)
		if(health_shown)
			health_shown = 0
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(src)
		if(arrest_shown)
			arrest_shown = 0
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(src)


	if(!src.key && delete_on_logout)
		//qdel(src)
		// so here's a fun thing im gonna do: ghosts dont go away now.
		// theres too much shit that relies on ghosts staying aroudn post-qdel.
		// and quite frankly fuck fixing all of that horse shit right now.
		// (personally i think transfer_to should be changed to handle
		// "this is temporary, keep the old mob" or "this is perma, nuke the old one"
		// or something, or even the process doing the switching)
		// but that's way too much effort to fix and i do not feel like debugging
		// 2000 different "use after free" issues.
		// so. your ghost doesnt go away. it just, uh. it takes a break for a while.
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "clientless", INVIS_ALWAYS)
	return

/mob/dead/observer/Move(NewLoc, direct)
	if(!canmove) return

	var/turf/NewTurf = get_turf(NewLoc)
	if (NewLoc && isghostrestrictedz(NewTurf.z) && !restricted_z_allowed(src, NewTurf) && !(src.client && src.client.holder && !src.client.holder.tempmin))
		var/OS = pick_landmark(LANDMARK_OBSERVER, locate(150, 150, 1))
		src.set_loc(OS)
		OnMove()
		return

	. = ..()

/mob/dead/observer/mouse_drop(atom/A)
	if (usr != src || isnull(A)) return
	if (ismob(A))
		var/mob/M = A
		if (!M.unobservable || isadmin(src))
			if (isadmin(src) || (!isadmin(src) && !isadminghost(M)) )
				src.insert_observer(A)
				return
	if (!istype(A,/turf))
		src.Move(get_turf(A.loc))
		return
	src.Move(A)

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/proc/toggle_tgui_auto_open()
	set category = "Ghost"
	set name = "Toggle TGUI auto-observing"
	if(src.auto_tgui_open)
		boutput(src, "No longer auto-opening TGUI windows of observed mobs.")
		src.auto_tgui_open = FALSE
	else
		boutput(src, "Observed mob's TGUI windows will now auto-open")
		src.auto_tgui_open = TRUE

/mob/dead/observer/proc/reenter_corpse()
	set category = null
	set name = "Re-enter Corpse"
	if(!corpse || corpse.disposed)
		tgui_alert(src, "You don't have a corpse! If you're very sure you do, and this seems wrong, make a bug report!", "No corpse")
		return
	if(src.client && src.client.holder && src.client.holder.state == 2)
		var/rank = src.client.holder.rank
		src.client.clear_admin_verbs()
		src.client.holder.state = 1
		src.client.update_admins(rank)
	if (src.mind)
		src.mind.transfer_to(corpse)
	qdel(src)

/mob/dead/observer/verb/dead_tele()
	set category = null
	set name = "Teleport"
	set desc= "Teleport"
	if((!isdead(usr)) || !isobserver(usr))
		boutput(usr, "Not when you're not dead!")
		return
	var/A
	var/list/tele_areas = get_teleareas()
	A = tgui_input_list(src, "Area to jump to", "Jump", tele_areas)
	if (!A)
		// aaaaaaaaaaaaaaaaaaaagggggggggggg
		return
	var/area/thearea = get_telearea(A)
	var/list/L = list()
	if (!istype(thearea))
		return

	for(var/turf/T in get_area_turfs(thearea.type))
		if (isghostrestrictedz(T.z)) //fffffuckk you
			continue
		L+=T

	if (length(L)) //ZeWaka: Fix for pick() from empty list
		usr.set_loc(pick(L))
		OnMove()
	else
		boutput(usr, "Couldn't find anywhere in that area to go to!")

/mob/dead/observer/say_understands(var/other)
	return 1

/* //dont need this anymores
/mob/dead/observer/verb/toggle_wide()
	set name = "Toggle Widescreen"
	set category = "Ghost"

	src.client.set_widescreen(!src.client.widescreen)
*/

//Commented out, not sure if this is safe for the average player (might cause lags?)
/*
/mob/dead/observer/verb/set_view()
	set name = "Set View Size"
	//set category = "Ghost"
	// ooooo its a secret, oooooo!!

	if(!mind || !mind.dnr)
		boutput( usr, "<span class='alert'>You must enable DNR to use this.</span>" )
		return

	var/x = input("Enter view width in tiles: (Capped at 59)", "Width", 15)
	var/y = input("Enter view height in tiles: (Capped at 30)", "Height", 15)
	src.client.set_view_size(x,y)
	//We don't need to worry about resetting view size when the player is revived or somesuch. The widescreen funcs will do that for us.
*/

/mob/dead/observer/verb/toggle_lighting()
	set name = "Toggle Lighting"
	set category = null

	var/atom/plane = client.get_plane(PLANE_LIGHTING)
	if (plane)
		switch(plane.alpha)
			if(255)
				render_special.set_centerlight_icon("")
				plane.alpha = 254 // I'm sorry
			if(254)
				plane.alpha = 0
			if(0)
				plane.alpha = 255
				render_special.set_centerlight_icon("nightvision", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))
	else
		boutput( usr, "Well, I want to, but you don't have any lights to fix!" )

/mob/dead/observer/verb/observe()
	set name = "Observe"
	set category = null

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	for (var/client/C in clients)
		LAGCHECK(LAG_LOW)
		// not sure how this could happen, but be safe about it
		if (!C?.mob)
			continue
		var/mob/M = C.mob
		// remove some types you cannot observe
		if (!isliving(M) && !iswraith(M) && !isAI(M))
			continue
		// admins aren't observable unless they're in player mode
		if (C.holder && !C.player_mode)
			continue
		// remove any secret mobs that someone is controlling
		if (M.unobservable)
			continue
		// add to list
		var/name = M.name
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if (M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if (isliving(M) && isdead(M) && !isAI(M))
			name += " \[dead\]"
		creatures[name] = M

	var/eye_name = null
	sortList(creatures, /proc/cmp_text_asc)
	eye_name = tgui_input_list(src, "Please, select a target!", "Observe", creatures)

	if (!eye_name)
		return

	insert_observer(creatures[eye_name])


/mob/dead/observer/verb/observe_object()
	set name = "Observe Objects"
	set category = "Ghost"

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	// Same thing you could do with the old auth disk. The bomb is equally important
	// and should appear at the top of any unsorted list  (Convair880).
	if (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
		var/datum/game_mode/nuclear/N = ticker.mode
		if (N.the_bomb && istype(N.the_bomb, /obj/machinery/nuclearbomb/))
			var/name = "Nuclear bomb"
			if (name in names)
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = N.the_bomb


	if (ticker?.mode && istype(ticker.mode, /datum/game_mode/football))
		var/datum/game_mode/football/F = ticker.mode
		if (F.the_football && istype(F.the_football, /obj/item/football/the_big_one))
			var/name = "THE FOOTBALL"
			if (name in names)
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = F.the_football


	for_by_tcl(O, /obj/observable)
		LAGCHECK(LAG_LOW)
		var/name = O.name
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = O

	for_by_tcl(GB, /obj/item/ghostboard)
		LAGCHECK(LAG_LOW)
		var/name = "Ouija board"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = GB

	for_by_tcl(G, /obj/item/gnomechompski)
		var/name = "Gnome Chompski"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = G

	for_by_tcl(CR, /obj/cruiser_camera_dummy)
		var/name = CR.name
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = CR

	for_by_tcl(L, /obj/item/reagent_containers/food/snacks/prison_loaf)
		var/name = L.name
		if (name != "strangelet loaf")
			continue
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = L

	for (var/obj/machinery/bot/B in machine_registry[MACHINES_BOTS])
		LAGCHECK(LAG_LOW)
		if (isghostrestrictedz(B.z)) continue
		var/name = "*[B.name]"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = B


	for(var/name in creatures)
		var/obj/O = creatures[name]
		if(!istype(O))
			creatures -= name
		else
			// let people observe these regardless of where they are. who cares
			// there's probably a way to do this better (some bots have no-camera mode for example)
			// which would work but someone else can fix it later. jhon madden
			if (!istype(O, /obj/machinery/nuclearbomb) && !istype(O, /obj/item/football/the_big_one))
				var/turf/T = get_turf(O)
				if(!T || isghostrestrictedz(T.z))
					creatures -= name

	var/eye_name = null
	sortList(creatures, /proc/cmp_text_asc)
	eye_name = tgui_input_list(src, "Please, select a target!", "Observe", creatures)

	if (!eye_name)
		return

	insert_observer(creatures[eye_name])

mob/dead/observer/proc/insert_observer(var/atom/target)
	var/mob/dead/target_observer/newobs = new /mob/dead/target_observer
	src.set_loc(newobs)
	newobs.attach_hud(hud)
	newobs.name = src.name
	newobs.real_name = src.real_name
	newobs.corpse = src.corpse
	newobs.ghost = src
	newobs.set_observe_target(target)
	delete_on_logout_reset = delete_on_logout
	delete_on_logout = 0
	if (target?.invisibility)
		newobs.see_invisible = target.invisibility
	if (src.corpse)
		corpse.ghost = newobs
	if (src.mind)
		mind.transfer_to(newobs)
	else if (src.client) //Wire: Fix for Cannot modify null.mob.
		src.client.mob = newobs

mob/dead/observer/proc/insert_slasher_observer(var/atom/target) //aaaaaa i had to create a new proc aaaaaa
	var/mob/dead/target_observer/slasher_ghost/newobs = new /mob/dead/target_observer/slasher_ghost
	newobs.attach_hud(hud)
	newobs.set_observe_target(target)
	newobs.name = src.name
	newobs.real_name = src.real_name
	newobs.corpse = src.corpse
	newobs.ghost = src
	delete_on_logout_reset = delete_on_logout
	delete_on_logout = 0
	if (target?.invisibility)
		newobs.see_invisible = target.invisibility
	if (src.corpse)
		corpse.ghost = newobs
	if (src.mind)
		mind.transfer_to(newobs)
	else if (src.client)
		src.client.mob = newobs
	set_loc(newobs)
	return newobs
