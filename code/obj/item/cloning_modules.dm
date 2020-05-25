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
	spawn_contents = list(/obj/item/cloneModule/mindslave_module,
	/obj/item/electronics/soldering,
	/obj/item/electronics/frame/cloning/computer,
	/obj/item/electronics/frame/cloning/pod,
	/obj/item/electronics/frame/cloning/grinder,
	/obj/item/electronics/frame/cloning/scanner)

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

// Frames for mindslave module kit
/obj/item/electronics/frame/cloning
	viewstat = 2
	secured = 2
	icon_state = "dbox"

/obj/item/electronics/frame/cloning/computer
	name = "boxed cloning computer"
	store_type = /obj/machinery/computer/cloning

/obj/item/electronics/frame/cloning/pod
	name = "disassembled cloning pod"
	store_type = /obj/machinery/clonepod

/obj/item/electronics/frame/cloning/grinder
	name = "compacted giant blender"
	store_type = /obj/machinery/clonegrinder

/obj/item/electronics/frame/cloning/scanner
	name = "expandable DNA scanner"
	store_type = /obj/machinery/clone_scanner
