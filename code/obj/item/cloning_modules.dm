/*

Modules to do things with cloning modules

*/


// This one makes clones come out faster. Nice!
/obj/item/cloneModule/speedyclone
	icon = 'icons/obj/module.dmi'
	icon_state = "speedyclone"
	name = "SpeedyClone2000"
	desc = "An experimental cloning module. Greatly speeds up the cloning process. Also voids the cloning pod warranty."


// This one makes the pod more efficient. For filthy space hippies who are into that recycling stuff.
/obj/item/cloneModule/efficientclone
	icon = 'icons/obj/module.dmi'
	icon_state = "efficientclone"
	name = "Biomatter recycling unit"
	desc = "An experimental cloning module. Lowers the amount of biomatter a cloning pod needs by recycling old biomatter."


// A spooky module. Zaps the memories of anyone who gets cloned in a machine using this
/obj/item/cloneModule/minderaser
	icon = 'icons/obj/module.dmi'
	icon_state = "mindwipe"
	name = "Prototype Rehabilitation Module #17"
	desc = "An experimental treatment device meant for only the worst of criminals. Fires a barrage of electrical signals to the brain during medical procedues. It looks like it has some cloning goop and blood smeared on it - yuck."

/obj/item/cloneModule/mindhack_module
	icon = 'icons/obj/cloning.dmi'
	icon_state = "mindhack"
	name = "Mindhack cloning module"
	desc = "A powerful device that remaps people's brains when they get cloned to make them completely loyal to the owner of this module"
	HELP_MESSAGE_OVERRIDE({"Click on a cloning pod while holding the Mindhack Cloning Module to install it. Anyone cloned while the module is on it will be loyal to the person who installed it. Use a <b>screwdriver</b> on the cloning pod to remove it."})

/obj/item/storage/box/mindhack_module_kit
	name = "Mindhack module kit"
	icon_state = "box"
	desc = "A box with a mindhack cloning module and a cloning lab. Yes, a whole cloning lab. In a box. Somehow."

	make_my_stuff()
		..()
		src.storage.add_contents(new /obj/item/cloneModule/mindhack_module(src))
		src.storage.add_contents(new /obj/item/disk/data/floppy(src))


		// Creates premade mechanics scanned items. That way you can make a cloning lab faster.

		var/obj/item/electronics/frame/flatpack/F1 = new(src)
		src.storage.add_contents(F1)
		F1.name = "Boxed Cloning Computer"
		F1.store_type = /obj/machinery/computer/cloning
		F1.viewstat = 2
		F1.secured = 2

		var/obj/item/electronics/frame/flatpack/F2 = new(src)
		src.storage.add_contents(F2)
		F2.name = "Disassembled Cloning Pod"
		F2.store_type = /obj/machinery/clonepod
		F2.viewstat = 2
		F2.secured = 2

		var/obj/item/electronics/frame/flatpack/F3 = new(src)
		src.storage.add_contents(F3)
		F3.name = "Compacted Giant Blender"
		F3.store_type = /obj/machinery/clonegrinder
		F3.viewstat = 2
		F3.secured = 2

		var/obj/item/electronics/frame/flatpack/F4 = new(src)
		src.storage.add_contents(F4)
		F4.name = "Expandable DNA Scanner"
		F4.store_type = /obj/machinery/clone_scanner
		F4.viewstat = 2
		F4.secured = 2

		var/obj/item/electronics/frame/flatpack/F5 = new(src)
		src.storage.add_contents(F5)
		F5.name = "Flatpacked Clone Rack"
		F5.store_type = /obj/machinery/disk_rack/clone
		F5.viewstat = 2
		F5.secured = 2

/obj/item/cloneModule/genepowermodule
	icon = 'icons/obj/module.dmi'
	icon_state = "genemodule"
	name = "Gene power module"
	desc = "A module that automatically inserts a gene into clones. It has a slot on the side that looks like it would hold a DNA injector."

	var/datum/bioEffect/BE = null

/obj/item/cloneModule/genepowermodule/attackby(obj/item/W, mob/user)
	if (!BE && istype(W, /obj/item/genetics_injector/dna_injector))
		var/obj/item/genetics_injector/dna_injector/injector = W
		boutput(user, "You put the DNA injector into the slot on the cartridge.")
		set_icon_state("genemodule_loaded")
		BE = injector.BE
		user.drop_item()
		qdel(W)
