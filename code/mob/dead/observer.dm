// Observer

#define GHOST_HAIR_ALPHA 192

/mob/dead/observer
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	plane = PLANE_NOSHADOW_ABOVE_NOWARP
	event_handler_flags =  IMMUNE_MANTA_PUSH | IMMUNE_SINGULARITY | USE_FLUID_ENTER | MOVE_NOCLIP | IMMUNE_TRENCH_WARP
	density = FALSE
	canmove = TRUE
	blinded = FALSE
	anchored = ANCHORED	//  don't get pushed around
	var/doubleghost = FALSE //! When a ghost gets busted they become a ghost of a ghost and this var is true
	var/observe_round = FALSE
	var/health_shown = FALSE
	var/arrest_shown = FALSE
	var/delete_on_logout = TRUE
	var/delete_on_logout_reset = TRUE
	var/obj/item/clothing/head/wig/wig = null
	var/datum/hud/ghost_observer/hud
	var/auto_tgui_open = TRUE
	/// Observer menu TGUI datum. Can be null.
	var/datum/observe_menu/observe_menu = null
	var/last_words = null //! Last words of the mob before they died
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

/mob/dead/observer/update_cursor()
	..()
	if (src.client)
		if (src.client.check_key(KEY_POINT))
			src.set_cursor('icons/cursors/point.dmi')
		else if (src.client.check_key(KEY_EXAMINE))
			src.set_cursor('icons/cursors/examine.dmi')

/mob/dead/observer/click(atom/target, params, location, control)
	// If we have an ability active, skip all this and go straight to parent call.
	if (!src.targeting_ability)
		if (src.client && src.client.check_key(KEY_POINT))
			src.point_at(target, text2num(params["icon-x"]), text2num(params["icon-y"]))
			return
		if (ismob(target) && !src.client.check_key(KEY_EXAMINE) && !istype(target, /mob/dead))
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

	src.visible_message(SPAN_DEADSAY("[SPAN_PREFIX("DEAD:")] <b>[src]</b> points to [target]."))

	var/point_invisibility = src.invisibility
#ifdef HALLOWEEN
	if(prob(20))
		point_invisibility = INVIS_NONE
#endif
	if (!ON_COOLDOWN(src, "point", 0.5 SECONDS))
		..()
		make_point(target, pixel_x=pixel_x, pixel_y=pixel_y, color="#5c00e6", invisibility=point_invisibility, pointer=src)


#define GHOST_LUM	1		// ghost luminosity

