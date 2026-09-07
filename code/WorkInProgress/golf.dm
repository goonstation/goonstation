/obj/item/golf_club
	name = "golf club"
	desc = "A metal rod, a curved face, and a grippy synthrubber grip.  Probably good at getting objects to go someplace else."
	icon = 'icons/obj/items/golf.dmi'
	inhand_image_icon = 'icons/obj/items/golf.dmi'
	icon_state = "golf_club"
	item_state = "golf_club_inhand"
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
			color = pick(null,"#f44","#942", "#4f4","#296", "#44f","#429")

	test
		New(turf/newLoc)
			..()
			new /obj/item/golf_ball(newLoc)
			new /obj/item/storage/golf_goal(newLoc)

	New()
		AddComponent(/datum/component/holdertargeting/golf_club, list(SLOT_L_HAND, SLOT_R_HAND))
		..()

	afterattack(obj/O as obj, mob/user as mob)
		if(HAS_ATOM_PROPERTY(O, PROP_OBJ_GOLFABLE) && O.GetComponent(/datum/component/golfable) && isturf(O.loc))
			step(user, get_dir(user, O))
			animate(user, pixel_x=O.pixel_x, pixel_y=O.pixel_y, 2 SECONDS, easing=CUBIC_EASING | EASE_OUT)
			SPAWN(1 SECONDS)
				if(GET_DIST(O, user) == 0)
					ball = O
					swing.the_mob = user
					swing.the_item = src
					if(istype(swing, /obj/ability_button/golf_swing))
						var/obj/ability_button/golf_swing/GS = swing
						GS.target_item = ball
						swing = GS
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

/datum/component/holdertargeting/golf_club

/datum/component/holdertargeting/golf_club/on_pickup(datum/source, mob/equipper, slot)
	var/obj/item/I = parent
	I.add_item_ability(equipper, /obj/ability_button/golf_swing)
	. = ..()

/datum/component/holdertargeting/golf_club/on_dropped(datum/source, mob/user)
	var/obj/item/I = parent
	I.remove_item_ability(user, /obj/ability_button/golf_swing)
	. = ..()


