package me.Dewoji.artifact;

import me.Dewoji.artifact.statEnums.MainstatType;
import me.Dewoji.artifact.statEnums.SlotType;

import java.util.List;
import java.util.Objects;

public record Artifact(
        String set,
        int level,
        int rarity,
        SlotType slot,
        MainstatType mainstatType,
        double mainstatValue,
        String equippedBy,
        List<Substat> listOfSubstats
) {
    public Artifact {
        if (listOfSubstats != null) {
            if (listOfSubstats.size() > 4 || listOfSubstats.size() < 3)
                throw new IllegalArgumentException("An Artifact cannot have more than 4 or less than 3 substats.");
            if (listOfSubstats.stream().anyMatch(s -> Objects.equals(s.substatType().getValue(), mainstatType.getValue())))
                throw new IllegalArgumentException("An Artifact cannot have a substat equal to its mainstat.");
        }
    }
}

