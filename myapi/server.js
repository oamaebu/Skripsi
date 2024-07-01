const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

const db = mysql.createConnection({
  host: '127.0.0.1',
  user: 'root',
  database: 'gameapp'
});

db.connect(err => {
  if (err) throw err;
  console.log('MySQL Connected...');
});

// CRUD operations for Anak table
app.get('/anak', (req, res) => {
  let sql = 'SELECT * FROM Anak';
  db.query(sql, (err, results) => {
    if (err) throw err;
    res.send(results);
  });
});

app.post('/anak', (req, res) => {
  let newAnak = req.body;
  let sql = 'INSERT INTO Anak SET ?';
  db.query(sql, newAnak, (err, result) => {
    if (err) throw err;
    res.send(result);
  });
});

app.put('/anak/:id', (req, res) => {
  let sql = `UPDATE Anak SET ? WHERE id = ${req.params.id}`;
  db.query(sql, req.body, (err, result) => {
    if (err) throw err;
    res.send(result);
  });
});

app.delete('/anak/:id', (req, res) => {
  let sql = `DELETE FROM Anak WHERE id = ${req.params.id}`;
  db.query(sql, (err, result) => {
    if (err) throw err;
    res.send(result);
  });
});

// Repeat similar endpoints for other tables: game, puzzle, garis, game_state

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
