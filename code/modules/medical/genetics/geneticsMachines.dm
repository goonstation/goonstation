var/list/genetics_computers = list()

/obj/machinery/computer/genetics
	name = "genetics console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "scanner"
	req_access = list(access_heads) //Only used for record deletion right now.
	object_flags = CAN_REPROGRAM_ACCESS
	var/obj/machinery/genetics_scanner/scanner = null //Linked scanner. For scanning.
	var/list/equipment = list(0,0,0,0)
	// Injector, Analyser, Emitter, Reclaimer
	var/list/saved_mutations = list()
	var/list/saved_chromosomes = list()
	var/list/combining = list()
	var/datum/dna_chromosome/to_splice = null
	var/datum/bioEffect/currently_browsing = null
	var/datum/geneticsResearchEntry/tracked_research = null

	var/botbutton_html = ""
	var/info_html = ""
	var/topbotbutton_html = ""

	var/print = 0
	var/printlabel = null
	var/backpage = null

	var/registered_id = null

/obj/machinery/computer/genetics/New()
	..()
	genetics_computers += src
	SPAWN_DBG(0.5 SECONDS)
		src.scanner = locate(/obj/machinery/genetics_scanner, orange(1,src))
		return
	return

/obj/machinery/computer/genetics/disposing()
	genetics_computers -= src
	..()


/obj/machinery/computer/genetics/attackby(obj/item/W as obj, mob/user as mob)
	if (isscrewingtool(W) && ((src.status & BROKEN) || !src.scanner))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if (do_after(user, 20))
			boutput(user, "<span class='notice'>The broken glass falls out.</span>")
			var/obj/computerframe/A = new /obj/computerframe( src.loc )
			if(src.material) A.setMaterial(src.material)
			var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
			G.set_loc(src.loc)

			var/obj/item/circuitboard/genetics/M = new /obj/item/circuitboard/genetics( A )
			for (var/obj/C in src)
				C.set_loc(src.loc)
			A.circuit = M
			A.state = 3
			A.icon_state = "3"
			A.anchored = 1
			qdel(src)
	else if (istype(W,/obj/item/genetics_injector/dna_activator))
		var/obj/item/genetics_injector/dna_activator/DNA = W
		if (DNA.expended_properly)
			user.drop_item()
			qdel(DNA)

			if (genResearch.time_discount < 0.75)
				genResearch.time_discount += 0.025
			if (genResearch.cost_discount < 0.75)
				genResearch.cost_discount += 0.025

			boutput(user, "<b>SCANNER ALERT:</b> Recycled genetic info has yielded materials, auto-decryptors, and chromosomes.")
			genResearch.researchMaterial += 40
			genResearch.lock_breakers += rand(1, 3)
			var/numChromosomes = rand(1, 3) == 3 ? rand(3, 5) : rand(2, 3)
			for (var/i = 1; i <= numChromosomes; i++)
				var/type_to_make = pick(typesof(/datum/dna_chromosome))
				var/datum/dna_chromosome/C = new type_to_make(src)
				src.saved_chromosomes += C

		else
			src.attack_hand(user)
	else
		if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if (istype(W, /obj/item/card/id))
			var/obj/item/card/id/ID = W
			registered_id = ID.registered
			user.show_text("You swipe the ID on [src]. You will now recieve a cut from gene booth sales.", "blue")

		src.attack_hand(user)
	return

