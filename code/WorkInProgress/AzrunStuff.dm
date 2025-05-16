/obj/item/deconstructor/admin_crimes
	// do not put this anywhere anyone can get it. it is for crime.
	name = "(de/re)-construction device"
	desc = "A magical saw-like device for unmaking things. Is that a soldering iron on the back?"
	default_material = "miracle"

	New()
		. = ..()
		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(pre_attackby), override=TRUE)

	pre_attackby(source, atom/target, mob/user)
		if (!isobj(target))
			return
		if (istype(target, /obj/item/electronics/frame))
			var/obj/item/electronics/frame/F = target
			F.deploy(user)
			return ATTACK_PRE_DONT_ATTACK

		finish_decon(target, user)
		return ATTACK_PRE_DONT_ATTACK

/obj/item/paper/artemis_todo
	icon = 'icons/obj/electronics.dmi';
	icon_state = "blueprint";
	info = "<h3>Project Artemis</h3><i>The blueprint depicts the design of a small spaceship and a unique method of travel through space.  It is covered in small todo-lists in red ink.</i>";
	item_state = "sheet";
	name = "Artemis Blueprint"
	interesting = "The title block indicates this was originally made by Emily while all revisions seem to have been done in crayon by Azrun?"

/obj/item/paper/terrainify
	icon = 'icons/obj/electronics.dmi';
	icon_state = "blueprint";
	info = "<h3>Project Metamorphose</h3><i>It depicts of a series of geoids with varying topology and various processing to convert to and from one another.</i>";
	item_state = "sheet";
	name = "Strange Blueprint"
	interesting = "There is additional detail regarding the creation of flora and fauna."
/obj/table/wood/auto/desk/azrun
	has_drawer = TRUE
	drawer_contents = list(/obj/item/raw_material/molitz_beta,
							/obj/item/raw_material/molitz_beta,
							/obj/item/raw_material/plasmastone,
							/obj/item/organ/lung/plasmatoid/left,
							/obj/item/pen/crayon/red)

/obj/item/storage/toilet/goldentoilet/azrun
	name = "thinking throne"
	desc = "A wonderful place to send bad ideas...  Clogged more often than not."
	dir = NORTH

/datum/manufacture/sub/treads
	name = "Vehicle Treads"
	item_requirements = list("metal_dense" = 5,
							 "conductive" = 2)
	item_outputs = list(/obj/item/shipcomponent/locomotion/treads)
	create = 1
	time = 5 SECONDS
	category = "Component"

/datum/manufacture/sub/wheels
	name = "Vehicle Wheels"
	item_requirements = list("metal_dense" = 5,
							 "conductive" = 2)
	item_outputs = list(/obj/item/shipcomponent/locomotion/wheels)
	create = 1
	time = 5 SECONDS
	category = "Component"


/obj/machinery/plantpot/bareplant/swamp_flora
	New()
		..()
		spawn_plant = pick(/datum/plant/spore_poof, /datum/plant/seed_spitter)

/datum/plant/spore_poof
	name = "mysterious plant"
	plant_icon = 'icons/obj/hydroponics/plants_alien.dmi'
	growthmode = "weed"
	sprite = "Poof"
	special_proc = 1
	attacked_proc = 1
	harvestable = 0
	assoc_reagents = list("cyanide", "histamine", "nitrogen_dioxide")
	starthealth = 40
	growtime = 50
	harvtime = 90
	cropsize = 1
	harvests = 0
	endurance = 5
	vending = FALSE


	var/list/cooldowns

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.HYPget_growth_to_harvestable(DNA) + 10))
			for (var/mob/living/X in view(1,POT.loc))
				if(isalive(X) && !iskudzuman(X))
					poof(X, POT)
					break

	HYPattacked_proc(obj/machinery/plantpot/POT, mob/user)
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.HYPget_growth_to_harvestable(DNA) + 10))
			if(!iskudzuman(user))
				poof(user, POT)

	proc/poof(atom/movable/AM, obj/machinery/plantpot/POT)
		if(!ON_COOLDOWN(src,"spore_poof", 2 SECONDS))
			var/datum/plant/P = POT.current
			var/datum/plantgenes/DNA = POT.plantgenes
			var/datum/reagents/reagents_temp = new/datum/reagents(max(1,(50 + DNA.cropsize))) // Creating a temporary chem holder
			reagents_temp.my_atom = POT
			var/list/plant_complete_reagents = HYPget_assoc_reagents(src, DNA)
			for (var/plantReagent in plant_complete_reagents)
				reagents_temp.add_reagent(plantReagent, 2 * max(1, HYPfull_potency_calculation(DNA, 0.1 / length(plant_complete_reagents))))

			SPAWN(0) // spawning to kick fluid processing out of machine loop
				reagents_temp.smoke_start()
				qdel(reagents_temp)

			POT.growth = clamp(POT.growth/2, P.HYPget_growth_to_matured(DNA), P.HYPget_growth_to_harvestable(DNA)-10)
			POT.UpdateIcon()

	getIconState(grow_level, datum/plantmutation/MUT)
		if(GET_COOLDOWN(src, "spore_poof"))
			return "Poof-Open"
		else
			. = ..()

/obj/item/seed/alien/spore_poof
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/spore_poof, src)

