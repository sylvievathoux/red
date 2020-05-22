Red [
	Needs: 'View
	Purpose: "Face's auto-sizing and confining functions"
	;Config: [red-strict-check?: no]
]

system/view/auto-sync?: off

confine: func [
{^(tab)  Keeps gel in parent's face area while draggin'it}
	offset 			[pair!]		"Current gel's offset"
	size 			[pair!]		"Gel's size"
	parent-offset 	[pair!]		"Parent's face offset"
	parent-size 	[pair!]		"Parent's size"
	][
	if (offset/x < parent-offset/x) [offset/x: parent-offset/x + 1]
	if (offset/x > (parent-offset/x + parent-size/x - size/x)) [offset/x: parent-offset/x + parent-size/x - size/x]
	if (offset/y < parent-offset/y) [offset/y: parent-offset/y + 1]
	if (offset/y > (parent-offset/y + parent-size/y - size/y)) [offset/y: parent-offset/y + parent-size/y - size/y]
	offset
]

limit: func [
{
^(tab) Keeps gel's size within two sizes:
^(tab) the parent's face as the largest,
^(tab) lim's as the smallest.
}
	size [pair!] parent-size [pair!] lim
	][
	ratio: 1.0 * parent-size/x / parent-size/y
	if size/x > parent-size/x [size/x: parent-size/x]
	if size/y > parent-size/y [size/y: parent-size/y]
	if (size/x < lim) [size/x: lim size/y: to integer! (lim / ratio)]
	size 
]

center-it: func [
	inside-f [object!] outside-f [object!]
	][
	return outside-f/offset + (outside-f/size / 2) - (inside-f/size / 2)
]

compute-sizes: function [
{
^(tab) Draw the largest window that fits the OS screen.
^(tab) Consists in the largest possible image face and
^(tab) a smaller one including a gel to navigate through
^(tab) the large one. 
}
	img [image!]			"LOADed image file"
	margins [pair!]			"Regular margins between faces"
	box-width [integer!]		"Width of the gel's container (size of gel's parent-face). Set it as you need!"
	extra-pad [pair!]		"If needed, extra margins for fine tuning"
	][
	if not image? img [print "File error - Not an image!"]
	svsz: 	system/view/screens/1/size - extra-pad  			; OS screen-size
	svr:	round/to 1.0 * svsz/x / svsz/y 0.01					; OS screen aspect ratio
	iz: 	img/size											; image-sz
	ir:  	round/to 1.0 * iz/x / iz/y 0.01						; image aspect ratio
	scale: 	max 1												; image scale (
				1 + max (2 * margins/x + iz/x) / svsz/x 		; Thanks to DideC!)
						(2 * margins/y + iz/y) / svsz/y				
	either ir > 1 [
		win-x: svsz/x - box-width - (margins/x * 3) - extra-pad/x		; win-x: window/size/x
		win-y: win-x / ir
		if (ir < svr) and (win-y + (margins/y * 2 + extra-pad/y) > svsz/y) [win-y: svsz/y - (margins/y * 2 + extra-pad/y)  win-x: win-y * ir]
	][
		win-y: svsz/y - extra-pad/y - (margins/y * 2)					; win-y: window/size/y
		win-x: win-y * ir
		if (ir > svr) and (win-x + (margins/x * 3 + box-width ) > svsz/x) [win-x: svsz/x - (margins/x * 3 + box-width) win-y: win-x / ir] 
	]
	return reduce [win-x win-y svsz svr iz ir scale]
]
