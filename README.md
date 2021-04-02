This repository contains binaries of xmrig miner (see https://github.com/xmrig/xmrig) built to work on more platforms and bundled with helper Windows/Linux/PI setup scripts that automatically configure them to work with **stratum+tcp://xmr.f2pool.com** mining pool.

## Download

* Binary releases: https://github.com/alterhu2020/xmrig_setup/releases
* Git tree: https://github.com/alterhu2020/xmrig_setup.git
  * Clone with git clone https://github.com/alterhu2020/xmrig_setup.git 🔨 Build instructions.

### 2.1 windows

If you're intersting to compile this raspberry build from source code: `https://github.com/xmrig/xmrig`, take a look at the guideline:
[Windows编译安装脚本xmrig零抽水](https://code.pingbook.top/blog/setup/bitcoin-mining.html#windows%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85%E8%84%9A%E6%9C%ACxmrig%E9%9B%B6%E6%8A%BD%E6%B0%B4)

This build had bundled the script for windows miner with **donate: 0%**, just run below command:

```
> windows/setup_xmrig_miner.bat <Your wallet address>
```
This script will download the required file from server, if you don't want to download it, just use the offline version in folder: `offline_miner_setup` and run the 
script as below:

```
> unzip offline_miner_setup.zip
> windows/offline_miner_setup/setup_xmrig_miner_offline.bat <Your wallet address>
```

The result:
![Windows_result](https://raw.githubusercontent.com/alterhu2020/StorageHub/master/img/20200711183215-2020-07-11.png)

### 2.2 Linux

If you're intersting to compile this linux build from source code: `https://github.com/xmrig/xmrig`, take a look at the guideline:
[linux编译安装脚本xmrig零抽水](https://code.pingbook.top/blog/setup/bitcoin-mining.html#linux%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85%E8%84%9A%E6%9C%ACxmrig%E9%9B%B6%E6%8A%BD%E6%B0%B4)

This build had bundled the script for linux miner with **donate: 0%**, just run below command:

```
$ ./linux/setup_xmrig_miner.sh <Your wallet address>
```

The result:
![Linux_result](https://raw.githubusercontent.com/alterhu2020/StorageHub/master/img/20200711182612-2020-07-11.png)

## 2.3 Raspberry PI 4 

If you're intersting to compile this raspberry build from source code: `https://github.com/xmrig/xmrig`, take a look at the guideline:
[树莓派如何编译xmrig零抽水](https://code.pingbook.top/blog/setup/bitcoin-mining.html#%E6%A0%91%E8%8E%93%E6%B4%BE%E5%A6%82%E4%BD%95%E7%BC%96%E8%AF%91xmrig%E9%9B%B6%E6%8A%BD%E6%B0%B4)

This build had bundled the script for raspberry miner with **donate: 0%**, just run below command:

```
$ ./pi/setup_xmrig_miner.sh <Your wallet address>
```

The result:
![PI_result](https://raw.githubusercontent.com/alterhu2020/StorageHub/master/img/20200711220304-2020-07-11.png)


## Donations

 If you feel like giving me a small donation for my time spent and sharing this binary and my findings, please feel free to donate to one of my wallets:
* XMR: 84YikQQa894Grw3Kcsb3GbDaKsY2CciqUC4xeBCPQWqggncrQUNBtV4dZDwdQAcfrTZ32GijR8Ws7EuuAC5bhJG7FdTHFfy


## Credits

* Official xmrig repo: https://github.com/xmrig/xmrig
* Guide that helped me in compiling gcc on Raspberry Pi: 
1. https://github.com/xmrig/xmrig/issues/1446
2. https://code.pingbook.top/blog/setup/bitcoin-mining.html#%E6%A0%91%E8%8E%93%E6%B4%BE%E5%A6%82%E4%BD%95%E7%BC%96%E8%AF%91xmrig%E9%9B%B6%E6%8A%BD%E6%B0%B4


## Contacts

- alterhu2020@gmail.com
