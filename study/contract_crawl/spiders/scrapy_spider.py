import scrapy

import requests
import json
# # from urllib.request import urlopen, Request
# import urllib
# from .google_url_shortner import GooglException
import os


class ContractsSpider(scrapy.Spider):
    name = 'contracts'
    allowed_domains = ['etherscan.io', 'arbiscan.io', 'snowtrace.io', 'bscscan.com', 'celoscan.io',
                       'ftmscan.com', 'optimistic.etherscan.io', 'polygonscan.com']
    chain_names = ['ethereum', 'arbitrum', 'avalanche', 'bsc', 'celo', 'fantom', 'optimism', 'polygon']
    #start_urls = ['https://etherscan.io/contractsVerified']
    addresses = []
    data: dict = {"totals": {"count": 0, "native_balance": 0, "native_value": 0, "token_value": 0}}
    # ethereum_path = "/home/USCHunt/Documents/ethereum/smart-contract-sanctuary/ethereum/contracts/mainnet"
    # proxy_dir = "/proxies/"
    price = 0.75
    # price = 302.17
    i = 7
    domain_name = allowed_domains[i]
    chain_name = chain_names[i]
    proxies_path = f"/home/USCHunt/Documents/ethereum/smart-contract-sanctuary/" \
                   f"{chain_name}/contracts/mainnet/proxies/"

    def start_requests(self):

        # Loop for all pages in the table of verified smart contracts in EtherScan
        # urls = ['https://etherscan.io/contractsVerified/' + format(i) + "?filter=opensourcelicense"
        #        for i in range(1, 400, 1)]  # 1685
        # urls = ['https://etherscan.io/searchcontractlist?q=function&a=all&ps=100&p=' + format(i)
        #     for i in range(1, 500, 1)] # contract search for "function" (appears in all contracts) 1585 pages 100 each
        # Loop over all upgradeable proxies (including "maybe" cases) to compile a list of addresses to query
        # for proxy_dir in self.proxy_dirs:

        # for i in range (1, len(self.chain_names)):

        for root, d_names, f_names in os.walk(self.proxies_path):
            for file_name in f_names:
                if file_name.endswith(".sol"):
                    proxy_address = "0x" + file_name.split("_")[0]
                    self.addresses.append(proxy_address)
        urls = [f'https://{self.domain_name}/address/' + address for address in self.addresses]
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse)

    def parse(self, response):
        address = response.css('#mainaddress *::text').get()
        native_balance = float(str(response.css('.card-body').css('.row').xpath('//div[contains(., "Balance:")]')
                                   .css('.col-md-8::text').get()).split()[0].replace(",", ""))
        # print(response.css('.card-body').css('.row').xpath('//div[contains(., "Balance:")]')
        #                            .css('.col-md-8::text').get())
        # native_value = float(str(response.css('.card-body').css('.row').css('.col-md-8')
        #                          .xpath('//div[contains(., "Value:")]/text()').re_first(r'$\s*(.*)'))
        #                      .split()[0].replace("$", "").replace(",", ""))
        native_value = native_balance * self.price
        token_value = float(str(response.xpath('//a[@id="availableBalanceDropdown"]/text()').get(default='0'))
                            .split()[0].replace("$", "").replace(",", "").replace(">", ""))
        print(f'{address}: Native balance: {native_balance}\n'
              f'                                            Native value: ${native_value}\n'
              f'                                            Tokens value: ${token_value}')
        if address not in self.data.keys():
            self.data[address] = {"address": address}
        self.data[address]["native_balance"] = native_balance
        self.data[address]["native_value"] = native_value
        self.data[address]["token_value"] = token_value
        self.data["totals"]["native_balance"] += native_balance
        self.data["totals"]["native_value"] += native_value
        self.data["totals"]["token_value"] += token_value
        self.data["totals"]["count"] += 1

        print(f'Totals: Native balance: {self.data["totals"]["native_balance"]}\n'
              f'        Native value: ${self.data["totals"]["native_value"]}\n'
              f'        Tokens value: ${self.data["totals"]["token_value"]}\n'
              f'        Count: {self.data["totals"]["count"]}')

        out = open(self.proxies_path + "balances.json", "w")
        json_str = str(self.data).replace("'", '"')
        out.write(json.dumps(json.loads(json_str), indent=4, sort_keys=True))
        out.close()

        yield self.data[address]

        # address = response.css('.text-primary::text').extract()  # modified for different css tag on search results page
        # # address = response.css('.hash-tag::text').extract()
        # # address = ['0x9ab630dc20f049f49ed6ca5e034cf6d8b69248ce',]
        # for addr in address:
        #     contract_url = 'https://etherscan.io/address/' +  addr + '#code'
        #
        #     next_page = str(contract_url)
        #     print('next page is ', next_page)
        #     yield scrapy.Request(next_page, self.parse_contract, dont_filter=True, meta={'address': addr})

    def parse_contract(self, response):
        #Extracting the content using css selectors
        address = response.meta['address']
        sourcecode = response.xpath('//pre[@id ="editor"]/text()').extract_first(default='not-found')
        print(sourcecode)
        abi = response.xpath('//pre[@id ="js-copytextarea2"]/text()').extract_first(default='not-found')
        binarycode = response.xpath('//div[@id ="verifiedbytecode2"]/text()').extract_first(default='not-found')
        #content = response.css('.address-tag::text').extract()
        print('parse address' , address)
                
        scraped_info = {
            'address' : address,
            'sourcecode' : sourcecode,
            'abi' : abi,
            'binarycode' : binarycode
        }
        yield scraped_info