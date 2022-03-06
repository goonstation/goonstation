
/client
	var
		hellbanned = 0 //The intention here is to basically make the game stealthily unplayable, prevents you from getting randomly picked as traitor, silently drops some Move() and Click() calls, etc.
		click_drops = 40
		move_drops = 30
		spiking = 0

	New()
		if (hellbans && (src.ckey in hellbans))
			hellbanned = 1
		..()

	proc
		fake_lagspike()
			if(!src.hellbanned || src.spiking) return
			//Let's significantly increase the dropped clicks / moves for some time
			var/duration = rand(10, 80) //1 - 8 seconds

			move_drops = min(move_drops + rand(30, 80), 100)
			click_drops = min(click_drops + rand(30, 80), 100)

			spiking = 1
			SPAWN(duration)
				move_drops = initial(move_drops)
				click_drops = initial(click_drops)
				spiking = 0

			return duration
