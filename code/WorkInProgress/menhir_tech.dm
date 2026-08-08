TYPEINFO(/obj/effects/menhir_fog)
	var/list/connects_to = null
TYPEINFO_NEW(/obj/effects/menhir_fog)
	. = ..()
	connects_to = typecacheof(list(/obj/effects/menhir_fog))
///Menhir's "fog of war". Provides an (imperfect) visual shroud to somewhat preserve the mystique of the Crown.
/obj/effects/menhir_fog
	name = "peculiar fog"
	desc = "Something has chosen not to be seen."
	icon = 'icons/effects/fogofwar.dmi'
	layer = 3.9
	mouse_opacity = 1
	anchored = ANCHORED
	invisibility = INVIS_FLOCK //selected so as not to block out AI more than for any particular lore implication
#ifdef IN_MAP_EDITOR
	icon_state = "editor"
#else
	icon_state = "0"
#endif

	New()
		..()
		if (current_state > GAME_STATE_WORLD_NEW)
			SPAWN(0)
				src.UpdateIcon()
				if(istype(src))
					src.update_neighbors()
		else
			worldgenCandidates += src

	proc/generate_worldgen()
		src.UpdateIcon()

	update_icon()
		var/typeinfo/turf/simulated/wall/auto/tpnf = get_typeinfo()
		var/connectdir = get_connected_directions_bitflag(tpnf.connects_to, null, connect_diagonal = 1)
		var/the_state = "[connectdir]"
		src.icon_state = the_state

	proc/update_neighbors()
		for (var/obj/effects/menhir_fog/mfog in orange(1,src))
			mfog.UpdateIcon()

//convenient shorthand for don't blow up this floor
/turf/simulated/floor/shuttle/menhir_arm
	name = "blue floor"
	desc = "This floor looks awfully strange."
	icon = 'icons/misc/worlds.dmi'
	pryable = FALSE
#ifdef IN_MAP_EDITOR
	icon_state = "old_floor2"
#else
	icon_state = "bluefloor"
#endif

/turf/unsimulated/floor/setpieces/menhir_cavepool
	name = "cenote"
	desc = "A faint shimmer coats the surface."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "cenote"

/datum/fishing_spot/biodome_lake/menhir
	fishing_atom_type = /turf/unsimulated/floor/setpieces/menhir_cavepool

/area/station/crown // stole this code from the void definition
	name = "The Crown"
	icon_state = "purple"
	filler_turf = "/turf/unsimulated/floor/setpieces/bluefloor"
	sound_environment = 5
	sound_loop = 'sound/ambience/industrial/Precursor_Drone1.ogg'
	teleport_blocked = AREA_TELEPORT_BLOCKED
	do_not_irradiate = 1
	requires_power = FALSE

/area/station/crown/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/station/crown/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/station/crown/area_process()
	if(prob(20))
		var/weirdnoise = pick('sound/ambience/industrial/Precursor_Drone2.ogg',\
			'sound/ambience/industrial/Precursor_Choir.ogg',\
			'sound/ambience/industrial/Precursor_Drone3.ogg',\
			'sound/ambience/industrial/Precursor_Bells.ogg')

		var/turf/noisy_turf = pick(get_area_turfs(/area/station/crown))
		playsound(noisy_turf, weirdnoise, 70, 1)

#define ARC_NOT_READY 0
#define ARC_READY 1
#define ARC_ACTIVE 2
#define ARC_CONCLUDE 3

