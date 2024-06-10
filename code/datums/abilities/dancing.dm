#define DANCE_TRAVEL_FORWARD 1
#define DANCE_TRAVEL_RIGHT 2
#define DANCE_TRAVEL_LEFT 3
#define DANCE_TRAVEL_BACK 4
#define DANCE_TRAVEL_TOWARD 5
#define DANCE_TRAVEL_AWAY 6

#define DANCING_BONK "dancing_bonked"

#define BEAT_COUNT(_X) (AH.time_per_count * _X)

/datum/abilityHolder/dancing
	var/style = "Waltz"
	var/list/styles = list("NC2S", "Waltz", "Salsa")
	var/mob/lead
	var/mob/follow
	var/time_per_count = 3

	onAttach(mob/to_whom)
		. = ..()
		src.addAbility(/datum/targetable/dancing/choose_style)
		src.addAbility(/datum/targetable/dancing/rest)
		src.addAbility(/datum/targetable/dancing/change_speed/faster)
		src.addAbility(/datum/targetable/dancing/change_speed/slower)
		for(var/move in childrentypesof(/datum/targetable/dancing/nc2s))
			src.addAbility(move)
		for(var/move in childrentypesof(/datum/targetable/dancing/waltz))
			src.addAbility(move)
		for(var/move in childrentypesof(/datum/targetable/dancing/salsa))
			src.addAbility(move)


/datum/targetable/dancing
	icon = 'icons/mob/dance_ui.dmi'
	do_logs = FALSE
	var/style = null
	var/list/static/follower_offsets = list("[NORTH]"=list(-4,-2),
											"[EAST]"=list(-8,1),
											"[SOUTH]"=list(4,2),
											"[WEST]"=list(8,-1))

	display_available()
		var/datum/abilityHolder/dancing/AH = holder
		var/mob/living/carbon/human/H = holder.owner
		if(istype(H))
			var/obj/item/shoes = H.get_slot(SLOT_SHOES)
			if(istype(shoes, /obj/item/clothing/shoes/dress_shoes/dance))
				. = TRUE
			else
				. = FALSE
		else
			. = TRUE

		if(. && style)
			. = style == AH.style

	castcheck(atom/target)
		. = ..()
		if(.)
			src.cooldown = 0

		var/datum/abilityHolder/dancing/AH = holder
		AH.lead = holder.owner
		AH.follow = null

		if(AH.lead.getStatusDuration("knockdown") || AH.lead.getStatusDuration("stunned") || AH.lead.getStatusDuration("unconscious") || AH.lead.lying)
			. = FALSE
		if(AH.follow && (AH.follow.getStatusDuration("knockdown") || AH.follow.getStatusDuration("stunned") || AH.follow.getStatusDuration("unconscious") || AH.follow.lying))
			. = FALSE
		else
			for (var/obj/item/grab/G in AH.lead?.equipped_list(check_for_magtractor = 0))
				if (G.affecting.buckled) continue
				AH.follow = G.affecting

			var/reset_position = FALSE
			if(AH.lead)
#if !defined(LIVE_SERVER)
				boutput(AH.lead, "Dance Offset [AH.lead.pixel_x],[AH.lead.pixel_y] p:[(abs(AH.lead.pixel_x) + abs(AH.lead.pixel_y))]")
