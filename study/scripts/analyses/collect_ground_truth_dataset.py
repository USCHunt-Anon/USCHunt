import os
import shutil


with open("/home/webthethird/Ethereum/uschunt-slither/study/data/ground_truth_files.csv", "r") as file:
    path_list = file.readlines()
not_found = []
count = 0
root_path = "/home/webthethird/Ethereum/uschunt-slither/study/data/proxies_with_uschunt_results/ethereum/mainnet/proxies/"
for path in path_list:
    path = path.replace("\n", "").strip()
    if path.endswith("AndImpl.sol"):
        file_path = root_path.replace("/proxies/", "/proxies_and_implementations/") + path.replace("AndImpl.sol", ".sol")
        if not os.path.exists(file_path):
            file_path = root_path + path.replace("AndImpl.sol", ".sol")
    else:
        file_path = root_path + path
    if not os.path.exists(file_path):
        not_found.append(path)
    else:
        count += 1
        output_path = file_path.replace("/proxies_and_implementations/", "/proxies/").replace("proxies_with_uschunt_results/ethereum/mainnet/proxies", "ground_truth").replace("AndImpl.sol", ".sol")
        print(f"Copying {path} to {output_path}")
        try:
            shutil.copytree(file_path, output_path)
        except FileExistsError:
            continue

dirs_not_found = [path.rsplit("/", maxsplit=1)[1].replace("AndImpl.sol", ".sol") for path in not_found]
for root, d_names, f_names in os.walk(root_path):
    for dir_name in d_names:
        if dir_name in dirs_not_found:
            count += 1
            dir_path = os.path.join(root, dir_name)
            if os.path.exists(dir_path.replace("/proxies/", "/proxies_and_implementations/")):
                dir_path = dir_path.replace("/proxies/", "/proxies_and_implementations/")
            output_path = dir_path.replace("/proxies_and_implementations/", "/proxies/").replace(
                "proxies_with_uschunt_results/ethereum/mainnet/proxies", "ground_truth").replace("AndImpl.sol", ".sol")
            dirs_not_found.remove(dir_name)
            try:
                shutil.copytree(dir_path, output_path)
            except FileExistsError:
                continue
print(f"Found {count} files")
print("Not found:")
for path in dirs_not_found:
    print(path)