/datum/plant/seed_spitter
	name = "mysterious plant"
	plant_icon = 'icons/obj/hydroponics/plants_alien.dmi'
	sprite = "Spit"
	growthmode = "weed"
	special_proc = 1
	attacked_proc = 1
	harvestable = 0
	starthealth = 40
	growtime = 80
	harvtime = 120
	cropsize = 1
	harvests = 0
	endurance = 5
	assoc_reagents = list("toxin", "histamine")
	vending = FALSE

	var/datum/projectile/syringe/seed/projectile

	New()
		..()
		projectile = new

	proc/alter_projectile(var/datum/plantgenes/DNA, var/obj/projectile/P)
		if (!P.reagents)
			P.reagents = new /datum/reagents(P.proj_data.cost)
			P.reagents.my_atom = P
		var/list/plant_complete_reagents = HYPget_assoc_reagents(src, DNA)
		for (var/plantReagent in plant_complete_reagents)
			P.reagents.add_reagent(plantReagent, 2)

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		var/mob/M = POT.loc
		if(isalive(M))
			M.TakeDamage("All", 2, 0, 0, DAMAGE_STAB)
			if(prob(20))
				return

		if (POT.growth > (P.HYPget_growth_to_harvestable(DNA) + 5))
			var/list/stuffnearby = list()
			for (var/mob/living/X in view(7,POT.loc))
				if(isalive(X) && (X != POT.loc) && !iskudzuman(X))
					stuffnearby += X
			if(length(stuffnearby))
				var/mob/living/target = pick(stuffnearby)
				var/datum/callback/C = new(src, PROC_REF(alter_projectile), DNA)
				if(prob(10))
					shoot_projectile_ST_pixel_spread(POT, projectile, get_step(target, pick(ordinal)), alter_proj=C)
				else
					shoot_projectile_ST_pixel_spread(POT, projectile, target, alter_proj=C)
				POT.growth -= rand(1,5)
			return

/obj/item/seed/alien/seed_spitter
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/seed_spitter, src)

/datum/projectile/syringe/seed
	name = "strange seed"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "seedproj"
	implanted = /obj/item/implant/projectile/body_visible/seed/spitter_pod

/obj/item/implant/projectile/body_visible/seed/spitter_pod
	name = "strange seed pod"
	pull_out_name = "strange seed pod"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	desc = "A small hollow pod."
	icon_state = "seedproj"
	var/dig_ticker = 25

	New()
		..()
		implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "dart_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

	do_process()
		src.dig_ticker = max(src.dig_ticker-1, 0)
		if(!src.dig_ticker)
			online = FALSE
			if(prob(80))
				var/mob/living/carbon/human/H = src.owner
				var/obj/item/implant/projectile/spitter_pod/implant = new
				implant.implanted(H)
				boutput(src.owner,SPAN_ALERT("You feel something work its way into your body from \the [src]."))

	on_death()
		if(!online)
			return
		if(prob(80))
			var/mob/living/carbon/human/H = src.owner
			var/obj/item/implant/projectile/spitter_pod/implant = new
			implant.implanted(H)
			SPAWN(rand(5 SECONDS, 30 SECONDS))
				if(!QDELETED(H) && !QDELETED(implant))
					implant.on_death()

/obj/item/implant/projectile/spitter_pod
	name = "strange seed pod"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	desc = "A small hollow pod."
	icon_state = "seedproj"

	var/heart_ticker = 35
	online = TRUE

	implanted(mob/M, mob/Implanter)
		..()
		if(prob(10))
			online = FALSE

	on_death()
		if(!online)
			return
		var/atom/movable/P = locate(/obj/machinery/plantpot/bareplant) in src.owner

		// Uhhh.. just one thanks, don't need a pew pew army growing out of someone
		if(!P)
			P = new /obj/machinery/plantpot/bareplant {spawn_plant=/datum/plant/seed_spitter; spawn_growth=1; auto_water=FALSE;} (src.owner)
			var/atom/movable/target = src.owner
			src.owner.vis_contents |= P
			P.alpha = 0
			SPAWN(rand(2 SECONDS, 3 SECONDS))
				P.rest_mult = target.rest_mult
				P.pixel_x = 15 * -P.rest_mult
				P.transform = P.transform.Turn(P.rest_mult * -90)
				animate(P, alpha=255, time=2 SECONDS)

	do_process()
		heart_ticker = max(heart_ticker-1, 0)
		if(!isalive(src.owner))
			online = FALSE
			return
		if(heart_ticker & prob(60) && !ON_COOLDOWN(src,"[src] spam", 5 SECONDS) )
			if(prob(30))
				boutput(src.owner,SPAN_ALERT("You feel as though something moving towards your heart... That can't be good."))
			else
				boutput(src.owner,SPAN_ALERT("You feel as though something is working its way through your chest."))
		else if(!heart_ticker)
			if(!ON_COOLDOWN(src,"[src] spam", 8 SECONDS))
				var/mob/living/carbon/human/H = src.owner
				if(istype(H))
					H.organHolder.damage_organs(rand(1,5)/2, 0, 1, list("heart"))
				else
					src.owner.TakeDamage("All", 1, 0)

				if(prob(5))
					boutput(src.owner,SPAN_ALERT("AAHRRRGGGG something is trying to dig your heart out from the inside?!?!"))
					src.owner.emote("scream")
					src.owner.changeStatus("stunned", rand(1 SECOND, 2 SECONDS))
				else if(prob(40))
					boutput(src.owner,SPAN_ALERT("You feel a sharp pain in your chest."))

/datum/gimmick_event
	var/interaction = 0
	var/duration = 1 DECI SECOND
	var/description
	var/visible_message
	var/notify_admins = FALSE

	test1
		interaction = TOOL_PULSING
		duration = 2 SECONDS
		description = "A pulsing of this is needed!"
		visible_message = "sends a few pulses into the device."

	test2
		interaction = TOOL_SCREWING
		duration = 5 SECONDS
		description = "A few screws are still remaining to be, well, screwed."
		visible_message = "screws in the last few remaining screws."
		notify_admins = TRUE

