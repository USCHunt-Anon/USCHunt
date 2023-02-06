import math
import os
import threading
import time
import requests
import json

suffix_list = ['aa', 'ab', 'ac', 'ad', 'ae', 'af', 'ag', 'ah']

api_config = {
    "ethereum": {
        "keys": [
            "WMXJBN6S7D838WIIN3M64UTA1IMN897HMV",
            "3GRM2RBP872XEV26GUBMSTCHM828S1CVPE",
            "3H6GK8YF3548IZ9MK7XNK5HH3EK8K8BSFR",
            "V3RM37Z5EICQ4TZXDGGMW5M1XQVXM8Y484",
            "HD96JWIU7N6DF3D8GGAICD6HIZJUGRWC86",
            "UW4IWY38B912ZBVRDX5MUYSBVMEK37PSU2",
            "XN9E8NVTAC7VHN2J9S9PM4WKMX44CFE6H8",
            "AKC96T8STKUMVSZ9TQT34T9J3MN1PJVGDU"
        ],
        "urls": {
            # "mainnet": "api.etherscan.io",
            "goerli": "api-goerli.etherscan.io",
            "kovan": "api-kovan.etherscan.io",
            "rinkeby": "api-rinkeby.etherscan.io",
            "ropsten": "api-ropsten.etherscan.io",
        }
    },
    # "arbitrum": {
    #     "keys": ["R39J7Z3H8HAW12VHRQR4859S7JHQ9ZK96T"],
    #     "urls": {
    #         "mainnet": "api.arbiscan.io",
    #         "testnet": "api-testnet.arbiscan.io",
    #     }
    # },
    # "avalanche": {
    #     "keys": [
    #         "Q5AYWBQGG3N6JM4RW87PY7HAPZB9SUZR6C",
    #         "18P377JFB4588M4881359CPY5RH91J8CEZ"
    #     ],
    #     "urls": {
    #         "mainnet": "api.snowtrace.io",
    #         "testnet": "api-testnet.snowtrace.io",
    #     }
    # },
    # "bsc": {
    #     "keys": [
    #         "QSVE8VDS51DMHDY8JNMB1G5JVF7QY49695",
    #         "1JISCHPJAZIUBYMID8Z7V9EDVK2J73G4CF",
    #         "YKMK2ESXGJHBJ4GHGMQ1NC489SBWGUS7HM",
    #         "U8S2R1S8KW6GA49BP1BRTSHMJJ7C6U8RXN",
    #         "1X3YYIZWMZMMR5YHQG9BSGRWCY6G15TU24",
    #         "PPEF9F8AWKK52G2AQPR7ZJW28EQM1I9D6U"
    #     ],
    #     "urls": {
    #         "mainnet": "api.bscscan.com",
    #         "testnet": "api-testnet.bscscan.com",
    #     }
    # },
    # "celo": {
    #     "keys": ["WQ6ZT6AEWMUZ4HGA138GBBJ1JW82F33TSH"],
    #     "urls": {
    #         "mainnet": "api.celoscan.io",
    #     }
    # },
    # "fantom": {
    #     "keys": ["62JMQV4UM63BAK4AVTDHCRD2K6R6CGD3KR"],
    #     "urls": {
    #         "mainnet": "api.ftmscan.com",
    #     }
    # },
    # "optimism": {
    #     "keys": ["NTUJVM68N84UN9TGI9PM461BN6I7GDRHAZ"],
    #     "urls": {
    #         "mainnet": "api-optimistic.etherscan.io",
    #     }
    # },
    # "polygon": {
    #     "keys": [
    #         "ISEYA25AATQI5YQMVS3EJZXTPJ847Y2TVK"
    #         "XFP8E4P3PKTSZU53MEWDPGB9P6RUJS512M",
    #         "C3GTPDFC5PW3GSRNMKYGDPRJV38K3QJ3YE",
    #         "EKY8EVCWSGHN5ANHXC1Q6U2377B7Q21M9W",
    #         "E55BX25VS9HSR1M1KCKT4UR93Y5K2SQYDY",
    #         "GE5Q7DUZAHC46FC644S8SUH3NYPUXGPGCS"
    #         ],
    #     "urls": {
    #         "mainnet": "api.polygonscan.com",
    #         "mumbai": "api-testnet.polygonscan.com",
    #     }
    # },
}

results = {}


