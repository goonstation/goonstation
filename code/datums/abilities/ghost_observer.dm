#ifdef HALLOWEEN
var/global/datum/spooktober_ghost_handler/spooktober_GH = new()

/datum/spooktober_ghost_handler
	var/const/MAX_POINTS = 100000
	var/points = 0
	var/cur_meter_location = 0
	var/last_meter_location = 0			//the amount of points at the last update. Used for deciding when to redraw the sprite to have less progress
	var/earned_points = list()				//assoc list of ckeys to their gained points.
	var/spent_points = list()				//assoc list of ckeys to their spent points.
	var/maxed_out = 0					//set to 1 if the points get up to MAX_POINTS so we can play the special event/thing

	var/atom/movable/screen/spooktober_meter/meter = new()

	proc/change_points(var/ckey, var/added as num)
		if (ckey)
			if (added > 0)
				earned_points[ckey] += added
			else
				spent_points[ckey] += added
		src.points += added
		if (src.points >= MAX_POINTS)
			do_event()


	proc/update()

		cur_meter_location = round((points/MAX_POINTS)*145)	//length of meter
		if (cur_meter_location != last_meter_location)
			meter.overlays.Cut()
			var/icon/IB = new('icons/mob/spooktober_ghost_hud160x32.dmi', "bar")

			IB.Crop(1,1,cur_meter_location+8,32) // mehhhh
			IB.Blend(rgb(40,0,0))
			meter.overlays += IB

		last_meter_location = cur_meter_location

	proc/do_event()
		//Only 1 per round
		if (maxed_out)
			return
		maxed_out = 1


/atom/movable/screen/spooktober_meter
	icon = 'icons/mob/spooktober_ghost_hud160x32.dmi'
	icon_state = "empty"
	name = "Spooktober Spookpoints Meter"
	desc = "Seems to indicate how spooky the current ghosts are in this sector."
	var/theme = null // for wire's tooltips, it's about time this got varized

	get_desc()
		. += "[spooktober_GH.points] Points!"

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder && control == "mapwindow.map")
			var/theme = src.theme

			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = "spooktober spook points",//src.name,
				"content" = "[spooktober_GH.points] Points <br>All Points are shared between ghosts. <br>Spinning chairs, flipping, using the ouija board, and farting on people as a ghost generates more points faster.",//(src.desc ? src.desc : null),
				"theme" = theme
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

#endif

/atom/movable/screen/ability/topBar/ghost_observer
	clicked(params)
		var/datum/targetable/ghost_observer/abil = owner
		if (!istype(abil))
			return
		if (!abil.holder)
			return
		SPAWN(0)
			abil.handleCast()

#ifdef HALLOWEEN
	//total hack here, but lazy and in a hurry. -Kyle
	update_cooldown_cost()
		owner?.holder.points = spooktober_GH.points
		..()
#endif
/datum/abilityHolder/ghost_observer
	usesPoints = 0
	regenRate = 0
	tabName = "Abilities"
	cast_while_dead = 1
	var/display_buttons = 1
	var/disabled = FALSE

#ifdef HALLOWEEN
	usesPoints = 1
	var/points_since_last_tick = 0		//resets every life tick, prevents you from getting more than 10 points a tick from spam nonsense.
	var/spooking = 0		//if they're in their extra spooky form where they're visible and blurry.

	proc/change_points(var/amt as num)
		if (owner.client)
			if (points_since_last_tick < 50)
				var/k = 1
				if (amt > 0)
					points_since_last_tick += amt
					k = 1 //3 //when ready with event.

				spooktober_GH.change_points(owner.client.ckey, amt*k)		//idk why I did this with the multiplying by a constant, but I'll keep it
				src.points = spooktober_GH.points

	pointCheck(cost)
		// if (!usesPoints)
		// 	return 1
		if (spooktober_GH.points < 0) // Just-in-case fallback.
			logTheThing(LOG_DEBUG, usr, "'s ability holder ([src.type]) was set to an invalid value (points less than 0), resetting.")
			spooktober_GH.points = 0
		if (cost > spooktober_GH.points)
			boutput(owner, notEnoughPointsMessage)
			return 0
		return 1

	deductPoints(cost)
		..()
		if (owner.client)
			spooktober_GH.change_points(owner.client.ckey, -abs(cost))	//idk what format this comes in, I'll be safe


