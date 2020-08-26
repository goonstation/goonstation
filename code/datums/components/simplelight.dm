/datum/component/holdertargeting/simple_light
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/on_when_equipped = 1
	var/r = 255
	var/g = 255
	var/b = 255
	var/a = 255
	var/light_name
	var/enabled = 1
	var/atom/light_target = null

/datum/component/holdertargeting/simple_light/Initialize(r = 255, g = 255, b = 255, a = 127, enabled = 1, on_when_equipped = 1)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	src.r = r
	src.g = g
	src.b = b
	src.a = a
	src.enabled = 1
	src.on_when_equipped =  on_when_equipped
	src.light_name = "sl_comp_\ref[src]"

/datum/component/holdertargeting/simple_light/proc/update(var/new_enabled = -1)
	if(new_enabled != -1)
		src.enabled = new_enabled
	if(!src.enabled)
		light_target.remove_simple_light(src.light_name)
	else
		light_target.add_simple_light(src.light_name, list(r, g, b, a))

/datum/component/holdertargeting/simple_light/RegisterWithParent()
	src.light_target = src.parent
	src.update()

/datum/component/holdertargeting/simple_light/UnregisterFromParent()
	src.update(0)

/datum/component/holdertargeting/simple_light/proc/set_color(var/r, var/g, var/b)
	src.r = r
	src.g = g
	src.b = b
	src.update(0)

/datum/component/holdertargeting/simple_light/on_pickup(datum/source, mob/user)
	. = ..()
	if(!src.enabled)
		src.light_target = user
		return
	src.update(0)
	src.light_target = user
	src.update(1)

/datum/component/holdertargeting/simple_light/on_dropped(datum/source, mob/user)
	. = ..()
	var/obj/item/I = src.parent
	if (I.loc == user && src.on_when_equipped)
		src.light_target = user
		return

	if(!src.enabled)
		src.light_target = I
		return
	src.update(0)
	src.light_target = I
	src.update(1)



/datum/component/holdertargeting/sm_light
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/on_when_equipped = 1
	var/r = 255
	var/g = 255
	var/b = 255
	var/a = 255
	var/light_name
	var/enabled = 1
	var/atom/light_target = null

/datum/component/holdertargeting/sm_light/Initialize(r = 255, g = 255, b = 255, a = 127, enabled = 1, on_when_equipped = 1)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	src.r = r
	src.g = g
	src.b = b
	src.a = a
	src.enabled = 1
	src.on_when_equipped =  on_when_equipped
	src.light_name = "ml_comp_\ref[src]"

/datum/component/holdertargeting/sm_light/proc/update(var/new_enabled = -1)
	if(new_enabled != -1)
		src.enabled = new_enabled
	if(!src.enabled)
		light_target.remove_sm_light(src.light_name)
	else
		light_target.add_sm_light(src.light_name, list(r, g, b, a), medium=1)

/datum/component/holdertargeting/sm_light/RegisterWithParent()
	src.light_target = src.parent
	src.update()

/datum/component/holdertargeting/sm_light/UnregisterFromParent()
	src.update(0)

/datum/component/holdertargeting/sm_light/proc/set_color(var/r, var/g, var/b)
	src.r = r
	src.g = g
	src.b = b
	src.update(0)

/datum/component/holdertargeting/sm_light/on_pickup(datum/source, mob/user)
	. = ..()
	if(!src.enabled)
		src.light_target = user
		return
	src.update(0)
	src.light_target = user
	src.update(1)

/datum/component/holdertargeting/sm_light/on_dropped(datum/source, mob/user)
	. = ..()
	var/obj/item/I = src.parent
	if (I.loc == user && src.on_when_equipped)
		src.light_target = user
		return

	if(!src.enabled)
		src.light_target = I
		return
	src.update(0)
	src.light_target = I
	src.update(1)





/datum/component/holdertargeting/medium_directional_light
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/on_when_equipped = 1
	var/r = 255
	var/g = 255
	var/b = 255
	var/a = 255
	var/light_name
	var/enabled = 1
	var/atom/light_target = null

/datum/component/holdertargeting/medium_directional_light/Initialize(r = 255, g = 255, b = 255, a = 127, enabled = 1, on_when_equipped = 1)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	src.r = r
	src.g = g
	src.b = b
	src.a = a
	src.enabled = enabled
	src.on_when_equipped =  on_when_equipped
	src.light_name = "dl_comp_\ref[src]"

/datum/component/holdertargeting/medium_directional_light/proc/update(var/new_enabled = -1)
	if(new_enabled != -1)
		src.enabled = new_enabled
	if(!src.enabled)
		light_target.remove_mdir_light(src.light_name)
	else
		light_target.add_mdir_light(src.light_name, list(r, g, b, a))

/datum/component/holdertargeting/medium_directional_light/RegisterWithParent()
	src.light_target = src.parent
	src.update()

/datum/component/holdertargeting/medium_directional_light/UnregisterFromParent()
	src.update(0)

/datum/component/holdertargeting/medium_directional_light/on_pickup(datum/source, mob/user)
	. = ..()
	if(!src.enabled)
		src.light_target = user
		return
	src.update(0)
	src.light_target = user
	src.update(1)

/datum/component/holdertargeting/medium_directional_light/on_dropped(datum/source, mob/user)
	. = ..()
	var/obj/item/I = src.parent
	if (I.loc == user && src.on_when_equipped)
		src.light_target = user
		return

	if(!src.enabled)
		src.light_target = I
		return
	src.update(0)
	src.light_target = I
	src.update(1)

