/obj/item/golf_club
	name = "golf club"
	desc = "A metal rod, a curved face, and a grippy synthrubber grip.  Probably good at getting objects to go someplace else."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "club"
	item_state = "rods"
	flags = TABLEPASS| CONDUCT
	w_class = W_CLASS_NORMAL
	force = 9
	throwforce = 15
	throw_speed = 5
	throw_range = 20
	stamina_damage = 20
	stamina_cost = 16
	stamina_crit_chance = 30
	rand_pos = 1
	var/obj/item/ball
	var/obj/ability_button/swing = new /obj/ability_button/golf_swing
	var/putting = TRUE

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
		if(HAS_ATOM_PROPERTY(O, PROP_OBJ_GOLFABLE) && isturf(O.loc))
			step(user, get_dir(user, O))
			animate(user, pixel_x=O.pixel_x, pixel_y=O.pixel_y, 2 SECONDS, easing=CUBIC_EASING | EASE_OUT)
			SPAWN(1 SECONDS)
				if(GET_DIST(O, user) == 0)
					ball = O
					swing.the_mob = user
					swing.the_item = src
					user.targeting_ability = swing
					user.update_cursor()

	attack_self(mob/user as mob)
		if (src.putting)
			boutput(user, SPAN_NOTICE("You tighten your grip on the [src].  Ready for a big swing!"))
			src.putting = FALSE
		else
			boutput(user, SPAN_NOTICE("You loosen your grip on the [src]. Perfect for a nice gentle putt."))
			src.putting = TRUE
		return

	pickup(user)
		..()
		putting = TRUE

/obj/ability_button/golf_swing
	name = "Swing"
	icon_state = "shieldceoff"
	targeted = 1 //does activating this ability let you click on something to target it?
	target_anything = 1 //can you target any atom, not just people?

	execute_ability(atom/target, params)
		var/obj/item/golf_club/C = the_item
		if(GET_DIST(C,C.ball) > 0 || GET_DIST(C,the_mob) > 0 )
			return

		if (the_mob.bioHolder.HasEffect("clumsy") && prob(50))
			the_mob.visible_message(SPAN_ALERT("[the_mob] swings the [C] wildly and falls on [his_or_her(the_mob)] face."),\
			SPAN_ALERT("You swing so hard you lose your balance and fall!"))
			the_mob.changeStatus("knockdown", 2 SECONDS)
			JOB_XP(the_mob, "Clown", 4)
			return

		var/obj/item/golf_ball/GB = C.ball

		var/datum/projectile/ballshot
		if(istype(GB))
			ballshot = GB.ball_projectile
		else
			ballshot = new /datum/projectile/special/golfball

		var/debug = istype(C, /obj/item/golf_club/test)
		var/pox = text2num(params["icon-x"]) - 16
		var/poy = text2num(params["icon-y"]) - 16

		var/swing_strength = sqrt(((target.x - the_mob.x) * 32 + pox)**2 + ((target.y - the_mob.y) * 32 + poy)**2)
		swing_strength /= 32
		swing_strength *= get_swing_strength_mod(the_mob, C)

		if(istype(GB))
			GB.strike(C, the_mob, swing_strength)

		if(QDELETED(C.ball))
			C.ball = null

		if(!istype(C) || !C.ball || !ballshot)
			return

		var/golfyness = calculate_golfer(the_mob) // used to add RNG to shots, low is good
		var/mod_x = (rand()-0.5) * 5 * swing_strength * golfyness
		var/mod_y = (rand()-0.5) * 5 * swing_strength * golfyness

		if(debug)
			boutput(the_mob, "Swing Strength:[swing_strength] RNG [mod_x]x[mod_y] @ [golfyness]")

		ballshot.max_range = swing_strength + ( ((rand()-0.5) * 3) * golfyness )

		var/obj/projectile/P = shoot_projectile_ST_pixel_spread(the_mob, ballshot, target, pox+mod_x, poy+mod_y)
		if (P)
			P.targets = list(target)
			P.mob_shooter = the_mob
			P.shooter = the_mob
			P.icon = C.ball.icon
			P.icon_state = C.ball.icon_state
			if(debug)
				P.color = the_item.color
			else
				P.color = C.ball.color
			C.ball.set_loc(P)
			P.special_data["ball"] = C.ball
			P.special_data["debug"] = debug

			P.proj_data.RegisterSignal(P, COMSIG_MOVABLE_MOVED, /datum/projectile/special/golfball/proc/check_newloc)

		animate(the_mob, pixel_x=0, pixel_y=0, 1 SECONDS, easing=CUBIC_EASING)
		C.ball = null

	proc/get_swing_strength_mod(mob/user, obj/item/golf_club/C)
		. = 1
		if(user.is_hulk() || user.bioHolder.HasEffect("strong"))
			. *= (0.5 + (rand()*3))
		if(user.bioHolder.HasEffect("fitness_debuff"))
			. *= 0.75
		if(!C.putting)
			. *= 1.75

	proc/calculate_golfer(mob/user)
		. = 1

		if (user.hasStatus("drunk"))
			. *= 0.7
		if (user.reagents?.has_reagent("halfandhalf"))
			. *= 0.8

		if( the_mob.bioHolder.HasEffect("clumsy") )
			. *= 2
		if( the_mob.bioHolder.HasEffect("funky_limb") )
			if(prob(20))
				. *= 2
			else if(prob(5))
				. *= 0.5
		if( the_mob.bioHolder.HasEffect("sneeze") )
			if(prob(10))
				. *= 1.5

