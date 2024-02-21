/datum/dialogueMaster/traderGeneric
	dialogueName = "Trader"
	start = /datum/dialogueNode/traderStartGeneric
	New(var/atom/M)
		..()
		dialogueName = master.name

/datum/dialogueNode/traderStartGeneric
	nodeImage = "generic.png"
	linkText = "..."
	links = list(/datum/dialogueNode/traderWho, /datum/dialogueNode/traderStartTrade)

	getNodeImage(var/client/C)
		var/atom/A = master.master
		if(istype(A, /obj/npc/trader))
			var/obj/npc/trader/T = A
			return resource("images/traders/[((T.picture != null && T.picture != "") ? T.picture : "generic.png")]")
		else
			return resource("images/traders/[nodeImage]")

	getNodeText(var/client/C)
		var/atom/A = master.master
		if(istype(A, /obj/npc/trader))
			var/obj/npc/trader/T = A
			return T.greeting
		else
			return "Yes?"

/datum/dialogueNode/traderWho
	nodeImage = "generic.png"
	linkText = "Who are you?"
	nodeText = "Just a trader."

	getNodeImage(var/client/C)
		var/atom/A = master.master
		if(istype(A, /obj/npc/trader))
			var/obj/npc/trader/T = A
			return resource("images/traders/[((T.picture != null && T.picture != "") ? T.picture : "generic.png")]")
		else
			return resource("images/traders/[nodeImage]")

	getNodeText(var/client/C)
		var/atom/A = master.master
		if(istype(A, /obj/npc/trader))
			var/obj/npc/trader/T = A
			if(T.whotext != "")
				return T.whotext
			else
				return nodeText
		else
			return nodeText

/datum/dialogueNode/traderStartTrade
	nodeImage = "generic.png"
	linkText = "I want to trade ..."

	getNodeImage(var/client/C)
		var/atom/A = master.master
		if(istype(A, /obj/npc/trader))
			var/obj/npc/trader/T = A
			return resource("images/traders/[((T.picture != null && T.picture != "") ? T.picture : "generic.png")]")
		else
			return resource("images/traders/[nodeImage]")

	getNodeText(var/client/C)
		var/atom/A = master.master
		if(istype(A, /obj/npc/trader))
			var/obj/npc/trader/T = A
			if(T.angry)
				return T.angrynope
			else
				return nodeText
		else
			return nodeText

	onActivate(var/client/C)
		var/atom/A = master.master
		if(istype(A, /obj/npc/trader) && C.mob != null)
			var/obj/npc/trader/T = A
			if(!T.angry)
				T.openTrade(C.mob, windowName = "trader", windowSize = "400x700")
		return DIALOGUE_CLOSE