/obj/machinery/computer/genetics/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/genetics/attack_hand(mob/user as mob)
	if(status & (BROKEN|NOPOWER))
		return

	var/basicinfo = {"<b>Materials:</b> [genResearch.researchMaterial] (+[genResearch.checkMaterialGenerationRate()]) * "}

	botbutton_html = "<p><small>"
	var/mob/living/subject = get_scan_subject()
	if (subject)
		basicinfo += {"<b>Scanner Occupant:</b> [subject.name] - Health: [subject.health] - Stability: [subject.bioHolder.genetic_stability]"}
		botbutton_html += {"* <a href='?src=\ref[src];menu=potential'>Potential</a>"}
		botbutton_html += {" * <a href='?src=\ref[src];menu=mutations'>Mutations</a>"}
		if (ishuman(subject))
			var/mob/living/carbon/human/H = subject
			if (!istype(H.mutantrace))
				botbutton_html += {" * <a href='?src=\ref[src];menu=appearance'>Appearance</a>"}
			botbutton_html += {" * <a href='?src=\ref[src];menu=mutantrace'>Body</a>  "}
	else
		basicinfo += {"<b>Scanner Occupant:</b> None"}
	if (genResearch.debug_mode)
		if (src.get_scan_subject())
			botbutton_html += {"<a href='?src=\ref[src];debug_erase=1'>Erase Occupant</a>  "}
		else
			botbutton_html += {"<a href='?src=\ref[src];debug_create=1'>Create Occupant</a>  "}
	botbutton_html += "<br>"
	if (src.backpage)
		botbutton_html += "<a href='?src=\ref[src];menu=[src.backpage]'><b>\<</b></a> "
	botbutton_html += {"<a href='?src=\ref[src];menu=research'>Research Menu</a>  "}

	if (genResearch.isResearched(/datum/geneticsResearchEntry/checker))
		botbutton_html += {"<img alt="Analyser Cooldown" src="[resource("images/genetics/eqAnalyser.png")]" style="border-style: none">: [max(0,round((src.equipment[2] - world.time) / 10))] "}
	if (genResearch.isResearched(/datum/geneticsResearchEntry/rademitter))
		botbutton_html += {"<img alt="Emitter Cooldown" src="[resource("images/genetics/eqEmitter.png")]" style="border-style: none">: [max(0,round((src.equipment[3] - world.time) / 10))] "}
	if (genResearch.isResearched(/datum/geneticsResearchEntry/reclaimer))
		botbutton_html += {"<img alt="Reclaimer Cooldown" src="[resource("images/genetics/eqReclaimer.png")]" style="border-style: none">: [max(0,round((src.equipment[4] - world.time) / 10))] "}
	botbutton_html += {"<img alt="Injector Cooldown" src="[resource("images/genetics/eqInjector.png")]" style="border-style: none">: [max(0,round((src.equipment[1] - world.time) / 10))] "}
	if (src.tracked_research)
		botbutton_html += {"<img alt="[src.tracked_research.name]" src="[resource("images/genetics/eqResearch.png")]" style="border-style: none">: [max(0,round((src.tracked_research.finishTime - world.time) / 10))] "}

	botbutton_html += "<br>[basicinfo]"

	botbutton_html += "</small></p>"

	var/html = {"<html><head><title>GeneTek</title>
				<STYLE type=text/css>
				A:link {COLOR: #EAFDE6}
				A:visited {COLOR: #88C425}
				A:hover{COLOR: #BEF202}
				A {font-family:"Arial", sans-serif; font-size:14px; COLOR: #EAFDE6;}
				P {font-family:"Arial", sans-serif; font-size:14px; COLOR: #EAFDE6;}
				</STYLE>
				</head>
				<body style="overflow: hidden; background-color: rgb(27, 103, 107); font-family:"Arial", sans-serif; font-size:14px; COLOR: #800080;">
				<span></span>
				<big style="font-family: Helvetica,Arial,sans-serif; color: rgb(234, 253, 230); font-style: italic;">GeneTek Console v1</big>
				<table style="text-align: left; background-color: rgb(27, 103, 107); width: 700px; height: 335px;" border="0" cellpadding="0" cellspacing="0">
				<tbody><tr><td style="width: 183px;">
				<img style="width: 182px; height: 300px;" alt="" src="[resource("images/genetics/DNAorbit.gif")]"></td>
				<td><table style="text-align: left; width: 100%; height: 100%;" border="0" cellpadding="0" cellspacing="0"><tbody>
				<tr><td style="vertical-align: middle; height: 20%;">[topbotbutton_html]</td></tr>
				<tr><td valign="middle"><div style="overflow:auto;width:517px; height:240px; padding:0px 0px 0px 0px; margin:0px 0 0px 0;margin:0 auto;">[info_html]</div></td></tr>
				</tbody></table></td></tr>
				<tr><td valign="middle" align="middle"><a href='?src=\ref[src];print=1'><img alt="" src="[resource("images/genetics/gprint.png")]" style="border-style: none"></a><br>
				<a href='?src=\ref[src];printlabel=1'><small>Label: [src.printlabel ? "[src.printlabel]" : "No Label"]</small></a></td>
				<td style="vertical-align: middle; height: 40px;">[botbutton_html]</td></tr>
				</tbody></table>
				<span></span></body></html>
				"}

	user.machine = src
	add_fingerprint(user)

	if(print == 1) //Hilariously hacky temporary print thing.
		print = -1
		SPAWN_DBG (15)
			print = 0

		var/temp_html = {"
		<script language='javascript' type='text/javascript'>
		window.onload = function() {
    	var anchors = document.getElementsByTagName("a");
    	for (var i = 0; i < anchors.length; i++)
    	{
        	anchors\[i\].onclick = function() {return(false);};
        }
        };
        </script>
        "} + html

		temp_html = replacetext(temp_html, "DNAorbit.gif", "DNAorbitstatic.png")

		playsound(src.loc, "sound/machines/printer_dotmatrix.ogg", 50, 1)
		var/obj/item/paper/p = unpool(/obj/item/paper)
		p.set_loc(src.loc)

		p.sizex = 730
		p.sizey = 415
		if (src.printlabel)
			p.name = src.printlabel
		else
			p.name = "Genetics Console Paper"
		p.info = temp_html

	user << browse(html, "window=genetics;size=730x415;can_resize=0;can_minimize=0")
	onclose(user, "genetics")
	return

/obj/machinery/computer/genetics/proc/bioEffect_sanity_check(var/datum/bioEffect/E,var/occupant_check = 1)
	var/mob/living/carbon/human/H = src.get_scan_subject()
	if(occupant_check)
		if (!istype(H))
			info_html = "<p>Operation error: Invalid subject.</p>"
			src.updateUsrDialog()
			return 1
		if(!H.bioHolder)
			info_html = "<p>Operation error: Invalid genetic structure.</p>"
			src.updateUsrDialog()
			return 1
		//if(H.bioHolder.HasEffectInEither(E.id))
		//	info_html = "<p>Operation error: Gene already present in subject's DNA.</p>"
		//	src.updateUsrDialog()
		//	return 1
	if(!istype(E,/datum/bioEffect/))
		info_html = "<p>Operation error: Unrecognized gene.</p>"
		src.updateUsrDialog()
		return 1
	return 0

/obj/machinery/computer/genetics/proc/sample_sanity_check(var/datum/computer/file/genetics_scan/S)
	if (!istype(S,/datum/computer/file/genetics_scan/))
		info_html = "<p>Unable to scan DNA Sample. The sample may be corrupt.</p>"
		src.updateUsrDialog()
		return 1
	return 0

/obj/machinery/computer/genetics/proc/research_sanity_check(var/datum/geneticsResearchEntry/R)
	if (!istype(R,/datum/geneticsResearchEntry/))
		info_html = "<p>Invalid research article.</p>"
		src.updateUsrDialog()
		return 1
	return 0

/obj/machinery/computer/genetics/Topic(href, href_list)
	if (!can_reach(usr,src))
		boutput(usr, "<span class='alert'>You can't reach the computer from there.</span>")
		return
#ifdef HALLOWEEN
	if(prob(1))
		new/obj/extremely_spooky_ghost(get_turf(src))
#endif
	var/list/html_list = list()
	if(href_list["viewpool"])
		var/datum/bioEffect/E = locate(href_list["viewpool"])
		if (bioEffect_sanity_check(E)) return

		backpage = null
		src.currently_browsing = E
		topbotbutton_html = ui_build_clickable_genes("pool")

		var/datum/bioEffect/GBE = E.get_global_instance()

		html_list += {"<p><b>[GBE.research_level >= 2 ? E.name : "Unknown Mutation"]</b>"}
		if (GBE.research_level >= 2)
			if(src.equipment_available("precision_emitter",E))
				html_list += " <a href='?src=\ref[src];Prademitter=\ref[E]'><small>(Scramble)</small></a>"
			if(src.equipment_available("reclaimer",E))
				html_list += " <a href='?src=\ref[src];reclaimer=\ref[E]'><small>(Reclaim)</small></a>"
		html_list += "</p><br>"

		html_list += src.ui_build_mutation_research(E)

		html_list += "<p> Sequence: <br>"
		var/list/build = src.ui_build_sequence(E,"pool")
		html_list += "[build[1]]<br>[build[2]]<br>[build[3]]</p><br>"

		html_list += "<p><small>"
		if(E.dnaBlocks.sequenceCorrect())
			html_list += "* <a href='?src=\ref[src];activatepool=\ref[E]'>Activate</a>"
		else
			if (GBE.research_level >= 3)
				html_list += " * <a href='?src=\ref[src];autocomplete=\ref[E]'>Autocomplete</a>"
		if (src.equipment_available("activator",E) && GBE.research_level >= 2)
			html_list += " * <a href='?src=\ref[src];make_activator=\ref[E]'>Create Activator</a>"
		if (src.equipment_available("analyser"))
			html_list += " * <a href='?src=\ref[src];checkstability=\ref[E]'>Check Stability</a>"
		html_list += "</small></p>"

	else if(href_list["sample_viewpool"])
		var/datum/bioEffect/E = locate(href_list["sample_viewpool"])
		if (bioEffect_sanity_check(E,0)) return
		var/datum/computer/file/genetics_scan/sample = locate(href_list["sample_to_viewpool"])
		if (sample_sanity_check(sample)) return

		backpage = "dna_samples"
		src.currently_browsing = E
		topbotbutton_html = ui_build_clickable_genes("sample_pool",sample)

		var/datum/bioEffect/GBE = E.get_global_instance()

		html_list += {"<p><b>[GBE.research_level >= 2 ? E.name : "Unknown Mutation"]</b></p><br>"}

		html_list += src.ui_build_mutation_research(E,sample)

		html_list += "<p> Sequence : <br>"
		var/list/build = src.ui_build_sequence(E,"sample_pool")
		html_list += "[build[1]]<br>[build[2]]<br>[build[3]]</p><br>"

		if (src.equipment_available("activator",E) && GBE.research_level >= 2)
			html_list += " <p><small><a href='?src=\ref[src];make_activator=\ref[E]'>Create Activator</a></small></p>"

	else if(href_list["researched_mutation"])

		var/datum/bioEffect/E = locate(href_list["researched_mutation"])
		if (bioEffect_sanity_check(E,0)) return

		backpage = "mutresearch"
		src.currently_browsing = E

		if (E.research_level >= 3 && E.researched_desc)
			html_list += {"<p><b>[E.name]</b><br>[E.researched_desc]</p>"}
		else
			html_list += {"<p><b>[E.name]</b><br>[E.desc]</p>"}

		if (E.research_level >= 3)
			html_list += "<p> Sequence : <br>"
			var/list/build = src.ui_build_sequence(E,"active")
			html_list += "[build[1]]<br>[build[2]]<br>[build[3]]</p><br>"
		else
			html_list += "<p> This mutation needs to be activated at least once to see the sequence.</p>"

		if (src.equipment_available("activator",E) && E.research_level >= 2)
			html_list += " <p><small><a href='?src=\ref[src];make_activator=\ref[E]'>Create Activator</a></small></p>"

	else if(href_list["vieweffect"])
		var/datum/bioEffect/E = locate(href_list["vieweffect"])
		if (bioEffect_sanity_check(E)) return

		backpage = null
		var/datum/bioEffect/globalInstance = bioEffectList[E.id]
		src.currently_browsing = E
		topbotbutton_html = ui_build_clickable_genes("active")

		if(globalInstance != null)
			var/name_string = "Unknown Mutation"
			var/desc_string = "Research on a non-active instance of this gene is required."
			if (globalInstance.research_level == 3)
				name_string = globalInstance.name
				desc_string = globalInstance.desc
			else if (globalInstance.research_level == 2)
				name_string = E.name
				desc_string = E.desc
			else if (globalInstance.research_level == 1)
				desc_string = "Research on this gene is currently in progress."

			html_list += "<p><b>[name_string]</b><br>[desc_string]</p>"

			html_list += "<p> Sequence : <br>"
			var/list/build = src.ui_build_sequence(E,"active")
			html_list += "[build[1]]<br>[build[2]]<br>[build[3]]</p><br>"

			html_list += "<p><small>"
			if (src.equipment_available("injector",E))
				html_list += " * <a href='?src=\ref[src];make_injector=\ref[E]'>Create Injector</a>"
			if (src.equipment_available("genebooth",E))
				html_list += " * <a href='?src=\ref[src];send_booth=\ref[E]'>Sell at Gene Booth</a>"
			if (src.equipment_available("activator",E))
				html_list += " * <a href='?src=\ref[src];make_activator=\ref[E]'>Create Activator</a>"
			if (src.to_splice)
				html_list += " * <a href='?src=\ref[src];splice_chromosome=\ref[E]'>Splice Chromosome</a>"
			if (src.equipment_available("saver",E))
				html_list += " * <a href='?src=\ref[src];genesaver=\ref[E]'>Store</a>"
			html_list += "</small></p>"
		else
			html_list += "<p>Error attempting to read gene.</p>"

	else if(href_list["stored_mut"])
		var/datum/bioEffect/E = locate(href_list["stored_mut"])
		if (bioEffect_sanity_check(E,0)) return

		backpage = "storedmuts"
		var/datum/bioEffect/globalInstance = bioEffectList[E.id]
		src.currently_browsing = E

		if(globalInstance != null)
			var/name_string = "Unknown Mutation"
			var/desc_string = "Research on a non-active instance of this gene is required."
			if (globalInstance.research_level == 3)
				name_string = globalInstance.name
				desc_string = globalInstance.desc
			else if (globalInstance.research_level == 2)
				name_string = E.name
				desc_string = E.desc
			else if (globalInstance.research_level == 1)
				desc_string = "Research on this gene is currently in progress."

			html_list += "<p><b>[name_string]</b><br>[desc_string]</p>"

			html_list += "<p> Sequence : <br>"
			var/list/build = src.ui_build_sequence(E,"active")
			html_list += "[build[1]]<br>[build[2]]<br>[build[3]]</p><br>"

			var/mob/living/subject = get_scan_subject()
			html_list += "<p><small>* <a href='?src=\ref[src];delete_stored_mut=\ref[E]'>Delete</a>"
			if (subject)
				html_list += " * <a href='?src=\ref[src];add_stored_mut=\ref[E]'>Add to Occupant</a>"
			if (src.equipment_available("injector",E))
				html_list += " * <a href='?src=\ref[src];make_injector=\ref[E]'>Create Injector</a>"
			if (src.equipment_available("genebooth",E))
				html_list += " * <a href='?src=\ref[src];send_booth=\ref[E]'>Sell at Gene Booth</a>"
			if (src.equipment_available("activator",E))
				html_list += " * <a href='?src=\ref[src];make_activator=\ref[E]'>Create Activator</a>"
			if (src.to_splice)
				html_list += " * <a href='?src=\ref[src];splice_chromosome=\ref[E]'>Splice Chromosome</a>"
			html_list += "</small></p>"
		else
			html_list += "<p>Error attempting to read gene.</p>"

	else if(href_list["stored_chromosome"])
		var/datum/dna_chromosome/E = locate(href_list["stored_chromosome"])
		if (!istype(E)) return
		backpage = "chromosomes"

		html_list += "<p><b>[E.name]</b><br>[E.desc]</p>"
		if (src.to_splice != E)
			html_list += "<small><a href='?src=\ref[src];splice_stored_chromosome=\ref[E]'>Mark for Splicing</a>"
		html_list += " <a href='?src=\ref[src];delete_stored_chromosome=\ref[E]'>Delete</a></small>"

	else if(href_list["splice_chromosome"])
		var/datum/bioEffect/E = locate(href_list["splice_chromosome"])
		if (bioEffect_sanity_check(E,0)) return
		if (!src.to_splice) return
		var/datum/dna_chromosome/C = src.to_splice

		var/result = C.apply(E)
		if(istext(result))
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Splice failed: [result]</span>")
		else
			boutput(usr, "<span class='notice'><b>SCANNER ALERT:</b> Splice successful.</span>")
			src.saved_chromosomes -= C
			qdel(C)
			src.to_splice = null
		usr << link("byond://?src=\ref[src];menu=research")

	else if(href_list["splice_stored_chromosome"])
		var/datum/dna_chromosome/E = locate(href_list["splice_stored_chromosome"])
		if (!istype(E)) return
		if (!saved_chromosomes.Find(E))
			message_admins("[key_name(usr)] tried to splice a chromosome ([E]) but failed href validation (maybe they're a dirty cheat)!")
			logTheThing("debug", usr, null, "tried to splice a chromosome ([E]) but failed href validation.")
			logTheThing("diary", usr, null, "tried to splice a chromosome ([E]) but failed href validation.", "debug")
			return

		src.to_splice = E
		boutput(usr, "<b>SCANNER ALERT:</b> Chromosome marked for splicing.")
		usr << link("byond://?src=\ref[src];stored_chromosome=\ref[E]")

	else if(href_list["delete_stored_mut"])
		var/datum/bioEffect/E = locate(href_list["delete_stored_mut"])
		if (bioEffect_sanity_check(E,0)) return
		if (!saved_mutations.Find(E))
			message_admins("[key_name(usr)] tried to delete the [E.id] mutation but failed href validation (maybe they're a dirty cheat)!")
			logTheThing("debug", usr, null, "tried to delete the [E.id] mutation but failed href validation.")
			logTheThing("diary", usr, null, "tried to delete the [E.id] mutation but failed href validation.", "debug")
			return

		backpage = "research"

		saved_mutations -= E
		qdel(E)
		boutput(usr, "<b>SCANNER ALERT:</b> Mutation deleted.")
		usr << link("byond://?src=\ref[src];menu=storedmuts")

	else if(href_list["delete_stored_chromosome"])
		var/datum/dna_chromosome/E = locate(href_list["delete_stored_chromosome"])
		if (!istype(E)) return
		backpage = "chromosomes"
		if (!saved_chromosomes.Find(E))
			message_admins("[key_name(usr)] tried to delete a chromosome ([E]) but failed href validation (maybe they're a dirty cheat)!")
			logTheThing("debug", usr, null, "tried to delete a chromosome ([E]) but failed href validation.")
			logTheThing("diary", usr, null, "tried to delete a chromosome ([E]) but failed href validation.", "debug")
			return

		if (E == src.to_splice)
			src.to_splice = null
		saved_chromosomes -= E
		qdel(E)
		boutput(usr, "<b>SCANNER ALERT:</b> Chromosome deleted.")
		usr << link("byond://?src=\ref[src];menu=chromosomes")

	else if(href_list["add_stored_mut"])
		var/datum/bioEffect/E = locate(href_list["add_stored_mut"])
		if (bioEffect_sanity_check(E)) return
		if (!saved_mutations.Find(E))
			message_admins("[key_name(usr)] tried to add the [E.id] mutation but failed href validation (maybe they're a dirty cheat)!")
			logTheThing("debug", usr, null, "tried to add the [E.id] mutation but failed href validation.")
			logTheThing("diary", usr, null, "tried to add the [E.id] mutation but failed href validation.", "debug")
			return

		backpage = null
		var/mob/living/subject = get_scan_subject()
		if (!subject)
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Subject not found.</span>")
			return

		src.log_me(subject, "mutation added", E)

		subject.bioHolder.AddEffectInstance(E)
		saved_mutations -= E
		boutput(usr, "<b>SCANNER ALERT:</b> Mutation successfully added to occupant.")
		usr << link("byond://?src=\ref[src];menu=mutations")

	else if(href_list["mark_for_combination"])
		var/datum/bioEffect/E = locate(href_list["mark_for_combination"])
		if (bioEffect_sanity_check(E,0)) return

		if (E in combining)
			combining -= E
		else
			combining += E

		usr << link("byond://?src=\ref[src];menu=combinemuts")

	else if(href_list["do_combine"])
		var/matches = 0
		for (var/datum/geneticsrecipe/GR in genResearch.combinationrecipes)
			matches = 0
			if (GR.required_effects.len != combining.len)
				continue
			var/list/temp = GR.required_effects.Copy()
			for (var/datum/bioEffect/BE in combining)
				if (BE.wildcard)
					matches++
				if (BE.id in temp)
					temp -= BE.id
					matches++
			if (matches == GR.required_effects.len)
				var/datum/bioEffect/NEWBE = new GR.result(src)
				saved_mutations += NEWBE
				var/datum/bioEffect/GBE = NEWBE.get_global_instance()
				GBE.research_level = max(GBE.research_level,3) // counts as researching it
				for (var/X in combining)
					saved_mutations -= X
					combining -= X
					qdel(X)
				boutput(usr, "<b>SCANNER ALERT:</b> Combination successful. New [NEWBE.name] mutation created.")
				usr << link("byond://?src=\ref[src];menu=storedmuts")
				return

		boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Combination unsuccessful.</span>")
		combining = list()
		usr << link("byond://?src=\ref[src];menu=storedmuts")
		return

	else if(href_list["cancel_combine"])
		backpage = "research"
		combining = list()
		usr << link("byond://?src=\ref[src];menu=storedmuts")

	else if(href_list["make_injector"])
		if (!genResearch.isResearched(/datum/geneticsResearchEntry/injector))
			return

		var/datum/bioEffect/E = locate(href_list["make_injector"])
		if (bioEffect_sanity_check(E,0)) return
		var/mob/living/L = get_scan_subject()
		//if (!L.bioHolder.HasEffect(E.id) && !saved_mutations.Find(E))
		if (!((L && L.bioHolder && L.bioHolder.HasEffect(E.id)) || saved_mutations.Find(E)))
			message_admins("[key_name(usr)] tried to create a [E.id] injector but failed href validation (maybe they're a dirty cheat)!")
			logTheThing("debug", usr, null, "tried to create a [E.id] injector but failed href validation.")
			logTheThing("diary", usr, null, "tried to create a [E.id] injector but failed href validation.", "debug")
			return

		if (!src.equipment_available("injector",E))
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> That equipment is on cooldown.</span>")
			return

		var/price = genResearch.injector_cost
		if (genResearch.researchMaterial < price)
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Not enough research materials to manufacture an injector.</span>")
			return
		if (!E.can_make_injector)
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Cannot make an injector using this gene.</span>")
			return

		src.equipment_cooldown(1,400)

		genResearch.researchMaterial -= price
		var/obj/item/genetics_injector/dna_injector/I = new /obj/item/genetics_injector/dna_injector(src.loc)
		I.name = "dna injector - [E.name]"
		var/datum/bioEffect/NEW = new E.type(I)
		copy_datum_vars(E,NEW)
		I.BE = NEW // valid. still, wtf

		SPAWN_DBG(0)
			if (backpage == "storedmuts")
				usr << link("byond://?src=\ref[src];stored_mut=\ref[E]")
			else
				usr << link("byond://?src=\ref[src];vieweffect=\ref[E]")

	else if(href_list["send_booth"])
		if (!genResearch.isResearched(/datum/geneticsResearchEntry/genebooth))
			return

		var/datum/bioEffect/E = locate(href_list["send_booth"])
		if (bioEffect_sanity_check(E,0)) return
		var/mob/living/L = get_scan_subject()
		if (!((L && L.bioHolder && L.bioHolder.HasEffect(E.id)) || saved_mutations.Find(E)))
			message_admins("[key_name(usr)] tried to create a [E.id] injector but failed href validation (maybe they're a dirty cheat)!")
			logTheThing("debug", usr, null, "tried to create a [E.id] injector but failed href validation.")
			logTheThing("diary", usr, null, "tried to create a [E.id] injector but failed href validation.", "debug")
			return

		if (!src.equipment_available("genebooth",E))
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> That equipment is not connected.</span>")
			return

		var/price = genResearch.genebooth_cost
		if (genResearch.researchMaterial < price)
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Not enough research materials to manufacture an injector.</span>")
			return
		if (!E.can_make_injector)
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Cannot sell this gene.</span>")
			return

		//src.equipment_cooldown(1,400)

		genResearch.researchMaterial -= price

		var/booth_effect_cost = input(usr, "Please enter a price to sell this effect.", "$$$", 200) as null|num
		booth_effect_cost = max(0,booth_effect_cost)
		booth_effect_cost = min(999999, booth_effect_cost)

		var/booth_effect_desc = input(usr, "Please enter a product description.", "$$$", "") as null|text
		booth_effect_desc = strip_html(booth_effect_desc,280)

		for (var/obj/machinery/genetics_booth/GB in genetics_computers)
			var/already_has = 0
			for (var/datum/geneboothproduct/P in GB.offered_genes)
				if (P.id == E.id)
					already_has = P
					P.uses += 5
					P.desc = booth_effect_desc
					P.cost = booth_effect_cost
					P.registered_sale_id = registered_id
					boutput(usr, "<span class='notice'>Sent 5 of '[P.name]' to gene booth.</span>")
					GB.reload_contexts()
					break

			if (!already_has)
				var/datum/bioEffect/NEW = new E.type(GB)
				copy_datum_vars(E,NEW)
				GB.offered_genes += new /datum/geneboothproduct(NEW,booth_effect_desc,booth_effect_cost,registered_id) //uses will start at 5
				if (GB.offered_genes.len == 1)
					GB.just_pick_anything()
				boutput(usr, "<span class='notice'>Sent 5 of '[NEW.name]' to gene booth.</span>")
				GB.reload_contexts()

		SPAWN_DBG(0)
			if (backpage == "storedmuts")
				usr << link("byond://?src=\ref[src];stored_mut=\ref[E]")
			else
				usr << link("byond://?src=\ref[src];vieweffect=\ref[E]")

	else if(href_list["make_activator"])
		var/datum/bioEffect/E = locate(href_list["make_activator"])
		var/datum/bioEffect/GBE = E.get_global_instance()
		if (GBE.research_level <= 1)
			message_admins("[key_name(usr)] tried to create a [E.id] activator on an unresearched gene (href spoofing, they may be a shit)!")
			logTheThing("debug", usr, null, "tried to create a [E.id] activator on an unresearched gene (href spoofing?).")
			logTheThing("diary", usr, null, "tried to create a [E.id] activator on an unresearched gene (href spoofing?).", "debug")
			return
		if (bioEffect_sanity_check(E,0)) return
		if (!src.equipment_available("activator",E))
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> That equipment is on cooldown.</span>")
			return

		if (!E.can_make_injector)
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Cannot make an activator using this gene.</span>")
			return
		src.equipment_cooldown(1,200)

		var/obj/item/genetics_injector/dna_activator/I = new /obj/item/genetics_injector/dna_activator(src.loc)
		I.name = "dna activator - [E.name]"
		I.gene_to_activate = E.id
		src.updateUsrDialog()
		return

	else if(href_list["genesaver"])
		if (!genResearch.isResearched(/datum/geneticsResearchEntry/saver))
			return

		var/datum/bioEffect/E = locate(href_list["genesaver"])
		if (bioEffect_sanity_check(E)) return
		var/mob/living/subject = get_scan_subject()
		if(!subject.bioHolder.HasEffect(E.id))
			message_admins("[key_name(usr)] tried to store a [E.id] mutation but failed href validation (maybe they're a dirty cheat)!")
			logTheThing("debug", usr, null, "tried to store a [E.id] mutation but failed href validation.")
			logTheThing("diary", usr, null, "tried to store a [E.id] mutation but failed href validation.", "debug")
			return

		if (saved_mutations.len >= genResearch.max_save_slots)
			boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> No more room in this scanner for stored mutations.</span>")
			return

		src.log_me(subject, "mutation removed", E)

		src.saved_mutations += E
		subject.bioHolder.RemoveEffect(E.id)
		E.owner = null
		E.holder = null
		boutput(usr, "<b>SCANNER ALERT:</b> Mutation stored successfully.")
		usr << link("byond://?src=\ref[src];menu=mutations")

	else if(href_list["checkstability"])
		if (!src.equipment_available("analyser"))
			return

		var/datum/bioEffect/E = locate(href_list["checkstability"])
		if (bioEffect_sanity_check(E)) return

		for(var/i=0, i < E.dnaBlocks.blockListCurr.len, i++)
			var/datum/basePair/bp = E.dnaBlocks.blockListCurr[i+1]
			var/datum/basePair/bpc = E.dnaBlocks.blockList[i+1]
			if (bp.marker == "locked")
				continue
			if (bp.bpp1 == bpc.bpp1 && bp.bpp2 == bpc.bpp2)
				bp.marker = "blue"
			else
				bp.marker = "red"
		src.equipment_cooldown(2,200)

		usr << link("byond://?src=\ref[src];viewpool=\ref[E]")

	else if(href_list["rademitter"])
		if (!src.equipment_available("emitter"))
			return
		topbotbutton_html = ""
		var/mob/living/subject = get_scan_subject()
		if(!subject)
			boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
			return
		if(subject.health <= 0)
			boutput(usr, "<b>SCANNER ALERT:</b> Emitter cannot be used on dead or dying patients.")
			return

		src.log_me(subject, "DNA scrambled")

		subject.bioHolder.RemoveAllEffects()
		subject.bioHolder.BuildEffectPool()
		if (genResearch.emitter_radiation > 0)
			subject.changeStatus("radiation", (genResearch.emitter_radiation*10), 3)
		if (prob(genResearch.emitter_radiation * 0.5) && ismonkey(subject) && !subject:ai_active)
			subject:ai_init()

		src.equipment_cooldown(3,1200)

		boutput(usr, "<B>SCANNER:</B> Genes successfully scrambled.")

		usr << link("byond://?src=\ref[src];menu=potential")

	else if(href_list["Prademitter"])
		var/datum/bioEffect/E = locate(href_list["Prademitter"])
		if (bioEffect_sanity_check(E)) return
		if (!src.equipment_available("precision_emitter",E))
			return

		var/mob/living/subject = get_scan_subject()
		if(!subject)
			boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
			return
		if(subject.stat)
			boutput(usr, "<b>SCANNER ALERT:</b> Emitter cannot be used on dead or dying patients.")
			return

		src.log_me(subject, "DNA scrambled")

		topbotbutton_html = ""

		if (genResearch.emitter_radiation > 0)
			subject.changeStatus("radiation", (genResearch.emitter_radiation*10), 3)
		subject.bioHolder.RemovePoolEffect(E)
		subject.bioHolder.AddRandomNewPoolEffect()

		src.equipment_cooldown(3,600)

		boutput(usr, "<b>SCANNER ALERT:</b> Gene successfully scrambled.")
		usr << link("byond://?src=\ref[src];menu=potential")

	else if(href_list["reclaimer"])
		var/datum/bioEffect/E = locate(href_list["reclaimer"])
		if (bioEffect_sanity_check(E)) return
		if (!src.equipment_available("reclaimer",E))
			return

		var/mob/living/subject = get_scan_subject()
		if(!subject)
			boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
			return

		var/reclamation_cap = genResearch.max_material * 1.5
		if (prob(E.reclaim_fail))
			boutput(usr, "<b>SCANNER:</b> Reclamation failed.")
		else
			var/waste = (E.reclaim_mats + genResearch.researchMaterial) - reclamation_cap
			if (waste == E.reclaim_mats)
				boutput(usr, "<b>SCANNER ALERT:</b> Nothing would be gained from reclamation due to material capacity limit. Reclamation aborted.")
				return
			else
				genResearch.researchMaterial = min(genResearch.researchMaterial + E.reclaim_mats, reclamation_cap)
				if (waste > 0)
					boutput(usr, "<b>SCANNER:</b> Reclamation successful. [E.reclaim_mats] materials gained. Material count now at [genResearch.researchMaterial]. [waste] units of material wasted due to material capacity limit.")
				else
					boutput(usr, "<b>SCANNER:</b> Reclamation successful. [E.reclaim_mats] materials gained. Material count now at [genResearch.researchMaterial].")
				subject.bioHolder.RemovePoolEffect(E)

		src.equipment_cooldown(4,600)
		src.currently_browsing = null
		usr << link("byond://?src=\ref[src];menu=potential")

	else if(href_list["print"] && print != -1)
		print = 1

	else if(href_list["printlabel"])
		var/label = input("Automatically label printouts as what?","[src.name]",src.printlabel) as null|text
		label = copytext(html_encode(label), 1, 65)
		if (!label)
			src.printlabel = null
		else
			src.printlabel = label
			playsound(src.loc, "keyboard", 50, 1, 5)

	else if(href_list["setseq"])

		var/datum/bioEffect/E = locate(href_list["setseq"])
		if (bioEffect_sanity_check(E)) return

		var/mob/living/subject = get_scan_subject()
		if(!subject)
			boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
			return

		E = subject.bioHolder.GetEffectFromPool(E.id)
		if(E)
			if (istext(E.req_mut_research) && GetBioeffectResearchLevelFromGlobalListByID(E.id) < 2)
				boutput(usr, "<span class='alert'><b>SCANNER ERROR:</b> Genetic structure unknown. Cannot alter mutation.</span>")
				return
			if(href_list["setseq1"])
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[text2num(href_list["setseq1"])]
				if (!bp || bp.marker == "locked")
					boutput(usr, "<span class='alert'><b>SCANNER ERROR:</b> Cannot alter encrypted base pairs. Click lock to attempt decryption.</span>")
					return
			else if(href_list["setseq2"])
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[text2num(href_list["setseq2"])]
				if (!bp || bp.marker == "locked")
					boutput(usr, "<span class='alert'><b>SCANNER ERROR:</b> Cannot alter encrypted base pairs. Click lock to attempt decryption.</span>")
					return

		var/input = input(usr, "Select:", "[src.name]","Swap") as null|anything in list("Swap","G","C","A","T","G>C","C>G","A>T","T>A")
		if(!input)
			return

		if(!subject)
			boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
			return

		var/temp_holder = null

		if(E.id && subject.bioHolder.HasEffectInPool(E.id)) //Change this to occupant and check if empty aswell. ZeWaka: Fix for null.id
			var/datum/basePair/bp
			var/clicked = 1

			if(href_list["setseq1"])
				clicked = 1
				bp = E.dnaBlocks.blockListCurr[text2num(href_list["setseq1"])]
			else if(href_list["setseq2"])
				clicked = 2
				bp = E.dnaBlocks.blockListCurr[text2num(href_list["setseq2"])]

			if (input == "Swap")
				temp_holder = bp.bpp1
				bp.bpp1 = bp.bpp2
				bp.bpp2 = temp_holder
			else if (findtext(input,">"))
				bp.bpp1 = copytext(input,1,2)
				bp.bpp2 = copytext(input,3,4)
			else
				if (clicked == 1) bp.bpp1 = input
				else bp.bpp2 = input

		if (E.dnaBlocks.sequenceCorrect())
			E.dnaBlocks.ChangeAllMarkers("white")

		usr << link("byond://?src=\ref[src];viewpool=\ref[E]")
		//OH MAN LOOK AT THIS CRAP. FUCK BYOND. (This refreshes the page)
		return

	else if(href_list["marker"])
		var/datum/bioEffect/E = locate(href_list["marker"])
		if (bioEffect_sanity_check(E)) return
		var/mob/living/subject = get_scan_subject()
		if(!subject)
			boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
			return
		var/datum/basePair/bp = E.dnaBlocks.blockListCurr[text2num(href_list["themark"])]
		if (istext(E.req_mut_research) && GetBioeffectResearchLevelFromGlobalListByID(E.id) < 2)
			boutput(usr, "<span class='alert'><b>SCANNER ERROR:</b> Genetic structure unknown. Cannot alter mutation.</span>")
			return

		if(bp.marker == "locked")
			boutput(usr, "<span class='notice'><b>SCANNER ALERT:</b> Encryption is a [E.lockedDiff]-character code.</span>")
			var/characters = ""
			for(var/X in E.lockedChars)
				characters += "[X] "
			boutput(usr, "<span class='notice'>Possible characters in this code: [characters]</span>")
			if(genResearch.lock_breakers > 0)
				boutput(usr, "<span class='notice'>[genResearch.lock_breakers] auto-decryptions available. Enter UNLOCK as the code to expend one.</span>")
			var/code = input("Enter decryption code.","Genetic Decryption") as null|text
			if(!code)
				return
			code = uppertext(code)
			if (code == "UNLOCK")
				if(genResearch.lock_breakers > 0)
					genResearch.lock_breakers--
					var/datum/basePair/bpc = E.dnaBlocks.blockList[text2num(href_list["themark"])]
					bp.bpp1 = bpc.bpp1
					bp.bpp2 = bpc.bpp2
					bp.marker = "green"
					boutput(usr, "<span class='notice'><b>SCANNER ALERT:</b> Base pair unlocked.</span>")
					if (E.dnaBlocks.sequenceCorrect())
						E.dnaBlocks.ChangeAllMarkers("white")
					usr << link("byond://?src=\ref[src];viewpool=\ref[E]")
					return
				else
					boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> No automatic decryptions available.</span>")
					return

			if(lentext(code) != lentext(bp.lockcode))
				boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Invalid code length.</span>")
				return
			if (code == bp.lockcode)
				var/datum/basePair/bpc = E.dnaBlocks.blockList[text2num(href_list["themark"])]
				bp.bpp1 = bpc.bpp1
				bp.bpp2 = bpc.bpp2
				bp.marker = "green"
				boutput(usr, "<span class='notice'><b>SCANNER ALERT:</b> Decryption successful. Base pair unlocked.</span>")
				if (E.dnaBlocks.sequenceCorrect())
					E.dnaBlocks.ChangeAllMarkers("white")
			else
				if (bp.locktries <= 1)
					bp.lockcode = ""
					for (var/c = E.lockedDiff, c > 0, c--)
						bp.lockcode += pick(E.lockedChars)
					bp.locktries = E.lockedTries
					boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Decryption failed. Base pair encryption code has mutated.</span>")
				else
					bp.locktries--
					var/length = lentext(bp.lockcode)

					var/list/lockcode_list = list()
					for(var/i=0,i < length,i++)
						lockcode_list["[copytext(bp.lockcode,i+1,i+2)]"]++

					var/correct_full = 0
					var/correct_char = 0
					var/current
					var/seek = 0
					for(var/i=0,i < length,i++)
						current = copytext(code,i+1,i+2)
						if (current == copytext(bp.lockcode,i+1,i+2))
							correct_full++
						seek = lockcode_list.Find(current)
						if (seek)
							correct_char++
							lockcode_list[current]--
							if (lockcode_list[current] <= 0)
								lockcode_list -= current

					boutput(usr, "<span class='alert'><b>SCANNER ALERT:</b> Decryption code \"[code]\" failed.</span>")
					boutput(usr, "<span class='alert'>[correct_char]/[length] correct characters in entered code.</span>")
					boutput(usr, "<span class='alert'>[correct_full]/[length] characters in correct position.</span>")
					boutput(usr, "<span class='alert'>Attempts remaining: [bp.locktries].</span>")
		else
			switch(bp.marker)
				if("green")
					bp.marker = "red"
				if("red")
					bp.marker = "blue"
				if("blue")
					bp.marker = "green"
		usr << link("byond://?src=\ref[src];viewpool=\ref[E]") // i hear ya buddy =(
		return

	else if(href_list["activatepool"])
		var/datum/bioEffect/E = locate(href_list["activatepool"])
		if (bioEffect_sanity_check(E)) return
		if (!E.dnaBlocks.sequenceCorrect())
			return
		var/mob/living/subject = get_scan_subject()

		src.log_me(subject, "mutation activated", E)

		subject.bioHolder.ActivatePoolEffect(E)
		usr << link("byond://?src=\ref[src];menu=mutations")
		//send them to the mutations page.
		return

	else if(href_list["autocomplete"])
		var/datum/bioEffect/E = locate(href_list["autocomplete"])
		if (bioEffect_sanity_check(E)) return
		var/mob/living/subject = get_scan_subject()
		if (!subject)
			return
		var/datum/basePair/current
		var/datum/basePair/correct
		for(var/i=0, i < E.dnaBlocks.blockListCurr.len, i++)
			current = E.dnaBlocks.blockListCurr[i+1]
			correct = E.dnaBlocks.blockList[i+1]
			if (current.marker == "locked")
				continue
			current.bpp1 = correct.bpp1
			current.bpp2 = correct.bpp2
			current.marker = "white"
		usr << link("byond://?src=\ref[src];viewpool=\ref[E]")
		return

	else if(href_list["viewopenres"])
		var/datum/geneticsResearchEntry/E = locate(href_list["viewopenres"])
		if (research_sanity_check(E)) return
		backpage = "resopen"

		topbotbutton_html = ""
		html_list += {"
		<p>[E.name]<br><br>
		[E.desc]</p><br><br>
		<a href='?src=\ref[src];research=\ref[E]'>Research now</a>"}

	else if(href_list["researchmut"])
		var/datum/bioEffect/E = locate(href_list["researchmut"])
		if (bioEffect_sanity_check(E)) return

		topbotbutton_html = ""
		if (!genResearch.addResearch(E))
			boutput(usr, "<b>SCANNER ERROR: Unable to begin research.</b>")
		else
			boutput(usr, "<b>SCANNER:</b> Research initiated successfully.")
		usr << link("byond://?src=\ref[src];viewpool=\ref[E]")
		return

	else if(href_list["researchmut_sample"])
		var/datum/bioEffect/E = locate(href_list["researchmut_sample"])
		if (bioEffect_sanity_check(E,0)) return
		var/datum/computer/file/genetics_scan/sample = locate(href_list["sample_to_research"])
		if (sample_sanity_check(sample)) return

		if (!genResearch.addResearch(E))
			boutput(usr, "<span class='alert'><b>SCANNER ERROR:</b> Unable to begin research.</span>")
		else
			boutput(usr, "<b>SCANNER:</b> Research initiated successfully.")

		usr << link("byond://?src=\ref[src];sample_viewpool=\ref[E];sample_to_viewpool=\ref[sample]")
		return

	else if(href_list["research"])
		var/datum/geneticsResearchEntry/E = locate(href_list["research"])
		if (research_sanity_check(E)) return

		topbotbutton_html = ""
		if(genResearch.addResearch(E))
			boutput(usr, "<b>SCANNER:</b> Research initiated successfully.")
			usr << link("byond://?src=\ref[src];menu=resopen")
		else
			boutput(usr, "<span class='alert'><b>SCANNER ERROR:</b> Unable to begin research.</span>")
		return

	else if(href_list["track_research"])
		var/datum/geneticsResearchEntry/R = locate(href_list["track_research"])
		if (!istype(R,/datum/geneticsResearchEntry/))
			return
		src.tracked_research = R
		usr << link("byond://?src=\ref[src];menu=resrunning")
		return

	else if(href_list["debug_erase"])
		if (!genResearch.debug_mode)
			return

		var/mob/subject = get_scan_subject()
		if (scanner)
			scanner.go_out()
		else if (istype(src,/obj/machinery/computer/genetics/portable/))
			var/obj/machinery/computer/genetics/portable/please = src
			please.go_out()
		SPAWN_DBG(0)
			qdel(subject)

	else if(href_list["debug_create"])
		if (!genResearch.debug_mode)
			return

		if (get_scan_subject())
			return
		var/mob/subject

		if (scanner)
			subject = new /mob/living/carbon/human(get_turf(src))
			scanner.go_in(subject)
		else if (istype(src,/obj/machinery/computer/genetics/portable/))
			var/obj/machinery/computer/genetics/portable/please = src
			subject = new /mob/living/carbon/human(get_turf(src))
			please.go_in(subject)
		else
			return

	else if(href_list["menu"])
		switch(href_list["menu"])
			if("potential")
				var/mob/living/subject = get_scan_subject()
				if(!subject)
					boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
					return
				topbotbutton_html = ""
				backpage = null

				topbotbutton_html = ui_build_clickable_genes("pool")

				html_list += "<p><b>Occupant</b>: [subject ? "[subject.name]" : "None"]</p><br>"
				html_list += "<p>Showing potential mutations</p><br>"
				if(src.equipment_available("emitter"))
					html_list += "<a href='?src=\ref[src];rademitter=1'>Scramble DNA</a>"

			if("sample_potential")
				topbotbutton_html = ""

				var/datum/computer/file/genetics_scan/sample = locate(href_list["sample_to_view_potential"])
				if (sample_sanity_check(sample)) return

				topbotbutton_html = ui_build_clickable_genes("sample_pool",sample)

				html_list += "<p><b>Sample</b>: [sample.subject_name] <small>([sample.subject_uID])</small></p><br>"
				html_list += "<p>Showing potential mutations <small><a href='?src=\ref[src];menu=dna_samples'>(Back)</a></small></p><br>"

			if("mutations")
				var/mob/living/subject = get_scan_subject()
				if(!subject)
					boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
					return
				topbotbutton_html = ""
				backpage = null

				topbotbutton_html = ui_build_clickable_genes("active")

				html_list += "<p><b>Occupant</b>: [subject ? "[subject.name]" : "None"]</p><br>"
				html_list += "<p>Showing active mutations</p>"

			if("research")
				backpage = null
				topbotbutton_html = "<p><b>Research Menu</b><br>"
				topbotbutton_html += "<b>Research Material:</b> [genResearch.researchMaterial]/[genResearch.max_material]<br>"
				topbotbutton_html += "<b>Research Budget:</b> [wagesystem.research_budget] Credits<br>"
				topbotbutton_html += "<b>Mutations Researched:</b> [genResearch.mutations_researched]<br>"
				if (genResearch.isResearched(/datum/geneticsResearchEntry/saver))
					topbotbutton_html += "<b>Mutations Stored:</b> [saved_mutations.len]/[genResearch.max_save_slots]</p>"

				html_list += "<br>"
				html_list += "<a href='?src=\ref[src];menu=buymats'>Purchase Additional Materials</a><br>"
				html_list += "<a href='?src=\ref[src];menu=resopen'>Available Research</a><br>"
				html_list += "<a href='?src=\ref[src];menu=resrunning'>Research in Progress</a><br>"
				html_list += "<a href='?src=\ref[src];menu=mutresearch'>Researched Mutations</a><br>"
				if (genResearch.isResearched(/datum/geneticsResearchEntry/saver))
					html_list += "<a href='?src=\ref[src];menu=storedmuts'>Stored Mutations</a><br>"
				html_list += "<a href='?src=\ref[src];menu=chromosomes'>Stored Chromosomes</a><br>"
				html_list += "<a href='?src=\ref[src];menu=dna_samples'>View DNA Samples</a><br>"
				html_list += "<a href='?src=\ref[src];menu=resfin'>Finished Research</a><br>"

			if("resopen")
				backpage = "research"
				topbotbutton_html = "<p><b>Available Research</b> - ([genResearch.researchMaterial] Research Materials)</p>"
				var/lastTier = -1
				html_list += ""
				for(var/R in genResearch.researchTreeTiered)
					if(text2num(R) == 0) continue
					var/list/tierList = genResearch.researchTreeTiered[R]
					if(text2num(R) != lastTier)
						html_list += "[html_list.len > 1 ? "<br>" : ""]<p><b>Tier [text2num(R)]:</b></p>"

					for(var/datum/geneticsResearchEntry/C in tierList)
						if(!C.meetsRequirements())
							continue

						var/research_cost = C.researchCost
						if (genResearch.cost_discount)
							research_cost -= round(research_cost * genResearch.cost_discount)
						var/research_time = C.researchTime
						if (genResearch.time_discount)
							research_time -= round(research_time * genResearch.time_discount)
						if (research_time)
							research_time = round(research_time / 10)

						html_list += "<a href='?src=\ref[src];viewopenres=\ref[C]'>� [C.name] (Cost: [research_cost] * Time: [research_time] sec)</a><br>"

			if("resrunning")
				backpage = "research"
				topbotbutton_html = "<p><b>Research in Progress</b></p>"
				html_list += "<p>"
				for(var/datum/geneticsResearchEntry/R in genResearch.currentResearch)
					html_list += "� [R.name] - [round((R.finishTime - world.time) / 10)] seconds left."
					if (R != src.tracked_research)
						html_list += " <small><a href='?src=\ref[src];track_research=\ref[R]'>(Track)</a></small>"
					html_list += "<br>"
				html_list += "</p>"

			if("buymats")
				var/amount = input("50 credits per 1 point.","Buying Materials") as null|num
				if (amount + genResearch.researchMaterial > genResearch.max_material)
					amount = genResearch.max_material - genResearch.researchMaterial
					boutput(usr, "You cannot exceed [genResearch.max_material] research materials with this option.")
				if (!amount || amount <= 0)
					return

				var/cost = amount * 50
				if (cost > wagesystem.research_budget)
					html_list += "<p>Insufficient research budget to make that transaction.</p>"
				else
					html_list += "<p>Transaction successful.</p>"
					wagesystem.research_budget -= cost
					genResearch.researchMaterial += amount

			if("mutresearch")
				topbotbutton_html = "<p><b>Mutation Research</b></p>"

				backpage = "research"
				html_list += "<p>"
				var/datum/bioEffect/BE
				for(var/X in bioEffectList)
					BE = bioEffectList[X]
					if (!BE.scanner_visibility || BE.research_level < 2)
						continue
					if (BE.research_level == 2)
						html_list += "- <a href='?src=\ref[src];researched_mutation=\ref[BE]'>[BE.name]</a><br>"
					else if (BE.research_level == 3)
						html_list += "* <a href='?src=\ref[src];researched_mutation=\ref[BE]'>[BE.name]</a><br>"
				html_list += "</p>"

			if("storedmuts")
				topbotbutton_html = "<p><b>Stored Mutations: [saved_mutations.len]/[genResearch.max_save_slots]</b></p>"

				backpage = "research"
				html_list += "<p><a href='?src=\ref[src];menu=combinemuts'>Combine Mutations</a><br><br>"
				var/slot = 1
				for(var/datum/bioEffect/BE in saved_mutations)
					html_list += "<a href='?src=\ref[src];stored_mut=\ref[BE]'><b>Slot [slot]:</b> [BE.name]</a><br>"
					slot++
				html_list += "</p>"

			if("chromosomes")
				topbotbutton_html = "<p><b>Stored Chromosomes</b></p>"

				backpage = "research"
				html_list += ""
				var/slot = 1
				for(var/datum/dna_chromosome/C in src.saved_chromosomes)
					html_list += "<a href='?src=\ref[src];stored_chromosome=\ref[C]'><b>[slot]:</b> [C.name]</a><br>"
					slot++
				html_list += "</p>"

			if("combinemuts")
				topbotbutton_html = "<p><b>Combine Mutations: [saved_mutations.len]/[genResearch.max_save_slots]</b></p>"

				backpage = "storedmuts"
				html_list += "<p>"
				var/slot = 1
				html_list += "<a href='?src=\ref[src];do_combine=1'>Combine Marked Mutations</a><br>"
				html_list += "<a href='?src=\ref[src];cancel_combine=1'>Cancel</a><br><br>"

				for(var/datum/bioEffect/BE in saved_mutations)
					html_list += "<a href='?src=\ref[src];mark_for_combination=\ref[BE]'><b>Slot [slot]:</b> [BE.name]</a>"
					if (BE in combining)
						html_list += " *"
					html_list += "<br>"
					slot++

				html_list += "</p>"

			if("resfin")
				topbotbutton_html = "<p><b>Finished Research</b></p>"
				var/lastTier = -1
				backpage = "research"
				html_list += "<p>"
				for(var/R in genResearch.researchTreeTiered)
					if(text2num(R) == 0) continue
					var/list/tierList = genResearch.researchTreeTiered[R]
					if(text2num(R) != lastTier)
						html_list += "[html_list.len ? "<br>" : ""]<b>Tier [text2num(R)]:</b><br>"

					for(var/datum/geneticsResearchEntry/C in tierList)
						if(C.isResearched == 0 || C.isResearched == -1) continue
						html_list += "� [C.name]<br>"
				html_list += "</p>"

			if("dna_samples")
				backpage = "research"
				topbotbutton_html = "<p><b>DNA Samples</b></p>"

				html_list += "<p>"
				var/datum/computer/file/genetics_scan/S = null
				for(var/datum/data/record/R in data_core.medical)
					S = R.fields["dnasample"]
					if (!istype(S))
						continue
					html_list += "* <a href='?src=\ref[src];menu=sample_potential;sample_to_view_potential=\ref[S]'>[S.subject_name]</a><br>"
				html_list += "</p>"

			if("appearance")
				topbotbutton_html = ""
				var/mob/living/subject = get_scan_subject()
				if(!subject)
					boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
					return
				if(ishuman(subject))
					if(hasvar(subject, "mutantrace"))
						if(subject:mutantrace)
							topbotbutton_html = ""
							html_list += "<p>Can not change appearance of mutants.</p>"
						else

							src.log_me(subject, "appearance modifier accessed")

							new/datum/genetics_appearancemenu(usr.client, subject)
							usr << browse(null, "window=genetics")
							usr.machine = null
				else
					topbotbutton_html = ""
					html_list += "<p>Can not change appearance of non-humans.</p>"

			if("mutantrace") //TODO FIX: You can change the body type of bad clones to make them normal
				topbotbutton_html = ""
				var/mob/living/subject = get_scan_subject()
				if(!subject)
					boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
					return
				var/list/options = list("Human")

				var/datum/bioEffect/BE
				for (var/X in bioEffectList)
					BE = bioEffectList[X]
					if (BE.effectType == effectTypeMutantRace && BE.research_level >= 2 && BE.mutantrace_option)
						options += BE
					else continue

				if(ishuman(subject) && !isprematureclone(subject))
					var/mob/living/carbon/human/H = subject
					var/racepick = input(usr,"Change to which body type?","[src.name]") as null|anything in options
					if (racepick == "Human")

						if (!isnull(H.mutantrace))
							src.log_me(H, "mutantrace removed")

						H.set_mutantrace(null)
					else if (istype(racepick,/datum/bioEffect/mutantrace/) && H.bioHolder)
						var/datum/bioEffect/mutantrace/MR = racepick
						//H.bioHolder.AddEffect(MR.id)
						H.set_mutantrace(MR.mutantrace_path)

						src.log_me(H, "mutantrace added", MR)

					else
						return

				else
					topbotbutton_html = ""
					html_list += "<p>Can not change body type of non-human-like creatures.</p>"

			if("saveload")
				topbotbutton_html = ""
				//html_list += "<p>Temporary : </p><a href='?src=\ref[src];copyself=1'>Copy Occupant to Self</a>" Disabled due to shitlords

	info_html = html_list.Join()

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, 5)
	return

/obj/machinery/computer/genetics/proc/equipment_available(var/equipment = "analyser",var/datum/bioEffect/E)
	if (genResearch.debug_mode)
		return 1
	var/mob/living/subject = get_scan_subject()
	var/datum/bioEffect/GBE
	if (istype(E))
		GBE = E.get_global_instance()
	switch(equipment)
		if("analyser")
			if(genResearch.isResearched(/datum/geneticsResearchEntry/checker) && world.time >= src.equipment[2])
				return 1
		if("emitter")
			if(!iscarbon(subject))
				return 0
			if(genResearch.isResearched(/datum/geneticsResearchEntry/rademitter) && world.time >= src.equipment[3])
				return 1
		if("precision_emitter")
			if(!iscarbon(subject))
				//boutput(world, "failed carbon check")
				return 0
			if (!E)
				//boutput(world, "failed E check")
				return 0
			if (!GBE)
				//boutput(world, "failed GBE check")
				return 0
			if (GBE.research_level < 2)
				//boutput(world, "failed GBE level check")
				return 0
			if (E.can_scramble)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/rad_precision) && world.time >= src.equipment[3])
					return 1
		if("reclaimer")
			if(E && GBE && GBE.research_level >= 2 && E.can_reclaim)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/reclaimer) && world.time >= src.equipment[4])
					return 1
		if("injector")
			if(genResearch.researchMaterial < genResearch.injector_cost)
				return 0
			if(E && GBE && GBE.research_level >= 2 && E.can_make_injector)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/injector) && world.time >= src.equipment[1])
					if (genResearch.researchMaterial >= genResearch.injector_cost)
						return 1
		if("genebooth")
			if(genResearch.researchMaterial < genResearch.genebooth_cost)
				return 0
			if(E && GBE && GBE.research_level >= 1 && E.can_make_injector)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/genebooth))
					return 1
		if("activator")
			if(E && GBE && GBE.research_level >= 2 && E.can_make_injector)
				if(world.time >= src.equipment[1])
					return 1
		if("saver")
			if(E && GBE && GBE.research_level >= 2)
				if (genResearch.isResearched(/datum/geneticsResearchEntry/saver) && src.saved_mutations.len < genResearch.max_save_slots)
					return 1

	return 0

