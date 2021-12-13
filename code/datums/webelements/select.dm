/datum/tag/select
	INIT()
		..("select")

	proc/setName(var/name as text)
		setAttribute("name", name)

	proc/addOption(var/value as text, var/txt as text, var/selected = 0)
		var/datum/tag/option/opt = new
		opt.setValue(value)
		opt.setText(txt)
		if(selected)
			opt.setAttribute("selected", "selected")
		addChildElement(opt)
