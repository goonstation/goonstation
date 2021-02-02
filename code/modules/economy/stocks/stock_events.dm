/// Stock market events that influence the market
ABSTRACT_TYPE(/datum/stock/event)
/datum/stock/event
	var/name = "event"
	var/next_phase = 0
	var/datum/stock/ticker/company = null
	var/current_title = "A company holding an pangalactic conference in the Seattle Conference Center, Seattle, Earth"
	var/current_desc = "We will continue to monitor their stocks as the situation unfolds."
	var/phase_id = 0
	var/hidden = FALSE
	var/finished = 0
	var/last_change = 0

	proc/process()
		if (finished)
			return
		if (ticker.round_elapsed_ticks > next_phase)
			transition()

	proc/transition()
		return

	proc/spacetime(ticks)
		var/seconds = round(ticks / 10)
		var/minutes = round(seconds / 60)
		seconds -= minutes * 60
		return "[minutes]:[seconds]"

/datum/stock/event/product
	name = "product"
	var/product_name = ""
	var/datum/stock/article/product_article = null
	var/effect = 0

	New(datum/stock/ticker/S)
		..()
		company = S
		var/mins = rand(5,20)
		next_phase = mins * 600 + (ticker?.round_elapsed_ticks ? ticker.round_elapsed_ticks : 0)
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
				var/datum/stock/article/A = company.industry.generateInCharacterProductArticle(product_name, company)
				product_article = A
				effect = A.opinion + rand(-1, 1)
				company.affectPublicOpinion(effect)
				phase_id = 1
			if (1)
				finished = 1
				hidden = TRUE
				company.addArticle(product_article)
				effect += product_article.opinion * 5
				company.affectPublicOpinion(effect)
				phase_id = 2
				company.generateEvent(type)

/datum/stock/event/bankruptcy
	name = "bankruptcy"
	var/effect = 0
	var/bailout_millions = 0

	New(datum/stock/ticker/S)
		..()
		hidden = TRUE
		company = S
		var/mins = rand(9,60)
		bailout_millions = rand(70, 190)
		next_phase = mins * 600 + (ticker?.round_elapsed_ticks ? ticker.round_elapsed_ticks : 0)
		current_title = ""
		current_desc = ""
		S.addEvent(src)

	transition()
		switch (phase_id)
			if (0)
				next_phase = ticker.round_elapsed_ticks + rand(300, 600) * 10
				var/datum/stock/article/A = generateBankruptcyArticle()
				if (!A.opinion)
					effect = rand(5) * (prob(50) ? -1 : 1)
				else
					effect = prob(25) ? -A.opinion * rand(8) : A.opinion * rand(4)
				company.addArticle(A)
				company.affectPublicOpinion(rand(-6, -3))
				hidden = FALSE
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
		var/datum/stock/article/A = new
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

/datum/stock/event/arrest
	name = "arrest"
	var/female = 0
	var/tname = "Elvis Presley"
	var/position = "CEO"
	var/offenses = "murder"
	var/effect = 0

	New(datum/stock/ticker/S)
		..()
		hidden = TRUE
		company = S
		var/mins = rand(10, 35)
		next_phase = mins * 600 + (ticker?.round_elapsed_ticks ? ticker.round_elapsed_ticks : 0)
		current_title = ""
		current_desc = ""
		female = prob(50)
		if (prob(75))
			position = "C[prob(20) ? pick(vowels_upper) : pick(consonants_upper)]O"
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
				var/datum/stock/article/A = generateArrestArticle()
				if (!A.opinion)
					effect = rand(5) * (prob(50) ? -1 : 1)
				else
					effect = prob(25) ? -A.opinion * rand(5) : A.opinion * rand(3)
				company.addArticle(A)
				company.affectPublicOpinion(rand(-3, -1))
				hidden = FALSE
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
		var/datum/stock/article/A = new
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
