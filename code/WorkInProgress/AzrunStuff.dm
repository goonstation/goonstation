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

		if (POT.growth > (P.harvtime + DNA.harvtime + 10))
			for (var/mob/living/X in view(1,POT.loc))
				if(isalive(X) && !iskudzuman(X))
					poof(X, POT)
					break

	HYPattacked_proc(obj/machinery/plantpot/POT, mob/user)
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.harvtime + DNA.harvtime + 10))
			if(!iskudzuman(user))
				poof(user, POT)

	proc/poof(atom/movable/AM, obj/machinery/plantpot/POT)
		if(!ON_COOLDOWN(src,"spore_poof", 2 SECONDS))
			var/datum/plantgenes/DNA = POT.plantgenes
			var/datum/reagents/reagents_temp = new/datum/reagents(max(1,(50 + DNA.cropsize))) // Creating a temporary chem holder
			reagents_temp.my_atom = POT

			for (var/plantReagent in assoc_reagents)
				reagents_temp.add_reagent(plantReagent, 2 * round(max(1,(1 + DNA.potency / (10 * length(assoc_reagents))))))

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

		if (POT.growth > (P.harvtime + DNA.harvtime + 5))
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
<<<<<<< HEAD



/*=========================*/
/*------Ghost Brain--------*/
/*=========================*/

/datum/manufacture/ghost_brain // Move to manufacturing.dm
	name = "Ghost Intelligence Core"
	item_paths = list("MET-1","CON-1","ALL", "soulsteel")
	item_amounts = list(6,5,3,5)
	item_outputs = list(/obj/item/organ/brain/ghost)
	time = 45 SECONDS
	create = 1
	category = "Component"

/obj/item/paper/manufacturer_blueprint/ghost_brain
	blueprint = /datum/manufacture/ghost_brain

/obj/item/organ/brain/ghost // Move to brain.dm
	name = "Ghost Intelligence Core"
	desc = "A brain shaped mass of silicon, soulsteel, and LED lights. Attempts to hold onto soul to give life to something else."
	icon_state = "ghost_brain"
	item_state = "ai_brain"
	created_decal = /obj/decal/cleanable/oil
	made_from = "pharosium"
	var/activated = 0
	var/lastTrigger
	var/datum/movement_controller/ghost_brain/MC
	var/obj/item/organ/brain/old_brain

	New()
		..()
		MC = new

	get_desc(dist, mob/user)
		if (user?.traitHolder?.hasTrait("training_medical"))
			if (activated)
				if (src.owner?.key)
					if (!find_ghost_by_key(src.owner?.key))
						. += "<br><span class='notice'>[src]'s indicators show that it once had a conciousness captured, but that conciousness cannot be located.</span>"
					else
						. += "<br><span class='notice'>[src]'s indicators show that it is still operational, and can be installed into a new body immediately.</span>"
				else
					. += "<br><span class='alert'>[src] has powered down fully.</span>"
			else
				. += "<br><span class='alert'>[src] is brand new. No conciousness has entered it yet.</span>"

	attack_self(mob/user as mob)
		if(activated && src.owner?.key && istype(owner.current, /mob/dead/observer))
			if(alert(user, "Are you sure you want to release the ghost?", "Release Ghost?", "Yes", "No") == "Yes")
				boutput(owner.current, "<span class='notice'>You no longer feel anchored to [src]!</span>")
				owner.current.delStatus("bound_ghost")
				if(old_brain)
					owner.brain = old_brain // attempt to restore to previous brain?
				owner = null

	on_life()
		var/mob/living/M = holder.donor
		if(!ishuman(M)) // silicon shouldn't have these problems
			return

		if(M.client && (isnull(M.client.color) || M.client.color == "#FFFFFF") && !ON_COOLDOWN(src,"ghost_eyes", 5 MINUTES))
			boutput(M,"<span class='alert'>Your vision starts to change as your connection this body wavers.</span>")
			animate(M.client, color=COLOR_MATRIX_GRAYSCALE, time=5 SECONDS, easing=SINE_EASING)
			animate(color=COLOR_MATRIX_IDENTITY, time=30 SECONDS, easing=SINE_EASING)
		if(prob(1))
			boutput(M,"<span class='alert'>You find you lose control of your body for a moment...</span>")
			M.changeStatus("paralysis", 2 SECONDS)
		if(prob(1))
			boutput(M,"<span class='alert'>You suddenly feel sluggish as though your connection to your body isn't as strong.</span")
			M.changeStatus("slowed", 8 SECONDS, 2)

	get_movement_controller()
		.= MC

	Crossed(atom/movable/AM)
		..()

		var/mob/dead/observer/O = AM
		if(!src.owner && !GET_COOLDOWN(src,"ghost_suck") && istype(O))
			if(jobban_isbanned(O, "Ghostbrain"))
				boutput(O, "<span class='notice'>Sorry, you are banned from playing a ghostbrain.</span>")
				return
			if(O.can_respawn_as_ghost_critter()) // Azrun TODO New func with more apporpriate verbage?
				actions.start(new/datum/action/bar/capture_ghost(O), src)
				ON_COOLDOWN(src, "ghost_suck", 2 SECONDS)

	Entered(atom/movable/A,atom/OldLoc)
		. = ..()
		var/mob/dead/observer/O = A
		if(MC && istype(O) )
			O.use_movement_controller = src
			O.setStatus("bound_ghost", duration = 2 MINUTES, optional=list("anchor"=src, "client"=O.client))
			if (istype(O.abilityHolder, /datum/abilityHolder/ghost_observer))
				var/datum/abilityHolder/ghost_observer/GH = O.abilityHolder
				GH.disable(TRUE)
				GH.updateButtons()

	Exited(atom/movable/A,atom/OldLoc)
		. = ..()
		var/mob/dead/observer/O = A
		if(istype(O) && O.use_movement_controller == src)
			O.use_movement_controller = null

		if (istype(O) && istype(O.abilityHolder, /datum/abilityHolder/ghost_observer))
			var/datum/abilityHolder/ghost_observer/GH = O.abilityHolder
			GH.disable(FALSE)
			GH.updateButtons()

