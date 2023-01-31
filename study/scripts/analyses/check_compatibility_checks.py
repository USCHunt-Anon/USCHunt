import os
import json

chains = {
    "ethereum": {
        "networks": [
            "mainnet",
            "goerli",
            "kovan",
            "rinkeby",
            "ropsten"
        ]
    },
    "arbitrum": {
        "networks": [
            "mainnet",
            "testnet"
        ]
    },
    "avalanche": {
        "networks": [
            "mainnet",
            "testnet"
        ]
    },
    "bsc": {
        "networks": [
            "mainnet",
            "testnet"
        ]
    },
    "celo": {
        "networks": [
            "mainnet"
        ]
    },
    "fantom": {
        "networks": [
            "mainnet"
        ]
    },
    "optimism": {
        "networks": [
            "mainnet"
        ]
    },
    "polygon": {
        "networks": [
            "mainnet",
            "mumbai"
        ]
    },
}

counts = {}

for chain in chains.keys():
    counts[chain] = {}
    for network in chains[chain]["networks"]:
        counts[chain][network] = {
            "missing_check_count": 0,
            "incorrect_check_count": 0,
            "count_by_check_type": {},
            "total": 0,
        }
        for root, d_names, f_names in os.walk(f"{chain}/contracts/{network}/proxies"):
            for file_name in f_names:
                if file_name.endswith(".json"):
                    file_path = os.path.join(root, file_name)
                    if os.path.exists(file_path.replace(".json", ".sol")):
                        f = open(file_path, "r")
                        data = f.read()
                        f.close()
                        analysis = json.loads(data)
                        if not analysis["success"]:
                            continue
                        results = analysis["results"]["detectors"]
                        for i in range(len(results) - 1, -1, -1):
                            result = results[i]
                            features = result["features"]
                            if not features["upgradeable"]:
                                continue
                            compatibility = features["compatibility_checks"]
                            if not compatibility["has_all_checks"]:
                                counts[chain][network]["missing_check_count"] += 1
                            found_incorrect = False
                            checks_found = []
                            if isinstance(compatibility["functions"], dict):
                                for function in compatibility["functions"].keys():
                                    if compatibility["functions"][function] == "missing":
                                        # counts[chain][network]["missing_check_count"] += 1  # already counted above
                                        continue
                                    if isinstance(compatibility["functions"][function], str):
                                        check: str = compatibility["functions"][function]
                                    elif isinstance(compatibility["functions"][function], dict):
                                        if not compatibility["functions"][function]["is_correct"] and not found_incorrect:
                                            counts[chain][network]["incorrect_check_count"] += 1
                                            found_incorrect = True
                                        check: str = compatibility["functions"][function]["check"]
                                    else:
                                        continue
                                    if check.startswith("require(bool,string)"):
                                        check = check.rsplit(",", maxsplit=1)[0] + ")"
                                    check = check.replace("bool,string", "bool")\
                                        .replace("require(bool)", "").replace("assert(bool)", "")
                                    if check not in checks_found:
                                        checks_found.append(check)
                                        if check not in counts[chain][network]["count_by_check_type"].keys():
                                            counts[chain][network]["count_by_check_type"][check] = 1
                                        else:
                                            counts[chain][network]["count_by_check_type"][check] += 1
                            counts[chain][network]["total"] += 1
                            break
out = open("compatability_check_analysis.json", "w")
json_str = str(counts).replace("'", '"')
out.write(json.dumps(json.loads(json_str), indent=4))
out.close