/datum/projectile/special/golfball
	name = "golf ball"
	sname = "golf ball"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "golf_ball"
	shot_sound = null
	stun = 0
	cost = 1
	damage_type = D_SPECIAL
	hit_type = DAMAGE_BLUNT
	dissipation_delay = 0
	dissipation_rate = 0
	projectile_speed = 20
	hit_ground_chance = 100
	var/max_bounce_count = 25
	var/slam_text = "The golf ball SLAMS into you!"
	var/hit_sound = 'sound/effects/mag_magmisimpact_bounce.ogg'
	var/last_sound_time = 0

	proc/check_newloc(obj/projectile/O, atom/NewLoc)
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
				if(istype(I,/obj/item/storage/golf_goal))
					. = FALSE
				else if(prob((W_CLASS_BUBSIAN - I.w_class) * 10))
					if(O.special_data["debug"])
						boutput(O.mob_shooter, "[O] misses [hit].")
					. = TRUE
				else
					O.visible_message("[O] bounces off of [hit].")
					hit_twitch(hit)
			else
				if(hit.pixel_x >= 10 || hit.pixel_x <= -10 || hit.pixel_y >= 10 || hit.pixel_y <= -10)
					if(O.special_data["debug"])
						boutput(O.mob_shooter, "[O] ignored [hit].")
						. = TRUE

	on_hit(atom/A, direction, var/obj/projectile/projectile)
		. = ..()
		var/obj/item/golf_ball/ball = projectile.special_data["ball"]
		if(projectile.reflectcount < src.max_bounce_count)
			var/reflect_power = max(0, projectile.max_range*(1-(projectile.travelled/(projectile.max_range*32))))
			if(istype(ball))
				ball.strike(A, projectile.mob_shooter, reflect_power, TRUE)
			if(QDELETED(ball))
				return

			var/obj/projectile/Q = shoot_reflected_bounce(projectile, A, src.max_bounce_count, PROJ_RAPID_HEADON_BOUNCE)
			if(Q)
				ball.set_loc(Q)
				Q.icon = projectile.icon
				Q.icon_state = projectile.icon_state
				Q.color = projectile.color
				Q.special_data["ball"] = ball
				Q.travelled = projectile.travelled
			else
				ball.set_loc(get_turf(A))

			var/turf/T = get_turf(A)
			if(TIME >= last_sound_time + 1 DECI SECOND)
				last_sound_time = TIME
				playsound(T, src.hit_sound, 60, 1)
		else
			ball.set_loc(get_turf(A))

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

		var/obj/item/ball = O.special_data["ball"]
		if(!ball)
			ball = new /obj/item/golf_ball(T)
			ball.color = O.special_data["color"]
		else
			if(!QDELETED(ball))
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

	var/datum/projectile/special/golfball/ball_projectile

	New()
		..()
		if(!ball_projectile)
			ball_projectile = new
		APPLY_ATOM_PROPERTY(src, PROP_OBJ_GOLFABLE, src)

	attackby(obj/item/W, mob/user, params)
		if(istype(W, /obj/item/golf_club))
			return //We haven't hit been hit yet...
		else
			. = ..()

	proc/strike(atom/A, mob/user, power, reflect=FALSE)
		if(!reflect)
			src.Attackby(A, user)
		return

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
				if( ((P.max_range * 32) - P.travelled) <= 48) // 32?
					if(length(contents))
						visible_message("[P] knocks into [src]. There must already be a ball in there!")
					else
						if(!QDELETED(ball))
							src.storage.add_contents(ball)
						P.alpha = 0
						P.die()
						visible_message("[P] makes it into [src]. Nice shot!")
						hit_twitch(src)
				else
					src.visible_message("[P] bounces off of [src].")
					hit_twitch(src)

	automatic_return
		var/return_range = 5

		bullet_act(var/obj/projectile/P)
			..()
			var/obj/item/golf_ball/ball = locate() in src.storage.get_contents()
			if(ball)
				var/list/nearby_turfs = list()
				for (var/turf/T in view(2, src))
					nearby_turfs += T

				SPAWN(rand(2 SECONDS, 5 SECONDS))
					animate_spin(src,looping=3)
					sleep(0.2 SECOND)

					src.storage.transfer_stored_item(ball, get_turf(src))
					ball.layer = src.layer

					ball.ball_projectile.max_range = lerp(return_range, rand()*return_range, 0.3)
					var/target = pick(nearby_turfs)
					var/obj/projectile/Q = shoot_projectile_ST_pixel_spread(src, ball.ball_projectile, target, (rand()-0.5)*32, (rand()-0.5)*32)
					if (Q)
						Q.targets = list(target)
						Q.mob_shooter = null
						Q.shooter = src
						Q.color = ball.color
						ball.set_loc(Q)
						Q.special_data["ball"] = ball

/obj/item/storage/toilet
	bullet_act(var/obj/projectile/P)
		if(istype(P.proj_data,/datum/projectile/special/golfball))
			var/obj/item/ball = P.special_data["ball"]
			if(istype(ball) && P.mob_shooter)
				if( ((P.max_range * 32) - P.travelled) < 48 || prob(10))
					if(!QDELETED(ball))
						src.storage.add_contents(ball)
					P.alpha = 0
					P.die()
					visible_message("[P] makes it into [src]. Nice shot?")
					hit_twitch(src)
					attack_hand(P.mob_shooter)
		else
			..()
