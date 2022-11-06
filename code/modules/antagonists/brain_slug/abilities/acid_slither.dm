/datum/targetable/brain_slug/acid_slither
	name = "Acidic sweat"
	desc = "Lay a trail of acid as you move."
	icon_state = "slither"
	cooldown = 40 SECONDS
	targeted = 0
	cast()
		if (!isturf(holder.owner.loc))
			boutput(holder.owner, "<span class='notice'>You cannot use that here!</span>")
			return TRUE
		playsound(holder.owner.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 30, 1, 1, 1.2)
		holder.owner.AddComponent(/datum/component/acid_slime)
		var/datum/component/C = holder.owner.GetComponent(/datum/component/acid_slime)
		holder.owner.visible_message("<span class='alert'><b>[holder.owner] begins leaving a trail of acidic slime behind itself!</b></span>", "<span class='notice'>You expel some slime out of your body.</span>")
		spawn(5 SECONDS)
			C?.RemoveComponent(/datum/component/acid_slime)
		return FALSE