//Menhir variant of precursor energy sphere without the tag stuff, for events. Hooks to an APC and charges it
/obj/machinery/menhir_energy_sphere
	name = "rydberg-matter sphere"
	desc = "That doesn't look very safe at all."
	icon = 'icons/obj/artifacts/puzzles.dmi'
	icon_state = "sphere"
	anchored = ANCHORED
	density = 0
	opacity = 0
	alpha = 0
	var/datum/light/light
	var/obj/machinery/power/apc/target_apc
	var/list/boltlines = list()
	var/arc_status = ARC_NOT_READY
	var/warned = FALSE
	///Can overcharge cells by 500 units an orb, to a cap of 5,000 cell capacity
	var/add_budget = 500

	New(newLoc, var/obj/inputapc)
		if(inputapc)
			target_apc = inputapc
		else
			var/obj/machinery/power/apc/prospective_target = get_local_apc(src)
			if(prospective_target) target_apc = prospective_target
		..()
		src.Scale(3,3)
		src.light = new /datum/light/point
		src.light.attach(src)
		src.light.set_color(0.6,0.7,1)
		src.light.set_brightness(0.7)
		src.AddComponent(/datum/component/proximity)

		if(target_apc)
			playsound(src.loc, 'sound/weapons/energy/howitzer_firing.ogg', 40, 0, pitch = 0.45, extrarange = 24)
			SPAWN(3)
				src.light.enable()
				animate(src, alpha = 255, transform = matrix(), time = 2 SECONDS, easing = CIRCULAR_EASING)
			SPAWN(3 SECONDS)
				src.density = 1
				src.arc_status = ARC_READY

	process()
		if(!target_apc || !target_apc.cell)
			src.complete_cycle()
			return
		switch(src.arc_status)
			if(ARC_READY)
				src.arc_status = ARC_ACTIVE
				playsound(src.loc, 'sound/machines/shieldoverload.ogg', 80, 0, extrarange = 24)
				SPAWN(8)
					src.boltlines = drawLineObj(src, target_apc, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')
					src.light.set_brightness(1.4)
			if(ARC_ACTIVE)
				if(!target_apc.operating && target_apc.cell.charge > 0.3 * target_apc.cell.maxcharge) //if the APC is charged but not "flowing", interrupt early
					if(!src.warned)
						src.visible_message(SPAN_ALERT("<b>[src] begins to shudder and spark!</b>"))
						src.warned = TRUE
					playsound(src.loc, 'sound/effects/elec_bzzz.ogg', 65, 1, pitch = 0.8)
					src.arc_status = ARC_CONCLUDE
				else
					var/obj/item/cell/targetcell = target_apc.cell
					var/add_amt = rand(80,100)
					if(src.add_budget && targetcell.maxcharge < 5000)
						targetcell.maxcharge = min(targetcell.maxcharge + 100, 5000)
						src.add_budget -= 100

					if(targetcell.charge + 210 > targetcell.maxcharge)
						if(!src.warned)
							src.visible_message(SPAN_ALERT("<b>[src] begins to shudder and spark!</b>"))
							src.warned = TRUE
						playsound(src.loc, 'sound/effects/elec_bzzz.ogg', 65, 1, pitch = 0.8)
					else
						playsound(src.loc, 'sound/machines/siphon_run.ogg', 65, 0, pitch = 1.65)

					targetcell.charge = min(targetcell.charge + add_amt, targetcell.maxcharge)
					if(targetcell.charge == targetcell.maxcharge)
						src.arc_status = ARC_CONCLUDE
			if(ARC_CONCLUDE)
				src.complete_cycle()

	proc/complete_cycle()
		playsound(src.loc, 'sound/effects/lightning_strike.ogg', 80, 0, pitch = 0.8)
		for (var/mob/living/flashmob in range(src, 4))
			if (flashmob.hasStatus("spatial_protection"))
				for_by_tcl(IX, /obj/machinery/interdictor)
					if(IX.notify_interdictor(flashmob))
						break
				boutput(flashmob,"<b>The discharge glances off of your protective field!</b>")
				arcFlash(src, get_turf(flashmob), (600 - add_budget) * 200)
			else
				arcFlash(src, flashmob, (600 - add_budget) * 200) //don't arcflash hard unless we overcharged something
				if (isdead(flashmob) && prob(15))
					flashmob.gib()
		animate(src, alpha = 0, time = 5, easing = BOUNCE_EASING)
		SPAWN(6)
			qdel(src)

	disposing()
		for (var/obj/O in boltlines)
			qdel(O)
		light.disable()
		..()

	EnteredProximity(atom/movable/AM)
		if(src.arc_status && iscarbon(AM) && prob(20))
			var/mob/living/carbon/user = AM
			src.shock(user)

	bump(atom/movable/AM as mob)
		if(iscarbon(AM))
			var/mob/living/carbon/user = AM
			src.shock(user)
			src.density = 0 //special behavior for this version

	proc/shock(var/mob/living/user as mob)
		if(user)
			elecflash(user,power=2)
			var/shock_damage = rand(10,15)

			if (user.bioHolder.HasEffect("resist_electric_heal"))
				var/healing = 0
				if (shock_damage)
					healing = shock_damage / 3
				user.HealDamage("All", shock_damage, shock_damage)
				user.take_toxin_damage(0 - healing)
				boutput(user, SPAN_NOTICE("You absorb the electrical shock, healing your body!"))
				return
			else if (user.bioHolder.HasEffect("resist_electric"))
				boutput(user, SPAN_NOTICE("You feel electricity course through you harmlessly!"))
				return

			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, shock_damage)
			boutput(user, SPAN_ALERT("<B>You feel a powerful shock course through your body sending you flying!</B>"))
			user.unlock_medal("HIGH VOLTAGE", 1)
			user.Virus_ShockCure(100)
			user:shock_cyberheart(100)
			user.changeStatus("stunned", 2 SECONDS)
			user.changeStatus("knockdown", 2 SECONDS)
			var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
			user.throw_at(target, 200, 4)
			for(var/mob/M in AIviewers(src))
				if(M == user)	continue
			user.show_message(SPAN_ALERT("[user.name] was shocked by the [src.name]!"), 3, SPAN_ALERT("You hear a heavy electrical crack"), 2)

