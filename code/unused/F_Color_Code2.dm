#define FTCS_Background "#999999"
#define FTCS_Button "#bbbbbb"
#define FTCS_Cancel "#FFFFFF"
#define FTCS_Cancel_Background "#FF0000"
#define FTCS_Layer 1000
#define FTCS_Help_Background "#0000dd"
#define FTCS_Help_Color "#FFFFFF"

f_color_selector_handler
	var
		current_clients[0]
		current_selectors[0]



	proc
		Get_Color(mob/M, default_color = null)
			if(ismob(M))
				if(!M.client)
					world.log << "<b>ERROR:</b> Call to f_color_selector_handler passed mob with no client."
					return
			var/client/C
			if(ismob(M))
				C = M.client
			else if(isclient(M))
				C = M
			else
				world.log << "<b>ERROR:</b> Call to f_color_selector_handler passed invalid value.  (Not a client or mob with client.)"
				return
			if(C in current_clients)
				return
			current_clients += C
			var/customization_second_color_selector/F = new(C, default_color, src)
			current_selectors += F
			var/color = F.Get_Color(C)
			del F
			current_clients -= C
			return color

customization_second_color_selector
	var
		f_color_selector_handler/owner
		list/pieces = new
		R = 0
		G = 0
		B = 0
		current_color
		background[0]
		obj/FTCS_Object/current_color/Current_Color
		obj/FTCS_Object/current_rgb_text/RGB_Text = new
		ok_buttons[0]
		waiting = TRUE
		list/backgroundPieces = new


	New(client/C, default_color, f_color_selector_handler/F)
		..()
		owner = F
		Setup(C)
		if(default_color)
			Current_Color.Update_Color(default_color)
			UpdateColorText(default_color, C)
	disposing()
		for(var/V in (ok_buttons + pieces + background + Current_Color + backgroundPieces + RGB_Text))
			del V
		..()
	proc
		UpdateColorText(color, client/C)
			var/r
			var/g
			var/b
			r = Hex2Num(copytext(color, 2,4))
			g = Hex2Num(copytext(color, 4,6))
			b = Hex2Num(copytext(color, 6))
			R = r
			G = g
			B = b
			RGB_Text.Update("RED", r)
			RGB_Text.Update("GREEN", g)
			RGB_Text.Update("BLUE", b)
			for(var/obj/FTCS_Object/color_slider/O in pieces)
				if(O.base_color == "RED" && r >= O.base_value && r <= O.base_value+63)
					O.SetMark(round((r-O.base_value)/2), C)
				if(O.base_color == "GREEN" && g >= O.base_value && g <= O.base_value+63)
					O.SetMark(round((g-O.base_value)/2), C)
				if(O.base_color == "BLUE" && b >= O.base_value && b <= O.base_value+63)
					O.SetMark(round((b-O.base_value)/2), C)



		Hex2Num(value)
			var/list/nums = list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F")
			return (16*(nums.Find(uppertext(copytext(value, 1,2)))-1)+nums.Find(uppertext(copytext(value,2)))-1)

		Cancel()
			current_color = null
			waiting = FALSE

		Setup(client/C)
			var/i
			var/xval = Get_X(C)
			var/yval = Get_Y(C)
			ShowBackground(xval, yval, C)
			Show_Text(xval,yval, C)
			Show_Buttons(xval,yval,C)
