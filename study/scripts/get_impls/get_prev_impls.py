import os
import time
import requests
import json


api_config = {
    "ethereum": {
        "key": "WMXJBN6S7D838WIIN3M64UTA1IMN897HMV",
        "urls": {
            "mainnet": "api.etherscan.io",
            "goerli": "api-goerli.etherscan.io",
            "kovan": "api-kovan.etherscan.io",
            "rinkeby": "api-rinkeby.etherscan.io",
            "ropsten": "api-ropsten.etherscan.io",
        }
    },
    "arbitrum": {
        "key": "R39J7Z3H8HAW12VHRQR4859S7JHQ9ZK96T",
        "urls": {
            "mainnet": "api.arbiscan.io",
            "testnet": "api-testnet.arbiscan.io",
        }
    },
    "avalanche": {
        "key": "Q5AYWBQGG3N6JM4RW87PY7HAPZB9SUZR6C",
        "urls": {
            "mainnet": "api.snowtrace.io",
            "testnet": "api-testnet.snowtrace.io",
        }
    },
    "bsc": {
        "key": "QSVE8VDS51DMHDY8JNMB1G5JVF7QY49695",
        "urls": {
            "mainnet": "api.bscscan.com",
            "testnet": "api-testnet.bscscan.com",
        }
    },
    "celo": {
        "key": "WQ6ZT6AEWMUZ4HGA138GBBJ1JW82F33TSH",
        "urls": {
            "mainnet": "api.celoscan.io",
        }
    },
    "fantom": {
        "key": "62JMQV4UM63BAK4AVTDHCRD2K6R6CGD3KR",
        "urls": {
            "mainnet": "api.ftmscan.com",
        }
    },
    "optimism": {
        "key": "NTUJVM68N84UN9TGI9PM461BN6I7GDRHAZ",
        "urls": {
            "mainnet": "api-optimistic.etherscan.io",
        }
    },
    "polygon": {
        "key": "ISEYA25AATQI5YQMVS3EJZXTPJ847Y2TVK",
        "urls": {
            "mainnet": "api.polygonscan.com",
            "mumbai": "api-testnet.polygonscan.com",
        }
    },
}


def prev_impl_detector(proxyAddress, chain_name, chain_network, setter):
    if chain_name == "tron":
        """
        Tronscan /api/contracts/code endpoint only returns bytecode and ABI, not source code.
        So while the commented out code below does fetch the implementation address, it is of no use to us
        """
        return None, None
        # response = requests.get("https://apilist.tronscan.org/api/contract?"
        #                         f"contract={proxyAddress}")
        # data = json.loads(response.text)
        # try:
        #     proxy = data.get("data")[0].get("is_proxy")
        # except e:
        #     print(f"error on contract at {proxyAddress}")
        #     proxy = 0
    else:
        time.sleep(0.2)
        headers = {
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0"
        }
        response = requests.get(f"https://{api_config[chain_name]['urls'][chain_network]}/api?"
                                "module=contract&"
                                "action=getsourcecode&"
                                f"address={proxyAddress}&"
                                f"apikey={api_config[chain_name]['key']}", 
                                headers=headers)
        try:
            data = json.loads(response.text)
            proxy = data.get("result")[0].get("Proxy")
        except json.decoder.JSONDecodeError:
            print(f"error on contract at {proxyAddress}")
            proxy = 0
        except AttributeError:
            print(f"error on contract at {proxyAddress}")
            proxy = 0
    if int(proxy) == 1:
        # if chain_name == "tron":
        #     current_impl_address = data.get("data")[0].get("proxy_implementation")
        # else:
        proxy_name = data.get("result")[0].get("ContractName")
        if proxy_name == "Diamond":
            proxy_name = "Diamond"
        current_impl_address = data.get("result")[0].get("Implementation")
        implementation_source_code = ""
        """Get a list of transactions from the proxy address to search for calls to the setter"""
        time.sleep(0.2)
        response2 = requests.get(f"https://{api_config[chain_name]['urls'][chain_network]}/api?"
                                 "module=account&"
                                 "action=txlist&"
                                 f"address={proxyAddress}&"
                                 f"startblock=0&"
                                 f"endblock=99999999&"
                                 f"sort=desc&"
                                 f"apikey={api_config[chain_name]['key']}", 
                                 headers=headers)
        try:
            data2 = json.loads(response2.text)
        except json.decoder.JSONDecodeError:
            print(f"error on contract at {proxyAddress}")
            return None, None
        tx_list = data2["result"]
        if tx_list is None:
            return None, None
        """
        Search the transaction list for one with a function name matching the setter,
        then extract the address value from the input and compare with the current impl address
        (will need to check the setter signature for the position of the address argument first)
        Then, if the address is not the current implementation, make another query to get its code
        """
        if "address" not in setter:
            return None, None
        setter_name = setter.split("(")[0]
        setter_args = setter.split("(")[1].replace(")", "").split(",")
        idx = 0
        for arg in setter_args:
            if arg == "address":
                break
            idx += 1
        prev_impl_address = None
        for tx in tx_list:
            function_name = str(tx["functionName"]).split("(")[0]
            if function_name == setter_name or function_name == setter_name + "AndCall" or \
                    function_name.lower() == setter_name.lower().replace("implementation", "") + "andcall":
                if len(tx["input"]) > 10:
                    tx_input = str(tx["input"])[10:]
                    input_args = [tx_input[i:i+64] for i in range(0, len(tx_input), 64)]
                    if input_args[idx][24:] == "0000000000000000000000000000000000000000":
                        continue
                    address_arg = "0x" + input_args[idx][24:]
                    if address_arg != current_impl_address:
                        prev_impl_address = address_arg
                        break
        if prev_impl_address is None:
            return None, None
        response3 = requests.get(f"https://{api_config[chain_name]['urls'][chain_network]}/api?"
                                 "module=contract&"
                                 "action=getsourcecode&"
                                 f"address={prev_impl_address}&"
                                 f"apikey={api_config[chain_name]['key']}",
                                 headers=headers)
        try:
            data3 = json.loads(response3.text)
        except json.decoder.JSONDecodeError:
            print(f"error on contract at {proxyAddress}")
            return None, None
        d3: str = data3.get("result")[0].get("SourceCode")
        if d3 == "":
            return None, None
        prev_impl_name = data3.get("result")[0].get("ContractName")
        print(f"Previous implementation contract for {proxyAddress} is called {prev_impl_name}, "
              f"located at {prev_impl_address}")
        if not d3.startswith("{"):
            return d3, prev_impl_name
        if "{{" in d3:
            d3 = d3.replace("{{", "{")
            d3 = d3.rstrip('}') + "}"
        try:
            data3: dict = json.loads(d3)
        except json.decoder.JSONDecodeError:
            print(f"error on contract at {proxyAddress}")
            return None, None
        if data3.get("sources"):
            data3: dict = data3.get("sources")
        """
        If source code is not flattened, then the main contract is listed first, followed by dependencies in order.
        We need the dependencies to be written first, hence the if block below.
        """
        if len(data3.items()) > 1:
            for i in range(1, len(data3.items())):
                implementation_source_code += list(data3.items())[i][1].get("content") + "\n\n"
        implementation_source_code += list(data3.items())[0][1].get("content") + "\n\n"
        # implementation_source_Code= data2.get("result")[0].get("SourceCode")[0].get("content")
        return implementation_source_code, prev_impl_name
    else:
        return None, None