/mob/dead/observer/proc/apply_looks_of(var/client/C)
	if (!C || !C.preferences)
		return
	var/datum/preferences/P = C.preferences

	if (!P.AH)
		return

	var/is_mutantrace = FALSE
	var/datum/trait/trait
	for (var/trait_id in P.traitPreferences.traits_selected)
		trait = getTraitById(trait_id)
		if (trait.mutantRace && src.icon == initial(src.icon))
			src.icon_state = trait.mutantRace.ghost_icon_state
			is_mutantrace = TRUE
			break

	var/cust_one_state = P.AH.customizations["hair_bottom"].style.id
	var/cust_two_state = P.AH.customizations["hair_middle"].style.id
	var/cust_three_state = P.AH.customizations["hair_top"].style.id

	var/image/hair = image(P.AH.customizations["hair_bottom"].style.icon, cust_one_state)
	hair.color = P.AH.customizations["hair_bottom"].color
	hair.alpha = GHOST_HAIR_ALPHA

	var/force_hair = FALSE
	if (istype(C.mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = C.mob
		force_hair = H.hair_override
	else if ("mutant_hair" in P.traitPreferences.traits_selected) //ooughh
		force_hair = TRUE

	if (!is_mutantrace || force_hair || (is_mutantrace && ("bald" in P.traitPreferences.traits_selected)))
		src.AddOverlays(hair, "hair")

		var/image/beard = image(P.AH.customizations["hair_middle"].style.icon, cust_two_state)
		beard.color = P.AH.customizations["hair_middle"].color
		beard.alpha = GHOST_HAIR_ALPHA
		src.AddOverlays(beard, "beard")

		var/image/detail = image(P.AH.customizations["hair_middle"].style.icon, cust_three_state)
		detail.color = P.AH.customizations["hair_top"].color
		detail.alpha = GHOST_HAIR_ALPHA
		src.AddOverlays(detail, "detail")

	if(cust_one_state && cust_one_state != "none")
		wig = new
		wig.mat_changename = 0
		var/datum/material/wigmat = getMaterial("ectofibre")
		wigmat = wigmat.getMutable()
		wigmat.setColor(P.AH.customizations["hair_bottom"].color)
		wig.setMaterial(wigmat)
		wig.name = "ectofibre [name]'s hair"
		wig.icon = 'icons/mob/human_hair.dmi'
		wig.icon_state = cust_one_state
		wig.color = P.AH.customizations["hair_bottom"].color
		wig.wear_image_icon = 'icons/mob/human_hair.dmi'
		wig.wear_image = image(wig.wear_image_icon, wig.icon_state)
		wig.wear_image.color = P.AH.customizations["hair_bottom"].color

	if (!src.bioHolder) //For critter spawns
		var/datum/bioHolder/newbio = new/datum/bioHolder(src)
		newbio.mobAppearance.customizations["hair_bottom"].color = hair.color
		newbio.mobAppearance.e_color = P.AH.e_color
		src.bioHolder = newbio


// Make sure to keep this JPS-cache safe
/mob/dead/observer/Cross(atom/movable/mover)
	if (!doubleghost && istype(mover, /obj/projectile))
		var/obj/projectile/proj = mover
		if (proj.proj_data?.hits_ghosts)
			return 0

	return 1

#ifdef HALLOWEEN
/mob/dead/observer/Crossed(atom/movable/mover)
	if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
		var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
		if (GH.spooking && mover.invisibility == INVIS_NONE && prob(20))
			GH.stop_spooking()
	. = ..()
#endif

/mob/dead/observer/bullet_act(var/obj/projectile/P)
	if (doubleghost|| !P.proj_data?.hits_ghosts)
		return

	if (P.proj_data && istype(P.proj_data, /datum/projectile/paintball))
		// i wanna paint ghosts not bust em
		return

#ifdef HALLOWEEN
	if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
		var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
		if (GH.spooking)
			GH.stop_spooking()
			//animate(src, )	explode?
			src.visible_message(SPAN_ALERT("<b>[src] is busted! Maybe?!</b>"),SPAN_ALERT("You are knocked out of your powerful state and feel dead again!"))
			log_shot(P,src)
			return
#endif

	src.doubleghost = TRUE
	if(!try_set_icon_state("doubleghost"))
		src.add_filter("doubleghost_outline", 0, outline_filter(1, "#000000", OUTLINE_SHARP))
		// color matrix makes the outline and all other fully black pixels white and somewhat transparent, hides the rest
		src.color = list(0,0,0,-255, 0,0,0,-255, 0,0,0,-255, 0,0,0,0.627451, 1,1,1,0)
	src.visible_message(SPAN_ALERT("<b>[src] is busted!</b>"),SPAN_ALERT("You are demateralized into a state of further death!"))


	if (wig)
		wig.set_loc(src.loc)
	new /obj/item/reagent_containers/food/snacks/ectoplasm(get_turf(src))
	src.ClearSpecificOverlays("hair", "beard", "detail", "glasses")
	log_shot(P,src)


//#endif

/mob/dead/observer/get_desc(dist, mob/user)
	. = ..()
	if (src.last_words && (user?.traitHolder?.hasTrait("training_chaplain") || istype(user, /mob/dead)))
		. += " <span class='deadsay' style='font-weight:bold;'>[capitalize(his_or_her(src))] last words were: \"[src.last_words]\".</span>"

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
	APPLY_ATOM_PROPERTY(src, PROP_MOB_SPECTRO, src)
	src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	src.see_invisible = INVIS_SPOOKY
	src.see_in_dark = SEE_DARK_FULL
	animate_bumble(src) // floaty ghosts  c:
	src.verbs += /mob/dead/observer/proc/toggle_tgui_auto_open
	src.verbs += /mob/dead/observer/proc/toggle_ghost_chem_vision
	src.verbs += /mob/dead/observer/proc/toggle_ghost_law_vision
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
		if (src.mind?.get_player()?.dnr)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_LAW_VISION, src)

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
			var/confirm = tgui_alert(src, "Are you sure you want to ghost? You won't be able to exit cryogenic storage, DNR status will be set, and you will be an observer the rest of the round.", "Observe?", list("Yes", "No"))
			if(confirm == "Yes")
				respawn_controller.subscribeNewRespawnee(src.ckey)
				for(var/datum/antagonist/antagonist as anything in src.mind?.antagonists)
					antagonist.handle_perma_cryo()
				src.mind?.get_player()?.dnr = TRUE
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
		if(isvirtual(src))
			src.death()
			return null
		if(src.mind && src.mind.damned) // Wow so much sin. Off to hell with you.
			INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, hell_respawn), src.mind)
			return null
		var/datum/mind/mind = src.mind

		// step 1: either find a ghost or make one
		var/mob/dead/observer/our_ghost = null

		// if we already have a ghost, just go get that instead
		if (src.ghost && !src.ghost.disposed && src.ghost.last_ckey == src.ckey)
			our_ghost = src.ghost
		// no existing ghost, make a new one
		else
			our_ghost = new/mob/dead/observer(src)
			our_ghost.bioHolder.CopyOther(src.bioHolder, copyActiveEffects = 0)
			if(!src.mouse_opacity)
				our_ghost.mouse_opacity = 0
				our_ghost.alpha = 0
			src.ghost = our_ghost

		if(isliving(src))
			var/mob/living/living_src = src
			if(living_src.last_words)
				if(istype(our_ghost, /mob/dead/target_observer))
					var/mob/dead/target_observer/our_observer = our_ghost
					our_observer.ghost?.last_words = living_src.last_words
				else
					our_ghost.last_words = living_src.last_words

		// step 2: make sure they actually make it to the ghost
		if (src.mind)
			src.mind.transfer_to(our_ghost)
		else
			our_ghost.key = src.key //they're probably logged out, set key so they're in the ghost when they get back

		var/turf/T = get_turf(src)
		if (can_ghost_be_here(our_ghost, T))
			our_ghost.set_loc(T)
		else
			our_ghost.set_loc(pick_landmark(LANDMARK_OBSERVER, locate(150, 150, 1)))

		if(istype(get_area(src), /area/afterlife))
			qdel(src)

		if(!mind?.get_player()?.dnr)
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

	if (src.mutantrace)
		O.icon_state = src.mutantrace.ghost_icon_state

	. = O

	if (glasses)
		var/image/glass = image(glasses.wear_image_icon, glasses.icon_state)
		glass.color = glasses.color
		glass.alpha = glasses.alpha * 0.75
		O.AddOverlays(glass, "glasses")
	else
		O.ClearSpecificOverlays("glasses")

	if (src.mutantrace && !istype(src.mutantrace, /datum/mutantrace/human) && !src.hair_override && !src.traitHolder?.hasTrait("bald"))
		return O

	if (src.bioHolder) //Not necessary for ghost appearance, but this will be useful if the ghost decides to respawn as critter.
		var/datum/appearanceHolder/temp_holder = null
		if (QDELETED(src.AH_we_spawned_with))
			if (QDELETED(src.bioHolder.mobAppearance))
				CRASH("Ghostize called on a mob [src] with bioHolder but no non-null appearance holders")
			else
				temp_holder = src.bioHolder.mobAppearance
		else
			temp_holder = src.AH_we_spawned_with
		var/image/hair = image(temp_holder.customizations["hair_bottom"].style.icon, temp_holder.customizations["hair_bottom"].style.id)
		hair.color = src.bioHolder.mobAppearance.customizations["hair_bottom"].color
		hair.alpha = GHOST_HAIR_ALPHA
		O.AddOverlays(hair, "hair")

		var/image/beard = image(temp_holder.customizations["hair_middle"].style.icon, temp_holder.customizations["hair_middle"].style.id)
		beard.color = src.bioHolder.mobAppearance.customizations["hair_middle"].color
		beard.alpha = GHOST_HAIR_ALPHA
		O.AddOverlays(beard, "beard")

		var/image/detail = image(temp_holder.customizations["hair_top"].style.icon, temp_holder.customizations["hair_top"].style.id)
		detail.color = src.bioHolder.mobAppearance.customizations["hair_top"].color
		detail.alpha = GHOST_HAIR_ALPHA
		O.AddOverlays(detail, "detail")

		var/cust_one = src.bioHolder.mobAppearance.customizations["hair_bottom"].style.id
		if(cust_one && cust_one != "none")
			O.wig = new
			O.wig.mat_changename = 0
			var/datum/material/wigmat = getMaterial("ectofibre")
			wigmat = wigmat.getMutable()
			wigmat.setColor(src.bioHolder.mobAppearance.customizations["hair_bottom"].color)
			O.wig.setMaterial(wigmat)
			O.wig.name = "[O.name]'s hair"
			O.wig.icon = 'icons/mob/human_hair.dmi'
			O.wig.icon_state = cust_one
			O.wig.color = src.bioHolder.mobAppearance.customizations["hair_bottom"].color
			O.wig.wear_image_icon = 'icons/mob/human_hair.dmi'
			O.wig.wear_image = image(O.wig.wear_image_icon, O.wig.icon_state)
			O.wig.wear_image.color = src.bioHolder.mobAppearance.customizations["hair_bottom"].color


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
		boutput(src, SPAN_SUCCESS("Health status toggled on."))
	else
		health_shown = 0
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(src)
		boutput(src, SPAN_ALERT("Health status toggled off."))

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

	if(!mind || !mind.get_player()?.dnr)
		boutput( usr, SPAN_ALERT("You must enable DNR to use this.") )
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


	if(delete_on_logout)
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
	if (!can_ghost_be_here(src, NewTurf))
		var/OS = pick_landmark(LANDMARK_OBSERVER, locate(150, 150, 1))
		src.set_loc(OS)
		OnMove()
		return

	. = ..()