/obj/machinery/computer/genetics/proc/equipment_cooldown(var/equipment_num,var/time)
	if (genResearch.debug_mode)
		return
	if (!isnum(equipment_num) || !isnum(time))
		return
	if (equipment_num < 1 || equipment_num > src.equipment.len)
		return
	// Equipment Numbers:
	// 1) Injectors
	// 2) Analyser/Checker
	// 3) Emitters
	// 4) Reclaimer
	time *= genResearch.checkCooldownBonus()

	src.equipment[equipment_num] = world.time + time

/obj/machinery/computer/genetics/proc/ui_build_mutation_research(var/datum/bioEffect/E,var/datum/computer/file/genetics_scan/sample = null)
	if(!E)
		return null

	var/research_cost = genResearch.mut_research_cost
	if (genResearch.cost_discount)
		research_cost -= round(research_cost * genResearch.cost_discount)

	var/list/build = list()
	var/datum/bioEffect/global_BE = E.get_global_instance()
	if (!global_BE)
		build += "<p>Genetic structure unknown. Research currently impossible.</p>"
		return

	switch(global_BE.research_level)
		if (0)
			if (E.can_research)
				if (istext(E.req_mut_research) && GetBioeffectResearchLevelFromGlobalListByID(E.id) < 2)
					build += "<p>Genetic structure unknown. Research currently impossible.</p>"
				else
					if (sample)
						build += "<p><a href='?src=\ref[src];researchmut_sample=\ref[E];sample_to_research=\ref[sample]'>Research required.</a>"
					else
						build += "<p><a href='?src=\ref[src];researchmut=\ref[E]'>Research required.</a>"
					if (research_cost > genResearch.researchMaterial)
						build += " <i>Material: [research_cost]/[genResearch.researchMaterial]</i></p>"
					else
						build += " Material: [research_cost]/[genResearch.researchMaterial]</p>"
			else
				build += "<p>Manual Research required.</p>"
		if(1)
			build += "<p>Currently under research.</p>"
		else
			build += "<p>[E.desc]</p>"

	return build.Join()

