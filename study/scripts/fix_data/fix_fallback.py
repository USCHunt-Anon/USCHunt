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
        path = f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/{chain}/contracts/{net}/sorted/0.4.22"
        for root, d_names, f_names in os.walk(path):
            # if "0.4." in root:
            for file_name in f_names:
                if file_name.endswith(".json"):
                    file_path = os.path.join(root, file_name)
                    f = open(file_path, "r")
                    data = f.read()
                    f.close()
                    results = json.loads(data)
                    if not results["success"] and "constructor" in results["error"] \
                            and "Other declaration is here:" in results["error"]:
                        file_path = file_path.replace(".json", ".sol")
                        contract_name = file_name.split("_", maxsplit=1)[1].replace(".json", "")
                        f = open(file_path, "r")
                        code = f.read()
                        code_split = code.split("\ncontract ")
                        for idx, contract in enumerate(code_split):
                            if "function ()" in contract or "function()" in contract:
                                code_split[idx] = code_split[idx].replace("constructor", 'function '
                                                                          + code_split[idx].split()[0])
                        code = "\ncontract ".join(code_split)
                        # code = rreplace(code, "constructor", "function " + contract_name, 1)
                        code = code.replace("fallback() public", "function() public")
                        code = code.replace("fallback () public", "function() public")
                        print(f"replaced constructor() with {'function ' + contract_name}() in {file_path}")
                        f.close()
                        new_path = file_path.replace("0.4.22", "0.4.22/new")
                        os.makedirs(new_path.rsplit("/", maxsplit=1)[0], exist_ok=True)
                        f = open(new_path, "w")
                        f.write(code)
                        f.close()
