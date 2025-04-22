# Flight Tracking Backend

## Technologies Used

- **Node.js & Express** – for building the RESTful API server
- **MySQL** – for relational data storage and stored procedure execution
- **dotenv** – for environment variable configuration
- **mysql2** – for connecting and querying MySQL from Node.js

---

## Instructions to Setup the App

1. **Clone the repository**

   ```bash
   git clone https://github.com/Li-8023/cs4400-flight-tracking-backend.git
   ```
2. **Install dependencies**
    ```bash
    npm install
    ```
3. **Set up ```.env```**
    ```bash
    DB_HOST=localhost
    DB_USER=root
    DB_PASSWORD=yourpassword
    DB_NAME=your_database
    DB_PORT=3306
    ```
4. **Import the SQL schema**

    Make sure your MySQL server is running, and execute your schema and stored procedure SQL files:

    ```bash
    cs4400_phase3_stored_procedures_team58_try.sql
    ```

## Instructions to Run the App
1. **Start the backend server using:**

    ```bash
    npm start
    ```
## How It Works

This backend serves as an API layer over a structured MySQL database for an flight tracking management system. It supports features such as managing people, flights, pilots, passengers, and locations.

- **Express Server & API Endpoints**  
  The backend uses Express.js to define RESTful endpoints that handle requests such as adding persons, retrieving views, and invoking stored procedures. These endpoints serve as an interface between the frontend and the underlying MySQL logic.

- **MySQL Integration with Stored Procedures**  
  Business logic is implemented in **stored procedures** inside MySQL. These procedures encapsulate core application rules and ensure data integrity.

- **Views for Query Abstraction**  
  The backend also uses **SQL views** to simplify complex joins and aggregations. 

- **Frontend Communication**  
  The frontend sends JSON payloads to backend endpoints. The backend extracts, sanitizes, and transforms this data, then passes it into stored procedures via MySQL's `CALL` syntax.

In summary, this application emphasizes a thin backend controller with fat database logic, which centralizes rules and reduces redundancy across different application layers.

## Contributor
Li He and Fanshi Meng were working on the backend