#endif

	New()
		..()
		add_all_abilities()
		updateButtons()

	proc/disable(disable)
		if(disable)
			boutput(owner, "You're trapped in here!")
		else
			boutput(owner, "Your ghost powers return!")
		src.disabled = disable

	proc/toggle()
		if (!islist(src.abilities))
			boutput(usr, "You have no abilities! What happened?! Call 1-800-CODER!")
			return

		display_buttons = !display_buttons
		if (display_buttons)
			for (var/datum/targetable/ghost_observer/A in src.abilities)
				if (!istype (A, /datum/targetable/ghost_observer/toggle_HUD) && istype(A.object))
					A.object.invisibility = INVIS_NONE
		else
			for (var/datum/targetable/ghost_observer/A in src.abilities)
				if (!istype (A, /datum/targetable/ghost_observer/toggle_HUD) && istype(A.object))
					A.object.invisibility = INVIS_ALWAYS_ISH

	proc/add_all_abilities()
		src.addAbility(/datum/targetable/ghost_observer/toggle_HUD)
		src.addAbility(/datum/targetable/ghost_observer/teleport)
		src.addAbility(/datum/targetable/ghost_observer/observe)
		src.addAbility(/datum/targetable/ghost_observer/reenter_corpse)
		src.addAbility(/datum/targetable/ghost_observer/toggle_lighting)
		// src.addAbility(/datum/targetable/ghost_observer/afterlife_Bar)
		// src.addAbility(/datum/targetable/ghost_observer/respawn_animal)	//moved to respawn_options menu
		src.addAbility(/datum/targetable/ghost_observer/respawn_options)


#ifdef HALLOWEEN
		src.addAbility(/datum/targetable/ghost_observer/spooktober_hud)

		src.addAbility(/datum/targetable/ghost_observer/decorate)
		src.addAbility(/datum/targetable/ghost_observer/levitate_object)
		// src.addAbility(/datum/targetable/ghost_observer/levitate_chair)
		src.addAbility(/datum/targetable/ghost_observer/spooky_sounds)
		src.addAbility(/datum/targetable/ghost_observer/summon_bat)
		src.addAbility(/datum/targetable/ghost_observer/manifest)

		src.addAbility(/datum/targetable/ghost_observer/spooktober_writing)
#endif
		src.updateButtons()

	//this weird. doesn't remove from screen.
	proc/remove_all_abilities()
		src.removeAbility(/datum/targetable/ghost_observer/toggle_HUD)
		src.removeAbility(/datum/targetable/ghost_observer/teleport)
		src.removeAbility(/datum/targetable/ghost_observer/observe)
		src.removeAbility(/datum/targetable/ghost_observer/reenter_corpse)
		src.removeAbility(/datum/targetable/ghost_observer/toggle_lighting)
		// src.removeAbility(/datum/targetable/ghost_observer/afterlife_Bar)
		// src.removeAbility(/datum/targetable/ghost_observer/respawn_animal)
		src.removeAbility(/datum/targetable/ghost_observer/respawn_options)

#ifdef HALLOWEEN
		src.removeAbility(/datum/targetable/ghost_observer/spooktober_hud)


		src.removeAbility(/datum/targetable/ghost_observer/levitate_object)
		// src.removeAbility(/datum/targetable/ghost_observer/levitate_chair)
		src.removeAbility(/datum/targetable/ghost_observer/spooky_sounds)
		src.removeAbility(/datum/targetable/ghost_observer/summon_bat)
		src.removeAbility(/datum/targetable/ghost_observer/manifest)
		src.removeAbility(/datum/targetable/ghost_observer/decorate)
		src.removeAbility(/datum/targetable/ghost_observer/spooktober_writing)
#endif
		src.updateButtons()

