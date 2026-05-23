package me.Dewoji.artifact;

import me.Dewoji.artifact.statEnums.MainstatType;
import me.Dewoji.artifact.statEnums.SlotType;

public record Jewel(
        int id,
        String set,
        SlotType slot,
        MainstatType mainstatType,
        double critValue,
        String equippedBy
) {
}
