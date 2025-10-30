/datum/client_auth_gate/proc/check(client/C)
	return TRUE

/datum/client_auth_gate/proc/fail(client/C)
	logTheThing(LOG_DEBUG, C, "failed to pass gate check: [src]")
	src.show_fail_message(C)

	if (C.mob) C.on_auth_failed()
	else C.mob = new /mob/unauthed(C)

/datum/client_auth_gate/proc/get_failure_message(client/C)
	return ""

/datum/client_auth_gate/proc/show_fail_message(client/C)
	var/failure_message = src.get_failure_message(C)
	if (!failure_message)
		failure_message = "Failed to authenticate with the server. Please try again later."

	C << browse({"
		<!doctype html>
		<html>
			<head>
				<meta name="color-scheme" content="[C.darkmode ? "dark" : "light"]" />
				<title>Login Failed</title>
				<style>
					* {
						box-sizing: border-box;
					}

					html, body { height: 100%; }

					html {
						font-size: 16px;
						font-family: Arial, Helvetica, sans-serif;
						line-height: 1.5;
						[C.darkmode ? "background: #0f0f0f; color: white;" : "background: #fff; color: black;"]
					}

					body {
						display: flex;
						flex-direction: column;
						align-items: center;
						justify-content: center;
						margin: 0;
						padding: 0;
						text-align: center;
					}

					.content-wrapper {
						margin: 1rem;
						min-width: 25rem;
						min-height: 0;
					}

					.button {
						display: block;
						margin-bottom: 0.5rem;
						padding: 0.75rem 1rem;
						background: #ffd125;
						color: black;
						text-decoration: none;
						font-size: 0.85rem;
						font-weight: 600;
						text-transform: uppercase;
						text-decoration: none;
						text-align: center;
						cursor: pointer;
						border-radius: 3px;
					}

					.button:hover {
						background-color: #b48e05;
						color: black;
					}
				</style>
			</head>
			<body><div class="content-wrapper">[failure_message]</div></body>
		</html>
	"}, "window=mainwindow.authfailed")
	winshow(C, "mainwindow.authfailed", TRUE)