#endif
				if((abs(AH.lead.pixel_x) + abs(AH.lead.pixel_y)) > 30)
					reset_position = BEAT_COUNT(4)
				else if(AH.follow && (abs(AH.lead.pixel_x - AH.follow.pixel_x ) + abs(AH.lead.pixel_y - AH.follow.pixel_y)) > 10 )
					reset_position = BEAT_COUNT(4)
				if(reset_position)
					animate(AH.lead, time=reset_position, pixel_x=0, pixel_y = 0)

			if(AH.follow && style)
				if(reset_position || (AH.follow.dir != turn(AH.lead.dir,180)) || ((abs(AH.lead.pixel_x - AH.follow.pixel_x ) + abs(AH.lead.pixel_y - AH.follow.pixel_y))==0))
					reset_position = max(reset_position, BEAT_COUNT(1))
					AH.follow.dir = turn(AH.lead.dir,180)
					AH.follow.layer = AH.lead.layer
					if(AH.follow.dir & (SOUTH | EAST))
						AH.follow.layer -= 0.1
					else
						AH.follow.layer += 0.1

					animate(AH.follow, time=reset_position, pixel_x=follower_offsets["[AH.follow.dir]"][1], pixel_y = follower_offsets["[AH.follow.dir]"][2])


	cast(atom/target)
		. = ..()
		var/datum/abilityHolder/dancing/AH = holder
		if(AH)
			if(GET_COOLDOWN(AH.lead, DANCING_BONK) || (AH.follow && GET_COOLDOWN(AH.follow, DANCING_BONK)))
				AH.lead.emote(pick("mumble", "grumble"))
				AH.lead.setStatusMin("stunned", 2 SECOND)
				AH.lead.setStatusMin("dancing", 0.5 SECONDS)
				AH.follow?.setStatusMin("dancing", 0.5 SECONDS)

			else
				var/duration = src.cooldown + 5 SECONDS
				AH.lead.setStatusMin("dancing", duration)
				AH.follow?.setStatusMin("dancing", duration)

	choose_style
		name = "Style"
		icon_state = "style"
		desc = "Choose from style of dance"
		cooldown = 2 SECOND

		cast(atom/target)
			. = ..()
			var/datum/abilityHolder/dancing/AH = holder
			var/dance_style = tgui_input_list(holder.owner, "Select style", "Dance Selection", AH.styles)
			if(dance_style in AH.styles)
				AH.style = dance_style

	rest
		name = "Pause"
		desc = "Maintain your current position"
		icon_state = "pause"
		cooldown = 10 SECOND

		cast(atom/target)
			. = ..()
			var/datum/abilityHolder/dancing/AH = holder
			if(AH)
				if(GET_COOLDOWN(AH.lead, DANCING_BONK) || (AH.follow && GET_COOLDOWN(AH.follow, DANCING_BONK)))
					AH.lead.setStatusMin("dancing", 0.5 SECONDS)
					AH.follow?.setStatusMin("dancing", 0.5 SECONDS)
				else
					AH.lead.setStatusMin("dancing", 15 SECONDS)
					AH.follow?.setStatusMin("dancing", 15 SECONDS)

	change_speed
		var/time_change

		cast(atom/target)
			. = ..()
			var/datum/abilityHolder/dancing/AH = holder
			if(AH)
				AH.time_per_count += time_change
				boutput(holder.owner,"[AH.time_per_count/10] seconds per count. ([60/(AH.time_per_count/10)] BPM)")

		faster
			name = "Faster"
			icon_state = "fast"
			time_change = -0.5

		slower
			name = "Slower"
			icon_state = "slow"
			time_change = 0.5

/datum/targetable/dancing/nc2s
	style = "NC2S"

	var/list/static/turn_offsets = list("[NORTH]"=list(4,-12),
											"[EAST]"=list(-20,-1),
											"[SOUTH]"=list(-4,12),
											"[WEST]"=list(20,1),
											)

	proc/basic(var/mob/dancer, loop=1)
		var/datum/abilityHolder/dancing/AH = holder
		if(dancer==AH.lead)
			src.cooldown += BEAT_COUNT(8) - BEAT_COUNT(0.5)
		if(!dancer)
			return

		var/datum/dance_transform/D = new(dancer, turn_offsets)
		if(D.travel(dancer, DANCE_TRAVEL_AWAY, AH.lead, 3))
			animate(dancer, time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, loop=loop, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_TOWARD, AH.lead, 3))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_LEFT, AH.lead, 8))
			animate(time=BEAT_COUNT(2), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING | EASE_OUT, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_AWAY, AH.lead, 3))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_TOWARD, AH.lead, 3))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_RIGHT, AH.lead, 8))
			animate(time=BEAT_COUNT(2), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING | EASE_OUT, flags=ANIMATION_RELATIVE)


	proc/closed_left_turn(var/mob/dancer, loop=1)
		var/datum/abilityHolder/dancing/AH = holder
		if(dancer==AH.lead)
			src.cooldown += BEAT_COUNT(8) - BEAT_COUNT(0.5)
		if(!dancer)
			return

		var/datum/dance_transform/D = new(dancer, turn_offsets)
		if(D.travel(dancer, DANCE_TRAVEL_AWAY, AH.lead, 3))
			animate(dancer, time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, loop=loop, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_TOWARD, AH.lead, 3))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_LEFT, AH.lead, 8))
			D.do_turn(dancer, AH.lead, 90)
			animate(time=BEAT_COUNT(2), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=D.dir, easing = QUAD_EASING | EASE_OUT, flags=ANIMATION_RELATIVE)

		if(D.travel(dancer, DANCE_TRAVEL_RIGHT, AH.lead, 16))
			animate(time=BEAT_COUNT(3), pixel_x=D.x_offset, pixel_y=D.y_offset, loop=loop, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_LEFT, AH.lead, 2))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = BACK_EASING | EASE_IN, flags=ANIMATION_RELATIVE)


	proc/grapevine(var/mob/dancer, loop=1)
		var/datum/abilityHolder/dancing/AH = holder
		if(dancer==AH.lead)
			src.cooldown += BEAT_COUNT(8) - BEAT_COUNT(0.5)
		if(!dancer)
			return

		var/datum/dance_transform/D = new(dancer, turn_offsets)
		if(D.travel(dancer, DANCE_TRAVEL_LEFT, AH.lead, 16))
			animate(dancer, time=BEAT_COUNT(3), pixel_x=D.x_offset, pixel_y=D.y_offset, loop=loop, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_RIGHT, AH.lead, 2))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = BACK_EASING | EASE_IN, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_RIGHT, AH.lead, 16))
			animate(time=BEAT_COUNT(3), pixel_x=D.x_offset, pixel_y=D.y_offset, loop=loop, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_LEFT, AH.lead, 2))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = BACK_EASING | EASE_IN, flags=ANIMATION_RELATIVE)


	basic
		name = "Basic"
		icon_state = "basic"

		cast(atom/target)
			var/datum/abilityHolder/dancing/AH = holder
			basic(AH.lead, 1)
			basic(AH.follow, 1)
			..()

	grapevine
		name = "Grapevine"
		icon_state = "grapevine"

		cast(atom/target)
			var/datum/abilityHolder/dancing/AH = holder
			grapevine(AH.lead, 1)
			grapevine(AH.follow, 1)
			..()

	closed_left_turn
		name = "Left Turn"
		icon_state = "left_turn"

		cast(atom/target)
			var/datum/abilityHolder/dancing/AH = holder
			closed_left_turn(AH.lead, 1)
			closed_left_turn(AH.follow, 1)
			..()

