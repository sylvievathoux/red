Red [
	Needs: 'View
	Config: [red-strict-check?: no]
]

system/view/auto-sync?: off

confine: func [
	offset [pair!] size [pair!] parent-offset [pair!] parent-size [pair!]
	][
	if (offset/x < parent-offset/x) [offset/x: parent-offset/x]
	if (offset/x > (parent-offset/x + parent-size/x - size/x)) [offset/x: parent-offset/x + parent-size/x - size/x - 1]
	if (offset/y < parent-offset/y) [offset/y: parent-offset/y]
	if (offset/y > (parent-offset/y + parent-size/y - size/y)) [offset/y: parent-offset/y + parent-size/y - size/y - 1]
	offset
]
limit: func [
	size [pair!] parent-size [pair!] ratio [float!] lim
	][
	sz: size
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

d-font: make font! [name: "calibri" size: 8 color: maroon anti-alias: yes]
f-font: make font! [name: "calibri" size: 10 color: maroon anti-alias: yes]
f-para: make para! [align: 'left v-align: 'middle]

img: load to-file request-file/filter ["jpgs" "*.jpg" "jpegs" "*.jpeg" "pngs" "*.png" "bitmaps" "*.bmp"]

sz: system/view/screens/1/size - 50x50 	string-sz: form sz
iz: img/size 							string-iz: form iz
img-area: iz/x * iz/y

margins: 10x10

scale: max 1 1 + max (2 * margins/x + iz/x) / sz/x  (2 * margins/y + iz/y) / sz/y
string-scale: rejoin ["1:" scale]
sr: round/to 1.0 * sz/x / sz/y 0.01
string-sr: form sr ; screen ratio
ir: round/to 1.0 * iz/x / iz/y 0.01
string-ir: form ir ; aspect ratio
string-zoom: ""

win-sz: 0x0
win-x: 0
win-y: 0

either ir > 1 [
	win-x: sz/x - 250 - (margins/x * 3) 
	win-y: win-x / ir
	if (ir < sr) and (win-y + (margins/y * 2 + 20) > sz/y) [win-y: sz/y - (margins/y * 2 + 20)  win-x: win-y * ir]
	][
	win-y: sz/y - 20 - (margins/y * 2)
	win-x: win-y * ir
	if (ir > sr) and (win-x + (margins/x * 3 + 250 ) > sz/x) [win-x: sz/x - (margins/x * 3 + 250) win-y: win-x / ir] 
]

win-sz: as-pair win-x win-y						
b-size: win-sz  								string-b: form b-size			
b-area: b-size/x * b-size/y
c-size: as-pair 250 b-size/y * 250 / b-size/x
c-area: c-size/x * c-size/y
d-size: as-pair 60 b-size/y * 60 / b-size/x  	string-d: form d-size

b-offset: 10x10
c-offset: as-pair b-size/x + 20 10
d-offset: c-offset + (c-size / 2) - (d-size / 2)
t-offset: as-pair c-offset/x c-size/y + 20

G: (d-offset - c-offset) * iz / c-size
H: d-size * iz / c-size

draw-b: compose [line-width 1 pen black box -1x-1 (b-size) image img 1x1 (b-size - 1x1) crop (G) (H)]
draw-c: compose [line-width 1 pen black box -1x-1 (c-size) image img 1x1 (c-size - 1x1)]
draw-d: compose [line-width 3 pen orange box -1x-1 (d-size)] 

string-elapse: ""
time: now/time/precise

b: c: d: none
t1: t2: t3: t4: t5: t6: t7: t8: t9: none

win: layout [
	title "Drag'n'zoom"
	origin margins
	space margins
	style textInfo: text white 80x17 font f-font para f-para

	across
	
	b: base b-size all-over draw draw-b 

	c: base c-size aqua draw draw-c

	at d-offset
	d: base d-size 255.255.255.230 loose draw draw-d 
		on-drag [
			face/offset: confine face/offset face/size c-offset c-size
			b/draw/13: (d/offset - c-offset) * iz / c-size
			b/draw/14: d/size * iz / c-size
			show win
		]
	
	at t-offset
	infoPanel: panel [
	origin 5x5
	space 5x-2
	across
	text "Datas" bold font-size 9 pad 0x5
	return 
	text "Displayed:" 100 t1: textInfo react [
		ofs: d/size t1/data: form to percent! round/to 1.0 * (ofs/x * ofs/y) / (c-size/x * c-size/y) 0.01
		] 
	return
	text "Zoom:" 100 t2: textInfo react [
		d-sz: d/size
		d-area: d-sz/x * d-sz/y
		t2/data: rejoin ["x" form round/to (1.0 * b-area / img-area * c-area / d-area) 0.01]
		]
	return
	text "Image size:" 100 t3: textInfo string-iz
	return
	text "Aspect ratio:" 100 t4: textInfo string-ir
	return
	text "Scale:" 100 t5: textInfo string-scale
	return
	text "Left box size:" 100 t6: textInfo string-b
	return
	text "Scren size:" 100 t7: textInfo string-sz
	return
	text "Rendered in:" 100 t8: textInfo string-elapse
	return pad 0x20
	text 200x50 {Scroll the mouse in any face ^/or drag the orange gel to ^/select an area to display} italic
	return across pad 0x20
	button "Reload" [] button "Quit" [quit]
	]
]

b/actors: c/actors: d/actors: object [
	clicked: false
	start: 0x0
	istart: 0x0
	iend: 0x0
	
	on-down: func [face [object!] event [event!]][probe clicked: not clicked start: event/offset]

	on-up: func [face [object!] event [event!]][
		clicked: not clicked
		istart: G
		iend: H
	]
	on-over: func [face [object!] event [event!]][
		if (face = b and clicked) [
			probe clicked
			probe b/draw/13: G: istart - event/offset + start
			;probe b/draw/14: H: iend - event/offset + start 
		]
		show win
	]
	on-wheel: func [face [object!] event [event!]] [
		ofst: d/offset
		zoom: multiply event/picked either ir > 1 [as-pair 10 to integer! (10 / ir)][as-pair to integer! (10 * ir) 10]
		d/size: limit d/size + (zoom * 2) c-size ir 50	
		either ((d/size/x = 50) and (zoom/x < 0)) [
			d/offset: ofst
			][
			d/offset: confine d/offset - zoom d/size c-offset c-size		
		]
		b/draw/13: G: (d/offset - c-offset) * iz / c-size
		b/draw/14: H: d/size * iz / c-size
		d/draw/7: d/size
		istart: G
		iend: H
		show win
	]
	on-drag: func [face [object!] event [event!]] [
		if face = d [
			face/offset: confine face/offset face/size c-offset c-size
			b/draw/13: G: (d/offset - c-offset) * iz / c-size
			b/draw/14: H: d/size * iz / c-size
			istart: G
			iend: H
		]
		show win
	]
]

win/size/x: b/size/x + c/size/x + (margins/x * 3)
center-it d c
G: (d/offset - c-offset) * iz / c-size
H: d-size * iz / c-size

view/flags/no-wait win 'resize

t8/data: third now/time/precise - time
show win

do-events
