import os
import json

chain_names = ['ethereum']  # , 'arbitrum', 'avalanche', 'bsc', 'celo', 'fantom', 'optimism', 'polygon']
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
        # if net == "mainnet":
        #     continue
        path = f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/{chain}/contracts/{net}/proxies_and_impls_separate"
        for root, d_names, f_names in os.walk(path):
            # if "0.4." in root:
            for file_name in f_names:
                if file_name == "ab9c8c81228abd4687078ebda5ae236789b08673_TransparentUpgradeableProxy-check-proxy.json":
                    file_name = "ab9c8c81228abd4687078ebda5ae236789b08673_TransparentUpgradeableProxy-check-proxy.json"
                file_path = os.path.join(root, file_name)
                if file_name.endswith("-check-proxy.json"):  # and os.path.exists(file_path.replace("-check-proxy.json", ".sol")):
                    f = open(file_path, "r")
                    data = f.read()
                    f.close()
                    results = json.loads(data)
                    if not results["success"] and "Definition of base" in results["error"]:
                        file_path = file_path.replace("-check-proxy.json", "implementation.sol")
                        f = open(file_path, "r")
                        code = f.read()
                        f.close()
                        try:
                            version = "0." + file_path.split("0.")[1].split("/", maxsplit=1)[0]
                        except IndexError:
                            version = None
                        code_lines = [line for line in code.split("\n") if not line.strip().startswith("/")
                                      and not line.strip().startswith("*") and not line.strip().startswith("@")]
                        code_lines = [line.replace("{}", "{ }") if line.strip().startswith("function") else line
                                      for line in code_lines]
                        code = "\n".join(code_lines)
                        code = code.replace("{}", "{\n}")
                        iContracts = code.split("\n}")
                        iContracts = [c + "\n}\n" for c in iContracts if "{" in c]
                        """
                        Need to find a way to rearrange the contracts according to inheritance,
                        rather than simply reversing their order
                        """
                        inheritance = {
                            "libraries": []
                        }
                        error = False
                        for c in iContracts:
                            try:
                                if "\nlibrary" in c:
                                    """Libraries cannot inherit, but everything else can"""
                                    name = c.split("\nlibrary ")[1].split()[0]
                                    inheritance[name] = {
                                        "contract": c,
                                        "inherits": []
                                    }
                                    inheritance["libraries"].append(name)
                                elif "\ninterface" in c:
                                    declaration = c.split("\ninterface "
                                                          "")[1].split("{")[0].replace("\n", " ")
                                    declaration = declaration.replace("\r", "").replace("\t", "").replace("  ", " ")
                                    name = declaration.split()[0]
                                    inheritance[name] = {
                                        "contract": c,
                                        "inherits": []
                                    }
                                    if f"{name} is" in declaration:
                                        inheritance[name]["inherits"] = declaration.split(" is ")[1].strip().split(",")
                                        inheritance[name]["inherits"] = [name.replace(" ", "")
                                                                         for name in inheritance[name]["inherits"]]
                                elif "\nabstract" in c:
                                    declaration = c.split("\nabstract contract "
                                                          "")[1].split("{")[0].replace("\n", " ")
                                    declaration = declaration.replace("\r", "").replace("\t", "").replace("  ", " ")
                                    name = declaration.split()[0]
                                    inheritance[name] = {
                                        "contract": c,
                                        "inherits": []
                                    }
                                    if f"{name} is" in declaration:
                                        inheritance[name]["inherits"] = declaration.split(" is ")[1].strip().split(",")
                                        inheritance[name]["inherits"] = [name.replace(" ", "")
                                                                         for name in inheritance[name]["inherits"]]
                                else:
                                    declaration = c.split("\ncontract "
                                                          "")[1].split("{")[0].replace("\n", " ")
                                    declaration = declaration.replace("\r", "").replace("\t", "").replace("  ", " ")
                                    name = declaration.split()[0]
                                    inheritance[name] = {
                                        "contract": c,
                                        "inherits": []
                                    }
                                    if f"{name} is" in declaration:
                                        inheritance[name]["inherits"] = declaration.split(" is ")[1].strip().split(",")
                                        inheritance[name]["inherits"] = [name.replace(" ", "")
                                                                         for name in inheritance[name]["inherits"]]
                            except IndexError:
                                error = True
                                break
                        if error:
                            continue
                        # new_order = [c for c in iContracts if "\nlibrary" in c]
                        # new_order += [c for c in iContracts if "\ninterface" in c]
                        # new_order += [c for c in iContracts if "\nabstract" in c]
                        new_order = []
                        for name in inheritance["libraries"]:
                            new_order.append(inheritance[name]["contract"])
                            try:
                                iContracts.remove(inheritance[name]["contract"])
                                for key in inheritance.keys():
                                    if key == "libraries":
                                        continue
                                    if name in inheritance[key]["inherits"]:
                                        inheritance[key]["inherits"].remove(name)
                            except ValueError:
                                error = True
                                break
                        if error:
                            continue
                        num_c = len(iContracts)
                        while len(iContracts) > 0:
                            for c in iContracts:
                                try:
                                    if "\ninterface" in c:
                                        name = c.split("\ninterface ")[1].split()[0].split("{")[0]
                                    elif "\nabstract" in c:
                                        name = c.split("\nabstract contract ")[1].split()[0].split("{")[0]
                                    else:
                                        name = c.split("\ncontract ")[1].split()[0].split("{")[0]
                                    if len(inheritance[name]["inherits"]) == 0:
                                        new_order.append(inheritance[name]["contract"])
                                        try:
                                            iContracts.remove(inheritance[name]["contract"])
                                            for key in inheritance.keys():
                                                if key == "libraries":
                                                    continue
                                                if name in inheritance[key]["inherits"]:
                                                    inheritance[key]["inherits"].remove(name)
                                        except ValueError:
                                            num_c = len(iContracts)
                                            break
                                except IndexError:
                                    num_c = len(iContracts)
                                    break
                                except KeyError:
                                    num_c = len(iContracts)
                                    break
                            if num_c == len(iContracts):
                                break
                            else:
                                num_c = len(iContracts)
                        if len(iContracts) > 0 or error:
                            continue
                        new_code = "\n\n".join(new_order)
                        if version is not None and "pragma solidity" not in new_order[0]:
                            new_code = f"pragma solidity {version};\n\n" + new_code
                        new_file_path = file_path.replace("reversed_order", "reversed_order_again")
                        print(f"Reversed the contract definition order in {file_name} and saved in "
                              f"{new_file_path.split('smart-contract-sanctuary')[1]}")
                        try:
                            os.makedirs(new_file_path.rsplit("/", maxsplit=1)[0], exist_ok=True)
                            f = open(new_file_path, "w")
                            f.write(new_code)
                            f.close()
                        except:
                            continue
