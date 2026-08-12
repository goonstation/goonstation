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
		analyze_target(target, user)

	proc/analyze_target_abridged(var/atom/target)
		var/report_mat = ""
		if(target.material)
			report_mat += SPAN_NOTICE("<li><u>Material</u>: [capitalize(target.material.getName())]")
			report_mat += SPAN_SUBTLE(" ([target.material_amount_total()] units)</li>")
		else
			report_mat += SPAN_ALERT("<li>No significant material found in \the [target].</li>")

	proc/analyze_target(var/atom/target, var/mob/user)
		var/report_mat = analyze_material(target)
		var/report_effects = analyze_effects(target)
		boutput(user, report_mat + report_effects)

	proc/analyze_material(var/atom/target)
		var/datum/material/mat = target.material
		if(!mat)
			return SPAN_ALERT("<li>No significant material found in \the [target].</li>")
		var/report = SPAN_SUCCESS("<li><u>Material</u>: [capitalize(mat.getName())]")
		report += SPAN_SUBTLE(" ([target.material_amount_total()] units)</li>")
		if(length(mat.getMaterialProperties()))
			report += "<ul style='margin-top:0px;margin-bottom:0px;padding-left:20px'>"
			for(var/datum/material_property/X in mat.getMaterialProperties())
				var/value = mat.getProperty(X.id)
				report += "<li style='padding-left:0px'>[X.getAdjective(mat)] ([value][X.value_unit])</li>"
			report += "</ul>"
		else
			report += "<li>The material properties are completely unremarkable.</li>"

		var/report_trigger = analyze_material_triggers(mat)
		if(report_trigger)
			report += "<li>[SPAN_NOTICE("Material Effects:")]</li>" + report_trigger

		return report

	proc/analyze_material_triggers(var/datum/material/mat)
		var/list/trigger_desc = list()
		for(var/X in triggerVars)
			for(var/datum/materialProc/mat_proc in mat.vars[X])
				var/desc = mat_proc.get_scan_desc()
				if(!desc)
					continue
				var/desc_match = FALSE
				for(var/other in trigger_desc)
					if(desc == other)
						desc_match = TRUE
						break
				if(!desc_match)
					trigger_desc += desc

		if(length(trigger_desc) == 0)
			return null
		var/report = "<ul style='margin-top:0px;margin-bottom:0px;padding-left:20px'>"
		for(var/desc in trigger_desc)
			report += "<li style='padding-left:0px'>[desc]</li>"
		return "[report]</ul>"

	proc/analyze_effects(var/atom/target)
		var/report = ""
		var/scan_data = target.on_material_scan()
		if(islist(scan_data))
			for(var/data in scan_data)
				report += "<li style='padding-left:0px'>[data]</li>"
		else if(scan_data)
			report = "<li style='padding-left:0px'>[scan_data]</li>"
		if(report)
			report = "<li>[SPAN_NOTICE("Additional Notes:")]</li><ul style='margin-top:0px;margin-bottom:0px;padding-left:20px'>[report]</ul>"
		return report