/obj/ability_button/golf_swing
	name = "Swing"
	icon_state = "shieldceoff"
	targeted = 1 //does activating this ability let you click on something to target it?
	target_anything = 1 //can you target any atom, not just people?
	var/target_item = null //what we're actually swinging

	execute_ability(atom/target, params)
		var/obj/item/golf_club/C = the_item
		if(istype(C, /obj/item/golf_ball)) // unique cause only official balls track course performance
			var/obj/item/golf_ball/GB = C
			GB.strike_amount++
		if(GET_DIST(C,C.ball) > 0 || GET_DIST(C,the_mob) > 0 )
			return

		if (the_mob.bioHolder.HasEffect("clumsy") && prob(50))
			the_mob.visible_message(SPAN_ALERT("[the_mob] swings the [C] wildly and falls on [his_or_her(the_mob)] face."),\
			SPAN_ALERT("You swing so hard you lose your balance and fall!"))
			the_mob.changeStatus("knockdown", 2 SECONDS)
			JOB_XP(the_mob, "Clown", 4)
			return

		var/obj/item/GB = C.ball

		var/datum/projectile/special/golfball/ballshot
		if(istype(GB) && GB.GetComponent(/datum/component/golfable))
			var/datum/component/golfable/GC = GB.GetExactComponent(/datum/component/golfable)
			var/datum/projectile/special/golfball/GBD = GC.ball_projectile
			ballshot = GBD
		else
			ballshot = new /datum/projectile/special/golfball

		var/debug = istype(C, /obj/item/golf_club/test)
		var/pox = text2num(params["icon-x"]) - 16
		var/poy = text2num(params["icon-y"]) - 16

		var/swing_strength = sqrt(((target.x - the_mob.x) * 32 + pox)**2 + ((target.y - the_mob.y) * 32 + poy)**2)
		swing_strength /= 32
		swing_strength *= get_swing_strength_mod(the_mob, C)

		if(istype(GB) && GB.GetComponent(/datum/component/golfable))
			SEND_SIGNAL(src, COMSIG_GOLF_STRIKE, C, the_mob, swing_strength)

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
			P.create_storage(/datum/storage/golfball)
			if(debug)
				P.color = the_item.color
			else
				P.color = C.ball.color
			C.ball.set_loc(P)
			if(!P.proj_data)
				P.proj_data = C.ball
			if(istype(P.proj_data, /datum/projectile/special/golfball))
				ballshot.origin_item = C.ball
			P.proj_data.RegisterSignal(P, COMSIG_MOVABLE_MOVED, /datum/projectile/special/golfball/proc/check_newloc)
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
	icon = 'icons/obj/items/golf.dmi'
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
	var/obj/item/origin_item = null

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
					if(origin_item)
						origin_item.loc = O.loc
					hit_twitch(hit)
			else
				if(hit.pixel_x >= 10 || hit.pixel_x <= -10 || hit.pixel_y >= 10 || hit.pixel_y <= -10)
					if(origin_item)
						origin_item.loc = O.loc
					if(O.special_data["debug"])
						boutput(O.mob_shooter, "[O] ignored [hit].")
						. = TRUE
				else

					origin_item.loc = O.loc

	on_hit(atom/A, direction, var/obj/projectile/projectile)
		. = ..()
		var/obj/item/ball = src.origin_item
		if(projectile.reflectcount < src.max_bounce_count)
			var/reflect_power = max(0, projectile.max_range*(1-(projectile.travelled/(projectile.max_range*32))))
			if(istype(ball))
				src.icon = ball.icon //for "balls"
				src.name = ball.name
			if(istype(ball))
				SEND_SIGNAL(origin_item, COMSIG_GOLF_STRIKE, A, src, reflect_power, TRUE)
			if(QDELETED(ball))
				return
			if(!A.density)
				return

			var/obj/projectile/Q = shoot_reflected_bounce(projectile, A, src.max_bounce_count, PROJ_RAPID_HEADON_BOUNCE)
			if(Q)
				ball.set_loc(Q)
				Q.icon = projectile.icon
				Q.icon_state = projectile.icon_state
				Q.color = projectile.color
				if(istype(Q.proj_data, /datum/projectile/special/golfball))
					var/datum/projectile/special/golfball/GBD = Q.proj_data
					GBD.origin_item = ball
				Q.create_storage(/datum/storage/golfball)
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
		var/obj/item/ball = null
		var/turf/T = get_turf(O)
		if(istype(O, /obj/projectile))
			if(istype(O.proj_data, /datum/projectile/special/golfball))
				var/datum/projectile/special/golfball/GBD = O.proj_data
				ball = GBD.origin_item
			if(O.storage) // Disposings got this
				qdel()
		if(!ball)
			ball = new origin_item(T)
			ball.color = O.special_data["color"]
		else
			if(!QDELETED(ball))
				ball.set_loc(T)

		ball.pixel_x = O.pixel_x
		ball.pixel_y = O.pixel_y
		return

/datum/storage/golfball // What stores the actual golf ball item in the projectile (obj)
	slots = 1

/datum/component/golfable
	var/list/signals = list()
	var/obj/item/golf_club/club = null
	var/obj/item/ball = null
	var/datum/projectile/special/golfball/ball_projectile = null

/datum/component/golfable/Initialize(atom/target)
	. = ..()
	if(!istype(src.parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.ball = target
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(pass_on_attackby))
	if(!ball_projectile)
		ball_projectile = new
		ball_projectile.origin_item = src.ball

/datum/component/golfable/proc/pass_on_attackby(atom/movable/parent, obj/item/item, mob/user, params)
	if(istype(item, /obj/item/golf_club))
		return //We haven't hit been hit yet...
	else
		src.ball.Attackby(item, user, params)

/datum/component/golfable/UnregisterFromParent()
	var/atom/movable/parent = src.parent
	UnregisterSignal(parent, list(COMSIG_ATTACKBY))
	src.ball = null
	. = ..()

/datum/component/golfable/proc/strike(atom/A, mob/user, power, reflect=FALSE)
	if(!reflect)
		ball.Attackby(A, user)
	return

/obj/item/golf_ball
	name = "golf ball"
	desc = "A small dimpled ball intended for recreation."
	icon = 'icons/obj/items/golf.dmi'
	icon_state = "golf_ball"
	w_class = W_CLASS_TINY
	var/current_hole = null // Balls are smarter then improvised balls and can work on mechcomp courses
	var/current_course = null
	var/strike_amount = null
	var/owner = null

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_OBJ_GOLFABLE, src)
		AddComponent(/datum/component/golfable)
		AddComponent(/datum/component/mechanics_holder)

	pick_up_by(mob/M)
		if(ishuman(M))
			boutput(M, "You feel a slight heat as the golf ball registers itself to your fingerprint.")
			owner = M.bioHolder.Uid


	random
		New(turf/newLoc)
			..()
			color = pick(null,"#f44","#942", "#4f4","#296", "#44f","#429")