#undef ARC_NOT_READY
#undef ARC_READY
#undef ARC_ACTIVE
#undef ARC_CONCLUDE

/obj/dreamcatcher
	name = "hypnotizing mechanism"
	desc = "A near-imperceptible noise suffuses your senses. It sings."
	anchored = ANCHORED
	density = 1
	icon = 'icons/obj/artifacts/artifacts.dmi'
	icon_state = "precursor-4"
	var/expended = FALSE
	//replicate artifact vfx
	var/obj/effect/artifact_glowie/fx_image = null
	var/obj/effect/artifact_glowie/fx_fallback = null

	New()
		. = ..()
		src.fx_image = new
		src.fx_image.icon = src.icon
		src.fx_image.icon_state = src.icon_state + "fx"
		src.fx_image.color = "#BEBEFF"
		src.fx_image.alpha = 200
		src.fx_image.layer = 5
		src.fx_image.blend_mode = BLEND_ADD
		src.fx_image.plane = PLANE_LIGHTING

		src.fx_fallback = new
		src.fx_fallback.icon = src.icon
		src.fx_fallback.icon_state = src.icon_state + "fx"
		src.fx_fallback.color = src.fx_image.color
		src.fx_fallback.alpha = src.fx_image.alpha
		src.fx_fallback.vis_flags |= VIS_INHERIT_LAYER
		src.fx_fallback.vis_flags |= VIS_INHERIT_PLANE

	disposing()
		qdel(src.fx_image)
		qdel(src.fx_fallback)
		. = ..()

	Crossed(atom/movable/O)
		if (src.expended || !istype(O, /mob/dead/observer))
			return ..()
		var/mob/dead/observer/ghost = O
		var/datum/mind/M = ghost.mind

		if(!istype(M))
			return ..()

		if (!assess_ghostdrone_eligibility(M))
			boutput(ghost, "<span class='alert'>A whisper washes over you, then quiets. The mechanism seeks another.</span>")
			return ..()

		. = ..()
		SPAWN(0)
			if (tgui_alert(ghost, "The machine offers you a physical form.", "Inquiry", list("Yes", "No"), timeout = 20 SECONDS) != "Yes")
				return
			if (!src.expended)
				src.catch_dream(ghost,M)

	proc/catch_dream(var/mob/form,var/datum/mind/soul)
		if (!form || !soul || src.expended)
			return
		if (form.transforming)
			return

		var/turf/ourturf = get_turf(src)
		if (!ourturf)
			return

		src.expended = TRUE
		ourturf.visible_message("<b>[src] lights up with an unearthly glow!</b>")
		playsound(ourturf,'sound/machines/ArtifactPre1.ogg', 100, TRUE)
		src.vis_contents += src.fx_image
		src.vis_contents += src.fx_fallback

		var/mob/living/critter/robotic/probe/P = new /mob/living/critter/robotic/probe(src)

		form.transforming = 1
		form.canmove = 0
		form.icon = null
		APPLY_ATOM_PROPERTY(form, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

		if (isobserver(form) && form:corpse)
			P.oldmob = form:corpse

		if (form?.real_name)
			P.oldname = form.real_name

		soul.transfer_to(P)

		P.job = "Proxy"
		soul.assigned_role = "Proxy"

		SPAWN(5 SECONDS)
			P.playsound_local_not_inworld('sound/ambience/industrial/Precursor_Drone3.ogg', 40, 0, pitch = 2)
		SPAWN(9 SECONDS)
			boutput(P, "<span class='bold' style='color: #BEBEFF'>The chorus sings for you now.<br>You are offered a new mortality.</span>")
		SPAWN(15 SECONDS)
			P.show_edicts()
		SPAWN(20 SECONDS)
			ourturf = get_turf(src)
			P.set_loc(ourturf)
			showswirl(ourturf)
			src.vis_contents -= src.fx_image
			src.vis_contents -= src.fx_fallback
			ourturf.visible_message("<b>[src] releases a probe.</b>")
			src.color = "#DDDDDD"
			src.desc = "Its sheen has dulled. Whatever purpose it was built to serve, it has fulfilled it."

#ifdef MAP_OVERRIDE_MENHIR

/client/proc/cmd_admin_vislayer()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Menhir Fogsight"
	set desc = "Alters your see_invisible layer to allow slipping below Menhir's \"fog of war\"."
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!ismob(usr))
		return

	var/activated = FALSE
	if(usr.see_invisible == INVIS_AI_EYE)
		usr.see_invisible = INVIS_SPOOKY // this could revert to a saved pre-change state eventually
	else
		usr.see_invisible = INVIS_AI_EYE // highest level that's still beneath the fog
		activated = TRUE

	boutput(usr, SPAN_NOTICE("<b>Vision [activated ? "altered." : "restored to default."]</b>"))
