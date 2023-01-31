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


def impl_detector(proxyAddress, chain_name, chain_network):
    if chain_name == "tron":
        """
        Tronscan /api/contracts/code endpoint only returns bytecode and ABI, not source code.
        So while the commented out code below does fetch the implementation address, it is of no use to us
        """
        return None, None, None
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
        #     implementation_address = data.get("data")[0].get("proxy_implementation")
        # else:
        proxy_name = data.get("result")[0].get("ContractName")
        implementation_address = data.get("result")[0].get("Implementation")
        implementation_source_code = ""

        time.sleep(0.2)
        response2 = requests.get(f"https://{api_config[chain_name]['urls'][chain_network]}/api?"
                                 "module=contract&"
                                 "action=getsourcecode&"
                                 f"address={implementation_address}&"
                                 f"apikey={api_config[chain_name]['key']}", 
                                 headers=headers)
        try:
            data2 = json.loads(response2.text)
        except json.decoder.JSONDecodeError:
            print(f"error on contract at {proxyAddress}")
            return None, None, None
        d3: str = data2.get("result")[0].get("SourceCode")
        if d3 == "":
            return None, None, None
        implementation_name = data2.get("result")[0].get("ContractName")
        print(f"Implementation contract for {proxyAddress} is called {implementation_name}, "
              f"located at {implementation_address}")
        if not d3.startswith("{"):
            return d3, implementation_name, proxy_name
        if "{{" in d3:
            d3 = d3.replace("{{", "{")
            d3 = d3.rstrip('}') + "}"
        try:
            data3: dict = json.loads(d3)
        except json.decoder.JSONDecodeError:
            print(f"error on contract at {proxyAddress}")
            return None, None, None
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
        return implementation_source_code, implementation_name, proxy_name
    else:
        return None, None, None


# for i in range(0, len(A)):
for chain_name in api_config.keys():
    for chain_network in api_config[chain_name]["urls"].keys():
        if chain_network == "mainnet":
            continue
        for root, d_names, f_names in os.walk(f"/home/USCHunt/Documents/ethereum/smart-contract-sanctuary/"
                                              f"{chain_name}/contracts/{chain_network}/proxies"):
            proxyAddress = ""
            Implementation = ""
            if "/proxies/" in root:
                for file in f_names:
                    if file.endswith(".sol"):
                        path = os.path.join(root, file)
                        if os.path.exists(path.replace("proxies/", "proxies_and_impls_separate/")):
                            continue
                        # chain_name = root.split("smart-contract-sanctuary/")[1].split("/contracts")[0]
                        # chain_network = root.split("contracts/")[1].split("/proxies")[0]
                        proxyAddress = "0x" + file.split("_")[0]
                        outputPath = path.replace("/proxies/", "/proxies_and_impls_separate/")  # .replace("/", "\\")
                        # skip contracts that aren't missing implementations
                        # if os.path.exists(outputPath):
                        #     print(f"skipping {file}")
                        #     continue
                        # path = path.rstrip("\n\r")
                        print(f"processing {file} ({chain_name + ' ' + chain_network})")
                        Implementation, impl_name, proxy_name = impl_detector(proxyAddress, chain_name, chain_network)
                        if Implementation is not None:
                            """Copy existing proxy code as is"""
                            f = open(path, "r")
                            proxy_code = f.read()
                            f.close()
                            os.makedirs(outputPath.rsplit("/", maxsplit=1)[0], exist_ok=True)
                            f = open(outputPath, "w")
                            f.write(proxy_code)
                            f.close()
                            """Clean up the implementation code"""
                            Implementation = Implementation.replace("import ", "//import")
                            if "SPDX-License-Identifier" in Implementation:
                                Implementation = Implementation.replace("SPDX-License-Identifier", "")
                            """Write the implementation code to a separate file with a standard name"""
                            outputPath = outputPath.rsplit(".", maxsplit=1)[0] + "implementation.sol"
                            f = open(outputPath, 'w')
                            f.write(Implementation)
                            f.close()
                            """Write the implementation name to another file with a standard name"""
                            outputPath = outputPath.replace("implementation.sol", "impl_name.txt")
                            f = open(outputPath, 'w')
                            f.write(impl_name)
                            f.close()
                            """Write the proxy name to another file with a standard name"""
                            outputPath = outputPath.replace("impl_name.txt", "proxy_name.txt")
                            f = open(outputPath, 'w')
                            f.write(proxy_name)
                            f.close()
                        else:
                            if "/0." in outputPath:
                                outputPath = outputPath.split("0.")[0]
                            else:
                                outputPath = outputPath.split("_and_impls_separate/")[0] + "_and_impls_separate/"
                            outputPath += "missing_implementations.txt"
                            if os.path.exists(outputPath):
                                append_write = "a"
                            else:
                                os.makedirs(outputPath.rsplit("/", maxsplit=1)[0], exist_ok=True)
                                append_write = "w"
                            f = open(outputPath, append_write)
                            # f = open(outputPath, "w")
                            f.write(proxyAddress + "\n")
                            f.close()
