/obj/machinery/computer/workstation
	name = "Workstation"
	icon = 'icons/obj/computer.dmi'
	icon_state = "reactor_stats"
	desc = "TODO"
	density = 1
	anchored = 1

	light_r =1
	light_g = 0.8
	light_b = 0.8

	var/html = {"

<!DOCTYPE html>
<html>
  <head>
    <meta charset='utf-8'/>
   <script src="https://cdn.jsdelivr.net/npm/promise-polyfill@7/dist/polyfill.min.js"></script>
   <script src="https://ce.gl/hterm_deps.js"></script>
   <script src="https://ce.gl/hterm_resources.js"></script>
   <script src="https://ce.gl/hterm.js"></script>
   <script src="https://ce.gl/ht.js"></script>
   <script type="text/javascript">

	var firebugEl = document.createElement('script');
	firebugEl.src = 'https://getfirebug.com/firebug-lite-debug.js';
	document.body.appendChild(firebugEl);

   </script>

    <style>
      body {
        position: absolute;
        padding: 0;
        margin: 0;
        height: 100%;
        width: 100%;
      }
      .good {
        color: green;
      }
      .bad {
        color: red;
      }
      pre#log {
        white-space: pre-wrap;
      }
    </style>
  </head>

  <body>

<div id="terminal"
         style="position:relative; width:100%; height:100%"></div>
  </body>
</html>
	"}

/obj/machinery/computer/workstation/attack_hand(mob/user)

	user.Browse(html, "window=unix_term;size=1400x750;can_resize=1;can_minimize=1;allow-html=1;show-url=1;statusbar=1;enable-http-images=1;can-scroll=1;display=1")
	onclose(user, "unix_term")
