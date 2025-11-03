import express from 'express';
import expressWinston from 'express-winston';
import winston from 'winston';

const app = express();
const PORT = 8000;

process.on('SIGINT', function () {
  process.exit();
});

app.use(expressWinston.logger({
  transports: [
    new winston.transports.Console()
  ],
  format: winston.format.combine(
    winston.format.colorize(),
    winston.format.simple()
  ),
  meta: false,
  msg: (req, res) => {
    return `${req.method} ${req.url}`
  },
  expressFormat: true,
  colorize: true,
  ignoreRoute: function (req, res) { return false; }
}));

app.get('/healthz', (req, res) => res.sendStatus(200))

app.get('/', (req, res) => {
  const code = req.header('x-code')
  const format = req.header('x-format')
  const id = req.header('x-request-id')

  return res.sendStatus(Number(code) || 404)
});

app.get('*', (req, res) => {
  res.sendStatus(404);
});

app.listen(PORT, () => {
  console.log(`⚡️[server]: Server is running at http://0.0.0.0:${PORT}`);
});