TYPEINFO(/mob/living/intangible)
	start_listen_languages = list(LANGUAGE_ALL)

/mob/living/intangible
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = ANCHORED
	throws_can_hit_me = FALSE
	event_handler_flags =  IMMUNE_OCEAN_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP | MOVE_NOCLIP
	canbegrabbed = FALSE
	can_lie = FALSE

	New()
		. = ..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_GHOST)
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		src.see_invisible = INVIS_GHOST
		src.see_in_dark = SEE_DARK_FULL
		src.flags |= UNCRUSHABLE

	nauseate(stacks)
		return
	can_strip()
		return 0
	can_eat()
		return FALSE
	can_use_hands()
		return 0
	is_active()
		return 0
	Cross(atom/movable/mover)
		return 1

	meteorhit()
		return

	mouse_drop()
		return

	MouseDrop_T()
		return

	projCanHit(datum/projectile/P)
		return 0

    //can't electrocute intangible things
	shock(var/atom/origin, var/wattage, var/zone = "chest", var/stun_multiplier = 1, var/ignore_gloves = 0)
		return 0

	//can't be on fire if you're intangible either
	set_burning(var/new_value)
		return 0

	update_burning(var/change)
		return 0

	// No log entries for unaffected mobs (Convair880).
	ex_act(severity)
		return

	Move(NewLoc, direct)
		if(!canmove) return

		//Mostly for manifested wraith. Dont move through everything.
		if (src.density) return ..()

		if (!can_ghost_be_here(src, NewLoc))
			var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (OS)
				src.set_loc(OS)
			else
				src.z = 1
			OnMove()
			return

		return ..()

/mob/living/intangible/change_eye_blurry(var/amount, var/cap = 0)
	if (amount < 0)
		return ..()
	else
		return 1

/mob/living/intangible/take_eye_damage(var/amount, var/tempblind = 0)
	if (amount < 0)
		return ..()
	else
		return 1

/mob/living/intangible/take_ear_damage(var/amount, var/tempdeaf = 0)
	if (amount < 0)
		return ..()
	else
		return 1
