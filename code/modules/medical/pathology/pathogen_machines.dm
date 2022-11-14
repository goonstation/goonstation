/obj/machinery/centrifuge
	name = "Centrifuge"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "centrifuge0"
	desc = "A large machine that can be used to separate a pathogen sample from a blood sample."
	anchored = 1
	density = 1

	var/obj/item/bloodslide/source = null
	var/datum/pathogen/isolated = null
	var/obj/item/reagent_containers/glass/petridish/target = null
	var/obj/item/reagent_containers/glass/beaker/beaker = null

	var/on = 0

	var/datum/pathogen/process_pathogen
	var/obj/item/bloodslide/process_source
	var/counter = 15

	attack_hand(mob/user)
		var/output_text = "<B>Centrifuge</B><BR><BR>"
		if (src.on)
			output_text = "The centrifuge is currently working.<br><a href='?src=\ref[src];shutdown=1'>Emergency shutdown</a>"
		else

			if (src.source)
				output_text += "The centrifuge currently contains a [src.source]. <a href='?src=\ref[src];ejectsrc=1'>Eject</a><br><br>"
			else
				output_text += "The centrifuge's source slot is empty.<br><br>"
			if (src.source)
				if (istype(src.source, /obj/item/bloodslide))
					if (!src.source.reagents.has_reagent("blood"))
						output_text += "The [src.source] contains no viable sample.<BR><BR>"
					else
						var/datum/reagent/blood/B = src.source.reagents.reagent_list["blood"]
						if (B.volume && length(B.pathogens))
							if (B.pathogens.len > 1)
								output_text += "The centrifuge is calibrated to isolate a sample of [src.isolated ? src.isolated.name : "all pathogens"].<br><br>"
								output_text += "The blood in the [src.source] contains multiple pathogens. Calibrate to isolate a sample of:<br>"
								output_text += "<a href='?src=\ref[src];all=1'>All</a><BR>"
								for (var/uid in B.pathogens)
									var/datum/pathogen/P = B.pathogens[uid]
									output_text += "<a href='?src=\ref[src];isolate=\ref[P]'>[P.name]</a><br>"
								output_text += "<BR>"
							else
								var/uid = B.pathogens[1]
								var/datum/pathogen/P = B.pathogens[uid]
								output_text += "The centrifuge will isolate the single sample of [P].<br><br>"
						else
							output_text += "The [src.source] contains no viable sample.<BR><BR>"
			else
				output_text += "There is no isolation source inserted into the centrifuge.<br><br>"
			if (src.target)
				output_text += "There is a petri dish inserted into the machine. <a href='?src=\ref[src];ejectdish=1'>Eject</a><br><br>"
			else
				output_text += "There is no petri dish inserted into the machine.<br><br>"
			output_text += "<a href='?src=\ref[src];begin=1'>Begin isolation process</a>"

		user.Browse("<HEAD><TITLE>Centrifuge</TITLE></HEAD><BODY>[output_text]</BODY>", "window=centrifuge")
		onclose(user, "centrifuge")
		return

	Topic(href, href_list)
		if (..())
			return
		if (href_list["ejectsrc"])
			if (src.source && !src.on)
				src.source.master = null
				src.source.set_loc(src.loc)
				src.contents -= src.target
				src.source.layer = initial(src.source.layer)
				src.source = null
				src.isolated = null
		else if (href_list["ejectdish"])
			if (src.target && !src.on)
				src.target.master = null
				src.target.set_loc(src.loc)
				src.contents -= src.target
				src.target.layer = initial(src.target.layer)
				src.target = null
		else if (href_list["shutdown"])
			if (src.on && alert("Are you sure you want to shut down the process?",,"Yes","No") == "Yes")
				src.on = 0
				src.icon_state = "centrifuge0"
				src.visible_message("<span class='alert'>The centrifuge grinds to a sudden halt. The blood slide flies off the supports and shatters somewhere inside the machine.</span>", "<span class='alert'>You hear a grinding noise, followed by something shattering.</span>")
				qdel(src.source)
				src.source = null
				src.isolated = null
				counter = 15
				processing_items.Remove(src)
		else if (href_list["isolate"])
			if (!src.on)
				if (href_list["isolate"] == "All")
					src.isolated = null
				else
					src.isolated = locate(href_list["isolate"])
		else if (href_list["begin"])
			var/maybegin = 1
			if (!src.on)
				if (!src.source)
					boutput(usr, "<span class='alert'>You cannot begin isolation without a source container.</span>")
					maybegin = 0
				else if (!src.source.reagents.has_reagent("blood"))
					boutput(usr, "<span class='alert'>You cannot begin isolation without a source blood sample.</span>")
					maybegin = 0
				else
					var/datum/reagent/blood/B = src.source.reagents.reagent_list["blood"]
					if (!B.pathogens.len)
						boutput(usr, "<span class='alert'>The inserted blood sample is clean, there is nothing to isolate.</span>")
						maybegin = 0
					else if (!src.target)
						boutput(usr, "<span class='alert'>You cannot begin isolation without a target receptacle.</span>")
						maybegin = 0
				if (maybegin)
					src.visible_message("<span class='notice'>The centrifuge powers up and begins the isolation process.</span>", "<span class='notice'>You hear a machine powering up.</span>")
					src.on = 1
					src.icon_state = "centrifuge1"
					var/obj/item/bloodslide/S = src.source
					var/datum/reagent/blood/pathogen/P = new
					var/datum/reagent/blood/B = src.source.reagents.reagent_list["blood"]
					if (src.isolated)
						P.pathogens = list(src.isolated.pathogen_uid = src.isolated)
					else
						P.pathogens = B.pathogens.Copy()
					P.volume = 5
					processing_items |= src
					src.process_pathogen = P
					src.process_source = S
					counter = 25
		src.Attackhand(usr)

	attackby(var/obj/item/O, var/mob/user)
		if (istype(O, /obj/item/bloodslide))
			if (src.source)
				boutput(user, "<span class='alert'>There is already a blood slide in the machine.</span>")
				return
			else
				src.source = O
				O.set_loc(src)
				O.master = src
				O.layer = src.layer
				src.contents += O
				if (user.client)
					user.client.screen -= O
				user.u_equip(O)
				boutput(user, "You insert the blood slide into the machine.")
				if (src.source.blood && src.source.blood.pathogens.len == 1)
					var/uid = src.source.blood.pathogens[1]
					src.isolated = src.source.blood.pathogens[uid]
				else
					src.isolated = null
		else if (istype(O, /obj/item/reagent_containers/glass/petridish))
			if (src.target)
				boutput(user, "<span class='alert'>There is already a petri dish in the machine.</span>")
				return
			else
				src.target = O
				O.set_loc(src)
				O.master = src
				O.layer = src.layer
				src.contents += O
				if (user.client)
					user.client.screen -= O
				user.u_equip(O)
				boutput(user, "You insert the petri dish into the machine.")

	process()
		if (!src.on)
			return
		counter--
		if (counter <= 0)
			processing_items.Remove(src)
			var/datum/reagent/blood/pathogen/P = src.process_pathogen
			src.visible_message("<span class='notice'>The centrifuge beeps and discards the disfigured bloodslide.</span>", "<span class='notice'>You hear a machine powering down.</span>")
			if (src.target.reagents.has_reagent("pathogen"))
				var/datum/reagent/blood/pathogen/Q = src.target.reagents.reagent_list["pathogen"]
				for (var/uid in P.pathogens)
					var/datum/pathogen/PT = P.pathogens[uid]
					Q.pathogens += uid
					Q.pathogens[uid] = PT
			else
				src.target.reagents.reagent_list += "pathogen"
				src.target.reagents.reagent_list["pathogen"] = P
				P.holder = src.target.reagents
				src.target.reagents.update_total()
			src.target.icon_state = "petri1"
			src.target.stage = 0
			del(src.source)
			src.source = null
			src.isolated = null
			src.on = 0
			src.icon_state = "centrifuge0"

