/datum/tag/page
	var/tmp/datum/tag/doctype/dt = new
	var/tmp/datum/tag/head = new /datum/tag("head")
	var/tmp/datum/tag/body = new /datum/tag("body")

	New()
		..("html")

		addChildElement(head)
		addChildElement(body)

	toHtml()
		return dt.toHtml() + ..()

	proc/addToHead(var/datum/tag/child)
		head.addChildElement(child)

	proc/addToBody(var/datum/tag/child)
		body.addChildElement(child)
