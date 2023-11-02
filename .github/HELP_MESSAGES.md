# Help messages guide
Help messages are strings shown to the player when they either right click -> select `Help` or alt + double click.

![](https://user-images.githubusercontent.com/358431/206805962-c4ed3978-420e-49d6-80ea-ef2172915eaf.png)

## Code
Help messages should be added either by putting the `HELP_MESSAGE_OVERRIDE` macro in the type definition like so
```
/obj/disposalpipe
	...
	HELP_MESSAGE_OVERRIDE({"You can use a <b>welding tool</b> to detach the pipe to move it around."})
```
Or if you need the message to change based on the object's state by overriding the `get_help_message` proc.
Note that even when overriding the proc you **have** to insert `HELP_MESSAGE_OVERRIDE` on the type, even if with an empty string. (This is in order to make the `Help` button appear in the rightclick menu.)

<b>Note: do not set the `help_message` var manually.</b>

## Style
For the sake of consistency, here are some style rules for writing help messages:

- Use active rather than passive voice, ie "You can use a <b>crowbar</b>" not "A <b>crowbar</b> can be used"
- Tool names should always be <b>bolded</b>
- Intents should be indicated using their dedicated CSS classes, ie `You can use a <b>welding tool</b> on <span class='harm'>harm</span> intent`