/obj/item/organ/brain/ghost/boreing
	color = "#F99"

	var/revives = 1

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		if(src.owner == user.mind)
			if(..() && revives)
				revives--
				if (M.stat > 1)
					setalive(M)

			else if (isdead(M) && M.organHolder.head.scalp_op_stage <= 3.0)
				playsound(M, "sound/impact_sounds/Slimy_Cut_1.ogg", 50, 1)

				if (M.organHolder.brain)
					src.tri_message(M, "<span class='alert'><b>[src]</b> severs [M]'s brain's connection to the spine!</span>",\
						"<span class='alert'>You sever [M]'s brain's connection to the spine!</span>",\
						"<span class='alert'><b>[src]</b> severs your brain's connection to the spine!</span>")

					M.organHolder.drop_organ("brain")
				else
					// If the brain is gone, but the suture site was closed and we're re-opening
					src.tri_message(M, "<span class='alert'><b>[src]</b> cuts open [M]'s brain cavity!</span>",\
						"<span class='alert'>You cut open [M]'s brain cavity!</span>",\
						"<span class='alert'><b>[src]</b> cuts open your brain cavity!</span>")

				var/damage_low = rand(5,15)
				M.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(M, user, damage_low, surgery_bleed = 1)
				logTheThing(LOG_COMBAT, user, "removed [constructTarget(M,"combat")]'s brain with [src].")
				M.death()
				M.organHolder.head.scalp_op_stage = 4
		else
			. = ..()

	can_attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		if(src.owner == user.mind)
			/* Checks if an organ can be attached to a target mob */
			if (istype(/obj/item/organ/chest/, src))
				// We can't transplant a chest
				return 0

			if (!in_interact_range(src, user))
				return 0

			var/mob/living/carbon/human/H = M
			if (!H.organHolder)
				return 0

			return 1
		else
			. = ..()

/datum/action/bar/capture_ghost
	id = "capture_ghost"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 5 SECONDS
	var/mob/dead/observer/target
	var/image/pulling

	New(mob/dead/observer/O)
		..()
		if (istype(O))
			target = O
		if(!pulling)
			pulling = image('icons/effects/effects.dmi',"pulling",pixel_y=16)
			pulling.alpha = 200

	onUpdate()
		..()
		var/obj/item/organ/brain/ghost/B = owner
		if(GET_DIST(target,owner) != 0)
			interrupt(INTERRUPT_ALWAYS)
		if(B.owner)
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		boutput(target, "<span class='notice'>You feel yourself being pulled into [owner]!</span>")
		owner.UpdateOverlays(pulling, id)

	onEnd()
		..()
		var/obj/item/organ/brain/ghost/B = owner
		if(target.observe_round) return
		if(B && !B.owner && target.client)
			B.activated = TRUE
			playsound(B, "sound/effects/suck.ogg", 20, TRUE, 0, 0.9)
			B.old_brain = target.mind.brain
			B.setOwner(target.mind)
			target.set_loc(B)

	onDelete()
		..()
		owner.ClearSpecificOverlays(id)