#ifdef HALLOWEEN

/datum/abilityHolder/ghost_observer/proc/stop_spooking()
	var/datum/targetable/ghost_observer/manifest/ability = getAbility(/datum/targetable/ghost_observer/manifest)
	if (istype(ability))
		ability.stop_spooking()

#endif

/datum/targetable/ghost_observer
	cooldown = 0
	last_cast = 0
	preferred_holder_type = /datum/abilityHolder/ghost_observer
	icon = 'icons/mob/ghost_observer_abilities.dmi'
	icon_state = "teleport"

	display_available()
		. = ..()
		var/datum/abilityHolder/ghost_observer/AH = holder
		var/atom/movable/screen/ability/topBar/abilityIcon = src.object
		if(istype(AH) && AH.disabled)
			abilityIcon.darkener.alpha = 200
			abilityIcon.UpdateOverlays(abilityIcon.darkener, "darkener")
		else
			abilityIcon.UpdateOverlays(null, "darkener")

	castcheck(atom/target)
		. = ..()
		var/datum/abilityHolder/ghost_observer/AH = holder
		if(istype(AH) && AH.disabled)
			. = FALSE

///////////////////////////////////////

/datum/targetable/ghost_observer/teleport
	name = "Teleport"
	desc = "Teleport to an area."
	icon_state = "teleport"
	targeted = 0
	cooldown = 0


	cast(atom/target)
		if (holder && istype(holder.owner, /mob/dead/observer))
			var/mob/dead/observer/ghost = holder.owner
			ghost.dead_tele()

		else
			boutput(usr, "Oop! Something broke! Just type \"teleport\" (without the quotation marks) into the bottom bar.")

/datum/targetable/ghost_observer/observe
	name = "Observe"
	desc = "Observe a specific person."
	icon_state = "observe-person"
	targeted = 0
	cooldown = 0


	cast(atom/target)
		if (holder && istype(holder.owner, /mob/dead/observer))
			var/mob/dead/observer/ghost = holder.owner
			ghost.observe()

		else
			boutput(usr, "Oop! Something broke! Just type \"Re-enter Corpse\" (without the quotation marks) into the bottom bar.")

/datum/targetable/ghost_observer/reenter_corpse
	name = "Re-enter Corpse"
	desc = "Re-enter your original corpse."
	icon_state = "reenter-corpse"
	targeted = 0
	cooldown = 0


	cast(atom/target)
		if (holder && istype(holder.owner, /mob/dead/observer))
			var/mob/dead/observer/ghost = holder.owner
			ghost.reenter_corpse()

		else
			boutput(usr, "Oop! Something broke! Just type \"Re-enter Corpse\" (without the quotation marks) into the bottom bar.")



/datum/targetable/ghost_observer/toggle_lighting
	name = "Toggle Lighting"
	desc = "Toggle lighting effects on tiles."
	icon_state = "bulb-t"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		if (holder && istype(holder.owner, /mob/dead/observer))
			var/mob/dead/observer/ghost = holder.owner
			ghost.toggle_lighting()
			// var/atom/plane = ghost.client.get_plane(PLANE_LIGHTING)
			// if (plane)
			// 	if (plane.alpha)
			// 		icon_state = "bulb-0"
			// 	else
			// 		icon_state = "bulb-1"
			// holder.updateButtons()
		else
			boutput(usr, "Oop! Something broke! Just type \"Toggle Lighting\" (without the quotation marks) into the bottom bar.")

/datum/targetable/ghost_observer/toggle_HUD
	name = "Hide HUD"
	desc = "Hide all HUD buttons."
	icon_state = "hide"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		if (holder && istype(holder, /datum/abilityHolder/ghost_observer) && istype(holder.owner, /mob/dead/observer))
			var/datum/abilityHolder/ghost_observer/GH = holder
			if (GH.display_buttons)
				name = "Show HUD"
				desc = "Show all HUD buttons."
				icon_state = "show"
			else
				name = "Hide HUD"
				desc = "Hide all HUD buttons."
				icon_state = "hide"

			GH.toggle()
			GH.updateButtons(1)

			boutput( usr, "Use the command \"Toggle Ability Buttons\" in the \"Ghost\" commands tab at the top right to re-enable buttons.." )

		else
			boutput(usr, "Oop! Something broke! Just type \"Toggle Ability Buttons\" (without the quotation marks) into the bottom bar.")