/obj/gimmick_obj
	var/list/gimmick_events
	var/active_stage
	flags = FLUID_SUBMERGE | TGUI_INTERACTIVE

	New()
		..()
		gimmick_events = list()

	get_desc()
		var/datum/gimmick_event/AE = get_active_event()
		if(!AE)
			return
		else
			. += AE.description

	attack_hand(mob/user)
		var/datum/gimmick_event/AE = get_active_event()

		if(!AE)
			..()
		else if(AE.interaction == 0)
			SETUP_GENERIC_ACTIONBAR(user, src, AE.duration, PROC_REF(complete_stage), list(user, null), null, null, null, null)
		else
			..()

	attackby(obj/item/W, mob/user)

		var/attempt = FALSE
		var/datum/gimmick_event/AE = get_active_event()

		if(!AE)
			return

		if(AE.interaction & TOOL_CUTTING && iscuttingtool(W))
			attempt = TRUE
		else if(AE.interaction & TOOL_PULSING && ispulsingtool(W))
			attempt = TRUE
		else if(AE.interaction & TOOL_CUTTING && iscuttingtool(W))
			attempt = TRUE
		else if(AE.interaction & TOOL_PRYING && ispryingtool(W))
			attempt = TRUE
		else if(AE.interaction & TOOL_SCREWING && isscrewingtool(W))
			attempt = TRUE
		else if(AE.interaction & TOOL_SNIPPING && issnippingtool(W))
			attempt = TRUE
		else if(AE.interaction & TOOL_WRENCHING && iswrenchingtool(W))
			attempt = TRUE
		else if(AE.interaction & TOOL_WELDING && isweldingtool(W))
			if(W:try_weld(user,1))
				attempt = TRUE

		if(attempt)
			SETUP_GENERIC_ACTIONBAR(user, src, AE.duration, PROC_REF(complete_stage), list(user, W), W.icon, W.icon_state, null, null)

	proc/complete_stage(mob/user as mob, obj/item/W as obj)
		var/datum/gimmick_event/AE = get_active_event()
		if(!AE)
			return
		if(AE.visible_message)
			src.visible_message("[user] [AE.visible_message]")

		if(AE.notify_admins)
			message_admins("[key_name(user)] completed stage [active_stage] on [src].  [log_loc(src)]")

		active_stage++

	proc/get_active_event()
		if(length(gimmick_events) && active_stage <= length(gimmick_events))
			return(gimmick_events[active_stage])

	test
		icon = 'icons/obj/machines/nuclear.dmi'
		icon_state = "neutinj"

		New()
			..()
			gimmick_events += new /datum/gimmick_event/test1
			gimmick_events += new /datum/gimmick_event/test2
			active_stage = 1

/obj/gimmick_obj/ui_state(mob/user)
	return tgui_admin_state

/obj/gimmick_obj/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GimmickObject")
		ui.open()

/obj/gimmick_obj/ui_static_data(mob/user)
	. = list()
	.["interactiveTypes"] = list("Clamp"=TOOL_CLAMPING, "Cut"=TOOL_CUTTING, "Pry"=TOOL_PRYING, "Pulse"=TOOL_PULSING, "Saw"=TOOL_SAWING, "Screw"=TOOL_SCREWING, "Snip"=TOOL_SNIPPING, "Spoon"=TOOL_SPOONING, "Weld"=TOOL_WELDING, "Wrench"=TOOL_WRENCHING, "Chop"=TOOL_CHOPPING)

/obj/gimmick_obj/ui_data()
	. = list()

	.["activeStage"] = active_stage
	.["eventList"] = list()
	for(var/datum/gimmick_event/GE as anything in gimmick_events)
		.["eventList"] += list(list(
			"interaction" = GE.interaction,
			"description" = GE.description,
			"duration" = GE.duration/10,
			"message"=GE.visible_message,
			"notify"=GE.notify_admins ))

/obj/gimmick_obj/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/id = params["event"]
	var/value = params["value"]
	var/datum/gimmick_event/GE
	if(!isnull(id) && length(gimmick_events) && id <= length(gimmick_events))
		id++
		GE = gimmick_events[id]

	switch(action)
		if("add_new")
			gimmick_events += new /datum/gimmick_event
			. = TRUE

		if("delete_event")
			gimmick_events -= GE
			. = TRUE

		if("interaction")
			GE.interaction ^= value
			. = TRUE

		if("message")
			GE.visible_message = value
			. = TRUE

		if("description")
			GE.description = value
			. = TRUE

		if("duration")
			GE.duration = value * 10
			. = TRUE

		if("notify")
			GE.notify_admins = value
			. = TRUE

		if("move-up")
			gimmick_events.Swap(id, id-1)
			. = TRUE

		if("move-down")
			gimmick_events.Swap(id, id+1)
			. = TRUE

		if("active_step")
			active_stage = id
			. = TRUE

	active_stage = clamp(active_stage, 1, length(gimmick_events))

/obj/item/aiModule/ability_expansion/taser
	name = "CLF:Taser Expansion Module"
	desc = "A camera lense focus module.  This module allows for the AI controlled camera produce a taser like effect."
	lawText = "CLF:Taser EXPANSION MODULE"
	highlight_color = rgb(255, 251, 0, 255)
	ai_abilities = list(/datum/targetable/ai/module/camera_gun/taser)

/obj/item/aiModule/ability_expansion/laser
	name = "CLF:Laser Expansion Module"
	desc = "A camera lense focus module.  This module allows for the AI controlled camera produce a laser like effect."
	lawText = "CLF:Laser EXPANSION MODULE"
	highlight_color = rgb(255, 0, 0, 255)
	ai_abilities = list(/datum/targetable/ai/module/camera_gun/laser)

/obj/item/aiModule/ability_expansion/mfoam_launcher
	name = "Metal Foam Expansion Module"
	desc = "Chemical release module.  This module allows for the AI controlled camera to launch metal foam payloads."
	lawText = "MFoam EXPANSION MODULE"
	highlight_color = rgb(71, 92, 85, 255)
	ai_abilities = list(/datum/targetable/ai/module/chems/metal_foam)

/obj/item/aiModule/ability_expansion/friend_turret
	name = "Turret Expansion Module"
	desc = "A turret expansion module.  This module allows for control of turret."
	lawText = "TURRET EXPANSION MODULE"
	highlight_color = rgb(255, 255, 255, 255)
	ai_abilities = list(/datum/targetable/ai/module/turret/deploy, /datum/targetable/ai/module/turret/target, /datum/targetable/ai/module/turret/swap_bullets)
	var/obj/machinery/turret/friend/turret

	New()
		..()
		turret = new(src)

