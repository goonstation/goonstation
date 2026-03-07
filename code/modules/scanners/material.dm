// Contents
// Handheld material analyzer

TYPEINFO(/obj/item/device/matanalyzer)
	mats = 5

/obj/item/device/matanalyzer
	icon_state = "matanalyzer"
	name = "material analyzer"
	desc = "This piece of equipment can detect and analyze materials."
	flags = EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(GET_DIST(src, target) > world.view)
			boutput(user, SPAN_ALERT("[target] is too far away."))
			return
		animate_scanning(target, "#597B6D")
		var/atom/W = target
		if(!W.material)
			boutput(user, SPAN_ALERT("No significant material found in \the [target]."))
		else
			boutput(user, SPAN_NOTICE("<u>[capitalize(W.material.getName())]</u>"))
			boutput(user, SPAN_NOTICE("[W.material.getDesc()]"))

			if(length(W.material.getMaterialProperties()))
				boutput(user, SPAN_NOTICE("<u>The material is:</u>"))
				for(var/datum/material_property/X in W.material.getMaterialProperties())
					var/value = W.material.getProperty(X.id)
					boutput(user, SPAN_NOTICE("• [X.getAdjective(W.material)] ([value])"))
			else
				boutput(user, SPAN_NOTICE("<u>The material is completely unremarkable.</u>"))
		if (istype(target, /obj/machinery/atmospherics/pipe))
			var/obj/machinery/atmospherics/pipe/pipe = target
			if (pipe.can_rupture)
				boutput(user, SPAN_NOTICE("<u>This pipe has an estimated fatigue pressure of [round(pipe.effective_fatigue_pressure(), 10)]KPa</u>"))