/datum/targetable/dancing/waltz
	style = "Waltz"
	var/list/static/turn_offsets = list("[NORTH]"=list(4,-12),
											"[EAST]"=list(-4,-1),
											"[SOUTH]"=list(-4,12),
											"[WEST]"=list(4,1),
											)


	proc/box_step(var/mob/dancer, loop=1, turn)
		var/datum/abilityHolder/dancing/AH = holder
		if(dancer==AH.lead)
			src.cooldown += BEAT_COUNT(6) - BEAT_COUNT(0.5)
		if(!dancer)
			return

		var/datum/dance_transform/D = new(dancer, turn_offsets)
		if(D.travel(dancer, DANCE_TRAVEL_FORWARD, AH.lead, 9))
			animate(dancer, time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, loop=loop, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_RIGHT, AH.lead, 8))
			if(turn)
				D.do_turn(dancer, AH.lead, turn)
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=D.dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_BACK, AH.lead, 1))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING | EASE_OUT, flags=ANIMATION_RELATIVE)

		if(D.travel(dancer, DANCE_TRAVEL_BACK, AH.lead, 7))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_LEFT, AH.lead, 8))
			if(turn)
				D.do_turn(dancer, AH.lead, turn)
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=D.dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_BACK, AH.lead, 1))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING | EASE_OUT, flags=ANIMATION_RELATIVE)


	box_step
		name = "Box Step"
		icon_state = "box"
		cast(atom/target)
			var/datum/abilityHolder/dancing/AH = holder
			box_step(AH.lead, 1)
			box_step(AH.follow, 1)
			..()

	turning_box
		name = "Turning Box Step"
		icon_state = "l_box"
		cast(atom/target)
			var/datum/abilityHolder/dancing/AH = holder
			box_step(AH.lead, 1, 90)
			box_step(AH.follow, 1, 90)
			..()

