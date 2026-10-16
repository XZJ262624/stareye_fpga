"""Read-only, bounded-memory verification of explicitly listed evidence objects."""
from pathlib import Path
import argparse, gzip, hashlib, json

def digest(stream):
    h=hashlib.sha256(); n=0
    for b in iter(lambda:stream.read(1048576),b''):
        h.update(b); n+=len(b)
    return n,h.hexdigest()

def mappings(value):
    if isinstance(value,dict):
        if 'object' in value and ('original' in value or 'declared_input' in value):
            yield value.get('original',value.get('declared_input')),value['object']
        for v in value.values(): yield from mappings(v)
    elif isinstance(value,list):
        for v in value: yield from mappings(v)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1])
    p.add_argument('manifests',nargs='+',type=Path)
    a=p.parse_args(); root=a.root.resolve(); seen={}; count=0
    for name in a.manifests:
        path=name if name.is_absolute() else root/name
        data=json.loads(path.read_bytes())
        for original,obj in mappings(data):
            q=(root/obj['path']).resolve()
            assert q.is_relative_to(root),('PATH_ESCAPE',obj['path'])
            key=(obj['path'],obj['bytes'],obj['sha256'])
            if key not in seen:
                with q.open('rb') as f: compressed=digest(f)
                assert compressed==(obj['bytes'],obj['sha256']),('OBJECT_BYTES',obj['path'])
                with gzip.open(q,'rb') as f: seen[key]=digest(f)
            assert seen[key]==(original['bytes'],original['sha256']),('DECODED_BYTES',original['path'])
            count+=1
    print(json.dumps(dict(status='PASS_EXPLICIT_OBJECTS_STREAMED_BYTE_EXACT',mappings=count,unique_objects=len(seen),decoded_unique_bytes=sum(x[0] for x in seen.values()),read_only=True)))

if __name__=='__main__': main()
