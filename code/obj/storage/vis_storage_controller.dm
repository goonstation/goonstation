/datum/vis_storage_controller
	var/obj/parent = null
	///The items this storage controller contains
	var/list/obj/vis_items = list()

	proc/initialize(new_parent)
		parent = new_parent
	proc/add_item(var/obj/O)
		vis_items += O
		O.AddComponent(/datum/component/storage_viscontents, container = src)

	proc/hide()
		for (var/obj/O in vis_items)
			parent.vis_contents -= O

	proc/show()
		for (var/obj/O in vis_items)
			parent.vis_contents += O

	proc/remove(var/obj/O)
		parent.vis_contents -= O
		vis_items -= O