/datum/targetable/ghost_observer/respawn_options
	name = "Respawn Options"
	desc = "Respawn as something."
	icon_state = "spawnbutton"
	targeted = 0
	cooldown = 0
	special_screen_loc = "NORTH,EAST"
	tooltip_flags = TOOLTIP_LEFT
	var/displaying_buttons = 0

	New()
		..()
		object.contextLayout = new /datum/contextLayout/screen_HUD_default/click_to_close()
		if (!object.contextActions)
			object.contextActions = list()

		object.contextActions += new /datum/contextAction/ghost_respawn/close()
		object.contextActions += new /datum/contextAction/ghost_respawn/afterlife_bar()
		object.contextActions += new /datum/contextAction/ghost_respawn/virtual_reality()
		object.contextActions += new /datum/contextAction/ghost_respawn/respawn_animal()
		object.contextActions += new /datum/contextAction/ghost_respawn/ghostdrone()
		// object.contextActions += new /datum/contextAction/ghost_respawn_button/blobtutorial()
		object.contextActions += new /datum/contextAction/ghost_respawn/respawn_mentor_mouse()
		object.contextActions += new /datum/contextAction/ghost_respawn/respawn_admin_mouse()

	cast(atom/target)
		displaying_buttons = !displaying_buttons
		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/football))
			boutput(holder.owner, "Sorry, respawn options aren't availbale during football mode.")
			displaying_buttons = 0
		if (!displaying_buttons)
			holder.owner.closeContextActions()

/datum/targetable/ghost_observer/respawn_animal
	name = "Respawn As Animal"
	desc = "Respawn as an animal."
	icon_state = "respawn-animal"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		if (holder && istype(holder.owner, /mob/dead/observer))
			var/mob/dead/observer/ghost = holder.owner
			ghost.respawn_as_animal()

		else
			boutput(usr, "Oop! Something broke! Just type \"Respawn-As-Animal\" (without the quotation marks) into the bottom bar.")

/datum/targetable/ghost_observer/ass_day_arena
	name = "Fight for a new life!"
	desc = "Go to the Respawn Arena."
	icon_state = "ass_day_arena"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		if (holder && istype(holder.owner, /mob/dead/observer))
			var/mob/dead/observer/ghost = holder.owner
			ghost.go_to_respawn_arena()

		else
			boutput(usr, "Uhhh something broke. Oops. Please go yell at a coder to get this fixed.")

#ifdef HALLOWEEN
/datum/targetable/ghost_observer/spooktober_hud
	name = "Spooktober Spookpoints"
	desc = "How many Spookpoints do we have."
	icon = 'icons/mob/spooktober_ghost_hud160x32.dmi'
	// icon_state = "empty"
	targeted = 0
	cooldown = 0
	special_screen_loc = "NORTH,CENTER-2"
	var/count = 0

	onAttach(var/datum/abilityHolder/H)
		object.mouse_opacity = 0
		object.maptext_y = -32
		object.vis_contents += spooktober_GH.meter
		return

	// Stat()
	// 	if (object)
	// 		object.maptext = "[spooktober_GH.points]"

	// 	spooktober_GH.update()

