datum/controller/process/railway
	var/tmp/list/vehicles

	setup()
		name = "Railways"
		schedule_interval = 5
		vehicles = global.railway_vehicles

	doWork()
		var/c
		for(var/obj/railway_vehicle/v in global.railway_vehicles)
			v.process()
			if (!(c++ % 10))
				scheck()
