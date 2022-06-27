// Anything that is used specifically as a 'tell' for when someone is infected goes here
// A tell is a conspicuous effect that allows the player to quickly determine if they are infected with something.
// Tells must not inherently cause harm to the infected player.
// Tells are permitted to roll probabilities to transmit, within good reason.
ABSTRACT_TYPE(/datum/microbioeffects/tells)
/datum/microbioeffects/tells
	name = "Tells"

/datum/microbioeffects/tells/hiccups
	name = "Hiccups"
	desc = "The microbes send involuntary signals to the infected individual's diaphragm."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("hiccup")

	may_react_to()
		return "The pathogen appears to be violently... hiccuping?"

/*datum/pathogeneffects/benevolent/oxytocinproduction
	name = "Oxytocin Production"
	desc = "The pathogen produces Pure Love within the infected."
	infect_type = INFECT_TOUCH
	rarity = THREAT_BENETYPE2
	spread = SPREAD_BODY | SPREAD_HANDS
	infect_message = "<span style=\"color:pink\">You can't help but feel loved.</span>"
	infect_attempt_message = "Their touch is suspiciously soft..."

	onemote(mob/M as mob, act, voluntary, param, datum/pathogen/origin)
		if (origin.in_remission)
			return
		if (act != "hug" && act != "sidehug")  // not a hug
			return
		if (param == null) // weirdo is just hugging themselves
			return
		for (var/mob/living/carbon/human/H in view(1, M))
			if (ckey(param) == ckey(H.name) && prob(origin.spread*2))
				SPAWN(0.5)
					infect_direct(H, origin, "hug")
				return

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		var/check_amount = M.reagents.get_reagent_amount("love")
		if (!check_amount || check_amount < 5)
			M.reagents.add_reagent("love", origin.stage / 3)

	may_react_to()
		return "The pathogen's cells appear to be... hugging each other?"
*/

/datum/microbioeffects/tells/sunglass
	name = "Sunglass Glands"
	desc = "The infected grew sunglass glands."

	proc/glasses(var/mob/living/carbon/human/M)
		var/obj/item/clothing/glasses/G = M.glasses
		var/obj/item/clothing/glasses/N = new/obj/item/clothing/glasses/sunglasses()
		M.show_message({"<span class='notice'>[pick("You feel cooler!", "You find yourself wearing sunglasses.", "A pair of sunglasses grow onto your face.")][G?" But you were already wearing glasses!":""]</span>"})
		if (G)
			N.set_loc(M.loc)
			var/turf/T = get_edge_target_turf(M, pick(alldirs))
			N.throw_at(T,rand(0,5),1)
		else
			N.set_loc(M)
			N.layer = M.layer
			N.master = M
			M.glasses = N
			M.update_clothing()

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (!ishuman(M))
			return

		var/mob/living/carbon/human/H = M
		if ((!(H.glasses) && prob (origin.probability)) || (!(istype(H.glasses, /obj/item/clothing/glasses/sunglasses)) && prob(origin.probability/2)))
			glasses(M)

	may_react_to()
		return "The pathogen appears to be sensitive to sudden flashes of light."

	react_to(var/R, var/zoom)
		if (R == "flashpowder")
			if (zoom)
				return "The individual microbodies appear to be wearing sunglasses."
			else
				return "The pathogen appears to have developed a resistance to the flash powder."

/datum/microbioeffects/tells/deathgasping
	name = "Deathgasping"
	desc = "The pathogen causes the user's brain to believe the body is dying."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability/20))
			M:emote("deathgasp")

	may_react_to()
		return "The pathogen appears to be.. sort of dead?"

/datum/microbioeffects/tells/shakespeare
	name = "Shakespeare"
	desc = "The infected has an urge to begin reciting shakespearean poetry."

	onsay(var/mob/M, message, var/datum/microbesubdata/origin)
		if (!(message in MICROBIO_SHAKESPEARE))
			return shakespearify(message)

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability/10)) // 3. holy shit shut up shUT UP
			M.say(pick(MICROBIO_SHAKESPEARE))

	may_react_to()
		return "The culture appears to be quite dramatic."


/datum/microbioeffects/tells/hoarseness
	name = "Hoarseness"
	desc = "The pathogen causes dry throat, leading to hoarse speech."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("wheeze")
		else if (prob(origin.probability))
			M:emote("cough")
		else if (prob(origin.probability))
			M:emote("grumble")

	may_react_to()
		return "The pathogen appears to be rapidly breaking down certain materials around it."

/datum/microbioeffects/tells/malaise
	name = "Malaise"
	desc = "The pathogen causes very mild, inconsequential fatigue to its host."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("yawn")
		else if (prob(origin.probability))
			M:emote("cough")
		else if (prob(origin.probability))
			M:emote("stretch")

	may_react_to()
		return "The pathogen appears to have a gland that may affect neural functions."