/datum/targetable/ai/module/turret/deploy
	name = "Deploy Turret"
	desc = "Conviently place a turret for fun and compliance."
	icon_state = "turret_deploy"
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return 1

		var/turf/floorturf = get_turf(target)
		var/x_coeff = rand(0, 1)	// open the floor horizontally
		var/y_coeff = !x_coeff // or vertically but not both - it looks weird
		var/slide_amount = 22 // around 20-25 is just wide enough to show most of the person hiding underneath

		var/obj/item/aiModule/ability_expansion/friend_turret/expansion = get_law_module()
		if(!expansion)
			return 1

		if (!floorturf.intact)
			boutput(holder.owner, "The floor is not intact here.  LAME!!!")
			return 1

		if(!checkTurfPassable(floorturf) && get_turf(target) != get_turf(expansion.turret))
			boutput(holder.owner, "Something is blocking a turret here.  LAME!!!")
			return 1

		if(expansion.turret.loc != expansion)
			var/turf/oldLoc = get_turf(expansion.turret)
			expansion.turret.popDown()
			if (oldLoc.intact)
				animate_slide(oldLoc, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)

				sleep(0.4 SECONDS)

				if(expansion.turret)
					expansion.turret.layer = MOB_LAYER
					expansion.turret.plane = PLANE_DEFAULT

					expansion.turret.set_density(0)
					expansion.turret.cover.set_density(0)
					expansion.turret.layer = BETWEEN_FLOORS_LAYER
					expansion.turret.plane = PLANE_FLOOR
					expansion.turret.cover.set_density(0)
					expansion.turret.cover.layer = BETWEEN_FLOORS_LAYER
					expansion.turret.cover.plane = PLANE_FLOOR

				if(oldLoc?.intact)
					animate_slide(oldLoc, 0, 0, 4)
			sleep(1.0 SECONDS)
			expansion.turret.set_loc(expansion)
			expansion.turret.cover.set_loc(expansion)

		if(get_turf(target) == get_turf(expansion.turret))
			expansion.turret.target = null
			icon_state = "turret_deploy"
			return

		expansion.turret.set_loc(floorturf)
		expansion.turret.cover.set_loc(floorturf)
		icon_state = "turret_undeploy"
		if (floorturf.intact)
			animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			sleep(0.4 SECONDS)
			expansion.turret.set_density(1)
			expansion.turret.cover.set_density(1)
			expansion.turret.layer = OBJ_LAYER
			expansion.turret.plane = PLANE_DEFAULT
			expansion.turret.cover.layer = OBJ_LAYER
			expansion.turret.cover.plane = PLANE_DEFAULT

		if(floorturf?.intact)
			animate_slide(floorturf, 0, 0, 4)

		if(expansion.turret.target)
			if(GET_DIST(expansion.turret, expansion.turret.target) > 10)
				expansion.turret.target = null

/datum/targetable/ai/module/turret/target
	name = "Assign Target"
	desc = "Assign a target for the turret"
	icon_state = "target"
	targeted = TRUE
	cooldown = 2 SECONDS

	cast(atom/target)
		if (..())
			return 1

		var/obj/item/aiModule/ability_expansion/friend_turret/expansion = get_law_module()
		if(!expansion)
			return 1

		var/mob/M = target

		if(target == expansion.turret.target)
			expansion.turret.target = null
			boutput(holder.owner, "Clearing active turret target.")
		else if(!isdead(M) && (iscarbon(M) || !ismobcritter(M)))
			expansion.turret.target = M
			logTheThing(LOG_COMBAT, holder.owner, "[key_name(holder.owner)] used <b>[src.name]</b> on [key_name(target)] [log_loc(holder.owner)].")

			boutput(holder.owner, "Deployable turret now targeting: [M.name].")
		else
			boutput(holder.owner, "Invalid target selected.")
/datum/targetable/ai/module/turret/swap_bullets
	name = "Change Lethality"
	desc = "Lethal to Non-Lethal and Non-Lethal to Lethal!"
	icon_state = "stun_turret"
	cooldown = 2 SECONDS

	cast(atom/target)
		. = ..()
		var/obj/item/aiModule/ability_expansion/friend_turret/expansion = get_law_module()
		expansion.turret.lasers = !expansion.turret.lasers
		var/mode = expansion.turret.lasers ? "LETHAL" : "STUN"
		logTheThing(LOG_COMBAT, holder.owner, "[key_name(holder.owner)] set deployable turret to [mode].")
		boutput(holder.owner, "Turret now set to [mode].")
		icon_state = expansion.turret.lasers ? "lethal_turret" : "stun_turret"
		expansion.turret.power_change()
/obj/machinery/turret/friend
	var/mob/target

/obj/machinery/turret/friend/process()
	src.target_list = list()
	if(target)
		if(!isdead(target) && (iscarbon(target) || !ismobcritter(target)))
			target_list |= target
	var/prev_enabled = src.enabled
	src.enabled = length(target_list) > 0
	if(prev_enabled != src.enabled)
		power_change()
	..()
	return

/obj/item/aiModule/ability_expansion/assisted_guidance
	name = "GPS Expansion Module"
	desc = "A prototype GPS path module.  This module provides for the direct crew members."
	lawText = "GPS EXPANSION MODULE"
	highlight_color = rgb(110, 110, 110, 255)
	ai_abilities = list(/datum/targetable/ai/module/gps_select)

/datum/abilityHolder/silicon/ai
	var/mob/assisted_target = null

