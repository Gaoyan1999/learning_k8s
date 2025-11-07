import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class App {
    public static void main(String[] args) {
        System.out.println("Java backend container started!");
        // TODO: replace with wait-for-db.sh
        // for wait-for-db.sh to be ready
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        try {
            String url = "jdbc:mysql://db:3306/testdb";
            String user = "root";
            String password = "root";

            Connection conn = DriverManager.getConnection(url, user, password);
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT NOW()");

            while (rs.next()) {
                System.out.println("Database time: " + rs.getString(1));
            }

            conn.close();
        } catch (Exception e) {
            System.out.println("Database connection failed:");
            e.printStackTrace();
        }
    }
}
