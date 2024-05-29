/*
	Various Notes: OnActivate and OnLeave can return a value of DIALOGUE_CLOSE to close the dialogue window. (Without causing runtimes)
*/

var/global/list/globalDialogueFlags = list()
/client/var/list/list/datum/dialogueNode/dialogueNodePath = list()

//Same as the dialogue master based versions but global.vvv
proc/setGlobalFlag(var/client/C, var/flag="", var/value=null)
	if(!globalDialogueFlags.Find(C.ckey))
		globalDialogueFlags.Add(C.ckey)
		globalDialogueFlags[C.ckey] = list()

	var/list/curr = globalDialogueFlags[C.ckey]
	curr[flag] = value
	globalDialogueFlags[C.ckey] = curr
	return

proc/getGlobalFlag(var/client/C, var/flag="")
	if(!globalDialogueFlags.Find(C.ckey)) return null
	else
		var/list/curr = globalDialogueFlags[C.ckey]
		if(curr.Find(flag))
			return curr[flag]
		else
			return null

/datum/dialogueMaster
	var/datum/dialogueNode/start = null //The node the dialogue starts at.
	var/dialogueName = "" //Name that is shown in the dialogue and title.
	var/atom/master = null //The atom that this dialogueMaster belongs to.
	var/visibleDialogue = 1 //Is the dialogue visible to everyone?
	var/floatingText = 0 // Does this dialogue show floating chat?
	var/floating_text_style = "" // Style for floating text?
	var/windowSize = "400x700" //Size of the dialogue window.
	var/maxDistance = -1 //If >=0 The user needs to be at least this close for the dialogue to work.
	var/objectDialogueVerb = "says" //If the dialogueMaster belong to an object and showDialogue is one, what "verb" do we use for it's chat output.
	var/list/dialogueFlags = list() //Holds simple string flags that can be used in dialogue. I.e. "Have we talked about this before"
	var/list/allNodes = null //Complete list of nodes in the master.
	var/wait_to_speak = 0 SECONDS // time to wait for more natural visible conversations

	New(var/datum/M)
		master = M
		if(ispath(start))
			var/datum/dialogueNode/instance = new start(src)
			allNodes = instance.initialize(recursive=1)
			start = allNodes[1]
		..()

	Topic(href,href_list[])
		if(href_list["close"])
			var/datum/dialogueNode/D = getUserNode(usr.client)
			D.onLeave(usr.client, null)
			return
		if(href_list["link"] && href_list["client"])
			var/datum/dialogueNode/N = locate(href_list["link"])
			var/client/C = locate(href_list["client"])
			if(maxDistance >= 0)
				if(GET_DIST(C.mob, master) > maxDistance)
					boutput(C.mob, "You are too far away for that.")
					return
			if(N != null && N.canShow(C)) //The order of the stuff below is very important. You might break things if you change it.
				var/datum/dialogueNode/D = getUserNode(C)
				var/retVal = D.onLeave(C, N)
				if(retVal & DIALOGUE_CLOSE)
					C << browse(null, "window=dialogue")
					return
				if(!C.dialogueNodePath.Find("\ref[src]"))
					C.dialogueNodePath.Add("\ref[src]")
					C.dialogueNodePath["\ref[src]"] = list()
				var/list/path = C.dialogueNodePath["\ref[src]"]
				path.Add(N)
				retVal = null
				retVal = N.onActivate(C)
				if(retVal & DIALOGUE_CLOSE)
					C << browse(null, "window=dialogue")
					return
				var/html = getHtml(C, N)
				showDialogue(C.mob, html)
				if(visibleDialogue)
					C.mob.say(N.getLinkText(C))
					if(N != start)
						if(ismob(master))
							var/mob/M = master
							M.say(N.getNodeText(C))
						else if(isobj(master))
							sleep(wait_to_speak)
							var/chat_text = null
							if (floatingText)
								chat_text = make_chat_maptext(master, N.getNodeText(C), floating_text_style)
							for(var/mob/O in all_hearers(5, master.loc))
								O.show_message("[SPAN_NAME("[master.name]")] [objectDialogueVerb], [SPAN_MESSAGE("\"[N.getNodeText(C)]\"")]", 2, assoc_maptext = chat_text)
		return

	proc/setFlag(var/client/C, var/flag="", var/value="") //Sets flag to value for this client in this dialogue master.
		if(!dialogueFlags.Find(C.ckey))
			dialogueFlags.Add(C.ckey)
			dialogueFlags[C.ckey] = list()

		var/list/curr = dialogueFlags[C.ckey]
		curr[flag] = value
		dialogueFlags[C.ckey] = curr //Not sure if reference or not. Just to be sure here.
		return

	proc/getFlag(var/client/C, var/flag="") //Returns value of dialogue flag, or null if no match.
		if(!dialogueFlags.Find(C.ckey)) return null
		else
			var/list/curr = dialogueFlags[C.ckey]
			if(curr.Find(flag))
				return curr[flag]
			else
				return null

	proc/setFlagGlobal(var/client/C, var/flag="", var/value=null)
		return setGlobalFlag(C, flag, value)

	proc/getFlagGlobal(var/client/C, var/flag="")
		return getGlobalFlag(C, flag)

	proc/getUserNode(var/client/C, var/steps=0) //Returns the last activated node of the given user on this dialogueMaster. Can be considered the currently "active" node.
		RETURN_TYPE(/datum/dialogueNode)
		if(C.dialogueNodePath)					//Optionally goes [steps] steps back and gets that node instead of the last one.
			if(C.dialogueNodePath["\ref[src]"])
				if(C.dialogueNodePath["\ref[src]"].len)
					var/length = length(C.dialogueNodePath["\ref[src]"])
					if(steps > 0)
						if(length > steps)
							return C.dialogueNodePath["\ref[src]"][length - steps]
						else
							return null
					else
						return C.dialogueNodePath["\ref[src]"][length] //AAAAAAAAH WHAT THE FUCK
		return null

	proc/showDialogue(var/mob/user, var/html = null)
		if(!user || !user.client) return
		var/client/C = user.client
		if(html == null)
			if(start != null)
				if(!C.dialogueNodePath.Find("\ref[src]"))
					C.dialogueNodePath.Add("\ref[src]")
					C.dialogueNodePath["\ref[src]"] = list()
				var/list/path = C.dialogueNodePath["\ref[src]"]
				path.Add(start)
				var/retVal = start.onActivate(C) //I don't know why you'd want to close the dialogue window right after you open it but there you go.
				if(retVal & DIALOGUE_CLOSE)
					C << browse(null, "window=dialogue")
					return
				html = getHtml(C, start)
		C.Browse(html,"window=dialogue;title=[dialogueName];size=[windowSize]", 1)
		onclose(user, "dialogue", src)
		return

	proc/getHtml(var/client/C, var/datum/dialogueNode/node = start)
		var/html = {"<link rel="stylesheet" type="text/css" href="[resource("css/dialogue.css")]">"}
		html += node.getNodeHtml(C)
		html += "<br><br>"
		html += node.getBodyHtml(C)
		if(node != start && node.showBackToMain)
			html += start.getLinkHtml(C)
		return html

