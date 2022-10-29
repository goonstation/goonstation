/*
CONTAINS:
WIRE
TILES

*/

// TILES

/obj/item/tile
	name = "steel floor tile"
	desc = "They keep the floor in a good and walkable condition."
	icon = 'icons/obj/metal.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "tile"
	health = 2
	w_class = W_CLASS_NORMAL
	m_amt = 937.5
	throw_speed = 5
	throw_range = 20
	force = 6
	throwforce = 7
	max_stack = 80
	stamina_damage = 25
	stamina_cost = 25
	stamina_crit_chance = 15

	New()

		src.pixel_x = rand(1, 14)
		src.pixel_y = rand(1, 14)
		return

	examine()
		. = ..()
		. += "There are [src.amount] tile\s left on the stack."

	attack_hand(mob/user)

		if ((user.r_hand == src || user.l_hand == src))
			src.add_fingerprint(user)
			var/obj/item/tile/F = new /obj/item/tile( user )
			F.amount = 1
			src.amount--
			user.put_in_hand_or_drop(F)
			if (src.amount < 1)
				qdel(src)
				return
		else
			..()
		return

	attack_self(mob/user as mob)

		if (user.stat)
			return
		var/T = user.loc
		if (!( istype(T, /turf) ))
			boutput(user, "<span class='notice'>You must be on the ground!</span>")
			return
		else
			var/S = T
			if (!( istype(S, /turf/space) ))
				boutput(user, "You cannot build on or repair this turf!")
				return
			else
				src.build(S)
				src.amount--
		if (src.amount < 1)
			user.u_equip(src)
			qdel(src)
			return
		src.add_fingerprint(user)
		return

	attackby(obj/item/tile/W, mob/user)

		if (!( istype(W, /obj/item/tile) ))
			return
		if (W.amount == src.max_stack)
			return
		W.add_fingerprint(user)
		if (W.amount + src.amount > src.max_stack)
			src.amount = W.amount + src.amount - src.max_stack
			W.amount = src.max_stack
		else
			W.amount += src.amount
			qdel(src)
			return
		return

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins stacking floor tiles!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish stacking tiles.</span>")

	proc/build(turf/S as turf)
		var/turf/simulated/floor/W = S.ReplaceWithFloor()
		if (!W.icon_old)
			W.icon_old = "floor"
		W.to_plating()
		return
