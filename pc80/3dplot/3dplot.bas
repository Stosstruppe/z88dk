100 '
110 defint a-z:color 0,0,1:width 80,25
120 dim yt(159),yb(159):tr!=3.14159265/180
 130 for i=0 to 159:yt(i)=100:yb(i)=-1:next
140 for y=-180 to 180 step 8
150  for x=-180 to 180 step 8
160   r!=sqr(x*x+y*y)*tr!
170   z!=cos(r!)*100-cos(3*r!)*30
180   sx=int(80.5+x/4-y/8)
190   sy=int(42.5-(y/8+z!/4))
200   d=0
210   if yt(sx)>sy then yt(sx)=sy:d=1
220   if yb(sx)<sy then yb(sx)=sy:d=1
230   if d then pset(sx,sy)
240 next x,y