# for i in range(0, len(A)):
for chain_name in api_config.keys():
    for chain_network in api_config[chain_name]["urls"].keys():
        if chain_network == "mainnet":
            continue
        for root, d_names, f_names in os.walk(f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/"
                                              f"{chain_name}/contracts/{chain_network}/proxies"):
            proxyAddress = ""
            prev_implementation = ""
            # if "/proxies/" in root:
            for file in f_names:
                if file.endswith(".json"):
                    path = os.path.join(root, file)
                    """Do not bother with proxies without implementations"""
                    if not os.path.exists(path.replace("proxies/", "proxies_and_impls_separate/")
                                              .replace(".json", ".sol")):
                        continue
                    """Do not bother with proxies which were not determined to be upgradeable"""
                    f = open(path, "r")
                    analysis = json.loads(f.read())
                    f.close()
                    if not analysis["success"] or "'upgradeable': True" not in str(analysis["results"]):
                        continue
                    """Do not bother with Diamonds, those won't work for comparing previous implementations"""
                    if "'eip_2535': True" in str(analysis["results"]):
                        continue
                    """Proxy is upgradeable and we already have its current implementation"""
                    file = file.replace(".json", ".sol")
                    path = path.replace(".json", ".sol")
                    # chain_network = root.split("contracts/")[1].split("/proxies")[0]
                    proxyAddress = "0x" + file.split("_")[0]
                    """Get the name of the setter function from our analysis results"""
                    results = analysis["results"]["detectors"]
                    setter = None
                    for i in range(len(results) - 1, -1, -1):
                        if "features" in results[i].keys():
                            features = results[i]["features"]
                            if features["upgradeable"] and "impl_address_setter" in features.keys():
                                if "." in str(features["impl_address_setter"]):
                                    setter = str(features["impl_address_setter"]).split(".", maxsplit=1)[1]
                                    break
                                else:
                                    setter = str(features["impl_address_setter"])
                                    break
                    if setter is None:
                        continue
                    outputPath = path.replace("/proxies/", "/proxies_and_impls_separate/")  # .replace("/", "\\")
                    print(f"processing {file} ({chain_name + ' ' + chain_network})")
                    prev_implementation, impl_name = prev_impl_detector(proxyAddress, chain_name, chain_network, setter)
                    if prev_implementation is not None:
                        os.makedirs(outputPath.rsplit("/", maxsplit=1)[0], exist_ok=True)
                        """Clean up the implementation code"""
                        prev_implementation = prev_implementation.replace("import ", "//import")
                        if "SPDX-License-Identifier" in prev_implementation:
                            prev_implementation = prev_implementation.replace("SPDX-License-Identifier", "")
                        """Write the implementation code to a separate file with a standard name"""
                        outputPath = outputPath.rsplit(".", maxsplit=1)[0] + "previmplementation.sol"
                        f = open(outputPath, 'w')
                        f.write(prev_implementation)
                        f.close()
                        """Write the implementation name to another file with a standard name"""
                        outputPath = outputPath.replace("previmplementation.sol", "prev_impl_name.txt")
                        f = open(outputPath, 'w')
                        f.write(impl_name)
                        f.close()
                    else:
                        continue
                        # if "/0." in outputPath:
                        #     outputPath = outputPath.split("0.")[0]
                        # else:
                        #     outputPath = outputPath.split("_and_impls_separate/")[0] + "_and_impls_separate/"
                        # outputPath += "missing_implementations.txt"
                        # if os.path.exists(outputPath):
                        #     append_write = "a"
                        # else:
                        #     os.makedirs(outputPath.rsplit("/", maxsplit=1)[0], exist_ok=True)
                        #     append_write = "w"
                        # f = open(outputPath, append_write)
                        # # f = open(outputPath, "w")
                        # f.write(proxyAddress + "\n")
                        # f.close()
