var/global/datum/controller/process/spacewind/spacewind_control

#define DEQUEUE_MOVABLE(movable) \
	movable.pre_airflow_density = null; \
	movable.airflow_speed = 0; \
	movable.airflow_origin = null; \
	movable.airflow_skip_speedcheck = null; \
	movable.airflow_time = 0; \
	movable.airflow_direction = 0; \
	src.queued_movables -= movable; \
	if (movable.pre_airflow_density == 0) { \
		movable.set_density(FALSE); \
	} \

///How much speed is lost per step
#define AIRFLOW_SPEED_DECAY 1.5
///The minimum speed an object can travel during airflow
#define AIRFLOW_SPEED_MIN 15
///The speed where movables start skipping the speedcheck during repeat runs
#define AIRFLOW_SPEED_SKIP_CHECK 7

/datum/controller/process/spacewind
	name = "Spacewind"
	schedule_interval = 0.1 SECONDS

	///The queue list for all movables ready to go through the process
	var/list/queued_movables
	///The current process run
	var/list/current_run

	///The delay (in deciseconds) between each movable's airflow movement
	var/movement_delay = 1 SECONDS

/datum/controller/process/spacewind/setup()
	src.queued_movables = list()
	global.spacewind_control = src

/datum/controller/process/spacewind/copyStateFrom(datum/controller/process/target)
	src.queued_movables = target:queued_movables

/datum/controller/process/spacewind/onStart()
	src.current_run = src.queued_movables.Copy()

/datum/controller/process/spacewind/doWork()
	while(length(current_run))
		var/atom/movable/target = src.current_run[length(src.current_run)]
		src.current_run.len--

		if(QDELETED(target))
			DEQUEUE_MOVABLE(target)
			scheck()
			continue

		if(!isturf(target.loc))
			DEQUEUE_MOVABLE(target)
			scheck()
			continue

		if(target.airflow_speed <= 0)
			DEQUEUE_MOVABLE(target)
			scheck()
			continue

		if(target.airflow_process_delay > 0)
			target.airflow_process_delay -= 1
			continue

		target.airflow_speed = min(target.airflow_speed, AIRFLOW_SPEED_MIN) - AIRFLOW_SPEED_DECAY

		if(target.airflow_skip_speedcheck)
			goto AfterSpeedCheck

		if((target.airflow_speed > AIRFLOW_SPEED_SKIP_CHECK))
			if(target.airflow_time++ >= target.airflow_speed - AIRFLOW_SPEED_SKIP_CHECK)
				if(target.pre_airflow_density == 0)
					target.set_density(FALSE)
				target.airflow_skip_speedcheck = TRUE
				continue
		else
			if(target.pre_airflow_density == 0)
				target.set_density(FALSE)

			target.airflow_process_delay = max(1, 10 - (target.airflow_speed))
			target.airflow_skip_speedcheck = TRUE
			continue


		///All this garbage is AFTER the speed check, using goto to make code more legible
		AfterSpeedCheck:

		target.airflow_skip_speedcheck = FALSE

		if(target.pre_airflow_density == 0)
			target.set_density(TRUE)


		boutput(world, "[target.name] moving by airflow at ([target.x], [target.y], [target.z])")
		var/olddir = target.dir

		var/dirfromoriginasangle = dir2angle(get_dir(target.airflow_origin, target))
		var/airflow_angle = dir2angle(target.airflow_direction)
		var/angle = max(dirfromoriginasangle, airflow_angle) - min(dirfromoriginasangle, airflow_angle)

		if(target.loc = target.airflow_origin)
			step(target, target.airflow_direction)
		else
			switch(angle)
				if(0 to 45)
					step_away(target, target.airflow_origin)
				if(46 to 89)
					step(target, target.airflow_direction)
				if(90 to 360)
					step_towards(target, target.airflow_origin)

		target.dir = olddir
		boutput(world, "[target.name] moved by airflow at ([target.x], [target.y], [target.z])")
		scheck()

/datum/controller/process/spacewind/proc/Enqueue(atom/movable/target, delta as num, turf/origin)
	if(!target.PrepareAirflow(delta, origin))
		return FALSE

	src.queued_movables += target
