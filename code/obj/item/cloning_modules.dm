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

/obj/item/cloneModule/mindslave_module
	icon = 'icons/obj/cloning.dmi'
	icon_state = "slavemodule"
	name = "Mindslave cloning module"
	desc = "A powerful device that remaps people's brains when they get cloned to make them completely loyal to the owner of this module"


/obj/item/storage/box/mindslave_module_kit
	name = "Mindslave module kit"
	icon_state = "box"
	desc = "A box with a mindslave cloning module and a cloning lab. Yes, a whole cloning lab. In a box. Somehow."

	make_my_stuff()
		..()
		new /obj/item/cloneModule/mindslave_module(src)
		new /obj/item/electronics/soldering(src)


		// Creates premade mechanics scanned items. That way you can make a cloning lab faster.

		var/obj/item/electronics/frame/F1 = new/obj/item/electronics/frame(src)
		F1.name = "Boxed Cloning Computer"
		F1.store_type = /obj/machinery/computer/cloning
		F1.viewstat = 2
		F1.secured = 2
		F1.icon_state = "dbox"

		var/obj/item/electronics/frame/F2 = new/obj/item/electronics/frame(src)
		F2.name = "Disassembled Cloning Pod"
		F2.store_type = /obj/machinery/clonepod
		F2.viewstat = 2
		F2.secured = 2
		F2.icon_state = "dbox"

		var/obj/item/electronics/frame/F3 = new/obj/item/electronics/frame(src)
		F3.name = "Compacted Giant Blender"
		F3.store_type = /obj/machinery/clonegrinder
		F3.viewstat = 2
		F3.secured = 2
		F3.icon_state = "dbox"

		var/obj/item/electronics/frame/F4 = new/obj/item/electronics/frame(src)
		F4.name = "Expandable DNA Scanner"
		F4.store_type = /obj/machinery/clone_scanner
		F4.viewstat = 2
		F4.secured = 2
		F4.icon_state = "dbox"

/obj/item/cloneModule/genepowermodule
	icon = 'icons/obj/module.dmi'
	icon_state = "genemodule"
	name = "Gene power module"
	desc = "A module that automatically inserts a gene into clones. It has a slot in the back that looks like it would hold a DNA injector."

	var/datum/bioEffect/BE = null

/obj/item/cloneModule/genepowermodule/attackby(obj/item/W as obj, mob/user as mob)
	if (!BE && istype(W, /obj/item/genetics_injector/dna_injector))
		var/obj/item/genetics_injector/dna_injector/injector = W
		boutput(user, "You put the DNA injector into the slot on the cartridge.")
		BE = injector.BE
		user.drop_item()
		qdel(W)