/obj/machinery/microscope
	name = "Microscope"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "microscope0"
	desc = "A device which provides a magnified view of a culture in a petri dish."

	var/obj/item/target = null

	var/list/symptom_action_out = new/list()
	var/list/symptom_action_in = new/list()
	var/list/supp_action = new/list()

	var/zoom = 0

	anchored = 1

	proc/message_parts(var/message)
		var/cloc = findtext(message, ":")
		if (cloc)
			var/name = copytext(message, 1, cloc)
			var/data = copytext(message, cloc + 1)
			return list(name, data)
		else
			return null

	attack_hand(mob/user)
		if (src.target)
			var/action = input("What would you like to do with the microscope?", "Microscope", "View [target]") in list("View [target]", "[src.zoom ? "Zoom Out" : "Zoom In"]", "Remove [target]", "Cancel")
			if (BOUNDS_DIST(user.loc, src.loc) == 0)
				if (action == "View [target]")
					if (zoom)
						user.show_message("<span class='notice'>You look at the [target] through the microscope.</span>")
						if (istype(src.target, /obj/item/reagent_containers/glass/petridish))
							var/obj/item/reagent_containers/glass/petridish/PD = target
							if (PD.dirty)
								user.show_message("<span class='notice'>The petri dish cannot be used for cultivating pathogens, due to: </span>")
								user.show_message(PD.dirty_reason)
						var/list/path_list = src.target.reagents.aggregate_pathogens()
						var/pcount = length(path_list)
						if (pcount > 0)
							var/uid
							var/datum/pathogen/P
							if (pcount > 1)
								var/list/names = new/list()
								for (uid in path_list)
									P = path_list[uid]
									names += P.name
								names += "Cancel"
								var/name = input("Which pathogen?", "Microscope", "Cancel") in names
								if (name == "Cancel")
									return
								for (uid in path_list)
									P = path_list[uid]
									if (P.name == name)
										break
							else
								uid = path_list[1]
								P = path_list[uid]
							user.show_message("<span class='notice'>Apparent features of the pathogen:</span>")
							var/lines = 1
							var/DNA = ""
							user.show_message(P.suppressant.may_react_to())
							for (var/datum/pathogeneffects/E in P.effects)
								var/res = E.may_react_to()
								if (res)
									lines++
									DNA = pathogen_controller.symptom_to_UID[E.type]
									user.show_message("([DNA]) [res]")
							if (!lines)
								user.show_message("You cannot see anything out of the ordinary.")
							if (src.symptom_action_in.len)
								user.show_message("<span class='notice'>You can observe in the [target]:</span>")
								for (var/act in src.symptom_action_in)
									var/list/actl = message_parts(act)
									if (actl[1] == P.name)
										user.show_message("[actl[2]]")
							if (src.supp_action[P.name])
								user.show_message("[src.supp_action[P.name]]")
						else
							user.show_message("The [target] is empty.")
					else
						var/list/path_list = src.target.reagents.aggregate_pathogens()
						user.show_message("<span class='notice'>You look at the [target] through the microscope.</span>")
						var/pcount = length(path_list)
						if (pcount > 0)
							var/uid
							var/datum/pathogen/P
							if (pcount > 1)
								var/list/names = new/list()
								for (uid in path_list)
									P = path_list[uid]
									names += P.name
								names += "Cancel"
								var/name = input("Which pathogen?", "Microscope", "Cancel") in names
								if (name == "Cancel")
									return
								for (uid in path_list)
									P = path_list[uid]
									if (P.name == name)
										break
							else
								uid = path_list[1]
								P = path_list[uid]
							user.show_message("<span class='notice'>The pathogen appears to be consistent with the strain [P.name_base]</span>")
							user.show_message("The pathogen appears to be composed of [P.desc].")
							if (src.symptom_action_out.len)
								user.show_message("<span class='notice'>You can observe in the [target]:</span>")
								for (var/act in src.symptom_action_out)
									var/list/actl = message_parts(act)
									if (actl[1] == P.name)
										user.show_message("[actl[2]]")
							if (src.supp_action[P.name])
								user.show_message("[src.supp_action[P.name]]")
						else
							user.show_message("The [target] is empty.")
				else if (action == "Zoom Out")
					zoom = 0
					icon_state = "microscope1"
					user.show_message("The microscope is now zoomed out.")
				else if (action == "Zoom In")
					zoom = 1
					icon_state = "microscope3"
					user.show_message("The microscope is now zoomed in.")
				else if (action == "Remove [target]")
					user.show_message("<span class='notice'>You remove the [target] from the microscope.</span>")
					src.target.set_loc(src.loc)
					src.target.layer = initial(src.target.layer)
					src.target.master = null
					icon_state = zoom ? "microscope2" : "microscope0"
					src.contents -= src.target
					src.target = null

	attackby(var/obj/item/O, var/mob/user)
		if (istype(O, /obj/item/reagent_containers/glass/petridish) || istype(O, /obj/item/bloodslide))
			if (src.target)
				boutput(user, "<span class='alert'>There is already a [target] on the microscope.</span>")
				return
			else
				src.target = O
				O.set_loc(src)
				O.master = src
				O.layer = src.layer
				src.contents += O
				if (user.client)
					user.client.screen -= O
				user.u_equip(O)
				src.icon_state = zoom ? "microscope3" : "microscope1"
				boutput(user, "You insert the [O] into the microscope.")
		else if (istype(O, /obj/item/reagent_containers/dropper))
			if (src.target && istype(src.target, /obj/item/reagent_containers/glass/petridish))
				if (O.reagents.total_volume > 0)
					user.visible_message("[user] drips some of the contents of the dropper into the petri dish.", "You drip some of the contents of the dropper into the petri dish.")
					var/list/path_list = src.target.reagents.aggregate_pathogens()
					for (var/rid in O.reagents.reagent_list)
						var/datum/reagent/R = O.reagents.reagent_list[rid]
						if (R.volume < 1)
							continue
						for (var/uid in path_list)
							var/datum/pathogen/P = path_list[uid]
							var/act = P.suppressant.react_to(R.id)
							if (act != null)
								if (!(P.name in src.supp_action))
									src.supp_action += P.name
								if (P.curable_by_suppression)
									act += "<br>The culture appears to be severely damaged by the suppressing agent."
								src.supp_action[P.name] = act
								SPAWN(10 SECONDS) // 100
									src.supp_action -= P.name
							for (var/datum/pathogeneffects/E in P.effects)
								var/a_in = "[P.name]: " + E.react_to(R.id, 1)
								var/a_out = "[P.name]: " + E.react_to(R.id, 0)
								if (a_in && !(a_in in src.symptom_action_in))
									src.symptom_action_in += a_in
									SPAWN(10 SECONDS) // 100
										src.symptom_action_in -= a_in
								if (a_out && !(a_out in src.symptom_action_out))
									src.symptom_action_out += a_out
									SPAWN(10 SECONDS) // 100
										src.symptom_action_out -= a_out

#define PATHOGEN_MANIPULATOR_STATE_MAIN 0
#define PATHOGEN_MANIPULATOR_STATE_LOADER 1
#define PATHOGEN_MANIPULATOR_STATE_MANIPULATE 2
#define PATHOGEN_MANIPULATOR_STATE_SPLICE 3
#define PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION 4
#define PATHOGEN_MANIPULATOR_STATE_TESTER 5

#define SEND_SLOT_LOAD_INFO gui.sendToSubscribers({"{"dnaDetails":[src.slots2json()], "loadedDna":[src.pathogen2json(src.manip.loaded)]}"}, "setUIState")

#define PA_SUCCESS 	1
#define PA_UNKNOWN 	2
#define PA_FAIL 	4



/datum/pathobank
	var/list/known_sequences = list()
	var/certainty = 0
	var/list/assigned_names = list()
	var/list/transient_sequences = list()

