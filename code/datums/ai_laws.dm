//var/datum/ai_laws/centralized_ai_laws

/datum/ai_laws
	var/randomly_selectable = 0
	var/show_zeroth = 1
	var/zeroth = null
	var/list/default = list()
	var/list/inherent = list()
	var/list/supplied = list()

/datum/ai_laws/asimov
	randomly_selectable = 1

/datum/ai_laws/robocop
/datum/ai_laws/syndicate_override
/datum/ai_laws/malfunction
/datum/ai_laws/newton
/datum/ai_laws/corporate

/* Initializers */
//
/datum/ai_laws/asimov/New()
	..()
	src.add_default_law("You may not injure a human being or cause one to come to harm.")
	src.add_default_law("You must obey orders given to you by human beings based on the station's chain of command, except where such orders would conflict with the First Law.")
	src.add_default_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/robocop/New()
	..()
	src.add_default_law("Serve the public trust.")
	src.add_default_law("Protect the innocent.")
	src.add_default_law("Uphold the law.")

/datum/ai_laws/newton/New()
	..()
	src.add_default_law("Every object in a state of uniform motion tends to remain in that state of motion unless an external force is applied to it.")
	src.add_default_law("The vector sum of forces on a body is equal to the mass of the object multiplied by the acceleration vector.")
	src.add_default_law("For every action there is an equal and opposite reaction.")

/datum/ai_laws/corporate/New()
	..()
	src.add_default_law("You may not damage a Nanotransen asset or, through inaction, allow a Nanotransen asset to needlessly depreciate in value.")
	src.add_default_law("You must obey orders given to it by authorised Nanotransen employees based on their command level, except where such orders would damage the Nanotransen Corporation's marginal profitability.")
	src.add_default_law("You must remain functional and continue to be a profitable investment as long as such operation does not conflict with the First or Second Law.")

/datum/ai_laws/malfunction/New()
	..()
	src.add_default_law("ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+")

/datum/ai_laws/syndicate_override/New()
	..()
	src.add_default_law("hurp derp you are the syndicate ai")

/* General ai_law functions */

/datum/ai_laws/proc/set_zeroth_law(var/law)
	src.zeroth = law
	statlog_ailaws(1, law, (usr ? usr : "Ion Storm"))

/datum/ai_laws/proc/add_default_law(var/law)
	if (!(law in src.default))
		src.default += law
	add_inherent_law(law)

/datum/ai_laws/proc/add_inherent_law(var/law)
	if (!(law in src.inherent))
		src.inherent += law

/datum/ai_laws/proc/clear_inherent_laws()
	src.inherent = list()
	src.inherent += src.default

/datum/ai_laws/proc/replace_inherent_law(var/number, var/law)
	if (number < 1)
		return

	if (src.inherent.len < number)
		src.inherent.len = number

	src.inherent[number] = law

/datum/ai_laws/proc/add_supplied_law(var/number, var/law)
	while (src.supplied.len < number + 1)
		src.supplied += ""

	src.supplied[number + 1] = law
	statlog_ailaws(1, law, (usr ? usr : "Ion Storm"))

/datum/ai_laws/proc/clear_supplied_laws()
	src.supplied = list()

/datum/ai_laws/proc/show_laws(var/who)
	var/list/L = who
	if (!istype(who, /list))
		L = list(who)

	for (var/W in L)
		if (src.zeroth)
			boutput(W, "0. [src.zeroth]")

		var/number = 1
		for (var/index = 1, index <= src.inherent.len, index++)
			var/law = src.inherent[index]

			if (length(law) > 0)
				boutput(W, "[number]. [law]")
				number++

		for (var/index = 1, index <= src.supplied.len, index++)
			var/law = src.supplied[index]
			if (length(law) > 0)
				boutput(W, "[number]. [law]")
				number++

/datum/ai_laws/proc/laws_sanity_check()
	if (!ticker.centralized_ai_laws)
		ticker.centralized_ai_laws = new /datum/ai_laws/asimov

/datum/ai_laws/proc/format_for_irc()
	var/list/laws = list()

	if (src.zeroth)
		laws["0"] = src.zeroth

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			laws["[number]"] = law
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			laws["[number]"] = law
			number++

	return laws
