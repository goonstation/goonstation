/datum/targetable/brain_slug/acid_slither
	name = "Acidic sweat"
	desc = "Lay a trail of acid as you move."
	icon_state = "slither"
	cooldown = 40 SECONDS
	targeted = 0
	cast()
		playsound(holder.owner.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 30, 1, 1, 1.2)
		holder.owner.AddComponent(/datum/component/acid_slime)
		var/datum/component/C = holder.owner.GetComponent(/datum/component/acid_slime)
		holder.owner.visible_message("<span class='alert'>[holder.owner] begins leaving a trail of slippery slime behind itself!</span>", "<span class='notice'>You expel some slime out of your body.</span>")
		spawn(5 SECONDS)
			C?.RemoveComponent(/datum/component/acid_slime)
