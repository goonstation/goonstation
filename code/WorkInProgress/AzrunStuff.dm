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

	attack_hand(mob/user as mob)
		var/datum/gimmick_event/AE = get_active_event()

		if(!AE)
			..()
		else if(AE.interaction == 0)
			SETUP_GENERIC_ACTIONBAR(user, src, AE.duration, .proc/complete_stage, list(user, null), null, null, null, null)
		else
			..()

	attackby(obj/item/W as obj, mob/user as mob)

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

/obj/item/golf_club
	name = "golf club"
	desc = "A metal rod, a curved face, and a grippy synthrubber grip.  Probably good at getting objects to go someplace else."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "club"
	item_state = "rods"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = W_CLASS_NORMAL
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	max_stack = 50
	stamina_damage = 20
	stamina_cost = 16
	stamina_crit_chance = 30
	rand_pos = 1
	var/obj/item/golf_ball/ball
	var/obj/ability_button/swing = new /obj/ability_button/golf_swing

	random
		New(turf/newLoc)
			..()
			color = pick("#f44","#942", "#4f4","#296", "#44f","#429")

	test
		New(turf/newLoc)
			..()
			new /obj/item/golf_ball(newLoc)
			new /obj/item/storage/golf_goal(newLoc)

	afterattack(obj/O as obj, mob/user as mob)
		var/obj/item/golf_ball/B = O
		if(istype(B))
			step(user, get_dir(user, O))
			animate(user, pixel_x=O.pixel_x, pixel_y=O.pixel_y, 2 SECONDS, easing=CUBIC_EASING | EASE_OUT)
			SPAWN(1 SECONDS)
				if(GET_DIST(O, user) == 0)
					ball = O
					swing.the_mob = user
					swing.the_item = src
					user.targeting_ability = swing
					user.update_cursor()

/obj/ability_button/golf_swing
	name = "Swing"
	icon_state = "shieldceoff"
	targeted = 1 //does activating this ability let you click on something to target it?
	target_anything = 1 //can you target any atom, not just people?
	var/datum/projectile/ballshot = new /datum/projectile/special/golfball

	execute_ability(atom/target, params)
		var/obj/item/golf_club/C = the_item
		if(GET_DIST(C,C.ball) > 0 || GET_DIST(C,the_mob) > 0 )
			return

		if(istype(C) && C.ball)
			C.ball.set_loc(C)
		else
			return

		var/debug = istype(C, /obj/item/golf_club/test)

		var/pox = text2num(params["icon-x"]) - 16
		var/poy = text2num(params["icon-y"]) - 16
		var/swing_strength = sqrt(((target.x - the_mob.x) * 32 + pox)**2 + ((target.y - the_mob.y) * 32 + poy)**2)
		swing_strength /= 32

		var/mod_x = (rand()-0.5)* 5 * swing_strength
		var/mod_y = (rand()-0.5)* 5 * swing_strength

		if(debug)
			boutput(the_mob, "Swing Strength:[swing_strength] RNG [mod_x]x[mod_y]")

		ballshot.max_range = swing_strength + ((rand()-0.5) * 3)

		var/obj/projectile/P = shoot_projectile_ST_pixel(the_mob, ballshot, target, pox+mod_x, poy+mod_y)
		if (P)
			P.targets = list(target)
			P.mob_shooter = the_mob
			P.shooter = the_mob
			if(debug)
				P.color = the_item.color
			else
				P.color = C.ball.color

			P.special_data["ball"] = C.ball
			P.special_data["debug"] = debug
			P.proj_data.RegisterSignal(P, list(COMSIG_MOVABLE_MOVED), /datum/projectile/special/golfball/proc/check_newloc)

		animate(the_mob, pixel_x=0, pixel_y=0, 1 SECONDS, easing=CUBIC_EASING)

