package me.Dewoji.weapon;

import me.Dewoji.weapon.weaponEnums.WeaponStatType;
import me.Dewoji.weapon.weaponEnums.WeaponType;

public record Weapon(
        String name,
        int rarity,
        int refinement,
        int level,
        WeaponType weaponType,
        WeaponStatType statType,
        double statValue,
        String character
) {

}