/*
Seeker nodes are a special type of node subclass that break the normal dialogue flow. Be careful with these.
targetNodeType is the type of the node we want to jump to. If you give your subclass of this node any
images or text, they will override the corresponding values on the target node. Useful if you want a
"go back one step" button that provides a different text when you get back to the last node, or something like that.
Links are ignored on this node. It uses the target node's links.
*/
/datum/dialogueNode/seeker
	var/targetNodeType = null //Which node type to jump to. Must be present in the same dialogueMaster as this node.
	var/respectCanShow = 1 //Only consider nodes that can normally be shown to the client.

	proc/getTargetNode()
		var/datum/dialogueNode/foundNode = null
		for(var/datum/dialogueNode/N in master.allNodes)
			if(N.type == targetNodeType)
				foundNode = N
				break
		return foundNode

	canShow(var/client/C)
		var/datum/dialogueNode/foundNode = getTargetNode()
		if(foundNode && (!respectCanShow || foundNode.canShow(C)))
			return 1
		else
			return 0

	getBodyHtml(var/client/C)
		var/datum/dialogueNode/foundNode = getTargetNode()
		if(foundNode != null)
			src.showBackToMain = foundNode.showBackToMain
			foundNode.onActivate(C)
			var/html = ""
			for(var/X in foundNode.links)
				if(ispath(X))
					message_coders("Uninitialized node in dialogue [X] in [foundNode.type] - via seeker node [src.type]")
					continue
				else if(istype(X, /datum/dialogueNode))
					var/datum/dialogueNode/N = X
					if(N.canShow(C))
						html += N.getLinkHtml(C)
						html += "<br>"
			return html
		else
			alert(C, "Uh-oh, the dialogue broke! No valid link was found. Please alert a coder with this info: getBodyHtml [targetNodeType] [master.allNodes.len]", "Oh no", "Ok")

	getNodeHtml(var/client/C)
		var/datum/dialogueNode/foundNode = getTargetNode()
		if(foundNode != null)
			var/html = ""

			if(nodeImage != null)
				html += {"<img class="centerimg" src='[getNodeImage(C)]'><HR><B>[master.dialogueName]</B><HR>"}
			else if(foundNode.nodeImage != null)
				html += {"<img class="centerimg" src='[foundNode.getNodeImage(C)]'><HR><B>[master.dialogueName]</B><HR>"}

			if(getNodeText(C) != "")
				html += {"<span>[getNodeText(C)]</span>"}
			else
				html += {"<span>[foundNode.getNodeText(C)]</span>"}
			return html
		else
			alert(C, "Uh-oh, the dialogue broke! No valid link was found. Please alert a coder with this info: getNodeHtml [targetNodeType] [master.allNodes.len]", "Oh no", "Ok")

