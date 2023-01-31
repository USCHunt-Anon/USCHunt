import os
import json
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import numpy as np
from datetime import datetime

chain_names = ['ethereum', 'arbitrum', 'avalanche', 'bsc', 'celo', 'fantom', 'optimism', 'polygon']

total_proxies_by_date = {}
upgradeable_proxies_by_date = {}
for chain in chain_names:
    upgradeable_addresses = ""
    if os.path.exists(f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/"
                      f"{chain}/contracts/mainnet/upgradeable_addresses.txt"):
        f = open(f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/"
                 f"{chain}/contracts/mainnet/upgradeable_addresses.txt", "r")
        upgradeable_addresses = f.read()
        f.close()
    total_proxies_by_date[chain] = {}
    upgradeable_proxies_by_date[chain] = {}
    path = f"/home/webthethird/Documents/ethereum/smart-contract-sanctuary/" \
           f"{chain}/contracts/mainnet/proxies/balances_and_dates.json"
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
        x2 = np.array(x_axis_upgradeable)
        y2 = np.array(y_axis_upgradeable)
        fig, ax = plt.subplots()
        # plt.figure(figsize=(11, 8.5))
        plt.plot(x2, y2)
        monthyearFmt = mdates.DateFormatter('%m/%y')
        ax.xaxis.set_major_formatter(monthyearFmt)
        # plt.xlabel("Date")
        plt.ylabel("USC proxy count")
        # plt.title(f"{chain} mainnet")
        plt.show()
