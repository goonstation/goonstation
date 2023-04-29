
#define GENETICS_INJECTORS 1
#define GENETICS_ANALYZER 2
#define GENETICS_EMITTERS 3
#define GENETICS_RECLAIMER 4

/obj/machinery/computer/genetics
	name = "genetics console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "scanner"
	req_access = list(access_medlab)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	can_reconnect = TRUE
	circuit_type = /obj/item/circuitboard/genetics
	/// Linked scanner. For scanning.
	var/obj/machinery/genetics_scanner/scanner = null
	var/list/equipment = list(
		GENETICS_INJECTORS = 0,
		GENETICS_ANALYZER = 0,
		GENETICS_EMITTERS = 0,
		GENETICS_RECLAIMER = 0,
	)
	var/list/datum/bioEffect/saved_mutations = list()
	var/list/datum/dna_chromosome/saved_chromosomes = list()
	var/list/datum/bioEffect/combining = list()
	var/datum/dna_chromosome/to_splice = null
	var/datum/bioEffect/currently_browsing = null
	var/datum/geneticsResearchEntry/tracked_research = null
	var/last_scanner_alert = null
	var/last_scanner_alert_clear_after = INFINITY
	var/last_scanner_alert_error = FALSE
	var/datum/computer/file/genetics_scan/selected_record = null
	var/decrypt_bp_num = 0
	var/datum/basePair/decrypt_bp = null
	var/datum/bioEffect/decrypt_gene = null
	var/decrypt_correct_char = "?"
	var/decrypt_correct_pos = "?"
	var/datum/genetics_appearancemenu/modify_appearance = null

	var/registered_id = null

/obj/machinery/computer/genetics/New()
	..()
	START_TRACKING
	SPAWN(0.5 SECONDS)
		connection_scan()

/obj/machinery/computer/genetics/connection_scan()
	src.scanner = locate(/obj/machinery/genetics_scanner, orange(1,src))

/obj/machinery/computer/genetics/disposing()
	STOP_TRACKING
	..()

/obj/machinery/computer/genetics/attackby(obj/item/W, mob/user)
	if (istype(W,/obj/item/genetics_injector/dna_activator))
		var/obj/item/genetics_injector/dna_activator/DNA = W
		if (DNA.expended_properly)
			user.drop_item()
			qdel(DNA)
			activated_bonus(user)
		else if (DNA.uses < 1)
			// You get nothing from these but at least let people clean em up
			boutput(user, "You dispose of the [DNA].")
			user.drop_item()
			qdel(DNA)
		else
			src.Attackhand(user)
	else
		var/obj/item/device/pda2/PDA = W
		if (istype(PDA) && PDA.ID_card)
			W = PDA.ID_card

		var/obj/item/card/id/ID = W
		if (istype(ID))
			registered_id = ID.registered
			user.show_text("You swipe the ID on [src]. You will now receive a cut from gene booth sales.", "blue")
			return

		..()


/obj/machinery/computer/genetics/proc/activated_bonus(mob/user as mob)
	if (genResearch.time_discount < 0.75)
		genResearch.time_discount += 0.025
	if (genResearch.cost_discount < 0.75)
		genResearch.cost_discount += 0.025

	scanner_alert(user, "Recycled genetic info has yielded materials, auto-decryptors, and chromosomes.")
	genResearch.researchMaterial += 40
	genResearch.lock_breakers += rand(1, 3)
	var/numChromosomes = pick(16.5;2, 39.5;3, 22;4, 22;5)
	for (var/i in 1 to numChromosomes)
		var/type_to_make = pick(concrete_typesof(/datum/dna_chromosome))
		var/datum/dna_chromosome/C = new type_to_make(src)
		src.saved_chromosomes += C

/obj/machinery/computer/genetics/proc/bioEffect_sanity_check(datum/bioEffect/E, occupant_check = 1)
	var/mob/living/carbon/human/H = src.get_scan_subject()
	. = 0
	if(occupant_check)
		if (!istype(H))
			scanner_alert(usr, "Invalid subject.", error = TRUE)
			return 1
		else if(!H.bioHolder)
			scanner_alert(usr, "Invalid genetic structure.", error = TRUE)
			return 1
	if(!istype(E, /datum/bioEffect/))
		scanner_alert(usr, "Unrecognized gene.", error = TRUE)
		return 1

/obj/machinery/computer/genetics/proc/sample_sanity_check(var/datum/computer/file/genetics_scan/S)
	. = 0
	if (!istype(S, /datum/computer/file/genetics_scan/))
		scanner_alert(usr, "Unable to scan DNA sample. The sample may be corrupt.", error = TRUE)
		return 1

/obj/machinery/computer/genetics/proc/research_sanity_check(var/datum/geneticsResearchEntry/R)
	. = 0
	if (!istype(R, /datum/geneticsResearchEntry/))
		scanner_alert(usr, "Invalid research article.", error = TRUE)
		return 1

