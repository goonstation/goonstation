/datum/controller/process/stock_market
	setup()
		name = "Stock Market"
		schedule_interval = 15

	doWork()
		if (stockExchange)
			stockExchange.process()

