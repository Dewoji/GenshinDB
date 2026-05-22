package me.Dewoji.weapon;

import me.Dewoji.sql.MySQLConnection;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

public class WeaponDataAccessObject {

    public static void saveWeapon(Weapon w) throws SQLException {
        MySQLConnection mySQLConnection = new MySQLConnection();
        try (Connection connection = mySQLConnection.connect(); CallableStatement statement = connection.prepareCall("{CALL insertWeapon(?, ?, ?, ?, ?, ?, ?)}")) {
            statement.setString(1, w.name());
            statement.setInt(2, w.rarity());
            statement.setInt(3, w.refinment());
            statement.setString(4, String.valueOf(w.weaponType()));
            statement.setString(5, String.valueOf(w.statType()));
            statement.setDouble(6, w.statValue());
            statement.setString(7, w.character());

            statement.execute();
        }
    }

    public static void equipWeapon(int weaponId, String characterName) throws SQLException {
        MySQLConnection mySQLConnection = new MySQLConnection();
        try (Connection connection = mySQLConnection.connect(); CallableStatement statement = connection.prepareCall("{CALL equipWeaponToCharacter(?, ?)}")) {
            statement.setInt(1, weaponId);
            statement.setString(2, characterName);
            statement.execute();
        }
    }
}