#endif

/obj/decal/poster/wallsign/menhere_sign
	name = "pun hazard tracking sign"
	icon = 'icons/obj/decals/countdown_sign.dmi'
	icon_state = "base"
	desc = "It has been X shifts since the last 'men here'."
	var/shift_count = 0

	New()
		..()
		src.RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_MEN_HERE, PROC_REF(funny_phrase_handler))
		src.shift_count = min(world.load_intra_round_value("men_here_count_[map_settings.name]") || 0, 99)
		src.shift_count++
		world.save_intra_round_value("men_here_count_[map_settings.name]", src.shift_count)
		src.update_da_sign()

	attack_hand(mob/user)
		interact_particle(user, src)
		user.examine_verb(src)

	disposing()
		src.UnregisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_MEN_HERE)
		. = ..()

	proc/update_da_sign()
		src.UpdateOverlays(image(src.icon, "[round(shift_count/10)]_"), "number10s")
		src.UpdateOverlays(image(src.icon, "_[round(shift_count%10)]"), "number1s")
		src.desc = "It has been [shift_count] shift\s since the last 'men here'."
		switch(src.shift_count)
			if(0)
				src.desc += " The men are here."
			if(1 to 10)
				src.desc += " The men were here not long ago."
			if(11 to 20)
				src.desc += " The men were here fairly recently."
			if(21 to 40)
				src.desc += " It's been a while since the men were here."
			if(41 to 80)
				src.desc += " Men may, in fact, not be here."
			if(81 to 98)
				src.desc += " Humor is in its waning days."
			if(99 to INFINITY)
				src.desc += " The pun lies dormant, at long last."

	proc/funny_phrase_handler()
		world.save_intra_round_value("men_here_count_[map_settings.name]", 0)
		src.shift_count = 0
		src.update_da_sign()
