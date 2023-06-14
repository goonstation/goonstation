// ----------------------------------
// writhe around
// ----------------------------------
/datum/targetable/critter/writhe
	name = "Writhe"
	desc = "Writhe on the floor to damage and stun any nearby targets."
	cooldown = 600
	start_on_cooldown = 0
	icon_state = "writhe"

	cast(atom/target)
		if (..())
			return 1
		var/mob/ow = holder.owner

		ow.visible_message(text("<span class='alert'><B>[ow.name] spasms and writhes violently!</B></span>"))
		ow.emote("flip")

		var/found_target = 0
		for(var/i=1, i<5, i++)
			found_target = 0


			for (var/mob/living/M in view(1,ow.loc))
				if (M != ow && prob(80))
					found_target = 1

					random_brute_damage(M, 2,1)
					M.changeStatus("weakened", 1 SECONDS)
					M.force_laydown_standup()
					playsound(ow.loc, "swing_hit", 60, 1)
					ow.visible_message("<span class='alert'><B>[ow.name] kicks [M]!</B></span>")

			if (!found_target)
				playsound(ow.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 30, 1)

			ow.set_dir(turn(ow.dir, pick(-90,90)))

			sleep(0.5 SECONDS)

		ow.changeStatus("weakened", 3 SECONDS)
		ow.force_laydown_standup()
