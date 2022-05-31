// Anything that is used specifically as a 'tell' for when someone is infected goes here
// A tell is a conspicuous effect that allows the player to quickly determine if they are infected with something.
// Tells must not inherently cause harm to the infected player.
// Tells are permitted to roll probabilities to transmit, within good reason.
ABSTRACT_TYPE(/datum/microbioeffects/tells)
datum/microbioeffects/tells
	name = "Tells"

datum/microbioeffects/tells/hiccups
	name = "Hiccups"
	desc = "The microbes send involuntary signals to the infected individual's diaphragm."

	onadd(var/datum/microbe/origin)
		origin.effectdata += "hiccups"

	mob_act(var/mob/M as mob, var/datum/microbe/origin)
		if (prob(2))
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

datum/pathogeneffects/neutral/sunglass
	name = "Sunglass Glands"
	desc = "The infected grew sunglass glands."

	onadd(var/datum/microbe/origin)
		origin.effectdata += "sunglass"

	proc/glasses(var/mob/living/carbon/human/M as mob)
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

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!ishuman(M))
			return

		var/mob/living/carbon/human/H = M
		if ((!(H.glasses) &&prob (2)) || (!(istype(H.glasses, /obj/item/clothing/glasses/sunglasses)) && prob(1)))
			glasses(M)

	may_react_to()
		return "The pathogen appears to be sensitive to sudden flashes of light."

	react_to(var/R, var/zoom)
		if (R == "flashpowder")
			if (zoom)
				return "The individual microbodies appear to be wearing sunglasses."
			else
				return "The pathogen appears to have developed a resistance to the flash powder."

datum/pathogeneffects/neutral/deathgasping
	name = "Deathgasping"
	desc = "The pathogen causes the user's brain to believe the body is dying."
	onadd(var/datum/microbe/origin)
		origin.effectdata += "deathgasp"

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (prob(1))
			M:emote("deathgasp")

	may_react_to()
		return "The pathogen appears to be.. sort of dead?"

datum/pathogeneffects/neutral/shakespeare
	name = "Shakespeare"
	desc = "The infected has an urge to begin reciting shakespearean poetry."

	onadd(var/datum/microbe/origin)
		origin.effectdata += "shakespeare"

	var/static/list/shk = list("Expectation is the root of all heartache.",
"A fool thinks himself to be wise, but a wise man knows himself to be a fool.",
"Love all, trust a few, do wrong to none.",
"Hell is empty and all the devils are here.",
"Better a witty fool than a foolish wit.",
"The course of true love never did run smooth.",
"Come, gentlemen, I hope we shall drink down all unkindness.",
"Suspicion always haunts the guilty mind.",
"No legacy is so rich as honesty.",
"Alas, I am a woman friendless, hopeless!",
"The empty vessel makes the loudest sound.",
"Words without thoughts never to heaven go.",
"This above all; to thine own self be true.",
"An overflow of good converts to bad.",
"It is a wise father that knows his own child.",
"Listen to many, speak to a few.",
"Boldness be my friend.",
"Speak low, if you speak love.",
"Give thy thoughts no tongue.",
"The devil can cite Scripture for his purpose.",
"In time we hate that which we often fear.",
"The lady doth protest too much, methinks.")

	onsay(var/mob/M as mob, message, var/datum/pathogen/origin)
		if (!(message in shk))
			return shakespearify(message)

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (prob(0.5)) // 3. holy shit shut up shUT UP
			M.say(pick(shk))

	may_react_to()
		return "The culture appears to be quite dramatic."


datum/microbioeffects/tells/hoarseness
	name = "Hoarseness"
	desc = "The pathogen causes dry throat, leading to hoarse speech."

	onadd(var/datum/microbe/origin)
		origin.effectdata += "Hoarseness"

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (prob(2))
			M:emote("wheeze")
		else if (prob(2))
			M:emote("cough")
		else if (prob(2))
			M:emote("grumble")

	may_react_to()
		return "The pathogen appears to be rapidly breaking down certain materials around it."

datum/microbioeffects/tells/malaise
	name = "Malaise"
	desc = "The pathogen causes very mild, inconsequential fatigue to its host."

	onadd(var/datum/microbe/origin)
		origin.effectdata += "malaise"

	mob_act(var/mob/M as mob, var/datum/microbe/origin)
		if (prob(2))
			M:emote("yawn")
		else if (prob(3))
			M:emote("cough")
		else if (prob(4))
			M:emote("stretch")

	may_react_to()
		return "The pathogen appears to have a gland that may affect neural functions."

datum/microbioeffects/tells/hyperactive
	name = "Psychomotor Agitation"
	desc = "Also known as restlessness, the infected individual is prone to involuntary motions and tics."

	mob_act(var/mob/M as mob, var/datum/microbe/origin)
		if (prob(2))
			M:emote("gesticulate")
		else if (prob(2))
			M:emote("blink_r")
		else if (prob(2))
			M:emote("twitch")

	may_react_to()
		return "The pathogen appears to be wilder than usual, perhaps sedatives or psychoactive substances might affect its behaviour."
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
datum/microbioeffects/tells/startleresponse
	name = "Exagerrated Startle Reflex"
	desc = "The pathogen generates synaptic signals that amplify the host's startle reflex."

	onadd(var/datum/microbe/origin)
		origin.effectdata += "Startled"

	mob_act(var/mob/M as mob, var/datum/microbe/origin)
		if (prob(2))
			M:emote("flinch")

	may_react_to()
		return "The pathogen appears to have a gland that may affect neural functions."

datum/microbioeffects/tells/tearyeyed
	name = "Overactive Eye Glands"
	desc = "The pathogen causes the host's lacrimal glands to overproduce tears."

	onadd(var/datum/microbe/origin)
		origin.effectdata += "Teary"

	mob_act(var/mob/M as mob, var/datum/microbe/origin)
		if (prob(2))
			M:emote("blink")
		else if (prob(2))
			M:emote("blink_r")
		else if (prob(2))
			M:emote("cry")

	may_react_to()
		return "The pathogen appears to generate a high amount of fluids."

datum/microbioeffects/tells/restingface
	name = "Grumpy Cat Syndrome"
	desc = "The pathogen causes the host's facial muscles to frown at rest."

	onadd(var/datum/microbe/origin)
		origin.effectdata += "Frowny"

	mob_act(var/mob/M as mob, var/datum/microbe/origin)
		if (prob(2))
			M:emote("frown")
		else if (prob(2))
			M:emote("scowl")
		else if (prob(2))
			M:emote("grimace")

	may_react_to()
		return "The pathogen appears to react to hydrating agents."
/*
datum/microbioeffects/tells/farts
	name = "Farts"
	desc = "The infected individual occasionally farts."

	var/cooldown = 200 // we just use the name of the symptom to keep track of different fart effects, so their cooldowns do not interfere
	var/doInfect = 1 // smoke farts were just too good

	proc/fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		if(doInfect)
			src.infect_cloud(M, origin, origin.spread/5)
		if(voluntary)
			origin.effectdata[name] = TIME

	onemote(mob/M as mob, act, voluntary, param, datum/pathogen/P)
		// involuntary farts are free, but the others use the cooldown
		if(voluntary && TIME-P.effectdata[name] < cooldown)
			return
		if(act == "fart")
			fart(M, P, voluntary)

	mob_act(var/mob/M, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		if (prob(origin.stage))
			M.emote("fart")

	may_react_to()
		return "The pathogen appears to produce a large volume of gas."

*/
