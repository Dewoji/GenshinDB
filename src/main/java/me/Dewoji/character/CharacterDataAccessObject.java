package me.Dewoji.character;

import me.Dewoji.sql.MySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class CharacterDataAccessObject {

    public void saveCharacter(Character c) throws SQLException {
        MySQLConnection mySQLConnection = new MySQLConnection();
        try(Connection connection = mySQLConnection.connect(); PreparedStatement statement = connection.prepareCall("{CALL insertCharacter(?, ?, ?, ?)}")) {
            statement.setString(1, c.name());
            statement.setInt(2, c.level());
            statement.setInt(3, c.constellation());
            statement.setString(4, String.valueOf(c.canHandle()));

            statement.execute();
        }
    }
}
