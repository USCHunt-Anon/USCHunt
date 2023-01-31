#!/bin/sh

dir_name="proxies"

walk_dir () {
    version=""
    last_version="$2"
    address=""
    for pathname in "$1"/*; do
        if [ -d "$pathname" ]; then
            walk_dir "$pathname" "$last_version"
        elif [ -e "$pathname" ]; then
            case "$pathname" in *.sol)
                echo ${pathname}
                tmp=${pathname#*${dir_name}//}
                echo ${tmp}
                version=$(echo ${tmp%%/${tmp#*/}})
                echo ${version}
                atmp=${tmp#*$version/}
                echo ${atmp}
                address=$(echo ${atmp%%_${atmp#*_}})
                echo ${address}
                resultpath=${pathname%.sol}
                rm -f "$resultpath"-time.txt
#                rm -f "$resultpath".json
                name=${resultpath#*$address/}
                echo ${name}
                if [ "$version" != "$last_version" ]; then
                    last_version="$version"
                    echo ${last_version}
                    solc-select install "$version"
                fi
                solc-select use "$version"
                # slither-check-upgradeability "$pathname" "$name" --json "$resultpath"-check-proxy.json
                time -o "$resultpath"-time.txt slither "$pathname" --detect proxy-patterns 2>"$resultpath"-err.txt
            esac
        fi
    done
}

DIR=$HOME/Documents/ethereum/smart-contract-sanctuary/ethereum/contracts/mainnet/${dir_name}/
walk_dir "$DIR" "0"


### to move all results which were flagged as proxies
# grep -lr '"upgradeable":' | sed 's/.json/.sol/g' | xargs -I{} cp --parents "{}" ../proxies/
# grep -lr '"upgradeable":' | sed 's/.json/.txt/g' | xargs -I{} cp --parents "{}" ../proxies/
# grep -lr '"upgradeable":' | xargs -I{} cp --parents "{}" ../proxies/
#
#
### to move all results which were flagged as upgradeable proxies
# grep -lr '"upgradeable": true' | sed 's/.json/.sol/g' | xargs -I{} cp --parents "{}" ../upgradeable_proxies/
# grep -lr '"upgradeable": true' | sed 's/.json/.txt/g' | xargs -I{} cp --parents "{}" ../upgradeable_proxies/
# grep -lr '"upgradeable": true' | xargs -I{} cp --parents "{}" ../upgradeable_proxies/
#
### to move all results which were flagged as maybe upgradeable, and which don't contain a true result
# grep -lr '"upgradeable": "maybe"' | xargs -I{} grep -Lr '"upgradeable": true' | sed 's/.json/.sol/g' | xargs -I{} cp --parents "{}" ../upgradeable_proxies/
# grep -lr '"upgradeable": "maybe"' | xargs -I{} grep -Lr '"upgradeable": true' | sed 's/.json/.txt/g' | xargs -I{} cp --parents "{}" ../upgradeable_proxies/
# grep -lr '"upgradeable": "maybe"' | xargs -I{} grep -Lr '"upgradeable": true' | xargs -I{} cp --parents "{}" ../upgradeable_proxies/
#
# grep -lr '"error": null' | sed 's/.json/.sol/g' | xargs -I{} cp --parents "{}" ../no_errors/
# grep -lr '"error": null' | sed 's/.json/.txt/g' | xargs -I{} cp --parents "{}" ../no_errors/
# grep -lr '"error": null' | xargs -I{} cp --parents "{}" ../no_errors/
