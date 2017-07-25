Red [
	Title:   "Flip tests "
	Author:  "Francois Jouen"
	File: 	 %Imageclip.red
	Needs:	 'View
]

system/view/auto-sync?: off

confine: func [
{^(tab) Keeps gel in parent's face area while draggin'it}
	offset 			[pair!]		"Current gel's offset"
	size 			[pair!]		"Gel's size"
	parent-offset 	[pair!]		"Parent's face offset"
	parent-size 	[pair!]		"Parent's size"
	][
	if (offset/x < parent-offset/x) [offset/x: parent-offset/x + 1]
	if (offset/x > (parent-offset/x + parent-size/x - size/x)) [offset/x: parent-offset/x + parent-size/x - size/x - 1]
	if (offset/y < parent-offset/y) [offset/y: parent-offset/y]
	if (offset/y > (parent-offset/y + parent-size/y - size/y)) [offset/y: parent-offset/y + parent-size/y - size/y - 1]
	offset
]


; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
winBorder: 10x50
img1: rcvLoadImage %../../images/lena.jpg
dst:  rcvCreateImage img1/size
rLimit: 0x0
lLimit: 512x512
start: 0x0
end: start + 200
poffset: negate start
;drawBlk: compose [translate (poffset) clip (start) (end) image img1]

drawBlk: rcvClipImage poffset start end 
append drawBlk [img1] ; append to Draw block! the image instance
drawRect: compose [line-width 2 pen green fill-pen 255.255.255.240 box 0x0 200x200]

; ***************** Test Program ****************************
win: layout [
		title "Clip Tests"
		style rect: base 202x202 glass loose draw []
		origin margins space margins
		button 80 "Show Roi" [p1/draw: drawRect extrait/draw: drawBlk show win]
		button 80 "Hide Roi" [p1/draw: [] extrait/draw: [] show win]
		button 80 "Quit" 	 [rcvReleaseImage img1 dst Quit]
		return 
		canvas: base 512x512 dst
		
		extrait: base 200x200 white draw []
		return
		sb: field 512
		at winBorder
		p1: rect ;250.250.250.255
			on-drag [
				face/offset: confine face/offset face/size canvas/offset canvas/size
				start: p1/offset - winBorder
				end: start + 200
				poffset: negate start
				sb/text: form start		
				drawBlk/2: poffset 
				drawBlk/4: start
				drawBlk/5: end
				show win
			]
		
		do [rcvCopyImage img1 dst lLimit: canvas/offset rLimit: canvas/size + canvas/offset - p1/size ]
]
view/tight win