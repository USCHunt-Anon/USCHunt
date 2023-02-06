import os
import json
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import numpy as np
from datetime import datetime

chain_names = ['ethereum', 'arbitrum', 'avalanche', 'bsc', 'celo', 'fantom', 'optimism', 'polygon']

total_proxies_by_date = {}
upgradeable_proxies_by_date = {}
upgradeable_addresses = ""
for chain in chain_names:

    if os.path.exists(f"../../data/proxies_with_uschunt_results/{chain}/mainnet/upgradeable_addresses.txt"):
        f = open(f"../../data/proxies_with_uschunt_results/{chain}/mainnet/upgradeable_addresses.txt", "r")
        upgradeable_addresses += f.read()
        f.close()

path = f"../../artifacts/balances_and_dates.json"
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
    sorted_json = json.loads(json.dumps(sorted_dict, indent=4, sort_keys=False))
    f = open(path.replace("balances_and_dates", "sorted_by_date"), "w")
    f.write(str(sorted_json))
    f.close()
    x_axis_all = []
    y_axis_all = []
    x_axis_upgradeable = []
    y_axis_upgradeable = []
    upgradeable_count = 0
    for i in range(1, len(sorted_proxy_data)):
        item = sorted_proxy_data[i]
        address = str(item[0])
        try:
            deploy_date = datetime.strptime(item[1]["deploy_date"], "%Y-%m-%d %H:%M:%S").date()
        except ValueError:
            continue
        except TypeError:
            continue
        total_proxies_by_date[str(deploy_date)] = i
        if address in upgradeable_addresses:
            is_upgradeable = True
            upgradeable_count += 1
        else:
            is_upgradeable = False
        if len(x_axis_all) > 0 and x_axis_all[len(x_axis_all) - 1] == deploy_date:
            y_axis_all[len(y_axis_all) - 1] = i
        else:
            x_axis_all.append(deploy_date)
            y_axis_all.append(i)
        if is_upgradeable:
            if len(x_axis_upgradeable) > 0 and x_axis_upgradeable[len(x_axis_upgradeable) - 1] == deploy_date:
                y_axis_upgradeable[len(y_axis_upgradeable) - 1] = upgradeable_count
            else:
                x_axis_upgradeable.append(deploy_date)
                y_axis_upgradeable.append(upgradeable_count)
    # x1 = np.array(x_axis_all)
    # y1 = np.array(y_axis_all)
    # plt.plot(x1, y1)
    x_all = np.array(x_axis_upgradeable)
    y_all = np.array(y_axis_upgradeable)

    total_proxies_by_date = {}
    upgradeable_proxies_by_date = {}
    x_chains = {}
    y_chains = {}
    for chain in chain_names:
        x_chains[chain] = []
        y_chains[chain] = []
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
                                       key=lambda p: datetime(1900, 1, 1) if p[0] == "total" or p[1][
                                           "deploy_date"] == ""
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
            sorted_json = json.loads(json.dumps(sorted_dict, indent=4, sort_keys=False))
            f = open(path.replace("balances_and_dates", "sorted_by_date"), "w")
            f.write(str(sorted_json))
            f.close()
            x_axis_all = []
            y_axis_all = []
            x_axis_upgradeable = []
            y_axis_upgradeable = []
            upgradeable_count = 0
            for i in range(1, len(sorted_proxy_data)):
                item = sorted_proxy_data[i]
                address = str(item[0])
                try:
                    deploy_date = datetime.strptime(item[1]["deploy_date"], "%Y-%m-%d %H:%M:%S").date()
                    if any([str(deploy_date).startswith(d) for d in ["2022-08", "2022-09"]]):
                        continue
                except ValueError:
                    continue
                except TypeError:
                    continue
                total_proxies_by_date[chain][str(deploy_date)] = i
                if address in upgradeable_addresses:
                    is_upgradeable = True
                    upgradeable_count += 1
                else:
                    is_upgradeable = False
                if len(x_axis_all) > 0 and x_axis_all[len(x_axis_all) - 1] == deploy_date:
                    y_axis_all[len(y_axis_all) - 1] = i
                else:
                    x_axis_all.append(deploy_date)
                    y_axis_all.append(i)
                if is_upgradeable:
                    if len(x_axis_upgradeable) > 0 and x_axis_upgradeable[len(x_axis_upgradeable) - 1] == deploy_date:
                        y_axis_upgradeable[len(y_axis_upgradeable) - 1] = upgradeable_count
                    else:
                        x_axis_upgradeable.append(deploy_date)
                        y_axis_upgradeable.append(upgradeable_count)
            # x1 = np.array(x_axis_all)
            # y1 = np.array(y_axis_all)
            # plt.plot(x1, y1)
            x_chains[chain] = np.array(x_axis_upgradeable)
            y_chains[chain] = np.array(y_axis_upgradeable)
            # fig, ax = plt.subplots()
            # plt.figure(figsize=(11, 8.5))
            # plt.plot(x_chains[chain], y_chains[chain], label=chain)
    fig, ax = plt.subplots()
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    # plt.figure(figsize=(6.4, 4.8))
    plt.plot(x_all, y_all, label="all chains")
    for chain in chain_names:
        plt.plot(x_chains[chain], y_chains[chain], label=chain)
    monthyearFmt = mdates.DateFormatter('%m/%y')
    ax.xaxis.set_major_formatter(monthyearFmt)
    plt.xlabel("Date")
    plt.ylabel("USC proxy count")
    # plt.title(f"{chain} mainnet")
    plt.legend()
    # plt.show()
    plt.savefig('./all_chains_upgradeable_count_by_date.pdf')
