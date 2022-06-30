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
	reactionlist = list("ethanol")
	reactionmessage = "The microbes appear to be violently... hiccuping?"

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("hiccup")

/datum/microbioeffects/tells/sunglass
	name = "Sunglass Glands"
	desc = "The infected grew sunglass glands."
	reactionlist = list("flashpowder")
	reactionmessage = "The microbes appear to be wearing sunglasses."

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

/datum/microbioeffects/tells/deathgasping
	name = "Deathgasping"
	desc = "The microbes cause the user's brain to believe the body is dying."
	reactionlist = MB_BRAINDAMAGE_REAGENTS
	reactionmessage = "The microbes appear to be.. sort of dead?"

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability/20))
			M:emote("deathgasp")

/datum/microbioeffects/tells/hoarseness
	name = "Hoarseness"
	desc = "The microbes cause dry throat, leading to hoarse speech."
	reactionlist = list("water")
	reactionmessage = "The microbes rapidly absorb the water."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("wheeze")
		else if (prob(origin.probability))
			M:emote("cough")
		else if (prob(origin.probability))
			M:emote("grumble")

/datum/microbioeffects/tells/malaise
	name = "Malaise"
	desc = "The pathogen causes very mild, inconsequential fatigue to its host."
	reactionlist = list("ethanol")
	reactionmessage = "The microbes move slowly toward the solution."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("yawn")
		else if (prob(origin.probability))
			M:emote("cough")
		else if (prob(origin.probability))
			M:emote("stretch")

/datum/microbioeffects/tells/hyperactive
	name = "Psychomotor Agitation"
	desc = "Also known as restlessness, the infected individual is prone to involuntary motions and tics."
	reactionlist = list("sugar")
	reactionmessage = "The microbes move quickly toward the solution."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("gesticulate")
		else if (prob(origin.probability))
			M:emote("blink_r")
		else if (prob(origin.probability))
			M:emote("twitch")

/datum/microbioeffects/tells/startleresponse
	name = "Exaggerated Startle Reflex"
	desc = "The microbes generate synaptic signals that trigger the host's startle reflex."
	reactionlist = list("mannitol")
	reactionmessage = "The microbes start to produce uncoordinated electrical impulses."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("flinch")

/datum/microbioeffects/tells/tearyeyed
	name = "Overactive Eye Glands"
	desc = "The microbes cause the host's lacrimal glands to overproduce tears."
	reactionlist = list("saline")
	reactionmessage = "The microbes seem to disappear into the solution."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("blink")
		else if (prob(origin.probability))
			M:emote("blink_r")
		else if (prob(origin.probability))
			M:emote("cry")

/datum/microbioeffects/tells/restingface
	name = "Grumpy Cat Syndrome"
	desc = "The pathogen causes the host's facial muscles to frown at rest."
	reactionlist = list("THC","sugar")
	reactionmessage = "The microbes start to move in a strangely cheerful manner."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			M:emote("frown")
		else if (prob(origin.probability))
			M:emote("scowl")
		else if (prob(origin.probability))
			M:emote("grimace")

/datum/microbioeffects/tells/farts
	name = "Farts"
	desc = "The infected individual occasionally farts."
	reactionlist = list("saline","oil","sugar","water")	//Look at what chemicals go into laxatives
	reactionmessage = "The microbes appear to produce a large volume of gas. The smell is horrendous."
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

//
// TRANSMISSION-ENABLING EFFECTS
//

/datum/microbioeffects/tells/beesneeze
	name = "Projectile Bee Egg Sneezing"
	desc = "The infected sneezes bee eggs frequently."
	reactionlist = list(,"sugar")	//Look at what chemicals go into laxatives
	reactionmessage = "The microbes appear to convert the sugar into a viscous fluid."

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
		for (var/mob/M in range(1))
			infect_direct(M, origin, MICROBIO_TRANSMISSION_TYPE_AEROBIC)
		//src.infect_cloud(M, origin, origin.spread) // TODO: at some point I want the bees to spread this instead

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability*MICROBIO_EFFECT_PROBABILITY_FACTOR_HORRIFYING))	// Divide by 10, less bee spam!
			sneeze(M, origin)

// Give this to genetics: they already have a ton of accents and other say-modifiers!
/*
/datum/microbioeffects/tells/shakespeare
	name = "Shakespeare"
	desc = "The infected has an urge to begin reciting shakespearean poetry."
	reactionlist = list("sonic_powder")
	reactionmessage = "The microbes appear to be quite dramatic."

	onsay(var/mob/M, message, var/datum/microbesubdata/origin)
		if (!(message in MICROBIO_SHAKESPEARE))
			return shakespearify(message)

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
		if (prob(origin.probability/10)) // 3. holy shit shut up shUT UP
			M.say(pick(MICROBIO_SHAKESPEARE))
*/

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
/*
datum/pathogeneffects/benevolent/oxytocinproduction
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