/datum/targetable/ai/module/gps_select
	name = "Assisted Guidance"
	desc = "Provide a target a GPS path to a target location. Herd the cats."
	targeted = TRUE
	target_anything = FALSE
	icon_state = "gps"

	var/datum/targetable/ai/module/gps_direct
	var/mob/assisted

	New()
		. = ..()

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/silicon/ai/ai_holder = holder

		if(assisted)
			assisted.gpsToTurf(target, TRUE)
			target_anything = FALSE
			assisted = null
		else
			var/mob/possible_target = target
			if(possible_target.client)
				if (!locate(/obj/item/device/pda2) in possible_target)
					boutput(ai_holder.owner, SPAN_ALERT("Target does not have a PDA to use to assist!"))
					return 1

				assisted = target
				target_anything = TRUE

				ai_holder.owner.targeting_ability = src
				ai_holder.owner.set_cursor('icons/cursors/point.dmi')
				ai_holder.updateButtons()
				boutput(ai_holder.owner, SPAN_NOTICE("Select a destination for your target!"))
				return 1
			else
				boutput(ai_holder.owner, SPAN_ALERT("Not a valid target to assist!"))
				return 1


/turf/unsimulated/floor

	proc/update_ambient()
		var/obj/ambient/A = locate() in vis_contents
		if(A)
			if(A.color=="#222222")
				animate(A, color="#666666", time=10 SECONDS)
			else
				animate(A, color="#222222", time=10 SECONDS)

	proc/lightning(fadeout=3 SECONDS, flash_color="#ccf")
		var/obj/ambient/A = locate() in vis_contents
		if(A)
			var/old_color = A.color
			var/first_flash_low = "#666666"
			var/list/L1 = hex_to_rgb_list(A.color)
			var/list/L2 = hex_to_rgb_list(flash_color)
			if(!isnull(L1) && !isnull(L2))
				first_flash_low = rgb(lerp(L1[1],L2[1],0.8), lerp(L1[1],L2[1],0.8), lerp(L1[1],L2[1],0.8))

			A.color = flash_color
			animate(A, color=flash_color, time=0.5)
			animate(color=first_flash_low, time=0.75 SECONDS, easing = SINE_EASING)
			animate(color=flash_color, time=0.75)
			animate(color=old_color, time = fadeout, easing = SINE_EASING)
			playsound(src, pick('sound/effects/thunder.ogg','sound/ambience/nature/Rain_ThunderDistant.ogg'), 75, 1)
			SPAWN(fadeout + (1.5 SECONDS))
				A.color = old_color

	proc/color_shift_lights(colors, durations)
		var/obj/ambient/A = locate() in vis_contents
		if(A && length(colors) && length(durations))
			var/iterations = min(length(colors), length(durations))
			for(var/i in 1 to iterations)
				if(i==1)
					animate(A, color=colors[i], time=durations[i])
				else
					animate(color=colors[i], time=durations[i])

	proc/sunset()
		color_shift_lights(list("#AAA", "#c53a8b", "#b13333", "#444","#222"), list(0, 25 SECONDS, 25 SECONDS, 20 SECONDS, 25 SECONDS))

	proc/sunrise()
		color_shift_lights(list("#222", "#444","#ca2929", "#c4b91f", "#AAA", ), list(0, 10 SECONDS, 20 SECONDS, 15 SECONDS, 25 SECONDS))

	proc/set_color()
		var/color = input(usr, "Please select ambient light color.", "Color Menu") as color
		color_shift_lights(list(color), list(3 SECONDS))


ADMIN_INTERACT_PROCS(/turf/unsimulated/floor, proc/sunset, proc/sunrise, proc/set_color, proc/lightning)

/proc/get_cone(turf/epicenter, radius, angle, width, heuristic, heuristic_args)
	var/list/nodes = list()

	var/index_open = 1
	var/list/open = list(epicenter)
	var/list/next_open = list()
	var/list/heuristics = list() //caching is only valid if we arn't calculating based on the open node
	nodes[epicenter] = radius
	var/i = 0
	while (index_open <= length(open) || length(next_open))
		if(i++ % 500 == 0)
			LAGCHECK(LAG_HIGH)
		if(index_open > length(open))
			open = next_open
			next_open = list()
			index_open = 1
		var/turf/T = open[index_open++]
		var/value = nodes[T] - (1)
		var/value2 = nodes[T] - (1.4)
		if (heuristic) // Only use a custom hueristic if we were passed one
			if(isnull(heuristics[T]))
				heuristics[T] = call(heuristic)(T, heuristic_args)
			if(heuristics[T])
				value -= heuristics[T]
				value2 -= heuristics[T]
		if (value < 0)
			continue
		for (var/dir in alldirs)
			var/turf/target = get_step(T, dir)
			if (!target) continue // woo edge of map
			var/new_value = dir & (dir-1) ? value2 : value
			if(width < 360)
				var/diff = abs(angledifference(get_angle(epicenter, target), angle))
				if(diff > width)
					continue
				else if(diff > width/2)
					new_value = new_value / 3 - 1
			if ((nodes[target] && nodes[target] >= new_value))
				continue

			nodes[target] = new_value
			next_open[target] = 1

	for (var/turf/T as anything in nodes)
		if(nodes[T]<=0)
			nodes -= T

	return nodes

/datum/mutex
	var/locked

	proc/unlock()
		locked = FALSE

	proc/lock()
		while(!trylock())
			sleep(1)

	proc/trylock()
		if(!locked)
			locked = TRUE
			. = TRUE

	limited
		var/iterations
		var/maxIterations

		New(maxItrs)
			..()
			maxIterations = maxItrs

		trylock()
			if(iterations <= 0 && locked)
				locked = FALSE
			. = ..()
			if(.)
				iterations = maxIterations
			else
				iterations--

		unlock()
			iterations = 0
			..()

/obj/item/ammo/bullets/pipeshot/web
	sname = "web load"
	desc = "This appears to be some sticky webbing shoved into a few cut open pipe frames."
	ammo_type = new/datum/projectile/bullet/web
	icon_state = "makeshift_u"

	New()
		..()
		var/image/overlay = image(src.icon,"makeshift_o")
		overlay.color = "#eee"
		UpdateOverlays(overlay,"overlay")

