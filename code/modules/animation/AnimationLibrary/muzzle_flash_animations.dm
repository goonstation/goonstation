/obj/overlay/simple_light/muzzle_flash
	appearance_flags = RESET_COLOR | NO_CLIENT_COLOR | KEEP_APART


ADD_TO_NAMESPACE(ANIMATE)(var/obj/overlay/simple_light/muzzle_flash/muzzle_simple_light = new())

ADD_TO_NAMESPACE(ANIMATE)(var/list/default_muzzle_flash_colors = list(
	"muzzle_flash" = "#FFEE9980",
	"muzzle_flash_laser" = "#FF333380",
	"muzzle_flash_elec" = "#FFC80080",
	"muzzle_flash_bluezap" = "#00FFFF80",
	"muzzle_flash_plaser" = "#00A9FB80",
	"muzzle_flash_phaser" = "#F41C2080",
	"muzzle_flash_launch" = "#FFFFFF50",
	"muzzle_flash_wavep" = "#B3234E80",
	"muzzle_flash_waveg" = "#33CC0080",
	"muzzle_flash_waveb" = "#87BBE380"
))

ADD_TO_NAMESPACE(ANIMATE)(proc/muzzle_flash_attack_particle(mob/M, turf/origin, turf/target, muzzle_anim, muzzle_light_color, offset = 25))
	if (!M || !origin || !target || !muzzle_anim) return
	var/firing_angle = get_angle(origin, target)
	ANIMATE.muzzle_flash_any(M, firing_angle, muzzle_anim, muzzle_light_color, offset)

ADD_TO_NAMESPACE(ANIMATE)(proc/muzzle_flash_any(atom/movable/A, firing_angle, muzzle_anim, muzzle_light_color, offset = 25, horizontal_offset = 0))
	if (!A || firing_angle == null || !muzzle_anim) return

	var/obj/particle/attack/muzzleflash/muzzleflash = new /obj/particle/attack/muzzleflash

	if(isnull(muzzle_light_color))
		muzzle_light_color = ANIMATE.default_muzzle_flash_colors[muzzle_anim]
	muzzleflash.overlays.Cut()
	if(muzzle_light_color)
		ANIMATE.muzzle_simple_light.color = muzzle_light_color
		muzzleflash.overlays += ANIMATE.muzzle_simple_light

	var/matrix/mat = new
	mat.Translate(horizontal_offset, offset)
	mat.Turn(firing_angle)
	muzzleflash.transform = mat
	muzzleflash.layer = A.layer
	muzzleflash.set_loc(A)
	A.vis_contents.Add(muzzleflash)
	if (muzzleflash.icon_state == muzzle_anim)
		FLICK(muzzle_anim,muzzleflash)
	muzzleflash.icon_state = muzzle_anim

	animate(muzzleflash, time=0.4 SECONDS)
	animate(alpha=0, easing=SINE_EASING, time=0.2 SECONDS)

	SPAWN(0.6 SECONDS)
		A.vis_contents.Remove(muzzleflash)
		qdel(muzzleflash)