/datum/movement_controller/ghost_brain
	var/next_move = 0
	var/mc_delay = 20

	keys_changed(mob/user, keys, changed)
		var/do_step = TRUE
		var/obj/O = user.loc
		if(istype(O))
			if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT))
				var/move_x = 0
				var/move_y = 0
				if (keys & KEY_FORWARD)
					move_y += 1
				if (keys & KEY_BACKWARD)
					move_y -= 1
				if (keys & KEY_RIGHT)
					move_x += 1
				if (keys & KEY_LEFT)
					move_x -= 1
				if (move_x || move_y)
					if(!user.move_dir && user.canmove && user.restrained())
						if (user.pulled_by || length(user.grabbed_by))
							boutput(user, "<span class='notice'>You're restrained! You can't move!</span>")
							do_step = FALSE

					user.move_dir = angle2dir(arctan(move_y, move_x))
					var/old_loc = O.loc
					if(do_step)
						attempt_move(user)

					if(old_loc == O.loc)
						if(!ON_COOLDOWN(user,"ghost_glow", 5 SECONDS))
							O.visible_message("[O] glows brightly momentarily.")
						if(!ON_COOLDOWN(user,"ghost_wiggle", 1 SECONDS))
							animate(O, time=0.5 SECONDS, pixel_x=move_x, pixel_y=move_y, flags=ANIMATION_RELATIVE)
							animate(pixel_x=-move_x, pixel_y=-move_y, time=0.2 SECONDS, flags=ANIMATION_RELATIVE)

				else
					user.move_dir = 0

			if(!user.dir_locked)
				user.set_dir(user.move_dir)
			if (changed & (KEY_THROW|KEY_PULL|KEY_POINT|KEY_EXAMINE|KEY_BOLT|KEY_OPEN|KEY_SHOCK)) // bleh
				user.update_cursor()

	process_move(mob/user, keys)
		set waitfor = 0

		var/obj/O = user.loc
		var/old_loc = O.loc
		var/delay = src.mc_delay

		if (next_move - world.time >= world.tick_lag / 10)
			return max(world.tick_lag, (next_move - world.time) - world.tick_lag / 10)

		if(!isturf(old_loc))
			return // You are subject to the whims of the holder

		if (user.move_dir)
			if (user.move_dir & (user.move_dir-1))
				delay *= DIAG_MOVE_DELAY_MULT
			var/glide = (world.icon_size / ceil(delay / world.tick_lag))
			O.glide_size = glide // dumb hack: some Move() code needs glide_size to be set early in order to adjust "following" objects
			O.animate_movement = SLIDE_STEPS
			step(O, user.move_dir)
			if (O.loc != old_loc)
				O.OnMove()
				. = TRUE
			O.glide_size = glide // but Move will auto-set glide_size, so we need to override it again

			next_move = world.time + delay

/datum/statusEffect/bound_ghost
	id= "bound_ghost"
	var/atom/bound_target
	var/client/target_client
	move_triggered = TRUE
	onAdd(optional)
		..()
		var/list/statusargs = optional
		if(statusargs["anchor"])
			bound_target = statusargs["anchor"]
		if(statusargs["client"])
			target_client = statusargs["client"]

	onUpdate()
		..()
		get_back_here()

	move_trigger(mob/user, ev)
		. = 0
		get_back_here()

	proc/get_back_here()
		var/mob/dead/observer/ghost = owner
		if(istype(ghost) && bound_target && ghost.loc != bound_target)
			boutput(ghost, "<span class='notice'>You find yourself pulled back into [bound_target]!</span>")
			ghost.set_loc(bound_target)

	onRemove()
		..()
		var/mob/dead/observer/ghost = owner
		if(istype(ghost) && ghost.mind && bound_target && ghost.loc == bound_target)
			ON_COOLDOWN(bound_target, "ghost_suck", 2 SECONDS)
			ghost.set_loc(get_turf(bound_target))


