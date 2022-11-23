/datum/targetable/brain_slug/take_control
	name = "Assume control"
	desc = "Take full control of the being you infested along with healing any superficial damage they may have."
	icon_state = "take_control"
	cooldown = 10 SECONDS
	targeted = 0

	cast()
		var/mob/M = holder.owner
		if (!istype(M, /mob/living/critter/brain_slug))
			boutput(M, "<span class='notice'>You arent enough of a slug to do that.</span>")
			return TRUE
		var/mob/living/critter/brain_slug/the_slug = M
		if (istype(the_slug.loc,/mob/))	//Check you're in a mob and not like, a locker or something. Though a brain possessed locker would be kinda funny.
			var/mob/the_mob = the_slug.loc
			//Begin the sluggening
			hit_twitch(the_mob)
			boutput(M, "<span class='notice'>You begin to take over [the_mob].</span>")
			spawn(3 SECONDS)
				if (!the_mob || !the_slug) return
				if (the_slug.loc != the_mob) return
				hit_twitch(the_mob)
				spawn(2 SECONDS)
					if (!the_mob || !the_slug) return
					if (the_slug.loc != the_mob) return
					make_cleanable(/obj/decal/cleanable/slime, the_mob.loc)
					the_mob.HealDamage("All", INFINITY, INFINITY, INFINITY)
					the_mob.take_oxygen_deprivation(-INFINITY)
					the_slug.mind?.transfer_to(the_mob)
					setalive(the_mob)
			return FALSE
		else
			boutput(M, "<span class='notice'>You arent inside something you can possess.</span>")
			return TRUE
