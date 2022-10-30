#define CHUI_THEME_CHROMELESS 1
#define CHUI_THEME_SCROLLBARS 2

client/var/list/receivedThemes = list()

chui/theme
	//Unique name for the theme. Windows reference their desired based on this name. (and defaults to the base if it doesn't exist)
	var/name  = "example"

	//A list of 'file's to send to clients. Make sure they're singlequoted files.
	//If CHUI_VERBOSITY is at least 1, files in here will automatically be reloaded into the cache
	//at runtime for utility of testing new themes.
	//var/list/send = list()

	//Stream the theme's resources to the client; it will bail if they have already received it.
	/*
	proc/streamToClient( var/client/c )
		if( !c.receivedThemes[ name ] )
			c.receivedThemes[ name ] = 1
			chui.RscStream( c, send )
	*/

	//Generates a header based on a set of parameters
	proc/generateHeader(var/list/params)
		var/list/generated = list({"<!DOCTYPE html>
			<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
				<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">"})
		generated += "<script>document.addEventListener('keydown', function(ev){ if(ev.key === 'w' && ev.ctrlKey){ document.location = 'byond://winset?command=.chui-close [params["data"]["ref"]]'; } });</script>"
		if( params["js"] )
			//Common to all themes
			generated += "<script src='[resource("js/jquery.min.js")]'></script>"
			generated += "<script src='[resource("js/jquery.nanoscroller.min.js")]'></script>"
			generated += "<script src='[resource("js/chui/chui.js")]'></script>"
			generated += "<script src='[resource("js/errorHandler.js")]'></script>"
			generated += "<script src='[resource("js/jquery.debounce-1.0.5.js")]'></script>"
			generated += "\n"

			//Theme specific
			for( var/key in params["js"] )
				generated += "<script src='[resource(key)]'></script>"

		if( params["css"] )
			generated += "<link rel='stylesheet' type='text/css' href='[resource("css/font-awesome.css")]'>"

			for( var/key in params["css"] )
				generated += "<link rel='stylesheet' type='text/css' href='[resource(key)]'>"

		if( params["title"] )
			generated += "<title>[html_encode(params["title"])]</title>"

		if( params["data"] )
			var/data = params["data"]
			for( var/key in data )
				generated += "<meta name=\"[key]\" value=\"[html_encode(data[key])]\">"

		return "[generated.Join("")]</head><body>"

	//Generates a body based on parameters and desired body content.
	proc/generateBody(var/body, var/list/params)
		return body

	//Generates a footer based on parameters.
	proc/generateFooter(var/list/params)
		return "</body></html>"

	//Renders a button. The elements ID must be set to id in order for the javascript portion of Chui to function properly.
	proc/generateButton( var/id, var/display )
		return "<button id='[id]'>[display]</button>"

chui/theme/base
	name = "base"
	//send = list('chui/themes/default/default.css', 'chui/chui.js', 'chui/themes/default/images/bl.gif', 'chui/themes/default/images/borderSlants.png', 'chui/themes/default/images/br.gif', 'chui/themes/default/images/scanLine.png', 'chui/themes/default/images/tl.gif', 'chui/themes/default/images/topShadow.png', 'chui/themes/default/images/tr.gif', 'chui/themes/default/images/buttons/btn-contrast-active-br.gif','chui/themes/default/images/buttons/btn-contrast-active-tl.gif','chui/themes/default/images/buttons/btn-contrast-br.gif','chui/themes/default/images/buttons/btn-contrast-hover-br.gif','chui/themes/default/images/buttons/btn-contrast-tl.gif','chui/themes/default/images/buttons/btn-standard-active-br.gif','chui/themes/default/images/buttons/btn-standard-active-tl.gif','chui/themes/default/images/buttons/btn-standard-br.gif','chui/themes/default/images/buttons/btn-standard-hover-br.gif','chui/themes/default/images/buttons/btn-standard-tl.gif')

	generateHeader(var/list/params)
		params["css"] += list("css/chui/themes/default/default.css")

		return ..(params) //todo, remember if this matters

	generateBody( var/body, var/list/params )
		var/flags = params["data"]["flags"]
		var/rendered = {"
				<div id='titlebar'>
					<div class='corner tl'></div>
					<div class='corner tr'></div>
					<h1 id="windowtitle">[params["title"] ? params["title"] : ""]</h1>
					<a href='byond://winset?[params["data"]["ref"]].is-minimized=true' class='min'><i class='icon-minus'></i></a>
				"}
		if(flags & CHUI_FLAG_CLOSABLE)
			rendered += {"
					<a href='byond://winset?command=.chui-close [params["data"]["ref"]]' class='close'><i class='icon-remove'></i></a>
			"}
		rendered += {"
				</div>
			"}

		if (flags & CHUI_FLAG_SIZABLE)
			rendered += {"
				<div class='resizeArea top'    rx='0' ry='-1'></div>
				<div class='resizeArea tr'     rx='1' ry='-1'></div>
				<div class='resizeArea right'  rx='1' ry='0'></div>
				<div class='resizeArea br'     rx='1' ry='1'></div>
				<div class='resizeArea bottom' rx='0' ry='1'></div>
				<div class='resizeArea bl'     rx='-1' ry='1'></div>
				<div class='resizeArea left'   rx='-1' ry='0'></div>
				<div class='resizeArea tl'     rx='-1' ry='-1'></div>"}
		rendered += {"<div id="cornerWrap">
					<div class='borderSlants'></div>
					<div class='corner bl'></div>
					<div class='corner br'></div>
					<div id='content' class='nano'>
						<div class='nano-content innerContent'>
							[body]
						</div>
					</div>
				</div>"}
		return rendered

	generateFooter()
		return ..()

	generateButton( var/id, var/label )
		return {"<a class="button medium" id="[id]"><span class="top"></span>[label]<span class="bottom"></span></a>"}

	proc/generateSwitch( var/id, var/list/options )
		return "IDK"//have the switch, when an option is selected, chui.onSwitchSelected( id, optionName )
		//the key of the list is the name, the value is the label. these labels cannot be changed at runtime so don't worry about that