/datum/pipeshotrecipe/web
	thingsneeded = 1
	result = /obj/item/ammo/bullets/pipeshot/web
	accepteditem = /obj/item/material_piece/cloth/spidersilk
	craftname = "web"

/datum/projectile/bullet/web
	name = "web slug"
	icon_state = "acidspit"
	color_icon = COLOR_MATRIX_GRAYSCALE
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	damage = 0
	stun = 10
	dissipation_rate = 5
	dissipation_delay = 3
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bullethole"
	casing = /obj/item/casing/shotgun/pipe

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			new /obj/icecube/web(get_turf(M), M)

/obj/icecube/web
	name = "bundle of web"
	desc = "A big wad of web. Someone seems to be stuck inside it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "web"
	health = 10
	steam_on_death = FALSE
	add_underlay = FALSE

	New(loc, mob/iced as mob)
		..()
		if(iced.rest_mult)
			icon_state = "web2"


/datum/projectile/special/shotchem/shells
	name = "chemical shot"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	casing = /obj/item/casing/shotgun/pipe
	max_range = 3
	damage = 0
	stun = 10
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT

	var/list/reagent_ids
	var/reagent_volume = 10
	var/chem_pct_app_tile = 0.3
	var/speed_mult = 1
	var/smoke_remaining = FALSE

	on_launch(obj/projectile/O)
		O.create_reagents(reagent_volume)
		if(islist(reagent_ids))
			for(var/R in reagent_ids)
				O.reagents.add_reagent(R, reagent_ids[R])

		O.special_data["speed_mult"] = speed_mult
		O.special_data["chem_pct_app_tile"] = chem_pct_app_tile

		O.special_data["IS_LIT"] = TRUE
		O.special_data["burn_temp"]	= 2500 KELVIN
		O.special_data["temp_pct_loss_atom"] = 0.3

		O.special_data["proj_color"] = O.reagents.get_average_color()
		O.color = O.reagents.get_average_rgb()
		. = ..()

	on_hit(atom/hit, direction, var/obj/projectile/P)
		..()
		P.die()

	on_end(obj/projectile/O)
		if(smoke_remaining && O.reagents.total_volume)
			smoke_reaction(O.reagents, 1, get_turf(O), do_sfx=FALSE)

/obj/item/ammo/bullets/pipeshot/chems
	sname = "chem load"
	desc = "This appears to be some chemical soaked wadding shoved into a few cut open pipe frames."
	icon_state = "makeshift_u"
	var/color_override = null

	New()
		..()
		var/image/overlay = image(src.icon,"makeshift_o")
		overlay.color = get_chem_color()
		UpdateOverlays(overlay,"overlay")

	proc/get_chem_color()
		var/datum/projectile/special/shotchem/shells/S = ammo_type
		if(color_override)
			. = color_override
		else if(istype(S))
			if(islist(S.reagent_ids))
				var/datum/reagents/mix = new(100)
				for(var/R in S.reagent_ids)
					mix.add_reagent(R, S.reagent_ids[R], donotreact=TRUE)
				. = mix.get_average_rgb()
				qdel(mix)
		if(!.)
			. = "#ffffff"

/datum/pipeshotrecipe/chem
	accepteditem = /obj/item/reagent_containers
	thingsneeded = 4
	var/list/reagents_req
	var/reagent_volume = 10

	check_match(obj/item/craftingitem)
		if(..() && length(reagents_req))
			var/obj/item/reagent_containers/RC = craftingitem
			if(RC.is_open_container())
				var/datum/reagents/R = new(100)
				RC.reagents.trans_to_direct(R, reagent_volume)
				. = TRUE
				for(var/required_reagent in reagents_req)
					. &&= R.has_reagent(required_reagent, reagents_req[required_reagent])
				R.trans_to(RC, R.total_volume)

	craftwith(obj/item/craftingitem, obj/item/frame, mob/user)
		if(check_match(craftingitem, TRUE))
			var/obj/item/reagent_containers/RC = craftingitem
			RC.reagents.trans_to(frame, reagent_volume)
			thingsneeded -= 1

			if (thingsneeded > 0)//craft successful, but they'll need more
				boutput(user, SPAN_NOTICE("You carefully pour some of [craftingitem] into \the [frame]. You feel like you'll need more to fill all the shells. "))

			if (thingsneeded <= 0) //check completion and produce shells as needed
				var/obj/item/ammo/bullets/shot = new src.result(get_turf(frame))
				user.put_in_hand_or_drop(shot)
				qdel(frame)

			. = TRUE

/obj/item/power_pack
	name = "battery pack"
	desc = "A portable battery that can be worn on the back, or hooked up to a compatible receptacle."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "power_pack"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "bp_security"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags = TABLEPASS | CONDUCT
	c_flags = ONBACK
	inventory_counter_enabled = 1

	New()
		. = ..()
		var/cell = new/obj/item/ammo/power_cell/self_charging/medium{max_charge = 300; recharge_rate = 10}
		AddComponent(/datum/component/cell_holder, new_cell=cell, chargable=TRUE, max_cell=300, swappable=FALSE)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		UpdateIcon()

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])

	equipped(mob/user, slot)
		. = ..()
		if (src.inventory_counter)
			src.inventory_counter.show_count()

/obj/item/power_pack/makeshift
	name = "makeshift battery pack"
	desc = "An array of cell batteries that can be worn on the back, or hooked up to a compatible receptacle."
	icon_state = "power_pack_a"

/obj/item/power_pack/test
	New()
		. = ..()
		new /obj/item/baton/power_pack(src.loc)
		new /obj/item/gun/energy/taser_gun/power_pack(src.loc)

/obj/item/ammo/power_cell/redirect/power_pack
	desc = "A passthrough power cell that has cables to hook directly into a power pack."
	target_type = /obj/item/power_pack