/datum/projectile/special/golfball
	name = "golf ball"
	sname = "golf ball"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "golf_ball"
	shot_sound = null
	power = 0
	cost = 1
	power = 0
	ks_ratio = 0
	damage_type = D_SPECIAL
	hit_type = DAMAGE_BLUNT
	dissipation_delay = 0
	dissipation_rate = 0
	ks_ratio = 1
	projectile_speed = 20
	hit_ground_chance = 100
	goes_through_walls = 0 // It'll stop homing when it hits something, then go bouncy
	var/max_bounce_count = 25 // putting the I in ICEE BEEYEM
	var/weaken_length = 4 SECONDS
	var/slam_text = "The golf ball SLAMS into you!"
	var/hit_sound = 'sound/effects/mag_magmisimpact_bounce.ogg'
	var/last_sound_time = 0

	proc/check_newloc(obj/projectile/O, atom/NewLoc)
	// set_loc(atom/newloc)
		var/obj/item/storage/golf_goal = locate() in NewLoc
		if(golf_goal)
			O.collide(golf_goal)
		for(var/atom/A in NewLoc.contents)
			if (isobj(A) && !A.density)
				if (istype(A, /obj/overlay) || istype(A, /obj/effects)) continue
				if (HAS_ATOM_PROPERTY(A, PROP_ATOM_NEVER_DENSE)) continue
				if(A.invisibility > INVIS_NONE) continue
				if(A.mouse_opacity)
					O.collide(A)

	on_pre_hit(var/atom/hit, var/angle, var/obj/projectile/O)
		if(ismob(hit) || iscritter(hit))
			O.visible_message("[O] bounces off of [hit].  Oops...")

		if(!hit.density)
			var/obj/item/I = hit
			if(istype(I))
				if(prob(I.w_class * 10))
					. = TRUE
				else
					O.visible_message("[O] bounces off of [hit].")
					hit_twitch(hit)

	on_hit(atom/A, direction, var/obj/projectile/projectile)
		. = ..()
		if(projectile.reflectcount < src.max_bounce_count)
			var/obj/projectile/Q = shoot_reflected_bounce(projectile, A, src.max_bounce_count, PROJ_RAPID_HEADON_BOUNCE)

			Q.color = projectile.color
			Q.special_data["ball"] = projectile.special_data["ball"]
			Q.travelled = projectile.travelled
			var/turf/T = get_turf(A)
			if(TIME >= last_sound_time + 1 DECI SECOND)
				last_sound_time = TIME
				playsound(T, src.hit_sound, 60, 1)
		else
			playsound(A, 'sound/effects/mag_magmisimpact.ogg', 15, 1, -1)

	on_end(var/obj/projectile/O)
		if(O.special_data["debug"])
			var/turf/T = get_turf(O)

			var/atom/A = new /obj/item/golf_ball(T)
			A.pixel_x = O.pixel_x
			A.pixel_y = O.pixel_y
			A.color = O.color
			A.alpha = 150
			A.mouse_opacity = 0
			animate(A, alpha=0, time=10 SECONDS)
			SPAWN(5 SECONDS)
				qdel(A)

	on_max_range_die(var/obj/projectile/O)
		var/turf/T = get_turf(O)

		var/obj/item/golf_ball/ball = O.special_data["ball"]
		if(!ball)
			ball = new /obj/item/golf_ball(T)
			ball.color = O.special_data["color"]
		else
			ball.set_loc(T)

		ball.pixel_x = O.pixel_x
		ball.pixel_y = O.pixel_y
		return

/obj/item/golf_ball
	name = "golf ball"
	desc = "A small dimpled ball intended for recreation."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "golf_ball"
	w_class = W_CLASS_TINY

	digital
		can_pickup(user)
			. = FALSE
	random
		New(turf/newLoc)
			..()
			color = pick("#f44","#942", "#4f4","#296", "#44f","#429")


/obj/item/storage/golf_goal
	name = "Golf Goal"
	desc = "This appears to simply be a coffee mug but it has a little hole in the bottom."
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	icon_state = "mug"
	item_state = "mug"
	rand_pos = TRUE
	can_hold = list(/obj/item/golf_ball)
	slots = 1
	max_wclass = W_CLASS_TINY

	New()
		..()
		src.transform = turn(src.transform, -90)

	bullet_act(var/obj/projectile/P)
		if(istype(P.proj_data,/datum/projectile/special/golfball))
			var/obj/item/golf_ball/ball = P.special_data["ball"]
			if(istype(ball))
				if( ((P.max_range * 32) - P.travelled) < 64) // 32?
					if(length(contents))
						visible_message("[P] knocks into [src]. There must already be a ball in there!")
					else
						P.alpha = 0
						P.die()
						visible_message("[P] makes it into [src]. Nice shot!")
						ball.set_loc(src)
						hit_twitch(src)
