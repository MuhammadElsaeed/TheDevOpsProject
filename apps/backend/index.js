const express = require('express');
const app = express();

app.get('/health', (req, res) => res.json({ status: 'ok' }));

if (require.main === module) {
  const port = process.env.PORT || 8080;
  app.listen(port, () => console.log(`backend listening on ${port}`));
}

module.exports = app;