/datum/targetable/ghost_observer/levitate_object
	name = "Levitate Object"
	desc = "Levitate an object."
	icon_state = "levitate-object"
	targeted = 1
	target_anything = 1
	max_range = 10
	cooldown = 30 SECONDS // MINUTES
	special_screen_loc = "SOUTH,CENTER-2"
	pointCost = 50

	cast(obj/item/target)
		if (!holder)
			return 1

		boutput(holder.owner, "<span class='alert'>You exert some force to levitate [target]!</span>")
		SPAWN(rand(30,50))
			if (!holder)
				return
			//levitates the target chair, as well as any mobs mobs buckled in. Since buckled mobs are placed into the chair/bed's contents
			//only doing chair. doing the bed levatate moves the mobs on it in a weird way, and I don't wanna spend the time to fix it
			if (istype(target, /obj/stool/chair)/* || istype(target, /obj/stool/bed)*/)
				for (var/mob/living/L in target.loc.contents)
					if (L.buckled)
						animate_levitate(L, 1, 10)
				animate_levitate(target, 1, 10)
				boutput(holder.owner, "<span class='alert'>You levitate[target] and its occupant(s)!</span>")
			else if (istype(target, /obj/item))
				animate_levitate(target, 1, 10)
				boutput(holder.owner, "<span class='alert'>You levitate[target]!</span>")
			else
				boutput(holder.owner, "<span class='alert'>But it's beyond your power!</span>")


/datum/targetable/ghost_observer/spooky_sounds
	name = "Make a Spooky Sound"
	desc = "Makes a spooky sound at your location.."
	icon_state = "spooky-sound"
	targeted = 0
	cooldown = 30 SECONDS // MINUTES
	target_anything = 0
	max_range = 0
	cooldown = 1 MINUTES
	pointCost = 30
	special_screen_loc = "SOUTH,CENTER-1"
	pointCost = 100

	cast()
		if (!holder)
			return 1

		var/turf/T = get_turf(holder.owner)
		var/S = pick('sound/ambience/nature/Wind_Cold1.ogg', 'sound/ambience/nature/Wind_Cold2.ogg', 'sound/ambience/nature/Wind_Cold3.ogg','sound/ambience/nature/Cave_Bugs.ogg', 'sound/ambience/nature/Glacier_DeepRumbling1.ogg', 'sound/effects/bones_break.ogg', 'sound/effects/glitchy1.ogg',	'sound/effects/gust.ogg', 'sound/effects/static_horror.ogg', 'sound/effects/blood.ogg', 'sound/effects/kaboom.ogg')
		playsound(T, S, 30, 0, -1)
		boutput(holder.owner, "<span class='alert'>You make a spooky sound!</span>")


/datum/targetable/ghost_observer/decorate
	name = "Decorate"
	desc = "Decorate on the ground!"
	icon_state = "decorate"
	targeted = 1
	cooldown = 2 MINUTES
	start_on_cooldown = 1
	target_anything = 1
	special_screen_loc = "SOUTH,CENTER"
	pointCost = 200
	var/static/list/effects = list("ectoplasm"=1, "Cobweb"=2, "candle"=3, "pumpkin"=4, "skellington"=5, "spider vomit puddles"=6, "Random"=7)

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		if (isturf(T))
			var/effect = input("Which effect?", "Effect", "Random") in effects
			if (effect == "Random")
				effect = rand(1, 6)
			else
				effect = effects[effect]
			switch (effect)
				if (1)
					new/obj/item/reagent_containers/food/snacks/ectoplasm(T)
				if (2)
					new/obj/decal/cleanable/cobwebFloor(T)
				if (3)
					new/obj/item/device/light/candle/spooky/summon(T)
				if (4)
					new/obj/item/reagent_containers/food/snacks/plant/pumpkin/summon(T)
				if (5)
					new/obj/decal/fakeobjects/skeleton/unanchored/summon(T)
				if (6)
					new/obj/decal/cleanable/vomit/spiders(T)

			boutput(usr, "<span class='notice'>Matter from your realm appears near the designated location!</span>")


