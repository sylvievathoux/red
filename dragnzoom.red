Red [
	Needs: 'View
	;Config: [red-strict-check?: no]
]

#include %display-tools.red

system/view/auto-sync?: off
system/view/VID/GUI-rules/active?: no


d-font: make font! [name: "calibri" size: 7 color: maroon anti-alias: yes]
f-font: make font! [name: "calibri" size: 8 color: maroon anti-alias: yes]
f-para: make para! [align: 'left v-align: 'middle]

img: load to-file request-file/filter ["jpgs" "*.jpg" "jpegs" "*.jpeg" "pngs" "*.png" "bitmaps" "*.bmp"]

margins: 10x10
extra-pad: 20x35
box-width: 250


set/any [win-x win-y svsz svr iz ir scale] compute-sizes img margins box-width extra-pad

img-area: iz/x * iz/y
win-sz: as-pair win-x win-y						

b-size: win-sz  											
b-area: b-size/x * b-size/y
c-size: as-pair box-width b-size/y * box-width / b-size/x
c-area: c-size/x * c-size/y
d-size: as-pair 60 b-size/y * 60 / b-size/x  	
b-offset: 10x10
c-offset: as-pair margins/x * 2 + b-size/x margins/y
d-offset: c-offset + (c-size / 2) - (d-size / 2)
t-offset: as-pair c-offset/x c-size/y + margins/y + 10
button-size: as-pair box-width / 4 - 5 25

G: d-offset - c-offset * iz / c-size
H: d-size * iz / c-size

draw-b: compose [line-width 1 pen black box -1x-1 (b-size) image img 1x1 (b-size - 1x1) crop (G) (H)]
draw-c: compose [line-width 1 pen black box -1x-1 (c-size) image img 1x1 (c-size - 1x1)]
draw-d: compose [line-width 4 pen orange box -1x-1 (d-size)] 
draw-infoPanel: compose [pen gray line-width 1 box 1x1 (as-pair box-width - 1 129)]

string-sz: form svsz
string-iz: form iz
string-b: form b-size
string-d: form d-size
string-scale: rejoin ["1:" scale]
string-sr: form svr ; screen ratio
string-ir: form ir ; aspect ratio
string-zoom: ""
string-elapse: ""

start-time: now/time/precise
a: b: c: d: none

win: layout [
	title "Drag'n'zoom"
	origin margins
	space margins
	style textInfo: text 230.230.230 80x16 font f-font para f-para ;font-size 8
	style button: button button-size font d-font ;font-size 7
	style text: text 80 font-size 8
	across
	
	b: base b-size all-over draw draw-b ;extra "b"

	c: base c-size aqua draw draw-c ;extra "c"

	at d-offset
	d: base d-size 255.255.255.230 loose draw draw-d ;extra "d"
	
	at t-offset
	infoPanel: panel [
		size 250x600
		origin 15x15
		space 5x-5
		across
		;text "Datas" bold font-size 9 pad 0x5
		;return 
		text "Display rate:" t1: textInfo react [
			ofs: d/size
			t1/extra: round/to 1.0 * (ofs/x * ofs/y) / (c-size/x * c-size/y) 0.001
			t1/data: form to percent! t1/extra
			] 
		return
		text "Zoom:" t2: textInfo react [
			d-sz: d/size
			d-area: d-sz/x * d-sz/y
			t2/data: rejoin ["x" form round/to (1.0 * b-area / img-area * c-area / d-area) 0.01]
			]
		return
		text "Image size:" t3: textInfo string-iz
		return
		text "Aspect ratio:" t4: textInfo string-ir
		return
		text "Scale:"  t5: textInfo string-scale
		return
		text "Left box size:" t6: textInfo string-b
		return
		text "Screen size:" t7: textInfo string-sz
		return
		text "Rendered in:" t8: textInfo string-elapse
		return across pad -15x30 space 1x0
		button "Reload" font-color black font-size 7 []
		button "Transform" font-color black font-size 7 [probe length? infoPanel/pane]
		button "Ceph" font-color black font-size 7 []
		button font-color crimson font-size 7 "Quit" [quit]
		return pad -15x10
		text 250x150 {Scroll the mouse in both faces, drag either the image or the orange gel to select an area to display}
	]
	;return
	;button 80x25 "Quit" [quit]
]
	

b/actors: c/actors: d/actors: object [
	
	clicked: false
	start: 0x0
	;start2: 0x0
	iOffset: b/draw/13
	iSize: b/draw/14
	AA: iOffset
	BB: iSize
	;coef: 0.0
	;delta: 0x0
	
	on-down: func [face [object!] event [event!]][
		if same? face b [
			clicked: true ;not clicked
			start2: start: event/offset
			iOffset: AA
			iSize: BB
			;probe coef: round/to 1.0 * BB/x / iz/x 0.001 ;t1/extra
			
		]
	]
	on-over: func [face [object!] event [event!] /local temp delta it][
		delta: 0x0
		temp: 0x0
		it: 0
		if (same? face b) and clicked [
			b/draw/13: AA: iOffset - event/offset + start
			if AA/x < 0 [b/draw/13/x: 0]
			if AA/y < 0 [b/draw/13/y: 0]
			if AA/x + BB/x > iz/x [b/draw/13/x: iz/x - BB/x] 
			if AA/y + BB/y > iz/y [b/draw/13/y: iz/y - BB/y]
			AA: b/draw/13
			d/offset: AA * c-size / iz + c-offset
			show [b d]
		]
	]
	on-up: func [face [object!] event [event!]][
		if same? face b [
			clicked: false ;not clicked 
			iOffset: b/draw/13
			;show d
		]
	]
	on-wheel: func [face [object!] event [event!] /local ofst zoom] [
		ofst: d/offset
		zoom: multiply event/picked either ir > 1 [as-pair 10 to integer! (10 / ir)][as-pair to integer! (10 * ir) 10]
		d/size: limit d/size + (zoom * 2) c-size 10	
		either ((d/size/x = 10) and (zoom/x < 0)) [
			d/offset: ofst
			][
			d/offset: confine d/offset - zoom + 1x0 d/size c-offset - 1x0 c-size ;+ 1x0 		
		]
		b/draw/13: AA: (d/offset - c-offset) * iz / c-size
		b/draw/14: BB: d/size * iz / c-size
		d/draw/7: d/size
		show win
	]
	on-drag: func [face [object!] event [event!]] [
		face/offset: confine face/offset face/size c-offset c-size
		b/draw/13: AA: (d/offset - c-offset) * iz / c-size
		show [b d] ;win
	]
]

win/size/x: b/size/x + c/size/x + (margins/x * 3)
center-it d c ;win/pane/2 win/pane/3
G: (d/offset - c-offset) * iz / c-size
H: d-size * iz / c-size
;draw-infoPanel/7: as-pair box-width - 1 164 ;infoPanel/size/y - 110
;infoPanel/size
append infoPanel/pane reduce make face! [size: 250x130 color: 255.255.0.245 type: 'base draw: draw-infoPanel]

view/flags/no-wait win [resize]
t8/data: third now/time/precise - start-time
show win
do-events
