/// How long the Zero-G floating animation takes (ms)
#define GRAVITY_LIVING_ZERO_G_ANIM_TIME 25

proc/SubscribeGravity(atom/AM)
	var/datum/controller/process/gravity/controller = global.processScheduler?.getProcess("Gravity Process")
	controller?.subscriber_list |= AM

proc/UnsubscribeGravity(atom/AM)
	var/datum/controller/process/gravity/controller = global.processScheduler?.getProcess("Gravity Process")
	controller?.subscriber_list -= AM

/// Controller to store gravity variables and update atom gravity
///
/// Subscribe **non-lifeprocess** atoms to get regular gravity updates.
/datum/controller/process/gravity
	var/list/subscriber_list = list()

	setup()
		name = "Gravity Process"
		schedule_interval = 3 SECONDS

	doWork()
		for (var/atom/movable/AM as anything in src.subscriber_list)
			if (QDELETED(AM))
				continue
			AM.set_gravity(AM.loc)

// this sucks and i'm placing it here
proc/StartDriftFloat(atom/movable/AM)
	if (!(AM.temp_flags & DRIFT_ANIMATION))
		AM.temp_flags |= DRIFT_ANIMATION
		animate(AM, flags=ANIMATION_END_NOW, tag="grav_drift") // reset animations so they don't stack
		animate_drift(AM, -1, GRAVITY_LIVING_ZERO_G_ANIM_TIME)

proc/StopDriftFloat(atom/movable/AM)
	AM.temp_flags &= ~DRIFT_ANIMATION
	animate(AM, flags=ANIMATION_END_NOW, tag="grav_drift")


#undef GRAVITY_LIVING_ZERO_G_ANIM_TIME
