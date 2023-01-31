import os
import json
import solcx

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

stats = {}
for chain in chain_names:
    stats[chain] = {}
    # for net in network_names[chain]:
    net = "mainnet"
    list_upgradeable = []
    stats[chain][net] = {
        'proxies': 0,
        'upgradeable_proxies': 0,
        'total': 0,
        'error': 0
    }
    path = f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/{chain}/contracts/{net}/sorted/"
    for root, d_names, f_names in os.walk(path):
        for file_name in f_names:
            file_path = os.path.join(root, file_name)
            if file_name.endswith(".json") and os.path.exists(file_path.replace(".json", ".sol")):
                version = file_path.split("/sorted/")[1].split("/")[0]
                address = "0x" + file_name.split("_")[0]
                f = open(file_path, "r")
                results = json.loads(f.read())
                f.close()
                if results["success"]:
                    stats[chain][net]['total'] += 1
                    res: dict = results['results']
                    if "detectors" in res.keys():
                        stats[chain][net]['proxies'] += 1
                        if os.path.exists(file_path.replace("sorted", "proxies")):
                            f = open(file_path.replace("sorted", "proxies"), "r")
                            latest_results = json.loads(f.read())
                            f.close()
                            if latest_results["success"]:
                                results = latest_results
                        if os.path.exists(file_path.replace("sorted", "proxies_and_implementations")):
                            f = open(file_path.replace("sorted", "proxies_and_implementations"), "r")
                            latest_results = json.loads(f.read())
                            f.close()
                            if latest_results["success"]:
                                results = latest_results
                        contracts = results['results']['detectors']
                        # for contract in contracts:
                        for i in range(len(contracts) - 1, -1, -1):
                            contract = contracts[i]
                            if isinstance(contract, dict) and "features" in contract.keys():
                                if contract['features']['upgradeable']:
                                    stats[chain][net]['upgradeable_proxies'] += 1
                                    list_upgradeable.append(address)
                                    break
                else:
                    stats[chain][net]['error'] += 1
    stats[chain][net]['proxy_ratio'] = float(stats[chain][net]['proxies']) / float(stats[chain][net]['total'])
    stats[chain][net]['upgradeable_proxy_ratio'] = (float(stats[chain][net]['upgradeable_proxies']) /
                                                    float(stats[chain][net]['total']))
    print(f"Statistics for {chain} {net} chain:\n{stats[chain][net]}")
    o = open(f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/"
             f"{chain}/contracts/{net}/upgradeable_addresses.txt", "w")
    o.write(str(list_upgradeable).replace(",", "\n"))
    o.close()
out = open("/home/webthethird/Documents/ethereum/smart-contract-sanctuary/proxy_counts.json", "w")
json_str = str(stats).replace("'", '"')
out.write(json.dumps(json.loads(json_str), indent=4, sort_keys=True))
out.close()