/obj/machinery/computer/genetics/proc/equipment_available(equipment = "analyser", datum/bioEffect/E)
	if (genResearch.debug_mode)
		return TRUE
	var/mob/living/subject = get_scan_subject()
	. = FALSE
	var/datum/bioEffect/GBE
	if (istype(E))
		GBE = E.get_global_instance()
	switch(equipment)
		if("analyser")
			if(genResearch.isResearched(/datum/geneticsResearchEntry/checker) && world.time >= src.equipment[GENETICS_ANALYZER])
				return 1
		if("emitter")
			if(!iscarbon(subject))
				return 0
			if(genResearch.isResearched(/datum/geneticsResearchEntry/rademitter) && world.time >= src.equipment[GENETICS_EMITTERS])
				return 1
		if("precision_emitter")
			if(!iscarbon(subject) || !E || !GBE || GBE.research_level < EFFECT_RESEARCH_DONE)
				return 0
			if (E.can_scramble)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/rad_precision) && world.time >= src.equipment[GENETICS_EMITTERS])
					return 1
		if("reclaimer")
			if(E?.can_reclaim && GBE?.research_level >= EFFECT_RESEARCH_DONE)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/reclaimer) && world.time >= src.equipment[GENETICS_RECLAIMER])
					return 1
		if("injector")
			if(genResearch.researchMaterial < genResearch.injector_cost)
				return 0
			if(E?.can_make_injector && GBE?.research_level >= EFFECT_RESEARCH_DONE)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/injector) && world.time >= src.equipment[GENETICS_INJECTORS])
					if (genResearch.researchMaterial >= genResearch.injector_cost)
						return 1
		if("genebooth")
			if(genResearch.researchMaterial < genResearch.genebooth_cost)
				return 0
			if(E?.can_make_injector && GBE?.research_level >= EFFECT_RESEARCH_IN_PROGRESS)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/genebooth))
					return 1
		if("activator")
			if(E?.can_make_injector && GBE?.research_level >= EFFECT_RESEARCH_DONE)
				if(world.time >= src.equipment[GENETICS_INJECTORS])
					return 1
		if("saver")
			if(E && GBE?.research_level >= EFFECT_RESEARCH_DONE)
				if (genResearch.isResearched(/datum/geneticsResearchEntry/saver) && src.saved_mutations.len < genResearch.max_save_slots)
					return 1

/obj/machinery/computer/genetics/proc/equipment_cooldown(var/equipment_num,var/time)
	if (genResearch.debug_mode)
		return
	if (!isnum(equipment_num) || !isnum(time))
		return
	if (equipment_num < 1 || equipment_num > src.equipment.len)
		return
	time *= genResearch.checkCooldownBonus()

	src.equipment[equipment_num] = world.time + time

/obj/machinery/computer/genetics/proc/get_scan_subject()
	if (!src)
		return null
	// Check for the occupant
	if (scanner?.occupant)
		// Verify that the occupant is actually inside the scanner
		if(scanner.occupant.loc != scanner)
			// They're not. Bweeoo, dodgy stuff alert

			// The person trying to use the computer should be inside the scanner, they know what they're doing
			if(usr == scanner.occupant)
				stack_trace("[identify_object(usr)] is using [identify_object(src)] while being inside a clone scanner. That's weird and they might be cheating!")

			scanner.occupant = null
			scanner.icon_state = "scanner_0"
			return null
		else
			for (var/D as anything in scanner.occupant.bioHolder.effects)
				var/datum/bioEffect/BE = scanner.occupant.bioHolder.effects[D]
				var/datum/bioEffect/GBE = BE.get_global_instance()
				if (GBE.research_level == EFFECT_RESEARCH_DONE)
					// Hey look, it's the gene, and it's activated.
					GBE.research_level = EFFECT_RESEARCH_ACTIVATED

			return scanner.occupant
	else
		return null

/obj/machinery/computer/genetics/proc/get_scanner()
	if (!src)
		return null
	if (scanner)
		return scanner
	return null

/obj/machinery/computer/genetics/proc/get_occupant_preview()
	if (!src.scanner)
		return null
	if (!src.scanner.occupant_preview)
		src.scanner.occupant_preview = new()
		src.scanner.occupant_preview.add_background("#092426", height_mult=2)
		src.scanner.update_occupant()
	return src.scanner.occupant_preview

/obj/machinery/computer/genetics/proc/update_occupant_preview()
	src.scanner?.update_occupant()

// There weren't any (Convair880)!
/obj/machinery/computer/genetics/proc/log_me(var/mob/M, var/action = "", var/datum/bioEffect/BE)
	if (!src || !M || !ismob(M) || !action)
		return

	logTheThing(LOG_STATION, usr, "uses [src.name] on [constructTarget(M,"station")][M.bioHolder ? " (Genetic stability: [M.bioHolder.genetic_stability])" : ""] at [log_loc(src)]. Action: [action][BE && istype(BE, /datum/bioEffect/) ? ". Gene: [BE] (Stability impact: [BE.stability_loss])" : ""]")
	return

/obj/machinery/computer/genetics/proc/log_maybe_cheater(var/who, var/action = "")
	// this is used repeatedly so let's just make it a proc and stop repeating ourselves 50 times
	message_admins("[key_name(who)] [action] (failed validation, maybe cheating)")
	logTheThing(LOG_DEBUG, who, "[action] but failed validation.")
	logTheThing(LOG_DIARY, who, "[action] but failed validation.", "debug")

/obj/machinery/computer/genetics/ui_status(mob/user)
	if (user in src.scanner)
		return UI_UPDATE
	. = ..()
	if (!src.allowed(user))
		. = min(., UI_UPDATE)

/obj/machinery/computer/genetics/proc/on_ui_interacted(mob/user, minor = FALSE)
	src.add_fingerprint(user)
	playsound(src.loc, 'sound/machines/keypress.ogg', minor ? 25 : 50, 1, -15)

/obj/machinery/computer/genetics/proc/play_emitter_sound()
	SPAWN(0)
		for (var/i = 0, i < 15 && (i < 3 || prob(genResearch.emitter_radiation)), i++)
			switch (genResearch.emitter_radiation)
				if(1 to 15)
					playsound(src.get_scanner(), "sound/items/geiger/geiger-1-[rand(1, 2)].ogg", 50, 1)
				if(15 to 30)
					playsound(src.get_scanner(), "sound/items/geiger/geiger-2-[rand(1, 2)].ogg", 50, 1)
				if(30 to 45)
					playsound(src.get_scanner(), "sound/items/geiger/geiger-3-[rand(1, 2)].ogg", 50, 1)
				if(45 to 60)
					playsound(src.get_scanner(), "sound/items/geiger/geiger-4-[rand(1, 3)].ogg", 50, 1)
				if(60 to INFINITY)
					playsound(src.get_scanner(), "sound/items/geiger/geiger-5-[rand(1, 3)].ogg", 50, 1)
			sleep(0.3 SECONDS)

