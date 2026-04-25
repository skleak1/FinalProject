// Import Express Server
const express = require('express');
const app = express();
const port = 5000;

// get
app.get('/', (req, res) => {
  res.send('Welcome to Express API');
});

app.get('/search', (req, res) => {
  res.send('Inside Searching API');
});

app.post('/add', (req, res) => {
  res.send('Inside Adding API');
});

// app.put('/update', (req, res) => {
//   res.send('Inside Updating API');
// });

app.delete('/delete', (req, res) => {
  res.send('Inside Deleting API');
});

app.listen(port, () => {
  console.log(`Express server started at http://localhost:${port}`);
});
