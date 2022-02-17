chui/window/law_rack
	name = "AI Law Mount Rack"
	var/obj/machinery/ai_law_rack/owner
	windowSize = "650x500"
	flags = CHUI_FLAG_MOVABLE

	New(var/obj/machinery/ai_law_rack/my_rack)
		..()
		owner = my_rack
		theAtom = owner

	GetBody()
		var/html = ""
		html += "<ol start=\"0\">"

		html += "[theme.generateButton("update", "Update Laws")]"

		for (var/i=0, i < my_rack.MAX_CIRCUITS, i++)
			if (my.rack.law_circuits[i] == null)
				html += "<li>[theme.generateButton([i], "No Law Circuit Inserted")] </li>"
			else
				html += "<li>[theme.generateButton([i], "[my_rack.law_circuits[i].lawtext]")]</li>"

		html += "</ol>"

		for(var/obj/machinery/phone/P in my_rack.law_circuits)
			html += "[theme.generateButton(P.phone_id, "[P.phone_id]")] <br/>"
		return html

	OnClick(var/client/who, var/id, var/data) //SOUND FX FOR CLICKY CLICKY TODO
		if (!my_rack) return
		if (my_rack.status & BROKEN || my_rack.status & NOPOWER))
			boutput(who, "<b><span style=\"color:red\">The button doesn't seem to do anything! Something must be wrong with the rack.</span></b>")
			return
		switch(id)
			if ("update")
				my_rack.update_laws(who.mob)
			else
				my_rack.Topic("", list("[id]"=1) + params2list(data))

		Unsubscribe(who)