/datum/microbioeffects/tells/hyperactive
	name = "Psychomotor Agitation"
	desc = "Also known as restlessness, the infected individual is prone to involuntary motions and tics."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("gesticulate")
		else if (prob(origin.probability))
			M:emote("blink_r")
		else if (prob(origin.probability))
			M:emote("twitch")

	may_react_to()
		return "The pathogen appears to be wilder than usual, perhaps sedatives or psychoactive substances might affect its behaviour."

/datum/microbioeffects/tells/startleresponse
	name = "Exagerrated Startle Reflex"
	desc = "The pathogen generates synaptic signals that amplify the host's startle reflex."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("flinch")

	may_react_to()
		return "The pathogen appears to have a gland that may affect neural functions."

/datum/microbioeffects/tells/tearyeyed
	name = "Overactive Eye Glands"
	desc = "The pathogen causes the host's lacrimal glands to overproduce tears."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("blink")
		else if (prob(origin.probability))
			M:emote("blink_r")
		else if (prob(origin.probability))
			M:emote("cry")

	may_react_to()
		return "The pathogen appears to generate a high amount of fluids."

/datum/microbioeffects/tells/restingface
	name = "Grumpy Cat Syndrome"
	desc = "The pathogen causes the host's facial muscles to frown at rest."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("frown")
		else if (prob(origin.probability))
			M:emote("scowl")
		else if (prob(origin.probability))
			M:emote("grimace")

	may_react_to()
		return "The pathogen appears to react to hydrating agents."

/datum/microbioeffects/tells/farts
	name = "Farts"
	desc = "The infected individual occasionally farts."
	/*
	var/cooldown = 200 // we just use the name of the symptom to keep track of different fart effects, so their cooldowns do not interfere
	var/doInfect = 1 // smoke farts were just too good

	proc/fart(var/mob/M, var/datum/microbe/origin, var/voluntary)
		//if(doInfect)
			//src.infect_cloud(M, origin, origin.spread/5)
		if(voluntary)
			origin.effectdata[name] = TIME

	onemote(var/mob/M, act, voluntary, param, var/datum/microbe/P)
		// involuntary farts are free, but the others use the cooldown
		if(voluntary && TIME-P.master.effectdata[name] < cooldown)
			return
		if(act == "fart")
			fart(M, P, voluntary)
	*/
	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M.emote("fart")

	may_react_to()
		return "The pathogen appears to produce a large volume of gas."

/datum/microbioeffects/tells/beesneeze
	name = "Projectile Bee Egg Sneezing"
	desc = "The infected sneezes bee eggs frequently."

	proc/sneeze(var/mob/M, var/datum/microbesubdata/origin)
		if (!M || !origin)
			return
		var/turf/T = get_turf(M)
		var/flyroll = rand(10)
		var/turf/target = locate(M.x,M.y,M.z)
		var/chosen_phrase = pick("<B><span class='alert'>W</span><span class='notice'>H</span>A<span class='alert'>T</span><span class='notice'>.</span></B>","<span class='alert'><B>What the [pick("hell","fuck","christ","shit")]?!</B></span>","<span class='alert'><B>Uhhhh. Uhhhhhhhhhhhhhhhhhhhh.</B></span>","<span class='alert'><B>Oh [pick("no","dear","god","dear god","sweet merciful [pick("neptune","poseidon")]")]!</B></span>")
		switch (M.dir)
			if (NORTH)
				target = locate(M.x, M.y+flyroll, M.z)
			if (SOUTH)
				target = locate(M.x, M.y-flyroll, M.z)
			if (EAST)
				target = locate(M.x+flyroll, M.y, M.z)
			if (WEST)
				target = locate(M.x-flyroll, M.y, M.z)
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/toThrow = new /obj/item/reagent_containers/food/snacks/ingredient/egg/bee(T)
		M.visible_message("<span class='alert'>[M] sneezes out a space bee egg!</span> [chosen_phrase]", "<span class='alert'>You sneeze out a bee egg!</span> [chosen_phrase]", "<span class='alert'>You hear someone sneezing.</span>")
		toThrow.throw_at(target, 6, 1)
		//src.infect_cloud(M, origin, origin.spread) // TODO: at some point I want the bees to spread this instead

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability/10))
			sneeze(M, origin)

	may_react_to()
		return "The pathogen appears to generate a high amount of fluids. Honey, to be more specific."

	react_to(var/R, var/zoom)
		if (R == "pepper")
			return "The pathogen violently discharges honey when coming in contact with pepper."

/*
datum/microbioeffects/tells/bloodcolors
	name = "Blood Pigmenting"
	desc = "The pathogen attaches to the kidneys and adds a harmless pigment to the host's blood cells, causing their blood to have an unusual color."

	//var/bloodcolor =

	//randomly select blood color

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		//if bleeding
			//change blood color to bloodcolor

	may_react_to()
		return "The pathogen appears to generate a high amount of fluids."
*/
