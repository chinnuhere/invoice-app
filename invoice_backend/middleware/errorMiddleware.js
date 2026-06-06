const logger = require('../utils/logger');

function errorMiddleware(err, req, res, next) {
  // Log error using our Logger service
  logger.error(`Error during request: ${req.method} ${req.originalUrl}`, {
    message: err.message,
    stack: err.stack,
  });

  // Determine status code and error details
  const statusCode = err.status || err.statusCode || 500;
  
  // Format structured error response
  res.status(statusCode).json({
    status: 'error',
    statusCode,
    message: err.message || 'Internal Server Error',
    // Hide details in production if needed, but since we want friendly structured errors, we return a standard msg
    error: statusCode === 500 ? 'An unexpected error occurred on the server' : err.message
  });
}

module.exports = errorMiddleware;