/obj/machinery/computer/genetics/proc/scanner_alert(mob/user, message, remove_after = 5 SECONDS, error = FALSE)
	if (error)
		boutput(user, "<span class='alert'><b>SCANNER ERROR:</b> [message]</span>")
	else
		boutput(user, "<b>SCANNER ALERT:</b> [message]")
	src.last_scanner_alert = message
	src.last_scanner_alert_clear_after = TIME + remove_after
	src.last_scanner_alert_error = error

/obj/machinery/computer/genetics/proc/decrypt_sanity_check()
	if (!istype(src.decrypt_gene))
		return TRUE
	var/mob/subject = src.get_scan_subject()
	if (src.decrypt_bp.marker != "locked" || !subject?.bioHolder)
		src.clear_decrypt()
		return TRUE
	if (subject.bioHolder.effectPool[src.decrypt_gene.id] != src.decrypt_gene)
		src.clear_decrypt()
		return TRUE
	return FALSE

/obj/machinery/computer/genetics/proc/clear_decrypt()
	src.decrypt_bp_num = 0
	src.decrypt_bp = null
	src.decrypt_gene = null
	src.decrypt_correct_char = "?"
	src.decrypt_correct_pos = "?"

/obj/machinery/computer/genetics/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch (action)
		if("purchasematerial")
			. = TRUE
			// UI doesn't allow making invalid purchases,
			// but it can still be invalid due to lag.
			var/amount = params["amount"]
			amount = min(
				round(amount),
				genResearch.max_material - genResearch.researchMaterial,
				round(wagesystem.research_budget / 50),
			)
			if (amount > 0)
				var/cost = amount * 50
				wagesystem.research_budget -= cost
				genResearch.researchMaterial += amount
				on_ui_interacted(ui.user)
		if("research")
			. = TRUE
			var/datum/geneticsResearchEntry/E = locate(params["ref"])
			if (!research_sanity_check(E))
				if (genResearch.addResearch(E))
					scanner_alert(ui.user, "Research initiated successfully.")
				else
					scanner_alert(ui.user, "Unable to begin research.", error = TRUE)
				on_ui_interacted(ui.user)
		if("setgene")
			. = TRUE
			src.currently_browsing = locate(params["ref"])
			on_ui_interacted(ui.user, minor = TRUE)
		if("setrecord")
			. = TRUE
			src.selected_record = locate(params["ref"])
			on_ui_interacted(ui.user, minor = TRUE)
		if("clearrecord")
			. = TRUE
			src.selected_record = null
			on_ui_interacted(ui.user, minor = TRUE)
		if("activator")
			. = TRUE
			var/datum/bioEffect/E = locate(params["ref"])
			var/datum/bioEffect/GBE = E.get_global_instance()
			if (GBE.research_level < EFFECT_RESEARCH_DONE)
				src.log_maybe_cheater(usr, "tried to create a [E.id] activator on an unresearched gene (href spoofing?)")
				return
			if (!E.can_make_injector)
				src.log_maybe_cheater(usr, "tried to create a [E.id] activator (non-injectable gene)")
				return
			if (!bioEffect_sanity_check(E, 0) && src.equipment_available("activator", E))
				src.equipment_cooldown(GENETICS_INJECTORS, 200)
				var/obj/item/genetics_injector/dna_activator/I = new(src.loc)
				I.name = "dna activator - [E.name]"
				I.gene_to_activate = E.id
				on_ui_interacted(ui.user)
				playsound(src, 'sound/machines/click.ogg', 50, 1)
		if("injector")
			. = TRUE
			if (!genResearch.isResearched(/datum/geneticsResearchEntry/injector))
				return
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E, 0))
				return
			var/mob/living/L = get_scan_subject()
			if (!((L && L.bioHolder && L.bioHolder.HasEffect(E.id)) || (E in saved_mutations)) || !E.can_make_injector)
				src.log_maybe_cheater(usr, "tried to create a [E.id] injector")
				return
			if (!src.equipment_available("injector", E))
				return
			var/price = genResearch.injector_cost
			if (genResearch.researchMaterial < price)
				return
			src.equipment_cooldown(GENETICS_INJECTORS, 400)
			genResearch.researchMaterial -= price
			var/obj/item/genetics_injector/dna_injector/I = new /obj/item/genetics_injector/dna_injector(src.loc)
			I.name = "dna injector - [E.name]"
			var/datum/bioEffect/NEW = new E.type(I)
			copy_datum_vars(E, NEW)
			I.BE = NEW
			on_ui_interacted(ui.user)
			playsound(src, 'sound/machines/click.ogg', 50, 1)
		if("researchmut")
			. = TRUE
			var/datum/bioEffect/E = locate(params["ref"])
			if (params["sample"])
				if (bioEffect_sanity_check(E, 0))
					return
				if (!istype(selected_record))
					return
				if (!(E in selected_record.dna_pool))
					return
			else if (bioEffect_sanity_check(E))
				return
			genResearch.addResearch(E)
			on_ui_interacted(ui.user)
		if("advancepair")
			. = TRUE
			var/mob/living/subject = get_scan_subject()
			if (!subject)
				return
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E))
				return
			if (istext(E.req_mut_research) && GetBioeffectResearchLevelFromGlobalListByID(E.req_mut_research) < EFFECT_RESEARCH_DONE)
				scanner_alert(usr, "Genetic structure unknown. Cannot alter mutation.", error = TRUE)
				return
			var/bp_num = params["pair"]
			var/datum/basePair/bp = E.dnaBlocks.blockListCurr[bp_num]
			if (!subject.bioHolder.HasEffectInPool(E.id))
				return
			if (!bp)
				return
			if (bp.marker == "locked")
				src.decrypt_bp_num = bp_num
				src.decrypt_bp = bp
				src.decrypt_gene = E
				return
			if (bp.bpp1 == "?")
				switch (bp.bpp2)
					if("G")
						bp.bpp1 = "C"
					if("C")
						bp.bpp1 = "G"
					if("A")
						bp.bpp1 = "T"
					if("T")
						bp.bpp1 = "A"
					else
						bp.bpp1 = "G"
						bp.bpp2 = "C"
			else if (bp.bpp2 == "?")
				switch (bp.bpp1)
					if("G")
						bp.bpp2 = "C"
					if("C")
						bp.bpp2 = "G"
					if("A")
						bp.bpp2 = "T"
					if("T")
						bp.bpp2 = "A"
			else
				switch (bp.bpp1)
					if("G")
						bp.bpp1 = "C"
						bp.bpp2 = "G"
					if("C")
						bp.bpp1 = "A"
						bp.bpp2 = "T"
					if("A")
						bp.bpp1 = "T"
						bp.bpp2 = "A"
					if("T")
						bp.bpp1 = "G"
						bp.bpp2 = "C"
			bp.style = "3"
			if (E.dnaBlocks.sequenceCorrect())
				E.dnaBlocks.ChangeAllMarkers("white")
			on_ui_interacted(ui.user, minor = TRUE)
		if("analyze")
			. = TRUE
			if (!src.equipment_available("analyser"))
				return
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E))
				return
			for(var/i = 1, i <= length(E.dnaBlocks.blockListCurr), i++)
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[i]
				var/datum/basePair/bpc = E.dnaBlocks.blockList[i]
				if (bp.marker == "locked")
					continue
				if (bp.bpp1 == bpc.bpp1 && bp.bpp2 == bpc.bpp2)
					bp.marker = "blue"
					bp.style = ""
				else
					bp.marker = "red"
					bp.style = "5"
			src.equipment_cooldown(GENETICS_ANALYZER, 200)
			on_ui_interacted(ui.user)
		if("autocomplete")
			. = TRUE
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E))
				return
			for(var/i = 1, i <= length(E.dnaBlocks.blockListCurr), i++)
				var/datum/basePair/current = E.dnaBlocks.blockListCurr[i]
				var/datum/basePair/correct = E.dnaBlocks.blockList[i]
				if (current.marker == "locked")
					continue
				current.bpp1 = correct.bpp1
				current.bpp2 = correct.bpp2
				current.style = ""
				current.marker = "white"
				on_ui_interacted(ui.user, minor = TRUE)
		if("activate")
			. = TRUE
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E))
				return
			if (!E.dnaBlocks.sequenceCorrect())
				return
			var/mob/living/subject = get_scan_subject()
			src.log_me(subject, "mutation activated", E)
			if (subject.bioHolder.ActivatePoolEffect(E) && !isnpcmonkey(subject) && subject.client)
				activated_bonus(usr)
			on_ui_interacted(ui.user)
		if("mutantrace")
			. = TRUE
			var/mob/living/carbon/human/H = get_scan_subject()
			if (!istype(H) || isprematureclone(H))
				return
			var/datum/bioEffect/mutantrace/BE = locate(params["ref"])
			if (H.mutantrace && !H.mutantrace?.genetics_removable)
				//this should probably be a UI notification but I'm not touching that code with a ten foot pole
				scanner_alert(ui.user, "Unable to purge corrupt genotype.")
				return
			if (isnull(BE))
				if (!isnull(H.mutantrace))
					src.log_me(H, "mutantrace removed")
				H.set_mutantrace(null)
			else
				if (!istype(BE) || BE.effectType != EFFECT_TYPE_MUTANTRACE || BE.research_level < EFFECT_RESEARCH_DONE || !BE.mutantrace_option || !H.bioHolder)
					return
				H.set_mutantrace(BE.mutantrace_path)
				src.log_me(H, "mutantrace added", BE)
			src.update_occupant_preview()
			on_ui_interacted(ui.user)
		if("editappearance")
			. = TRUE
			if (!src.modify_appearance)
				var/mob/living/carbon/human/H = get_scan_subject()
				if (istype(H))
					src.log_me(H, "appearance modifier accessed")
					src.modify_appearance = new(H)
			if (!src.modify_appearance || src.modify_appearance.target_mob != get_scan_subject())
				qdel(src.modify_appearance)
				src.modify_appearance = null
				return
			src.modify_appearance.ui_act(action, params, ui, state)
			if (params["apply"] || params["cancel"])
				qdel(src.modify_appearance)
				src.modify_appearance = null
				src.update_occupant_preview()
		if("emitter")
			. = TRUE
			if (!src.equipment_available("emitter"))
				return
			var/mob/living/subject = get_scan_subject()
			if (!subject || subject.health <= 0)
				return
			src.log_me(subject, "DNA scrambled")
			var/addEffect = null
			var/mob/living/carbon/human/H = subject
			if (istype(H) && H.mutantrace)
				var/datum/bioEffect/mutantrace = H.mutantrace.race_mutation
				if (mutantrace && GetBioeffectResearchLevelFromGlobalListByID(initial(mutantrace.id)) >= EFFECT_RESEARCH_ACTIVATED)
					addEffect = initial(mutantrace.id)
			subject.bioHolder.RemoveAllEffects()
			subject.bioHolder.BuildEffectPool()
			if (addEffect) // re-mutantify if we would have been able to anyway
				subject.bioHolder.AddEffect(addEffect)
			if (genResearch.emitter_radiation > 0)
				subject.take_radiation_dose((genResearch.emitter_radiation/75) * 0.5 SIEVERTS)
			src.equipment_cooldown(GENETICS_EMITTERS, 1200)
			scanner_alert(ui.user, "Genes successfully scrambled.")
			on_ui_interacted(ui.user)
			play_emitter_sound()
		if("precisionemitter")
			. = TRUE
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E))
				return
			if (!src.equipment_available("precision_emitter", E))
				return
			var/mob/living/subject = get_scan_subject()
			if(!subject)
				return
			if(subject.stat)
				return
			src.log_me(subject, "gene scrambled", E)
			if (genResearch.emitter_radiation > 0)
				subject.take_radiation_dose((genResearch.emitter_radiation/75) * 0.1 SIEVERTS)
			subject.bioHolder.RemovePoolEffect(E)
			subject.bioHolder.AddRandomNewPoolEffect()
			src.equipment_cooldown(GENETICS_EMITTERS, 600)
			scanner_alert(ui.user, "Gene successfully scrambled.")
			on_ui_interacted(ui.user)
			play_emitter_sound()
		if("booth")
			. = TRUE
			if (!genResearch.isResearched(/datum/geneticsResearchEntry/genebooth))
				return
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E, 0))
				return
			var/mob/living/L = get_scan_subject()
			if (!((L && L.bioHolder && L.bioHolder.HasEffect(E.id)) || (E in saved_mutations)))
				src.log_maybe_cheater(usr, "tried to send [E.id] to the booth")
				return
			if (!src.equipment_available("genebooth", E))
				return
			var/price = genResearch.genebooth_cost
			if (genResearch.researchMaterial < price)
				return
			if (!E.can_make_injector)
				return
			genResearch.researchMaterial -= price
			var/booth_effect_cost = text2num_safe(params["price"])
			booth_effect_cost = clamp(booth_effect_cost, 0, 999999)
			var/booth_effect_desc = params["desc"]
			booth_effect_desc = strip_html(booth_effect_desc, 280)
			for_by_tcl(GB, /obj/machinery/genetics_booth)
				var/already_has = 0
				for (var/datum/geneboothproduct/P as anything in GB.offered_genes)
					if (P.id == E.id && P.name == E.name)
						already_has = P
						P.uses += 5
						P.desc = booth_effect_desc
						P.cost = booth_effect_cost
						P.registered_sale_id = registered_id
						scanner_alert(ui.user, "Sent 5 of '[P.name]' to gene booth.")
						GB.reload_contexts()
						break
				if (!already_has)
					var/datum/bioEffect/NEW = new E.type(GB)
					copy_datum_vars(E, NEW)
					GB.offered_genes += new /datum/geneboothproduct(NEW,booth_effect_desc,booth_effect_cost,registered_id)
					if (GB.offered_genes.len == 1)
						GB.select_product(GB.offered_genes[1])
					scanner_alert(ui.user, "Sent 5 of '[NEW.name]' to gene booth.")
					GB.reload_contexts()
			on_ui_interacted(ui.user)
		if("splicechromosome")
			. = TRUE
			var/datum/dna_chromosome/E = locate(params["ref"])
			if (!istype(E))
				return
			if (!(E in saved_chromosomes))
				src.log_maybe_cheater(usr, "tried to splice a chromosome ([E])")
				return
			src.to_splice = E
			on_ui_interacted(ui.user, minor = TRUE)
		if("deletechromosome")
			. = TRUE
			var/datum/dna_chromosome/E = locate(params["ref"])
			if (!istype(E))
				return
			if (!(E in saved_chromosomes))
				src.log_maybe_cheater(usr, "tried to delete a chromosome ([E])")
				return
			if (E == src.to_splice)
				src.to_splice = null
			saved_chromosomes -= E
			qdel(E)
			scanner_alert(ui.user, "Chromosome deleted.")
			on_ui_interacted(ui.user)
		if("splicegene")
			. = TRUE
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E, 0))
				return
			if (!src.to_splice)
				return
			var/datum/dna_chromosome/C = src.to_splice
			var/result = C.apply(E)
			if(isnull(result))
				src.saved_chromosomes -= C
				qdel(C)
				src.to_splice = null
			on_ui_interacted(ui.user)
		if("deletegene")
			. = TRUE
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E, 0))
				return
			if (!(E in saved_mutations))
				src.log_maybe_cheater(usr, "tried to delete the [E.id] mutation")
				return
			saved_mutations -= E
			qdel(E)
			scanner_alert(ui.user, "Mutation deleted.")
			on_ui_interacted(ui.user)
		if("reclaim")
			. = TRUE
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E))
				return
			if (!src.equipment_available("reclaimer", E))
				return
			var/mob/living/subject = get_scan_subject()
			if (!subject)
				return
			var/reclamation_cap = genResearch.max_material * 1.5
			on_ui_interacted(ui.user)
			if (prob(E.reclaim_fail))
				scanner_alert(ui.user, "Reclamation failed.", error = TRUE)
			else
				var/waste = (E.reclaim_mats + genResearch.researchMaterial) - reclamation_cap
				if (waste >= E.reclaim_mats)
					scanner_alert(ui.user, "Nothing would be gained from reclamation due to material capacity limit. Reclamation aborted.", error = TRUE)
					playsound(src, 'sound/machines/buzz-two.ogg', 50, 1, -10)
					return
				genResearch.researchMaterial = min(genResearch.researchMaterial + E.reclaim_mats, reclamation_cap)
				if (waste > 0)
					scanner_alert(ui.user, "Reclamation successful. [E.reclaim_mats] materials gained. Material count now at [genResearch.researchMaterial]. [waste] units of material wasted due to material capacity limit.")
				else
					scanner_alert(ui.user, "Reclamation successful. [E.reclaim_mats] materials gained. Material count now at [genResearch.researchMaterial].")
				subject.bioHolder.RemoveEffect(E.id)
				E.owner = null
				E.holder = null
				saved_mutations -= E
				qdel(E)
			playsound(src, 'sound/machines/pc_process.ogg', 50, 1)
			src.equipment_cooldown(GENETICS_RECLAIMER, 600)
		if("save")
			. = TRUE
			if (!genResearch.isResearched(/datum/geneticsResearchEntry/saver))
				return
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E))
				return
			var/mob/living/subject = get_scan_subject()
			if(!subject.bioHolder.HasEffect(E.id))
				src.log_maybe_cheater(usr, "tried to store a [E.id] mutation")
				return
			if (saved_mutations.len >= genResearch.max_save_slots)
				return
			src.log_me(subject, "mutation removed", E)
			src.saved_mutations += E
			subject.bioHolder.RemoveEffect(E.id)
			E.owner = null
			E.holder = null
			on_ui_interacted(ui.user)
		if("addstored")
			. = TRUE
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E))
				return
			if (!(E in saved_mutations))
				src.log_maybe_cheater(usr, "tried to add the [E.id] mutation")
				return
			var/mob/living/subject = get_scan_subject()
			if (!subject)
				return
			src.log_me(subject, "mutation added", E)
			subject.bioHolder.AddEffectInstance(E)
			saved_mutations -= E
			scanner_alert(ui.user, "Mutation successfully added to occupant.")
			on_ui_interacted(ui.user)
		if("togglecombine")
			. = TRUE
			var/datum/bioEffect/E = locate(params["ref"])
			if (bioEffect_sanity_check(E, 0))
				return
			if (E in combining)
				combining -= E
			else
				combining += E
			on_ui_interacted(ui.user, minor = TRUE)
		if("combinegenes")
			. = TRUE
			for (var/datum/geneticsrecipe/GR in genResearch.combinationrecipes)
				var/matches = 0
				if (GR.required_effects.len != src.combining.len)
					continue
				var/list/temp = GR.required_effects.Copy()
				for (var/datum/bioEffect/BE as anything in src.combining)
					if (BE.wildcard)
						matches++
					if (BE.id in temp)
						temp -= BE.id
						matches++
				if (matches == GR.required_effects.len)
					var/datum/bioEffect/NEWBE = new GR.result()
					src.saved_mutations += NEWBE
					var/datum/bioEffect/GBE = NEWBE.get_global_instance()
					NEWBE.dnaBlocks.blockList = GBE.dnaBlocks.blockList
					GBE.research_level = max(GBE.research_level, EFFECT_RESEARCH_ACTIVATED) // counts as researching it
					for (var/datum/bioEffect/X as anything in src.combining)
						src.saved_mutations -= X
						src.combining -= X
						qdel(X)
					scanner_alert(ui.user, "Combination successful. New '[NEWBE.name]' mutation created.")
					src.currently_browsing = NEWBE
					on_ui_interacted(ui.user)
					return
			scanner_alert(ui.user, "Combination unsuccessful.", error = TRUE)
			src.combining = list()
			on_ui_interacted(ui.user)
		if ("unlock")
			. = TRUE
			if (src.decrypt_sanity_check())
				return
			var/code = params["code"]
			if (!code)
				src.clear_decrypt()
				return
			code = uppertext(code)
			if (code == "UNLOCK")
				if (genResearch.lock_breakers > 0)
					genResearch.lock_breakers--
					code = src.decrypt_bp.lockcode
				else
					return
			if (length(code) != src.decrypt_gene.lockedDiff)
				// shouldn't be able to get here through the UI.
				return
			if (code == src.decrypt_bp.lockcode)
				var/datum/basePair/bpc = src.decrypt_gene.dnaBlocks.blockList[src.decrypt_bp_num]
				src.decrypt_bp.bpp1 = bpc.bpp1
				src.decrypt_bp.bpp2 = bpc.bpp2
				src.decrypt_bp.marker = "green"
				src.decrypt_bp.style = ""
				scanner_alert(ui.user, "Base pair unlocked.")
				on_ui_interacted(ui.user)
				if (src.decrypt_gene.dnaBlocks.sequenceCorrect())
					src.decrypt_gene.dnaBlocks.ChangeAllMarkers("white")
				src.clear_decrypt()
				return
			if (src.decrypt_bp.locktries <= 1)
				src.decrypt_bp.lockcode = ""
				for (var/c = src.decrypt_gene.lockedDiff, c > 0, c--)
					src.decrypt_bp.lockcode += pick(src.decrypt_gene.lockedChars)
				src.decrypt_bp.locktries = src.decrypt_gene.lockedTries
				scanner_alert(ui.user, "Decryption failed. Base pair encryption code has mutated.", error = TRUE)
				on_ui_interacted(ui.user)
				src.clear_decrypt()
				return
			src.decrypt_bp.locktries--
			var/L = length(src.decrypt_bp.lockcode)
			var/list/lockcode_list = list()
			for (var/i = 0, i < L, i++)
				lockcode_list["[copytext(src.decrypt_bp.lockcode, i + 1, i + 2)]"]++
			var/correct_full = 0
			var/correct_char = 0
			var/current
			var/seek = 0
			for(var/i = 0, i < L, i++)
				current = copytext(code, i + 1, i + 2)
				if (current == copytext(src.decrypt_bp.lockcode, i + 1, i + 2))
					correct_full++
				seek = lockcode_list.Find(current)
				if (seek)
					correct_char++
					lockcode_list[current]--
					if (lockcode_list[current] <= 0)
						lockcode_list -= current
			src.decrypt_correct_char = correct_char
			src.decrypt_correct_pos = correct_full
			scanner_alert(ui.user, "Decryption code \"[code]\" failed.", error = TRUE)
			on_ui_interacted(ui.user)

