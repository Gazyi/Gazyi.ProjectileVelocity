# Gazyi.ProjectileVelocity
Yet another Northstar mod that converts Pilot and Titan hitscan weapons to projectiles (with exception of Charge Rifle, Laser Shot and Laser Core). Inspired by [**Daar375's hitscan to projectile mod**](https://github.com/Daar375/Daar375ModularBalancePatch/tree/main/Daar375.HitscanToProjectile).

Key differencies:
- Uses keyvalue patching instead of replacing weapon scripts to improve compability with other mods.
- Doesn't crash client when AI Titan or NPC is shooting.
- AI Titans and NPCs have muzzleflash and shoot sound.
- Unique velocity and gravity drop for each converted weapon.

| Weapon  | Projectile velocity | Projectile gravity |
| ------------- | ------------- | ------------- |
| Alternator | 6610 | 0.2 |
| RE-45 Autopistol | 6610 | 0.09 |
| C.A.R. | 6270 | 0.2 |
| Longbow DMR | 10340 | 0.25 |
| X-55 Devotion | 11355 | 0.25 |
| G2A5 Battle Rifle | 10170 | 0.25 |
| Hemlok BF-R | 9320 | 0.23 |
| Volt | 7965 | 0.15 |
| Spitfire MK2 | 9325 | 0.25 |
| R97-CN SMG | 7120 | 0.2 |
| R-201 | 9830 | 0.23 |
| R-101C | 9830 | 0.23 |
| Hammond P2016 | 6270 | 0.09 |
| EVA-8 Shotgun | 5425 | 0.18 |
| Smart Pistol MK6 | 6270 | 0 |
| V-47 Flatline | 8135 | 0.23 |
| B3 Wingman V2 | 6100 | 0.09 |
| XO16A2 Chaingun | 12000 | 0.25 |
| Predator Cannon (Primary attacks) | 12000 | 0.25 |
| Predator Cannon (Short Range Power Shot) | 6000 | 0.25 |

TODO:
- Balancing changes.
- Better particles.

Issues:
- Smart Pistol spawns explosion effects on impact (Probably because it uses "homing_missile" type of smart ammuntion).
