package me.Dewoji.artifact.statEnums;

public enum MainstatType {
    HP("HP"),
    HP_PERCENT("HP%"),
    ATK("ATK"),
    ATK_PERCENT("ATK%"),
    DEF_PERCENT("DEF%"),
    EM("EM"),
    ER_PERCENT("ER%"),
    PHYSICAL_DMG("PHYSICAL_DMG%"),
    PYRO_DMG("PYRO_DMG%"),
    HYDRO_DMG("HYDRO_DMG%"),
    ELECTRO_DMG("ELECTRO_DMG%"),
    CRYO_DMG("CRYO_DMG%"),
    DENDRO_DMG("DENDRO_DMG%"),
    GEO_DMG("GEO_DMG%"),
    ANEMO_DMG("ANEMO_DMG%"),
    CRIT_RATE("CRIT_RATE%"),
    CRIT_DMG("CRIT_DMG%"),
    HEALING_BONUS("HEALING_BONUS%");

    private final String value;

    MainstatType(String value) {
        this.value = value;
    }

    public String getValue() {
        return this.value;
    }

    public static MainstatType from(String value) {
        for(MainstatType m : MainstatType.values()) {
            if(m.getValue().equalsIgnoreCase(value))
                return m;
        }
        return null;
    }
}