/obj/item/organ/brain/ghost/afterattack(atom/target, mob/user)
	if(istype(target, /obj/machinery/bot))
		target.AddComponent(/datum/component/brain_control, src, user)

/obj/item/organ/brain/ghost/mouse_drop(atom/over_object, src_location, over_location, over_control, params)
	if(istype(over_object, /obj/machinery/bot))
		afterattack(over_object, usr)

/datum/component/brain_control
	var/orig_path
	var/obj/item/organ/brain/controller

TYPEINFO(/datum/component/brain_control)
	initialization_args = list()

TYPEINFO(/datum/component/controlled_by_mob)
	initialization_args = list(
		ARG_INFO("B", DATA_INPUT_REFPICKER, "Brain to enter"),
		ARG_INFO("user", DATA_INPUT_MOB_REFERENCE, "Mob to control the component")
	)

/datum/component/brain_control/Initialize(obj/item/organ/brain/B, mob/user)
	var/atom/target = parent
	if(!istype(target))
		return COMPONENT_INCOMPATIBLE

	orig_path = parent.type
	if(istype(B))
		controller = B
	else
		return COMPONENT_INCOMPATIBLE

	// /obj/machinery/bot/medbot  TODO?
	// /obj/machinery/bot/cleanbot <-> /mob/living/critter/robotic/bot/cleanbot
	// /obj/machinery/bot/firebot <-> /mob/living/critter/robotic/bot/firebot
	// /obj/machinery/bot/floorbot  TODO?
	var/obj/machinery/bot/new_bot
	if(istype(target, /obj/machinery/bot)) // Maybe move to /obj/machinery/bot to get mapping out of here
		if(istype(target, /obj/machinery/bot/cleanbot ))
			new_bot = new /mob/living/critter/robotic/bot/cleanbot(target.loc)
		else if(istype(target, /obj/machinery/bot/firebot ))
			new_bot = new /mob/living/critter/robotic/bot/firebot(target.loc)

	if(new_bot)
		qdel(target)
		parent = new_bot
		RegisterSignal(parent, list(COMSIG_ATOM_POST_UPDATE_ICON), .proc/update_icon)
		RegisterSignal(parent, list(COMSIG_ATTACKBY), .proc/check_attack)

		if (controller.owner) //Mind transfer also handles key transfer.
			controller.owner.transfer_to(new_bot)
		user.u_equip(controller)
		controller.set_loc(new_bot)
		new_bot.UpdateIcon()
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/brain_control/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATTACKBY, COMSIG_ATOM_POST_UPDATE_ICON))
	. = ..()

/datum/component/brain_control/proc/update_icon(atom/A)
	var/image/I = A.SafeGetOverlayImage("brain",image('icons/obj/items/device.dmi', "head-brain"))
	I.appearance_flags = RESET_COLOR | KEEP_APART | PIXEL_SCALE
	if(istype(parent, /mob/living/critter/robotic/bot/cleanbot))
		I.pixel_x = -3
		I.pixel_y = 3
	else if(istype(parent, /mob/living/critter/robotic/bot/firebot ))
		I.pixel_x = -5
		I.pixel_y = 2

	var/mob/M = A
	if(controller)
		if(controller.owner || M.mind )
			I.icon_state = "head-brain"
		else
			I.icon_state = "head-nobrain"
	else
		I = null

	A.UpdateOverlays(I,"brain")

/datum/component/brain_control/proc/check_attack(mob/M, obj/item/thing, mob/user)
	if(ispryingtool(thing))
		actions.start(new /datum/action/bar/icon/callback(user, M, 3 SECONDS, /datum/component/brain_control/proc/detach, list(M, thing, user), \
					thing.icon, thing.icon_state, end_message="[user] successfully pries [thing] free from \the [M]!", call_proc_on=src), user)

		return ATTACK_PRE_DONT_ATTACK

/datum/component/brain_control/proc/detach(mob/M, obj/item/thing, mob/user)
	if(controller)
		controller.setOwner(M.mind)
		controller.set_loc(M.loc)

	M.ghostize()

	if(ispath(orig_path))
		new orig_path(M.loc)
	qdel(parent)
	qdel(src)
=======
>>>>>>> upstream/master
