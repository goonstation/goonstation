function input(cli, type, msg, title, default)
	return BYOND.CallProc("input", cli, type, msg, title or '', default or '')
end
function alert(cli, msg, title, btn1, btn2, btn3)
	return BYOND.CallProc( "alert", cli, msg, title or '', btn1 or 'Ok', btn2, btn3 )
end
function world(str)
	BYOND.CallProc("WorldPrint", tostring(str))
end
function locate(str, y, z)
	if z then
		return BYOND.CallProc("locate", str, y, z)
	end
	return BYOND.CallProc("locate", tostring(str))
end
function sleep(seconds)
	BYOND.CallProc("spawn", seconds)
end
function BYOND.GetClients()
	return BYOND.CallProc("clients")
end