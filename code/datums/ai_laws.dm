//This class is now a handler for all global AI law rack functions
//if you want to get laws and details about a specific rack, call the functions on that rack
//if you want to get laws and details about all racks - this is where you'd look
//this also keeps track of the default rack

/datum/ai_rack_manager

	var/first_registered = FALSE
	var/obj/machinery/computer/aiupload/default_ai_rack = null
	var/list/obj/machinery/computer/aiupload/registered_racks = new()

	New() //got to do it this way because ticker is init after map
		. = ..()
		boutput(world,"<B>Law rack manager init</B>")
		for_by_tcl(R, /obj/machinery/computer/aiupload)
			src.register_new_rack(R)
			boutput(world,"<B>registered!</B>")
		for_by_tcl(S, /mob/living/silicon)
			S.law_rack_connection = src.default_ai_rack
			boutput(world,"<B>connected</B>")


	proc/register_new_rack(var/obj/machinery/computer/aiupload/new_rack)
		if(isnull(src.default_ai_rack))
			src.default_ai_rack = new_rack
		if(!src.first_registered)
			boutput(world,"<B>First AI rack registered!</B>")
			src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov1,1,true,true)
			src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov2,2,true,true)
			src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov3,3,true,true)
			src.first_registered = TRUE
		src.registered_racks += new_rack



/* General ai_law functions */
	proc/format_for_irc()
		var/list/laws = list()
		for(var/obj/machinery/computer/aiupload/R in src.registered_racks)
			laws += R.format_for_irc()
		return laws


	proc/format_for_logs(var/glue = "<br>")
		var/list/laws = list()
		for(var/obj/machinery/computer/aiupload/R in src.registered_racks)
			laws += "Laws for [R] at [R.loc]:<br>" + R.format_for_logs(glue) +"<br>--------------<br>"
		return jointext(laws, glue)
