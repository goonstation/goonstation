/datum/vis_storage_controller
	var/obj/parent = null
	///The items this storage controller contains
	var/list/obj/vis_items
	New(obj/new_parent)
		vis_items = list()
		parent = new_parent
		..()
	proc/add_item(obj/O)
		vis_items += O
		O.AddComponent(/datum/component/storage_viscontents, container = src)

	proc/hide()
		for (var/obj/O as anything in vis_items)
			parent.vis_contents -= O

	proc/show()
		for (var/obj/O as anything in vis_items)
			parent.vis_contents += O

	proc/remove(obj/O)
		parent.vis_contents -= O
		vis_items -= O
