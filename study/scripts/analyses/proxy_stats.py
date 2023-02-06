# Python program to read
# json file


import json
import os

chain_names = ['ethereum', 'arbitrum', 'avalanche', 'bsc', 'celo', 'fantom', 'optimism', 'polygon']



transparent_counter = 0
feature_counts = {}


def extract_features(filepath: str):
   feature_counts[chain]['total_files'] += 1
   # Opening JSON file
   o = open(filepath)

   # returns JSON object as
   # a dictionary
   data: dict = json.load(o)
   o.close()
   if not data['success'] and "proxies_and_implementations/" in filepath:
      filepath = filepath.replace("proxies_and_implementations/", "proxies/")
      o = open(filepath)
      data: dict = json.load(o)
      o.close()
   # Iterating through the json
   # list
   if data['success']:
      if 'detectors' in dict(data['results']).keys():
         found_feature = False
         for i in range(len(data['results']['detectors']), 0, -1):
            result = data['results']['detectors'][i-1]
            features: dict = result['features']
            if 'transparent' in features.keys():
               if features['transparent']:
                  feature_counts[chain]['transparent'] += 1
                  found_feature = True
            if 'eip_1967' in features.keys():
               if features['eip_1967']:
                  feature_counts[chain]['eip_1967'] += 1
                  found_feature = True
            if 'inherited_storage' in features.keys():
               if features['inherited_storage']:
                  feature_counts[chain]['inherited_storage'] += 1
                  found_feature = True
            if 'unstructured_storage' in features.keys():
               if features['unstructured_storage']:
                  feature_counts[chain]['unstructured_storage'] += 1
                  found_feature = True
            if 'eip_1822' in features.keys():
               if features['eip_1822']:
                  feature_counts[chain]['eip_1822'] += 1
                  found_feature = True
            if 'beacon' in features.keys():
               if features['beacon']:
                  feature_counts[chain]['beacon'] += 1
                  found_feature = True
            if 'diamond_storage' in features.keys():
               if features['diamond_storage']:
                  feature_counts[chain]['diamond_storage'] += 1
                  found_feature = True
            if 'eip_2535' in features.keys():
               if features['eip_2535']:
                  feature_counts[chain]['eip_2535'] += 1
                  found_feature = True
            if 'eip_1538' in features.keys():
               if features['eip_1538']:
                  feature_counts[chain]['eip_1538'] += 1
                  found_feature = True
            if 'eternal_storage' in features.keys():
               if features['eternal_storage']:
                  feature_counts[chain]['eternal_storage'] += 1
                  found_feature = True
            if 'registry' in features.keys():
               if features['registry']:
                  feature_counts[chain]['registry'] += 1
                  found_feature = True
            if 'time_delay' in features.keys():
               if features['time_delay']['has_delay']:
                  feature_counts[chain]['time_delay'] += 1
                  found_feature = True
            if 'can_toggle_delegatecall' in features.keys():
               if features['can_toggle_delegatecall']:
                  feature_counts[chain]['can_toggle_delegatecall'] += 1
                  found_feature = True
            if 'immutable_functions' in features.keys():
               if features['immutable_functions'] and (any(key.startswith("erc")
                                                for key in features["immutable_functions"].keys())
                                             or "containing_delegatecall"
                                             in features["immutable_functions"].keys()):
                  feature_counts[chain]['partially_upgradeable'] += 1
                  found_feature = True
            if 'can_remove_upgradeability' in features.keys():
               if features['can_remove_upgradeability']:
                  feature_counts[chain]['removable_upgradeability'] += 1
                  found_feature = True
            if 'master_copy_coupling' in features.keys():
               if features['master_copy_coupling']:
                  feature_counts[chain]['MasterCopy/Singleton'] += 1
                  found_feature = True
            if 'compatibility_checks' in features.keys():
               if features['compatibility_checks']['has_all_checks'] is False:
                  feature_counts[chain]['missing_compatibility_checks'] += 1
                  found_feature = True
            if found_feature:
               break
   else:
      feature_counts[chain]['error'] += 1


for chain in chain_names:
   feature_counts[chain] = {
      "total_files": 0,
      "error": 0,
      "transparent": 0,
      "eip_1967": 0,
      "inherited_storage": 0,
      "unstructured_storage": 0,
      "eip_1822": 0,
      "beacon": 0,
      "diamond_storage": 0,
      "eip_2535": 0,
      "eternal_storage": 0,
      "registry": 0,
      "time_delay": 0,
      "can_toggle_delegatecall": 0,
      "partially_upgradeable": 0,
      "removable_upgradeability": 0,
      "missing_compatibility_checks": 0,
      "MasterCopy/Singleton": 0,
      "eip_1538": 0,
   }
   path = f"../../data/proxies_with_uschunt_results/{chain}/mainnet/proxies/"
   fname = []
   for root,d_names,f_names in os.walk(path):
      # print(f_names)
      for f in f_names:
         file_path = os.path.join(root, f)
         if os.path.exists(file_path.replace("/proxies/", "/proxies_and_implementations/")):
            file_path = file_path.replace("/proxies/", "/proxies_and_implementations/")
         if f.endswith('.json') and os.path.exists(file_path.replace(".json", ".sol")):
            extract_features(file_path)

   print(f"{chain}: {feature_counts[chain]}")


   out = open(path + "statistics.json", "w")
   json_str = str(feature_counts).replace("'", '"')
   out.write(json.dumps(json.loads(json_str), indent=4, sort_keys=True))
   out.close()
