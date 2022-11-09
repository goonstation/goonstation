/datum/targetable/brain_slug/slug_molt
	name = "Molt"
	desc = "Shed your old skin to cancel stuns and cover yourself in projectile-reflecting mucus for awhile."
	icon_state = "molt_icon"
	cooldown = 60 SECONDS
	targeted = 0
	var/duration = 5 SECONDS

	cast()
		if (!istype(holder.owner, /mob/living/critter/adult_brain_slug))
			boutput("<span class='notice'>You have to be a brain slug to do that!</span>")
			return TRUE
		make_cleanable(/obj/decal/cleanable/slug_molt, holder.owner.loc)
		var/mob/living/critter/adult_brain_slug/the_slug = holder.owner
		the_slug.visible_message("<span class='alert'>[the_slug] sheds it's skin and covers itself in sticky mucus!</span>", "<span class='notice'>You shed your skin and feel instantly refreshed!</span>")
		the_slug.add_filter("molted", 1, color_matrix_filter(normalize_color_to_matrix("#20b351")))
		the_slug.bullet_reflect = TRUE
		the_slug.delStatus("stunned")
		the_slug.delStatus("weakened")
		the_slug.delStatus("paralysis")
		the_slug.delStatus("slowed")
		the_slug.delStatus("disorient")
		the_slug.change_misstep_chance(-INFINITY)
		the_slug.stuttering = 0
		the_slug.delStatus("drowsy")
		if (the_slug.get_stamina() < 0)
			the_slug.set_stamina(50)
		the_slug.delStatus("resting")
		playsound(the_slug.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 70, 1, 0.9, 1.3)
		SPAWN (src.duration)
			the_slug?.bullet_reflect = FALSE
			the_slug?.remove_filter("molted")
		return FALSE