/mob/dead/observer/set_loc(atom/new_loc, new_pixel_x, new_pixel_y)
	if (isturf(new_loc) && !can_ghost_be_here(src, new_loc) && (isnull(src.corpse) || !can_ghost_be_here(src.corpse, new_loc)))
		var/OS = pick_landmark(LANDMARK_OBSERVER, locate(150, 150, 1))
		src.set_loc(OS)
		return
	. = ..()

/mob/dead/observer/mouse_drop(atom/A)
	if (usr != src || isnull(A) || A == src) return
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

/mob/dead/observer/proc/toggle_ghost_chem_vision()
	set category = "Ghost"
	set name = "Toggle Chemical Analysis Vision"
	if(HAS_ATOM_PROPERTY(src, PROP_MOB_SPECTRO))
		boutput(src, "No longer viewing chemical composition of objects.")
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_SPECTRO, src)
	else
		boutput(src, "Enabled viewing chemical composition of objects")
		APPLY_ATOM_PROPERTY(src, PROP_MOB_SPECTRO, src)

/mob/dead/observer/proc/toggle_ghost_law_vision()
	set category = "Ghost"
	set name = "Toggle Silicon Law Vision"
	if(!mind || !mind.get_player()?.dnr)
		boutput( usr, SPAN_ALERT("You must enable DNR to use this.") )
		return
	if(HAS_ATOM_PROPERTY(src, PROP_MOB_LAW_VISION))
		boutput(src, "No longer viewing laws of examined silicons.")
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_LAW_VISION, src)
	else
		boutput(src, "Enabled viewing laws of examined silicons.")
		APPLY_ATOM_PROPERTY(src, PROP_MOB_LAW_VISION, src)

