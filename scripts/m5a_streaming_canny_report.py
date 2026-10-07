"""Read-only summary of current verified evidence; preserve reviewed documents."""
import json
from m5a_streaming_canny_final_gate import review
from m5a_streaming_canny_validate import R, ROOT, load
from m3_sobel_core_validate import check_record

def main():
    result = review()
    root = load(R / 'ROOT_FINAL_REVIEW.json')
    assert root['root_final_verdict'] == 'PASS_OFFLINE_HARDWARE_PENDING'
    assert root['bit'] == result['bit']
    hdl = load(R / 'ROOT_HDL_REVIEW.json')
    assert hdl['status'] == 'PASS'
    for source in hdl['sources']:
        import hashlib
        assert hashlib.sha256((ROOT / source['path']).read_bytes()).hexdigest() == source['sha256']
    for run in hdl['results']:
        assert run['exit_code'] == 0
        import hashlib
        assert hashlib.sha256((ROOT / run['log']).read_bytes()).hexdigest() == run['sha256']
    print(json.dumps(dict(verdict=result['verdict'], bit=result['bit'], resources=result['resources'],
        build_report=str(R / 'BUILD_REPORT.md'), root_review=str(R / 'ROOT_REVIEW.md'),
        hardware='PENDING', staged=False, committed=False), indent=2))

if __name__ == '__main__':
    main()
