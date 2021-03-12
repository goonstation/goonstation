/datum/tag
	var/tmp/list/attributes = list()
	var/tmp/list/styles = list()
	var/tmp/list/classes = list()
	var/tmp/list/children = list()
	var/tmp/tagName = ""
	var/tmp/selfCloses = 0
	var/tmp/innerHtml

	New(var/_tagName as text)
		..()
		tagName = _tagName

	proc/addChildElement(var/datum/tag/child)
		children.Add(child)
		return src

	proc/addClass(var/class as text)
		var/list/classlist = kText.text2list(class, " ")

		for(var/cls in classlist)
			if(!classes.Find(cls))
				classes.Add(cls)

	proc/setAttribute(var/attribute as text, var/value as text)
		attributes[attribute] = "[attribute]=\"[value]\""

	proc/setStyle(var/attribute as text, var/value as text)
		styles[attribute] = "[attribute]:[value];"

	proc/toHtml()
		beforeToHtmlHook()
		var/html = "";

		html = "<[tagName]"

		if(classes.len)
			var/cls = kText.list2text(classes, " ")
			setAttribute("class", cls)

		if(styles.len)
			var/st = ""
			for(var/atr in styles)
				st += styles[atr]
			setAttribute("style", st)

		if(attributes.len)
			for(var/atr in attributes)
				html += " "
				html += attributes[atr]

		if(!selfCloses)
			html += ">"

			for(var/datum/tag/child in children)
				html += child.toHtml()

			if(innerHtml)
				html += "[innerHtml]"

			html += "</[tagName]>"
		else
			html += "/>"

		return html

	proc/beforeToHtmlHook()
		return

	proc/setId(var/id as text)
		setAttribute("id", id)

	proc/addJavascriptEvent(var/event as text, var/js as text)
		setAttribute(event, js)

	proc/sendAssets()
		for(var/datum/tag/child in children)
			child.sendAssets()