/obj/machinery/computer/genetics/proc/serialize_bioeffect_for_tgui(datum/bioEffect/BE, active = FALSE, potential = FALSE, full_data = TRUE)
	var/datum/bioEffect/GBE = BE.get_global_instance()
	var/research_level = GBE.research_level

	. = list(
		"ref" = "\ref[BE]",
		"name" = research_level >= EFFECT_RESEARCH_DONE ? BE.name \
			: "Unknown Mutation",
		"research" = research_level
		)
	// The following items are only applicable for currently selected gene or list of mutations
	if(full_data)
		var/list/blockList = active || (research_level >= EFFECT_RESEARCH_ACTIVATED && !potential) ? GBE.dnaBlocks.blockList : BE.dnaBlocks.blockListCurr
		if (!length(blockList)) // stable mutagen doesn't generate messed-up DNA for genes :(
			BE.dnaBlocks.ModBlocks()
			blockList = BE.dnaBlocks.blockListCurr

		var/list/dna = list()
		for (var/datum/basePair/BP as anything in blockList)
			dna += list(list(
				"pair" = "[BP.bpp1][BP.bpp2]",
				"style" = BP.style,
				"marker" = BP.marker,
			))

		. += list(
			"desc" = research_level >= EFFECT_RESEARCH_ACTIVATED && !isnull(BE.researched_desc) ? BE.researched_desc \
				: research_level >= EFFECT_RESEARCH_DONE ? BE.desc \
				: research_level >= EFFECT_RESEARCH_IN_PROGRESS ? "Research on this gene is currently in progress." \
				: "Research on a non-active instance of this gene is required.",
			"icon" = research_level >= EFFECT_RESEARCH_DONE ? BE.icon_state : "unknown",
			"time" = GBE.research_finish_time,
			"canResearch" = BE.can_research,
			"canInject" = BE.can_make_injector,
			"canScramble" = BE.can_scramble,
			"canReclaim" = BE.can_reclaim,
			"spliceError" = src.to_splice?.check_apply(BE),
			"dna" = dna,
			)

