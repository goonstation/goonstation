/datum/targetable/brain_slug/slither
	name = "Slither away"
	desc = "Expel some mucus from your body to trip threats."
	icon_state = "slither"
	cooldown = 30 SECONDS
	targeted = 0
	cast()
		playsound(holder.owner.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 30, 1, 1, 1.2)
		holder.owner.AddComponent(/datum/component/floor_slime, "superlube", 50, 75)
		var/datum/component/C = holder.owner.GetComponent(/datum/component/floor_slime)
		holder.owner.visible_message("<span class='alert'>[holder.owner] begins leaving a trail of slippery slime behind itself!</span>", "<span class='notice'>You expel some slime out of your body.</span>")
		spawn(7 SECONDS)
			C?.RemoveComponent(/datum/component/floor_slime)
