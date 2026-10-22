from common import *
def active():
 d=json.loads((O/'ACTIVE_PHYSICAL.json').read_text());return R/d['path'],R/d['project']
