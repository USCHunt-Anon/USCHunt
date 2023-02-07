import os
import json
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime


f = open("../../artifacts/upgrade_counts.json", "r")
data: dict = json.load(f)
f.close()
for chain_name in data.keys():
    sorted_data = dict(sorted(data[chain_name]["mainnet"].items(), key=lambda x:x[1]['tx_count']))
    addresses = []
    idxs = []
    tx_counts = []
    upgrade_counts = []
    upgrades_per_tx = []
    upgrades_per_1000_blocks = []
    block_spans = []

    idx = 0
    for address in sorted_data.keys():
        tx_count = int(sorted_data[address]["tx_count"])
        if tx_count == 0:
            continue
        tx_counts.append(tx_count)
        addresses.append(address)
        idxs.append(idx)
        idx += 1
        upgrade_count = int(sorted_data[address]["upgrade_count"])
        upgrade_counts.append(upgrade_count)
        per_tx: float = upgrade_count/tx_count
        upgrades_per_tx.append(per_tx)
        block_span = int(sorted_data[address]["end_block"]) - int(sorted_data[address]["start_block"])
        block_spans.append(block_span)
        if block_span == 0:
            block_span = 1
        per_1000_blocks = upgrade_count / block_span * 1000
        upgrades_per_1000_blocks.append(per_1000_blocks)

    x_axis = np.array(idxs)
    y_axis_all = np.array(tx_counts)
    y_axis_upgrades = np.array(upgrade_counts)

    plt.bar(x_axis, y_axis_all, label='tx count', width=1, align='edge')
    plt.bar(x_axis, y_axis_upgrades, label='upgrade count', width=1, align='edge')
    plt.legend(loc='upper left')
    plt.title(f'Upgrades vs Total Txs ({chain_name})')
    plt.yscale("log")
    plt.xticks(ticks=[len(x_axis)], labels=[f'{len(x_axis)}\ncontracts'])
    plt.show()
    plt.savefig(f'../../artifacts/upgrade_freq_{chain_name}.pdf')

    total_tx_count = sum(tx_counts)
    total_upgrades = sum(upgrade_counts)
    upgrades_per_1000_txs = total_upgrades / total_tx_count * 1000
    avg_upgrades_per_1000_blocks = total_upgrades/sum(block_spans) * 1000000
    print(f'Data for {chain_name}:')
    print(f'Upgrades per 1000 txs:  {upgrades_per_1000_txs}')
    print(f'Upgrades per 1M blocks: {avg_upgrades_per_1000_blocks}')