/datum/targetable/ghost_observer/spooktober_writing
	name = "Spooky Writing"
	desc = "Write a spooky character on the ground."
	icon_state = "bloodwriting"
	targeted = 1
	cooldown = 3 MINUTES
	start_on_cooldown = 1
	target_anything = 1
	special_screen_loc = "SOUTH,CENTER+1"
	pointCost = 300

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/list/c_default = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Exclamation Point", "Question Mark", "Period", "Comma", "Colon", "Semicolon", "Ampersand", "Left Parenthesis", "Right Parenthesis",
		"Left Bracket", "Right Bracket", "Percent", "Plus", "Minus", "Times", "Divided", "Equals", "Less Than", "Greater Than")
		var/list/c_symbol = list("Dollar", "Euro", "Arrow North", "Arrow East", "Arrow South", "Arrow West",
		"Square", "Circle", "Triangle", "Heart", "Star", "Smile", "Frown", "Neutral Face", "Bee", "Pentagram")

		var/string = input(holder.owner, "What do you want to write?", null, null) as null|anything in (c_default + c_symbol)

		if (!string)
			return 1

		var/turf/T = get_turf(target)
		if (isturf(T) && holder.owner)
			write_on_turf(T, holder.owner, params, string)


	proc/write_on_turf(var/turf/T as turf, var/mob/user as mob, params, string)
		if (!T && !user && !string)
			return

		var/obj/decal/cleanable/writing/spooky/G = make_cleanable(/obj/decal/cleanable/writing/spooky,T)
		G.artist = user.key

		logTheThing(LOG_STATION, user, "writes on [T] with [src] [log_loc(T)]: [string]")
		G.icon_state = string
		G.words = string
		if (islist(params) && params["icon-y"] && params["icon-x"])
			// playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)

			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)

/datum/targetable/ghost_observer/summon_bat
	name = "Summon Bat"
	desc = "Summons a single, harmless, friendly bat for the living to enjoy."
	icon_state = "summon-bat"
	targeted = 0
	target_anything = 0
	max_range = 0
	cooldown = 10 MINUTES
	start_on_cooldown = 1
	special_screen_loc = "SOUTH,CENTER+2"
	pointCost = 1000

	cast()
		if (!holder)
			return 1

		var/turf/T = get_turf(holder.owner)
		if (!istype(T, /turf/space) && !T.density)
			var/obj/itemspecialeffect/poof/P = new /obj/itemspecialeffect/poof
			P.setup(T)
			playsound(T, 'sound/effects/poff.ogg', 50, 1, pitch = 1)
			new /obj/critter/bat(T)
			boutput(holder.owner, "<span class='alert'>You call forth a bat!</span>")
		else
			boutput(holder.owner, "<span class='alert'>You can't put a bat there!</span>")

/datum/targetable/ghost_observer/manifest
	name = "Manifest"
	desc = "Push yourself more fully into the material realm and be a bit more powerful for 30 seconds."
	icon_state = "manifest"
	targeted = 0
	target_anything = 0
	max_range = 0
	cooldown = 7 MINUTES
	start_on_cooldown = 1
	special_screen_loc = "SOUTH,CENTER+3"
	pointCost = 1500
	var/time_to_manifest = 1 MINUTES		//How much time should they spend in the form if left uninterrupted.
	var/applied_filter_index


	cast()
		if (!holder)
			return 1

		start_spooking()
		//////////////////////////////////////////////////////////////////////
		sleep(time_to_manifest)
		//////////////////////////////////////////////////////////////////////
		stop_spooking()



	proc/start_spooking()
		src.holder.owner.color = rgb(170, 0, 0)
		anim_f_ghost_blur(src.holder.owner)

		if (istype(holder, /datum/abilityHolder/ghost_observer))
			var/datum/abilityHolder/ghost_observer/GAH = holder
			GAH.spooking = 1
		REMOVE_ATOM_PROPERTY(src.holder.owner, PROP_MOB_INVISIBILITY, src.holder.owner)
		boutput(holder.owner, "<span class='notice'>You start being spooky! The living can all see you!</span>")

	//remove the filter animation when we're done.
	proc/stop_spooking()
		src.holder.owner.color = null
		if (istype(holder, /datum/abilityHolder/ghost_observer))
			var/datum/abilityHolder/ghost_observer/GAH = holder
			GAH.spooking = 0
		APPLY_ATOM_PROPERTY(src.holder.owner, PROP_MOB_INVISIBILITY, src.holder.owner, ghost_invisibility)
		boutput(holder.owner, "<span class='alert'>You stop being spooky!</span>")

#endif