/obj/item/baton/power_pack
	desc = "A standard baton with a long cable to hook into a power pack."
	cell_type = /obj/item/ammo/power_cell/redirect/power_pack
	can_swap_cell = FALSE

/obj/item/gun/energy/taser_gun/power_pack
	cell_type = /obj/item/ammo/power_cell/redirect/power_pack
	can_swap_cell = FALSE

/obj/effect/station_projectile_relocator
	var/datum/projectile/current_projectile = new/datum/projectile/bullet/howitzer

	Crossed(atom/movable/AM)
		. = ..()
		var/obj/projectile/P = AM
		if(istype(P) && istype(P.proj_data, current_projectile))
			var/spread = 15
			var/turf/T = get_random_station_turf()
			var/rate = 10
			var/angle = ((rate*world.timeofday/100)%360 + 360)%360
			var/dir = angle_to_dir(angle)

			var/source_x = clamp(round(200*sin(angle)+150),2, world.maxx-2)
			var/source_y = clamp(round(200*cos(angle)+150),2, world.maxy-2)
			var/turf/turf_source = locate(source_x, source_y, Z_LEVEL_STATION)
			if(!ON_COOLDOWN(src, "warning", 20 SECONDS))
				command_alert("One or more high velocity masses are headed towards the station from the [dir2text(dir)].  Brace for possible impact.", "Warning: Prepare for impact.")

			message_admins("Projectile sent to station! From [log_loc(turf_source)] pointed at [log_loc(T)] with [angle]° [spread] spread.")
			shoot_projectile_ST_pixel_spread(turf_source, current_projectile, T, 0, 0 , spread)
			qdel(P)

/obj/effect/station_torpedo_relocator
	Crossed(atom/movable/AM)
		. = ..()

		if(ismob(AM) || istype(AM, /obj/storage/closet) || istype(AM, /obj/torpedo))
			var/spread = 5
			var/turf/station_turf = get_random_station_turf()
			var/rate = 10
			var/angle = ((rate*world.timeofday/100)%360 + 360)%360
			var/dir = angle_to_dir(angle)

			var/source_x = clamp(round(200*sin(angle)+150),2, world.maxx-2)
			var/source_y = clamp(round(200*cos(angle)+150),2, world.maxy-2)
			var/turf/turf_source = locate(source_x, source_y, Z_LEVEL_STATION)

			var/fire_angle = arctan(station_turf.y - turf_source.y, station_turf.x - turf_source.x)
			fire_angle = (fire_angle+rand(-spread+spread)+360)%360
			var/target_x = clamp(round(425*sin(fire_angle)+source_x),2, world.maxx-1) //425 for edge length to (300,300) from origin
			var/target_y = clamp(round(425*cos(fire_angle)+source_y),2, world.maxy-1)
			var/turf/turf_target = locate(target_x, target_y, Z_LEVEL_STATION)

			message_admins("[AM] sent to station! From [log_loc(turf_source)] [angle]° pointed at [log_loc(turf_target)] [fire_angle]°.")

			if(istype(AM, /obj/torpedo) && !ON_COOLDOWN(src, "warning", 20 SECONDS))
				command_alert("Unidentified missile detected from the [dir2text(dir)].  Brace for possible impact.", "Warning: Prepare for impact.")

			if(ismob(AM) || istype(AM, /obj/storage/closet))
				AM.throwing = FALSE
				AM.set_loc(turf_source)
				var/list/datum/thrown_thing/existing_throws = global.throwing_controller.throws_of_atom(AM)
				if(length(existing_throws))
					for(var/list/datum/thrown_thing/throw_data in existing_throws)
						global.throwing_controller.thrown -= throw_data
						qdel(throw_data)
				AM.throw_at(turf_target, 600, 2, thrown_from=turf_source)
			else if(istype(AM, /obj/torpedo))
				var/obj/torpedo/T = AM
				var/torpedo_dir = target_y > source_y ? NORTH : SOUTH  //angle_to_dir(fire_angle)
				T.target_turf = turf_target
				T.set_loc(turf_source)
				T.set_dir(torpedo_dir)
				T.lockdir = torpedo_dir

#ifdef MACHINE_PROCESSING_DEBUG
/datum/power_usage_viewer
	var/mob/target
	var/datum/machine_power_data/power_data

/datum/power_usage_viewer/New(mob/target)
	..()
	src.target = target
	power_data = detailed_power_data_last

/datum/power_usage_viewer/disposing()
	src.target = null
	src.power_data = null
	..()

/datum/power_usage_viewer/ui_state(mob/user)
	return tgui_admin_state

/datum/power_usage_viewer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PowerDebug")
		ui.open()

/datum/power_usage_viewer/ui_static_data(mob/user)
	. = list()
	if(power_data)
		.["areaData"] = list()
		for(var/area/A in power_data.areas)
			var/list/machine_data = list()
			for(var/obj/machinery/M in power_data.areas[A])
				machine_data[ref(M)] += list(
					"name" = M.name,
					"power_usage" = round(M.power_usage),
					"data" = power_data.machines[M]
				)
			.["areaData"][A.type] += list(
				"name" = A.name,
				"total" = round(A.area_apc?.lastused_total),
				"equip" = round(A.area_apc?.lastused_equip),
				"light" = round(A.area_apc?.lastused_light),
				"environ" = round(A.area_apc?.lastused_environ),
				"machines" = machine_data
			)

/datum/power_usage_viewer/ui_data()
	var/list/data = list()

	return data

/datum/power_usage_viewer/ui_act(action, list/params, datum/tgui/ui)
	USR_ADMIN_ONLY
	. = ..()
	if(.)
		return

	switch(action)
		if("jmp")
			var/obj/machinery/M = locate(params["ref"])
			if(istype(M) && target?.client?.holder)
				target.client.jumptoturf(get_turf(M))
#endif



