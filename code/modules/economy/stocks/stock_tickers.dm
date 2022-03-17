//#define FLUCTUATION_DEBUG

/// stonks
/datum/stock/ticker
	var/name = "Stock"
	var/short_name = "STK"
	var/desc = "A company that does not exist."
	var/list/values = list()
	var/current_value = 100
	var/last_value = 100
	var/list/products = list()

	/// The current performance of the company. Tends itself to 0 when no events happen.
	var/performance = 0
	/// How much the price fluctuates on an average daily basis
	var/fluctuational_coefficient = 1
	/// The history of shareholder optimism of this stock
	var/average_optimism = 0
	var/current_trend = 0
	var/last_trend = 0
	var/speculation = 0
	var/bankrupt = FALSE

	var/disp_value_change = 0
	var/optimism = 0
	var/last_unification = 0
	var/average_shares = 100
	/// The amount of offstation people holding shares in this company. The higher it is, the more fluctuation it causes.
	var/outside_shareholders = 10000
	var/available_shares = 500000

	var/list/borrow_brokers = list()
	var/list/shareholders = list()
	var/list/borrows = list()
	var/list/events = list()
	var/list/datum/stock/article/articles = list()
	var/fluctuation_rate = 15
	var/fluctuation_counter = 0
	var/datum/stock/industry/industry = null

	proc/addEvent(datum/stock/event/E)
		events |= E

	proc/addArticle(datum/stock/article/A)
		if (!(A in articles)) // we need to append new articles to the top
			articles.Insert(1, A)
		A.ticks = ticker.round_elapsed_ticks

	proc/generateEvents()
		for (var/type in concrete_typesof(/datum/stock/event))
			generateEvent(type)

	proc/generateEvent(type)
		var/datum/stock/event/E = new type(src)
		addEvent(E)

	proc/affectPublicOpinion(boost)
		optimism += rand(0, 500) / 500 * boost
		average_optimism += rand(0, 150) / 5000 * boost
		speculation += rand(-5, 25) / 10 * boost
		performance += rand(0, 110) / 100 * boost

	proc/generateIndustry()
		if (findtext(name, "Farms"))
			industry = new /datum/stock/industry/agriculture
		else if (findtext(name, "Software") || findtext(name, "Programming")  || findtext(name, "IT Group") || findtext(name, "Electronics") || findtext(name, "Electric") || findtext(name, "Nanotechnology"))
			industry = new /datum/stock/industry/it
		else if (findtext(name, "Mobile") || findtext(name, "Communications"))
			industry = new /datum/stock/industry/communications
		else if (findtext(name, "Pharmaceuticals") || findtext(name, "Health"))
			industry = new /datum/stock/industry/health
		else if (findtext(name, "Wholesale") || findtext(name, "Stores"))
			industry = new /datum/stock/industry/consumer
		else
			var/ts = childrentypesof(/datum/stock/industry)
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
			average_optimism = clamp(average_optimism + (rand(-3, 3) - current_trend * 0.15) / 100, -1, 1)

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
		for (var/datum/stock/borrow/B in borrow_brokers)
			B.share_amount = round(B.share_amount / 2)
			B.share_debt = round(B.share_debt / 2)
		for (var/datum/stock/borrow/B in borrows)
			B.share_amount = round(B.share_amount / 2)
			B.share_debt = round(B.share_debt / 2)
		average_shares /= 2
		available_shares /= 2
		current_value *= 2
		last_unification = ticker.round_elapsed_ticks
		// @todo crash if too little shares remain

	proc/process()
		for (var/datum/stock/borrow/borrow in borrows)
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
					if (amt >= borrow.share_debt)
						shareholders[borrow.borrower] -= borrow.share_debt
						borrows -= borrow
						if (borrow.borrower in FrozenAccounts)
							FrozenAccounts[borrow.borrower] -= borrow
						if (length(FrozenAccounts[borrow.borrower]) == 0)
							FrozenAccounts -= borrow.borrower
						//return deposit
						modifyAccount(borrow.borrower,borrow.deposit)
						qdel(borrow)
					else
						shareholders -= borrow.borrower
						borrow.share_debt -= amt
		if (bankrupt)
			return
		for (var/datum/stock/borrow/borrow in borrow_brokers)
			if (borrow.offer_expires < ticker.round_elapsed_ticks)
				borrow_brokers -= borrow
				qdel(borrow)
		if (prob(1) && prob(3))
			generateBrokers()
		fluctuation_counter++
		if (fluctuation_counter >= fluctuation_rate)
			for (var/datum/stock/event/E in events)
				E.process()
			fluctuation_counter = 0
			fluctuate()

	proc/generateBrokers()
		if (borrow_brokers.len > 2)
			return
		if (!stockExchange.stockBrokers.len)
			stockExchange.generateBrokers()
		var/broker = pick(stockExchange.stockBrokers)
		var/datum/stock/borrow/B = new
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
		var/datum/db_record/B = FindBankAccountByName(whose)
		if (B)
			if (by < 0 && B["current_money"] + by < 0 && !force)
				return 0
			B["current_money"] += by
			stockExchange.balanceLog(whose, by)
			return 1
		return 0

	proc/borrow(datum/stock/borrow/B, who)
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

	proc/buyShares(who, howmany)
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

	proc/sellShares(whose, howmany)
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

	proc/displayValues(mob/user)
		user.Browse(plotBarGraph(values, "[name] share value per share"), "window=stock_[name];size=450x450")
