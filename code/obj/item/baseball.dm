/obj/item/clothing/gloves/baseball_mitt
	name = "baseball mitt"
	desc = "Good at catching things and keeping them caught if you fall. Not so great at using things after you catch them."
	wear_image_icon = 'icons/mob/clothing/hands.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_feethand.dmi'
	icon_state = "baseball_mitt"
	item_state = "baseball_mitt"
	w_class = W_CLASS_NORMAL
	material_prints = "synthetic leather netting"
	which_hands = GLOVE_HAS_LEFT
	hitsound = 'sound/items/bball_bounce.ogg'

	get_fiber_mask()
		return FORENSIC_GLOVE_MASK_NONE

	equipped(mob/user, slot)
		. = ..()
		if(user.hand == RIGHT_HAND)
			src.which_hands = GLOVE_HAS_RIGHT
			user.hand_grip_count_r += 1
		else
			src.which_hands = GLOVE_HAS_LEFT
			user.hand_grip_count_l += 1
		RegisterSignal(user, COMSIG_ATOM_HITBY_THROWN, PROC_REF(mitt_catch))
		RegisterSignal(user, COMSIG_MOB_PICKUP, PROC_REF(mitt_pickup))
		RegisterSignal(user, COMSIG_MOB_DROPPED, PROC_REF(mitt_drop))
		RegisterSignal(user, COMSIG_MOB_THROW_ADJUST, PROC_REF(mitt_adjust_throw))

		if(!ishuman(user))
			return
		var/mob/living/carbon/human/H = user
		// Need to make it clear on the hud which hand the mitt is on
		if(which_hands == GLOVE_HAS_LEFT)
			H.hud.hand_type_l = "_mitt"
		if(which_hands == GLOVE_HAS_RIGHT)
			H.hud.hand_type_r = "_mitt"
		H.hud.update_hands()

	unequipped(mob/user)
		if(HAS_FLAG(src.which_hands, GLOVE_HAS_LEFT))
			user.hand_grip_count_l -= 1
		if(HAS_FLAG(src.which_hands, GLOVE_HAS_RIGHT))
			user.hand_grip_count_r -= 1
		. = ..()
		UnregisterSignal(user, COMSIG_ATOM_HITBY_THROWN)
		UnregisterSignal(user, COMSIG_MOB_PICKUP)
		UnregisterSignal(user, COMSIG_MOB_DROPPED)
		UnregisterSignal(user, COMSIG_MOB_THROW_ADJUST)

		if(!ishuman(user))
			return
		var/mob/living/carbon/human/H = user
		H.hud.hand_type_l = null
		H.hud.hand_type_r = null
		H.hud.update_hands()

	proc/mitt_catch(mob/owner, atom/movable/thing, datum/thrown_thing/thr)
		if(owner.hand == LEFT_HAND && !HAS_FLAG(src.which_hands, GLOVE_HAS_LEFT))
			return FALSE
		if(owner.hand == RIGHT_HAND && !HAS_FLAG(src.which_hands, GLOVE_HAS_RIGHT))
			return FALSE
		if(!isitem(thing))
			return FALSE
		var/obj/item/I = thing
		if(owner.restrained())
			return FALSE
		if((owner.hand == LEFT_HAND && owner.l_hand != null) || (owner.hand == RIGHT_HAND && owner.r_hand != null))
			owner.visible_message(SPAN_ALERT("[owner] attempts to catch \the [I], but \the [src] already has something inside of it!"))
			return FALSE
		if(I.w_class > W_CLASS_POCKET_SIZED)
			owner.visible_message(SPAN_ALERT("[owner] attempts to catch \the [I] with \the [src], but it's too big!"))
			return FALSE

		playsound(owner, 'sound/items/bball_bounce.ogg', 150, TRUE)
		owner.visible_message(SPAN_COMBAT("[owner] catches \the [I] with \the [src]!"), SPAN_SUCCESS("You catch \the [I] with \the [src]!"))
		thing.Attackhand(owner)
		logTheThing(LOG_COMBAT, owner, "catches [I] with \the [src]")
		#ifdef DATALOGGER
		game_stats.Increment("catches")
		#endif

		if((prob(50) && owner.bioHolder.HasEffect("clumsy")) || thr.bonus_throwforce > 3)
			owner.visible_message(SPAN_COMBAT("[owner] stumbles from the catch!"))
			owner.changeStatus("knockdown", 2 SECONDS)
			JOB_XP(owner, "Clown", 1)

		return TRUE

	/// If it can't fit in your pocket, it will fall out of the mitt
	proc/mitt_pickup(mob/user, obj/item/I)
		if(user.hand == LEFT_HAND && !HAS_FLAG(src.which_hands, GLOVE_HAS_LEFT))
			return
		if(user.hand == RIGHT_HAND && !HAS_FLAG(src.which_hands, GLOVE_HAS_RIGHT))
			return
		RegisterSignal(I, COMSIG_ITEM_ATTACK_PRE, PROC_REF(mitt_attackby_pre))
		if(istype(I, /obj/item/gun))
			RegisterSignal(I, COMSIG_GUN_TRY_SHOOT, PROC_REF(mitt_try_shoot))
			RegisterSignal(I, COMSIG_GUN_TRY_POINTBLANK, PROC_REF(mitt_try_shoot))
		if(I.w_class > W_CLASS_POCKET_SIZED)
			SPAWN(0.35 SECONDS)
				user.visible_message(SPAN_ALERT("The [I] falls out of [user]'s [src]!"))
				user.drop_item(I)
				playsound(user, 'sound/items/bball_hoop.ogg', 20, TRUE, pitch = 1.5)
		return

	proc/mitt_drop(mob/user, obj/item/I)
		UnregisterSignal(I, COMSIG_ITEM_ATTACK_PRE)
		UnregisterSignal(I, COMSIG_GUN_TRY_SHOOT)
		UnregisterSignal(I, COMSIG_GUN_TRY_POINTBLANK)

	/// Mitt is bad at throwing things
	proc/mitt_adjust_throw(mob/thrower, datum/thrown_thing/thr)
		if(thrower.hand == LEFT_HAND && !HAS_FLAG(src.which_hands, GLOVE_HAS_LEFT))
			return
		if(thrower.hand == RIGHT_HAND && !HAS_FLAG(src.which_hands, GLOVE_HAS_RIGHT))
			return
		thr.speed /= 5
		thr.momentum /= 2
		thrower.visible_message(SPAN_ALERT("\The [src] messes up the throw!"))

	proc/mitt_attackby_pre(source, atom/target, mob/user)
		boutput(user, SPAN_ALERT("Can't attack with the [source] while it is inside the [src]!"))
		playsound(user, 'sound/items/bball_hoop.ogg', 20, TRUE, pitch = 1.5)
		return ATTACK_PRE_DONT_ATTACK

	proc/mitt_try_shoot(source, turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target)
		boutput(user, SPAN_ALERT("You can't pull the trigger with the [src] on!"))
		playsound(user, 'sound/items/bball_hoop.ogg', 20, TRUE, pitch = 1.5)
		return TRUE

	proc/mitt_try_pointblank(source, turf/target, mob/user, second_shot)
		boutput(user, SPAN_ALERT("You can't pull the trigger with the [src] on!"))
		playsound(user, 'sound/items/bball_hoop.ogg', 20, TRUE, pitch = 1.5)
		return TRUE
