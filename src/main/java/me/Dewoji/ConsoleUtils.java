package me.Dewoji;

import me.Dewoji.artifact.Artifact;
import me.Dewoji.artifact.ArtifactDataAccessObject;
import me.Dewoji.artifact.Jewel;
import me.Dewoji.artifact.Substat;
import me.Dewoji.artifact.statEnums.MainstatType;
import me.Dewoji.artifact.statEnums.SlotType;
import me.Dewoji.artifact.statEnums.SubstatType;
import me.Dewoji.character.Character;
import me.Dewoji.character.CharacterDataAccessObject;
import me.Dewoji.weapon.Weapon;
import me.Dewoji.weapon.WeaponDataAccessObject;
import me.Dewoji.weapon.weaponEnums.WeaponStatType;
import me.Dewoji.weapon.weaponEnums.WeaponType;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class ConsoleUtils {

    private final static Scanner scanner = new Scanner(System.in);

    private static Artifact getArtifact() {

        System.out.println("Insert Set:");
        String set = scanner.nextLine();

        System.out.println("Insert level (0-20):");
        int level = scanner.nextInt();
        scanner.nextLine();

        System.out.println("Insert rarity (1-5):");
        int rarity = scanner.nextInt();
        scanner.nextLine();

        System.out.println("Insert slot:");
        SlotType slot = SlotType.valueOf(scanner.nextLine().toUpperCase());

        System.out.println("Insert mainstat type:");
        MainstatType mainstatType = MainstatType.valueOf(scanner.nextLine().toUpperCase());

        System.out.println("Insert mainstat value");
        double mainStatValue = scanner.nextDouble();
        scanner.nextLine();

        System.out.println("Insert equipped to (press enter if noone):");
        String equippedBy = scanner.nextLine();

        List<Substat> substatList = new ArrayList<>();
        for (int i = 1; i <= 4; i++) {
            System.out.println("Insert " + i + " substat type:");
            String input = scanner.nextLine().toUpperCase().trim();

            if (input.isBlank()) {
                break;
            }

            System.out.println("Insert " + i + " substat value:");
            double d = scanner.nextDouble();
            scanner.nextLine();

            substatList.add(new Substat(SubstatType.valueOf(input), d));
        }

        return new Artifact(set, level, rarity, slot, mainstatType, mainStatValue, equippedBy, substatList);
    }

    public static void saveArtifactToDb(ArtifactDataAccessObject artifactDataAccessObject) throws SQLException {
        artifactDataAccessObject.saveArtifact(getArtifact());
        System.out.println("Artifact saved!");
    }

    public static void equipArtifact(ArtifactDataAccessObject artifactDataAccessObject) throws SQLException {
        System.out.println("Insert Artifact Id:");
        int artifactId = scanner.nextInt();
        scanner.nextLine();

        System.out.println("Insert character Name:");
        String name = scanner.nextLine().trim();

        artifactDataAccessObject.equipArtifactTo(artifactId, name);
        System.out.println("Artifact equipped.");
    }

    public static void getBestArtifactFromMainStat(ArtifactDataAccessObject artifactDataAccessObject) throws SQLException {
        System.out.println("Insert slot type:");
        SlotType slotType = SlotType.valueOf(scanner.nextLine().toUpperCase().trim());

        System.out.println("Insert mainstat type:");
        MainstatType mainstatType = MainstatType.valueOf(scanner.nextLine().toUpperCase().trim());

        System.out.println("Insert substat 1 type:");
        SubstatType s1 = SubstatType.valueOf(scanner.nextLine().toUpperCase().trim());

        System.out.println("Insert substat 2 type:");
        SubstatType s2 = SubstatType.valueOf(scanner.nextLine().toUpperCase().trim());

        artifactDataAccessObject.getBestArtifactFrom(slotType, mainstatType, s1, s2);
    }

    public static void getJewels(ArtifactDataAccessObject artifactDataAccessObject) throws SQLException {
        List<Jewel> jewels = artifactDataAccessObject.getJewels();
        for (Jewel j : jewels) {
            System.out.println(j.toString());
        }
    }

    private static Character getCharacter() {
        System.out.println("Insert character name:");
        String name = scanner.nextLine();

        System.out.println("Insert character level:");
        int level = scanner.nextInt();
        scanner.nextLine();

        System.out.println("Insert character constellation:");
        int constellation = scanner.nextInt();
        scanner.nextLine();

        System.out.println("Insert type of weapon the character can handle:");
        WeaponType weaponType = WeaponType.valueOf(scanner.nextLine().toUpperCase().trim());

        return new Character(name, level, constellation, weaponType);
    }

    public static void saveCharacter(CharacterDataAccessObject characterDataAccessObject) throws SQLException {
        characterDataAccessObject.saveCharacter(getCharacter());
        System.out.println("Character saved!");
    }

    private static Weapon getWeapon() {
        System.out.println("Insert weapon name:");
        String name = scanner.nextLine();

        System.out.println("Insert weapon rarity:");
        int rarity = scanner.nextInt();
        scanner.nextLine();

        System.out.println("Insert weapon refinement:");
        int refinement = scanner.nextInt();
        scanner.nextLine();

        System.out.println("Insert weapon type:");
        WeaponType weaponType = WeaponType.valueOf(scanner.nextLine().toUpperCase().trim());

        System.out.println("Insert weapon stat type:");
        WeaponStatType weaponStatType = WeaponStatType.valueOf(scanner.nextLine().toUpperCase().trim());

        System.out.println("Insert weapon stat value:");
        double weaponStatValue = scanner.nextDouble();
        scanner.nextLine();

        System.out.println("Insert character that has this weapon equipped (press enter if noone):");
        String character = scanner.nextLine();

        return new Weapon(name, rarity, refinement, weaponType, weaponStatType, weaponStatValue, character);
    }

    public static void saveWeapon(WeaponDataAccessObject weaponDataAccessObject) throws SQLException {
        weaponDataAccessObject.saveWeapon(getWeapon());
        System.out.println("Weapon saved!");
    }

    public static void equipWeapon(WeaponDataAccessObject weaponDataAccessObject) throws SQLException {
        System.out.println("Insert weapon Id:");
        int artifactId = scanner.nextInt();
        scanner.nextLine();

        System.out.println("Insert character Name:");
        String name = scanner.nextLine().trim();

        weaponDataAccessObject.equipWeapon(artifactId, name);
        System.out.println("Weapon equipped.");
    }
}
