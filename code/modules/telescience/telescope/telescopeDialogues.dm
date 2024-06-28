
/* VALIANT DIALOGUE BELOW */

/datum/dialogueMaster/telescopeValiant
	dialogueName = "SS Valiant"
	start = /datum/dialogueNode/valiant/telValiantStart
	visibleDialogue = 0
	var/signal = 100
	var/maxSignal = 100
	var/corruptionThreshold = 39
	var/disconnectThreshold = 9

/datum/dialogueNode/valiant
	getNodeHtml(var/client/C)
		var/datum/dialogueMaster/telescopeValiant/M = master
		var/html = ""
		if(nodeImage != null)
			html += {"<img class="centerimg" src='[getNodeImage(C)]'><HR><B>[master.dialogueName]</B><br>SIGNAL STRENGTH: <div style="display:inline-block;height:1.5em;width:200px;padding:0;background-color:#545454;float:right;overflow:hidden;margin-bottom:4px;"><div style="height:100%;width:[max(0,round((M.signal/M.maxSignal) * 100))]%;text-align:right;background-color:#6c90a3;padding-right:3px;">[max(0,round((M.signal/M.maxSignal) * 100))]%</div></div><HR>"}
		html += {"<span>[getNodeText(C)]</span>"}
		return html

/datum/dialogueNode/valiant
	telValiantStart
		links = list(/datum/dialogueNode/valiant/telValiantWhatNow, /datum/dialogueNode/valiant/telValiantEmergency, /datum/dialogueNode/valiant/telValiantStatic)
		nodeImage = "valiant.png"
		nodeText = "Greetings. You are connected to the assistant A.I. of the <i>SS Valiant</i>."
		linkText = @"[Return]"

		getNodeText(client/C)
			var/datum/dialogueMaster/telescopeValiant/M = master
			// not constant, can't switch
			if (70 < M.signal && M.signal < INFINITY)
				if(master.getFlag(C, "valiantIntro"))
					return "Please state your query."
				else
					return nodeText
			else if (40 < M.signal && M.signal < 70)
				return "Warning: Signal integrity compromised.<br>A stable connection can not be guaranteed."
			else if(10 < M.signal && M.signal < M.corruptionThreshold)
				return "S_gn__icant data _oss d_tecte_. You might experi___e intermittent l_ss of connecti____"
			else if(-INFINITY < M.signal && M.signal < M.disconnectThreshold)
				return "<i>The connection to the SS Valiant has been lost. There is nothing left to do here.</i>"

		getNodeImage(client/C)
			var/datum/dialogueMaster/telescopeValiant/M = master
			if(M.signal > M.disconnectThreshold)
				return resource("images/traders/[nodeImage]")
			else
				return resource("images/traders/valiantStatic.png")

	telValiantStatic
		links = list()
		nodeImage = "valiantStatic.png"
		linkText = "Where is the Valiant now?"
		nodeText = {"<i>The screen unexpectedly bursts into static.<br>Looks like you'll have to find a way to re-establish the signal.</i>"}

		onActivate(var/client/C)
			var/datum/dialogueMaster/telescopeValiant/M = master
			master.setFlagGlobal(C, "valiantStatic", 1)
			M.signal -= 100
			return

		canShow(var/client/C)
			var/datum/dialogueMaster/telescopeValiant/M = master
			if(M.signal <= M.disconnectThreshold) return 0
			if(master.getFlagGlobal(C, "valiantStatic")) return 0
			if(master.getFlag(C, "valiantIntro")) return 1
			else return 0

	telValiantWhatNow
		links = list(/datum/dialogueNode/valiant/telValiantFunctions)
		nodeImage = "valiant.png"
		linkText = "The what now?"
		nodeText = {"I am the ship-wide A.I. of the <i>SS Valiant</i>.
		<br>My purpose is to aid the crew of the ship in both active, as well as advisory functions."}

		onActivate(var/client/C)
			var/datum/dialogueMaster/telescopeValiant/M = master
			master.setFlag(C, "valiantIntro", 1)
			M.signal -= rand(5,10)
			return

		canShow(var/client/C)
			var/datum/dialogueMaster/telescopeValiant/M = master
			if(M.signal <= M.disconnectThreshold) return 0
			if(master.getFlag(C, "valiantIntro")) return 0
			else return 1

	telValiantFunctions
		links = list()
		nodeImage = "valiant.png"
		linkText = "Active functions?"
		nodeText = {"As the ship's A.I. i have access to various sub-systems such as weapons, navigation and the nanite-hive.
		<br>In case of emergency, the communication-systems may also be accessed.
		<br>The signal you have received is the result of one such emergency."}

		onActivate(var/client/C)
			var/datum/dialogueMaster/telescopeValiant/M = master
			M.signal -= rand(5,10)
			return

	telValiantEmergency
		links = list()
		nodeImage = "valiant.png"
		linkText = "What happened to the ship?"
		nodeText = {"At 1352.5 the <i>SS Valiant</i> sustained critical damage due to an unspecified class-C incursion event.
		<br>The stern section of the ship has been severed from the rest of the ship.
		<br>Due to significant sensor failure, survival of the ship's crew can not be accurately assessed.
		"}

		onActivate(var/client/C)
			var/datum/dialogueMaster/telescopeValiant/M = master
			M.signal -= rand(10,20)
			return

		canShow(var/client/C)
			var/datum/dialogueMaster/telescopeValiant/M = master
			if(M.signal <= M.disconnectThreshold) return 0
			if(master.getFlag(C, "valiantIntro")) return 1
			else return 0

/* SECRET PEN DIALOGUE BELOW */

/datum/dialogueMaster/telescopePen
	dialogueName = "Unknown"
	start = /datum/dialogueNode/telPenStart
	visibleDialogue = 0

/datum/dialogueNode
	telPenStart
		nodeImage = "thesecretkey.png"
		nodeText = "The transmission is very weak and the video signal is heavily degraded.<br>It's nearly impossible to make out what's going on.<br>There is no audio and there seems to be some sort of object in the foreground.<br>The background appears strangely empty."
		linkText = "..."
		links = list()

/* GEMINORUM DIALOGUE BELOW */

/datum/dialogueMaster/telescopeGeminorum
	dialogueName = "Geminorum V"
	start = /datum/dialogueNode/telGeminorumStart
	visibleDialogue = 0

/datum/dialogueNode
	telGeminorumStart
		nodeImage = "blueplanet.png"
		nodeText = "There appears to be some sort of signal beacon in a cave on this planet.<br>Scans show that the planet is strangely devoid of any sentient life despite it's lush vegetation."
		linkText = "..."
		links = list(/datum/dialogueNode/telGeminorumEnable)

	telGeminorumEnable
		linkText = "Save the location."
		nodeText = "The location is now available at the long-range teleporter."

		onActivate(var/client/C)
			if(!special_places.Find("Geminorum V"))
				special_places.Add("Geminorum V")
			return

		canShow(var/client/C)
			if(!special_places.Find("Geminorum V"))
				return 1
			else
				return 0

/* DOJO DIALOGUE BELOW */

/datum/dialogueMaster/telescopeDojo
	dialogueName = "Hidden Workshop"
	start = /datum/dialogueNode/telDojoStart
	visibleDialogue = 0

/datum/dialogueNode
	telDojoStart
		nodeImage = "dojopreview.png"
		nodeText = "You can't tell exactly where this signal originates from.<br>There appears to be a great deal of energy radiating from either an abandoned vessel on the surface or an underground complex.<br>There is a clearing close to the center of the energy readings that you'd be able to send a team to."
		linkText = "..."
		links = list(/datum/dialogueNode/telDojoEnable)

	telDojoEnable
		linkText = "Save the location."
		nodeText = "The location is now available at the long-range teleporter."

		onActivate(var/client/C)
			if(!special_places.Find("Hidden Workshop"))
				special_places.Add("Hidden Workshop")
			return

		canShow(var/client/C)
			if(!special_places.Find("Hidden Workshop"))
				return 1
			else
				return 0

#ifdef ENABLE_ARTEMIS
/* Artemis Dialogue */

/datum/dialogueMaster/telescopeArtemis
	dialogueName = "Artemis"
	start = /datum/dialogueNode/telArtemisStart
	visibleDialogue = 0

/datum/dialogueNode
	telArtemisStart
		nodeImage = "static.png"
		nodeText = "There appears to be a transponder signal from a NT science vessel."
		linkText = "..."
		links = list(/datum/dialogueNode/telArtemisEnable)

	telArtemisEnable
		linkText = "Save the location."
		nodeText = "The location is now available at the long-range teleporter."

		onActivate(var/client/C)
			if(!special_places.Find("Artemis"))
				special_places.Add("Artemis")
			return

		canShow(var/client/C)
			if(!special_places.Find("Artemis"))
				return 1
			else
				return 0
#endif


/* COW DINER DIALOGUE BELOW */

/datum/dialogueMaster/telescopeCow
	dialogueName = "Void Diner"
	start = /datum/dialogueNode/telCowStart
	visibleDialogue = 0

/datum/dialogueNode
	telCowStart
		nodeImage = "milk.png"
		nodeText = "This place seems... familiar.<br>Have you been here before?"
		linkText = "..."
		links = list(/datum/dialogueNode/telCowEnable)

	telCowEnable
		linkText = "Save the location."
		nodeText = "The location is now available at the long-range teleporter."

		onActivate(var/client/C)
			if(!special_places.Find("Void Diner"))
				special_places.Add("Void Diner")
			return

		canShow(var/client/C)
			if(!special_places.Find("Void Diner"))
				return 1
			else
				return 0

/* WATCHFUL EYE SENSOR DIALOGUE */

/datum/dialogueMaster/telescopeEye
	dialogueName = "Watchful Eye Sensor"
	start = /datum/dialogueNode/telEyeStart
	visibleDialogue = 0

/datum/dialogueNode
	telEyeStart
		nodeImage = "eye.png"
		nodeText = "Periodic Signals emanate from this Satellite.<br>It seems awfully close to the purple giant."
		linkText = "..."
		links = list(/datum/dialogueNode/telEyeEnable)

	telEyeEnable
		linkText = "Save the location."
		nodeText = "The location is now available at the long-range teleporter."

		onActivate(var/client/C)
			if(!special_places.Find("Watchful-Eye Sensor"))
				special_places.Add("Watchful-Eye Sensor")
			return

		canShow(var/client/C)
			if(!special_places.Find("Watchful-Eye Sensor"))
				return 1
			else
				return 0

/* GENERIC ASTEROID DIALOGUE BELOW */

/datum/dialogueMaster/telescopeAsteroidDialogue
	dialogueName = "Asteroid"
	start = /datum/dialogueNode/telAstStart
	visibleDialogue = 0
	var/datum/telescope_event/linkedEvent = null
	var/encounterName = ""

/datum/dialogueNode
	telAstStart
		nodeImage = ""
		linkText = "..."
		links = list(/datum/dialogueNode/telAstRare,/datum/dialogueNode/telAstEnable,/datum/dialogueNode/telAstDiscard)

	telAstEnable
		linkText = "Save the location to the mining database."
		nodeText = "The asteroid is now available at the mining magnet."

		onActivate(var/client/C)
			var/datum/dialogueMaster/telescopeAsteroidDialogue/astMaster = master
			mining_controls.add_selectable_encounter(mining_controls.get_encounter_by_name(astMaster.encounterName))
			if(tele_man.events_found.Find(astMaster.linkedEvent.id))
				tele_man.events_found.Remove(astMaster.linkedEvent.id)
				tele_man.events_inactive.Add(astMaster.linkedEvent.id)
				tele_man.events_inactive[astMaster.linkedEvent.id] = astMaster.linkedEvent

				if(!astMaster.linkedEvent.fixed_location)
					astMaster.linkedEvent.loc_x = rand(0, 640)
					astMaster.linkedEvent.loc_y = rand(0, 431)

				var/numSeen = master.getFlagGlobal(C, "asteroidsSeen")
				if(numSeen != null)
					master.setFlagGlobal(C, "asteroidsSeen", numSeen+1)
				else
					master.setFlagGlobal(C, "asteroidsSeen", 1)
			return

		canShow(var/client/C)
			var/datum/dialogueMaster/telescopeAsteroidDialogue/astMaster = master
			if(tele_man.events_found.Find(astMaster.linkedEvent.id)) return 1
			else return 0

	telAstDiscard
		linkText = "Discard the location."
		nodeText = "The location has been deleted."

		onActivate(var/client/C)
			var/datum/dialogueMaster/telescopeAsteroidDialogue/astMaster = master
			if(tele_man.events_found.Find(astMaster.linkedEvent.id))
				tele_man.events_found.Remove(astMaster.linkedEvent.id)
				tele_man.events_inactive.Add(astMaster.linkedEvent.id)
				tele_man.events_inactive[astMaster.linkedEvent.id] = astMaster.linkedEvent

				if(!astMaster.linkedEvent.fixed_location)
					astMaster.linkedEvent.loc_x = rand(0, 640)
					astMaster.linkedEvent.loc_y = rand(0, 431)

				var/numSeen = master.getFlagGlobal(C, "asteroidsSeen")
				if(numSeen != null)
					master.setFlagGlobal(C, "asteroidsSeen", numSeen+1)
				else
					master.setFlagGlobal(C, "asteroidsSeen", 1)
			return

		canShow(var/client/C)
			var/datum/dialogueMaster/telescopeAsteroidDialogue/astMaster = master
			if(tele_man.events_found.Find(astMaster.linkedEvent.id)) return 1
			else return 0

	telAstRare
		linkText = "The scanner is picking up something else ..."
		nodeText = "To your surprise, you find that the asteroid also carries some ..."
		nodeImage = "static.png"
		links = list(/datum/dialogueNode/telAstRareViscerite,/datum/dialogueNode/telAstRareKoshmarite,/datum/dialogueNode/telAstRareErebite,/datum/dialogueNode/telAstRareCerenkite,/datum/dialogueNode/telAstRareStarstone,/datum/dialogueNode/telAstRareNanites,/datum/dialogueNode/telAstRareMolitz)

		onActivate(var/client/C)
			return

		canShow(var/client/C)
			if(master.getFlagGlobal(C, "asteroidsSeen") >= 5)
				return 1
			else
				return 0

	telAstRareErebite
		linkText = "... Erebite!"
		nodeText = "Well this is going to be dangerous. Best save that to the mining magnet."
		nodeImage = "asteroidgoldred.png"

		onActivate(var/client/C)
			master.setFlagGlobal(C, "asteroidsSeen", null)
			mining_controls.add_selectable_encounter(mining_controls.get_encounter_by_name("Erebite asteroid"))
			return

		canShow(var/client/C)
			if(master.getFlagGlobal(C, "asteroidsSeen") >= 5)
				return 1
			else
				return 0

	telAstRareCerenkite
		linkText = "... Cerenkite!"
		nodeText = "Don't know how you missed that. That stuff is practically glowing. Saving to mining magnet."
		nodeImage = "asteroidblue.png"

		onActivate(var/client/C)
			master.setFlagGlobal(C, "asteroidsSeen", null)
			mining_controls.add_selectable_encounter(mining_controls.get_encounter_by_name("Cerenkite asteroid"))
			return

		canShow(var/client/C)
			if(master.getFlagGlobal(C, "asteroidsSeen") >= 5)
				return 1
			else
				return 0

	telAstRareMolitz
		linkText = "... Molitz!"
		nodeText = "I'm sure more is better? ... Saved."
		nodeImage = "asteroidcrystal.png"

		onActivate(var/client/C)
			master.setFlagGlobal(C, "asteroidsSeen", null)
			mining_controls.add_selectable_encounter(mining_controls.get_encounter_by_name("Molitz asteroid"))
			return

		canShow(var/client/C)
			if(master.getFlagGlobal(C, "asteroidsSeen") >= 5)
				return 1
			else
				return 0

	telAstRareKoshmarite
		linkText = "... Koshmarite!"
		nodeText = "Well I'm sure it's good for ... something. Saving it."
		nodeImage = "asteroidglowpurp.png"

		onActivate(var/client/C)
			master.setFlagGlobal(C, "asteroidsSeen", null)
			mining_controls.add_selectable_encounter(mining_controls.get_encounter_by_name("Koshmarite asteroid"))
			return

		canShow(var/client/C)
			if(master.getFlagGlobal(C, "asteroidsSeen") >= 5)
				return 1
			else
				return 0

	telAstRareViscerite
		linkText = "... Viscerite!"
		nodeText = "Eww. Just ... eww. Why would you even ... Saved."
		nodeImage = "asteroidglowpurp.png"

		onActivate(var/client/C)
			master.setFlagGlobal(C, "asteroidsSeen", null)
			mining_controls.add_selectable_encounter(mining_controls.get_encounter_by_name("Viscerite asteroid"))
			return

		canShow(var/client/C)
			if(master.getFlagGlobal(C, "asteroidsSeen") >= 5)
				return 1
			else
				return 0

	telAstRareStarstone
		linkText = "... Starstone!"
		nodeText = "About time we got some of that. Saving it to the mining magnet."
		nodeImage = "asteroidcrystal.png"

		onActivate(var/client/C)
			master.setFlagGlobal(C, "asteroidsSeen", null)
			mining_controls.add_selectable_encounter(mining_controls.get_encounter_by_name("Starstone asteroid"))
			return

		canShow(var/client/C)
			if(master.getFlagGlobal(C, "asteroidsSeen") >= 15)
				return 1
			else
				return 0


	telAstRareNanites
		linkText = "... Nanites!"
		nodeText = "Who knows how those got on there, best be careful. Saving it to the mining magnet."
		nodeImage = "asteroidnano.png"

		onActivate(var/client/C)
			master.setFlagGlobal(C, "asteroidsSeen", null)
			mining_controls.add_selectable_encounter(mining_controls.get_encounter_by_name("Nanite asteroid"))
			return

		canShow(var/client/C)
			if(master.getFlagGlobal(C, "asteroidsSeen") >= 20)
				return 1
			else
				return 0
