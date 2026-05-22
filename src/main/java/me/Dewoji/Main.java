package me.Dewoji;

import me.Dewoji.artifact.ArtifactDataAccessObject;

import java.sql.SQLException;
import java.util.Scanner;
import java.util.logging.Logger;

public class Main {
    private static final Logger L = Logger.getLogger(Main.class.getName());
    private static final ArtifactDataAccessObject instance = new ArtifactDataAccessObject();

    public static void main(String[] args) {
        Scanner s = new Scanner(System.in);
        while (s.hasNext()) {
            switch (s.nextLine()) {
                case "insertA" -> {
                    try {
                        ConsoleUtils.saveArtifactToDb(instance);
                        System.out.println("Artifact saved.");
                    } catch (SQLException e) {
                        L.severe("Molto grave"); //TODO
                    }
                }
                case "equipA" -> {
                    try {
                        ConsoleUtils.equipArtifact(instance);
                        System.out.println("Artifact equipped.");
                    } catch (SQLException e) {
                        throw new RuntimeException(e);
                    }
                }
                case "getBestA" -> {
                    try {
                        ConsoleUtils.getBestArtifactFromMainStat(instance);
                    } catch (SQLException e) {
                        throw new RuntimeException(e);
                    }
                }
                case "showJ" -> {
                    try {
                        ConsoleUtils.getJewels(instance);
                    } catch (SQLException e) {
                        throw new RuntimeException(e);
                    }
                }
            }
        }
    }
}
