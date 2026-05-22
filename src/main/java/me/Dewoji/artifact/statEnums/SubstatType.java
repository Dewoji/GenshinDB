package me.Dewoji.artifact.statEnums;

public enum SubstatType {
    HP("HP"),
    HP_PERCENT("HP%"),
    ATK("ATK"),
    ATK_PERCENT("ATK%"),
    DEF("DEF"),
    DEF_PERCENT("DEF%"),
    EM("EM"),
    ER("ER%"),
    CRIT_RATE("CRIT_RATE%"),
    CRIT_DMG("CRIT_DMG%");

    private final String value;

    SubstatType(String value) {
        this.value = value;
    }

    public String getValue() {
        return this.value;
    }
}
