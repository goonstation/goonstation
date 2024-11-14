// -----------------
// Throw stomp
// -----------------
/datum/targetable/critter/powerstomp
	name = "Power Stomp"
	desc = "A powerful stomp, sends people flying away from you."
	cooldown = 150
	targeted = 0
	target_anything = 1
	icon_state = "power_kick"

	cast()
		if (..())
			return 1

		var/mob/ow = holder.owner

		animate_stomp(holder.owner)

		SPAWN(1)
			playsound(ow.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			var/list/range1 = orange(1, holder.owner.loc)
			animate_stomp1(holder.owner.loc)
			for(var/mob/M in holder.owner.loc)
				if (M == holder.owner)
					continue
				M.changeStatus("knockdown", 5 SECONDS)

			SPAWN(1)
				for(var/turf/T in range1)
					if (T == holder.owner.loc)
						continue
					animate_stomp1(T)
					for(var/atom/movable/A in T)
						A.throw_at(get_edge_cheap(A, get_dir(holder.owner, A)), 30, 1)

	proc/animate_stomp1(var/atom/A)
		if (!istype(A))
			return
		var/punchstr = rand(10, 20)
		var/original_y = A.pixel_y
		animate(A, transform = matrix(punchstr, MATRIX_ROTATE), pixel_y = 2, time = 2, color = "#eeeeee", easing = BOUNCE_EASING)
		animate(transform = matrix(-punchstr, MATRIX_ROTATE), pixel_y = original_y, time = 2, color = "#ffffff", easing = BOUNCE_EASING)
		animate(transform = null, time = 3, easing = BOUNCE_EASING)
		return


