TYPEINFO(/mob/dead/target_observer)
	start_listen_modifiers = null
	start_listen_inputs = null
	start_listen_languages = list(LANGUAGE_ALL)
	start_speech_modifiers = null
	start_speech_outputs = null

/mob/dead/target_observer/hivemind_observer
	is_respawnable = FALSE
	locked = TRUE
	var/datum/abilityHolder/changeling/hivemind_owner
	var/can_exit_hivemind_time = 0
	var/last_attack = 0
	/// Hivemind pointing uses an image rather than a decal
	var/static/point_img = null

	default_speech_output_channel = null

	New()
		. = ..()
		if (!point_img)
			point_img = image('icons/mob/screen1.dmi', icon_state = "arrow")
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)

	stop_observing()
		set hidden = 1

	disposing()
		LAZYLISTREMOVE(observers, src)
		hivemind_owner?.hivemind -= src
		..()

	click(atom/target, params)
		if (src.client.check_key(KEY_POINT))
			point_at(target, text2num(params["icon-x"]), text2num(params["icon-y"]))
			return
		if (try_launch_attack(target))
			return
		..()

	update_cursor()
		..()
		if (src.client)
			if (src.client.check_key(KEY_POINT))
				src.set_cursor('icons/cursors/point.dmi')
				return

	point_at(atom/target, var/pixel_x, var/pixel_y)
		if(ON_COOLDOWN(src, "hivemind_member_point", 1 SECOND))
			return
		..()
		make_hive_point(target, pixel_x, pixel_y, color="#e2a059")

	/// Like make_point, but the point is an image that is only displayed to hivemind members
	proc/make_hive_point(atom/movable/target, var/pixel_x, var/pixel_y, color="#ffffff", time=2 SECONDS)
		var/turf/target_turf = get_turf(target)
		var/image/point = image(point_img, loc = target_turf, layer = EFFECTS_LAYER_1)
		if (!target.pixel_point)
			pixel_x = target.pixel_x
			pixel_y = target.pixel_y
		else
			pixel_x -= 16 - target.pixel_x
			pixel_y -= 16 - target.pixel_y
		point.pixel_x = pixel_x
		point.pixel_y = pixel_y
		point.color = color
		point.layer = EFFECTS_LAYER_1
		point.plane = PLANE_HUD
		var/list/client/viewers = new
		for (var/mob/member in (hivemind_owner.get_current_hivemind() | hivemind_owner.owner.observers))
			if (!member.client)
				continue
			boutput(member, SPAN_HIVESAY("[SPAN_PREFIX("HIVEMIND: ")]<b>[src]</b> points to [target]."))
			member.client.images += point
			viewers += member.client
		var/matrix/M = matrix()
		M.Translate((hivemind_owner.owner.x - target_turf.x)*32 - pixel_x, (hivemind_owner.owner.y - target_turf.y)*32 - pixel_y)
		point.transform = M
		animate(point, transform=null, time=2)
		SPAWN(time)
			for (var/client/viewer in viewers)
				viewer.images -= point
			qdel(point)
		return point

	proc/try_launch_attack(atom/shoot_target)
		.= 0
		if (isabomination(hivemind_owner.owner) && world.time > (last_attack + src.combat_click_delay))
			var/obj/projectile/proj = initialize_projectile_pixel_spread(target, new /datum/projectile/special/acidspit, shoot_target)
			if (proj) //ZeWaka: Fix for null.launch()
				proj.launch()
				last_attack = world.time
				playsound(src, 'sound/weapons/flaregun.ogg', 30, 0.1, 0, 2.6)
				.= 1

	proc/set_owner(var/datum/abilityHolder/changeling/new_owner)
		if(!istype(new_owner)) return 0
		//DEBUG_MESSAGE("Calling set_owner on [src] with abilityholder belonging to [new_owner.owner]")

		//If we had an owner then remove ourselves from the their hivemind
		if(hivemind_owner)
			//DEBUG_MESSAGE("Removing [src] from [hivemind_owner.owner]'s hivemind.")
			hivemind_owner.hivemind -= src

		//DEBUG_MESSAGE("Adding [src] to new owner [new_owner.owner]'s hivemind.")
		//Add ourselves to the new owner's hivemind
		hivemind_owner = new_owner
		new_owner.hivemind |= src
		//...and transfer the observe stuff accordingly.
		//DEBUG_MESSAGE("Setting new observe target: [new_owner.owner]")
		set_observe_target(new_owner.owner)

		return 1

/mob/dead/target_observer/hivemind_observer/proc/regain_control()
	set name = "Retake Control"
	set category = "Changeling"
	usr = src

	if(hivemind_owner && hivemind_owner.master == src)
		if(hivemind_owner.return_control_to_master())
			qdel(src)

/mob/dead/target_observer/hivemind_observer/verb/exit_hivemind()
	set name = "Exit Hivemind"
	set category = "Commands"
	usr = src

	if(world.time >= can_exit_hivemind_time && hivemind_owner && hivemind_owner.master != src)
		boutput(src, SPAN_ALERT("You have parted with the hivemind."))
		src.mind?.remove_antagonist(ROLE_CHANGELING_HIVEMIND_MEMBER)
	else
		boutput(src, SPAN_ALERT("You are not able to part from the hivemind at this time. You will be able to leave in [(can_exit_hivemind_time/10 - world.time/10)] seconds."))

