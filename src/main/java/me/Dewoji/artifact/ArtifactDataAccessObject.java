package me.Dewoji.artifact;

import me.Dewoji.artifact.statEnums.MainstatType;
import me.Dewoji.artifact.statEnums.SlotType;
import me.Dewoji.artifact.statEnums.SubstatType;
import me.Dewoji.sql.MySQLConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ArtifactDataAccessObject {

    public void saveArtifact(Artifact a) throws SQLException {
        MySQLConnection mySQLConnection = new MySQLConnection();
        try (Connection connection = mySQLConnection.connect(); CallableStatement statement = connection.prepareCall("{CALL insertArtifact(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            statement.setString(1, a.set());
            statement.setInt(2, a.level());
            statement.setInt(3, a.rarity());
            statement.setString(4, a.slot().name());
            statement.setString(5, a.mainstatType().getValue());
            statement.setDouble(6, a.mainstatValue());
            if (a.equippedBy().isBlank()) {
                statement.setNull(7, Types.VARCHAR);
            } else {
                statement.setString(7, a.equippedBy());
            }

            statement.setString(8, a.listOfSubstats().get(0).substatType().getValue());
            statement.setDouble(9, a.listOfSubstats().get(0).subStatValue());

            statement.setString(10, a.listOfSubstats().get(1).substatType().getValue());
            statement.setDouble(11, a.listOfSubstats().get(1).subStatValue());


            statement.setString(12, a.listOfSubstats().get(2).substatType().getValue());
            statement.setDouble(13, a.listOfSubstats().get(2).subStatValue());

            if (a.listOfSubstats().size() < 4) {
                statement.setNull(14, Types.VARCHAR);
                statement.setNull(15, Types.DECIMAL);
            } else {
                statement.setString(14, a.listOfSubstats().get(3).substatType().getValue());
                statement.setDouble(15, a.listOfSubstats().get(3).subStatValue());
            }

            statement.execute();
        }
    }

    public void equipArtifactTo(int aId, String name) throws SQLException {
        MySQLConnection mySQLConnection = new MySQLConnection();
        try (Connection connection = mySQLConnection.connect(); CallableStatement statement = connection.prepareCall("{CALL equipArtifactToCharacter(?, ?)}")) {
            statement.setInt(1, aId);
            statement.setString(2, name);
            statement.executeUpdate();
        }
    }

    public int getBestArtifactFrom(SlotType slot, MainstatType mainstatType, SubstatType sub1, SubstatType sub2) throws SQLException {
        MySQLConnection mySQLConnection = new MySQLConnection();
        try (Connection connection = mySQLConnection.connect(); CallableStatement statement = connection.prepareCall("{CALL getBestArtifactInSlot(?, ?, ?, ?, ?, ?, ?)}")) {
            statement.setString(1, slot.name());
            statement.setString(2, mainstatType.getValue());
            statement.setString(3, sub1.getValue());
            statement.setString(4, sub2.getValue());

            statement.registerOutParameter(5, Types.INTEGER);
            statement.registerOutParameter(6, Types.VARCHAR);
            statement.registerOutParameter(7, Types.VARCHAR);

            statement.execute();

            int foundId = statement.getInt(5);
            String valueOfS1 = statement.getString(6);
            String valueOfS2 = statement.getString(7);

            System.out.println("Found " + foundId + " with " + sub1 + " = " + valueOfS1 + " and " + sub2 + " = " + valueOfS2); //TODO LOG values properly

            if (statement.wasNull()) {
                return -1;
            }
            statement.close();
            return foundId;
        }
    }

    public List<Jewel> getJewels() throws SQLException {
        MySQLConnection mySQLConnection = new MySQLConnection();
        String sql = "SELECT * FROM artifactjewels";
        List<Jewel> jewels = new ArrayList<>();
        try (Connection connection = mySQLConnection.connect();
             PreparedStatement stmt = connection.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()
        ) {
            while (rs.next()) {
                int id = rs.getInt("id");
                String set = rs.getString("set");
                SlotType slot = SlotType.valueOf(rs.getString("slot").toUpperCase().trim());
                MainstatType mainstatType = MainstatType.from(rs.getString("mainStatType"));
                double critValue = rs.getDouble("critValue");
                String equippedBy = rs.getString("equippedBy");

                jewels.add(new Jewel(id, set, slot, mainstatType, critValue, equippedBy));
            }

            return jewels;
        }
    }
}