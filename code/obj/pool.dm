/obj/pool
	name = "pool"
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pool"
	flags = FLUID_DENSE | IS_PERSPECTIVE_FLUID | FLUID_DENSE_ALWAYS

	Cross(atom/movable/mover)
		ENSURE_TYPE(mover)
		if (mover?.throwing)
			return 1
		return ..()

/obj/pool/ladder
	name = "pool ladder"
	anchored = ANCHORED
	density = 0
	dir = WEST
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder"

/obj/pool/perspective
	name = "pool"
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/fluid.dmi'
	plane = PLANE_FLOOR
	icon_state = "pool"

/obj/pool/perspective/innercorners
	name = "pool"
	icon_state = "pool_inner"
/obj/pool_springboard
	name = "springboard"
	density = 0
	anchored = ANCHORED
	layer = EFFECTS_LAYER_UNDER_2
	pixel_x = -16
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "springboard"
	var/in_use = 0
	var/suiciding = 0
	var/deadly = 0
	var/buckled_guy // a a aaaaaaa aa aaaaaaaa

	attackby(obj/item/W, mob/user)
		return src.Attackhand(user)

	MouseDrop_T(atom/target, mob/user)
		if (BOUNDS_DIST(user, src) == 0 && target == user)
			src.Attackhand(user)

	attack_hand(mob/user)
		if(in_use)
			boutput(user, SPAN_ALERT("Its already in use - wait a bit."))
			return
		else
			in_use = 1
			user.transforming = 1
			var/range = pick(25;1,2,3)
			var/turf/target = src.loc
			for(var/i = 0, i<range, i++)
				if(!suiciding && !deadly) target = get_step(target,WEST)
				else target = get_step(target,EAST)
			if(!suiciding && !deadly) user.set_dir(WEST)
			else user.set_dir(EAST)
			user.pixel_y = 15
			user.layer = EFFECTS_LAYER_UNDER_1
			user.set_loc(src.loc)
			if(user.buckled)
				user.buckled.unbuckle()
			user.buckled = src
			sleep(0.3 SECONDS)
			user.pixel_x = -3
			sleep(0.3 SECONDS)
			user.pixel_x = -6
			sleep(0.3 SECONDS)
			user.pixel_x = -9
			sleep(0.3 SECONDS)
			user.pixel_x = -12
			playsound(user, 'sound/effects/spring.ogg', 60, TRUE)
			sleep(0.3 SECONDS)
			user.pixel_y = 25
			sleep(0.5 SECONDS)
			user.pixel_y = 15
			playsound(user, 'sound/effects/spring.ogg', 60, TRUE)
			sleep(0.5 SECONDS)
			user.pixel_y = 25
			user.start_chair_flip_targeting(extrarange = 2)
			sleep(0.5 SECONDS)
			user.pixel_y = 15
			playsound(user, 'sound/effects/spring.ogg', 60, TRUE)
			sleep(0.5 SECONDS)
			user.pixel_y = 25
			playsound(user, 'sound/effects/brrp.ogg', 15, TRUE)
			sleep(0.2 SECONDS)
			if(range == 1) boutput(user, SPAN_ALERT("You slip..."))
			user.layer = MOB_LAYER
			user.buckled = null
			if (user.targeting_ability == user.chair_flip_ability) //we havent chair flipped, just do normal jump
				user.throw_at(target, 5, 1)
				user:changeStatus("knockdown", 2 SECONDS)
			user.end_chair_flip_targeting()
			if(suiciding || deadly)
				src.visible_message(SPAN_ALERT("<b>[user.name] dives headfirst at the [target.name]!</b>"))
				SPAWN(0.3 SECONDS) //give them time to land
					if (user)
						user.TakeDamage("head", 200, 0)
						playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			user.pixel_y = 0
			user.pixel_x = 0
			if (istype(user, /mob/living/silicon/ai))
				src.visible_message(SPAN_ALERT("[user.name]'s bulky frame slams straight into the ground!"))
				user.emote("scream")
				playsound(user, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 60, TRUE)
				user.TakeDamage(brute=10)
				for (var/mob/M in viewers(user))
					shake_camera(M, 4, 16)
			else
				if (!istype(get_turf(user), /turf/space) || istype(get_turf(user), /turf/space/fluid))
					var/underwater = FALSE
					if (istype(get_turf(user), /turf/space/fluid)) underwater = TRUE
					else
						var/turf/T = get_turf(user)
						if (T?.active_liquid)
							if(T.active_liquid.last_depth_level > 2)
								underwater = TRUE
					if (underwater)
						playsound(user, 'sound/impact_sounds/Liquid_Hit_Big_1.ogg', 60, TRUE)
					else
						if (issilicon(user))
							playsound(user, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 60, TRUE)
						else
							playsound(user, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, TRUE, 0.2, 1)
						src.visible_message(SPAN_ALERT("[user.name] lands on the ground hard!"))
						user.TakeDamage(brute = 10)
			in_use = 0
			suiciding = 0
			user.transforming = 0

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (in_use)
			return 0
		suiciding = 1 //reset in attack_hand() at the same time as in_use
		src.Attackhand(user)

		SPAWN(50 SECONDS)
			if (src)
				src.suiciding = 0
			if (user && !isdead(user))
				user.suiciding = 0
		return 1