/datum/dialogueNode
	var/nodeImage = null //Portrait or whatever for this node.
	var/nodeText = "" //What's displayed when you enter this node. What the npc says.
	var/linkText = "" //The text that links TO this node. What you say to the NPC to get to this node.
	var/links = list() //Which nodes are inside this node. What "buttons" this node contains.
	var/showBackToMain = 1 //Show button leading back to first screen on this node? Careful: Without this people might get stuck. Plan your dialogue.
	var/datum/dialogueMaster/master = null

	New(var/datum/dialogueMaster/M)
		master = M
		..()

	proc/initialize(var/recursive = 1, var/list/tree = null)
		if(tree == null)
			tree = list(src)
		else
			tree.Add(src)
		for(var/X in links)
			if(ispath(X))
				var/datum/dialogueNode/N = new X(master)
				links -= X
				links += N
				if(recursive)
					N.initialize(recursive, tree)
		return tree

	proc/getNodeImage(var/client/C) //Returns nodeImage by default but can override for dynamic behaviour.
		return resource("images/traders/[nodeImage]")

	proc/getNodeHtml(var/client/C) //Returns portrait and getNodeText() by default, separated by line. Can override for dynamic behaviour.
		var/html = ""
		if(nodeImage != null)
			html += {"<img class="centerimg" src='[getNodeImage(C)]'><HR><B>[master.dialogueName]</B><HR>"}
		html += {"<span>[getNodeText(C)]</span>"}
		return html

	proc/getLinkHtml(var/client/C) //Returns getLinkText() by default. Can override for dynamic behaviour.
		return {"<a class="button full" href='byond://?src=\ref[master];link=\ref[src];client=\ref[C]'>[getLinkText(C)]</a>"}

	proc/getNodeText(var/client/C) //Simply returns the node text by default - node text is what the npc says. Can override for dynamic behaviour.
		return nodeText

	proc/getLinkText(var/client/C) //Returns linkText by default - link text is what you say to the npc to get to this node. Can override for dynamic behaviour.
		return linkText

	proc/getBodyHtml(var/client/C) //Returns a list of buttons representing all nodes in this nodes links by default.
		var/html = ""
		for(var/X in links)
			if(ispath(X))
				message_coders("Uninitialized node in dialogue [X] in [src.type]")
				continue
			else if(istype(X, /datum/dialogueNode))
				var/datum/dialogueNode/N = X
				if(N.canShow(C))
					html += N.getLinkHtml(C)
					html += "<br>"
		return html

	proc/onActivate(var/client/C) //Called when selected. If you want to hook the actual world up somehow. This runs before any html is generates so it could be used to manipulate things before that.
		return

	// !!!!!!!!!!! WARNING : THIS WILL GET CALLED TWICE PER CHUI WINDOW CLOSE DUE TO A BUG I HAVENT BEEN ABLE TO RESOLVE - ACCOUNT FOR THAT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	proc/onLeave(var/client/C, var/datum/dialogueNode/nextNode) //Called when node is left for another node or when the window is closed with a node open. nextNode might be null if window was closed.
		return

	proc/canShow(var/client/C) //For conditional options. Link to this node only shows if result == true/1/whatever.
		return 1
