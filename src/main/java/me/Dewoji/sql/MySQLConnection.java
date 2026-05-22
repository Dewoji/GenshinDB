package me.Dewoji.sql;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class MySQLConnection {
    public record MySQLConfig(
            String host,
            String port,
            String database,
            String username,
            String password
    ) {
        private static final MySQLConfig DEFAULT = new MySQLConfig(
                "localhost",
                "3306",
                "genshindb",
                "root",
                "nonteladico"
        );
    }

    public MySQLConnection() {
        testConnection();
    }

    public Connection connect() throws SQLException {
        return DriverManager.getConnection(
                "jdbc:mysql://" + MySQLConfig.DEFAULT.host + ":" + MySQLConfig.DEFAULT.port + "/" + MySQLConfig.DEFAULT.database + "?useSSL=false",
                MySQLConfig.DEFAULT.username,
                MySQLConfig.DEFAULT.password
        );

    }

    private void testConnection() {
        try {
            Connection connection = connect();
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace(System.out);
        }
    }
}