/obj/machinery/computer/genetics/ui_data(mob/user)
	var/mut_research_cost = genResearch.mut_research_cost
	if (genResearch.cost_discount)
		mut_research_cost -= round(mut_research_cost * genResearch.cost_discount)

	if (src.last_scanner_alert_clear_after < TIME)
		src.last_scanner_alert = null
		src.last_scanner_alert_clear_after = INFINITY
		src.last_scanner_alert_error = FALSE

	. = list(
		"haveScanner" = !isnull(get_scanner()),
		"materialCur" = genResearch.researchMaterial,
		"mutationsResearched" = genResearch.mutations_researched,
		"autoDecryptors" = genResearch.lock_breakers,
		"budget" = wagesystem.research_budget,
		"costPerMaterial" = 50,
		"researchCost" = mut_research_cost,
		"toSplice" = src.to_splice?.name,
		"activeGene" = "\ref[src.currently_browsing]",
		"scannerAlert" = src.last_scanner_alert,
		"scannerError" = src.last_scanner_alert_error,
		"availableResearch" = list(list(), list(), list(), list()),
		"finishedResearch" = list(list(), list(), list(), list()),
		"currentResearch" = list(),
		"equipmentCooldown" = list(),
		"samples" = list(),
		"savedMutations" = list(),
		"savedChromosomes" = list(),
		"combining" = list(),
		"unlock" = null,
		"allowed" = src.allowed(user),
	)

	for(var/datum/db_record/R as anything in data_core.medical.records)
		var/datum/computer/file/genetics_scan/S = R["dnasample"]
		if (!istype(S))
			continue
		.["samples"] += list(list(
			"ref" = "\ref[S]",
			"name" = S.subject_name,
			"uid" = S.subject_uID,
		))

	for(var/datum/bioEffect/BE as anything in saved_mutations)
		.["savedMutations"] += list(serialize_bioeffect_for_tgui(BE))

	for(var/datum/dna_chromosome/C as anything in saved_chromosomes)
		.["savedChromosomes"] += list(list(
			"ref" = "\ref[C]",
			"name" = C.name,
			"desc" = C.desc,
		))

	for (var/datum/bioEffect/BE as anything in combining)
		.["combining"] += "\ref[BE]"

	if (!src.decrypt_sanity_check())
		.["unlock"] = list(
			"length" = src.decrypt_gene.lockedDiff,
			"chars" = src.decrypt_gene.lockedChars,
			"correctChar" = src.decrypt_correct_char,
			"correctPos" = src.decrypt_correct_pos,
			"tries" = src.decrypt_bp.locktries,
		)

	if (istype(selected_record))
		var/list/genes = list()
		for (var/datum/bioEffect/BE as anything in selected_record.dna_pool)
			var/datum/bioEffect/GBE = BE.get_global_instance()
			if (GBE.secret && !genResearch.see_secret)
				continue
			genes += list(serialize_bioeffect_for_tgui(BE, full_data=(BE == src.currently_browsing)))
		.["record"] = list(
			"ref" = "\ref[selected_record]",
			"name" = selected_record.subject_name,
			"uid" = selected_record.subject_uID,
			"genes" = genes,
		)
	else
		.["record"] = null

	var/mob/living/subject = get_scan_subject()
	if (subject)
		var/mob/living/carbon/human/H = subject
		var/datum/movable_preview/character/multiclient/P = src.get_occupant_preview()
		P?.add_client(user?.client)
		.["subject"] = list(
			"preview" = P?.preview_id,
			"name" = subject.name,
			"stat" = subject.stat,
			"health" = subject.health / subject.max_health,
			"stability" = subject.bioHolder.genetic_stability,
			"human" = istype(H),
			"bloodType" = subject.bioHolder.bloodType,
			"age" = subject.bioHolder.age,
			"mutantRace" = istype(H) ? capitalize(H.mutantrace?.name || "human") : "Unknown",
			"canAppearance" = istype(H) && (!H.mutantrace || length(H.mutantrace.color_channel_names) || H.mutantrace.mutant_appearance_flags & (HAS_HUMAN_SKINTONE | HAS_HUMAN_EYES | HAS_HUMAN_HAIR)),
			"premature" = isprematureclone(subject),
			"potential" = list(),
			"active" = list()
			)
		for (var/D in subject.bioHolder.effectPool)
			var/datum/bioEffect/BE = subject.bioHolder.effectPool[D]
			var/datum/bioEffect/GBE = BE.get_global_instance()
			if (!BE.scanner_visibility)
				continue
			if (GBE.secret && !genResearch.see_secret)
				continue
			.["subject"]["potential"] += list(serialize_bioeffect_for_tgui(BE, potential = TRUE, full_data=(BE == src.currently_browsing)))
		for (var/D in subject.bioHolder.effects)
			var/datum/bioEffect/BE = subject.bioHolder.effects[D]
			var/datum/bioEffect/GBE = BE.get_global_instance()
			if (!BE.scanner_visibility)
				continue
			if (GBE.secret && !genResearch.see_secret)
				continue
			.["subject"]["active"] += list(serialize_bioeffect_for_tgui(BE, active = TRUE, full_data=(BE == src.currently_browsing)))
		if (src.modify_appearance)
			.["modifyAppearance"] = src.modify_appearance.ui_data(user)
		else
			.["modifyAppearance"] = null
	else
		.["subject"] = null

	for(var/R as anything in genResearch.researchTreeTiered)
		if (text2num_safe(R) == 0)
			continue
		var/list/availTier = list()
		var/list/finishedTier = list()
		var/list/tierList = genResearch.researchTreeTiered[R]

		for (var/datum/geneticsResearchEntry/C as anything in tierList)
			if (C.meetsRequirements())
				var/research_cost = C.researchCost
				if (genResearch.cost_discount)
					research_cost -= round(research_cost * genResearch.cost_discount)
				var/research_time = C.researchTime
				if (genResearch.time_discount)
					research_time -= round(research_time * genResearch.time_discount)
				if (research_time)
					research_time = round(research_time / 10)

				availTier += list(list(
					"ref" = "\ref[C]",
					"cost" = research_cost,
					"time" = research_time,
				))
			else if (C.isResearched == 1)
				finishedTier += list(list(
					"ref" = "\ref[C]",
				))

		.["availableResearch"][text2num_safe(R)] = availTier
		.["finishedResearch"][text2num_safe(R)] = finishedTier

	for(var/datum/geneticsResearchEntry/R as anything in genResearch.currentResearch)
		.["currentResearch"] += list(list(
			"ref" = "\ref[R]",
			"name" = R.name,
			"desc" = R.desc,
			"current" = R.finishTime - world.time,
			"total" = R.researchTime,
		))

	.["equipmentCooldown"] += list(list(
		"label" = "Injectors",
		"cooldown" = src.equipment[GENETICS_INJECTORS] - world.time,
	))
	if (genResearch.isResearched(/datum/geneticsResearchEntry/checker))
		.["equipmentCooldown"] += list(list(
			"label" = "Analyzer",
			"cooldown" = src.equipment[GENETICS_ANALYZER] - world.time,
		))
	if (genResearch.isResearched(/datum/geneticsResearchEntry/rademitter))
		.["equipmentCooldown"] += list(list(
			"label" = "Emitter",
			"cooldown" = src.equipment[GENETICS_EMITTERS] - world.time,
		))
	if (genResearch.isResearched(/datum/geneticsResearchEntry/reclaimer))
		.["equipmentCooldown"] += list(list(
			"label" = "Reclaimer",
			"cooldown" = src.equipment[GENETICS_RECLAIMER] - world.time,
		))

