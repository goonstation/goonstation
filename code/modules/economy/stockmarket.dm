proc/consonant()
	var/list/vowels = list(65, 69, 73, 79, 85)
	var/R = rand(65, 90)
	while (R in vowels)
		R = rand(65, 90)
	return ascii2text(R)

proc/vowel()
	return pick("A", "E", "I", "O", "U")

proc/ucfirst(var/S)
	return "[uppertext(ascii2text(text2ascii(S, 1)))][copytext(S, 2)]"

proc/ucfirsts(var/S)
	var/list/L = splittext(S, " ")
	var/list/M = list()
	for (var/P in L)
		M += ucfirst(P)
	return jointext(M, " ")

var/global/list/FrozenAccounts = list()

proc/list_frozen()
	for (var/A in FrozenAccounts)
		boutput(usr, "[A]: [length(FrozenAccounts[A])] borrows")

/datum/article
	var/headline = "Something big is happening"
	var/subtitle = "Investors panic as stock market collapses"
	var/article = "God, it's going to be fun to randomly generate this."
	var/author = "P. Pubbie"
	var/spacetime = ""
	var/opinion = 0
	var/ticks = 0
	var/datum/stock/about = null
	var/outlet = ""
	var/static/list/outlets = list()
	var/static/list/default_tokens = list( \
		"buy" = list("buy!", "buy, buy, buy!", "get in now!", "ride the share value to the stars!"), \
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
		if ((outlets.len && !prob(100 / (outlets.len + 1))) || !outlets.len)
			var/ON = generateOutletName()
			if (!(ON in outlets))
				outlets[ON] = list()
			outlet = ON
		else
			outlet = pick(outlets)

		var/list/authors = outlets[outlet]
		if ((authors.len && !prob(100 / (authors.len + 1))) || !authors.len)
			var/AN = generateAuthorName()
			outlets[outlet] += AN
			author = AN
		else
			author = pick(authors)

		ticks = ticker.round_elapsed_ticks

	proc/generateOutletName()
		var/list/locations = list("Earth", "Luna", "Mars", "Saturn", "Jupiter", "Uranus", "Pluto", "Europa", "Io", "Phobos", "Deimos", "Space", "Venus", "Neptune", "Mercury", "Kalliope", "Ganymede", "Callisto", "Amalthea", "Himalia")
		var/list/nouns = list("Post", "Herald", "Sun", "Tribune", "Mail", "Times", "Journal", "Report")
		var/list/timely = list("Daily", "Hourly", "Weekly", "Biweekly", "Monthly", "Yearly")

		switch(rand(1,2))
			if (1)
				return "The [pick(locations)] [pick(nouns)]"
			if (2)
				return "The [pick(timely)] [pick(nouns)]"

	proc/generateAuthorName()
		switch(rand(1,3))
			if (1)
				return "[consonant()]. [pick_string_autokey("names/last.txt")]"
			if (2)
				return "[prob(50) ? pick_string_autokey("names/first_male.txt") : pick_string_autokey("names/first_female.txt")] [consonant()].[prob(50) ? "[consonant()]. " : null] [pick_string_autokey("names/last.txt")]"
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
		var/output = "<div class='article'><div class='headline'>[headline]</div><div class='subtitle'>[subtitle]</div><div class='article-body'>[article]</div><div class='author'>[author]</div><div class='timestamp'>[spacetime]</div></div>"
		return output

	proc/detokenize(var/token_string, var/list/industry_tokens, var/list/product_tokens = list())
		var/list/T_list = default_tokens.Copy()
		for (var/I in industry_tokens)
			T_list[I] = industry_tokens[I]
		for (var/I in product_tokens)
			T_list[I] = list(product_tokens[I])
		for (var/I in T_list)
			token_string = replacetext(token_string, "%[I]%", pick(T_list[I]))
		return ucfirst(token_string)

/datum/stockEvent
	var/name = "event"
	var/next_phase = 0
	var/datum/stock/company = null
	var/current_title = "A company holding an pangalactic conference in the Seattle Conference Center, Seattle, Earth"
	var/current_desc = "We will continue to monitor their stocks as the situation unfolds."
	var/phase_id = 0
	var/hidden = 0
	var/finished = 0
	var/last_change = 0

	proc/process()
		if (finished)
			return
		if (ticker.round_elapsed_ticks > next_phase)
			transition()

	proc/transition()
	proc/spacetime(var/ticks)
		var/seconds = round(ticks / 10)
		var/minutes = round(seconds / 60)
		seconds -= minutes * 60
		return "[minutes]:[seconds]"

	product
		name = "product"
		var/product_name = ""
		var/datum/article/product_article = null
		var/effect = 0
		New(var/datum/stock/S)
			company = S
			var/mins = rand(5,20)
			next_phase = mins * 600 + (ticker && ticker.round_elapsed_ticks ? ticker.round_elapsed_ticks : 0)
			current_title = "Product demo"
			current_desc = S.industry.detokenize("[S.name] will unveil a new product on an upcoming %industrial% conference held at spacetime [spacetime(next_phase)]")
			S.addEvent(src)


		transition()
			last_change = ticker.round_elapsed_ticks
			switch (phase_id)
				if (0)
					next_phase = ticker.round_elapsed_ticks + rand(300, 600) * 10
					product_name = company.industry.generateProductName(company.name)
					current_title = "Product release: [product_name]"
					current_desc = "[company.name] unveiled their newest product, [product_name], at a conference. Product release is expected to happen at spacetime [spacetime(next_phase)]."
					var/datum/article/A = company.industry.generateInCharacterProductArticle(product_name, company)
					product_article = A
					effect = A.opinion + rand(-1, 1)
					company.affectPublicOpinion(effect)
					phase_id = 1
				if (1)
					finished = 1
					hidden = 1
					company.addArticle(product_article)
					effect += product_article.opinion * 5
					company.affectPublicOpinion(effect)
					phase_id = 2
					company.generateEvent(type)

	bankruptcy
		name = "bankruptcy"
		var/effect = 0
		var/bailout_millions = 0

		New(var/datum/stock/S)
			hidden = 1
			company = S
			var/mins = rand(9,60)
			bailout_millions = rand(70, 190)
			next_phase = mins * 600 + (ticker && ticker.round_elapsed_ticks ? ticker.round_elapsed_ticks : 0)
			current_title = ""
			current_desc = ""
			S.addEvent(src)

		transition()
			switch (phase_id)
				if (0)
					next_phase = ticker.round_elapsed_ticks + rand(300, 600) * 10
					var/datum/article/A = generateBankruptcyArticle()
					if (!A.opinion)
						effect = rand(5) * (prob(50) ? -1 : 1)
					else
						effect = prob(25) ? -A.opinion * rand(8) : A.opinion * rand(4)
					company.addArticle(A)
					company.affectPublicOpinion(rand(-6, -3))
					hidden = 0
					current_title = "Bailout pending due to bankruptcy"
					current_desc = "The government prepared a press release, which will occur at spacetime [spacetime(next_phase)]."
					phase_id = 1
				if (1)
					next_phase = ticker.round_elapsed_ticks + rand(300, 600) * 10
					finished = 1
					if (effect <= -5 && prob(10))
						current_title = "[company.name]: Complete crash"
						current_desc = "The company had gone bankrupt, was not bailed out and could not recover. No further stock trade will take place. All shares in the company are effectively worthless."
						company.bankrupt = 1
						for (var/X in company.shareholders)
							var/amt = company.shareholders[X]
							stockExchange.balanceLog(X, -amt * company.current_value)
						company.shareholders = list()
						company.current_value = 0
						company.borrow_brokers = list()
						stockExchange.generateStocks(1)

					var/bailout = (effect > 0 && prob(80)) || (effect < 0 && prob(20))
					current_title = "[company.name] [bailout ? "bailed out" : "on a painful rebound"]"
					if (bailout)
						current_desc = "The company has been bailed out by the government. Investors are highly optimistic."
						company.affectPublicOpinion(abs(effect) * 2)
					else
						current_desc = "The company was not bailed out, but managed to crawl out of bankruptcy. Stockholder trust is severely dented."
						company.affectPublicOpinion(-abs(effect) / 2)
					company.generateEvent(type)

		proc/generateBankruptcyArticle()
			var/datum/article/A = new
			var/list/bankrupt_reason = list("investor pessimism", "failure of product lines", "economic recession", "overblown inflation", "overblown deflation", "collapsed pyramid schemes", "a Ponzi scheme", "economic terrorism", "extreme hedonism", "unfavourable economic climate", "rampant government corruption", "cartelling competitors", "some total bullshit", "volatile plans")
			A.about = company
			A.headline = pick(	"[company.name] filing for bankruptcy", \
								"[company.name] unable to pay, investors run", \
								"[company.name] crashes, in foreclosure", \
								"[company.name] in dire need of credits")
			A.subtitle = "Investors panic, bailout pending"
			if (prob(15))
				A.opinion = rand(-1, 1)
			var/article = "Another one might bite the dust: [company.current_trend > 0 ? "despite their positive trend" : "in line with their failing model"], [company.name] is files for bankruptcy citing [pick(bankrupt_reason)]. The president of %country% has been asked to bail the company out, "
			if (!A.opinion)
				article += "but no answer has been given by the government to date. Our tip to stay safe is: %sell%"
			else if (A.opinion > 0)
				article += "and the government responded positively. When the share value hits its lowest, it is a safe bet to %buy%"
			else
				article += "but the outlook is not good. For investors, now would be an ideal time to %sell%"
			A.article = A.detokenize(article, company.industry.tokens)
			return A

	arrest
		name = "arrest"
		var/female = 0
		var/tname = "Elvis Presley"
		var/position = "CEO"
		var/offenses = "murder"
		var/effect = 0

		New(var/datum/stock/S)
			hidden = 1
			company = S
			var/mins = rand(10, 35)
			next_phase = mins * 600 + (ticker && ticker.round_elapsed_ticks ? ticker.round_elapsed_ticks : 0)
			current_title = ""
			current_desc = ""
			female = prob(50)
			if (prob(50))
				position = "C[prob(20) ? vowel() : consonant()]O"
			else
				position = ucfirsts(company.industry.detokenize("Lead %industrial% Engineer"))
			offenses = ""
			var/list/O = list("corruption", "murder", "jaywalking", "assault", "battery", "drug possession", "burglary", "theft", "larceny", "bribery", "disorderly conduct", "treason", "sedition", "shoplifting", "tax evasion", "tax fraud", "insurance fraud", "perjury", "kidnapping", "manslaughter", "vandalism", "forgery", "extortion", "embezzlement", "public indecency", "public intoxication", "trespassing", "loitering", "littering", "vigilantism", "squatting", "panhandling")
			do
				var/offense = pick(O)
				O -= offense
				offense = "[prob(20) ? "attempted " : (prob(20) ? "being accessory to " : null)][offense][prob(5) ? " of the [pick("first", "second", "third", "fourth", "fifth", "sixth")] degree" : null]"
				if (offenses == "")
					offenses = offense
				else
					offenses += ", [offense]"
			while (prob(60) && O.len > 2)
			offenses += " and [prob(20) ? "attempted " : null][pick(O)]" // lazy
			S.addEvent(src)

		transition()
			switch (phase_id)
				if (0)
					tname = "[female ? pick_string_autokey("names/first_female.txt") : pick_string_autokey("names/first_male.txt")] [pick_string_autokey("names/last.txt")]"
					next_phase = ticker.round_elapsed_ticks + rand(300, 600) * 10
					var/datum/article/A = generateArrestArticle()
					if (!A.opinion)
						effect = rand(5) * (prob(50) ? -1 : 1)
					else
						effect = prob(25) ? -A.opinion * rand(5) : A.opinion * rand(3)
					company.addArticle(A)
					company.affectPublicOpinion(rand(-3, -1))
					hidden = 0
					current_title = "Trial of [tname] ([position]) scheduled"
					current_desc = "[female ? "She": "He"] has been charged with [offenses]; the trial is scheduled to occur at spacetime [spacetime(next_phase)]."
					phase_id = 1
				if (1)
					next_phase = ticker.round_elapsed_ticks + rand(300, 600) * 10
					finished = 1
					current_title = "[tname] [effect > 0 ? "acquitted" : "found guilty"]"
					if (effect > 0)
						current_desc = "The accused has been acquitted of all charges. Investors optimistic."
					else
						current_desc = "The accused has been found guilty of all charges. Investor trust takes massive hit."
					company.affectPublicOpinion(effect)
					company.generateEvent(type)

		proc/generateArrestArticle()
			var/datum/article/A = new
			A.about = company
			A.headline = company.industry.detokenize(pick( \
								"[tname], [position] of [company.name] arrested", \
								"[position] of [company.name] facing jail time", \
								"[tname] behind bars", \
								"[position] of %industrial% company before trial", \
								"Police arrest [tname] in daring raid", \
								"Job vacancy ahead: [company.name]'s [position] in serious trouble"))
			A.subtitle = "[A.author] reporting directly from the courtroom"
			if (prob(15))
				A.opinion = rand(-1, 1)
			var/article = "[pick("Police", "Law enforcement")] forces issued a statement that [tname], the [position] of [company.name], the %famous% %industrial% %company% was arrested %this_time%. The trial has been scheduled and the statement reports that the arrested individual is being charged with [offenses]. "
			if (!A.opinion)
				article += "While we cannot predict the outcome of this trial, our tip to stay safe is: %sell%"
			else if (A.opinion > 0)
				article += "Our own investigation shows that these charges are baseless and the arrest is most likely a publicity stunt. Our advice? You should %buy%"
			else
				article += "[tname] has a prior history of similar misdeeds and we're confident the charges will stand. For investors, now would be an ideal time to %sell%"
			A.article = A.detokenize(article, company.industry.tokens)
			return A


/datum/stockMarket
	var/list/stocks = list()
	var/list/balances = list()
	var/list/last_read = list()

	New()
		..()
		generateBrokers()
		generateStocks()

	proc/balanceLog(var/whose, var/net)
		if (!(whose in balances))
			balances[whose] = net
		else
			balances[whose] += net

	var/list/stockBrokers = list()
	proc/generateBrokers()
		stockBrokers = list()
		var/list/fnames = list("Goldman", "Edward", "James", "Luis", "Alexander", "Walter", "Eugene", "Mary", "Morgan", "Jane", "Elizabeth", "Xavier", "Hayden", "Samuel", "Lee")
		var/list/names = list("Johnson", "Rothschild", "Sachs", "Stanley", "Hepburn", "Brown", "McColl", "Fischer", "Edwards", "Becker", "Witter", "Walker", "Lambert", "Smith", "Montgomery", "Lynch", "Roosevelt", "Lehman")
		var/list/locations = list("Earth", "Luna", "Mars", "Saturn", "Jupiter", "Uranus", "Pluto", "Europa", "Io", "Phobos", "Deimos", "Space", "Venus", "Neptune", "Mercury", "Kalliope", "Ganymede", "Callisto", "Amalthea", "Himalia")
		var/list/first = list("The", "First", "Premier", "Finest", "Prime")
		var/list/company = list("Investments", "Securities", "Corporation", "Bank", "Brokerage", "& Co.", "Brothers", "& Sons", "Investement Firm", "Union", "Partners", "Capital", "Trade", "Holdings")
		for (var/i = 1, i <= 5, i++)
			var/pname = ""
			switch (rand(1,5))
				if (1)
					pname = "[prob(10) ? pick(first) + " " : null][pick(names)] [pick(company)]"
				if (2)
					pname = "[pick(names)] & [pick(names)][prob(25) ? " " + pick(company) : null]"
				if (3)
					pname = "[prob(45) ? pick(first) + " " : null][pick(locations)] [pick(company)]"
				if (4)
					pname = "[prob(10) ? "The " : null][pick(names)] [pick(locations)] [pick(company)]"
				if (5)
					pname = "[prob(10) ? "The " : null][pick(fnames)] [pick(names)][prob(10) ? " " + pick(company) : null]"
			if (pname in stockBrokers)
				i--
				continue
			stockBrokers += pname

	proc/generateDesignation(var/name)
		if (length(name) <= 4)
			return uppertext(name)
		var/list/w = splittext(name, " ")
		if (w.len >= 2)
			var/d = ""
			for (var/i = 1; i <= min(5, w.len), i++)
				d += uppertext(ascii2text(text2ascii(w[i], 1)))
			return d
		else
			var/d = uppertext(ascii2text(text2ascii(name, 1)))
			for (var/i = 2; i <= length(name); i++)
				if (prob(100 / i))
					d += uppertext(ascii2text(text2ascii(name, i)))
			return d

	proc/generateStocks(var/amt = 15)
		var/list/fruits = list("Banana", "Strawberry", "Watermelon", "Maracuja", "Pomegranate", "Papaya", "Mango", "Tomato", "Conkerberry", "Fig", "Lychee", "Mandarin", "Oroblanco", "Pumpkin", "Rhubarb", "Tamarillo", "Yantok", "Ziziphus")
		var/list/tech_prefix = list("Nano", "Cyber", "Funk", "Astro", "Fusion", "Tera", "Exo", "Star", "Virtual", "Plasma", "Robust", "Bit", "Butt")
		var/list/tech_short = list("soft", "tech", "prog", "tec", "tek", "ware", "", "gadgets", "nics", "tric", "trasen", "tronic", "coin")
		var/list/random_nouns = list("Johnson", "Cluwne", "General", "Specific", "Master", "King", "Queen", "Wayne", "Rupture", "Dynamic", "Massive", "Mega", "Giga", "Certain", "Stale", "State", "National", "International", "Interplanetary", "Sector", "Planet", "Burn", "Robust", "Exotic", "Solar", "Cheesecake")
		var/list/company = list("Company", "Factory", "Incorporated", "Industries", "Group", "Consolidated", "GmbH", "LLC", "Ltd", "Inc.", "Association", "Limited", "Software", "Technology", "Programming", "IT Group", "Electronics", "Nanotechnology", "Farms", "Stores", "Mobile", "Motors", "Electric", "Energy", "Pharmaceuticals", "Communications", "Wholesale", "Holding", "Health", "Machines", "Astrotech", "Gadgets", "Kinetics")
		for (var/i = 1, i <= amt, i++)
			var/datum/stock/S = new
			var/sname = ""
			switch (rand(1,6))
				if(1)
					while (sname == "" || sname == "FAG") // honestly it's a 0.6% chance per round this happens - or once in 166 rounds - so i'm accounting for it before someone yells at me
						sname = "[consonant()][vowel()][consonant()]"
				if (2)
					sname = "[pick(tech_prefix)][pick(tech_short)][prob(20) ? " " + pick(company) : null]"
				if (3 to 4)
					var/fruit = pick(fruits)
					fruits -= fruit
					sname = "[prob(10) ? "The " : null][fruit][prob(40) ? " " + pick(company): null]"
				if (5 to 6)
					var/pname = pick(random_nouns)
					random_nouns -= pname
					switch (rand(1,3))
						if (1)
							sname = "[pname] & [pname]"
						if (2)
							sname = "[pname] [pick(company)]"
						if (3)
							sname = "[pname]"
			S.name = sname
			S.short_name = generateDesignation(S.name)
			S.current_value = rand(10, 125)
			var/dv = rand(10, 40) / 10
			S.fluctuational_coefficient = prob(50) ? (1 / dv) : dv
			S.average_optimism = rand(-10, 10) / 100
			S.optimism = S.average_optimism + (rand(-40, 40) / 100)
			S.current_trend = rand(-200, 200) / 10
			S.last_trend = S.current_trend
			S.disp_value_change = rand(-1, 1)
			S.speculation = rand(-20, 20)
			S.average_shares = round(rand(500, 10000) / 10)
			S.outside_shareholders = rand(1000, 30000)
			S.available_shares = rand(200000, 800000)
			S.fluctuation_rate = rand(6, 20)
			S.generateIndustry()
			S.generateEvents()
			stocks += S
			last_read[S] = list()

	proc/process()
		for (var/datum/stock/S in stocks)
			S.process()


var/global/datum/stockMarket/stockExchange = new

/datum/borrow
	var/broker = ""
	var/borrower = ""
	var/datum/stock/stock = null
	var/lease_expires = 0
	var/lease_time = 0
	var/grace_time = 0
	var/grace_expires = 0
	var/share_amount = 0
	var/share_debt = 0
	var/deposit = 0
	var/offer_expires = 0

/datum/industry
	var/name = "Industry"
	var/list/tokens = list()

	var/list/title_templates = list("The brand new %product_name% by %company_name% will revolutionize %industry%", \
									"%jobs% rejoice as %product_name% hits shelves", \
									"Does %product_name% threaten to reorganize the %industrial% status quo?")

	var/list/title_templates_neutral = list("%product_name%: as if nothing happened", \
											"Nothing new but the name: %product_name% not quite exciting %jobs%", \
											"Same old %company_name%, same old product")

	var/list/title_templates_bad = list("%product_name% shaping up to be the disappointment of the century", \
										"Recipe for disaster: %company_name% releases %product_name%", \
										"Atrocious quality - %jobs% boycott %product_name%")

	var/list/title_templates_ooc = list("%company_name% is looking to enter the %industry% playing field with %product_name%", \
										"%company_name% broadens spectrum, %product_name% is their latest and greatest")
	var/list/subtitle_templates = list(	"%author% investigates whether or not you should invest!", \
										"%outlet%'s very own %author% takes it to the magnifying glass", \
										"%outlet% lets you know if you should use it", \
										"Read our top tips for investors", \
										"%author% wants you to know if it's a safe bet to buy")

	proc/generateProductName(var/company_name)
	proc/generateInCharacterProductArticle(var/product_name, var/datum/stock/S)
		var/datum/article/A = new
		var/list/add_tokens = list("company_name" = S.name, "product_name" = product_name, "outlet" = A.outlet, "author" = A.author)
		A.about = S
		A.opinion = rand(-1, 1)

		A.subtitle = A.detokenize(pick(subtitle_templates), tokens, add_tokens)
		var/article = {"%company_name% %expand_influence% %industry%. [ucfirst(product_name)] %hit_shelves% %this_time% "}
		if (A.opinion > 0)
			A.headline = A.detokenize(pick(title_templates), tokens, add_tokens)
			article += "but %positive_outcome%, %signifying% the %resounding% %success% the product is. The %stock_market% is %excited% over this %development%, and %stockholder% optimism is expected to %rise% as well as the stock value. Our advice: %buy%."
		else if (A.opinion == 0)
			A.headline = A.detokenize(pick(title_templates_neutral), tokens, add_tokens)
			article += "but %neutral_outcome%. For the average %stockholder%, no significant change on the market will be apparent over this %development%. Our advice is to continue investing as if this product was never released."
		else
			A.headline = A.detokenize(pick(title_templates_bad), tokens, add_tokens)
			article += "but %negative_outcome%. Following this %complete% %failure%, %stockholder% optimism and stock value are projected to %dip%. Our advice: %sell%."
		A.article = A.detokenize(article, tokens, add_tokens)
		return A

	proc/detokenize(var/str)
		for (var/T in tokens)
			str = replacetext(str, "%[T]%", pick(tokens[T]))
		return str

	agriculture
		name = "Agriculture"
		tokens = list( \
			"industry" = list("agriculture", "farming", "agronomy", "horticulture"), \
			"industrial" = list("agricultural", "agronomical", "agrarian", "horticultural"), \
			"jobs" = list("farmers", "agricultural experts", "agricultural workers", "combine operators")
		)

		title_templates = list(	"The brand new %product_name% by %company_name% will revolutionize %industry%", \
								"%jobs% rejoice as %product_name% hits shelves", \
								"Does %product name% threaten to reorganize the %industrial% status quo?", \
								"Took it for a field trip: our first %sneak_peek% of %product_name%.", \
								"Reaping the fruits of %product_name% - %sneak_peek% by %author%", \
								"Cultivating a new %industrial% future with %product_name%", \
								"%company_name% grows and thrives: %product_name% now on the farmer's market", \
								"It's almost harvest season: %product_name% promises to ease your life", \
								"Become the best on the farmer's market with %product_name%", \
								"%product_name%: a gene-modified reimagination of an age-old classic")

		title_templates_ooc = list(	"%company_name% is looking to enter the %industry% playing field with %product_name%", \
									"A questionable decision: %product_name% grown on the soil of %company_name%", \
									"%company_name% broadens spectrum, %product_name% is their latest and greatest", \
									"Will %company_name% grow on %industrial% wasteland? Owners of %product_name% may decide", \
									"%company_name% looking to reap profits off the %industrial% sector with %product_name%")

		generateProductName(var/company_name)
			var/list/products = list("combine harvester", "cattle prod", "scythe", "plough", "sickle", "cloche", "loy", "spade", "hoe")
			var/list/prefix = list("[company_name]'s ", "the [company_name] ", "the fully automatic ", "the full-duplex ", "the semi-automatic ", "the drone-mounted ", "the industry-leading ", "the world-class ")
			var/list/suffix = list(" of farming", " multiplex", " +[rand(1,15)]", " [consonant()][rand(1000, 9999)]", " hybrid", " maximus", " extreme")
			return "[pick(prefix)][pick(products)][pick(suffix)]"



	it
		name = "Information Technology"
		tokens = list( \
			"industry" = list("information technology", "computing", "computer industry"), \
			"industrial" = list("information technological", "computing", "computer industrial"), \
			"jobs" = list("coders", "electricians", "engineers", "programmers", "devops experts", "developers")
		)

		proc/latin_number(n)
			if (n < 20 || !(n % 10))
				switch(n)
					if (0) return "Nihil"
					if (1) return "Unus"
					if (2) return "Duo"
					if (3) return "Tres"
					if (4) return "Quattour"
					if (5) return "Quinque"
					if (6) return "Sex"
					if (7) return "Septem"
					if (8) return "Octo"
					if (9) return "Novem"
					if (10) return "Decim"
					if (11) return "Undecim"
					if (12) return "Duodecim"
					if (13) return "Tredecim"
					if (14) return "Quattourdecim"
					if (15) return "Quindecim"
					if (16) return "Sedecim"
					if (17) return "Septdecim"
					if (18) return "Duodeviginti"
					if (19) return "Undeviginti"
					if (20) return "Viginti"
					if (30) return "Triginta"
					if (40) return "Quadriginta"
					if (50) return "Quinquaginta"
					if (60) return "Sexaginta"
					if (70) return "Septuaginta"
					if (80) return "Octoginta"
					if (90) return "Nonaginta"
			else
				return "[latin_number(n - (n % 10))] [lowertext(latin_number(n % 10))]"

		generateProductName(var/company_name)
			var/list/products = list("computer", "laptop", "keyboard", "memory card", "display", "operating system", "processor", "graphics card", "nanobots", "power supply")
			var/list/prefix = list("the [company_name] ", "the high performance ", "the mobile ", "the portable ", "the professional ", "the extreme ", "the incredible ", "the blazing fast ", "the bleeding edge ", null)
			var/L = pick(consonant(), "Seed ", "Radiant ", "Celery ", "Pentathon ", "Athlete ", "Phantom ", "Semper Fi ")
			var/N = rand(0,99)
			var/prefix2 = "[L][N][prob(5) ? " " + latin_number(N) : null]"
			return "[pick(prefix)][prefix2] [pick(products)]"

	communications
		name = "Communications"
		tokens = list( \
			"industry" = list("telecommunications"), \
			"industrial" = list("telecommunicational"), \
			"jobs" = list("electrical engineers", "microengineers")
		)

		generateProductName(var/company_name)
			var/list/products = list("mobile phone", "PDA", "tablet computer")
			var/list/prefix = list("the [company_name] ", "the high performance ", "the mobile ", "the portable ", "the professional ", "the extreme ", "the incredible ", "the blazing fast ", "the bleeding edge ", null)
			var/L = pick("[lowertext(consonant())]Phone ", "Universe ", "Xperience ", "Next ", "Engin Y ", "Cyborg ", "[consonant()]")
			var/N = rand(1,99)
			var/prefix2 = "[L][N][prob(25) ? pick(" Tiny", " Mini", " Micro", " Slim", " Water", " Air", " Fire", " Earth", " Nano", " Pico", " Femto", " Planck") : null]"
			return "[pick(prefix)][prefix2] [pick(products)]"

	health
		name = "Medicine"
		tokens = list( \
			"industry" = list("medicine"), \
			"industrial" = list("medicinal"), \
			"jobs" = list("doctors", "nurses", "psychologists", "psychiatrists", "diagnosticians")
		)

		generateProductName(var/company_name)
			var/list/prefix = list("amino", "nucleo", "nitro", "panto", "meth", "eth", "as", "algo", "coca", "hero", "morph", "trinitro", "prop", "but", "acet", "acyclo", "lansop", "dyclo", "hydro", "oxycod", "vicod")
			var/list/suffix = list("phen", "pirin", "pyrine", "ane", "amphetamine", "prazoline", "ine", "yl", "amine", "aminophen", "one", "ide", "phenate", "anol", "toulene", "glycerine", "vir")
			var/list/uses = list("antidepressant", "analgesic", "anesthetic", "antiretroviral", "antiviral", "antibiotic", "cough drop", "depressant", "hangover cure", "homeopathic", "fertility drug", "hypnotic", "narcotic", "laxative", "multivitamin", "purgative", "relaxant", "steroid", "sleeping pill", "suppository", "traquilizer")
			return "[pick(prefix)][pick(suffix)], the [pick(uses)]"

	consumer
		name = "Consumer"
		tokens = list( \
			"industry" = list("shops", "stores"), \
			"industrial" = list("consumer industrial"), \
			"jobs" = list("shopkeepers", "checkout machine operators", "manual daytime hygiene engineers", "janitors")
		)

		generateProductName(var/company)
			var/list/meat = list("chicken", "beef", "seal", "monkey", "goat", "insect", "pigeon", "human", "walrus", "wendigo", "bear", "horse", "turkey", "pork", "shellfish", "starfish", "mimic", "mystery")
			var/list/qualifier = list("synthetic", "organic", "bio", "diet", "sugar-free", "paleolithic", "homeopathic", "recycled", "reclaimed", "vat-grown")
			return "the [pick(qualifier)] [pick(meat)] meat product line"

//#define FLUCTUATION_DEBUG
/datum/stock
	var/name = "Stock"
	var/short_name = "STK"
	var/desc = "A company that does not exist."
	var/list/values = list()
	var/current_value = 100
	var/last_value = 100
	var/list/products = list()

	var/performance = 0						// The current performance of the company. Tends itself to 0 when no events happen.

	// These variables determine standard fluctuational patterns for this stock.
	var/fluctuational_coefficient = 1		// How much the price fluctuates on an average daily basis
	var/average_optimism = 0				// The history of shareholder optimism of this stock
	var/current_trend = 0
	var/last_trend = 0
	var/speculation = 0
	var/bankrupt = 0

	var/disp_value_change = 0
	var/optimism = 0
	var/last_unification = 0
	var/average_shares = 100
	var/outside_shareholders = 10000		// The amount of offstation people holding shares in this company. The higher it is, the more fluctuation it causes.
	var/available_shares = 500000

	var/list/borrow_brokers = list()
	var/list/shareholders = list()
	var/list/borrows = list()
	var/list/events = list()
	var/list/articles = list()
	var/fluctuation_rate = 15
	var/fluctuation_counter = 0
	var/datum/industry/industry = null

	proc/addEvent(var/datum/stockEvent/E)
		if (!(E in events))
			events += E

	proc/addArticle(var/datum/article/A)
		if (!(A in articles))
			articles.Insert(1, A)
		A.ticks = ticker.round_elapsed_ticks

	proc/generateEvents()
		var/list/types = childrentypesof(/datum/stockEvent)
		for (var/T in types)
			generateEvent(T)

	proc/generateEvent(var/T)
		var/datum/stockEvent/E = new T(src)
		addEvent(E)

	proc/affectPublicOpinion(var/boost)
		optimism += rand(0, 500) / 500 * boost
		average_optimism += rand(0, 150) / 5000 * boost
		speculation += rand(-5, 25) / 10 * boost
		performance += rand(0, 110) / 100 * boost

	proc/generateIndustry()
		if (findtext(name, "Farms"))
			industry = new /datum/industry/agriculture
		else if (findtext(name, "Software") || findtext(name, "Programming")  || findtext(name, "IT Group") || findtext(name, "Electronics") || findtext(name, "Electric") || findtext(name, "Nanotechnology"))
			industry = new /datum/industry/it
		else if (findtext(name, "Mobile") || findtext(name, "Communications"))
			industry = new /datum/industry/communications
		else if (findtext(name, "Pharmaceuticals") || findtext(name, "Health"))
			industry = new /datum/industry/health
		else if (findtext(name, "Wholesale") || findtext(name, "Stores"))
			industry = new /datum/industry/consumer
		else
			var/ts = childrentypesof(/datum/industry)
			var/in_t = pick(ts)
			industry = new in_t
		for (var/i = 0, i < rand(2, 5), i++)
			products += industry.generateProductName(name)

	proc/frc(amt)
		var/shares = available_shares + outside_shareholders * average_shares
		var/fr = amt / 100 / shares * fluctuational_coefficient * fluctuation_rate * max(-(current_trend / 100), 1)
#ifdef FLUCTUATION_DEBUG
		boutput(world, "fr = [amt] / 100 / [shares] * [fluctuational_coefficient] * [fluctuation_rate] * [max(-(current_trend / 5), 1)] = [fr]")
#endif
		if (fr < 0 && speculation < 0 || fr > 0 && speculation > 0)
			fr *= max(abs(speculation) / 5, 1)
#ifdef FLUCTUATION_DEBUG
			boutput(world, "Speculation is [speculation], boost is [max(abs(speculation) / 5, 1)], value is now [fr]")
#endif
		else
			fr /= max(abs(speculation) / 5, 1)
#ifdef FLUCTUATION_DEBUG
			boutput(world, "Speculation is [speculation], penalty is [max(abs(speculation) / 5, 1)], value is now [fr]")
#endif
		return fr

	proc/supplyGrowth(amt)
		var/fr = frc(amt)
		available_shares += amt
#ifdef FLUCTUATION_DEBUG
		boutput(world, "Supply change of [amt]; fluctuation rate coefficient [fr].")
#endif
		if (abs(fr) < 0.0001)
#ifdef FLUCTUATION_DEBUG
			boutput(world, "Too unsubstantial change.")
#endif
			return
		current_value -= fr * current_value

	proc/supplyDrop(amt)
		supplyGrowth(-amt)

	proc/fluctuate()
		var/change = rand(-100, 100) / 10 + optimism * rand(200) / 10
		optimism -= (optimism - average_optimism) * (rand(10,80) / 1000)
		var/shift_score = change + current_trend
#ifdef FLUCTUATION_DEBUG
		boutput(world, "Optimism: [optimism]. Change: [change]. Current trend: [current_trend]. Shift score: [shift_score].")
#endif
		var/as_score = abs(shift_score)
		var/sh_change_dev = rand(-10, 10) / 10
#ifdef FLUCTUATION_DEBUG
		boutput(world, "Shareholder change percentage: [shift_score] / [as_score + 1000] + [sh_change_dev]")
#endif
		var/sh_change = shift_score / (as_score + 100) + sh_change_dev
		var/shareholder_change = round(sh_change)
#ifdef FLUCTUATION_DEBUG
		boutput(world, "Absolute shareholder change: [sh_change] * [outside_shareholders] = [shareholder_change]")
#endif
		outside_shareholders += shareholder_change
		var/share_change = shareholder_change * average_shares
#ifdef FLUCTUATION_DEBUG
		boutput(world, "This adds up to [shareholder_change] * [average_shares] = [share_change] change of shares")
#endif
		if (as_score > 20 && prob(as_score / 4))
			var/avg_change_dev = rand(-10, 10) / 10
#ifdef FLUCTUATION_DEBUG
			boutput(world, "Average shares change percentage: [shift_score] / [as_score + 5000] + [avg_change_dev]")
#endif
			var/avg_change = shift_score / (as_score + 100) + avg_change_dev
#ifdef FLUCTUATION_DEBUG
			boutput(world, "Average shares change: [avg_change] * [average_shares] = [avg_change * average_shares]")
#endif
			average_shares += avg_change
			share_change += outside_shareholders * avg_change

#ifdef FLUCTUATION_DEBUG
		boutput(world, "Total shares bought by shareholders: [share_change]")
#endif
		var/cv = last_value
		supplyDrop(share_change)
		available_shares += share_change // temporary

		if (prob(25))
			average_optimism = max(min(average_optimism + (rand(-3, 3) - current_trend * 0.15) / 100, 1), -1)

		var/aspec = abs(speculation)
		if (prob((aspec - 75) * 2))
			speculation += rand(-2, 2)
		else
			if (prob(50))
				speculation += rand(-2, 2)
			else
				speculation += rand(-200, 0) / 1000 * speculation
				if (prob(1) && prob(5)) // pop that bubble
					speculation += rand(-2000, 0) / 1000 * speculation

		current_value += (speculation / rand(10000, 25000) + performance / rand(100, 800)) * current_value
		if (current_value < 5)
			current_value = 5

		if (performance != 0)
			performance = rand(900,1050) / 1000 * performance
			if (abs(performance) < 0.2)
				performance = 0

		disp_value_change = (cv < current_value) ? 1 : ((cv > current_value) ? -1 : 0)
		last_value = current_value
		if (values.len >= 50)
			values.Cut(1,2)
		values += current_value

		if (current_value < 10)
			unifyShares()

//		if (available_shares < 200000 || (available_shares < 400000 && prob((400000 - available_shares) / 2000)) || average_shares < 25 || (average_shares < 50 && prob(50 - average_shares) * 4))
//			splitStock()
		last_trend = current_trend
		current_trend += rand(-200, 200) / 100 + optimism * rand(200) / 10 + max(50 - abs(speculation), 0) / 50 * rand(0, 200) / 1000 * (-current_trend) + max(speculation - 50, 0) * rand(0, 200) / 1000 * speculation / 400

	proc/unifyShares()
		for (var/I in shareholders)
			var/shr = shareholders[I]
			if (shr % 2)
				sellShares(I, 1)
			shr -= 1
			shareholders[I] /= 2
			if (!shareholders[I])
				shareholders -= I
		for (var/datum/borrow/B in borrow_brokers)
			B.share_amount = round(B.share_amount / 2)
			B.share_debt = round(B.share_debt / 2)
		for (var/datum/borrow/B in borrows)
			B.share_amount = round(B.share_amount / 2)
			B.share_debt = round(B.share_debt / 2)
		average_shares /= 2
		available_shares /= 2
		current_value *= 2
		last_unification = ticker.round_elapsed_ticks
		// @todo crash if too little shares remain

	proc/process()
		for (var/datum/borrow/borrow in borrows)
			if (ticker.round_elapsed_ticks > borrow.grace_expires)
				modifyAccount(borrow.borrower, -max(current_value * borrow.share_debt, 0), 1)
				borrows -= borrow
				if (borrow.borrower in FrozenAccounts)
					FrozenAccounts[borrow.borrower] -= borrow
					if (length(FrozenAccounts[borrow.borrower]) == 0)
						FrozenAccounts -= borrow.borrower
				qdel(borrow)
			else if (ticker.round_elapsed_ticks > borrow.lease_expires)
				if (borrow.borrower in shareholders)
					var/amt = shareholders[borrow.borrower]
					if (amt > borrow.share_debt)
						shareholders[borrow.borrower] -= borrow.share_debt
						borrows -= borrow
						if (borrow.borrower in FrozenAccounts)
							FrozenAccounts[borrow.borrower] -= borrow
						if (length(FrozenAccounts[borrow.borrower]) == 0)
							FrozenAccounts -= borrow.borrower
						qdel(borrow)
					else
						shareholders -= borrow.borrower
						borrow.share_debt -= amt
		if (bankrupt)
			return
		for (var/datum/borrow/borrow in borrow_brokers)
			if (borrow.offer_expires < ticker.round_elapsed_ticks)
				borrow_brokers -= borrow
				qdel(borrow)
		if (prob(1) && prob(3))
			generateBrokers()
		fluctuation_counter++
		if (fluctuation_counter >= fluctuation_rate)
			for (var/datum/stockEvent/E in events)
				E.process()
			fluctuation_counter = 0
			fluctuate()

	proc/generateBrokers()
		if (borrow_brokers.len > 2)
			return
		if (!stockExchange.stockBrokers.len)
			stockExchange.generateBrokers()
		var/broker = pick(stockExchange.stockBrokers)
		var/datum/borrow/B = new
		B.broker = broker
		B.stock = src
		B.lease_time = rand(4, 7) * 600
		B.grace_time = rand(1, 3) * 600
		B.share_amount = rand(1, 10) * 100
		B.deposit = rand(20, 70) / 100
		B.share_debt = B.share_amount
		B.offer_expires = rand(5, 10) * 600 + ticker.round_elapsed_ticks
		borrow_brokers += B

	proc/modifyAccount(whose, by, force=0)
		var/datum/data/record/B = FindBankAccountByName(whose)
		if (B)
			if (by < 0 && B.fields["current_money"] + by < 0 && !force)
				return 0
			B.fields["current_money"] += by
			stockExchange.balanceLog(whose, by)
			return 1
		return 0

	proc/borrow(var/datum/borrow/B, var/who)
		if (B.lease_expires)
			return 0
		B.lease_expires = ticker.round_elapsed_ticks + B.lease_time
		var/old_d = B.deposit
		var/d_amt = B.deposit * current_value * B.share_amount
		if (!modifyAccount(who, -d_amt))
			B.lease_expires = 0
			B.deposit = old_d
			return 0
		B.deposit = d_amt
		if (!(who in shareholders))
			shareholders[who] = B.share_amount
		else
			shareholders[who] += B.share_amount
		borrow_brokers -= B
		borrows += B
		B.borrower = who
		B.grace_expires = B.lease_expires + B.grace_time
		if (!(who in FrozenAccounts))
			FrozenAccounts[who] = list(B)
		else
			FrozenAccounts[who] += B
		return 1

	proc/buyShares(var/who, var/howmany)
		if (howmany <= 0)
			return
		howmany = round(howmany)
		var/loss = howmany * current_value
		if (available_shares < howmany)
			return 0
		if (modifyAccount(who, -loss))
			supplyDrop(howmany)
			if (!(who in shareholders))
				shareholders[who] = howmany
			else
				shareholders[who] += howmany
			return 1
		return 0

	proc/sellShares(var/whose, var/howmany)
		if (howmany < 0)
			return
		howmany = round(howmany)
		var/gain = howmany * current_value
		if (shareholders[whose] < howmany)
			return 0
		if (modifyAccount(whose, gain))
			supplyGrowth(howmany)
			shareholders[whose] -= howmany
			if (shareholders[whose] <= 0)
				shareholders -= whose
			return 1
		return 0

	proc/displayValues(var/mob/user)
		user.Browse(plotBarGraph(values, "[name] share value per share"), "window=stock_[name];size=450x450")

/proc/plotBarGraph(var/list/points, var/base_text, var/width=400, var/height=400)
	var/output = "<table style='border:1px solid black; border-collapse: collapse; width: [width]px; height: [height]px'>"
	if (points.len && height > 20 && width > 20)
		var/min = points[1]
		var/max = points[1]
		for (var/v in points)
			if (v < min)
				min = v
			if (v > max)
				max = v
		var/cells = (height - 20) / 20
		if (cells > round(cells))
			cells = round(cells) + 1
		var/diff = max - min
		var/ost = diff / cells
		if (min > 0)
			min = max(min - ost, 0)
		diff = max - min
		ost = diff / cells
		var/cval = max
		var/cwid = width / (points.len + 1)
		for (var/y = cells, y > 0, y--)
			if (y == cells)
				output += "<tr>"
			else
				output += "<tr style='border:none; border-top:1px solid #00ff00; height: 20px'>"
			for (var/x = 0, x <= points.len, x++)
				if (x == 0)
					output += "<td style='border:none; height: 20px; width: [cwid]px; font-size:10px; color:#00ff00; background:black; text-align:right; vertical-align:bottom'>[round(cval - ost)]</td>"
				else
					var/v = points[x]
					if (v >= cval)
						output += "<td style='border:none; height: 20px; width: [cwid]px; background:#0000ff'>&nbsp;</td>"
					else
						output += "<td style='border:none; height: 20px; width: [cwid]px; background:black'>&nbsp;</td>"
			output += "</tr>"
			cval -= ost
		output += "<tr><td style='font-size:10px; height: 20px; width: 100%; background:black; color:green; text-align:center' colspan='[points.len + 1]'>[base_text]</td></tr>"
	else
		output += "<tr><td style='width:[width]px; height:[height]px; background: black'></td></tr>"
		output += "<tr><td style='font-size:10px; background:black; color:green; text-align:center'>[base_text]</td></tr>"

	return "[output]</table>"

