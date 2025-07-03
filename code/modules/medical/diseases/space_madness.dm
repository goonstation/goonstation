/datum/ailment/disease/space_madness
	name = "Space Madness"
	scantype = "Psychological Condition"
	max_stages = 5
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Haloperidol"
	reagentcure = list("haloperidol")
	associated_reagent = "loose_screws"
	affected_species = list("Human")

/datum/ailment/disease/space_madness/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if(affected_mob.job == "Clown")
		if(probmult(6))
			var/icp = pick("Fuckin' magnets!", "Fuckin' rainbows!", "Magic everywhere...", "Pure motherfuckin' miracles!", "Magic all around you and you don't even know it!")
			affected_mob.say("[icp]")
			return
	switch(D.stage)
		if(2)
			if (probmult(10))
				boutput(affected_mob, pick(SPAN_ALERT("<i><b><font face =Tempus Sans ITC>Kill them all!!!!!</b></i></FONT>"), SPAN_ALERT("<i><b><font face = Tempus Sans ITC>They are out to get you!</b></FONT></i>"), SPAN_ALERT("<i><b><font face = Tempus Sans ITC>They know what you did!!!!</b></FONT></i>"), SPAN_ALERT("<i><b><font face = Tempus Sans ITC>They are watching you!!!</b></i></FONT>")))
		if(3)
			if (probmult(8))
				for (var/mob/living/M in view(7,affected_mob))
					if(M!= affected_mob)
						boutput(affected_mob, "<b>[M.name]</b> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "TRAITOR!")]\"")
						break
			if (probmult(9))
				boutput(affected_mob, pick(SPAN_ALERT("<i><b><font face =Tempus Sans ITC>Kill them all!!!!!</b></i></FONT>"), SPAN_ALERT("<i><b><font face = Tempus Sans ITC>They are out to get you!</b></FONT></i>"), SPAN_ALERT("<i><b><font face = Tempus Sans ITC>They know what you did!!!!</b></FONT></i>"), SPAN_ALERT("<i><b><font face = Tempus Sans ITC>They are watching you!!!</b></i></FONT>")))

		if(4)
			if(probmult(5))
				switch(rand(1,2))
					if(1)
						if(prob(50))
							fake_attack(affected_mob)
						else
							var/monkeys = rand(1,3)
							for(var/i = 0, i < monkeys, i++)
								fake_attackEx(affected_mob, 'icons/mob/monkey.dmi', "monkey_hallucination", pick_string_autokey("names/monkey.txt"))
					if(2)
						var/halluc_state = null
						var/halluc_name = null
						switch(rand(1,5))
							if(1)
								halluc_state = "pig"
								halluc_name = pick("pig", "DAT FUKKEN PIG")
							if(2)
								halluc_state = "spider"
								halluc_name = pick("giant black widow", "aw look a spider", "OH FUCK A SPIDER")
							if(3)
								halluc_state = "dragon"
								halluc_name = pick("dragon", "Lord Cinderbottom", "SOME FUKKEN LIZARD THAT BREATHES FIRE")
							if(4)
								halluc_state = "slime"
								halluc_name = pick("red slime", "some gooey thing", "ANGRY CRIMSON POO")
							if(5)
								halluc_state = "shambler"
								halluc_name = pick("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
						fake_attackEx(affected_mob, 'icons/effects/hallucinations.dmi', halluc_state, halluc_name)
			if(probmult(9))
				affected_mob.playsound_local(affected_mob.loc, pick("explosion", "punch", 'sound/vox/poo-vox.ogg', "clownstep", 'sound/weapons/armbomb.ogg', 'sound/weapons/Gunshot.ogg'), 50, 1)

			if (probmult(8))
				for (var/mob/living/M in view(7,affected_mob))
					if(M!= affected_mob)
						boutput(affected_mob, "<b>[M.name]</b> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "You are a loser!")]\"")
						break

		if(5)
			if(probmult(5))
				switch(rand(1,2))
					if(1)
						if(prob(50))
							fake_attack(affected_mob)
						else
							var/monkeys = rand(1,3)
							for(var/i = 0, i < monkeys, i++)
								fake_attackEx(affected_mob, 'icons/mob/monkey.dmi', "monkey_hallucination", pick_string_autokey("names/monkey.txt"))
					if(2)
						var/halluc_state = null
						var/halluc_name = null
						switch(rand(1,5))
							if(1)
								halluc_state = "pig"
								halluc_name = pick("pig", "DAT FUKKEN PIG")
							if(2)
								halluc_state = "spider"
								halluc_name = pick("giant black widow", "aw look a spider", "OH FUCK A SPIDER")
							if(3)
								halluc_state = "dragon"
								halluc_name = pick("dragon", "Lord Cinderbottom", "SOME FUKKEN LIZARD THAT BREATHES FIRE")
							if(4)
								halluc_state = "slime"
								halluc_name = pick("red slime", "some gooey thing", "ANGRY CRIMSON POO")
							if(5)
								halluc_state = "shambler"
								halluc_name = pick("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
						fake_attackEx(affected_mob, 'icons/effects/hallucinations.dmi', halluc_state, halluc_name)
			if(probmult(9))
				affected_mob.playsound_local(affected_mob.loc, pick("explosion", "punch", 'sound/vox/poo-vox.ogg', "clownstep", 'sound/weapons/armbomb.ogg', 'sound/weapons/Gunshot.ogg'), 50, 1)

			if (probmult(8))
				for (var/mob/living/M in view(7,affected_mob))
					if(M!= affected_mob)
						boutput(affected_mob, "<b>[M.name]</b> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "You are a loser!")]\"")
						break

/datum/ailment/disease/space_madness/on_remove(var/mob/living/affected_mob, var/datum/ailment_data/D)
	if (affected_mob?.client)
		affected_mob.client.dir = NORTH // Reset their view of the map. Yes, this was missing for many years (Convair880).
	..()
	return
