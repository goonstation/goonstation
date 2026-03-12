/obj/item/clothing/under/gimmick/bowling
	name = "bowling suit"
	desc = "Who's up for some bowling?"
	icon = 'icons/obj/clothing/jumpsuits/item_js_athletic.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_athletic.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuits/hand_js_athletic.dmi'
	icon_state = "bowling"
	item_state = "bowling"
	item_function_flags = IMMUNE_TO_ACID
	HELP_MESSAGE_OVERRIDE("Wear this to wield bowling balls effectively in melee or thrown combat.")


/obj/item/bowling_ball
	name = "bowling ball"
	desc = "Just keep rollin' rollin'."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bowling_ball"
	w_class = W_CLASS_NORMAL
	force = 5
	throw_speed = 1

	HELP_MESSAGE_OVERRIDE("While wearing a bowling suit, you can throw this to stun and deal decent damage to someone. You can also effectively wield it in melee combat while wearing the bowling suit.")

	proc/hitWeak(var/mob/hitMob, var/mob/user)
		hitMob.visible_message(SPAN_ALERT("[hitMob] is hit by [user]'s [src]!"))

		src.damage(hitMob, 5, 10, user)

	proc/hitHard(var/mob/hitMob, var/mob/user)
		hitMob.visible_message(SPAN_ALERT("[hitMob] is knocked over by [user]'s [src]!"))

		src.damage(hitMob, 15, 20, user)

	proc/damage(var/mob/hitMob, damMin, damMax, var/mob/living/carbon/human/user)
		if(user.w_uniform && istype(user.w_uniform, /obj/item/clothing/under/gimmick/bowling))
			hitMob.stuttering = max(damMax-5, hitMob.stuttering)
			if (damMax-10 > 0)
				hitMob.changeStatus("knockdown", 5 SECONDS)
				hitMob.force_laydown_standup()
			hitMob.TakeDamageAccountArmor("chest", rand(damMin, damMax), 0)
		else
			hitMob.stuttering = max(damMax-5, hitMob.stuttering)
			hitMob.TakeDamageAccountArmor("chest", rand(damMin, damMax), 0)

	throw_at(atom/target, range, speed, list/params, turf/thrown_from, mob/thrown_by, throw_type = 1,
			allow_anchored = UNANCHORED, bonus_throwforce = 0, end_throw_callback = null)
		throw_unlimited = 1
		src.icon_state = "bowling_ball_spin"
		var/datum/thrown_thing/thr = ..()
		thr.stops_on_mob_hit = FALSE

	attack_hand(mob/user)
		..()
		if(user)
			src.icon_state = "bowling_ball"

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		var/mob/living/carbon/human/user = thr.user || usr

		src.icon_state = "bowling_ball"
		if(hit_atom)
			playsound(src.loc, 'sound/effects/exlow.ogg', 65, 1)
			if (ismob(hit_atom))
				var/mob/hitMob = hit_atom
				SPAWN( 0 )
					if (istype(user))
						if (istype(user.w_uniform, /obj/item/clothing/under/gimmick/bowling))
							src.hitHard(hitMob, user)
							if (ishuman(hitMob))
								var/turf/new_target = get_steps(hitMob, get_dir(thr.thrown_from, get_turf(hitMob)), 8)
								hitMob.throw_at(new_target, 8, thr.speed, thr.params, thr.thrown_from, thr.thrown_by, thr.throw_type)
								if(!(hitMob == user) && !ON_COOLDOWN(user, "bowling_speak", 1 SECOND))
									user.say(pick("Who's the kingpin now, baby?", "STRIIIKE!", "Watch it, pinhead!", "Ten points!"))
						else
							src.hitWeak(hitMob, user)
					else
						src.hitWeak(hitMob, user)
		return

	attack(obj/item/W, mob/user, params)
		var/mob/living/carbon/human/human_user = user
		if(istype(human_user.w_uniform, /obj/item/clothing/under/gimmick/bowling))
			//bashing someones skull in with a bowling ball should hurt if you are worthy of the bowling ball
			src.force = 15
			src.stamina_damage = 40
		. = ..()
		src.force = initial(src.force)
		src.stamina_damage = initial(src.stamina_damage)

/obj/item/armadillo_ball
	name = "armadillo ball"
	desc = "Just keep rollin' rollin'."
	icon_state = "armadillo_ball"

	pickup(mob/user)
		if(locate(/mob/living/critter/small_animal/armadillo) in src)
			..()
		else
			user.remove_item(src)
			qdel(src)

	throw_at(atom/target, range, speed, list/params, turf/thrown_from, mob/thrown_by, throw_type = THROW_NORMAL, allow_anchored = UNANCHORED, bonus_throwforce = 0)
		if(!ismob(target))
			throw_unlimited = 1
		..()
		src.icon = initial(src.icon)
		src.icon_state = "armadillo_spin"

	attack_hand(mob/user)
		..()
		if(user)
			src.icon = initial(src.icon)
			src.icon_state = "armadillo_ball"

	relaymove(mob/user as mob)
		if(user.stat)
			return
		var/mob/living/critter/small_animal/armadillo/A = user
		if(istype(A))
			A.ball_up(FALSE)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		var/mob/living/carbon/human/user = usr
		src.icon_state = "armadillo_ball"

		if(hit_atom)
			if (ismob(hit_atom))
				var/mob/hitMob = hit_atom
				if (ishuman(hitMob))
					hitMob.visible_message(SPAN_ALERT("[hitMob] is hit by [user]'s [src]!"))

	mob_flip_inside(mob/user)
		var/mob/living/critter/small_animal/armadillo/A = user
		if(istype(A))
			. = A.ball_up(TRUE)
