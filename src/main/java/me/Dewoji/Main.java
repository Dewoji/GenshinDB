package me.Dewoji;

import me.Dewoji.artifact.ArtifactDataAccessObject;
import me.Dewoji.character.CharacterDataAccessObject;
import me.Dewoji.weapon.WeaponDataAccessObject;

import java.sql.SQLException;
import java.util.Scanner;
import java.util.logging.Logger;

public class Main {
    private static final Logger L = Logger.getLogger(Main.class.getName());

    private static final ArtifactDataAccessObject INSTANCE_A = new ArtifactDataAccessObject();
    private static final CharacterDataAccessObject INSTANCE_C = new CharacterDataAccessObject();
    private static final WeaponDataAccessObject INSTANCE_W = new WeaponDataAccessObject();

    public static void main(String[] args) {
        Scanner s = new Scanner(System.in);
        while (s.hasNext()) {
            switch (s.nextLine()) {
                case "insertA" -> {
                    try {
                        ConsoleUtils.saveArtifactToDb(INSTANCE_A);
                    } catch (SQLException e) {
                        e.printStackTrace(); //TODO proper logging
                    }
                }
                case "equipA" -> {
                    try {
                        ConsoleUtils.equipArtifact(INSTANCE_A);

                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
                case "getBestA" -> {
                    try {
                        ConsoleUtils.getBestArtifactFromMainStat(INSTANCE_A);
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
                case "showJ" -> {
                    try {
                        ConsoleUtils.getJewels(INSTANCE_A);
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
                case "insertC" -> {
                    try {
                        ConsoleUtils.saveCharacter(INSTANCE_C);
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
                case "insertW" -> {
                    try {
                        ConsoleUtils.saveWeapon(INSTANCE_W);
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
                case "equipW" -> {
                    try {
                        ConsoleUtils.equipWeapon(INSTANCE_W);
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
