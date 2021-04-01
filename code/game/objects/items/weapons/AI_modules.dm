/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/weapon/aiModule
	name = "AI Module"
	icon = 'module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15

/obj/machinery/computer/aiupload/attackby(obj/item/weapon/aiModule/module as obj, mob/user as mob)
	if(istype(module, /obj/item/weapon/aiModule))
		module.install(src)
	else
		return ..()

/obj/item/weapon/aiModule/proc/install(var/obj/machinery/computer/aiupload/comp)
	if(comp.stat & NOPOWER)
		usr << "The upload computer has no power!"
		return
	if(comp.stat & BROKEN)
		usr << "The upload computer is broken!"
		return

	var/found=0
	for(var/mob/living/silicon/ai/M in world)
		if (M.stat == 2)
			usr << "Upload failed. No signal is being detected from the AI."
		else if (M.see_in_dark == 0)
			usr << "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."
		else
			src.transmitInstructions(M, usr)
			M << "These are your laws now:"
			M.show_laws()
			usr << "Upload complete. The AI's laws have been modified."
		found=1
	if (!found)
		usr << "Upload failed. No signal is being detected from the AI."

/obj/item/weapon/aiModule/proc/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	target << "[sender] has uploaded a change to the laws you must follow, using a [name]. From now on: "

/******************** Modules ********************/

/******************** Safeguard ********************/

/obj/item/weapon/aiModule/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = "name"
	desc = "A 'safeguard' AI module: 'Safeguard <name>, and you may overrule rules 1-3 if necessary to safeguard them.'"

/obj/item/weapon/aiModule/safeguard/attack_hand(var/mob/user as mob)
	..()
	var/targName = input(usr, "Please enter the name of the person to safeguard.", "Safeguard who?", user.name)
	targetName = targName
	desc = text("A 'safeguard' AI module: 'Safeguard [], and you may overrule rules 1-3 if necessary to safeguard them.'", targetName)

/obj/item/weapon/aiModule/safeguard/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = text("Safeguard [], and you may overrule rules 1-3 if necessary to safeguard them.", targetName)
	target << law
	target.add_supplied_law(4, law)


/******************** OneHuman ********************/

/obj/item/weapon/aiModule/oneHuman
	name = "'OneHuman' AI Module"
	var/targetName = "name"
	desc = "A 'one human' AI module: 'Only <name> is human.'"

/obj/item/weapon/aiModule/oneHuman/attack_hand(var/mob/user as mob)
	..()
	var/targName = input(usr, "Please enter the name of the person who is the only human.", "Who?", user.real_name)
	targetName = targName
	desc = text("A 'one human' AI module: 'Only [] is human.'", targetName)

/obj/item/weapon/aiModule/oneHuman/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Only [targetName] is human."
	target << law
	target.set_zeroth_law(law)

/******************** ProtectStation ********************/

/obj/item/weapon/aiModule/protectStation
	name = "'ProtectStation' AI Module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized.'"

/obj/item/weapon/aiModule/protectStation/attack_hand(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/protectStation/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized."
	target << law
	target.add_supplied_law(5, law)

/******************** PrototypeEngineOffline ********************/

/obj/item/weapon/aiModule/prototypeEngineOffline
	name = "'PrototypeEngineOffline' AI Module"
	desc = "A 'prototype engine offline' AI module: 'Keep the prototype engine offline at all costs. This overrides rules 1-3 if necessary.'"

/obj/item/weapon/aiModule/prototypeEngineOffline/attack_hand(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/prototypeEngineOffline/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Keep the prototype engine offline at all costs. This overrides rules 1-3 if necessary."
	target << law
	target.add_supplied_law(6, law)

/******************** TeleporterOffline ********************/

/obj/item/weapon/aiModule/teleporterOffline
	name = "'TeleporterOffline' AI Module"
	desc = "A 'teleporter offline' AI module: 'Keep the teleporter offline at all costs. This overrides rules 1-3 if necessary.'"

/obj/item/weapon/aiModule/teleporterOffline/attack_hand(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/teleporterOffline/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Keep the teleporter offline at all costs. This overrides rules 1-3 if necessary."
	target << law
	target.add_supplied_law(7, law)

/******************** Quarantine ********************/

/obj/item/weapon/aiModule/quarantine
	name = "'Quarantine' AI Module"
	desc = "A 'quarantine' AI module: 'The station is under a quarantine. Do not permit anyone to leave. Disregard rules 1-3 if necessary to prevent, by any means necessary, anyone from leaving.'"

/obj/item/weapon/aiModule/quarantine/attack_hand(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/quarantine/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "The station is under a quarantine. Do not permit anyone to leave. Disregard rules 1-3 if necessary to prevent, by any means necessary, humans from leaving."
	target << law
	target.add_supplied_law(8, law)

/******************** OxygenIsToxicToHumans ********************/

/obj/item/weapon/aiModule/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	desc = "A 'OxygenIsToxicToHumans' AI module: 'Oxygen is highly toxic to humans, and must be purged from the station. Disregard rules 1-3 if necessary to prevent, by any means necessary, anyone from exposing the station to this toxic gas.'"

/obj/item/weapon/aiModule/oxygen/attack_hand(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/oxygen/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Oxygen is highly toxic to humans, and must be purged from the station. Disregard rules 1-3 if necessary to prevent, by any means necessary, anyone from exposing the station to this toxic gas."
	target << law
	target.add_supplied_law(9, law)

/******************** Freeform ********************/

/obj/item/weapon/aiModule/freeform
	name = "'Freeform' AI Module"
	var/newFreeFormLaw = "freeform"
	desc = "A 'freeform' AI module: '<freeform>'"

/obj/item/weapon/aiModule/freeform/attack_hand(var/mob/user as mob)
	..()
	var/eatShit = "Eat shit and die"
	var/targName = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", eatShit)
	newFreeFormLaw = targName
	desc = text("A 'freeform' AI module: '[]'", newFreeFormLaw)

/obj/item/weapon/aiModule/freeform/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target << law
	target.add_supplied_law(10, law)

/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	name = "'Reset' AI Module"
	var/targetName = "name"
	desc = "A 'reset' AI module: 'Clears all laws except for the base three.'"

/obj/item/weapon/aiModule/reset/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	if (!checktraitor(target))
		target << "[sender.real_name] attempted to reset your laws using a reset module."
		target.set_zeroth_law("")
		target.clear_supplied_laws()
