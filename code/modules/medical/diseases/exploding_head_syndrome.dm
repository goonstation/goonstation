/datum/ailment/disease/exploding_head_syndrome
	name = "Exploding Head Syndrome"
	max_stages = 5
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Synaptizine"
	reagentcure = list("synaptizine")
	recureprob = 10
	associated_reagent = "explodingheadjuice"
	affected_species = list("Human","Monkey")



/datum/ailment/disease/exploding_head_syndrome/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	switch(D.stage)
		if(2)
			if(probmult(3))
				affected_mob.playsound_local(affected_mob.loc, 'sound/effects/explosionfar.ogg', 35, 1)
		if(3)
			if(probmult(7))
				affected_mob.playsound_local(affected_mob.loc, pick('sound/effects/exlow.ogg', 'sound/weapons/Gunshot.ogg', 'sound/effects/explosionfar.ogg'), 35, 1)
				if(probmult(45))
					affected_mob.emote("flinch")
		if(4)
			if(probmult(10))
				affected_mob.playsound_local(affected_mob.loc, pick('sound/weapons/Gunshot.ogg', 'sound/effects/Explosion1.ogg', 'sound/effects/explosion_new3.ogg', 'sound/effects/Explosion2.ogg', 'sound/effects/ExplosionFirey.ogg'), 40, 1)
				if(probmult(45))
					affected_mob.emote("scream")
				else if(probmult(75))
					affected_mob.emote("flinch")
			if(probmult(10))
				boutput(affected_mob, SPAN_ALERT("You see a flash of light in the corner of your vision"))
				affected_mob.take_brain_damage(1)

		if(5)
			if(probmult(20))
				affected_mob.playsound_local(affected_mob.loc, pick('sound/effects/Explosion1.ogg', 'sound/effects/explosion_new3.ogg', 'sound/effects/Explosion2.ogg', 'sound/effects/ExplosionFirey.ogg'), 45, 1)
				if(probmult(75))
					affected_mob.emote("scream")
				else
					affected_mob.emote("flinch")
			if(probmult(15))
				boutput(affected_mob, SPAN_ALERT("You see a flash of light in the corner of your vision"))
				affected_mob.take_brain_damage(3)
			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("<B>You feel a strange tingle moving towards your head</B>"))
				SPAWN(rand(20, 100))
					if (affected_mob)
						var/mob/living/carbon/human/H = affected_mob
						explosion(affected_mob, get_turf(affected_mob), -1,-1,0,1)
						H.head_explosion()
						logTheThing(LOG_COMBAT, affected_mob, "had their head exploded by the disease [name] at [log_loc(affected_mob)].")
