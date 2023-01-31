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


def rreplace(s, old, new, occurrence):
    li = s.rsplit(old, occurrence)
    return new.join(li)


for chain in chain_names:
    for net in network_names[chain]:
        # path = f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/{chain}/contracts/{net}/proxies_and_impls_separate"
        path = f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/{chain}/contracts/{net}/proxies_and_implementations"
        for root, d_names, f_names in os.walk(path):
            # if "0.4." in root:
            for file_name in f_names:
                file_path = os.path.join(root, file_name)
                # if file_name.endswith(".json") and os.path.exists(file_path.replace("-check-proxy.json",
                #                                                                     "implementation.sol")):
                if file_name.endswith(".json") and os.path.exists(file_path.replace(".json",
                                                                                    ".sol")):
                    f = open(file_path, "r")
                    analysis = json.loads(f.read())
                    f.close()
                    if not analysis["success"] and "Expected pragma" in str(analysis["error"]) and "| }" in str(analysis["error"]):
                        try:
                            code_line = int(str(analysis["error"]).split(".sol:")[1].split(":")[0]) - 1
                            code_path = file_path.replace(".json", ".sol")
                            f = open(code_path, "r")
                            code = f.readlines()
                            f.close()
                            f = open(code_path, "w")
                            f.writelines([code[i] for i in range(0, len(code)) if i != code_line])
                            f.close()
                        except ValueError:
                            continue

