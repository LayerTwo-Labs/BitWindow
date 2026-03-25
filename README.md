# BitWindow

BitWindow is an alternative frontend for a full node. It serves as your portal into Bitcoin!

# Why BitWindow?

BitWindow is superior to Core in many ways:

* Looks much better.
* Crams more stuff onto the screen, per pixel.
* **BIP-300 Aware** -- Tracks special L2s called sidechains.
* **Yet more cool stuff** -- Paper cheques, built-in block-explorer, hash calculator, paranoid-mode.
* **Even cooler stuff than that**:
* * **Coin News** -- A revolution in media.
* * **Multisig lounge** -- User-friendly multisig with automatic backup/restore.
* * **Deniability** -- Privacy tools.
* And much, much more!

In particular, BitWindow is [CUSF](https://bip300cusf.com/)-aware -- it can implement any soft fork on Bitcoin, without modifying Bitcoin Core at all.

Furthermore, we use the (superior) BDK wallet -- allowing for Bip-39 wordlists, PayNyms, etc.

Finally, BitWindow is **modular**. You may fork BitWindow and change anything you like! We could have 5 or 6 different competing BitWindows -- and we should. In contrast, the **qt frontend** in Bitcoin Core is tightly connected to the Bitcoin Core source code -- in order to modify it, you must get a pull request through their bureaucracy. Then you have to release a whole competing full node. Very few people would be willing to do that -- or trust it. In contrast, BitWindow will just download **the real Bitcoin Core** from bitcoin.org, and use it under the hood (via bitcoind and bitcoin-cli). It is a purely optional, cosmetic frontend!

# Where is the code?

The real **BitWindow Repository** is the "bitwindow" subdirectory of [https://github.com/LayerTwo-Labs/drivechain-frontends/tree/master/bitwindow](https://github.com/LayerTwo-Labs/drivechain-frontends/tree/master/bitwindow).

Sorry if that was confusing.

In general, this [tiny text file](https://drivechain.info/dev.txt) will help you find your way around.
