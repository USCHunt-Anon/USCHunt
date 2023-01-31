import os
import json
import shutil

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
        path = f"/home/USCHunt/Documents/ethereum/smart-contract-sanctuary/{chain}/contracts/{net}/proxies_and_impls_separate"
        if not os.path.exists(path):
            continue
        for root, d_names, f_names in os.walk(path):
            # if "0.4." in root:
            for file_name in f_names:
                if file_name.endswith("-check-proxy.json") and "/new/" not in root:
                    file_path = os.path.join(root, file_name)
                    f = open(file_path, "r")
                    data = f.read()
                    f.close()
                    results = json.loads(data)
                    if not results["success"] and "pragma solidity" in results["error"]:
                        file_path = file_path.replace("-check-proxy.json", "previmpl.sol")
                        try:
                            version = "0." + file_path.split("0.")[1].split("/")[0]
                        except IndexError:
                            version = None
                        try:
                            new_version = str(results["error"]).split("pragma solidity ")[1].split(";")[0]
                            v_split = new_version.split(" ")
                            if len(v_split) > 1:
                                if "<" in v_split[len(v_split) - 1]:
                                    new_version = v_split[len(v_split) - 2]
                                else:
                                    new_version = v_split[len(v_split) - 1]
                            new_version = new_version.replace(" ", "").replace("<", "").replace(">", "")\
                                .replace("=", "").replace("^", "").replace("~", "")
                        except IndexError:
                            continue
                        contract_name = file_name.split("_", maxsplit=1)[1].replace("-check-proxy.json", "")
                        if version is not None:
                            new_path = file_path.replace(version, f"{new_version}")
                        else:
                            new_path = file_path.replace("proxies_and_impls_separate", f"proxies_and_impls_separate/{new_version}")
                        os.makedirs(new_path.rsplit("/", maxsplit=1)[0], exist_ok=True)
                        if os.path.exists(file_path):
                            shutil.copy2(file_path, new_path)
                        file_path = file_path.replace("previmpl.sol", "implementation.sol")
                        new_path = new_path.replace("previmpl.sol", "implementation.sol")
                        shutil.copy2(file_path, new_path)
                        file_path = file_path.replace("implementation.sol", "impl_name.txt")
                        new_path = new_path.replace("implementation.sol", "impl_name.txt")
                        shutil.copy2(file_path, new_path)
                        file_path = file_path.replace("impl_name.txt", "prev_impl_name.txt")
                        new_path = new_path.replace("impl_name.txt", "prev_impl_name.txt")
                        if os.path.exists(file_path):
                            shutil.copy2(file_path, new_path)
                        file_path = file_path.replace("prev_impl_name.txt", "proxy_name.txt")
                        new_path = new_path.replace("prev_impl_name.txt", "proxy_name.txt")
                        shutil.copy2(file_path, new_path)
                        file_path = file_path.replace("proxy_name.txt", ".sol")
                        new_path = new_path.replace("proxy_name.txt", ".sol")
                        shutil.copy2(file_path, new_path)
                        print(f"Moved {file_name} from {version} to {new_version}")
