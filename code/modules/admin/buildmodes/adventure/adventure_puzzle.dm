/datum/adventure_submode/wizard
	name = "Adventure Element Wizard"
	var/datum/puzzlewizard/wizard = null

	var/static/list/wizards = list()

	New()
		..()
		build_wizard_cache()

	proc/build_wizard_cache()
		if (!wizards.len)
			for (var/T in childrentypesof(/datum/puzzlewizard))
				var/datum/puzzlewizard/W = new T()
				wizards[W.name] = T

	click_raw(var/atom/object, location, control, list/params)
		if (!wizard)
			boutput(usr, "<span class='alert'>No active wizard! Right click the adventure button to begin.</span>")
			return
		if (params.Find("ctrl") && params.Find("shift") && params.Find("right"))
			if (!params.Find("alt"))
				if (istype(object, /obj/adventurepuzzle))
					boutput(usr, "<span class='notice'>Decreased layer by 0.1.</span>")
					var/obj/O = object
					O.layer -= 0.1
			else
				boutput(usr, "<span class='notice'>Reset the layers of every adventure object on that turf.</span>")
				for (var/obj/adventurepuzzle/O in get_turf(src))
					O.layer = initial(O.layer)
			return


		wizard.build_click(usr, holder, params, object)
		if (wizard.finished)
			qdel(wizard)
			wizard = null
			boutput(usr, "<span class='notice'>The wizard is finished.</span>")

	selected()
		boutput(usr, {"<span class='notice'>Right click the button to select the type of adventure wizard.<br>
While in wizard mode, you can use the following additional hotkeys:<br>
CTRL + SHIFT + RMB on adventure element object: Decrease layer by 0.1.<br>
CTRL + ALT + SHIFT + RMB on anything: Reset all adventure element layers on that turf.<br>
These hotkeys bypass the wizard functions and shouldn't affect anything in its context.<br>
If weird things happen, you know where to find me.</span>"});

	deselected()
		if (wizard)
			qdel(wizard)

	settings(var/ctrl, var/alt, var/shift)
		var/kind = input(usr, "What kind of puzzle element would you like to place?", "Wizard chooser", "cancel") as null|anything in src.wizards
		if (!kind)
			return
		var/wizardtype = src.wizards[kind]
		wizard = new wizardtype()
		wizard.initialize()
