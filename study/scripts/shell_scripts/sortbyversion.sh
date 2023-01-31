#!/bin/sh

get_version () {
    path=$1
    ver=""
    ver1=$(cat $path | grep -oP -m 1 '(?<=pragma solidity).*(?=;)' | sed 's/\ \./\./g')
    ver2=$(cat $path | grep -oP '(?<=pragma solidity).*(?=;)' | tail -1 | sed 's/\ \./\./g')
    case "$ver1" in *" "*)
        ver1=$(echo $ver1 | cut -d' ' -f1)
    esac
    case "$ver2" in *" "*)
        ver2=$(echo $ver2 | cut -d' ' -f1)
    esac
    mid1=$(echo $ver1 | grep -o -P '(?<=0.).*(?=\.)')
    mid2=$(echo $ver2 | grep -o -P '(?<=0.).*(?=\.)')
    echo "$mid1"
    last1=$(echo ${ver1#*$mid1.} | sed 's/ *//')
    last2=$(echo ${ver2#*$mid2.} | sed 's/ *//')
    if [ $mid1 -gt $mid2 ]; then
        ver=$ver1
    elif [ $mid1 -lt $mid2 ]; then
        ver=$ver2
    elif [ $mid1 -eq $mid2 ]; then
        if [ "$last1" -gt "$last2" ]; then
            ver=$ver1
        else
            ver=$ver2
        fi
    fi
    case "$ver" in
        "<="*)
            ver=$(echo "$ver" | sed 's/<=//g')
            ;;
        ">="*)
            ver=$(echo "$ver" | sed 's/>=//g')
            ;;
        '^'*)
            ver=$(echo "$ver" | sed 's/^^//g' )
            ;;
        '='*)
            ver=$(echo "$ver" | sed 's/=//g')
            ;;
        '<'*)
            mid=$(echo "$ver" | grep -o -P '(?<=0.).*(?=\.)')
            last=$(echo "${ver#*$mid.}" | sed 's/ *//')
            if [ "$last" -eq "0" ]; then
                mid="$((mid-1))"
            else
                last="$((last-1))"
            fi
            ver="0.${mid}.${last}"
            ;;
        '>'*)
            mid=$(echo "$ver" | grep -o -P '(?<=0.).*(?=\.)')
            last=$(echo "${ver#*$mid.}" | sed 's/ *//')
            if [ "$last" -eq "99" ]; then
                mid="$((mid+1))"
                last="0"
            else
                last="$((last+1))"
            fi
            ver="0.${mid}.${last}"
            ;;
    esac
    case "$ver" in *" "*)
        ver=$(echo "${ver%% *}")
    esac
    echo $ver
}

walk_dir () {
    version=""
    address=""
    orig=$3
    for pathname in "$1"/*; do
        if [ -d "$pathname" ]; then
            dir=$(basename $pathname)
            case "$dir" in
                "0."*)
                    continue
                    ;;
                *)
                    walk_dir "$pathname" "$dir" "$orig"
            esac
        elif [ -e "$pathname" ]; then
            dir=$2
            echo "$pathname"
            case "$pathname" in *.sol)
                version=$(get_version "$pathname")
                name=${pathname#*_}
                tmp=${pathname%*_*}
                address=${tmp#*/$dir/$dir*}
                mkdir -p "$orig"/sorted/"$version"/"$dir""$address"_"$name"
                # echo "$version"
                echo "$orig"/sorted/"$version"/"$dir""$address"_"$name"
                cp "$pathname" "$orig"/sorted/"$version"/"$dir""$address"_"$name"
            esac
        fi
    done
}

#DIR=./arbitrum/contracts/mainnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./arbitrum/contracts/testnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./avalanche/contracts/mainnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./avalanche/contracts/testnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./bsc/contracts/mainnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./bsc/contracts/testnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./celo/contracts/mainnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./fantom/contracts/mainnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./optimism/contracts/mainnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./polygon/contracts/mainnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./polygon/contracts/mumbai
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./tron/contracts/mainnet
#walk_dir "$DIR" "$DIR" "$DIR"

#DIR=./ethereum/contracts/mainnet
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./ethereum/contracts/kovan
#walk_dir "$DIR" "$DIR" "$DIR"

DIR=./ethereum/contracts/goerli
walk_dir "$DIR" "$DIR" "$DIR"

#DIR=./ethereum/contracts/rinkeby
#walk_dir "$DIR" "$DIR" "$DIR"
#
#DIR=./ethereum/contracts/ropsten
#walk_dir "$DIR" "$DIR" "$DIR"