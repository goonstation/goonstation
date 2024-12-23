/mob/living/critter/small_animal/snake //done as part of a tutorial in converting /obj/critter to /mob/living/critter - https://hackmd.io/@amylizzle/mobbening_tutorial
	name = "snake"
	desc = "A snake. Not on a plane."
	icon = 'icons/misc/critter.dmi'
	icon_state = "snake"
	density = FALSE
	custom_gib_handler = /proc/gibs
	hand_count = 1
	can_help = TRUE
	can_throw = FALSE
	can_grab = TRUE
	can_disarm = FALSE
	butcherable = BUTCHER_ALLOWED
	name_the_meat = FALSE
	max_skins = 1
	health_brute = 15
	health_brute_vuln = 0.5
	health_burn = 15
	health_burn_vuln = 0.25
	ai_type = /datum/aiHolder/aggressive
	is_npc = TRUE
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD //angry snek kills you

	//Special behaviour vars
	var/double = 0
	var/attack_damage = 5
	var/image/colouring
	var/allow_empty = 0
	var/expiration_id = 1
	var/had_keep_together = 0
	var/atom/movable/my_stick = null

	//note: this is not the best way to do this, but I'm showing it here as an example. It is better to create a peaceful AI holder with no attack tasks and use that.
	aggressive = TRUE

	faction = list(FACTION_WIZARD)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth	// if not null, the special limb to use when attack_handing
		var/datum/limb/mouth/M = HH.limb
		M.stam_damage_mult = 0.5
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	valid_target(mob/living/C)
		if (C.ckey == null) return FALSE //do not attack non-threats ie. NPC monkeys and AFK players
		. = ..()

	seek_target(var/range)
		if(!src.aggressive) //see above note regarding peacefulness
			return .
		. = ..()

		if(length(.) && prob(30))
			playsound(src.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)
			src.visible_message(SPAN_ALERT("<B>[src]</B> hisses!"))

	//Special behaviour for Sticks To Snakes spell

	New(loc, var/atom/movable/stick)
		..()
		// build mode shenaningans, spawn a snek in something for it to become a snek
		if(!istype(loc, /turf))
			stick = loc
			src.set_loc(get_turf(loc))
		src.update_stick(stick)

	proc/snakify_name(var/name, var/double)
		if((findtext(name, "s") || findtext(name, "S")) && prob(15))
			if(double)
				name = replacetext(name, "s", stutter("sss"))
			else
				name = replacetext(name, "s", stutter("ss"))
			return "\improper[name]"
		else if(prob(20))
			var/part1 = "snak"
			if(double) part1 = "double-[part1]"
			var/part2 = copytext(name, round(length(name) / 2), 0)
			return "\improper[part1][part2]"
		else if(prob(20))
			return "\improper slithering [double?"two-headed ":""][name]"
		else
			return "\improper[name] [double?"double-":""]snake"

	proc/drop_stick(var/revert_message=0)
		if(src.my_stick)
			my_stick.render_target = "\ref[my_stick]" // or just null?
			my_stick.mouse_opacity = 1
			my_stick.set_loc(src.loc)
			if(revert_message)
				src.visible_message(SPAN_COMBAT("<b>[src]</b> reverts into [my_stick]!"))
			if(istype(my_stick, /mob/living/critter/small_animal/snake))
				var/mob/living/critter/small_animal/snake/snake = my_stick
				snake.start_expiration(2 MINUTES)
			if(!src.had_keep_together)
				my_stick.appearance_flags &= ~KEEP_TOGETHER
			src.my_stick = null
		src.vis_contents = initial(src.vis_contents)
		if(istype(src.colouring))
			src.colouring.filters = null

	proc/start_expiration(var/time)
		var/this_expiration_id = rand(1, 100000)
		src.expiration_id = this_expiration_id
		SPAWN(time)
			if(!isdead(src) && src.expiration_id == this_expiration_id)
				src.health = 0
				src.death()

	proc/update_stick(var/atom/movable/stick)
		drop_stick()

		src.double = initial(src.double)
		src.attack_damage = initial(src.attack_damage)
		src.icon_state = initial(src.icon_state)

		if(stick == null)
			src.icon_state = "snake_green"
			src.name = initial(src.name)
			src.desc = initial(src.desc)
			src.allow_empty = 1
			return

		src.had_keep_together = src.appearance_flags & KEEP_TOGETHER

		src.allow_empty = 0

		stick.set_loc(src)
		src.my_stick = stick
		src.desc = "\A [stick] transformed into a snake. It will probably revert to its original state once dead."

		var/do_stick_overlay = 0
		if(istype(stick, /mob/living/critter/small_animal/snake)) // alright, here I'm assuming that we're only going two levels deep, ok?
			src.double = 1
			src.icon_state = "snake_double"
			var/mob/living/critter/small_animal/snake/old_snake = stick
			old_snake.expiration_id = 0 // we don't want it to expire inside us
			if(old_snake.my_stick)
				stick = old_snake.my_stick
			// so until the end of the proc stick is actually the real stick inside the snake, keep that in mind
			do_stick_overlay = 1
		else if(istype(stick, /obj/critter/domestic_bee))
			src.icon_state = "snake_bee"
		else if(istype(stick, /obj/item/baton))
			src.icon_state = "snake_baton"
		else if(istype(stick, /obj/item/staff/cthulhu))
			src.icon_state = "snake_cthulhu"
		else if(istype(stick, /obj/item/staff))
			src.icon_state = "snake_staff"
		else
			do_stick_overlay = 1

		src.name = src.snakify_name(stick.name, src.double)

		if(istype(stick, /obj/item/staff))
			src.health += 15
			src.attack_damage += 3

		if(do_stick_overlay)
			stick.render_target = "*\ref[stick]"
			stick.appearance_flags |= KEEP_TOGETHER
			if(!src.render_target)
				src.render_target = "\ref[src]"
			colouring = new/image(null, src)
			src.vis_contents += stick
			stick.mouse_opacity = 0
			//stick.appearance_flags |= KEEP_TOGETHER
			colouring.filters += filter(type="layer", render_source=stick.render_target)
			colouring.filters += filter(type="blur", size=6) // background big blur for tiny objects
			colouring.filters += filter(type="layer", render_source=stick.render_target)
			colouring.filters += filter(type="blur", size=2) // foreground just slightly blurred to preserve colours better
			colouring.filters += filter(type="color", color=list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,0, 0.1,0.1,0.1,1) ) // alpha to 255 and darken a bit
			colouring.filters += filter(type="alpha", render_source=src.render_target)
			colouring.blend_mode = BLEND_MULTIPLY
			world << colouring

	proc/contents_check()
		if(!src.allow_empty && !length(src.contents))
			src.visible_message(SPAN_NOTICE("<B>[src]</B> realizes that its material essence is missing and vanishes in a puff of logic!"))
			qdel(src)

	death(var/gibbed)
		..()
		drop_stick(1)
		qdel(src)

	Cross(atom/mover)
		if (istype(mover, /obj/projectile))
			return prob(50)
		else
			return ..()

	on_pet(mob/user)
		..()
		if(prob(10))
			if(icon_state == "snake_bee")
				src.visible_message("[src] buzzes delightedly!")
			else
				src.visible_message("[src] slithers around happily!")
