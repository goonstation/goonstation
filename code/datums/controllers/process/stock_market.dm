
var/global/datum/stock/market/stockExchange

/datum/controller/process/stock_market
	setup()
		name = "Stock Market"
		schedule_interval = 15
		stockExchange = new

	doWork()
		if (stockExchange)
			stockExchange.process()