//			Set_Background(xval,yval,C)
			Current_Color = new(null,"[xval+1],[yval-2]", C)
			Current_Color.Update_Color(current_color)
			for(i=0, i<=3, i++)
				pieces += new /obj/FTCS_Object/color_slider/red(null,i,"[xval+i+1],[yval-1]", src)
				pieces += new /obj/FTCS_Object/color_slider/green(null,i,"[xval+i+1],[yval-1]", src)
				pieces += new /obj/FTCS_Object/color_slider/blue(null,i,"[xval+i+1],[yval-1]", src)

		Done()
			waiting = FALSE

		Set_Background(xval,yval,client/C)
			background += new /obj/FTCS_Object/background(null,"[xval+4],[yval-1]",C)

		Show_Buttons(xval,yval,client/C)
			ok_buttons += new /obj/FTCS_Object/ok_buttons(null,"[xval+4]:8,[yval-2]","O",C, src)
			background += new /obj/FTCS_Object/cancel_button(null, "[xval+3]:16,[yval-2]", C, src)
			background += new /obj/FTCS_Object/help_button(null, "[xval+2]:22,[yval-2]", C, src)

		ShowBackground(xval, yval, client/C)
			for(var/i in 1 to 6)
				for(var/j in 1 to 4)
					var/obj/O = new()
					O.layer = FTCS_Layer-1
					O.icon = 'icons/colselection/F_Select_Background.dmi'
					O.icon_state = "[i],[j]"
					O.screen_loc = "[xval+i-1],[yval+j-4]"
					backgroundPieces += O
			for(var/obj/P in backgroundPieces)
				C.screen += P

		Show_Text(xval,yval,client/C)
			var/i
			for(i=1, i<=6, i++)
				var/obj/O = new(null)
				O.text = "<font bgcolor=[FTCS_Background] color=#000055>[copytext("Select",i,i+1)]"
				O.screen_loc = "[xval-1+i],[yval+1]"
				O.layer = FTCS_Layer
				O.name = "Select Color"
				C.screen += O
				background += O
			for(i=1, i<=6, i++)
				var/obj/O = new(null)
				O.text = "<font bgcolor=[FTCS_Background] color=#000055>[copytext("Color ",i,i+1)]"
				O.screen_loc = "[xval-1+i],[yval]"
				O.layer = FTCS_Layer
				O.name = "Select Color"
				C.screen += O
				background += O
			RGB_Text.screen_loc = "[xval+1]:26,[yval-2]"
			C.screen += RGB_Text



		Update_Color(base_color, value)
			switch(base_color)
				if("RED")
					R = value
				if("GREEN")
					G = value
				if("BLUE")
					B = value
			current_color = rgb(R,G,B)
			Current_Color.Update_Color(current_color)
			RGB_Text.Update(base_color, value)

		Get_Color(client/C)
			for(var/V in pieces)
				C.screen += V
			while(waiting)
				sleep(10)
			return current_color

		Get_X(client/C)
			if(isnum(C.view))  //If view is already a number, set xval and yval
				if(C.view >=4)
					return C.view-3
				else
					return 1
			else													//If not, it is a text var.  Parse the xval and yval values
				var/divider = findtext(lowertext(C.view), "x")
				var/xval = text2num(copytext(C.view, 1, divider))
				if(xval >= 6)
					return round(xval/2 - 3)
				else
					return 0
		Get_Y(client/C)
			if(isnum(C.view))  //If view is already a number, set xval and yval
				if(C.view >=2)
					return C.view+3
				else
					return 5
			else													//If not, it is a text var.  Parse the xval and yval values
				var/divider = findtext(lowertext(C.view), "x")
				var/yval = text2num(copytext(C.view, divider+1))
				if(yval >= 6)
					return round(yval/2 + 3)
				else
					return 5




//				yval = text2num(copytext(C.view, divider+1))


obj/FTCS_Object
	color_slider
		icon = 'icons/colselection/sliders.dmi'
		layer = FTCS_Layer
		var
			obj/marker
			base_color
			base_value
			Yval
			Xval
			customization_second_color_selector/Owner
		New(loc,position, s_loc, customization_second_color_selector/F)
			..()
			icon_state = "[base_color]_[position+1]"
			Owner = F
			base_value = 2*position*32
			screen_loc = s_loc


		MouseUp(location, control, params)
			var/list/L = params2list(params)
			var/icon_x = text2num(L["icon-x"])
			// drsingh for Cannot execute null.Update Color()
			if (!isnull(Owner)) Owner.Update_Color(base_color, base_value+2*icon_x)
			SetMark(icon_x, usr.client)

		proc
			SetMark(icon_x, client/C)
				for(var/obj/FTCS_Object/color_slider/O in C.screen)
					if(O.base_color == src.base_color)
						O.overlays.Cut()
				var/icon/I = new('icons/colselection/selected_slider.dmi')
				I.Shift(EAST, min(icon_x,31))
				switch(base_color)
					if("GREEN")
						I.Shift(NORTH, 10)
					if("RED")
						I.Shift(NORTH, 20)
				var/obj/T = new()
				T.icon=I
				T.layer = FTCS_Layer+10
				overlays += I


		red
			base_color = "RED"
			name = "Red"
			New()
				..()
				text = "<font bgcolor=[rgb(base_value+32,0,0)]> "

		green
			base_color = "GREEN"
			name = "Green"
			New()
				..()
				text = "<font bgcolor=[rgb(0,base_value+32,0)]> "

		blue
			base_color = "BLUE"
			name = "Blue"
			New()
				..()
				text = "<font bgcolor=[rgb(0,0,base_value+32)]> "

