/*
This file serves as an example for various things that could be done with dialogues.
*/

/mob/living/carbon/human/dialogueDummy
	name = "Admiral Wardson"
	desc = "That *thing* is not a real person."
	density = 1
	anchored = 1
	icon='icons/mob/human.dmi'
	icon_state = "body_m"

	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/ntFaction(src)
		..()

	Click(location,control,params)
		dialogue.showDialogue(usr)
		return

/datum/dialogueMaster/ntFaction
	dialogueName = "NT Representative"
	start = /datum/dialogueNode/ntstart

/datum/dialogueNode/seeker/example //Skip from who section to reward section as an example. We override the target's image and node text.
	nodeImage = "ntrep_angery.png"
	linkText = "Oh btw, i want some of your rewards."
	nodeText = "Uh ... okay? I guess? Here's what i have ..."
	targetNodeType = /datum/dialogueNode/ntrewards
	respectCanShow = 1

/datum/dialogueNode
	ntstart
		nodeImage = "ntrep_neutral.png"
		linkText = "..." //Because we use the first node as a "go back" link as well.
		links = list(/datum/dialogueNode/ntwho,/datum/dialogueNode/ntreputation,/datum/dialogueNode/ntrewards,/datum/dialogueNode/ntstanding,/datum/dialogueNode/ntitem,/datum/dialogueNode/ntflagtestone,/datum/dialogueNode/ntflagtesttwo,/datum/dialogueNode/nttest,/datum/dialogueNode/ntlastnode)
		var/lastComplaint = 0

		getNodeImage(var/client/C)
			if(master.getFlag(C, "leftmehowdarethey"))
				return resource("images/traders/ntrep_angery.png")
			else
				return resource("images/traders/[nodeImage]")

		getNodeText(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(master.getFlag(C, "leftmehowdarethey"))
				master.setFlag(C, "leftmehowdarethey", 0)
				return "How dare you close the dialogue window on me? Did you think i wouldn't notice?!?!"
			else
				switch(rep)
					if(0)
						return "Hello [C.mob.name]."
					if(-3 to -1)
						return "And what do you want?"
					if(-6 to -4)
						return "What do you want, you darn traitor?"
					if(1 to 3)
						return "Good to see you [C.mob.name]!"
					if(4 to 6)
						return "Hope you're having an excellent day [C.mob.name]!"
			return ""

		onLeave(var/client/C, var/datum/dialogueNode/nextNode)
			if(nextNode == null) //Window closed
				if(world.time - lastComplaint >= 10)
					lastComplaint = world.time
					master.setFlag(C, "leftmehowdarethey", 1)
					var/mob/M = master.master
					M.say("hey ... HEY ... Where are you going?! I'm talking to you [C.mob.name]!")

	nttest
		nodeImage = "ntrep_neutral.png"
		nodeText = ""
		linkText = @"[Test input]"
		links = list()
		var/list/inputs = list() //Required in case multiple people are using this at the same time.

		onActivate(var/client/C)
			var/X = input(C,"ENTER THING","TEST","Hello") as text
			inputs[C.ckey] = X
			return

		getNodeText(var/client/C)
			return "You entered '[inputs[C.ckey]]'"

	ntwho
		nodeImage = "ntrep_sad.png"
		linkText = "Who are you?"
		nodeText = "I am Admiral Wardson. And for some reason they stuck me on this goddamn station to represent NT's interests."
		links = list(/datum/dialogueNode/seeker/example)

	ntreputation
		nodeImage = "ntrep_angery.png"
		linkText = "How can i earn reputation with you?"
		nodeText = "We would encourage you to dispose of any threats to the station you might find. Especially those darn syndicate members."
		links = list()

	ntstanding
		nodeImage = "ntrep_neutral.png"
		linkText = "What is my current standing?"
		links = list()

		getNodeText(var/client/C)
			var/rep = C.reputations.get_reputation_string("nt")
			return "Your current standing is [rep]."

	ntrewards
		nodeImage = "ntrep_neutral.png"
		linkText = "Let me see the available gear, please."
		nodeText = "Here's what i got ..."
		links = list(/datum/dialogueNode/ntreward_a)

	ntreward_a
		nodeImage = "ntrep_sad.png"
		linkText = "Hand-cranked antique taser trebuchet"
		nodeText = "Sure thing, please allow 12-86 weeks for shipping."
		links = list()

		canShow(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(rep >= 0) return 1
			else return 0

		onActivate(var/client/C)
			//Give them the thing here.
			return

	ntlastnode
		nodeImage = "ntrep_neutral.png"
		linkText = "What node am i currently on?!"
		nodeText = ""

		getNodeText(var/client/C)
			return "Well you <i>were</i> on [master.getUserNode(C, 1).type].<br>But now you're here on [master.getUserNode(C).type]"

	ntitem
		nodeImage = "ntrep_sad.png"
		linkText = "I HAVE AN /OBJ/ITEM"
		nodeText = "Okay thats nice for you"
		links = list(/datum/dialogueNode/ntitemtake)

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item)) return 1
			else return 0

	ntitemtake
		nodeImage = "ntrep_neutral.png"
		linkText = "TAKE MY /OBJ/ITEM"
		nodeText = ""
		links = list()

		getNodeText(var/client/C)
			return "That's a nice [C.mob.equipped().name], thanks."

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item)) return 1
			else return 0

		onActivate(var/client/C) //This happens after getNodeText, so you can still safely reference it in there.
			qdel(C.mob.equipped())
			return

	ntflagtestone
		nodeImage = "ntrep_neutral.png"
		linkText = "Set my dialogue flag, please."
		nodeText = "You got it boss."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "testflag") == "itssetyep") return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "testflag", "itssetyep")
			return

	ntflagtesttwo
		nodeImage = "ntrep_angery.png"
		linkText = "Set my dialogue flag AGAIN!!!"
		nodeText = "Fuck off, it's already set."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "testflag") == "itssetyep") return 1
			else return 0