/obj/machinery/computer/genetics/proc/ui_build_sequence(var/datum/bioEffect/E, var/screen = "pool")
	if (!E)
		return list("ERROR","ERROR","ERROR")

	var/list/build = list()

	var/list/top = list()
	var/list/mid = list()
	var/list/bot = list()

	switch(screen)
		if("pool")
			for(var/i=0, i < E.dnaBlocks.blockListCurr.len, i++)
				var/blockEnd = (((i+1) % 4) == 0 ? 1 : 0)
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[i+1]
				top += {"<a href='?src=\ref[src];setseq=\ref[E];setseq1=[i+1]'><img alt="" src="[resource("images/genetics/bp[bp.bpp1].png")]" style="border-style: none"></a>  [blockEnd ? {"<img alt="" src="[resource("images/genetics/bpSpacer.png")]">"} : ""]"}
				mid += {"<a href='?src=\ref[src];marker=\ref[E];themark=[i+1]'><img alt="" src="[resource("images/genetics/bpSep-[bp.marker].png")]" border=0></a>  [blockEnd ? {"<img alt="" src="[resource("images/genetics/bpSpacer.png")]" style="border-style: none">"} : ""]"}
				bot += {"<a href='?src=\ref[src];setseq=\ref[E];setseq2=[i+1]'><img alt="" src="[resource("images/genetics/bp[bp.bpp2].png")]" style="border-style: none"></a>  [blockEnd ? {"<img alt="" src="[resource("images/genetics/bpSpacer.png")]">"} : ""]"}
		if("sample_pool")
			for(var/i=0, i < E.dnaBlocks.blockListCurr.len, i++)
				var/blockEnd = (((i+1) % 4) == 0 ? 1 : 0)
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[i+1]
				top += {"<img alt="" src="[resource("images/genetics/bp[bp.bpp1].png")]" style="border-style: none">  [blockEnd ? {"<img alt="" src="[resource("images/genetics/bpSpacer.png")]">"} : ""]"}
				mid += {"<img alt="" src="[resource("images/genetics/bpSep-[bp.marker].png")]">  [blockEnd ? {"<img alt="" src="[resource("images/genetics/bpSpacer.png")]" style="border-style: none">"} : ""]"}
				bot += {"<img alt="" src="[resource("images/genetics/bp[bp.bpp2].png")]" style="border-style: none">  [blockEnd ? {"<img alt="" src="[resource("images/genetics/bpSpacer.png")]">"} : ""]"}
		if("active")
			var/datum/bioEffect/globalInstance = bioEffectList[E.id]
			for(var/i=0, i < globalInstance.dnaBlocks.blockList.len, i++)
				var/blockEnd = (((i+1) % 4) == 0 ? 1 : 0)
				var/datum/basePair/bp = globalInstance.dnaBlocks.blockList[i+1]
				top += {"<img alt="" src="[resource("images/genetics/bp[bp.bpp1].png")]" style="border-style: none">  [blockEnd ? {"<img alt="" src="[resource("images/genetics/bpSpacer.png")]">"} : ""]"}
				mid += {"<img alt="" src="[resource("images/genetics/bpSep-[bp.marker].png")]">  [blockEnd ? {"<img alt="" src="[resource("images/genetics/bpSpacer.png")]" style="border-style: none">"} : ""]"}
				bot += {"<img alt="" src="[resource("images/genetics/bp[bp.bpp2].png")]" style="border-style: none">  [blockEnd ? {"<img alt="" src="[resource("images/genetics/bpSpacer.png")]">"} : ""]"}

	build += top.Join()
	build += mid.Join()
	build += bot.Join()

	return build

