/datum/targetable/critter/drop_disguise
	name = "Drop Disguise"
	desc = "Shed your skin and return to your base form."
	icon_state = "mimic_drop_disguise"
	cooldown = 10 SECONDS
	targeted = 0

	cast()
		if (..())
			return TRUE
		var/mob/living/critter/mimic/user = holder.owner
		if (user.base_form)
			boutput(holder.owner, SPAN_ALERT("You're in your base form already!"))
			return TRUE
		src.drop(user)
		boutput(holder.owner, SPAN_ALERT("You shed your skin!"))
		return FALSE

	proc/drop(mob/user)
		var/mob/living/critter/mimic/parent = user
		parent.disguise_as(src, TRUE)
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(parent.loc)
		parent.setStatus("mimic_disguise", INFINITE_STATUS, parent.pixel_amount)