/obj/item/storage/golf_goal
	name = "Golf Goal"
	desc = "A deployable recreational golf goal, you should be aiming for this."
	icon = 'icons/obj/items/golf.dmi'
	icon_state = "golf_goal"
	item_state = "golf_goal"
	rand_pos = TRUE
	can_hold = list(/obj/item/golf_ball)
	slots = 1
	max_wclass = W_CLASS_TINY
	plane = PLANE_NOSHADOW_ABOVE
	var/deployed = FALSE
	var/hole_num = null // set hole in a larger set of holes
	var/course_id = null // actual identifier for the course group itself
	HELP_MESSAGE_OVERRIDE("Use a wrench to toggle the deployment of the goal.")

	New()
		..()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Hole Number", PROC_REF(set_hole_num))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Course ID", PROC_REF(set_course_id))

	attackby(var/obj/item/I, var/mob/M)
		if (iswrenchingtool(I))
			if (deployed)
				src.undeploy()
			else
				if (src in M.contents)
					src.force_drop()
				src.deploy()
		..()

	bullet_act(var/obj/projectile/P)
		if(!deployed) return
		if(istype(P.proj_data,/datum/projectile/special/golfball))
			var/datum/projectile/special/golfball/GBD = P.proj_data
			var/obj/item/ball = GBD.origin_item
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
						if(istype(ball, /obj/item/golf_ball))
							var/obj/item/golf_ball/GB = ball
							if(GB.current_course == src.course_id && GB.current_hole == src.hole_num)
								SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "scored_with=[GB.strike_amount]&hole_num=[GB.current_hole]&course_id=[GB.current_course]&golfer=[data_core.general.forensic_search_subjects(GB.owner)]")
							else
								visible_message("The infamous incorrect hole alert goes off.")
								playsound(src.loc, 'sound/machines/bloop_sad.ogg', 50, 1, 0.3)

							GB.strike_amount = null
				else
					src.visible_message("[P] bounces off of [src].")
					GBD.origin_item.set_loc(src.loc)
					hit_twitch(src)

	proc/undeploy()
		src.icon_state = "golf_goal"
		deployed = 0
		anchored = 0
		processing_items -= src

	proc/deploy()
		processing_items |= src
		src.icon_state = "golf_goal-d"
		pixel_x = 0
		pixel_y = 0
		deployed = 1
		anchored = 1
		process()
		usr.next_click = world.time + 1
		playsound(src.loc, 'sound/effects/chute_place_1.ogg', 50, 1, 0.3)

	proc/set_hole_num(obj/item/W, mob/user)
		var/newholenum = tgui_input_number(user, "Please enter hole number:", "Hole Number", 0, 18, 0)
		if (!newholenum)
			return
		src.hole_num = newholenum
		boutput(user, "Hole number set to:[src.hole_num]")

	proc/set_course_id(obj/item/W, mob/user)
		var/newcourseid = tgui_input_text(user, "Please enter course ID.", "Course ID", "", 20)
		if (!newcourseid)
			return
		src.course_id = newcourseid
		boutput(user, "Course ID set to:[src.course_id]")

	random
		New(turf/newLoc)
			..()
			color = pick(null,"#f44","#942", "#4f4","#296", "#44f","#429")

	automatic_return
		var/return_range = 5

		bullet_act(var/obj/projectile/P)
			..()
			var/obj/item/ball = locate() in src.storage.get_contents()
			if(ball && ball.GetComponent(/datum/component/golfable))
				var/datum/projectile/special/golfball/golf_projectile = null
				var/datum/component/golfable/GC = ball.GetExactComponent(/datum/component/golfable)
				golf_projectile = GC.ball_projectile //For projectile calls
				var/list/nearby_turfs = list()
				for (var/turf/T in view(2, src))
					nearby_turfs += T

				SPAWN(rand(2 SECONDS, 5 SECONDS))
					animate_spin(src,looping=3)
					sleep(0.2 SECOND)

					src.storage.transfer_stored_item(ball, get_turf(src))
					ball.layer = src.layer

					golf_projectile.max_range = lerp(return_range, rand()*return_range, 0.3)
					var/target = pick(nearby_turfs)
					var/obj/projectile/Q = shoot_projectile_ST_pixel_spread(src, golf_projectile, target, (rand()-0.5)*32, (rand()-0.5)*32)
					if (Q)
						Q.targets = list(target)
						Q.mob_shooter = null
						Q.shooter = src
						Q.color = ball.color
						ball.set_loc(Q)
						if(istype(Q.proj_data,/datum/projectile/special/golfball))
							var/datum/projectile/special/golfball/GB = Q.proj_data
							GB.origin_item = ball