obj/FTCS_Object
	layer = FTCS_Layer
	current_rgb_text
		icon = 'icons/colselection/numbers_ones.dmi'
		icon_state = "CODES_BACKGROUND"
		layer = 1118
		var
			icon/red_overlay
			icon/green_overlay
			icon/blue_overlay

		proc
			num2alpha(var/N as num)
				switch(N)
					if(1)
						return "ONE"
					if(2)
						return "TWO"
					if(3)
						return "THREE"
					if(4)
						return "FOUR"
					if(5)
						return "FIVE"
					if(6)
						return "SIX"
					if(7)
						return "SEVEN"
					if(8)
						return "EIGHT"
					if(9)
						return "NINE"
					if(0)
						return "ZERO"

			Update(color, value)
				switch(color)
					if("RED")
						overlays -= red_overlay
						red_overlay = Get_Number_Overlay(value)
						red_overlay.Shift(NORTH, 20)
						overlays += red_overlay
					if("GREEN")
						overlays -= green_overlay
						green_overlay = Get_Number_Overlay(value)
						green_overlay.Shift(NORTH, 10)
						overlays += green_overlay
					if("BLUE")
						overlays -= blue_overlay
						blue_overlay = Get_Number_Overlay(value)
						overlays += blue_overlay

			Get_Number_Overlay(value)
				var/icon/total_overlay = new /icon('icons/colselection/numbers_ones.dmi', "BLANK")
				if(value >= 100)
					var/icon/temp_icon = new('icons/colselection/numbers_ones.dmi', num2alpha((value-(value%100))/100))
					temp_icon.Shift(WEST, 12)
					total_overlay.Blend(temp_icon, ICON_OVERLAY)
				if(value >= 10)
					var/icon/temp_icon = new('icons/colselection/numbers_ones.dmi', num2alpha((value -(value-value%100) - value%10)/10))
					temp_icon.Shift(WEST, 6)
					total_overlay.Blend(temp_icon, ICON_OVERLAY)
				var/icon/I = new('icons/colselection/numbers_ones.dmi', num2alpha((value - (value-value%10))))
				total_overlay.Blend(I, ICON_OVERLAY)
				return total_overlay

	current_color
		name = "Current Color"
		layer = FTCS_Layer
		text = "<font bgcolor=#000001> "
		icon = 'icons/colselection/blank.dmi'
		New(loc,s_loc,client/C)
			..()
			screen_loc = s_loc
			C.screen += src
		proc
			Update_Color(value = "#000000")
				var/icon/I = new('icons/colselection/blank.dmi')
				if(value)
					I.Blend(value, ICON_ADD)
					icon = I

	ok_buttons
		layer = FTCS_Layer
		name = "OK"
		icon = 'icons/colselection/button.dmi'
		var
			customization_second_color_selector/Owner
		New(loc,s_loc,letter, client/C, customization_second_color_selector/F)
			..()
			Owner = F
			screen_loc = s_loc
			text = "<font bgcolor=[FTCS_Button] color=#000055>[letter]"
			C.screen += src
		Click()
			..()
			Owner.Done()

	cancel_button
		layer = FTCS_Layer
		name = "Cancel"
		icon = 'icons/colselection/cancel.dmi'
		var
			customization_second_color_selector/Owner
		New(loc,s_loc, client/C, customization_second_color_selector/F)
			..()
			Owner = F
			screen_loc = s_loc
			text = "<font bgcolor=[FTCS_Cancel_Background] color=[FTCS_Cancel]>X"
			C.screen += src
		Click()
			..()
			Owner.Cancel()

	background
		name = ""
		layer = FTCS_Layer-1
		New(loc,s_loc,client/C)
			..()
			text = "<font bgcolor=[FTCS_Background]> "
			screen_loc = s_loc
			C.screen += src

	help_button
		name = "Help"
		layer = FTCS_Layer
		icon = 'icons/colselection/help.dmi'
		invisibility = 100
		var
			customization_second_color_selector/Owner
		New(loc,s_loc, client/C, customization_second_color_selector/F)
			..()
			Owner = F
			text = "<font bgcolor=[FTCS_Help_Background] color=[FTCS_Help_Color]>?"
			screen_loc = s_loc
			C.screen += src
		Click()
			..()
			var/rendered = {"
<b>Basic Help</b>
To select a color, simply click on the red, green and blue selection
bars until you get the color you want.  Once you have the color you
want, click the 'OK' button.  Click the red slashed circle button to cancel.
			"}
			boutput(usr, rendered)




