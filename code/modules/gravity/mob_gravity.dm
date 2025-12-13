#define GRAVITY_EFFECT_NONE 0
#define GRAVITY_EFFECT_LOW 1
#define GRAVITY_EFFECT_NORMAL 2
#define GRAVITY_EFFECT_HIGH 3
#define GRAVITY_EFFECT_EXTREME 4

/mob/proc/update_gravity(new_gravity)
	src.update_traction()
	if (src.traction)
		src.inertia_dir = 0

/// The last gravity
/mob/living/var/last_gravity = 1
/mob/living/update_gravity(new_gravity)
	. = ..()
	if (new_gravity == src.last_gravity)
		return
	if (HAS_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE))
		return
	src.last_gravity = new_gravity
	switch(new_gravity)
		if (1) // mild perf i think
			src.setStatus("gravity", INFINITE_STATUS, optional=GRAVITY_EFFECT_NORMAL)
		if (-INFINITY to 0)
			src.setStatus("gravity", INFINITE_STATUS, optional=GRAVITY_EFFECT_NONE)
		if (GRAVITY_MOB_REGULAR_THRESHOLD to GRAVITY_MOB_HIGH_THRESHOLD)
			src.setStatus("gravity", INFINITE_STATUS, optional=GRAVITY_EFFECT_NORMAL)
		if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
			src.setStatus("gravity", INFINITE_STATUS, optional=GRAVITY_EFFECT_LOW)
		if (GRAVITY_MOB_HIGH_THRESHOLD to GRAVITY_MOB_EXTREME_THRESHOLD)
			src.setStatus("gravity", INFINITE_STATUS, optional=GRAVITY_EFFECT_HIGH)
		if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
			src.setStatus("gravity", INFINITE_STATUS, optional=GRAVITY_EFFECT_EXTREME)

/mob/living/intangible/update_gravity(new_gravity)
	return

// This is a gross hack where we're combining a few different status effects into one
// It's done to minimize status effect shuffling for something that will collectively change 1000s of times in a round
/datum/statusEffect/gravity
	id = "gravity"
	icon_state = "person"
	unique = TRUE
	movement_modifier = /datum/movement_modifier/gravity
	/// Current gravity state
	var/current_state = GRAVITY_EFFECT_NORMAL

	preCheck(atom/A)
		if (!ismob(A) || !isliving(A))
			return FALSE
		if (isintangible(A))
			return FALSE
		. = ..()

	onAdd(optional)
		. = ..()
		src.update_state(optional)

	onChange(optional)
		. = ..()
		src.update_state(optional)

	proc/update_state(new_state)
		if (new_state == src.current_state)
			return
		src.current_state = new_state

		if (new_state == GRAVITY_EFFECT_NONE)
			src.visible = TRUE
			src.name = "No Gravity"
			src.desc = "You feel floaty.<br>But that's OK."
			src.icon_state = "gravity-no"

			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
			APPLY_ATOM_PROPERTY(src.owner, PROP_ATOM_FLOATING, "gravity")
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
		else
			switch(new_state)
				if(GRAVITY_EFFECT_LOW)
					src.visible = TRUE
					src.name = "Low Gravity"
					src.desc = "You feel a little floaty.<br>Easier to slip, may cause space nausea."
					src.icon_state = "gravity-low"

				if(GRAVITY_EFFECT_NORMAL)
					src.visible = FALSE
					src.name = "Normal Gravity"
					src.desc = "You feel like you're on Earth.<br>No special effects."
					src.icon_state = "person"

				if(GRAVITY_EFFECT_HIGH)
					src.visible = TRUE
					src.name = "High Gravity"
					src.icon_state = "gravity-high"
					src.desc = "You feel heavy.<br>Movement speed reduced."

				if(GRAVITY_EFFECT_EXTREME)
					src.visible = TRUE
					src.name = "Extreme Gravity"
					src.icon_state = "gravity-extreme"
					src.desc = "You feel exteremely heavy.<br>Health issues may occur."

			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
			REMOVE_ATOM_PROPERTY(src.owner, PROP_ATOM_FLOATING, "gravity")
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")


	onUpdate(timePassed)
		. = ..()
		if (HAS_ATOM_PROPERTY(src.owner, PROP_ATOM_GRAVITY_IMMUNE))
			return

		switch(src.current_state)
			if (GRAVITY_EFFECT_NONE)
				;

			if (GRAVITY_EFFECT_LOW)
				if (ishuman(src.owner))
					var/mob/living/carbon/human/H = src.owner
					if (H.traitHolder?.hasTrait("training_miner"))
						return
					// lower the gravity, higher the probability
					if (prob(round((1 - H.last_gravity) * 10)))
						H.nauseate(1)

			if (GRAVITY_EFFECT_NORMAL)
				;

			if (GRAVITY_EFFECT_HIGH)
				;

			if (GRAVITY_EFFECT_EXTREME)
				var/mob/living/M = src.owner
				if (prob(M.last_gravity))
					if (!ON_COOLDOWN(M, "x_grav", 10 SECONDS))
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							switch(rand(1, 3))
								if(1)
									var/obj/item/I = H.equipped()
									if (istype(I))
										boutput(H, SPAN_ALERT("The extreme gravity [pick("yanks", "tears", "pulls")] [I] from your grip!"))
										H.drop_item(I)
									return
								if (2)
									boutput(H, SPAN_ALERT("The extreme gravity [pick("forces", "pulls")] you to the ground!"))
									H.changeStatus("knockdown", 1 SECOND)
									H.force_laydown_standup()
									return
								if (3)
									boutput(H, SPAN_COMBAT("The extreme gravity strains your skeleton!"))
									var/damage = rand(3, 5)
									if (istype(H.mutantrace, /datum/mutantrace/skeleton))
										damage *= 2
									H.TakeDamage("All", damage, damage_type=DAMAGE_CRUSH)
									H.playsound_local(H, 'sound/effects/bones_break.ogg', 40, TRUE)
									return
						else if (issilicon(M))
							var/mob/living/silicon/S = M
							boutput(S, SPAN_COMBAT("The extreme gravity strains your frame!"))
							S.playsound_local(S, "sound/effects/creaking_metal[rand(1,2)].ogg", 40, TRUE)
							S.TakeDamage("Chest", rand(2,5), damage_type=DAMAGE_CRUSH)
						// TODO: Mob critters
					else
						boutput(src.owner, SPAN_NOTICE("Extreme gravity severely impedes your movement!"), "x_grav")
	onRemove()
		. = ..()

		REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
		REMOVE_ATOM_PROPERTY(src.owner, PROP_ATOM_FLOATING, "gravity")
		REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")

/datum/movement_modifier/gravity
	ask_proc = TRUE

/datum/movement_modifier/gravity/modifiers(mob/user, turf/move_target, running)
	// list(additive_slowdown, multiplactive_slowdown)
	return list(0, move_target.effective_gravity > 1 ? move_target.effective_gravity : 1)
