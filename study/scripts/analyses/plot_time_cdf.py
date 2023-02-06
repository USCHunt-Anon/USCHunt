import os
import sys
from pprint import pprint

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import statsmodels.api as sm

g_tags = ['DeepBinDiff', 'DeepBinDiff-Ctx', 'Asm2Vec+K-Hop', 'BinDiff']
g_colors = ['tab:blue', 'tab:red', 'tab:green', 'tab:orange', 'tag:pink', 'tab:purple', 'tab:cyan']
g_markers = ['o', '^', 's', 'd', 'D', '*', 'x']

matplotlib.rcParams.update({'font.size': 60})
matplotlib.rcParams.update({'figure.figsize': (24, 20)})
matplotlib.rcParams.update({'figure.dpi': 96})


def read_data(fp):
    all_data = []
    lines = open(fp, 'r').readlines()
    for line in lines:
        ns = line.strip().split()
        ns = [float(n) for n in ns]
        all_data.append(ns)
    all_data = sorted(all_data, key=lambda x: x[0])
    all_data = zip(*all_data)
    all_data = [list(line) for line in all_data]
    return all_data


def plot_bar(all_data):
    width = 1
    N = len(all_data)
    step = (N + 1) * width

    bars = []
    for i, data_y in enumerate(all_data):
        n = len(data_y)
        data_x = np.arange(0, step * n, step) + i * width
        bar = plt.bar(data_x, data_y, width, color=g_colors[i])
        bars.append(bar)

    plt.xlim(xmin=-step, xmax=step * n)
    plt.legend(bars, g_tags, prop={'size': 30}, borderaxespad=0.5)
    plt.xticks([])
    plt.xlabel('binary', size=55, labelpad=15)
    # plt.ylabel('correct match rate')
    plt.subplots_adjust(left=0.04, right=0.98, bottom=0.04, top=0.98)


def plot_curve(all_data):
    for i, data in enumerate(all_data):
        n = len(data)
        ind = np.arange(n)
        plt.plot(ind, data, color=g_colors[i], label=g_tags[i], linewidth=4, marker=g_markers[i], markersize=10)

    leg = plt.legend(prop={'size': 60}, markerscale=4, borderaxespad=0.5)
    for line in leg.get_lines():
        line.set_linewidth(6)
    plt.xticks([])
    plt.xlabel('binary', size=65, labelpad=15)
    plt.subplots_adjust(left=0.04, right=0.98, bottom=0.04, top=0.98)


def plot_cdf(all_data):
    def _gen_cdf(all_data):
        number = 101
        cdf_data = []
        for data in all_data:
            ecdf = sm.distributions.ECDF(data)
            x = np.linspace(0, 9.0, 101)
            y = ecdf(x)
            y = [_y * 100 for _y in y]
            cdf_data.append((x, y))
        return cdf_data

    cdf_data = _gen_cdf(all_data)

    for i, (x, y) in enumerate(cdf_data):
        plt.plot(x, y, color=g_colors[i], linewidth=8)  # , marker=g_markers[i], markersize=10)

    # leg = plt.legend(prop={'size': 60}, borderaxespad=0.5)  # , markerscale=2)
    # for line in leg.get_lines():
    #     line.set_linewidth(10)

    # plt.xticks([])
    # plt.xlim(xmin=0.2)
    # plt.ylim(ymin=0, ymax=1)
    plt.xlabel('Time (sec)', size=65, labelpad=15)
    plt.ylabel('Percentage', size=65, labelpad=15)
    plt.subplots_adjust(left=0.12, right=0.98, bottom=0.1, top=0.98)


def main():
    # fp = './data/5.93_O1_8.30_O1'
    # fp = './data/6.4_O1_8.30_O1'
    # fp = './data/7.6_O1_8.30_O1'
    # fp = './data/8.1_O1_8.30_O1'
    # for fp in ['./data/5.93_O1_8.30_O1', './data/6.4_O1_8.30_O1', './data/7.6_O1_8.30_O1', './data/8.1_O1_8.30_O1']:
    data_dir = './data'
    # fns = os.listdir(data_dir)

    # ['593_830', '64_830', '76_830', '81_830', '5_93_O0_O3', '5_93_O1_O3', '5_93_O2_O3', '6_4_O0_O3', '6_4_O1_O3', '6_4_O2_O3', '7_6_O0_O3', '7_6_O1_O3', '7_6_O2_O3', '8_1_O0_O3', '8_1_O1_O3', '8_1_O2_O3', '8_30_O0_O3', '8_30_O1_O3', '8_30_O2_O3']

    all_data = read_data("../../artifacts/time.txt")
    # pprint(all_data)

    # plot_bar(all_data)
    # plot_curve(all_data)
    plt.clf()
    plot_cdf(all_data)

    plt.savefig('./time-cdf.pdf')


if __name__ == '__main__':
    main()