import os
import json
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime


f = open("../../artifacts/upgrade_counts.json", "r")
data: dict = json.load(f)
f.close()

sorted_data = sorted(data["ethereum"]["mainnet"].items(), key=lambda x:x[1]['tx_count'])
eth_data = dict(sorted_data)
addresses = []
idxs = []
tx_counts = []
upgrade_counts = []
upgrades_per_tx = []
upgrades_per_1000_blocks = []

idx = 0
for address in eth_data.keys():
    tx_count = int(eth_data[address]["tx_count"])
    if tx_count == 0:
        continue
    tx_counts.append(tx_count)
    addresses.append(address)
    idxs.append(idx)
    idx += 1
    upgrade_count = int(eth_data[address]["upgrade_count"])
    upgrade_counts.append(upgrade_count)
    per_tx: float = upgrade_count/tx_count
    upgrades_per_tx.append(per_tx)
    block_span = int(eth_data[address]["end_block"]) - int(eth_data[address]["start_block"])
    if block_span == 0:
        block_span = 1
    per_1000_blocks = upgrade_count / block_span * 1000
    upgrades_per_1000_blocks.append(per_1000_blocks)

x_axis = np.array(idxs)
y_axis_all = np.array(tx_counts)
y_axis_upgrades = np.array(upgrade_counts)

plt.bar(x_axis, y_axis_all, label='tx count', width=1)
plt.bar(x_axis, y_axis_upgrades, label='upgrade count', width=1)
plt.legend(loc='upper left')
plt.yscale("log")
plt.show()

total_tx_count = sum(tx_counts)
total_upgrades = sum(upgrade_counts)
upgrades_per_1000_txs = total_upgrades / total_tx_count * 1000
avg_upgrades_per_1000_blocks = sum(upgrades_per_1000_blocks)/len(upgrades_per_1000_blocks)
print(f'Upgrades per 1000 txs:    {upgrades_per_1000_txs}')
print(f'Upgrades per 1000 blocks: {avg_upgrades_per_1000_blocks}')