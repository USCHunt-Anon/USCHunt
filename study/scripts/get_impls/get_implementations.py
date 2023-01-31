import os
import time
import requests
import json
import threading


api_config = {
    "ethereum": {
        "key": "WMXJBN6S7D838WIIN3M64UTA1IMN897HMV",
        "urls": {
            "mainnet": "api.etherscan.io",
            # "goerli": "api-goerli.etherscan.io",
            # "kovan": "api-kovan.etherscan.io",
            # "rinkeby": "api-rinkeby.etherscan.io",
            # "ropsten": "api-ropsten.etherscan.io",
        }
    },
    # "arbitrum": {
    #     "key": "R39J7Z3H8HAW12VHRQR4859S7JHQ9ZK96T",
    #     "urls": {
    #         "mainnet": "api.arbiscan.io",
    #         "testnet": "api-testnet.arbiscan.io",
    #     }
    # },
    # "avalanche": {
    #     "key": "Q5AYWBQGG3N6JM4RW87PY7HAPZB9SUZR6C",
    #     "urls": {
    #         "mainnet": "api.snowtrace.io",
    #         "testnet": "api-testnet.snowtrace.io",
    #     }
    # },
    # "bsc": {
    #     "key": "QSVE8VDS51DMHDY8JNMB1G5JVF7QY49695",
    #     "urls": {
    #         "mainnet": "api.bscscan.com",
    #         "testnet": "api-testnet.bscscan.com",
    #     }
    # },
    # "celo": {
    #     "key": "WQ6ZT6AEWMUZ4HGA138GBBJ1JW82F33TSH",
    #     "urls": {
    #         "mainnet": "api.celoscan.io",
    #     }
    # },
    # "fantom": {
    #     "key": "62JMQV4UM63BAK4AVTDHCRD2K6R6CGD3KR",
    #     "urls": {
    #         "mainnet": "api.ftmscan.com",
    #     }
    # },
    # "optimism": {
    #     "key": "NTUJVM68N84UN9TGI9PM461BN6I7GDRHAZ",
    #     "urls": {
    #         "mainnet": "api-optimistic.etherscan.io",
    #     }
    # },
    # "polygon": {
    #     "key": "ISEYA25AATQI5YQMVS3EJZXTPJ847Y2TVK",
    #     "urls": {
    #         "mainnet": "api.polygonscan.com",
    #         "mumbai": "api-testnet.polygonscan.com",
    #     }
    # },
}


def impl_detector(proxyAddress, chain_name, chain_network):
    if chain_name == "tron":
        """
        Tronscan /api/contracts/code endpoint only returns bytecode and ABI, not source code.
        So while the commented out code below does fetch the implementation address, it is of no use to us
        """
        return None
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
            return None
        d3: str = data2.get("result")[0].get("SourceCode")
        if not d3.startswith("{"):
            return d3
        if "{{" in d3:
            d3 = d3.replace("{{", "{")
            d3 = d3.rstrip('}') + "}"
        try:
            data3: dict = json.loads(d3)
        except json.decoder.JSONDecodeError:
            print(f"error on contract at {proxyAddress}")
            return None
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
        return implementation_source_code
    else:
        return None


# f = open("/home/webthethird/Documents/ethereum/mainnet/proxies/a.txt")
# A = f.readlines() 

# Write Implementation Source code in a Solidity file

def chain_thread(chain_name):
    for net in api_config[chain_name]["urls"].keys():
        for root, d_names, f_names in os.walk(f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/"
                                              f"{chain_name}/contracts/{net}/proxies"):
            proxyAddress = ""
            Implementation = ""
            if "/proxies/" in root:
                for file in f_names:
                    if file.endswith(".sol"):
                        path = os.path.join(root, file)
                        # chain_name = root.split("smart-contract-sanctuary/")[1].split("/contracts")[0]
                        chain_network = root.split("contracts/")[1].split("/proxies")[0]
                        # path = A[i]  # .rstrip("\n\r")
                        # split = path.split("/")
                        # file = split[len(split) - 1]
                        proxyAddress = "0x" + file.split("_")[0]
                        outputPath = path.replace("/proxies/", "/proxies_and_implementations/")  # .replace("/", "\\")
                        # skip contracts that aren't missing implementations
                        if os.path.exists(outputPath):
                            print(f"skipping {file}")
                            continue
                        # path = path.rstrip("\n\r")
                        print(f"processing {file} ({chain_name + ' ' + chain_network})")
                        Implementation = impl_detector(proxyAddress, chain_name, chain_network)
                        if Implementation is not None:
                            Implementation = Implementation.replace("import ", "//import")
                            if "SPDX-License-Identifier" in Implementation:
                                Implementation = Implementation.replace("SPDX-License-Identifier", "")
                            iContracts = Implementation.split("\r\n}\r\n")
                            o = open(path, 'r')
                            osrc = o.read()
                            os.makedirs(outputPath.rsplit("/", maxsplit=1)[0], exist_ok=True)
                            f = open(outputPath, 'w')
                            try:
                                print(f"\nwriting to {outputPath}\n")
                                f.write(osrc + "\n\n")
                                # Make sure not to write any duplicate contracts included as dependencies to both proxy and impl
                                for c in iContracts:
                                    icomp = c.replace("\n", "").replace("\r", "").replace(" ", "")
                                    if "pragma" in icomp:
                                        icomp = icomp.split("pragma", 1)[1].split(";", 1)[1]
                                    ocomp = osrc.replace("\n", "").replace("\r", "").replace(" ", "")
                                    if "\r\n}" not in c:
                                        c = c + "\r\n}\r\n"
                                    if icomp not in ocomp:
                                        f.write(str(c))
                            except e:
                                print(f"Error writing implementation code from proxy at {proxyAddress}:\n{e}")
                            f.close()
                            o.close()
                        else:
                            if "/0." in outputPath:
                                outputPath = outputPath.split("0.")[0]
                            else:
                                outputPath = outputPath.split("_and_implementations/")[0] + "_and_implementations/"
                            outputPath += "missing_implementations.txt"
                            if os.path.exists(outputPath):
                                append_write = "a"
                            else:
                                append_write = "w"
                            f = open(outputPath, append_write)
                            # f = open(outputPath, "w")
                            f.write(proxyAddress + "\n")
                            f.close()

thread_list = []
for chain_name in api_config.keys():
    thread = threading.Thread(target=chain_thread, args=[chain_name])
    thread_list.append(thread)
    thread.start()
for thread in thread_list:
    thread.join()
print("Complete!")
