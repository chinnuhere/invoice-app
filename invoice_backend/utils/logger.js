const fs = require('fs');
const path = require('path');

const LOG_LEVELS = {
  INFO: 'INFO',
  WARNING: 'WARNING',
  ERROR: 'ERROR'
};

const formatMessage = (level, message, meta = '') => {
  const timestamp = new Date().toISOString();
  const metaString = meta ? ` | Meta: ${typeof meta === 'object' ? JSON.stringify(meta) : meta}` : '';
  return `[${timestamp}] [${level}] ${message}${metaString}`;
};

const writeLog = (level, message, meta) => {
  const formatted = formatMessage(level, message, meta);
  
  if (level === LOG_LEVELS.ERROR) {
    console.error(formatted);
  } else if (level === LOG_LEVELS.WARNING) {
    console.warn(formatted);
  } else {
    console.log(formatted);
  }
  
  try {
    const logsDir = path.join(__dirname, '..', 'logs');
    if (!fs.existsSync(logsDir)) {
      fs.mkdirSync(logsDir, { recursive: true });
    }
    fs.appendFileSync(path.join(logsDir, 'app.log'), formatted + '\n');
  } catch (err) {
    // Fallback if filesystem is not writable
  }
};

const logger = {
  info: (message, meta) => writeLog(LOG_LEVELS.INFO, message, meta),
  warning: (message, meta) => writeLog(LOG_LEVELS.WARNING, message, meta),
  warn: (message, meta) => writeLog(LOG_LEVELS.WARNING, message, meta),
  error: (message, meta) => writeLog(LOG_LEVELS.ERROR, message, meta)
};

module.exports = logger;
