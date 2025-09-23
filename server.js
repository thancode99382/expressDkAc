const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const methodOverride = require('method-override');
const expressLayouts = require('express-ejs-layouts');
const path = require('path');
require('dotenv').config();

// Import routes
const bookRoutes = require('./routes/books');

const app = express();
const PORT = process.env.PORT || 3000;

// View engine setup
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(expressLayouts);
app.set('layout', 'layout');

// Static files
app.use(express.static(path.join(__dirname, 'public')));

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies
app.use(methodOverride('_method')); // Override HTTP methods

// Routes
app.use('/books', bookRoutes);

// API routes (optional for API usage)
const apiBookRoutes = express.Router();
apiBookRoutes.get('/', require('./controllers/bookController').getAllBooks);
apiBookRoutes.get('/:id', require('./controllers/bookController').getBookById);
apiBookRoutes.post('/', require('./controllers/bookController').createBook);
apiBookRoutes.put('/:id', require('./controllers/bookController').updateBook);
apiBookRoutes.delete('/:id', require('./controllers/bookController').deleteBook);
app.use('/api/books', apiBookRoutes);

// Root route
app.get('/', (req, res) => {
  res.render('index', { 
    title: 'Home',
    success: req.query.success,
    error: req.query.error
  });
});

// Health check route
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Error:', error);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? error.message : undefined
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`API documentation available at http://localhost:${PORT}`);
});

module.exports = app;
