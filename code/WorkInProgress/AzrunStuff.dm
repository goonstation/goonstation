/obj/item/deconstructor/admin_crimes
	// do not put this anywhere anyone can get it. it is for crime.
	name = "(de/re)-construction device"
	desc = "A magical saw-like device for unmaking things. Is that a soldering iron on the back?"

	New()
		..()
		setMaterial(getMaterial("miracle"))

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (!isobj(target))
			return
		if(istype(target, /obj/item/electronics/frame))
			var/obj/item/electronics/frame/F = target
			F.deploy(user)

		finish_decon(target, user)

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

/obj/item/storage/desk_drawer/azrun/
	spawn_contents = list(	/obj/item/raw_material/molitz_beta,\
	/obj/item/raw_material/molitz_beta,\
	/obj/item/raw_material/plasmastone,\
	/obj/item/organ/lung/plasmatoid/left,\
	/obj/item/pen/crayon/red,\

)
/obj/table/wood/auto/desk/azrun
	New()
		..()
		var/obj/item/storage/desk_drawer/azrun/L = new(src)
		src.desk_drawer = L


/obj/item/storage/toilet/goldentoilet/azrun
	name = "thinking throne"
	icon_state = "goldentoilet"
	desc = "A wonderful place to send bad ideas...  Clogged more often than not."
	dir = NORTH

/datum/manufacture/sub/treads
	name = "Vehicle Treads"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(5,2)
	item_outputs = list(/obj/item/shipcomponent/locomotion/treads)
	time = 5 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/sub/wheels
	name = "Vehicle Wheels"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(5,2)
	item_outputs = list(/obj/item/shipcomponent/locomotion/wheels)
	time = 5 SECONDS
	create = 1
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

		if (POT.growth > (P.harvtime + DNA?.get_effective_value("harvtime") + 10))
			for (var/mob/living/X in view(1,POT.loc))
				if(isalive(X) && !iskudzuman(X))
					poof(X, POT)
					break

	HYPattacked_proc(obj/machinery/plantpot/POT, mob/user)
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.harvtime + DNA?.get_effective_value("harvtime") + 10))
			if(!iskudzuman(user))
				poof(user, POT)

	proc/poof(atom/movable/AM, obj/machinery/plantpot/POT)
		if(!ON_COOLDOWN(src,"spore_poof", 2 SECONDS))
			var/datum/plantgenes/DNA = POT.plantgenes
			var/datum/reagents/reagents_temp = new/datum/reagents(max(1,(50 + DNA.cropsize))) // Creating a temporary chem holder
			reagents_temp.my_atom = POT

			for (var/plantReagent in assoc_reagents)
				reagents_temp.add_reagent(plantReagent, 2 * round(max(1,(1 + DNA?.get_effective_value("potency") / (10 * length(assoc_reagents))))))

			SPAWN(0) // spawning to kick fluid processing out of machine loop
				reagents_temp.smoke_start()
				qdel(reagents_temp)

			POT.growth = clamp(POT.growth/2, src.growtime, src.harvtime-10)
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

	proc/alter_projectile(var/obj/projectile/P)
		if (!P.reagents)
			P.reagents = new /datum/reagents(P.proj_data.cost)
			P.reagents.my_atom = P
		for (var/plantReagent in assoc_reagents)
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

		if (POT.growth > (P.harvtime + DNA?.get_effective_value("harvtime") + 5))
			var/list/stuffnearby = list()
			for (var/mob/living/X in view(7,POT.loc))
				if(isalive(X) && (X != POT.loc) && !iskudzuman(X))
					stuffnearby += X
			if(length(stuffnearby))
				var/mob/living/target = pick(stuffnearby)
				var/datum/callback/C = new(src, .proc/alter_projectile)
				if(prob(10))
					shoot_projectile_ST(POT, projectile, get_step(target, pick(ordinal)), alter_proj=C)
				else
					shoot_projectile_ST(POT, projectile, target, alter_proj=C)
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
	implanted = /obj/item/implant/projectile/spitter_pod

/obj/item/implant/projectile/spitter_pod
	name = "strange seed pod"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	desc = "A small hollow pod."
	icon_state = "seedproj"

	var/heart_ticker = 10
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
		heart_ticker = max(heart_ticker--,0)
		if(heart_ticker & prob(50))
			if(prob(30))
				boutput(src.owner,"<span class='alert'>You feel as though something moving towards your heart... That can't be good.</span>")
			else
				boutput(src.owner,"<span class='alert'>You feel as though something is working its way through your chest.</span>")
		else if(!heart_ticker)
			var/mob/living/carbon/human/H = src.owner
			if(istype(H))
				H.organHolder.damage_organs(2, 0, 1, "heart")
			else
				src.owner.TakeDamage("All", 2, 0)

			if(prob(5))
				boutput(src.owner,"<span class='alert'>AAHRRRGGGG something is trying to dig your heart out from the inside?!?!</span>")
				src.owner.emote("scream")
				src.owner.changeStatus("stunned", 2 SECONDS)
			else if(prob(10))
				boutput(src.owner,"<span class='alert'>You feel a sharp pain in your chest.</span>")

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
	flags = FPRINT | FLUID_SUBMERGE | TGUI_INTERACTIVE

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
			SETUP_GENERIC_ACTIONBAR(user, src, AE.duration, .proc/complete_stage, list(user, null), null, null, null, null)
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
			SETUP_GENERIC_ACTIONBAR(user, src, AE.duration, .proc/complete_stage, list(user, W), W.icon, W.icon_state, null, null)

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
			gimmick_events = list()
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
	icon_state = "ai_template"
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
			return

		expansion.turret.set_loc(floorturf)
		expansion.turret.cover.set_loc(floorturf)
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
	desc = "Assign a target for the target"
	icon_state = "ai_template"
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
	icon_state = "ai_template"
	cooldown = 2 SECONDS

	cast(atom/target)
		var/obj/item/aiModule/ability_expansion/friend_turret/expansion = get_law_module()
		expansion.turret.lasers = !expansion.turret.lasers
		var/mode = expansion.turret.lasers ? "LETHAL" : "STUN"
		logTheThing(LOG_COMBAT, holder.owner, "[key_name(holder.owner)] set deployable turret to [mode].")
		boutput(holder.owner, "Turret now set to [mode].")
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
