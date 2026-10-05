TYPEINFO(/datum/component/health_maptext)
	initialization_args = list(
		list("do_popup_text", DATA_INPUT_BOOL, "Whether to popup damage numbers on damage.", TRUE)
	)
/datum/component/health_maptext
	var/obj/maptext_junk/health/maptext_obj = null
	var/do_popup_text = TRUE
	var/last_health = 0

/datum/component/health_maptext/Initialize(do_popup_text = TRUE)
	. = ..()
	if (. == COMPONENT_INCOMPATIBLE || !istype(parent, /mob))
		return COMPONENT_INCOMPATIBLE
	src.maptext_obj = new
	src.do_popup_text = do_popup_text

/datum/component/health_maptext/RegisterWithParent()
	if(!istype(src.parent, /mob))
		return
	var/mob/parent_mob = src.parent
	parent_mob.vis_contents += src.maptext_obj
	RegisterSignal(src.parent, COMSIG_MOB_UPDATE_DAMAGE, PROC_REF(on_update_damage))
	update_maptext(0, FALSE)

/datum/component/health_maptext/UnregisterFromParent()
	UnregisterSignal(src.parent, COMSIG_MOB_UPDATE_DAMAGE)
	var/mob/parent_mob = src.parent
	parent_mob.vis_contents -= src.maptext_obj

/datum/component/health_maptext/disposing()
	qdel(src.maptext_obj)
	src.maptext_obj = null
	..()

/datum/component/health_maptext/proc/on_update_damage(mob/M, prev_health)
	update_maptext(src.do_popup_text)

/datum/component/health_maptext/proc/update_maptext(do_popup_text = TRUE)
	var/mob/M = src.parent
	if (!isdead(M))
		var/h_color = "#999999"
		var/h_pct = round((M.health / (M.max_health != 0 ? M.max_health : 1)) * 100)
		switch (h_pct)
			if (50 to INFINITY)
				h_color	= "rgb([(100 - h_pct) / 50 * 255], 255, [(100 - h_pct) * 0.3])"
			if (0 to 50)
				h_color	= "rgb(255, [h_pct / 50 * 255], 0)"
			if (-100 to 0)
				h_color	= "#ffffff"
		maptext_obj.maptext = "<span style='color: [h_color];' class='pixel c sh'>[h_pct]%</span>"
		if (src.last_health != M.health && do_popup_text)
			new /obj/maptext_junk/damage(get_turf(M), change = M.health - src.last_health)
		src.last_health = M.health
	else
		maptext_obj.maptext = ""

/obj/maptext_junk/health
	maptext_y = 32