/obj/item/storage/golf_tee
	name = "Golf Tee"
	desc = "A deployable plastic sphere pedestal, meant to represent the start of a golf course."
	icon = 'icons/obj/items/golf.dmi'
	icon_state = "golf_tee"
	item_state = "golf_tee"
	rand_pos = TRUE
	can_hold = list(/obj/item/golf_ball)
	slots = 1
	max_wclass = W_CLASS_TINY
	plane = PLANE_NOSHADOW_ABOVE
	var/deployed = FALSE
	var/hole_num = null // set hole in a larger set of holes
	var/course_id = null // actual identifier for the course group itself
	HELP_MESSAGE_OVERRIDE("Use a wrench to toggle the deployment of the tee.")

	New()
		..()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Hole Number", PROC_REF(set_hole_num))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Course ID", PROC_REF(set_course_id))

	proc/set_hole_num(obj/item/W, mob/user)
		var/newholenum = tgui_input_number(user, "Please enter hole number:", "Hole Number", 0, 18, 0)
		if (!newholenum)
			return
		src.hole_num = newholenum
		boutput(user, "Hole number set to:[src.hole_num]")

	proc/set_course_id(obj/item/W, mob/user)
		var/newcourseid = tgui_input_text(user, "Please enter course ID.", "Course ID", "", 20)
		if (!newcourseid)
			return
		src.course_id = newcourseid
		boutput(user, "Course ID set to:[src.course_id]")

	random
		New(turf/newLoc)
			..()
			color = pick(null,"#f44","#942", "#4f4","#296", "#44f","#429")

	attackby(var/obj/item/I, var/mob/M)
		if (iswrenchingtool(I))
			if (deployed)
				src.undeploy()
			else
				if (src in M.contents)
					src.force_drop()
				src.deploy()
		if(I.GetComponent(/datum/component/golfable))
			if(istype(I, /obj/item/golf_ball))
				var/obj/item/golf_ball/GB = I
				if(length(contents))
					visible_message("[M] presses [GB] against the ball that's clearly already there!")
				else
					if(!QDELETED(I))
						src.storage.add_contents(GB, M)
						src.icon_state = "golf_tee-dp"
						GB.current_hole = src.hole_num
						GB.current_course = src.course_id
						GB.strike_amount = null
			else
				visible_message("[M] tries to put [I] on the golf tee, but the patented grooves inside make it impossible to properly attach!") // Just regular ones for the tee
		if(istype(I, /obj/item/golf_club))
			if(!length(contents))
				visible_message("[M] lines up to swing at nothing! What a dummy.")
			else
				for(var/obj/item/O in contents)
					src.storage.transfer_stored_item(O, src.loc)
					I.afterattack(O, M)
					src.icon_state = "golf_tee"
		..()


	proc/undeploy()
		deployed = 0
		anchored = 0
		processing_items -= src

	proc/deploy()
		processing_items |= src
		pixel_x = 0
		pixel_y = 0
		deployed = 1
		anchored = 1
		process()
		usr.next_click = world.time + 1
		playsound(src.loc, 'sound/effects/chute_place_1.ogg', 50, 1, 0.3)

/obj/item/storage/toilet
	bullet_act(var/obj/projectile/P)
		if(istype(P.proj_data,/datum/projectile/special/golfball))
			var/datum/projectile/special/golfball/GB = P.proj_data
			var/obj/item/ball = GB.origin_item
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