/datum/targetable/dancing/salsa
	style = "Salsa"

	// var/list/static/turn_offsets = list("[NORTH]"=list(4,-12),
	// 										"[EAST]"=list(-4,-1),
	// 										"[SOUTH]"=list(-4,12),
	// 										"[WEST]"=list(4,1),
	// 										)

	var/list/static/turn_offsets = list("[NORTH]"=list(4,-12),
											"[EAST]"=list(-20,-1),
											"[SOUTH]"=list(-4,12),
											"[WEST]"=list(20,1),
											)

	proc/basic(var/mob/dancer, loop=1, flare)
		var/datum/abilityHolder/dancing/AH = holder
		if(dancer==AH.lead)
			src.cooldown += BEAT_COUNT(8) - BEAT_COUNT(0.5)
		if(!dancer)
			return

		var/flare_dir = dancer.dir

		var/datum/dance_transform/D = new(dancer, turn_offsets)
		if(D.travel(dancer, DANCE_TRAVEL_FORWARD, AH.lead, 3))
			if(flare == AH.lead && dancer==AH.lead)
				flare_dir = turn(flare_dir, 90)
			animate(dancer, time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, loop=loop, dir=flare_dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_BACK, AH.lead, 3))
			if(flare == AH.lead && dancer==AH.lead)
				flare_dir = turn(flare_dir, 180)
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=flare_dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
			if(flare == AH.lead && dancer==AH.lead)
				flare_dir = turn(flare_dir, 90)
			animate(time=BEAT_COUNT(2), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=flare_dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)

		if(D.travel(dancer, DANCE_TRAVEL_BACK, AH.lead, 3))
			if(flare == AH.follow && dancer==AH.follow)
				flare_dir = turn(flare_dir, 90)
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=flare_dir, loop=loop, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_FORWARD, AH.lead, 3))
			if(flare == AH.follow && dancer==AH.follow)
				flare_dir = turn(flare_dir, 180)
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=flare_dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
			if(flare == AH.follow && dancer==AH.follow)
				flare_dir = turn(flare_dir, 90)
			animate(time=BEAT_COUNT(2), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=flare_dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)


	proc/side_basic(var/mob/dancer, loop=1)
		var/datum/abilityHolder/dancing/AH = holder
		if(dancer==AH.lead)
			src.cooldown += BEAT_COUNT(8) - BEAT_COUNT(0.5)
		if(!dancer)
			return

		var/datum/dance_transform/D = new(dancer, turn_offsets)
		if(D.travel(dancer, DANCE_TRAVEL_LEFT, AH.lead, 3))
			animate(dancer, time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, loop=loop, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_RIGHT, AH.lead, 3))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
			animate(time=BEAT_COUNT(2), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)

		if(D.travel(dancer, DANCE_TRAVEL_RIGHT, AH.lead, 3))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, loop=loop, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
		if(D.travel(dancer, DANCE_TRAVEL_LEFT, AH.lead, 3))
			animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
			animate(time=BEAT_COUNT(2), pixel_x=D.x_offset, pixel_y=D.y_offset, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)


	// proc/cross_body(var/mob/dancer, loop=1)
	// 	var/datum/abilityHolder/dancing/AH = holder
	// 	if(dancer==AH.lead)
	// 		src.cooldown += BEAT_COUNT(8) - BEAT_COUNT(0.5)
	// 	if(!dancer)
	// 		return

	// 	var/flare_dir = dancer.dir

	// 	var/datum/dance_transform/D = new(dancer, turn_offsets)
	// 	if(D.travel(dancer, DANCE_TRAVEL_FORWARD, AH.lead, 3))
	// 	animate(dancer, time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, loop=loop, dir=flare_dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)

	// 	if(D.travel(dancer, DANCE_TRAVEL_BACK, AH.lead, 3))
	// 	animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=flare_dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
	// 	// if(dancer==AH.lead)
	// 	// 	flare_dir = turn(flare_dir, 90)
	// 	animate(time=BEAT_COUNT(2), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=flare_dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)

	// 	if(D.travel(dancer, DANCE_TRAVEL_FORWARD, AH.lead, 3))
	// 	animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=flare_dir, loop=loop, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
	// 	D.do_turn(dancer, AH.lead, 180)
	// 	if(D.travel(dancer, DANCE_TRAVEL_FORWARD, AH.lead, 3))
	// 	animate(time=BEAT_COUNT(1), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=D.dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)
	// 	animate(time=BEAT_COUNT(2), pixel_x=D.x_offset, pixel_y=D.y_offset, dir=D.dir, easing = QUAD_EASING, flags=ANIMATION_RELATIVE)



	basic

		name = "Basic"
		icon_state = "basic"

		cast(atom/target)
			var/datum/abilityHolder/dancing/AH = holder
			var/flare = null
			if(prob(33))
				if(prob(50))
					flare = AH.lead
				else
					flare = AH.follow
			basic(AH.lead, 1, flare)
			basic(AH.follow, 1, flare)
			..()

	side_basic

		name = "Side Basic"
		icon_state = "side_basic"

		cast(atom/target)
			var/datum/abilityHolder/dancing/AH = holder
			side_basic(AH.lead, 1)
			side_basic(AH.follow, 1)
			..()

	// cross_body
	// 	name = "Cross Body Lead"
	// 	icon_state = "basic"

	// 	cast(atom/target)
	// 		var/datum/abilityHolder/dancing/AH = holder
	// 		cross_body(AH.lead, 1)
	// 		cross_body(AH.follow, 1)
	// 		..()


