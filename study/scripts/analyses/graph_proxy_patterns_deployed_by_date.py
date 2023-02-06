import os
import json
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import numpy as np
from datetime import datetime

chain_names = ['ethereum']  # , 'arbitrum', 'avalanche', 'bsc', 'celo', 'fantom', 'optimism', 'polygon']

total_proxies_by_date = {}
upgradeable_proxies_by_date = {}
for chain in chain_names:
    upgradeable_addresses = ""
    if os.path.exists(f"../../data/proxies_with_uschunt_results/{chain}/mainnet/upgradeable_addresses.txt"):
        f = open(f"../../data/proxies_with_uschunt_results/{chain}/mainnet/upgradeable_addresses.txt", "r")
        upgradeable_addresses = f.read()
        f.close()
    total_proxies_by_date[chain] = {}
    upgradeable_proxies_by_date[chain] = {}
    path = f"../../data/proxies_with_uschunt_results/{chain}/mainnet/proxies/balances_and_dates.json"
    if os.path.exists(path):
        f = open(path, "r")
        proxy_data: dict = json.loads(f.read())
        f.close()
        # Sort data according to deploy date
        sorted_proxy_data = sorted(proxy_data.items(),
                                   key=lambda p: datetime(1900, 1, 1) if p[0] == "total" or p[1]["deploy_date"] == ""
                                   else datetime.strptime(p[1]["deploy_date"], "%Y-%m-%d %H:%M:%S"))
        sorted_dict = {}
        for s in sorted_proxy_data:
            if s[0] == "total":
                continue
            sorted_dict[s[0]] = s[1]
            if s[0] in upgradeable_addresses:
                sorted_dict[s[0]]["upgradeable"] = True
            else:
                sorted_dict[s[0]]["upgradeable"] = False
        """Extract patterns / features from analysis results and add info to sorted_dict"""
        for root, d_names, f_names in os.walk(path.rsplit("/", maxsplit=1)[0]):
            for file_name in f_names:
                file_path = os.path.join(root, file_name)
                if file_name.endswith(".json") and os.path.exists(file_path.replace(".json", ".sol")):
                    f = open(file_path, "r")
                    analysis = json.loads(f.read())
                    f.close()
                    if os.path.exists(file_path.replace("sorted", "proxies_and_implementations")):
                        f = open(file_path.replace("sorted", "proxies_and_implementations"), "r")
                        latest_results = json.loads(f.read())
                        f.close()
                        if latest_results["success"]:
                            analysis = latest_results
                    proxy_address = "0x" + file_name.split("_")[0]
                    if proxy_address not in sorted_dict.keys() or not sorted_dict[proxy_address]["upgradeable"]:
                        continue
                    if not analysis["success"] or "'upgradeable': True" not in str(analysis["results"]):
                        continue
                    results = analysis["results"]["detectors"]
                    for i in range(len(results) - 1, -1, -1):
                        if results[i]["features"]["upgradeable"]:
                            sorted_dict[proxy_address]["features"] = results[i]["features"]
                            break
        x_axis_all = []
        y_axis_all = []
        x_axis_upgradeable = []
        y_axis_upgradeable = []

        x_inherited_storage = []
        y_inherited_storage = []
        count_inherited_storage = 0
        x_eternal_storage = []
        y_eternal_storage = []
        count_eternal_storage = 0
        x_unstructured_non_standard = []
        y_unstructured_non_standard = []
        count_unstructured_non_standard = 0
        x_eip_1967 = []
        y_eip_1967 = []
        count_eip_1967 = 0
        x_eip_1822 = []
        y_eip_1822 = []
        count_eip_1822 = 0
        x_eip_1538 = []
        y_eip_1538 = []
        count_eip_1538 = 0
        x_eip_2535 = []
        y_eip_2535 = []
        count_eip_2535 = 0
        x_master_copy = []
        y_master_copy = []
        count_master_copy = 0
        x_transparent = []
        y_transparent = []
        count_transparent = 0
        x_beacon = []
        y_beacon = []
        count_beacon = 0
        x_registry = []
        y_registry = []
        count_registry = 0

        upgradeable_count = 0

        for i in range(1, len(sorted_proxy_data)):
            item = sorted_proxy_data[i]
            address = str(item[0])
            if address not in upgradeable_addresses:
                continue
            try:
                deploy_date = datetime.strptime(item[1]["deploy_date"], "%Y-%m-%d %H:%M:%S").date()
                if any([str(deploy_date).startswith(d) for d in ["2022-08", "2022-09"]]):
                    continue
            except ValueError:
                continue
            except TypeError:
                continue
            if "features" not in sorted_dict[address].keys():
                continue
            features: dict = sorted_dict[address]["features"]
            if "inherited_storage" in features.keys() and features["inherited_storage"]:
                count_inherited_storage += 1
                if len(x_inherited_storage) > 0 and x_inherited_storage[len(x_inherited_storage) - 1] == deploy_date:
                    y_inherited_storage[len(y_inherited_storage) - 1] = count_inherited_storage
                else:
                    x_inherited_storage.append(deploy_date)
                    y_inherited_storage.append(count_inherited_storage)
            if "eternal_storage" in features.keys() and features["eternal_storage"]:
                count_eternal_storage += 1
                if len(x_eternal_storage) > 0 and x_eternal_storage[len(x_eternal_storage) - 1] == deploy_date:
                    y_eternal_storage[len(y_eternal_storage) - 1] = count_eternal_storage
                else:
                    x_eternal_storage.append(deploy_date)
                    y_eternal_storage.append(count_eternal_storage)
            if "unstructured_storage" in features.keys() and features["unstructured_storage"]:
                if "eip_1822" in features.keys() and features["eip_1822"]:
                    count_eip_1822 += 1
                    if len(x_eip_1822) > 0 and x_eip_1822[len(x_eip_1822) - 1] == deploy_date:
                        y_eip_1822[len(y_eip_1822) - 1] = count_eip_1822
                    else:
                        x_eip_1822.append(deploy_date)
                        y_eip_1822.append(count_eip_1822)
                if "eip_1967" in features.keys() and features["eip_1967"]:
                    count_eip_1967 += 1
                    if len(x_eip_1967) > 0 and x_eip_1967[len(x_eip_1967) - 1] == deploy_date:
                        y_eip_1967[len(y_eip_1967) - 1] = count_eip_1967
                    else:
                        x_eip_1967.append(deploy_date)
                        y_eip_1967.append(count_eip_1967)
                if "eip_1967" not in features.keys() or (not features["eip_1967"]
                                                         and ("eip_1822" not in features.keys()
                                                              or not features["eip_1822"])):
                    count_unstructured_non_standard += 1
                    if len(x_unstructured_non_standard) > 0 and x_unstructured_non_standard[len(x_unstructured_non_standard) - 1] == deploy_date:
                        y_unstructured_non_standard[len(y_unstructured_non_standard) - 1] = count_unstructured_non_standard
                    else:
                        x_unstructured_non_standard.append(deploy_date)
                        y_unstructured_non_standard.append(count_unstructured_non_standard)
            if "eip_1538" in features.keys() and features["eip_1538"]:
                count_eip_1538 += 1
                if len(x_eip_1538) > 0 and x_eip_1538[len(x_eip_1538) - 1] == deploy_date:
                    y_eip_1538[len(y_eip_1538) - 1] = count_eip_1538
                else:
                    x_eip_1538.append(deploy_date)
                    y_eip_1538.append(count_eip_1538)
            if "eip_2535" in features.keys() and features["eip_2535"]:
                count_eip_2535 += 1
                if len(x_eip_2535) > 0 and x_eip_2535[len(x_eip_2535) - 1] == deploy_date:
                    y_eip_2535[len(y_eip_2535) - 1] = count_eip_2535
                else:
                    x_eip_2535.append(deploy_date)
                    y_eip_2535.append(count_eip_2535)
            if "master_copy_coupling" in features.keys() and features["master_copy_coupling"]:
                count_master_copy += 1
                if len(x_master_copy) > 0 and x_master_copy[len(x_master_copy) - 1] == deploy_date:
                    y_master_copy[len(y_master_copy) - 1] = count_master_copy
                else:
                    x_master_copy.append(deploy_date)
                    y_master_copy.append(count_master_copy)
            if "transparent" in features.keys() and features["transparent"]:
                count_transparent += 1
                if len(x_transparent) > 0 and x_transparent[len(x_transparent) - 1] == deploy_date:
                    y_transparent[len(y_transparent) - 1] = count_transparent
                else:
                    x_transparent.append(deploy_date)
                    y_transparent.append(count_transparent)
            if "beacon" in features.keys() and features["beacon"]:
                count_beacon += 1
                if len(x_beacon) > 0 and x_beacon[len(x_beacon) - 1] == deploy_date:
                    y_beacon[len(y_beacon) - 1] = count_beacon
                else:
                    x_beacon.append(deploy_date)
                    y_beacon.append(count_beacon)
            if "registry" in features.keys() and features["registry"]:
                count_registry += 1
                if len(x_registry) > 0 and x_registry[len(x_registry) - 1] == deploy_date:
                    y_registry[len(y_registry) - 1] = count_registry
                else:
                    x_registry.append(deploy_date)
                    y_registry.append(count_registry)
            #
            # if is_upgradeable:
            #     if len(x_axis_upgradeable) > 0 and x_axis_upgradeable[len(x_axis_upgradeable) - 1] == deploy_date:
            #         y_axis_upgradeable[len(y_axis_upgradeable) - 1] = upgradeable_count
            #     else:
            #         x_axis_upgradeable.append(deploy_date)
            #         y_axis_upgradeable.append(upgradeable_count)
        fig, ax = plt.subplots()
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        x1 = np.array(x_inherited_storage)
        y1 = np.array(y_inherited_storage)
        plt.plot(x1, y1, label="Inherited Storage")
        x2 = np.array(x_eternal_storage)
        y2 = np.array(y_eternal_storage)
        plt.plot(x2, y2, label="Eternal Storage")
        x3 = np.array(x_unstructured_non_standard)
        y3 = np.array(y_unstructured_non_standard)
        plt.plot(x3, y3, label="Non-standard Unstructured Storage")
        x4 = np.array(x_eip_1967)
        y4 = np.array(y_eip_1967)
        plt.plot(x4, y4, label="EIP-1967: Standard Storage Slots")
        x5 = np.array(x_eip_1822)
        y5 = np.array(y_eip_1822)
        plt.plot(x5, y5, label="EIP-1822: UUPS")
        x6 = np.array(x_master_copy)
        y6 = np.array(y_master_copy)
        plt.plot(x6, y6, label="Mastercopy / Singleton")
        x7 = np.array(x_transparent)
        y7 = np.array(y_transparent)
        plt.plot(x7, y7, label="Transparent Proxy")
        x8 = np.array(x_eip_1538)
        y8 = np.array(y_eip_1538)
        plt.plot(x8, y8, label="EIP-1538: VTable Proxy")
        x9 = np.array(x_eip_2535)
        y9 = np.array(y_eip_2535)
        plt.plot(x9, y9, label="EIP-2535: Diamond Proxy")
        x10 = np.array(x_beacon)
        y10 = np.array(y_beacon)
        plt.plot(x10, y10, label="Beacon Proxy")
        x11 = np.array(x_registry)
        y11 = np.array(y_registry)
        plt.plot(x11, y11, label="Registry Proxy")
        monthyearFmt = mdates.DateFormatter('%m/%y')
        ax.xaxis.set_major_formatter(monthyearFmt)
        plt.xlabel("Date")
        plt.ylabel("USC proxy pattern count")
        plt.yscale("log")
        plt.legend(fontsize="x-small")
        # plt.title(f"{chain} mainnet")
        plt.savefig('./all_chains_pattern_count_by_date.pdf')
        plt.show()
