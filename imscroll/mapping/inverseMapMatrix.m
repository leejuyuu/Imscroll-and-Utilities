function invmapmat = inverseMapMatrix(fitparmvector)
za=fitparmvector(1,1);zb=fitparmvector(1,2);zc=fitparmvector(1,3);
zd=fitparmvector(2,1);ze=fitparmvector(2,2);zf=fitparmvector(2,3);
denom=1/(za*ze-zb*zd);
invmapmat=denom*[ze, -zb, (zb*zf-zc*ze);
                 -zd, za, (zd*zc-zf*za)]; % b9p148 inverse matrix

end