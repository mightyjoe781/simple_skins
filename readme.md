Simple Skins [Redo]

Note : This is a fork of simple_skins mod created by TenPlus1, it offers
several improvements over the old mod and comes with 800+ predownloaded skins.
Preview feature requires clients 5.4+. Works fine with both multicraft and minetest.
Completely tested on sfinv, unified_inventory


Simple Skins mod for Minetest uses SFInv, Inventory Plus or Unified Inventory mods when
available to allow players to select a skin/texture from the list.

https://forum.minetest.net/viewtopic.php?id=9100

Change log:

- 1.1 - Crash When formspec is skewed due to weird naming of meta details
- 1.0 - Now anything above `upper_limit` won't be scanned and above `skin_limit` won't appear in inventory.
- 0.9 - Added Unified Inventory support (thanks Opvolger)
- 0.8 - Added player model preview when viewing formspec (Minetest 5.4 dev only)
- 0.7 - Add some error checks, improve /setskin and tweak & tidy code
- 0.6 - Updated to use Minetest 0.4.16 functions
- 0.5 - Added compatibility with default sfinv inventory, disabled /skin command for now
- 0.4 - Added /skin command to set player skin, no longer dependent on Inventory+, also /setskin command for server admin to set custom skins for player.
- 0.3 - Now works with Minetest 0.4.10+
- 0.2 - Added 3D_Armor mod compatibility
- 0.1 - Added addi's changes to highlight selected skin on list (thanks)
- 0.0 - Initial release

Further Improvements
- When preview is disabled shift list formspec to side of screen and change camera to front third person view as to see the changes being applied. "Nicos servers have it but did not made the code public."
- Add a downloader script
- Improve the convertor script to allow converting even minecraft skins
- Fix some issues in meta fixer script. ( need to removed or merged into downloader script)
