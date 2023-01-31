import json

results = {}

f = open("compatability_check_analysis.json", "r")
data = f.read()
f.close()
analysis = json.loads(data)

if isinstance(analysis, dict):
    for chain_name in analysis.keys():
        results[chain_name] = {}
        for network in analysis[chain_name].keys():
            results[chain_name][network] = {
                "missing_check": analysis[chain_name][network]["missing_check_count"],
                "incorrect_check": analysis[chain_name][network]["incorrect_check_count"],
                "check_contract_call_result": 0,  # best
                "check_address_is_contract": 0,
                "check_address_is_not_zero": 0,
                "check_new_not_same_as_old": 0,   # worst
                "other_checks": {},
                "total": analysis[chain_name][network]["total"],
            }
            for check in analysis[chain_name][network]["count_by_check_type"].keys():
                if "proxiableUUID" in check or ".delegatecall" in check or ".call" in check:
                    results[chain_name][network]["check_contract_call_result"] += \
                        analysis[chain_name][network]["count_by_check_type"][check]
                elif "isContract" in check or ("> 0" in check and ("size" in check or "code.length" in check)):
                    results[chain_name][network]["check_address_is_contract"] += \
                        analysis[chain_name][network]["count_by_check_type"][check]
                elif "!=" in check:
                    if "address(0)" in check or "0x0" in check:
                        results[chain_name][network]["check_address_is_not_zero"] += \
                            analysis[chain_name][network]["count_by_check_type"][check]
                    else:
                        results[chain_name][network]["check_new_not_same_as_old"] += \
                            analysis[chain_name][network]["count_by_check_type"][check]
                else:
                    results[chain_name][network]["other_checks"][check] = \
                        analysis[chain_name][network]["count_by_check_type"][check]

out = open("compatability_checks_categorized.json", "w")
json_str = str(results).replace("'", '"')
out.write(json.dumps(json.loads(json_str), indent=4, sort_keys=False))
out.close()
