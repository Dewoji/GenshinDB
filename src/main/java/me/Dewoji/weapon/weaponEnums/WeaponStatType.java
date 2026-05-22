package me.Dewoji.weapon.weaponEnums;

public enum WeaponStatType {
    HP_PERCENT("HP%"),
    ATK_PERCENT("ATK%"),
    DEF_PERCENT("DEF%"),
    EM("EM"),
    ER("ER%"),
    PHYSICAL_DMG("PHYSICAL_DMG%"),
    CRIT_RATE("CRIT_RATE%"),
    CRIT_DMG("CRIT_DMG%");

    private final String value;

    WeaponStatType(String value) {
        this.value = value;
    }

    public String getValue() {
        return this.value;
    }
}
