import re, sys
def lum(h):
    h=h.lstrip('#'); r,g,b=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    f=lambda c: c/12.92 if c<=0.03928 else ((c+0.055)/1.055)**2.4
    return 0.2126*f(r)+0.7152*f(g)+0.0722*f(b)
def cr(a,b):
    la,lb=lum(a),lum(b); return (max(la,lb)+0.05)/(min(la,lb)+0.05)
c={}
for line in open(sys.argv[1]):
    m=re.match(r'\s*(\w+)\s*=\s*"(#[0-9a-fA-F]{6})"',line)
    if m: c[m[1]]=m[2]
bgs=['background','dark_background','lighter_background']
fgs=[k for k in c if k not in bgs and k not in ('darker_background','selection','mode')]
print(f"{'key':20}{'hex':10}"+''.join(f"{b[:10]:>12}" for b in bgs)+"   target")
for k in fgs:
    t = 7 if 'foreground' in k else (3 if k in ('muted','dark_foreground') else 4.5)
    if k=='dark_foreground': t=4.5
    row=[cr(c[k],c[b]) for b in bgs]
    flag=' ' if min(row)>=t else '!'
    print(f"{k:20}{c[k]:10}"+''.join(f"{v:12.2f}" for v in row)+f"   {t}  {flag}")
print("\nselection vs foreground:", round(cr(c['selection'],c['foreground']),2))
print("selection vs background:", round(cr(c['selection'],c['background']),2))
print("lighter_bg vs bg:", round(cr(c['lighter_background'],c['background']),2))
