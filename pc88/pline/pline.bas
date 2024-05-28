10 clear ,&hafff:defint a-z:def fnr(x)=int(rnd*x)
20 pline=&hb000:cls 2
30 for i=1 to 100
40  x0=fnr(640):y0=fnr(200):x1=fnr(640):y1=fnr(200):p=fnr(3)
50  call pline(x0,y0,x1,y1,p)
60 next