/obj/machinery/computer/genetics/proc/ui_build_clickable_genes(var/screen = "pool",var/datum/computer/file/genetics_scan/sample)
	if(screen == "sample_pool")
		if(!sample)
			return
	else
		var/mob/living/carbon/human/subject = get_scan_subject()
		if(!subject)
			boutput(usr, "<b>SCANNER ALERT:</b> Subject has absconded.")
			return

	var/list/build = list()
	var/gene_icon_status = "mutGrey.png"
	var/datum/bioEffect/GBE
	switch(screen)
		if("sample_pool")
			for(var/datum/bioEffect/E in sample.dna_pool)
				GBE = E.get_global_instance()
				if (GBE.secret && !genResearch.see_secret)
					continue
				switch(GBE.research_level)
					if (0,null)
						gene_icon_status = "mutGrey.png"
					if (1)
						gene_icon_status = "mutGrey2.png"
					if (2)
						gene_icon_status = "mutYellow.png"
					if (3)
						gene_icon_status = "mutGreen.png"
				build += {"<a href='?src=\ref[src];sample_viewpool=\ref[E];sample_to_viewpool=\ref[sample]'>"}
				build += {"<img style="border: [E == src.currently_browsing ? "solid 1px #00FFFF" : "dotted 1px #88C425"]" src="[resource("images/genetics/[gene_icon_status]")]" alt="[GBE.research_level >= 2  ? E.name : "???"]" width="43" height="39"></a>"}

		if("pool")
			var/mob/living/subject = get_scan_subject()
			var/datum/bioEffect/E
			for(var/ID in subject.bioHolder.effectPool)
				E = subject.bioHolder.GetEffectFromPool(ID)
				if (!E)
					continue
				GBE = E.get_global_instance()
				if (GBE.secret && !genResearch.see_secret)
					continue
				switch(GBE.research_level)
					if (0,null)
						gene_icon_status = "mutGrey.png"
					if (1)
						gene_icon_status = "mutGrey2.png"
					if (2)
						gene_icon_status = "mutYellow.png"
					if (3)
						gene_icon_status = "mutGreen.png"
				build += {"<a href='?src=\ref[src];viewpool=\ref[E]'>"}
				build += {"<img style="border: [E == src.currently_browsing ? "solid 1px #00FFFF" : "dotted 1px #88C425"]" src="[resource("images/genetics/[gene_icon_status]")]" alt="[GBE.research_level >= 2  ? E.name : "???"]" width="43" height="39"></a>"}

		if("active")
			var/mob/living/subject = get_scan_subject()
			var/datum/bioEffect/E
			for(var/ID in subject.bioHolder.effects)
				E = subject.bioHolder.GetEffect(ID)
				if (!E)
					continue
				GBE = E.get_global_instance()
				if (GBE.secret && !genResearch.see_secret)
					continue
				if (!E.scanner_visibility)
					continue
				switch(GBE.research_level)
					if (0,null)
						gene_icon_status = "mutGrey.png"
					if (1)
						gene_icon_status = "mutGrey2.png"
					if (2)
						gene_icon_status = "mutYellow.png"
					if (3)
						gene_icon_status = "mutGreen.png"
				build += {"<a href='?src=\ref[src];vieweffect=\ref[E]'>"}
				build += {"<img style="border: [E == src.currently_browsing ? "solid 1px #00FFFF" : "dotted 1px #88C425"]" src="[resource("images/genetics/[gene_icon_status]")]" alt="[GBE.research_level >= 2  ? E.name : "???"]" width="43" height="39"></a>"}

	return build.Join()

