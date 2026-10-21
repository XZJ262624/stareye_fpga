"""Frozen 128-case definitions interpreted as raw gray, before any prediction."""
import math
W,H=544,416
def image(c):
    result=bytearray();k=c['kind'];w=c['w'];h=c['h'];j=c.get('variant',0);size=c.get('foreign_size',0)
    ang=math.radians(c['angle']);co=math.cos(ang);si=math.sin(ang)
    for y in range(H):
        for x in range(W):
            xx=x-16;yy=y-16;u=(xx-c['cx'])*co+(yy-c['cy'])*si;v=-(xx-c['cx'])*si+(yy-c['cy'])*co
            ellipse=(u/(w/2))**2+(v/(h/2))**2<=1;rect=abs(u)<w/2 and abs(v)<h/2
            if k=='circle':inside=ellipse
            elif k=='rect':inside=rect
            elif k in ['top_foreign','bottom_foreign','symmetric_foreign']:
                dy=(-1 if k!='bottom_foreign' else 1)*(h/2-size/2-2)
                foreign=abs(v-dy)<size/2 and (abs(u+w*.32)<size/2 or k=='symmetric_foreign' and abs(u-w*.32)<size/2)
                inside=ellipse or foreign
            elif k=='cap_bar':inside=ellipse or abs(u)<w*.35 and abs(v-(-h/2+4))<(2+j%4)/2
            elif k=='middle_segments':inside=ellipse and not (abs(v)<h*.3 and (abs(u-w*.15)<2 or abs(u+w*.15)<2))
            elif k=='ring_double':inside=(ellipse and (u/(w*.32))**2+(v/(h*.32))**2>=1) if j%2==0 else (u+w*.3)**2+v*v<(w*.22)**2 or (u-w*.3)**2+v*v<(w*.22)**2
            elif k=='ellipse_truncated':inside=(u/(w/2))**2+(v/(h*.36))**2<=1 if j%2==0 else ((xx-8)/(w/2))**2+(v/(h/2))**2<=1
            elif k=='text_shadow':inside=rect and ((abs(u+w*.3)<w*.07 or abs(u-w*.3)<w*.07 or abs(v)<h*.07) if j%2==0 else u<(v+h/2)*.35-w*.1)
            else:raise ValueError(k)
            noise=((x*1103515245+y*12345+c['seed']*2654435761)>>12)%(2*c['noise']+1)-c['noise']
            result.append(max(0,min(255,220-c['contrast']*inside+noise)))
    return result
