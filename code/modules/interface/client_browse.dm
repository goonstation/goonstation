/client/proc/Browse(html, opts, forceChui)
	var/body = html

	if (!body)
		return

	body = {"<!doctype html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	[src.byond_version >= 516 ? "<link rel='stylesheet' type='text/css' href='[resource("vendor/css/font-awesome.css")]'>" : ""]
	<style type='text/css'>
		body {
			font-family: Tahoma, Arial, sans-serif;
			font-size: [(src.preferences && src.preferences.font_size) ? "[src.preferences.font_size]%" : "10pt"];
			}
		pre, tt, code {
			font-family: Consolas, 'Lucidia Console', monospace;
			}
	</style>
	<script>
		// Keeps the scroll position of a window when it reloads / updates.
		// Not really ideal in cases where the window changes contents, but better than nothing.
		function updateScroll() {window.name = document.documentElement.scrollTop || document.body.scrollTop;}
		window.addEventListener("beforeunload", updateScroll);
		window.addEventListener("scroll", updateScroll);
		window.addEventListener("load", function() {document.documentElement.scrollTop = document.body.scrollTop = window.name;});
		// Prevent some default window shortcuts that annoy people
		window.addEventListener("keydown", function(event){
			if (event.ctrlKey && "oln".indexOf(event.key) > -1) {
				event.preventDefault()
			}
		})
	</script>
</head>
<body>
"} + body
	src << browse(body,"titlebar=1;can_close=1;can_resize=1;can_scroll=1;border=0;[opts]")

	var/list/params_list = params2list(opts)
	if (params_list["window"])
		winset(src, params_list["window"], "is-minimized=false")

/mob/proc/Browse(html, opts, forceChui)
	src.client?.Browse( html, opts)