/datum/dance_transform
	var/x_offset
	var/y_offset
	var/total_x_offset
	var/total_y_offset
	var/layer
	var/dir
	var/open_position = FALSE
	var/bonked = FALSE
	var/list/turn_offsets

	New(mob/M, turn_offsets)
		. = ..()
		src.x_offset = 0
		src.y_offset = 0
		src.total_x_offset = M.pixel_x
		src.total_y_offset = M.pixel_y
		src.dir = M.dir
		src.turn_offsets = turn_offsets

	proc/travel(mob/M, dance_dir, mob/lead, distance)
		. = TRUE
		var/angle = dir_to_angle(src.dir)

		if(src.bonked || (GET_COOLDOWN(M, DANCING_BONK) || GET_COOLDOWN(lead, DANCING_BONK)))
			src.x_offset = 0
			src.y_offset = 0
			. = FALSE
			return

		switch(dance_dir)
			if(DANCE_TRAVEL_FORWARD)
				; //noop
			if(DANCE_TRAVEL_RIGHT)
				angle += 90
			if(DANCE_TRAVEL_LEFT)
				angle += -90
			if(DANCE_TRAVEL_BACK)
				angle += 180
			if(DANCE_TRAVEL_FORWARD)
				; //noop
			if(DANCE_TRAVEL_AWAY)
				angle += 180

		if(M != lead) // follow
			if( (dance_dir != DANCE_TRAVEL_TOWARD) && (dance_dir != DANCE_TRAVEL_AWAY))
				angle += 180

		src.x_offset = (distance*sin(angle))
		src.y_offset = (distance*cos(angle))

		src.total_x_offset += src.x_offset
		src.total_y_offset += src.y_offset
#if !defined(LIVE_SERVER)
		boutput(M, SPAN_ALERT("([src.x_offset],[src.y_offset]) -> ([src.total_x_offset],[src.total_y_offset])"))
#endif
		// Check if we are going to bonk into a thing...
		if((abs(src.total_x_offset) > 16) || (abs(src.total_y_offset - 14) > 16))
			var/x_offset = 0
			var/y_offset = 0
			if(total_x_offset)
				x_offset = round((src.total_x_offset + 16)/32)
			if(total_y_offset)
				y_offset = round((src.total_y_offset + 2)/32)
			if(lead==M)
				var/turf/target_turf = locate(M.x+x_offset,M.y+y_offset,M.z)
				if(!target_turf?.can_crossed_by(M))
					. = FALSE
					src.bonked = TRUE
					boutput(M, SPAN_ALERT("Your dance comes to a sudden stop as you bump into something."))
					M.emote(pick("mumble", "grumble"))
					EXTEND_COOLDOWN(M, DANCING_BONK, 5 SECONDS)
					EXTEND_COOLDOWN(lead, DANCING_BONK, 5 SECONDS)

	proc/do_turn(mob/M, mob/lead, angle, skip_offset)
		src.dir = turn(M.dir,angle)
		if(M != lead) // follow
			M.layer = lead.layer
			if(dir & (SOUTH | EAST))
				M.layer -= 0.1
			else
				M.layer += 0.1

			if(!skip_offset && length(src.turn_offsets))
				src.x_offset = src.turn_offsets["[src.dir]"][1]
				src.y_offset = src.turn_offsets["[src.dir]"][2]


/datum/statusEffect/dancing
	id = "dancing"
	name = "Dancing"
	maxDuration = 1 MINUTE
	effect_quality = STATUS_QUALITY_NEUTRAL
	move_triggered = TRUE

	// NO TRAVELING DANCING, WE CAN'T HAVE NICE THINGS
	move_trigger(mob/user, ev)
		if(ismob(owner))
			var/mob/M = owner
			animate(M, time=1 SECOND, pixel_x=0, pixel_y=0, easing = QUAD_EASING | EASE_OUT, flags=ANIMATION_END_NOW)

	onRemove()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			animate(M, time=2 SECOND, pixel_x=0, pixel_y=0, easing = QUAD_EASING | EASE_OUT, flags=ANIMATION_END_NOW)

#undef BEAT_COUNT
#undef DANCING_BONK
#undef DANCE_TRAVEL_FORWARD
#undef DANCE_TRAVEL_RIGHT
#undef DANCE_TRAVEL_LEFT
#undef DANCE_TRAVEL_BACK
#undef DANCE_TRAVEL_TOWARD
#undef DANCE_TRAVEL_AWAY
