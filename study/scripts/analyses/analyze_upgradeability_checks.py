import os
import json

chain_names = ['ethereum', 'arbitrum', 'avalanche', 'bsc', 'celo', 'fantom', 'optimism', 'polygon']
network_names = {
    'ethereum': [
        'mainnet',
        'goerli',
        'kovan',
        'rinkeby',
        'ropsten'
    ],
    'arbitrum': [
        'mainnet',
        'testnet'
    ],
    'avalanche': [
        'mainnet',
        'testnet'
    ],
    'bsc': [
        'mainnet',
        'testnet'
    ],
    'celo': [
        'mainnet'
    ],
    'fantom': [
        'mainnet'
    ],
    'optimism': [
        'mainnet'
    ],
    'polygon': [
        'mainnet',
        'mumbai'
    ],
}

data = {}

for chain in chain_names:
    data[chain] = {
        "missing-vars-v2": {
            "count": 0,
            "contracts": []
        },
        "order-vars-proxy": {
            "count": 0,
            "contracts": []
        },
        "order-vars-contracts": {
            "count": 0,
            "contracts": []
        },
        "extra-vars-proxy": {
            "count": 0,
            "contracts": []
        },
        "function-id-collision": {
            "count": 0,
            "contracts": []
        },
        # "function-shadowing": {
        #     "count": 0,
        #     "contracts": []
        # },
        # "variables-initialized": {
        #     "count": 0,
        #     "contracts": []
        # },
        # "missing-init-modifier": {
        #     "count": 0,
        #     "contracts": []
        # },
        # "missing-init-calls": {
        #     "count": 0,
        #     "contracts": []
        # },
        # "multiple-init-calls": {
        #     "count": 0,
        #     "contracts": []
        # },
        "were-constant": {
            "count": 0,
            "contracts": []
        },
        "became-constant": {
            "count": 0,
            "contracts": []
        }
    }
    proxies_path = f"/home/USCHunt/Documents/ethereum/smart-contract-sanctuary/{chain}" \
                   f"/contracts/mainnet/proxies_and_impls_separate"
    for root, d_names, f_names in os.walk(proxies_path):
        for file_name in f_names:
            if file_name.endswith("-check-proxy.json"):
                file_path = os.path.join(root, file_name)
                if os.path.exists(file_path.replace("proxies_and_impls_separate", "proxies_with_prev_impls")):
                    file_path = file_path.replace("proxies_and_impls_separate", "proxies_with_prev_impls")
                f = open(file_path, "r")
                analysis = json.loads(f.read())
                f.close()
                file_name = file_name.replace("-check-proxy.json", ".sol")
                if analysis["success"]:
                    results = analysis["results"]
                    if "'check': 'missing-variables'" in str(results) and file_name not in data[chain]["missing-vars-v2"]["contracts"]:
                        data[chain]["missing-vars-v2"]["count"] += 1
                        data[chain]["missing-vars-v2"]["contracts"].append(file_name)
                    if "'check': 'order-vars-proxy'" in str(results) and file_name not in data[chain]["order-vars-proxy"]["contracts"]:
                        data[chain]["order-vars-proxy"]["count"] += 1
                        data[chain]["order-vars-proxy"]["contracts"].append(file_name)
                    if "'check': 'order-vars-contracts'" in str(results) and file_name not in data[chain]["order-vars-contracts"]["contracts"]:
                        data[chain]["order-vars-contracts"]["count"] += 1
                        data[chain]["order-vars-contracts"]["contracts"].append(file_name)
                    if "'check': 'extra-vars-proxy'" in str(results) and file_name not in data[chain]["extra-vars-proxy"]["contracts"]:
                        data[chain]["extra-vars-proxy"]["count"] += 1
                        data[chain]["extra-vars-proxy"]["contracts"].append(file_name)
                    if "'check': 'function-id-collision'" in str(results) and file_name not in data[chain]["function-id-collision"]["contracts"]:
                        data[chain]["function-id-collision"]["count"] += 1
                        data[chain]["function-id-collision"]["contracts"].append(file_name)
                    # if "'check': 'function-shadowing'" in str(results):
                    #     data[chain]["function-shadowing"]["count"] += 1
                    #     data[chain]["function-shadowing"]["contracts"].append(file_name)
                    # if "'check': 'variables-initialized'" in str(results):
                    #     data[chain]["variables-initialized"]["count"] += 1
                    #     data[chain]["variables-initialized"]["contracts"].append(file_name)
                    # if "'check': 'missing-calls'" in str(results):
                    #     data[chain]["missing-init-calls"]["count"] += 1
                    #     data[chain]["missing-init-calls"]["contracts"].append(file_name)
                    # if "'check': 'missing-init-modifier'" in str(results):
                    #     data[chain]["missing-init-modifier"]["count"] += 1
                    #     data[chain]["missing-init-modifier"]["contracts"].append(file_name)
                    # if "'check': 'multiple-calls'" in str(results):
                    #     data[chain]["multiple-init-calls"]["count"] += 1
                    #     data[chain]["multiple-init-calls"]["contracts"].append(file_name)
                    if "'check': 'were-constant'" in str(results) and file_name not in data[chain]["were-constant"]["contracts"]:
                        data[chain]["were-constant"]["count"] += 1
                        data[chain]["were-constant"]["contracts"].append(file_name)
                    if "'check': 'became-constant'" in str(results) and file_name not in data[chain]["became-constant"]["contracts"]:
                        data[chain]["became-constant"]["count"] += 1
                        data[chain]["became-constant"]["contracts"].append(file_name)
output_path = "/home/USCHunt/Documents/ethereum/smart-contract-sanctuary/slither_check_upgradeability_results.json"
out = open(output_path, "w")
json_str = str(data).replace("'", '"')
out.write(json.dumps(json.loads(json_str), indent=4, sort_keys=False))
out.close()