/obj/effect/status_area
	name = "status area"
	layer = EFFECTS_LAYER_BASE
	var/status_effect = "time_slowed"
	var/mob/source

	New(turf/loc, mob/target)
		. = ..()
		if(target)
			src.source = target

	proc/check_movable(atom/movable/AM, crossed=TRUE)
		. = TRUE

	Crossed(atom/movable/AM)
		. = ..()
		if(check_movable(AM, TRUE))
			AM.changeStatus(status_effect, 20 SECONDS, src)

	Uncrossed(atom/movable/AM)
		. = ..()
		if(check_movable(AM, FALSE))
			AM.delStatus(status_effect)

/obj/effect/status_area/slow_globe
	name = "temporal sphere"
	icon = 'icons/effects/224x224.dmi'
	icon_state = "shockwave"
	pixel_x = -96
	pixel_y = -96
	bound_x = -64
	bound_y = -64
	bound_width = 160
	bound_height = 160
	status_effect = "time_slowed"
	var/hue_shift = 0
	var/sound = 'sound/effects/mag_forcewall.ogg'
	var/pitch

	New(turf/loc, mob/target)
		. = ..()
		if(hue_shift)
			color = hsv_transform_color_matrix(hue_shift)
		SafeScale(0.1,0.1)
		SafeScaleAnim((10/1.4), (10/1.4), anim_time=2 SECONDS, anim_easing=ELASTIC_EASING)
		SPAWN(2 SECONDS)
			animate_wave(src, waves=5)
		playsound(get_turf(src), sound, 25, 1, -1, pitch)

	check_movable(atom/movable/AM, crossed)
		if(crossed)
			if(AM != src.source)
				if(ismob(AM) || AM.throwing || istype(AM, /obj/projectile))
					. = TRUE
		else
			if(ismob(AM) || AM.throwing || istype(AM, /obj/projectile))
				if(!locate(/obj/effect/status_area/slow_globe) in obounds(AM,0))
					. = TRUE


	strong
		status_effect = "time_slowed_plus"
		hue_shift = 60

	reversed
		status_effect = "time_hasted"
		hue_shift = 90
		pitch = -1


/datum/statusEffect/time_slowed
	id = "time_slowed"
	name = "Slowed"
	desc = "You are slowed by a temporal anomoly.<br>Movement speed and action speed is reduced."
	icon_state = "slowed"
	unique = 1
	var/howMuch = 10
	exclusiveGroup = "temporal"
	movement_modifier = new /datum/movement_modifier/status_slowed
	effect_quality = STATUS_QUALITY_NEGATIVE
	move_triggered = TRUE
	var/atom/status_source

	onAdd(source)
		. = ..()
		if(source)
			status_source = source

		var/atom/movable/AM = owner
		var/scale_factor = (howMuch/2)
		if(howMuch<0)
			scale_factor = -1/scale_factor

		if (ismob(owner))
			var/mob/M = owner
			M.next_click = world.time + (0.5 SECONDS)
			movement_modifier.additive_slowdown = howMuch

		else if(istype(AM, /obj/projectile))
			var/obj/projectile/B = AM
			B.internal_speed = B.proj_data.projectile_speed / scale_factor
			B.special_data["slowed"] = TRUE

		if(istype(AM) && AM.throwing)
			var/list/datum/thrown_thing/existing_throws = global.throwing_controller.throws_of_atom(AM)
			for(var/datum/thrown_thing/T in existing_throws)
				T.speed /= scale_factor
			AM.throw_speed /= scale_factor

	onRemove()
		. = ..()
		var/atom/movable/AM = owner
		var/scale_factor = (howMuch/2)
		if(howMuch<0)
			scale_factor = -1/scale_factor

		if (ismob(owner))
			var/mob/M = owner
			var/atom/source = locate(/obj/effect/status_area/slow_globe) in obounds(M,0)
			if(source)
				M.changeStatus("time_slowed", 10 SECONDS, source)
		else if(istype(AM, /obj/projectile))
			var/obj/projectile/B = AM
			if(B?.special_data && B.special_data["slowed"])
				B.internal_speed *= scale_factor

		if(istype(AM) && AM.throwing)
			var/list/datum/thrown_thing/existing_throws = global.throwing_controller.throws_of_atom(AM)
			for(var/datum/thrown_thing/T in existing_throws)
				T.speed *= scale_factor
			AM.throw_speed *= scale_factor

	onUpdate(timePassed)
		. = ..()
		if(status_source && QDELETED(status_source))
			owner.delStatus(id)

		if (ismob(owner))
			var/mob/M = owner
			M.next_click = world.time + ((howMuch/20) SECONDS)

	move_trigger(mob/user, ev)
		if (ismob(owner))
			var/mob/M = owner
			M.next_click = world.time + ((howMuch/20) SECONDS)

	extra
		name = "Sloooowwwwed"
		id = "time_slowed_plus"
		howMuch = 20

	reversed
		name = "Hastened"
		id = "time_hasted"
		howMuch = -5



/obj/storage/crate/exosuit
	name = "experimental crate"
	desc = "A protective equipment case."

	qm
	medic
	janitor
	atmos
	clown
	runner
	defender
	flippers
	space

/obj/item/clothing/shoes/dress_shoes/dance
	desc = "A worn pair of suide soled shoes."

	equipped(var/mob/user, var/slot)
		if (slot == SLOT_SHOES)
			var/datum/abilityHolder/dancing/AH = user.get_ability_holder(/datum/abilityHolder/dancing)
			if(!AH)
				user.add_ability_holder(/datum/abilityHolder/dancing)
			SPAWN(0) // cargo culted
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if (H.hud)
						H.hud.update_ability_hotbar()
		..()

	unequipped(var/mob/user)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.hud)
				H.hud.update_ability_hotbar()
		..()

/obj/item/clothing/shoes/dress_shoes/dance/test
	desc = "A worn pair of suide soled shoes."

	New(newLoc)
		..()
		new /mob/living/carbon/human/normal/assistant(newLoc)

