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
        path = f"../../data/proxies_with_uschunt_results/{chain}/{net}/reversed_order"
        for root, d_names, f_names in os.walk(path):
            # if "0.4." in root:
            for file_name in f_names:
                file_path = os.path.join(root, file_name)
                if file_name.endswith(".sol"):
                    f = open(file_path, "r")
                    code = f.read()
                    f.close()
                    if not code.endswith("\n}"):
                        code = code + "\n}\n"
                        f = open(file_path, "w")
                        f.write(code)
                        f.close()
