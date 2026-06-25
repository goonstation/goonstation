/datum/cyberintel/article
	var/ticks = 0
	New()
		..()
		ticks = ticker.round_elapsed_ticks

	// ir - irrelevant
	var/list/industry = list("agricultural", "mining", "plasma research", "AI research", "medical", "power generation")
	var/list/industryir = list("ornitology", "horse-breeding", "interior design", "videogame", "entertainment")
	var/list/common = list("common-use", "widespread", "popular")
	var/list/fakeos = list("BakeROS", "Strawberry CI", "Thaumiel", "Buntutu", "Bedyan", "DollarDOS")
	var/list/culprit = list("culprit", "malware", "attacker", "threat")
	var/list/undergoing = list("undergoing", "pending", "unfinished", "planned to start soon")
	var/list/cybercompany = list("Cybersecurity and Infrastructure Bureau", "PacketWarden", "ReThreat")
	var/list/unexpect = list("unexpected", "sudden", "out-of-nowhere", "spontaneous")
	var/list/malwarestrains = list("CluwneBash", "Electrum")

	var/article = ""
	var/headline = ""
	var/relevant = TRUE
	var/author = ""
	var/inarticle_hash = ""
	var/outhash = "" // used in cybersecurity_machines.dm // probably could be cleaner but i am so done with this

	var/list/hashchars = list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
	proc/generateHash(charlist, amt) // for irrelevant articles
		var/hash = ""
		for (var/I in 1 to amt)
			hash += pick(charlist)
		return hash

	proc/generateHeadline(eventgroup, malwarestrain, hash, relevant)
		var/list/headlines = list(
			"[prob(50) ? "[malwarestrain]" : "[eventgroup]"] strikes again!",
			"[prob(50) ? "[malwarestrain]" : "[eventgroup]"] hits the [prob(99) ? pick(industry) : "circus"] industry!",
			"[pick(industry)] in shambles!",
			"[pick(common)] system breached!",
			"An unknown exploit in the wild!",
			"[prob(50) ? "[malwarestrain]" : "[eventgroup]"] at it again!",
			"[eventgroup] seeks revenge!"
		)
		return capitalize(pick(headlines))

	// article headline and body
	proc/generateArticle(eventgroup, malwarestrain, hash, relevant)
		headline = generateHeadline(eventgroup, malwarestrain, hash, relevant)
		switch(rand(1,3))
			if(1)
				if (relevant)
					article += "The [pick(unexpect)] malware attack has [prob(50) ? "revealed" : "uncovered"] a new \
					vulnerability in the [pick(common)] ThinkDos operarting system. "
				else
					article = "The [pick(unexpect)] malware attack has [prob(50) ? "revealed" : "uncovered"] a new \
					vulnerability in the [pick(fakeos)] operarting system. "
			if(2)
				if (relevant)
					article += "Another day, another hack! The [malwarestrain] proves relentless, as multiple \
					[industry] facilities report successful exploitation and remote access on [culprit]'s part."
				else
					article += "Another day, another hack! The [malwarestrain] proves relentless, as multiple \
					[industryir] facilities report successful exploitation and remote access on [culprit]'s part."
			if(3)
				if (relevant)
					article += "The cyberattacks never stop! [malwarestrain] has been reported breaching ThinkDos\
					-powered systems all over the Frontier with a multitude of complaints from [industry] companies."
				else
					article += "The cyberattacks never stop! [malwarestrain] has been reported breaching ThinkDos\
					-powered systems all over Sol with a multitude of complaints from [industryir] companies."


		if (prob(90)) // hash
			article += "[prob(50) ? "Luckily" : "Thankfully" ], [pick(cybercompany)] has already [prob(50) ? "published" : "analyzed"] [pick(culprit)]'s filehash."
			outhash = "[generateHash(hashchars, 8)]"
		else
			article += "Sample [prob(50) ? "research" : "analysis"] is [pick(undergoing)]."


	proc/generateAuthor()
		// generating author
		switch(rand(1,3))
			if (1)
				author = "[pick(consonants_upper)]. [pick_string_autokey("names/last.txt")]"
			if (2)
				author = "[prob(50) ? pick_string_autokey("names/first_male.txt") : pick_string_autokey("names/first_female.txt")] [pick(consonants_upper)].[prob(50) ? "[pick(consonants_upper)]. " : null] [pick_string_autokey("names/last.txt")]"
			if (3)
				author = "[prob(50) ? pick_string_autokey("names/first_male.txt") : pick_string_autokey("names/first_female.txt")] \"[prob(50) ? pick_string_autokey("names/first_male.txt") : pick_string_autokey("names/first_female.txt")]\" [pick_string_autokey("names/last.txt")]"

	var/spacetime = ""
	// im just copying stuff honestly (from stock market)
	proc/formatSpacetime()
		var/ticksc = round(ticks/100)
		ticksc = ticksc % 100000
		var/ticksp = "[ticksc]"
		while (length(ticksp) < 5)
			ticksp = "0[ticksp]"
		spacetime = "[ticksp]:[time2text(world.realtime, "MM")]:[time2text(world.realtime, "DD")]:[CURRENT_SPACE_YEAR]"

	//proc/formatArticle()
	//	if (spacetime == "")
	//		formatSpacetime()
	//	. = "<div class='article'><div class='headline'>[headline]</div><div class='article-body'>[article]</div><div class='author'>[author]</div><div class='timestamp'>[spacetime]</div></div>"

	//formatArticle()
