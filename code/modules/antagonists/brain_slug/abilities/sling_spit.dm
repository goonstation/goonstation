/datum/targetable/brain_slug/sling_spit
	name = "Elastic tether"
	desc = "Create a string of elastic goo between two points."
	icon_state = "slinging_slime"
	cooldown = 45 SECONDS
	targeted = 1
	target_anything = 1
	pointCost = 30

	cast(atom/target)
		if (!isturf(holder.owner.loc))
			boutput(holder.owner, "<span class='notice'>You cannot use that here!</span>")
			return TRUE
		if (GET_DIST(holder.owner, target) > 5)
			boutput(holder.owner, "<span class='alert'>That is too far away!</span>")
			return TRUE
		var/obj/brain_slug/anchor_setter/setter = new/obj/brain_slug/anchor_setter(holder.owner.loc)
		playsound(holder.owner.loc, 'sound/impact_sounds/Glub_1.ogg', 80, 1, 1, 1.2)
		setter.caster = holder.owner
		setter.set_loc(holder.owner.loc)
		setter.throw_at(target, 6, 1)
		return FALSE
