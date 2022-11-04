
/// Controls railway movement
/datum/controller/process/railway
	var/tmp/list/vehicles

	setup()
		name = "Railways"
		schedule_interval = 0.5 SECONDS
		vehicles = global.railway_vehicles

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/railway/old_railway = target
		src.vehicles = old_railway.vehicles

	doWork()
		var/c
		for(var/obj/railway_vehicle/v in global.railway_vehicles)
			v.process()
			if (!(c++ % 10))
				scheck()
