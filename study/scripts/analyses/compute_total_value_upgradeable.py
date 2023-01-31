import os
import json

chain_names = ['ethereum', 'arbitrum', 'avalanche', 'bsc', 'celo', 'fantom', 'optimism', 'polygon']
upgradeable_balances = {}

for chain in chain_names:
    upgradeable_balances[chain] = {
        "totals": {
            "count": 0,
            "native_balance": 0.0,
            "native_value": 0.0,
            "token_value": 0.0,
            "missing_balance": 0
        }
    }
    proxies_path = f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/" \
                   f"{chain}/contracts/mainnet/proxies/"
    f = open(proxies_path + "balances.json", "r")
    balances = json.loads(f.read())
    f.close()
    for root, d_names, f_names in os.walk(proxies_path):
        for file_name in f_names:
            file_path = os.path.join(root, file_name)
            if file_name.endswith(".json") and os.path.exists(file_path.replace(".json", ".sol")):
                f = open(file_path, "r")
                analysis = json.loads(f.read())
                f.close()
                if analysis["success"] and "'upgradeable': True" in str(analysis["results"]):
                    proxy_address = "0x" + file_name.split("_")[0]
                    if proxy_address in balances.keys():
                        native_balance = float(balances[proxy_address]["native_balance"])
                        native_value = float(balances[proxy_address]["native_value"])
                        token_value = float(balances[proxy_address]["token_value"])
                        upgradeable_balances[chain][proxy_address] = {
                            "native_balance": native_balance,
                            "native_value": native_value,
                            "token_value": token_value,
                        }
                        upgradeable_balances[chain]["totals"]["native_balance"] += native_balance
                        upgradeable_balances[chain]["totals"]["native_value"] += native_value
                        upgradeable_balances[chain]["totals"]["token_value"] += token_value
                        upgradeable_balances[chain]["totals"]["count"] += 1
                    else:
                        upgradeable_balances[chain]["totals"]["missing_balance"] += 1
    print(f"Total value of upgradeable proxies on {chain} mainnet:\n"
          f"    native_balance: {upgradeable_balances[chain]['totals']['native_balance']}\n"
          f"    native_value:  ${upgradeable_balances[chain]['totals']['native_value']}\n"
          f"    token_value:   ${upgradeable_balances[chain]['totals']['token_value']}")
    out = open(proxies_path + "upgradeable_balances.json", "w")
    json_str = str(upgradeable_balances).replace("'", '"')
    out.write(json.dumps(json.loads(json_str), indent=4, sort_keys=True))
    out.close()
                        

                    
