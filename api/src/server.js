const express = require("express")
const { Pool } = require("pg")
const app = express()

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: 5432,
})

app.use(express.json())

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ status: "ok" })
})

// Get users
app.get("/users", async (req, res) => {
  try {
    const { rows } = await pool.query("SELECT * FROM users")
    res.json(rows)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

// Create user
app.post("/users", async (req, res) => {
  const { name, email } = req.body
  try {
    const { rows } = await pool.query(
      "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *",
      [name, email]
    )
    res.json(rows[0])
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

const port = process.env.PORT || 3000
app.listen(port, () => {
  console.log(`API running on port ${port}`)
})
