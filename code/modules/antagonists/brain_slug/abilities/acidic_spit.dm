/datum/targetable/brain_slug/acidic_spit
	name = "Acidic Spit"
	desc = "Spew a stream of acidic spit at the ground, melting whoever stands in it."
	icon_state = "acid"
	cooldown = 80 SECONDS
	targeted = 1
	target_anything = 1
	pointCost = 50

	cast(atom/target)
		if (!isturf(holder.owner.loc))
			boutput(holder.owner, "<span class='notice'>You cannot use that here!</span>")
			return TRUE
		if (GET_DIST(holder.owner, target) > 5)
			boutput(holder.owner, "<span class='alert'>That is too far away!</span>")
			return TRUE
		var/obj/brain_slug/acidic_goo_ball = new /obj/brain_slug/acidic_goo_ball()
		playsound(holder.owner.loc, 'sound/impact_sounds/Glub_1.ogg', 70, 1, 0.7, 1.2)
		acidic_goo_ball.set_loc(holder.owner.loc)
		acidic_goo_ball.throw_at(target, 6, 1)
		holder.owner.visible_message("<span class='alert'>[holder.owner] spits out a glob of skin-melting acid at [target]!</span>")
		return FALSE
