/datum/component/loctargeting/simple_light
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/r = 255
	var/g = 255
	var/b = 255
	var/a = 255
	var/light_name
	loctype = /mob
	var/enabled = FALSE
	var/atom/light_target = null

TYPEINFO(/datum/component/loctargeting/simple_light)
	initialization_args = list(
		ARG_INFO("r", DATA_INPUT_NUM, "Value of red component \[0-255\]", 255),
		ARG_INFO("g", DATA_INPUT_NUM, "Value of green component \[0-255\]", 255),
		ARG_INFO("b", DATA_INPUT_NUM, "Value of blue component \[0-255\]", 255),
		ARG_INFO("a", DATA_INPUT_NUM, "Alpha (brightness) component \[0-255\]", 127),
		ARG_INFO("enabled", DATA_INPUT_BOOL, "Initial state of the simplelight (bool)", FALSE)
	)
/datum/component/loctargeting/simple_light/Initialize(r = 255, g = 255, b = 255, a = 127, enabled = FALSE)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	src.r = r
	src.g = g
	src.b = b
	src.a = a
	src.enabled = enabled
	src.light_name = "sl_comp_\ref[src]"

/datum/component/loctargeting/simple_light/proc/update(var/new_enabled = -1)
	if(new_enabled != -1)
		src.enabled = new_enabled
	if(!src.enabled)
		light_target.remove_simple_light(src.light_name)
	else
		light_target.add_simple_light(src.light_name, list(r, g, b, a))

/datum/component/loctargeting/simple_light/RegisterWithParent()
	src.light_target = src.parent
	src.update()
	. = ..()

/datum/component/loctargeting/simple_light/UnregisterFromParent()
	src.update(0)
	. = ..()

/datum/component/loctargeting/simple_light/proc/set_color(var/r, var/g, var/b)
	src.r = r
	src.g = g
	src.b = b
	src.update(0)

/datum/component/loctargeting/simple_light/on_added(datum/source, old_loc)
	. = ..()
	if(!src.enabled)
		src.light_target = current_loc
		return
	src.update(0)
	src.light_target = current_loc
	src.update(1)

/datum/component/loctargeting/simple_light/on_removed(datum/source, old_loc)
	. = ..()
	var/obj/item/I = src.parent

	if(!src.enabled)
		src.light_target = I
		return
	src.update(0)
	src.light_target = I
	src.update(1)



/datum/component/loctargeting/sm_light
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	loctype = /mob
	var/r = 255
	var/g = 255
	var/b = 255
	var/a = 255
	var/light_name
	var/enabled = FALSE
	var/atom/light_target = null

TYPEINFO(/datum/component/loctargeting/sm_light)
	initialization_args = list(
		ARG_INFO("r", DATA_INPUT_NUM, "Value of red component \[0-255\]", 255),
		ARG_INFO("g", DATA_INPUT_NUM, "Value of green component \[0-255\]", 255),
		ARG_INFO("b", DATA_INPUT_NUM, "Value of blue component \[0-255\]", 255),
		ARG_INFO("a", DATA_INPUT_NUM, "Alpha (brightness) component \[0-255\]", 127),
		ARG_INFO("enabled", DATA_INPUT_NUM, "Initial state of the simplelight (bool)", FALSE)
	)
/datum/component/loctargeting/sm_light/Initialize(r = 255, g = 255, b = 255, a = 127, enabled = FALSE)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	src.r = r
	src.g = g
	src.b = b
	src.a = a
	src.enabled = enabled
	src.light_name = "ml_comp_\ref[src]"

/datum/component/loctargeting/sm_light/proc/update(var/new_enabled = -1)
	if(new_enabled != -1)
		src.enabled = new_enabled
	if(!src.enabled)
		light_target.remove_sm_light(src.light_name)
	else
		light_target.add_sm_light(src.light_name, list(r, g, b, a), medium=1)

/datum/component/loctargeting/sm_light/RegisterWithParent()
	src.light_target = src.parent
	src.update()
	. = ..()

/datum/component/loctargeting/sm_light/UnregisterFromParent()
	src.update(0)
	. = ..()

/datum/component/loctargeting/sm_light/proc/set_color(var/r, var/g, var/b)
	src.r = r
	src.g = g
	src.b = b
	src.update(0)

/datum/component/loctargeting/sm_light/on_added(datum/source, old_loc)
	. = ..()
	if(!src.enabled)
		src.light_target = current_loc
		return
	src.update(0)
	src.light_target = current_loc
	src.update(1)

/datum/component/loctargeting/sm_light/on_removed(datum/source, old_loc)
	. = ..()
	var/obj/item/I = src.parent
	if(!src.enabled)
		src.light_target = I
		return
	src.update(0)
	src.light_target = I
	src.update(1)





/datum/component/loctargeting/medium_directional_light
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	loctype = /mob
	var/r = 255
	var/g = 255
	var/b = 255
	var/a = 255
	var/light_name
	var/enabled = FALSE
	var/atom/light_target = null

TYPEINFO(/datum/component/loctargeting/medium_directional_light)
	initialization_args = list(
		ARG_INFO("r", DATA_INPUT_NUM, "Value of red component \[0-255\]", 255),
		ARG_INFO("g", DATA_INPUT_NUM, "Value of green component \[0-255\]", 255),
		ARG_INFO("b", DATA_INPUT_NUM, "Value of blue component \[0-255\]", 255),
		ARG_INFO("a", DATA_INPUT_NUM, "Alpha (brightness) component \[0-255\]", 127),
		ARG_INFO("enabled", DATA_INPUT_BOOL, "Initial state of the simplelight", FALSE)
	)
/datum/component/loctargeting/medium_directional_light/Initialize(r = 255, g = 255, b = 255, a = 127, enabled = FALSE)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	src.r = r
	src.g = g
	src.b = b
	src.a = a
	src.enabled = enabled
	src.light_name = "dl_comp_\ref[src]"

/datum/component/loctargeting/medium_directional_light/proc/update(var/new_enabled = -1)
	if(new_enabled != -1)
		src.enabled = new_enabled
	if(!src.enabled)
		light_target.remove_mdir_light(src.light_name)
	else
		light_target.add_mdir_light(src.light_name, list(r, g, b, a))

/datum/component/loctargeting/medium_directional_light/RegisterWithParent()
	src.light_target = src.parent
	src.update()
	. = ..()

/datum/component/loctargeting/medium_directional_light/UnregisterFromParent()
	src.update(0)
	. = ..()

/datum/component/loctargeting/medium_directional_light/on_added(datum/source, old_loc)
	. = ..()
	if(!src.enabled)
		src.light_target = current_loc
		return
	src.update(0)
	src.light_target = current_loc
	src.update(1)

/datum/component/loctargeting/medium_directional_light/on_removed(datum/source, old_loc)
	. = ..()
	var/obj/item/I = src.parent
	if(!src.enabled)
		src.light_target = I
		return
	src.update(0)
	src.light_target = I
	src.update(1)

