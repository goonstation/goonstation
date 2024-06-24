/// Handles updating the shipping market
/datum/controller/process/shipping_market
	setup()
		name = "Shipping Market Update"
		schedule_interval = 7.5 MINUTES
		schedule_jitter = 90 SECONDS
		shippingmarket.market_shift()

	doWork()
		shippingmarket.market_shift()

	queued()
		. = ..()
		shippingmarket.time_until_shift = TIME + src.schedule_interval + src.schedule_jitter