def verify_proxy(proxy_address, chain_name, chain_network, api_key) -> int:
    print(f"Verifying proxy at address {proxy_address} on {chain_name} {chain_network} chain")
    if chain_name != "tron":
        headers = {
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0"
        }
        url = f"https://{api_config[chain_name]['urls'][chain_network]}" \
              f"/api?module=contract&action=verifyproxycontract&apikey={api_key}"
        data = {'address': proxy_address}
        response = requests.post(url, data=data, headers=headers)
        try:
            result = json.loads(response.text)
            print(response.text)
            status = int(result.get("status"))
            guid = result.get("result")
            while guid == "Daily limit of 100 source code submissions reached":
                print("Trying again in 6 hours...")
                time.sleep(21600)
                response = requests.post(url, data=data, headers=headers)
                result = json.loads(response.text)
                print(response.text)
                status = int(result.get("status"))
                guid = result.get("result")
        except json.decoder.JSONDecodeError:
            print(f"error on contract at {proxy_address}")
            print(response.text)
            status = 0
            guid = None
        except AttributeError:
            print(f"error on contract at {proxy_address}")
            print(response.text)
            status = 0
            guid = None
        if status == 1:
            time.sleep(1)
            response = requests.get(f"https://{api_config[chain_name]['urls'][chain_network]}" 
                                    f"/api?module=contract&action=checkproxyverification&guid={guid}&apikey={api_key}",
                                    headers=headers)
            print(response.text)
            status = json.loads(response.text).get("status")
            result = json.loads(response.text).get("result")
            while result == "Pending in queue":
                error_count = 0
                print("Trying again in 1 minute")
                time.sleep(60)
                response = requests.get(f"https://{api_config[chain_name]['urls'][chain_network]}/api?module=contract" 
                                        f"&action=checkproxyverification&guid={guid}&apikey={api_key}", headers=headers)
                try:
                    status = json.loads(response.text).get("status")
                    result = json.loads(response.text).get("result")
                except json.decoder.JSONDecodeError:
                    error_count += 1
                    if error_count > 5:
                        break
                print(response.text)
            results[chain_name][chain_network][proxy_address] = result
        return status


def scan_100(chain_name, chain_network, api_key, suffix):
    print(f"Starting thread for addresses in missing_implementations_{suffix}.txt "
          f"on {chain_name} {chain_network} chain")
    list_path = f"../../data/proxies_with_uschunt_results/{chain_name}/{chain_network}/proxies/all_addresses_{suffix}"
    if os.path.exists(list_path):
        f = open(list_path, "r")
        address_list = f.readlines()
        f.close()
        for address in address_list:
            if "balance" in address or "sorted" in address:
                continue
            address = address.replace("\n", "")
            verify_proxy(address, chain_name, chain_network, api_key)
            time.sleep(900)
    print(f"Finished thread for addresses in all_addresses_{suffix} "
          f"on {chain_name} {chain_network} chain")


# Yield successive n-sized
# chunks from l.
def divide_chunks(lst, n):
    # looping till length l
    for i in range(0, len(lst), n):
        yield lst[i:i + n]


def scan_chain(chain_name):
    urls: dict = api_config[chain_name]['urls']
    if chain_name not in results.keys():
        results[chain_name] = {}
    for chain_network in urls.keys():
        if chain_network not in results[chain_name].keys():
            results[chain_name][chain_network] = {}
        print(f"Starting thread for {chain_name} {chain_network} chain")
        proxies_path = f"../../data/proxies_with_uschunt_results/{chain_name}/{chain_network}/proxies"
        list_path = f"../../data/proxies_with_uschunt_results/{chain_name}/{chain_network}/proxies/all_addresses.txt"
        api_keys = api_config[chain_name]["keys"]
        num_keys = len(api_keys)
        if not os.path.exists(list_path):
            """Create a complete list of all proxy addresses"""
            count = 0
            f = open(list_path, "w")
            for root, d_names, f_names in os.walk(proxies_path):
                for file_name in f_names:
                    if file_name.endswith(".sol"):
                        address = "0x" + file_name.split("_")[0]
                        f.write(address + "\n")
            f.close()
        """Check the length of the resulting list"""
        f = open(list_path, "r")
        address_list = f.readlines()
        f.close()
        """Split the list of addresses into equal chunks, one chunk per API key"""
        num_per_list = math.ceil(len(address_list)/num_keys)
        sublists = list(divide_chunks(address_list, num_per_list))
        for i in range(0, len(sublists)):
            suffix = suffix_list[i]
            sublist = sublists[i]
            sublist_path = list_path.replace(".txt", f"_{suffix}")
            f = open(sublist_path, "w")
            f.writelines(sublist)
            f.close()
        threads = []
        if os.path.exists(list_path):
            for i in range(0, num_keys):
                suffix = suffix_list[i]
                api_key = api_keys[i]
                if os.path.exists(list_path.replace(".txt", f"_{suffix}")):
                    thread = threading.Thread(target=scan_100, args=(chain_name, chain_network, api_key, suffix))
                    threads.append(thread)
                    thread.start()
                    time.sleep(60)
            for thread in threads:
                thread.join()
                threads.remove(thread)
            results_path = list_path.replace("all_addresses.txt", "verification_results.json")
            out = open(results_path, "w")
            json_str = str(results[chain_name][chain_network]).replace("'", '"').replace('proxy"s', "proxy's")
            out.write(json.dumps(json.loads(json_str), indent=4, sort_keys=True))
            out.close()
        print(f"Finished thread for {chain_name} {chain_network} chain")


chain_threads = []
# Start scan_chain thread for each chain
for chain_name in api_config.keys():
    thread = threading.Thread(target=scan_chain, args=([chain_name]))
    chain_threads.append(thread)
    thread.start()

# Wait for each thread to finish
for thread in chain_threads:
    thread.join()
print("Complete!")
out = open("/home/USCHunt/Documents/ethereum/smart-contract-sanctuary/all_verification_results.json", "w")
json_str = str(results).replace("'", '"').replace('proxy"s', "proxy's")
out.write(json.dumps(json.loads(json_str), indent=4, sort_keys=True))
out.close()
