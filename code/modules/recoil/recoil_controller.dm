/datum/recoil_controller
	/// The client that this recoil controller belongs to.
	var/client/client
	var/recoilcamera_active = FALSE //! whether or not this mob's recoil camera is active
	var/recoilcamera_processing = 0 //! whether or not this mob's recoil camera is active
	var/recoilcamera_x = 0 //! current camera x offset from recoil
	var/recoilcamera_y = 0 //! current camera y offset from recoil
	var/recoilcamera_last = 0 //! time of the last recoil impulse
	var/recoilcamera_recoil_magnitude = 0 //! the magnitude of recoil this mob's experiencing (ie. how far away is the camera)
	var/recoilcamera_recoil_delta = 0 //! the rate of change of recoil magnitude
	var/recoilcamera_angle = 0 //! the current angle of the mob's recoil camera
	var/recoilcamera_sway_delta = 0 //! the rate of change of the mob's recoil angle

	// Reset/damping rates
	var/recoilcamera_sway_damp = 0.85 //! how much sway delta should be multiplied by every 10th of a second
	var/recoilcamera_damp = 0.6 //! how much recoil delta should be multiplied by every 10th of a second
	var/recoilcamera_damp_distance = 0.4 //! how much recoil delta should be decreased by, per pixel away from the centre
	var/recoilcamera_flat_reset_speed = 2 //! how much recoil_delta is reduced by, every 10th of a second

/datum/recoil_controller/New(client/owner)
	. = ..()
	src.client = owner

/client/var/datum/recoil_controller/recoil_controller

/client/New()
	. = ..()
	src.toggle_camera_recoil()

/datum/recoil_controller/proc/enable()
	recoilcamera_active = TRUE

/datum/recoil_controller/proc/disable()
	recoilcamera_active = FALSE
	var/deltax = -recoilcamera_x
	var/deltay = -recoilcamera_y
	recoilcamera_recoil_magnitude = 0
	recoilcamera_recoil_delta = 0
	recoilcamera_sway_delta = 0
	recoilcamera_angle = 0
	recoilcamera_x = 0
	recoilcamera_y = 0
	if(client && (deltax != 0 || deltay != 0))
		animate(client, pixel_x = deltax, pixel_y = deltay, time = 1, flags = ANIMATION_RELATIVE)


/datum/recoil_controller/proc/recoil_camera(dir, strength=1, spread=3)
	SPAWN(0)
		if(!client || !recoilcamera_active)
			return
		// If the instant recoil impulse is bigger than our camera's current recoil, just reset and use it.
		// This is basically the 'first shot' recoil, and it looks weird if it's got sway_delta.
		if (strength > recoilcamera_recoil_magnitude)
			var/rand_angle =  rand(-spread, spread)
			recoilcamera_angle = dir + rand_angle
			recoilcamera_recoil_delta += strength
		else
			// If we're shooting while the camera is already flying about:
			var/offset_angle = recoilcamera_angle - (dir)
			var/rand_angle =  offset_angle + rand(-spread, spread)

			// Reduce our recoil if we keep shooting in the same direction.
			var/angle_relative_mult = max(0,cos(recoilcamera_angle - dir)) // Moves closer to 1 if we're shooting in the direction our camera is pushed back
			var/max_reduction = strength*(rand(4,8)/10) // If we reduce recoil mult to 0 it stops your screen shaking (which is counterintuitive at high recoil)
			var/recoil_strength_reduction = min(recoilcamera_recoil_magnitude/(strength*6) * angle_relative_mult, max_reduction)

			var/recoil_strength_adjusted = strength-recoil_strength_reduction
			var/recoil_impulse = recoil_strength_adjusted * cos(offset_angle)
			var/sway_strength = max(15,strength) * sin(rand_angle)
			recoilcamera_sway_delta -= sway_strength
			recoilcamera_recoil_delta += recoil_impulse
		recoilcamera_last = TIME
		if (!recoilcamera_processing)
			recoilcamera_processing = TRUE
			SPAWN(0)
				recoil_camera_loop()

/datum/recoil_controller/proc/recoil_camera_loop()
	if(!client)
		return
	while(abs(recoilcamera_recoil_magnitude) > 0 || abs(recoilcamera_recoil_delta) > 0)
		recoilcamera_recoil_magnitude = max(0, recoilcamera_recoil_magnitude + recoilcamera_recoil_delta)
		recoilcamera_angle += recoilcamera_sway_delta
		var/targetx = cos(recoilcamera_angle) * recoilcamera_recoil_magnitude
		var/targety = sin(recoilcamera_angle) * recoilcamera_recoil_magnitude
		var/deltax = targetx - recoilcamera_x
		var/deltay = targety - recoilcamera_y

		recoilcamera_sway_delta *= recoilcamera_sway_damp
		recoilcamera_recoil_delta *= recoilcamera_damp
		recoilcamera_recoil_delta -= recoilcamera_recoil_magnitude * recoilcamera_damp_distance
		recoilcamera_recoil_delta -= recoilcamera_flat_reset_speed
		if (deltax >= 0)
			deltax = round(deltax)
		else
			deltax = -round(-deltax)

		if (deltay >= 0)
			deltay = round(deltay)
		else
			deltay = -round(-deltay)

		recoilcamera_x += deltax
		recoilcamera_y += deltay

		if (recoilcamera_recoil_magnitude == 0)
			recoilcamera_recoil_delta = 0
			recoilcamera_sway_delta = 0
			recoilcamera_angle = 0
		if(client)
			animate(client, pixel_x = deltax, pixel_y = deltay, time = 1, flags = ANIMATION_RELATIVE)
		sleep(1 DECI SECOND)
	recoilcamera_processing = FALSE
