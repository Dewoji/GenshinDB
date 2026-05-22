package me.Dewoji.character;

import me.Dewoji.weapon.weaponEnums.WeaponType;

public record Character(
        String name,
        int level,
        int constellation,
        WeaponType canHandle
) {
    public Character {
        if (level > 90 || level < 0)
            throw new IllegalArgumentException("Character level can be only beetween 0 and 90.");
        if (constellation < 0 || level > 6)
            throw new IllegalArgumentException("Character constellation can be only between 0 and 6.");
    }


}
