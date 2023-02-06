import os
import json

chain_names = ['ethereum', 'arbitrum', 'avalanche', 'bsc', 'celo', 'fantom', 'optimism', 'polygon']

for chain in chain_names:
    path = f"../../data/proxies_with_uschunt_results/{chain}/"
    for root, d_names, f_names in os.walk(path):
        if "0.4." in root:
            for file_name in f_names:
                if file_name.endswith(".json"):
                    file_path = os.path.join(root, file_name)
                    f = open(file_path, "r+")
                    data = f.read()
                    f.close()
                    results = json.loads(data)
                    if not results["success"] and \
                            "Expected identifier, got 'LParen'\n  constructor" in results["error"]:
                        file_path = file_path.replace(".json", ".sol")
                        f = open(file_path, "r")
                        code = f.read()
                        f.close()
                        version = "0." + file_path.split("0.")[1].split("/")[0]
                        new_path = file_path.replace(version, "0.4.22/new")
                        print(f"Copying {file_name.replace('.json', '.sol')} to {new_path}")
                        os.makedirs(new_path.rsplit("/", maxsplit=1)[0], exist_ok=True)
                        f = open(new_path, "w+")
                        f.write(code)
                        f.close()
                        f = open(new_path.split("0.4.22")[0] + "0.4.22/moved.txt", "a+")
                        f.write(new_path + "\n")
                        f.close()