/mob/dead/observer/proc/reenter_corpse()
	set category = null
	set name = "Re-enter Corpse"
	if(QDELETED(corpse) || corpse.loc == null)
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

	if(!mind || !mind.get_player()?.dnr)
		boutput( usr, SPAN_ALERT("You must enable DNR to use this.") )
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


/mob/dead/observer/verb/toggle_ghosts()
	set name = "Toggle Ghosts"
	set category = null

	if (src.see_invisible >= INVIS_GHOST)
		src.see_invisible = INVIS_NONE
		boutput(src, "You can no longer see other ghosts.", group="ghostsight")
	else if(HAS_FLAG(src.sight, SEE_SELF))
		src.sight &= ~SEE_SELF
		boutput(src, "You can no longer see yourself.", group="ghostsight")
	else
		src.see_invisible = INVIS_SPOOKY
		src.sight |= SEE_SELF
		boutput(src, "You can now see other ghosts and yourself.", group="ghostsight")


/mob/dead/observer/verb/observe()
	set name = "Observe"
	set category = null

	if(isnull(src.observe_menu))
		src.observe_menu = new()
	src.observe_menu.ui_interact(src)



/mob/dead/observer/proc/insert_observer(var/atom/target)
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
	if(HAS_ATOM_PROPERTY(src, PROP_MOB_SPECTRO))
		APPLY_ATOM_PROPERTY(newobs, PROP_MOB_SPECTRO, newobs)
	if (src.corpse)
		corpse.ghost = newobs
	if (src.mind)
		mind.transfer_to(newobs)
	else if (src.client) //Wire: Fix for Cannot modify null.mob.
		src.client.mob = newobs

/mob/dead/observer/proc/insert_slasher_observer(var/atom/target) //aaaaaa i had to create a new proc aaaaaa
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


/mob/dead/observer/verb/ghostjump(x as num, y as num, z as num)
	set name = ".ghostjump"
	set hidden = TRUE

	var/turf/T = locate(x, y, z)
	if (can_ghost_be_here(src, T))
		src.set_loc(T)

#undef GHOST_HAIR_ALPHA
