/datum/targetable/brain_slug/sling_spit
	name = "Slinging spit"
	desc = "Create a string of elastic goo between two points."
	icon_state = "slimeshot"
	cooldown = 2 SECONDS
	targeted = 1
	target_anything = 1
	pointCost = 10

	cast(atom/target)
		if (GET_DIST(holder.owner, target) > 5)
			boutput(holder.owner, "<span class='alert'>That is too far away!</span>")
			return TRUE
		var/obj/brain_slug/anchor_setter/setter = new/obj/brain_slug/anchor_setter(holder.owner.loc)
		setter.caster = holder.owner
		setter.set_loc(holder.owner.loc)
		setter.throw_at(target, 6, 1)
		return FALSE