/obj/machinery/computer/pathology
	name = "Pathology Research"
	icon = 'icons/obj/computer.dmi'
	icon_state = "pathology"
	desc = "A bulky machine used to control the pathogen manipulator."
	var/obj/machinery/pathogen_manipulator/manip = null

	var/datum/pathobank/db = new
	var/predictive_data = ""
	var/datum/spyGUI/gui = null
	var/manipulating = false //are we currently irradiating the pathogen?
	New()
		..()
		gui = new("html/pathoComp.html", "pathology", "size=715x685", src)
		gui.validate_user = 1
		SPAWN(5 SECONDS)
			rescan()

	proc/rescan()
		for (var/obj/machinery/pathogen_manipulator/P in orange(1, src))
			src.manip = P
			P.comp = src
			break

	attack_hand(var/mob/user)
		if(status & (BROKEN|NOPOWER))
			return
		..()
		show_interface(user)

	proc/show_interface(var/mob/user as mob)
		if(!src.manip)
			rescan()
			if(!src.manip)
				user.show_text("The [src] flashes an assertive \"NO CONNECTION\" message. Looks like it wants a pathogen manipulator.", "red")
				return

		gui.displayInterface(user, initUI())
		if(src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
			sendSpliceInfo(1)
		sendAnalysisData()
		/*
		user.Browse(grabResource("html/PathoComp.html"), "window=pathology;size=900x800")
		sendData(user, initUI(), "setUIState")
		*/

	proc/initUI()
		var/out = {"{"src":"\ref[src]","actPage":[src.manip.machine_state],"exposed":[src.manip.exposed],"loadedDna":[pathogen2json(src.manip.loaded)],"dnaDetails":[slots2json()],"splice":{"selected":[src.manip.splicesource]}}"}
		return out

	proc/pathogen2json(var/datum/pathogendna/PDNA)
		if(!PDNA)
			return "null"
		var/splicing = (PDNA == src.manip.loaded && (!PDNA.valid || src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION))
		return {"{"seq":"[PDNA.seqnumeric + PDNA.seqsplice]",
		"pathogenName":"[PDNA.reference.name]",
		"pathogenStages":"[PDNA.reference.stages]",
		"pathogenSymptomaticity":"[PDNA.reference.symptomatic]",
		"pathogenSupCode":"[pathogen_controller.suppressant_to_UID[PDNA.reference.suppressant.type]]",
		"pathogenCap":"[PDNA.reference.body_type.seqMax]",
		"pathogenMaxStats":"[PDNA.reference.body_type.maxStats]",
		"pathogenType":"[PDNA.reference.body_type.singular]","isSplicing":[splicing]}"}

	proc/slots2json()
		if(!src.manip) return "\[null,null,null]"
		var/seqs = "\["
		var/delimiter = ""
		for(var/i = 1; i <= src.manip.slots.len; i++)
			seqs +="[delimiter][pathogen2json(src.manip.slots[i])]"
			delimiter=","
		seqs += "]"
		return seqs

	proc/sendSpliceInfo(var/use_cache = 0)
		var/tOut = ""
		var/sOut = ""
		if(use_cache)
			for(var/i = 1; i <= src.manip.cache_target.len; i++)
				tOut += src.manip.cache_target[i]
			for(var/i = 1; i <= src.manip.cache_source.len; i++)
				sOut += src.manip.cache_source[i]
		else
			if(src.manip.loaded)
				tOut = src.manip.loaded.seqsplice
				//Select the last DNA sequence if not using cache
				var/targetEnd = length(src.manip.loaded.explode())
				src.manip.sel_target_lptr = targetEnd
				src.manip.sel_target_rptr = targetEnd
			if(src.manip.splicesource && src.manip.slots[src.manip.splicesource])
				var/datum/pathogendna/P = src.manip.slots[src.manip.splicesource]
				sOut = P.seqsplice
				var/sourceEnd = length(P.explode())
				src.manip.sel_source_lptr = sourceEnd
				src.manip.sel_source_rptr = sourceEnd
		tOut = length(tOut) > 0 ? "\"[tOut]\"" : "null"
		sOut = length(sOut) > 0 ? "\"[sOut]\"" : "null"

		gui.sendToSubscribers({"{"splice":{"source":[sOut],"target":[tOut],"pred":[predictive_data],"selSource":{"lptr_index":[src.manip.sel_source_lptr], "rptr_index":[src.manip.sel_source_rptr]},"selTarget":{"lptr_index":[src.manip.sel_target_lptr], "rptr_index":[src.manip.sel_target_rptr]},"selected":[src.manip.splicesource]}}"}, "setUIState")

	proc/sendAnalysisData()
		var/out = {"{"analysis":{"curr":"[src.manip.analysis]","predeffect":[db.certainty],"buttons":"[jointext(src.manip.analysis_list,"")]""}
		if(src.manip.last_analysis)
			out += {","prev":[src.manip.last_analysis]"}
		out += "}}"
		gui.sendToSubscribers(out, "setUIState")


	Topic(href, href_list)
		if ( ..() )
			gui.unsubscribeTarget(usr)
			return

		if (href_list["showknown"])

			var/json = "\["
			var/delimit = ""
			// "<table><tr><th>Sequence</th><th>Stable</th><th>Transient</th></tr>"
			for (var/seq in db.known_sequences)
				//op += "<tr><td>[seq]</td><td>[db.known_sequences[seq] ? "Yes" : "No"]</td><td>[db.transient_sequences[seq]]</td></tr>"
				json += "[delimit]{seq: '[seq]', stable:'[db.known_sequences[seq] ? "Yes" : "No"]', trans: '[db.transient_sequences[seq]]'}"
				delimit = ", "
			json += "]"

			var/op = {"
				<html>
					<head>
						<title>Known Sequences</title>
						<style>
							table {
								border: 1px solid black;
								border-collapse:collapse;
							}
							th, td {
								padding:5px;
								border: 1px solid black;
							}
						</style>
						<script type="text/javascript" src=[resource("js/pathology_display.js")]></script>
					</head>

					<body>
						<h2>Known sequences</h2>
						<span id="listing"></span>
						<script type='text/javascript'>
							initializeScript([json]);
							sortAndDisplay("seq");
						</script>
					</body>
				</html>"}
			//html = '<table><th><a href="#" onclick="sortAndDisplay('seq'); return false;">Sequence</a></th><th><a href="#" onclick="sortAndDisplay('stable'); return false;">Stable</a></th><th><a href="#" onclick="sortAndDisplay('trans'); return false;">Transient</a></th>' + html + '</table>';
			usr.Browse(op, "window=pathology_ks;size=300x500")
		if (href_list["setstate"])
			var/state  = text2num_safe(href_list["newstate"])
			if(state != null && state >= 0 && state <= 5 && state != PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION && src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
				//Received valid input, it's within bounds and it's not moving to or from a protected state (splicing in progress)
				src.manip.machine_state = state
				gui.sendToSubscribers({"{"actPage":[state]}"}, "setUIState")

		if (href_list["analysisclear"])
			src.manip.analysis = null
			sendAnalysisData()
		if (href_list["analysisdestroy"])
			if (src.manip.loaded)
				src.manip.analysis_list.len = 0
				var/list/bits = src.manip.loaded.explode()
				for (var/bit in bits)
					if (bit != "|")
						src.manip.analysis_list += bit
				src.manip.analysis_list -= src.manip.analysis_list[1]
				sortList(src.manip.analysis_list, /proc/cmp_text_asc)
				qdel(src.manip.loaded)
				src.manip.loaded = null
				visible_message("<span class='notice'>The manipulator ejects the empty vial.</span>")
				new /obj/item/reagent_containers/glass/vial(get_turf(src.manip))

				SEND_SLOT_LOAD_INFO
				sendAnalysisData()

		if (href_list["analysisappend"])
			if (length(src.manip.analysis) >= 15)
				return

			var/id = text2num_safe(href_list["analysisappend"])
			if(id != null && id >= 0)
				id++ //JS sent a zero-based ID
				if (id > 0 && src.manip.analysis_list.len >= id) //We want the index to be in bounds now.
					var/element = src.manip.analysis_list[id]
					src.manip.analysis_list.Cut(id, id+1)
					if (!src.manip.analysis)
						src.manip.analysis = ""

					src.manip.analysis += element
			sendAnalysisData()

		if (href_list["analysisdo"])
			if (!src.manip.analysis)
				return
			var/tlen = length(src.manip.analysis)
			if (tlen < 3)
				return
			var/analyzed = src.manip.analysis
			if (tlen > 15)
				analyzed = copytext(analyzed, 1, 16)
				tlen = 15
			var/bits = tlen / 3
			var/acc = ""

			//Result variables
			var/stable = 0
			var/transient = 0
			var/seqs = "\["
			var/conf = "\["
			var/delim = ""
			var/stableType = "" // is the tested sequence good or bad? (or unstable)
			var/transGood = 0 // how many following symptoms are good?
			var/transBad = 0 // how many following symptoms are bad?

			if (analyzed in pathogen_controller.UID_to_symptom)
				stable = 1
			if (!(analyzed in db.known_sequences))
				db.known_sequences[analyzed] = stable
				db.certainty += (stable ? 8 : 4) * (100 - db.certainty) / 100

			for (var/i = 1, i <= bits, i++)
				var/curr = copytext(analyzed, (i - 1) * 3 + 1, i * 3 + 1)
				acc += curr
				var/acc_len = length(acc)
				var/total = 0
				var/match = 0
				for (var/dna in pathogen_controller.UID_to_symptom)
					var/dnalen = length(dna)
					if (dnalen >= acc_len)
						total++
						if (dnalen == acc_len)
							if(dna == acc)
								match++
								if (i == bits)
									// get symptom from dna, so we can check if it is good or bad
									var/datum/pathogeneffects/S = pathogen_controller.path_to_symptom[pathogen_controller.UID_to_symptom[dna]]
									if(S.beneficial)
										stableType = "Good"
									else
										stableType = "Bad"
							else
								total--
						else
							if (copytext(dna, 1, acc_len + 1) == acc)
								match++
								if (i == bits)
									// get symptom from dna, so we can check if it is good or bad
									var/datum/pathogeneffects/S = pathogen_controller.path_to_symptom[pathogen_controller.UID_to_symptom[dna]]
									if(S.beneficial)
										transGood++
									else
										transBad++
				var/ratio = 0
				if (total)
					ratio = match / total

				seqs += "[delim]\"[curr]\""
				conf += "[delim][ratio]"
				delim = ","
				/*
				end_part += "<font color='[col]'>[curr]</font> "
				*/
				if (i == bits && match && (!stable || match > 1))
					//output += "Transient: <font color='#00ff00'>Yes</font><BR>"
					transient = 1
					db.transient_sequences[analyzed] = "Yes"
				else if (i == bits)
					//output += "Transient: <font color='#ff0000'>No</font><BR>"
					transient = -1
					db.transient_sequences[analyzed] = "No"
			seqs += "]"
			conf += "]"

			if (!stable)
				src.manip.analysis = null
				stable = -1
			var/output = {"{
			"valid":1,
			"stable":[stable],
			"trans":[transient],
			"seqs":[seqs],
			"conf":[conf],
			"transGood":[transGood],
			"transBad":[transBad],
			"stableType":"[stableType]"
			}"}
			src.manip.last_analysis = output
			//gui.sendToSubscribers(output, "handleAnalysisTestCallback")
			sendAnalysisData()


		if (href_list["rescan"])
			rescan()
		if (href_list["exchange"])
			if (src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION && src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_MANIPULATE)
				var/swap = src.manip.loaded
				var/slotid = text2num_safe(href_list["exchange"])
				src.manip.loaded = src.manip.slots[slotid]
				if (src.manip.splicesource == slotid)
					src.manip.splicesource = 0
				src.manip.slots[slotid] = swap
				SEND_SLOT_LOAD_INFO

		if (href_list["load"])
			if (src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION && src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_MANIPULATE)
				var/slotid = text2num_safe(href_list["load"])
				src.manip.loaded = src.manip.slots[slotid]
				if (src.manip.splicesource == slotid)
					src.manip.splicesource = 0
				src.manip.slots[slotid] = null
				SEND_SLOT_LOAD_INFO

		if (href_list["cancel"])
			src.manip.splicesource = 0
			gui.sendToSubscribers({"{"splice":{"source":[src.manip.splicesource]}}"}, "setUIState")
		if (href_list["expose"])
			if (src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION && src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_MANIPULATE)
				var/slotid = text2num_safe(href_list["expose"])
				src.manip.exposed = slotid
				if (src.manip.slots[src.manip.exposed])
					src.manip.icon_state = "manipulatore"
				else
					src.manip.icon_state = "manipulator"
				gui.sendToSubscribers({"{"exposed":[src.manip.exposed]}"}, "setUIState")
		if (href_list["splice"])
			var/slotid = clamp(text2num_safe(href_list["splice"]), 1, src.manip.slots.len)
			src.manip.splicesource = slotid
			gui.sendToSubscribers({"{"splice":{"selected":[src.manip.splicesource]}}"}, "setUIState")

		if (href_list["remove"])
			if (src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION && src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_MANIPULATE)
				var/slotid = text2num_safe(href_list["remove"])
				if (src.manip.splicesource == slotid)
					src.manip.splicesource = 0
				src.manip.slots[slotid] = null
				gui.sendToSubscribers({"{"splice":{"source":[src.manip.splicesource]}, "dnaDetails":[slots2json()]}"}, "setUIState")

		if (href_list["save"])
			if (src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION && src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_MANIPULATE)
				var/slotid = text2num_safe(href_list["save"])
				src.manip.slots[slotid] = src.manip.loaded
				src.manip.loaded = null
				SEND_SLOT_LOAD_INFO

		if(href_list["manip"])
			if(!src.manip.loaded) // Why are you clicking this, there is no pathogen loaded in!
				return
			// the buttons should be disabled if the stats are maxed out, so these checks are just in case someone does nerd stuff
			var/points = 0
			var/totalPoints = src.manip.loaded.reference.spread + src.manip.loaded.reference.advance_speed + src.manip.loaded.reference.suppression_threshold
			var/mut_type
			switch(href_list["manip"])
				if("adv")
					mut_type = "advance_speed"
					points = src.manip.loaded.reference.advance_speed
				if("sth")
					mut_type = "suppression_threshold"
					points = src.manip.loaded.reference.suppression_threshold
				if("spr")
					mut_type = "spread"
					points = src.manip.loaded.reference.spread
				else
					return

			var/dir = text2num_safe(href_list["dir"])
			if(mut_type && dir && (src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_MANIPULATE) && !(dir > 0 && totalPoints >= src.manip.loaded.reference.body_type.maxStats) && !(dir > 0 && points >= 50) && !(dir < 0 && points <= 0))
				var/act = src.manip.loaded.manipulate(mut_type, dir)
				var/out
				if (act == 0)
					src.manip.visible_message("<span class='alert'>The DNA is destabilized and destroyed by the radiation.</span>")
					out= {"{"success":0}"}
				if(!out) out = {"{"newseq":"[src.manip.loaded.seqnumeric + src.manip.loaded.seqsplice]","success":1}"}
				gui.sendToSubscribers(out, "handleManipCallback")

		if (href_list["eject"])
			if (src.manip.exposed && src.manip.slots[src.manip.exposed] && src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
				var/datum/reagent/blood/pathogen/P = new
				var/datum/pathogendna/D = src.manip.slots[src.manip.exposed]
				var/datum/pathogen/PT = new /datum/pathogen
				PT.setup(0, D.reference)
				PT.dnasample = D
				P.pathogens += PT.pathogen_uid
				P.pathogens[PT.pathogen_uid] = PT
				P.volume = 2
				var/obj/item/reagent_containers/glass/vial/vial = new
				vial.reagents.reagent_list[P.id] = P
				vial.reagents.total_volume = 2
				vial.set_loc(src.manip.loc)
				usr.put_in_hand_or_eject(vial) // try to eject it into the users hand, if we can
				vial.icon_state = "vial1"
				src.manip.slots[src.manip.exposed] = null
				src.manip.icon_state = "manipulator"
				SEND_SLOT_LOAD_INFO
		/*Uses splicemod to insert
		if (href_list["insert"])
			if (src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
				var/offset = text2num_safe(href_list["insert"])
				var/seq = src.manip.cache_source[src.manip.sel_source]
				for (var/i = src.manip.sel_source, i < src.manip.cache_source.len, i++)
					src.manip.cache_source[i] = src.manip.cache_source[i+1]
				src.manip.cache_source.Cut(src.manip.cache_source.len)
				src.manip.cache_target += "#IN"
				for (var/i = src.manip.cache_target.len, i > src.manip.sel_target + 1 + offset, i--)
					src.manip.cache_target[i] = src.manip.cache_target[i-1]
				src.manip.cache_target[src.manip.sel_target + 1 + offset] = seq
				//src.manip.sel_target--
				src.manip.sel_source--
				if (src.manip.sel_source < 1)
					src.manip.sel_source = 1
				predictive_analysis()
		*/
		if(href_list["splicesel"])
			var/lptr_index = text2num_safe(href_list["lptr_index"])
			var/rptr_index = text2num_safe(href_list["rptr_index"])
			var/t = text2num_safe(href_list["target"])
			if(t)
				lptr_index = clamp(lptr_index+1, 1, src.manip.cache_target.len)
				rptr_index = clamp(rptr_index+1, 1, src.manip.cache_target.len)
				src.manip.sel_target_lptr = lptr_index
				src.manip.sel_target_rptr = rptr_index
				gui.sendToSubscribers({"{"splice":{"selTarget":{"lptr_index":[lptr_index], "rptr_index":[rptr_index]}}}"}, "setUIState")
			else
				lptr_index = clamp(lptr_index+1, 1, src.manip.cache_source.len)
				rptr_index = clamp(rptr_index+1, 1, src.manip.cache_source.len)
				src.manip.sel_source_lptr = lptr_index
				src.manip.sel_source_rptr = rptr_index
				gui.sendToSubscribers({"{"splice":{"selSource":{"lptr_index":[lptr_index], "rptr_index":[rptr_index]}}}"}, "setUIState")

		if(href_list["splicemod"])
			var/direction = text2num_safe(href_list["direction"]) //The operation to perform, 0 = remove, -1 = insert before, 1 = insert after
			var/s_index = text2num_safe(href_list["s_index"]) //The source index
			var/s_len = text2num_safe(href_list["s_len"]) //How much from the source we want to add
			var/t_index = text2num_safe(href_list["t_index"]) //The target index
			var/t_len = text2num_safe(href_list["t_len"]) //How much we want to remove from the target (if any)

			if(direction == null || t_index == null || (direction != 0 && (s_index == null || s_len == null)) || (direction == 0 && t_len == null))
				return

			direction = clamp(direction, -1, 1)
			//Increase the positions by one since they are 0-indexed JS.
			s_index = clamp(s_index+1, 1, src.manip.cache_source.len)
			t_index = clamp(t_index+1, 1, src.manip.cache_target.len)

			if(direction == 0) //Remove
				if(src.manip.cache_target.len)
					src.manip.cache_target.Cut(t_index,t_index+t_len)
					src.manip.sel_target_lptr = min(t_index, src.manip.cache_target.len) //Ensure the new selected target is within bounds
					src.manip.sel_target_rptr = min(t_index, src.manip.cache_target.len)

			else	//Insert
				direction = max(direction,0) //In case we're inserting before we don't want to subtract from the target index
				if(src.manip.cache_source.len)
					var/newpos = clamp(t_index + direction, 1, src.manip.cache_target.len+1) 	//Set the position to insert at
					var/newseq = src.manip.cache_source.Copy(s_index, s_index + s_len) //Copy the elements from source we want to insert
					src.manip.cache_target.Insert(newpos, newseq)	//Do the insertion
					src.manip.cache_source.Cut(s_index, s_index + s_len) //Remove the DNA sequence from the source
					//Shift the target selection to the newly inserted component
					src.manip.sel_target_lptr = min(t_index + direction, src.manip.cache_target.len) //Ensure the new selected target is within bounds
					src.manip.sel_target_rptr = min(t_index + s_len + direction - 1, src.manip.cache_target.len)
					//Ensure the last position in the source array is selected.
					src.manip.sel_source_lptr = min(s_index, src.manip.cache_source.len)
					src.manip.sel_source_rptr = min(s_index, src.manip.cache_source.len)

			predictive_analysis()
			sendSpliceInfo(1)

		if (href_list["beginsplice"])
			if (src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_LOADER && src.manip.loaded && src.manip.splicesource && src.manip.slots[src.manip.splicesource])
				src.manip.cache_target = src.manip.loaded.explode()
				var/datum/pathogendna/P = src.manip.slots[src.manip.splicesource]
				src.manip.cache_source = P.explode()
				src.manip.machine_state = PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION
				src.manip.icon_state = "manipulator1"
				predictive_data = 1
				SEND_SLOT_LOAD_INFO
				sendSpliceInfo(0)

		/*
		if (href_list["target"])
			if (src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
				var/offset = text2num_safe(href_list["target"])
				if (offset > 0)
					if (src.manip.sel_target < src.manip.cache_target.len)
						src.manip.sel_target++
				else
					if (src.manip.sel_target > 1)
						src.manip.sel_target--

		if (href_list["source"])
			if (src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
				var/offset = text2num_safe(href_list["source"])
				if (offset > 0)
					if (src.manip.sel_source < src.manip.cache_source.len)
						src.manip.sel_source++
				else
					if (src.manip.sel_source > 1)
						src.manip.sel_source--

		if (href_list["jumpt"])
			if (src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
				src.manip.sel_target = text2num_safe(href_list["jumpt"])

		if (href_list["jumps"])
			if (src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
				src.manip.sel_source = text2num_safe(href_list["jumps"])
		*/
		/* Uses splicemod
		if (href_list["seqremove"])
			if (src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
				for (var/i = src.manip.sel_target, i < src.manip.cache_target.len, i++)
					src.manip.cache_target[i] = src.manip.cache_target[i+1]
				src.manip.cache_target.Cut(src.manip.cache_target.len)
				src.manip.sel_target--
				predictive_analysis()
		*/

		if (href_list["splicefinish"])
			if (src.manip.machine_state == PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
				src.manip.icon_state = "manipulator"
				var/datum/pathogendna/L = src.manip.loaded
				var/oldname = L.reference.name
				var/success = 0

				L.implode(src.manip.cache_target)
				var/result = L.reevaluate()
				if (result == 1)
					var/list/seqs = L.get_sequences()
					for (var/s in seqs)
						if (s in db.known_sequences)
							continue
						db.known_sequences[s] = 1
						db.certainty += 5 * (100 - db.certainty) / 100
						db.certainty = min(db.certainty, 100)
						if(!(s in db.transient_sequences))
							db.transient_sequences[s] = "UNK"

					boutput(usr, "<span class='notice'>The DNA sequence is assembled by the manipulator.</span>")
					src.manip.loaded = L
					//don't reactivate this unless the pathologists are being thundering buttheads
					/*if (prob(10))
						if (prob(75))
							boutput(usr, "<span class='alert'>The splicing session is completed imperfectly. The DNA sequence mutates.</span>")
							src.manip.loaded.reference.mutate()
							src.manip.loaded.recalculate()
							src.manip.loaded.reverse_engineer()
							success=1
						else
							boutput(usr, "<span class='alert'>The splicing session is completed imperfectly. The DNA sequence is lost.</span>")
							qdel(src.manip.loaded)
							new /obj/item/reagent_containers/glass/vial(get_turf(src.manip)) //Quit eating vials you fuck -Spy
					else
					*/
					boutput(usr, "<span class='notice'>The splicing session is concluded perfectly. The DNA sequence remains intact.</span>")
					success=1
					src.manip.loaded.move_mutation()
					if (src.manip.loaded && !src.manip.loaded.disposed)
						src.manip.loaded.reference.cdc_announce(usr)

					var/datum/pathogendna/source = src.manip.slots[src.manip.splicesource]
					logTheThing(LOG_PATHOLOGY, usr, "splices pathogen [source.reference.name] into [oldname] creating [src.manip.loaded.reference.name].")
				else
					// how about some more feedback for what went wrong? :)
					var/reason = ""
					switch(result)
						if(2)
							reason = ", because the suppressant code was invalid"
						if(3)
							reason = ", because there was no separator after the suppressant code"
						if(4)
							reason = ", because the carrier code was invalid"
						if(5)
							reason = ", because there was no separator after the carrier code"
						if(6)
							reason = ", due to an invalid symptom code"
						if(7)
							reason = ", because there was no symptom code between two separators"
						if(8)
							reason = ", because the microbody could not sustain the amount of symptoms"
					boutput(usr, "<span class='alert'>The DNA sequence is assembled by the manipulator, but it collapses[reason]!</span>")
					src.manip.loaded = null
					new /obj/item/reagent_containers/glass/vial(get_turf(src.manip)) //Quit eating vials you fuck -Spy

				qdel(src.manip.slots[src.manip.splicesource])
				src.manip.slots[src.manip.splicesource] = null
				src.manip.splicesource = 0
				src.manip.machine_state = PATHOGEN_MANIPULATOR_STATE_MAIN
				visible_message("<span class='notice'>The manipulator ejects the empty vial.</span>")
				new /obj/item/reagent_containers/glass/vial(get_turf(src.manip))
				var/datum/pathogendna/PDNA = src.manip.loaded
				if(success && PDNA)
					gui.sendToSubscribers({"{"newseq":"[PDNA.seqnumeric + PDNA.seqsplice]","success":1}"}, "handleSpliceCompletionCallback")
				else
					gui.sendToSubscribers({"{"success":0}"}, "handleSpliceCompletionCallback")
				SEND_SLOT_LOAD_INFO

		if (href_list["lock"])
			if (src.manip.machine_state != PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION)
				src.manip.exposed = 0
				src.manip.icon_state = "manipulator"
				gui.sendToSubscribers({"{"exposed":[src.manip.exposed]}"}, "setUIState")

	proc/predictive_analysis()
		if (!prob(db.certainty))
			predictive_data = PA_UNKNOWN //"Insufficient data, predictive analysis failed"
		else
			if (prob(100 - db.certainty))
				if (prob(50))
					predictive_data = PA_SUCCESS //"<span style='color:#008800'>Sequence suspected to be stable</span>"
				else
					predictive_data = PA_FAIL //"<span style='color:#880000'>Sequence suspected to be unstable</span>"
			else
				var/datum/pathogendna/L = src.manip.loaded.clone()
				L.implode(src.manip.cache_target)
				var/list/seq = L.get_sequences()
				if (!seq.len)
					predictive_data = PA_FAIL //"<span style='color:#880000'>Sequence suspected to be unstable</span>"
					return
				for (var/s in seq)
					if (s in db.known_sequences)
						if (!db.known_sequences[s])
							predictive_data = PA_FAIL //"<span style='color:#880000'>Sequence suspected to be unstable</span>"
							return
					else
						if (prob(db.certainty) || prob(50))
							if (!(s in pathogen_controller.UID_to_symptom))
								predictive_data = PA_FAIL//"<span style='color:#880000'>Sequence suspected to be unstable</span>"
								return
				predictive_data = PA_SUCCESS //"<span style='color:#008800'>Sequence suspected to be stable</span>"

#undef SEND_SLOT_LOAD_INFO

#undef PA_SUCCESS
#undef PA_UNKNOWN
#undef PA_FAIL

/obj/machinery/pathogen_manipulator
	name = "Pathogen Manipulator"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "manipulator"
	desc = "A large, softly humming machine."
	density = 1
	anchored = 1

	var/machine_state = 0

	var/sel_target_lptr = 1 //Starting index of selected target sequence
	var/sel_target_rptr = 1 //Ending index (inclusive) of selected target sequence
	var/sel_source_lptr = 1
	var/sel_source_rptr = 1

	var/list/cache_target = null
	var/list/cache_source = null

	var/list/analysis_list = list()
	var/analysis = null
	var/last_analysis = null

	var/splicesource = 0
	var/exposed = 0

	var/datum/pathogendna/loaded = null

	var/list/datum/pathogendna/slots[3]

	var/obj/item/reagent_containers/container = null

	var/obj/machinery/computer/pathology/comp = null

	New()
		..()
		flags |= NOSPLASH

	attackby(var/obj/item/O, var/mob/user)
		var/firstFreeSlot = -1 // -1 means no free slot, -2 means the active slot is free
		if(!loaded)
			firstFreeSlot = -2
		else
			for(var/i in 1 to length(slots))
				if(isnull(slots[i]))
					firstFreeSlot = i
					break
		if (firstFreeSlot == -1)
			user.show_message("<span class='alert'>The manipulator has no free slots.</span>")
			return
		if (!istype(O, /obj/item/reagent_containers/glass/vial))
			user.show_message("<span class='alert'>The slots on the manipulator are designed so that only vials will fit.</span>")
			return
		if (!O.reagents.has_reagent("pathogen"))
			user.show_message("<span class='alert'>The vial does not contain a viable pathogen sample, and is rejected by the machine.</span>")
			return
		if (O.reagents.reagent_list.len > 1)
			user.show_message("<span class='alert'>The machine rejects the sample, as it contains foreign chemical samples.</span>")
			return
		var/datum/reagent/blood/pathogen/P = O.reagents.reagent_list["pathogen"]
		if (P.pathogens.len > 1)
			user.show_message("<span class='alert'>The vial contains multiple pathogen samples, and is rejected by the machine.</span>")
			return
		if (P.pathogens.len == 0)
			user.show_message("<span class='alert'>The vial does not contain a viable pathogen sample, and is rejected by the machine.</span>")
			return
		if (P.volume < 2)
			user.show_message("<span class='alert'>Too small sample size. At least 2 units of pathogen required.</span>")
			return
		var/uid = P.pathogens[1]
		var/datum/pathogen/PT = P.pathogens[uid]
		//boutput(user, "Valid. Contains pathogen ([P.volume] units with pathogen [PT.name]. Slot is [exposed]. DNA: [PT.dnasample]")
		if (!PT.dnasample)
			PT.dnasample = new(PT) // damage control
			stack_trace("Pathogen [PT.name] (\ref[PT]) had no DNA.")
			logTheThing(LOG_PATHOLOGY, user, "Pathogen [PT.name] (\ref[PT]) had no DNA. (this is a bug)")
		if(firstFreeSlot == -2)
			loaded = PT.dnasample.clone()
		else
			slots[firstFreeSlot] = PT.dnasample.clone()
		O.reagents.del_reagent("pathogen")
		user.u_equip(O)
		qdel(O)
		user.show_message("<span class='notice'>You insert the vial into the machine.</span>")
		icon_state = "manipulatore"

		if (comp)
			comp.gui.sendToSubscribers({"{"dnaDetails":[src.comp.slots2json()]}"}, "setUIState")
			comp.sendAnalysisData()



#undef PATHOGEN_MANIPULATOR_STATE_MAIN
#undef PATHOGEN_MANIPULATOR_STATE_LOADER
#undef PATHOGEN_MANIPULATOR_STATE_MANIPULATE
#undef PATHOGEN_MANIPULATOR_STATE_SPLICE
#undef PATHOGEN_MANIPULATOR_STATE_SPLICING_SESSION

/obj/item/synthmodule
	name = "Synth-O-Matic module"
	desc = "A module that integrates with a Synth-O-Matic machine."
	icon = 'icons/obj/pathology.dmi'
	icon_state = "synthmodule"
	var/id = "bad"
	proc/received(obj/machinery/synthomatic/S)
		return

	afterattack(obj/target, mob/user , flag)
		if (istype(target, /obj/machinery/synthomatic))
			return
		..(target, user, flag)

/obj/item/synthmodule/vaccine
	name = "Synth-O-Matic Vaccine module"
	desc = "A module that allows the Synth-O-Matic machine to create vaccines."
	id = "vaccine"

/obj/item/synthmodule/upgrader
	name = "Synth-O-Matic Efficiency module"
	desc = "A module that allows the Synth-O-Matic machine to synthesize more anti-pathogenic agents from a single sample."
	id = "upgrade"

/obj/item/synthmodule/assistant
	name = "Synth-O-Matic Assistant module"
	desc = "A module that assists in creating cure for pathogens for the Synth-O-Matic machine."
	id = "assistant"

/obj/item/synthmodule/synthesizer
	name = "Synth-O-Matic Antiagent module"
	desc = "A module which allows the Synth-O-Matic to synthesize an anti-pathogen agent on the fly."
	id = "synthesizer"

/obj/item/synthmodule/virii
	name = "Synth-O-Matic Virii module"
	desc = "A module that allows the Synth-O-Matic to internally generate cures to virii."
	id = "virii"

/obj/item/synthmodule/bacteria
	name = "Synth-O-Matic Bacteria module"
	desc = "A module that allows the Synth-O-Matic to internally generate cures to bacteria."
	id = "bacteria"

/obj/item/synthmodule/fungi
	name = "Synth-O-Matic Fungi module"
	desc = "A module that allows the Synth-O-Matic to internally generate cures to fungi."
	id = "fungi"

/obj/item/synthmodule/parasite
	name = "Synth-O-Matic Parasite module"
	desc = "A module that allows the Synth-O-Matic to internally generate cures to parasitic diseases, using biocides."
	id = "parasite"

/obj/item/synthmodule/gmcell
	name = "Synth-O-Matic Mutatis module"
	desc = "A module that allows the Synth-O-Matic to internally generate cures to great mutatis cell diseases."
	id = "gmcell"

/obj/item/synthmodule/radiation
	name = "Synth-O-Matic Irradiation module"
	desc = "A module that allows the Synth-O-Matic to generate cure through irradiation, instead of chemicals."
	id = "radiation"

/obj/machinery/synthomatic
	name = "Synth-O-Matic 6.5.535"
	desc = "The leading technological assistant in synthesizing cure for certain pathogens."
	icon = 'icons/obj/pathology.dmi'
	icon_state = "synth1"
	density = 1
	anchored = 1

	var/list/obj/item/reagent_containers/glass/vial/vials[5]
	var/obj/item/reagent_containers/glass/beaker/antiagent = null
	var/obj/item/reagent_containers/glass/beaker/suppressant = null
	var/list/obj/item/synthmodule/modules = list()

	var/maintenance = 0
	var/machine_state = 0
	var/sel_vial = 0
	var/const/synthesize_pathogen_cost = 100 // used to be 2000

	New()
		..()
		src.reagents = new(100)
		src.reagents.my_atom = src
		flags |= NOSPLASH
		if (!pathogen_controller || !pathogen_controller.cure_bases || !length(pathogen_controller.cure_bases))
			SPAWN(2 SECONDS)
				for (var/C in pathogen_controller.cure_bases)
					src.reagents.add_reagent(C, 1)
		else
			for (var/C in pathogen_controller.cure_bases)
				src.reagents.add_reagent(C, 1)
		/*
		src.add_module(new /obj/item/synthmodule/virii())
		src.add_module(new /obj/item/synthmodule/bacteria())
		src.add_module(new /obj/item/synthmodule/parasite())
		src.add_module(new /obj/item/synthmodule/gmcell())
		*/
		// ZAMUJASA HERE WITH "FUCK THIS SHIT", LIVE!
		// what happens if we just give them the ability to cure shit. what then.
		src.add_module(new /obj/item/synthmodule/virii())
		src.add_module(new /obj/item/synthmodule/bacteria())
		src.add_module(new /obj/item/synthmodule/parasite())
		src.add_module(new /obj/item/synthmodule/gmcell())
		src.add_module(new /obj/item/synthmodule/fungi())
		src.add_module(new /obj/item/synthmodule/vaccine())
		src.add_module(new /obj/item/synthmodule/upgrader())
		src.add_module(new /obj/item/synthmodule/assistant())
		src.add_module(new /obj/item/synthmodule/synthesizer())
		src.add_module(new /obj/item/synthmodule/radiation())


	attack_hand(var/mob/user)
		if(status & (BROKEN|NOPOWER))
			return
		..()
		show_interface(user)

	proc/add_module(var/obj/item/synthmodule/M)
		if (has_module(M))
			boutput(usr, "<span class='alert'>The [name] already has that kind of module.</span>")
			return 0
		else
			modules[M.id] = M
			M.set_loc(src)
			M.received(src)
			return 1

	proc/has_module(var/id)
		if (src.modules.len && (id in src.modules) && src.modules[id])
			return 1
		return 0

	attackby(var/obj/item/O, var/mob/user)
		if(status & (BROKEN|NOPOWER))
			boutput(user,  "<span class='alert'>You can't insert things while the machine is out of power!</span>")
			return
		if (istype(O, /obj/item/reagent_containers/glass/vial))
			var/done = 0
			for (var/i = 1, i <= 5, i++)
				if (!(vials[i]))
					done = 1
					vials[i] = O
					user.u_equip(O)
					O.set_loc(src)
					O.master = src
					user.client.screen -= O
					break
			if (!done)
				boutput(user, "<span class='alert'>The machine cannot hold any more vials.</span>")
			else
				boutput(user, "<span class='notice'>You insert the vial into the machine.</span>")
				show_interface(user)
			return
		if (istype(O, /obj/item/reagent_containers/glass/beaker))
			var/action = input("Which slot?", "Synth-O-Matic", "Cancel") in list("Anti-Agent", "Suppressant", "Cancel")
			if (action == "Anti-Agent")
				if (!(user in range(1)))
					boutput(user, "<span class='alert'>You must be near the machine to do that.</span>")
					return
				if (user.equipped() != O)
					return
				if (!antiagent)
					antiagent = O
					user.u_equip(O)
					O.set_loc(src)
					O.master = src
					user.client.screen -= O
					boutput(user, "<span class='notice'>You insert the beaker into the machine.</span>")
					show_interface(user)
				else
					boutput(user, "<span class='alert'>That slot is already occupied!</span>")
			else if (action == "Suppressant")
				if (!(user in range(1)))
					boutput(user, "<span class='alert'>You must be near the machine to do that.</span>")
					return
				if (user.equipped() != O)
					return
				if (!suppressant)
					suppressant = O
					user.u_equip(O)
					O.set_loc(src)
					O.master = src
					user.client.screen -= O
					boutput(user, "<span class='notice'>You insert the beaker into the machine.</span>")
					show_interface(user)
				else
					boutput(user, "<span class='alert'>That slot is already occupied!</span>")
			return
		if (isscrewingtool(O))
			if (machine_state)
				boutput(user, "<span class='alert'>You cannot do that while the machine is working.</span>")
				return
			if (!maintenance)
				boutput(user, "<span class='notice'>You open the maintenance panel on the Synth-O-Matic.</span>")
				icon_state = "synthp"
				maintenance = 1
			else
				boutput(user, "<span class='notice'>You close the maintenance panel on the Synth-O-Matic.</span>")
				icon_state = "synth1"
				maintenance = 0
			return
		if (istype(O, /obj/item/synthmodule))
			if (maintenance)
				if (add_module(O))
					boutput(user, "<span class='notice'>You insert the [O] into the machine.</span>")
					O.master = src
					user.client.screen -= O
					user.u_equip(O)
					show_interface(user)
				else
					boutput(user, "<span class='alert'>The machine already has the [O].</span>")
			else
				boutput(user, "<span class='alert'>You must open the maintenance panel first.</span>")
			return
		..(O, user)

	proc/show_interface(var/mob/user as mob)
		var/output_text = ""

		output_text += "<b>SYNTH-O-MATIC 6.5.535</b><br>"
		output_text += "<i>\"Introducing the future in safe and controlled pathology science.\"</i><br>"
		output_text += "<br>"

		if (machine_state)
			output_text += "The machine is currently working. Please wait."
		else if (maintenance)
			output_text += "<b>Maintenance panel open - active modules</b><br>"
			for (var/module in modules)
				var/obj/item/synthmodule/mod = modules[module]
				output_text += "[mod.name] <a href='?src=\ref[src];remove=[module]'>\[remove\]</a><br>"
		else
			var/sane = 0
			var/vaccinable = 0
			var/body_name = null
			var/module = null
			output_text += "<b>Active vial:</b><br>"
			if (sel_vial && vials[sel_vial])
				var/obj/item/reagent_containers/glass/vial/V = vials[sel_vial]
				if (V.reagents.has_reagent("pathogen"))
					var/datum/reagent/blood/pathogen/R = V.reagents.reagent_list["pathogen"]
					if (R.pathogens.len > 1)
						output_text += "#[sel_vial] [V.name] (<font color='red'>ERROR:</font> contains multiple pathogen samples)<br><br>"
					else if (!R.pathogens.len)
						output_text += "#[sel_vial] [V.name] (empty)<br><br>"
					else
						var/uid = R.pathogens[1]
						var/datum/pathogen/P = R.pathogens[uid]
						sane = 1
						vaccinable = P.body_type.vaccination
						body_name = P.body_type.plural
						module = P.body_type.module_id
						output_text += "#[sel_vial] [V.name] (singular sample of strain [P.name_base])<br>"
						if (has_module("assistant"))
							var/units = P.suppression_threshold
							output_text += "<br>The assistant module suggests at least [units <= 5 ? 5 : units] unit(s) of one of the following suppressants for this pathogen:<br>"
							var/first = 1
							for (var/supp in P.suppressant.cure_synthesis)
								if (first)
									first = 0
								else
									output_text += ", "
								output_text += reagent_id_to_name(supp)
							output_text += "<br><br>"
						else
							output_text += "<br>"
				else
					output_text += "#[sel_vial] [V.name] (empty)<br><br>"
			else
				output_text += "None<br><br>"
			output_text += "<b>Research Budget:</b> [wagesystem.research_budget] Credits<br>"
			output_text += "<a href='?src=\ref[src];buymats=1;microbody=virus'>Synthesize a new virus pathogen sample for [synthesize_pathogen_cost] credits</a><br>"
			output_text += "<a href='?src=\ref[src];buymats=1;microbody=parasite'>Synthesize a new parasite pathogen sample for [synthesize_pathogen_cost] credits</a><br>"
			output_text += "<a href='?src=\ref[src];buymats=1;microbody=bacterium'>Synthesize a new bacterium pathogen sample for [synthesize_pathogen_cost] credits</a><br>"
			output_text += "<a href='?src=\ref[src];buymats=1;microbody=fungus'>Synthesize a new fungus pathogen sample for [synthesize_pathogen_cost] credits</a><br>"
			output_text += "<br>"
			output_text += "<b>Inserted vials:</b><br>"
			for (var/i = 1, i <= 5, i++)
				if (vials[i])
					var/obj/item/reagent_containers/glass/vial/V = vials[i]
					if ("pathogen" in V.reagents.reagent_list)
						var/datum/reagent/blood/pathogen/R = V.reagents.reagent_list["pathogen"]
						if (R.pathogens.len > 1)
							output_text += "#[i] <a href='?src=\ref[src];vial=[i]'>[V.name]</a> <a href='?src=\ref[src];eject=[i]'>\[eject\]</a> (multiple samples)<br>"
						else if (!R.pathogens.len)
							output_text += "#[i] <a href='?src=\ref[src];vial=[i]'>[V.name]</a> <a href='?src=\ref[src];eject=[i]'>\[eject\]</a> (empty)<br>"
						else
							var/uid = R.pathogens[1]
							var/datum/pathogen/P = R.pathogens[uid]
							output_text += "#[i] <a href='?src=\ref[src];vial=[i]'>[V.name]</a> <a href='?src=\ref[src];eject=[i]'>\[eject\]</a> (singular sample of strain [P.name_base])<br>"
					else
						output_text += "#[i] <a href='?src=\ref[src];vial=[i]'>[V.name]</a> <a href='?src=\ref[src];eject=[i]'>\[eject\]</a> (empty)<br>"
				else
					output_text += "#[i] Empty slot<br>"
			output_text += "<br>"
			output_text += "<b>Anti-agent beaker slot: </b>"

			if (antiagent)
				output_text += "[antiagent] <a href='?src=\ref[src];ejectanti=1'>\[eject\]</a><br><br>"

				if (has_module("synthesizer"))
					if (antiagent.reagents.total_volume != antiagent.reagents.maximum_volume)
						output_text += "<b>Anti-agent synthesizer module - select a reagent to add:</b><br>"
						for (var/A in pathogen_controller.cure_bases)
							var/datum/reagent/base_cure = src.reagents.reagent_list[A]
							output_text += "10 units of <a href='?src=\ref[src];antiagent=[A]'>[base_cure.name]</a><br>"
						output_text += "<br>"
					else
						output_text += "<b>Anti-agent synthesizer module - beaker is full.</b><br><br>"
				output_text += "<b>Contents:</b><br>"
				if (antiagent.reagents.reagent_list.len)
					for (var/reagent in antiagent.reagents.reagent_list)
						var/datum/reagent/R = antiagent.reagents.reagent_list[reagent]
						output_text += "[R.volume] units of [R.name]<br>"
					output_text += "<br>"
				else
					output_text += "Nothing.<br><br>"
			else
				output_text += "Empty<br><br>"

			output_text += "<b>Suppression beaker slot: </b>"
			if (suppressant)
				output_text += "[suppressant] <a href='?src=\ref[src];ejectsupp=1'>\[eject\]</a><br><br>"
				output_text += "<b>Contents:</b><br>"
				if (suppressant.reagents.reagent_list.len)
					for (var/reagent in suppressant.reagents.reagent_list)
						var/datum/reagent/R = suppressant.reagents.reagent_list[reagent]
						output_text += "[R.volume] units of [R.name]<br>"
					output_text += "<br>"
				else
					output_text += "Nothing.<br><br>"
			else
				output_text += "Empty<br><br>"


			if (sane)
				if (!antiagent || !length(antiagent.reagents.reagent_list))
					output_text += "<i><b>NOTICE:</b> Serums manufactured without the appropriate antiagent may lead to an epidemic.</i><br>"
				if (!suppressant || !length(suppressant.reagents.reagent_list))
					if (has_module("vaccine"))
						output_text += "<i><b>NOTICE:</b> Serums and vaccines manufactured without the appropriate suppression agent may lead to an epidemic.</i><br>"
					else
						output_text += "<i><b>NOTICE:</b> Serums manufactured without the appropriate suppression agent may lead to an epidemic.</i><br>"
				if (module && !has_module(module))
					output_text += "<b>ERROR:</b> Additional modules are required to synthesize cure for [body_name].<br>"
				else
					if (has_module("radiation"))
						output_text += "<a href='?src=\ref[src];serum=1'>Synthesize serum from suppressants</a><br>"
						output_text += "<a href='?src=\ref[src];serumrad=1'>Synthesize serum by irradiation</a><br>"
					else
						output_text += "<a href='?src=\ref[src];serum=1'>Synthesize serum</a><br>"
					if (has_module("vaccine"))
						if (vaccinable)
							if (has_module("radiation"))
								output_text += "<a href='?src=\ref[src];vaccine=1'>Synthesize vaccine from suppressants</a><br>"
								output_text += "<a href='?src=\ref[src];vaccinerad=1'>Synthesize vaccine by irradiation</a><br>"
							else
								output_text += "<a href='?src=\ref[src];vaccine=1'>Synthesize vaccine</a><br>"
						else
							output_text += "No vaccine synthesis method is known for [body_name].<br>"

		user.Browse(output_text, "window=synthomatic;size=800x600")

	Topic(href, href_list)
		if (!(usr in range(1)))
			return
		if (machine_state)
			show_interface(usr)
			return
		if (maintenance)
			if (href_list["remove"])
				if (modules[href_list["remove"]])
					var/obj/item/synthmodule/M = modules[href_list["remove"]]
					modules -= href_list["remove"]
					M.set_loc(src.loc)
					M.master = null
		else
			if (href_list["eject"])
				var/index = text2num_safe(href_list["eject"])
				//Arrays start at 0 -Byand
				if(index > 0 && index <= vials.len)
					if (vials[index])
						var/obj/item/reagent_containers/glass/vial/V = vials[index]
						vials[index] = null
						V.set_loc(src.loc)
						usr.put_in_hand_or_eject(V) // try to eject it into the users hand, if we can
						V.master = null
						if (sel_vial == index)
							sel_vial = 0
			else if (href_list["ejectanti"])
				if (antiagent)
					antiagent.set_loc(src.loc)
					antiagent.master = null
					antiagent = null
			else if (href_list["ejectsupp"])
				if (suppressant)
					suppressant.set_loc(src.loc)
					suppressant.master = null
					suppressant = null
			else if (href_list["vial"])
				var/index = text2num_safe(href_list["vial"])
				if(index > 0 && index <= vials.len)
					if (vials[index])
						sel_vial = index
			else if (href_list["serum"])
				machine_state = 1
				icon_state = "synth2"
				src.visible_message("The [src.name] bubbles and begins synthesis.", "You hear a bubbling noise.")
				SPAWN(2 SECONDS) // 80
					finish_creation(1, 1)
			else if (href_list["serumrad"])
				machine_state = 1
				icon_state = "synth2"
				src.visible_message("The [src.name] bubbles and begins synthesis.", "You hear a bubbling noise.")
				SPAWN(2 SECONDS) // 120
					finish_creation(0, 1)
			else if (href_list["vaccine"])
				machine_state = 1
				icon_state = "synth2"
				src.visible_message("The [src.name] bubbles and begins synthesis.", "You hear a bubbling noise.")
				SPAWN(2 SECONDS) // 80
					finish_creation(1, 0)
			else if (href_list["vaccinerad"])
				machine_state = 1
				icon_state = "synth2"
				src.visible_message("The [src.name] bubbles and begins synthesis.", "You hear a bubbling noise.")
				SPAWN(2 SECONDS) // 120
					finish_creation(0, 0)
			else if (href_list["antiagent"])
				var/new_antiagent = href_list["antiagent"]

				if( !has_module("synthesizer") || !pathogen_controller.cure_bases.Find(new_antiagent) )
					//Someone's tampering with the href
					if (usr in range(1))
						//Check that whoever's doing this is nearby - otherwise they could gib any old scrub

						trigger_anti_cheat(usr, "tried to href exploit antiagent on [src].")
						return
				var/added = min(10, src.antiagent.reagents.maximum_volume - src.antiagent.reagents.total_volume)
				src.antiagent.reagents.add_reagent(new_antiagent, added)
				boutput(usr, "<span class='notice'>[added] units of anti-agent added to the beaker.</span>")
			else if (href_list["buymats"])
				#ifdef CREATE_PATHOGENS //PATHOLOGY REMOVAL
				var/confirm = alert("How many pathogen samples do you wish to synthesize? ([synthesize_pathogen_cost] credits per sample)", "Confirm Purchase", "1", "5", "Cancel")
				if (confirm != "Cancel" && machine_state == 0 && (usr in range(1)))
					var/count = text2num_safe(confirm)
					if (synthesize_pathogen_cost*count > wagesystem.research_budget)
						boutput(usr, "<span class='alert'>Insufficient research budget to make that transaction.</span>")
					else
						boutput(usr, "<span class='notice'>Transaction successful.</span>")
						wagesystem.research_budget -= synthesize_pathogen_cost*count
						machine_state = 1
						icon_state = "synth2"
						src.visible_message("The [src.name] bubbles and begins synthesis.", "You hear a bubbling noise.")
						SPAWN(0 SECONDS)
							while(count > 0)
								count--
								sleep(5 SECONDS)
								for (var/mob/C in viewers(src))
									C.show_message("The [src.name] ejects a new pathogen sample.", 3)
								switch(href_list["microbody"])
									if("virus")
										new /obj/item/reagent_containers/glass/vial/prepared/virus(src.loc)
									if("parasite")
										new /obj/item/reagent_containers/glass/vial/prepared/parasite(src.loc)
									if("bacterium")
										new /obj/item/reagent_containers/glass/vial/prepared/bacterium(src.loc)
									if("fungus")
										new /obj/item/reagent_containers/glass/vial/prepared/fungus(src.loc)
							machine_state = 0
							icon_state = "synth1"
				#else
				boutput(usr, "<span class='alert'>[src] unable to complete task. Please contact your network administrator.</span>")
				#endif
		show_interface(usr)

	proc/finish_creation(var/use_suppressant, var/use_antiagent)
		machine_state = 0
		icon_state = "synth1"
		create_injectors(use_suppressant, use_antiagent)

	proc/create_injectors(var/use_suppressant, var/use_antiagent)
		if (has_module("upgrade"))
			for (var/mob/C in viewers(src))
				C.show_message("The [src.name] shuts down and ejects multiple syringes.", 3)
		else
			for (var/mob/C in viewers(src))
				C.show_message("The [src.name] shuts down and ejects a syringe.", 3)
		var/obj/item/reagent_containers/glass/vial/V = src.vials[sel_vial]
		var/datum/reagent/blood/pathogen/R = V.reagents.reagent_list["pathogen"]
		var/uid = R.pathogens[1]
		var/datum/pathogen/P = R.pathogens[uid]
		var/is_cure = 0
		if ((src.antiagent || !use_antiagent) && (src.suppressant || !use_suppressant))
			if (!use_antiagent || src.antiagent.reagents.has_reagent(P.body_type.cure_base, clamp(P.suppression_threshold, 5, 50)))
				var/found = 0
				if (use_suppressant)
					for (var/id in P.suppressant.cure_synthesis)
						if (src.suppressant.reagents.has_reagent(id, clamp(P.suppression_threshold, 5, 50)))
							found = 1
							break
					if (found)
						is_cure = 1
				else
					is_cure = 1
		if (use_antiagent && src.antiagent)
			src.antiagent.reagents.clear_reagents()
		if (use_suppressant && src.suppressant)
			src.suppressant.reagents.clear_reagents()
		V.reagents.clear_reagents()
		for (var/i = 1, i <= (has_module("upgrade") ? 4 : 1), i++)
			new/obj/item/serum_injector(src.loc, P, is_cure, use_antiagent ? 0 : 1)


/obj/machinery/autoclave
	name = "Autoclave"
	desc = "A bulky machine used for sanitizing pathogen growth equipment."
	icon = 'icons/obj/pathology.dmi'
	icon_state = "autoclave"
	density = 1
	anchored = 1
	var/obj/item/reagent_containers/glass/sanitizing = null
	var/machine_state = 0
	var/santime = 3 // 15

	attackby(var/obj/item/O, var/mob/user)
		if (istype(O, /obj/item/reagent_containers/glass))
			if (!sanitizing)
				boutput(user, "<span class='notice'>You place the [O] inside the machine.</span>")
				sanitizing = O
				O.set_loc(src)
				O.master = src
				user.u_equip(O)
				user.client.screen -= O
				icon_state = "autoclaveb"
			else
				boutput(user, "<span class='alert'>The machine already has an item loaded.</span>")
		else
			boutput(user, "<span class='alert'>The machine cannot clean that!</span>")

	process()
		if (machine_state)
			santime--
			if (santime < 0)
				machine_state = 0
				for (var/mob/M in range(7))
					boutput(M, "<span class='notice'>The machine finishes cleaning and shuts down.</span>")
				sanitizing.reagents.clear_reagents()
				if (istype(sanitizing, /obj/item/reagent_containers/glass/petridish))
					var/obj/item/reagent_containers/glass/petridish/P = sanitizing
					P.ctime = 15
					P.starving = 5
					if (P.medium)
						del P.medium
					P.medium = null
					for (var/N in P.nutrition)
						P.nutrition -= N
					P.dirty_reason = ""
					P.dirty = 0
				sanitizing.set_loc(src.loc)
				sanitizing.master = null
				sanitizing = null
				icon_state = "autoclave"

	attack_hand(var/mob/user)
		if (machine_state || (status & (BROKEN|NOPOWER)))
			return
		if (sanitizing)
			santime = initial(santime)
			icon_state = "autoclave1"
			machine_state = 1
			for (var/mob/M in range(7))
				boutput(M, "<span class='notice'>The machine steams up and begins cleaning.</span>")

/obj/machinery/vending/pathology
	name = "Path-o-Matic"
	desc = "Pathology equipment dispenser."
	icon_state = "path"
	icon_panel = "standard-panel"
	icon_deny = "path-deny"
	icon_off = "med-off"
	icon_broken = "med-broken"
	icon_fallen = "med-fallen"

	New()
		..()
		//Products
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe, 12)
		product_list += new/datum/data/vending_product(/obj/item/bloodslide, 50)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/vial, 25)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/petridish, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker/parasiticmedium, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker/fungal, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker/bacterial, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker/egg, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker/spaceacillin, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker/antiviral, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker/biocides, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker/inhibitor, 20)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer, 4)

/obj/machinery/incubator
	name = "Incubator"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "incubator"
	var/static/image/icon_beaker = image('icons/obj/chemical.dmi', "heater-beaker")
	desc = "A machine that can automatically provide a petri dish with nutrients. It can also directly fill vials with a sample of the pathogen inside."
	anchored = 1
	density = 1
	var/obj/item/reagent_containers/glass/petridish/target = null
	var/medium = null

	New()
		..()
		flags |= NOSPLASH

	update_icon()
		if (src.target)
			icon_state = "incubator_on"
		else
			icon_state = "incubator"

	attack_hand(mob/user)
		if(isnull(user.equipped()))
			if (src.target)
				src.target.set_loc(src.loc)
				user.put_in_hand_or_eject(src.target)
				src.target = null
				src.UpdateIcon()
		return

	attackby(var/obj/item/O, var/mob/user)
		if (istype(O, /obj/item/reagent_containers/glass/petridish))
			if (src.target)
				boutput(user, "<span class='alert'>There is already a petri dish in the machine.</span>")
				return
			else
				src.target = O
				user.drop_item()
				O.set_loc(src)
				if (src.target.reagents.has_reagent("pathogen"))
					var/datum/reagent/blood/pathogen/Q = src.target.reagents.reagent_list["pathogen"]
					var/datum/pathogen/PT = Q.pathogens[pick(Q.pathogens)] 	// more than one pathogen in a petri dish won't grow properly anyway
					medium = PT.body_type.growth_medium
				boutput(user, "You insert the [O] into the machine.")
				src.UpdateIcon()
		else if(istype(O, /obj/item/reagent_containers/glass/vial))
			var/obj/item/reagent_containers/glass/vial/V = O
			if(V.reagents.total_volume)
				boutput(user, "The [V] already has reagents inside it!")
			else if(src.target.reagents.total_volume <= 2)
				boutput(user, "The [src] does not have enough pathogen to dispense a sample.")
			else
				boutput(user, "The [src] dispenses some pathogen into the [V].")
				src.target.reagents.trans_to(V, 2)

	process()
		if(!src.target)
			return
		var/lowNutrients = isnull(src.target.nutrition)?1:0
		for(var/N in src.target.nutrition)
			if(src.target.nutrition[N] < 5 && N != "dna_mutagen") // noone ever gets a great mutatis anyway
				lowNutrients = 1
		if(lowNutrients)
			src.target.reagents.add_reagent(medium, 5)

	get_desc()
		if(src.target)
			if (src.target.reagents.has_reagent("pathogen"))
				. += "<br>The petri dish inside contains [src.target.reagents.reagent_list["pathogen"].volume] units of pathogen."
