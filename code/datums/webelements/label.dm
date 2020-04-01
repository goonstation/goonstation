/datum/tag/label
	New(var/type as text)
		..("label")
	
	proc/setText(var/txt as text)
		var/datum/tag/span/txtSpan = new
		txtSpan.setText(txt)
		addChildElement(txtSpan)