/obj/machinery/computer/genetics/proc/get_scan_subject()
	if (!src)
		return null
	// Check for the occupant
	if (scanner && scanner.occupant)
		// Verify that the occupant is actually inside the scanner
		if(scanner.occupant.loc != scanner)
			// They're not. Bweeoo, dodgy stuff alert

			// The person trying to use the computer should be inside the scanner, they know what they're doing
			if(usr == scanner.occupant)
				// Fuck you, buddy
				trigger_anti_cheat(usr, "tried to use the genetics scanner on themselves")

			scanner.occupant = null
			scanner.icon_state = "scanner_0"
			return null
		else
			return scanner.occupant
	else
		return null

/obj/machinery/computer/genetics/proc/get_scanner()
	if (!src)
		return null
	if (scanner)
		return scanner
	return null

/obj/machinery/computer/genetics/power_change()
	if(status & BROKEN)
		icon_state = "commb"
	else
		if( powered() )
			icon_state = initial(icon_state)
			status &= ~NOPOWER
		else
			SPAWN_DBG(rand(0, 15))
				src.icon_state = "c_unpowered"
				status |= NOPOWER

// There weren't any (Convair880)!
/obj/machinery/computer/genetics/proc/log_me(var/mob/M, var/action = "", var/datum/bioEffect/BE)
	if (!src || !M || !ismob(M) || !action)
		return

	logTheThing("station", usr, M, "uses [src.name] on %target%[M.bioHolder ? " (Genetic stability: [M.bioHolder.genetic_stability])" : ""] at [log_loc(src)]. Action: [action][BE && istype(BE, /datum/bioEffect/) ? ". Gene: [BE] (Stability impact: [BE.stability_loss])" : ""]")
	return
