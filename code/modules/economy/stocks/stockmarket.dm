
/datum/stock/market
	var/list/datum/stock/ticker/stocks
	var/list/stockBrokers
	var/list/balances
	var/list/last_read

	New()
		..()
		stocks = list()
		stockBrokers = list()
		balances = list()
		last_read = list()
		generateBrokers()
		generateStocks()

	proc/process()
		for (var/datum/stock/ticker/S as anything in stocks)
			S.process()

	proc/balanceLog(whose, net)
		if (!(whose in balances))
			balances[whose] = net
		else
			balances[whose] += net

	proc/generateBrokers()
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

	proc/generateDesignation(name)
		if (length(name) <= 4)
			return uppertext(name)
		var/list/w = splittext(name, " ")
		if (length(w) >= 2)
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

	proc/generateStocks(amt = 15)
		var/list/fruits = list("Banana", "Strawberry", "Watermelon", "Maracuja", "Pomegranate", "Papaya", "Mango", "Tomato", "Conkerberry", "Fig", "Lychee", "Mandarin", "Oroblanco", "Pumpkin", "Rhubarb", "Tamarillo", "Yantok", "Ziziphus")
		var/list/tech_prefix = list("Nano", "Cyber", "Funk", "Astro", "Fusion", "Tera", "Exo", "Star", "Virtual", "Plasma", "Robust", "Bit", "Butt")
		var/list/tech_short = list("soft", "tech", "prog", "tec", "tek", "ware", "", "gadgets", "nics", "tric", "trasen", "tronic", "coin")
		var/list/random_nouns = list("Johnson", "Cluwne", "General", "Specific", "Master", "King", "Queen", "Wayne", "Rupture", "Dynamic", "Massive", "Mega", "Giga", "Certain", "Stale", "State", "National", "International", "Interplanetary", "Sector", "Planet", "Burn", "Robust", "Exotic", "Solar", "Cheesecake")
		var/list/company = list("Company", "Factory", "Incorporated", "Industries", "Group", "Consolidated", "GmbH", "LLC", "Ltd", "Inc.", "Association", "Limited", "Software", "Technology", "Programming", "IT Group", "Electronics", "Nanotechnology", "Farms", "Stores", "Mobile", "Motors", "Electric", "Energy", "Pharmaceuticals", "Communications", "Wholesale", "Holding", "Health", "Machines", "Astrotech", "Gadgets", "Kinetics")

		for (var/i in 1 to amt)
			var/datum/stock/ticker/S = new
			var/sname = ""
			switch (rand(1,6))
				if(1)
					while (sname == "" || sname == "FAG") // honestly it's a 0.6% chance per round this happens - or once in 166 rounds - so i'm accounting for it before someone yells at me
						sname = "[pick(consonants_upper)][pick(vowels_upper)][pick(consonants_upper)]"
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
