/datum/stock/article
	var/headline = "Something big is happening"
	var/subtitle = "Investors panic as stock market collapses"
	var/article = "God, it's going to be fun to randomly generate this."
	var/author = "P. Pubbie"
	var/spacetime = ""
	var/opinion = 0
	var/ticks = 0
	var/datum/stock/ticker/about = null
	var/outlet = ""
	var/static/list/news_outlets = list()
	var/static/list/default_tokens = list( \
		"buy" = list("buy!", "buy, buy, buy!", "get in now!", "to the moon!", "ride the share value to the stars!"), \
		"company" = list("company", "corporation", "conglomereate", "enterprise", "venture"), \
		"complete" = list("complete", "total", "absolute", "incredible"), \
		"country" = list("Space", "Argentina", "Hungary", "United States of America", "United Space", "Space Federation", "Nanotrasen", "The Wizard Federation", "United Kingdom", "Poland", "Denmark", "Sweden", "Serbia", "The European Union", "The Illuminati", "The New World Order", "Eurasian Union", "Asian Union", "United Arab Emirates", "Arabian League", "United States of Africa", "Mars Federation", "Allied Colonies of Jupiter", "Saturn's Ring", "Fringe Republic of Formerly Planet Pluto"), \
		"development" = list("development", "unfolding of events", "turn of events"), \
		"dip" = list("dip", "fall", "rapidly descend", "decrease"), \
		"excited" = list("excited", "euphoric", "exhilarated", "thrilled", "stimulated"), \
		"expand_influence" = list("expands their influence over", "continues to dominate", "looks to gain shares in", "rolls their new product line out in"), \
		"failure" = list("failure", "meltdown", "breakdown", "crash", "defeat", "trainwreck", "wreck"), \
		"famous" = list("famous", "prominent", "leading", "renowned"), \
		"hit_shelves" = list("hit the shelves", "appeared on the market", "came out", "was released"), \
		"industry" = list("industry"), \
		"industrial" = list("industrial"), \
		"jobs" = list("workers"), \
		"negative_outcome" = list("it's not leaving the shelves", "nobody seems to have taken note", "no notable profits have been reported", "it's beginning to look like a huge failure"), \
		"neutral_outcome" = list("it's not lifting off as expected", "it's not selling according to the expectations", "it's only generating enough profit to cover the marketing and manufacturing costs", "it does not look like it will become a massive success"), \
		"positive_outcome" = list("it's already sold out", "it has already sold over one billion units", "suppliers cannot keep up with the wild demand", "several companies using this new technology are already reporting a projected increase in profits"), \
		"resounding" = list("resounding", "tremendous", "total", "massive", "terrific", "colossal"), \
		"rise" = list("rise", "increase", "fly off the positive side of the charts", "skyrocket", "lift off"), \
		"sell" = list("sell!", "sell, sell, sell!", "bail!", "abandon ship!", "get out before it's too late!", "evacuate!", "withdraw!"), \
		"signifying" = list("signifying", "indicating", "displaying the sign of", "displaying"), \
		"sneak_peek" = list("review", "sneak peek", "preview"), \
		"stock_market" = list("stock market", "stock exchange"), \
		"stockholder" = list("stockholder", "shareholder"), \
		"success" = list("success", "triumph", "victory"), \
		"this_time" = list("this week", "last week", "this month", "yesterday", "today", "a few days ago") \
	)

	New()
		..()
		// How we add new news outlets, with decreasing probability to add every article.
		if (!length(news_outlets) || (length(news_outlets) && !prob(100 / (length(news_outlets) + 1))))
			var/ON = generateOutletName()
			if (!(ON in news_outlets))
				news_outlets[ON] = list()
			outlet = ON
		else
			outlet = pick(news_outlets)

		// How we add new authors for news outlets, with decreasing probability to add every article.
		var/list/authors = news_outlets[outlet]
		if (!length(authors) || (length(authors) && !prob(100 / (length(authors) + 1))))
			var/AN = generateAuthorName()
			news_outlets[outlet] += AN
			author = AN
		else
			author = pick(authors)

		ticks = ticker.round_elapsed_ticks

	/// Returns a random news outlet name
	proc/generateOutletName()
		var/list/locations = list("Earth", "Luna", "Mars", "Saturn", "Jupiter", "Uranus", "Pluto", "Europa", "Io", "Phobos", "Deimos", "Space", "Venus", "Neptune", "Mercury", "Kalliope", "Ganymede", "Callisto", "Amalthea", "Himalia")
		var/list/nouns = list("Post", "Herald", "Sun", "Tribune", "Mail", "Times", "Journal", "Report")
		var/list/timely = list("Daily", "Hourly", "Weekly", "Biweekly", "Monthly", "Yearly")

		switch(rand(1,3))
			if (1)
				return "The [pick(locations)] [pick(nouns)]"
			if (2)
				return "The [pick(timely)] [pick(nouns)]"
			if (3)
				return "[pick(locations)] [pick(timely)]"

	/// Returns a random author name
	proc/generateAuthorName()
		switch(rand(1,3))
			if (1)
				return "[pick(consonants_upper)]. [pick_string_autokey("names/last.txt")]"
			if (2)
				return "[prob(50) ? pick_string_autokey("names/first_male.txt") : pick_string_autokey("names/first_female.txt")] [pick(consonants_upper)].[prob(50) ? "[pick(consonants_upper)]. " : null] [pick_string_autokey("names/last.txt")]"
			if (3)
				return "[prob(50) ? pick_string_autokey("names/first_male.txt") : pick_string_autokey("names/first_female.txt")] \"[prob(50) ? pick_string_autokey("names/first_male.txt") : pick_string_autokey("names/first_female.txt")]\" [pick_string_autokey("names/last.txt")]"

	proc/formatSpacetime()
		var/ticksc = round(ticks/100)
		ticksc = ticksc % 100000
		var/ticksp = "[ticksc]"
		while (length(ticksp) < 5)
			ticksp = "0[ticksp]"
		spacetime = "[ticksp][time2text(world.realtime, "MM")][time2text(world.realtime, "DD")][CURRENT_SPACE_YEAR]"

	proc/formatArticle()
		if (spacetime == "")
			formatSpacetime()
		. = "<div class='article'><div class='headline'>[headline]</div><div class='subtitle'>[subtitle]</div><div class='article-body'>[article]</div><div class='author'>[author]</div><div class='timestamp'>[spacetime]</div></div>"

	/// Replaces %tokens% in the string with the various default, industry, or product tokens.
	proc/detokenize(token_string, list/industry_tokens, list/product_tokens = list())
		var/list/T_list = default_tokens.Copy()
		for (var/I in industry_tokens)
			T_list[I] = industry_tokens[I]
		for (var/I in product_tokens)
			T_list[I] = list(product_tokens[I])
		for (var/I in T_list)
			token_string = replacetext(token_string, "%[I]%", pick(T_list[I]))
		return ucfirst(token_string)