/obj/machinery/computer/genetics/ui_static_data(mob/user)
	. = list("research"=list(),
					"boothCost" = genResearch.isResearched(/datum/geneticsResearchEntry/genebooth) ? genResearch.genebooth_cost : -1,
					"injectorCost" = genResearch.isResearched(/datum/geneticsResearchEntry/injector) ? genResearch.injector_cost : -1,
					"saveSlots" = genResearch.isResearched(/datum/geneticsResearchEntry/saver) ? genResearch.max_save_slots : 0,
					"precisionEmitter" = genResearch.isResearched(/datum/geneticsResearchEntry/rad_precision),
					"materialMax" = genResearch.max_material,
					"mutantRaces" = list(list(
						"name" = "Human",
						"icon" = "template",
						"ref" = "\ref[null]",
						)),
					)

	var/bioEffects = list()
	for (var/id as anything in bioEffectList)
		var/datum/bioEffect/BE = bioEffectList[id]
		if (!BE.scanner_visibility || BE.research_level < EFFECT_RESEARCH_IN_PROGRESS)
			continue
		bioEffects += list(serialize_bioeffect_for_tgui(BE))

		if (BE.effectType == EFFECT_TYPE_MUTANTRACE && BE.research_level >= EFFECT_RESEARCH_DONE && BE.mutantrace_option)
			.["mutantRaces"] += list(list(
				"name" = BE.mutantrace_option,
				"icon" = BE.icon_state,
				"ref" = "\ref[BE]",
			))
	.["bioEffects"] = bioEffects

	for(var/key as anything in genResearch.researchTree)
		var/datum/geneticsResearchEntry/R = genResearch.researchTree[key]

		//Only need name/description for available and completed research items
		if ((R.isResearched == 1) || R.meetsRequirements())
			.["research"]["\ref[R]"] = list(
				"name" = R.name,
				"desc" = R.desc
				)


/obj/machinery/computer/genetics/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GeneTek", "GeneTek Console v2.01")
		ui.open()

/obj/machinery/computer/genetics/ui_close(mob/user)
	. = ..()
	var/datum/movable_preview/character/multiclient/P = src.get_occupant_preview()
	P?.remove_client(user?.client)
	src.modify_appearance?.ui_close(user)

#undef GENETICS_INJECTORS
#undef GENETICS_ANALYZER
#undef GENETICS_EMITTERS
#undef GENETICS_RECLAIMER
