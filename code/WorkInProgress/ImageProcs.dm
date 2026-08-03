
/image/proc/apply_material_appearance(var/datum/material/material)
	if(material.getTexture())
		var/icon/icon_tex = GetTexturedIcon(src.icon, material.getTexture())
		if(!isnull(icon_tex))
			var/icon/icon_blend = icon(src.icon)
			icon_blend.Blend(icon_tex, ICON_OVERLAY)
			src.icon = icon_blend
	src.color = material.getColor()
	src.alpha = material.getAlpha()
	if(material.hsl_color)
		src.filters += filter(type="color", color=material.hsl_color, space = FILTER_COLOR_HSL)
	material.triggerOnImage(src)
