const express = require('express');
const app = express();

app.get('/', (req, res) => res.send('hello from demo-frontend'));

if (require.main === module) {
  const port = process.env.PORT || 8080;
  app.listen(port, () => console.log(`frontend listening on ${port}`));
}

module.exports = app;
