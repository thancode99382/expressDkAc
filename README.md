# Books CRUD Application

A full-stack web application for managing a book collection, built with Express.js, PostgreSQL, and EJS templating engine.

## Features

- **Full CRUD Operations**: Create, Read, Update, and Delete books
- **Web Interface**: Beautiful, responsive EJS-based front-end with Bootstrap
- **API Endpoints**: RESTful API for programmatic access
- **PostgreSQL Database**: Robust data storage with proper indexing
- **Form Validation**: Client-side and server-side validation
- **Modern UI**: Bootstrap 5 with custom styling and Font Awesome icons

## Tech Stack

- **Backend**: Node.js, Express.js
- **Frontend**: EJS templating, Bootstrap 5, Font Awesome
- **Database**: PostgreSQL
- **Additional**: method-override, express-ejs-layouts

## Prerequisites

- Node.js (v14 or higher)
- PostgreSQL (v12 or higher)
- npm or yarn

## Installation

### Option 1: Local Development

1. **Clone the repository** (if applicable):
   ```bash
   git clone <repository-url>
   cd expressDk
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Set up PostgreSQL database**:
   ```bash
   # Create database
   createdb books_db
   
   # Or using psql
   psql -U postgres -c "CREATE DATABASE books_db;"
   ```

4. **Configure environment variables**:
   Copy the `.env` file and update the database credentials:
   ```env
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=books_db
   DB_USER=your_username
   DB_PASSWORD=your_password
   PORT=3000
   ```

5. **Run database migrations**:
   ```bash
   # Execute the schema file
   psql -U your_username -d books_db -f database/schema.sql
   
   # If you have an existing database, run the migration
   psql -U your_username -d books_db -f database/migration_add_description.sql
   ```

### Option 2: Docker (Recommended)

1. **Prerequisites**:
   - Docker and Docker Compose installed

2. **Quick Start**:
   ```bash
   # Build and start all services
   ./docker-build.sh build
   ./docker-build.sh start
   
   # Or manually with docker-compose
   docker-compose up -d
   ```

3. **Access the application**:
   - Web Interface: `http://localhost:3000`
   - Database: `localhost:5432`

4. **Docker Management Commands**:
   ```bash
   ./docker-build.sh help        # Show all available commands
   ./docker-build.sh start       # Start services
   ./docker-build.sh stop        # Stop services
   ./docker-build.sh logs        # View app logs
   ./docker-build.sh status      # Check service status
   ./docker-build.sh cleanup     # Clean up resources
   ```

## Usage

### Local Development

Start the development server with auto-reload:
```bash
npm run dev
```

Start the production server:
```bash
npm start
```

### Docker Deployment

Start with Docker Compose:
```bash
docker-compose up -d
```

View logs:
```bash
docker-compose logs -f app
```

Stop services:
```bash
docker-compose down
```

The application will be available at `http://localhost:3000`

## Application Structure

```
expressDk/
├── config/
│   └── database.js          # Database connection configuration
├── controllers/
│   └── bookController.js    # Business logic for book operations
├── database/
│   ├── schema.sql          # Database schema and sample data
│   └── migration_add_description.sql  # Migration for description field
├── models/
│   └── Book.js             # Book model with database queries
├── public/
│   ├── css/
│   │   └── style.css       # Custom styles
│   └── js/
│       └── app.js          # Client-side JavaScript
├── routes/
│   └── books.js            # Route definitions for books
├── views/
│   ├── books/
│   │   ├── index.ejs       # List all books
│   │   ├── show.ejs        # Show single book
│   │   ├── new.ejs         # Add new book form
│   │   └── edit.ejs        # Edit book form
│   ├── partials/
│   │   └── navbar.ejs      # Navigation component
│   ├── layout.ejs          # Main layout template
│   └── index.ejs           # Home page
├── .env                    # Environment variables
├── server.js               # Main application file
└── package.json            # Dependencies and scripts
```

## Routes

### Web Routes
- `GET /` - Home page
- `GET /books` - List all books
- `GET /books/new` - Show add book form
- `GET /books/:id` - Show single book
- `GET /books/:id/edit` - Show edit book form
- `POST /books` - Create new book
- `PUT /books/:id` - Update book
- `DELETE /books/:id` - Delete book

### API Routes
- `GET /api/books` - Get all books (JSON)
- `GET /api/books/:id` - Get book by ID (JSON)
- `POST /api/books` - Create new book (JSON)
- `PUT /api/books/:id` - Update book (JSON)
- `DELETE /api/books/:id` - Delete book (JSON)

## Database Schema

The `books` table includes:
- `id` (SERIAL PRIMARY KEY)
- `title` (VARCHAR 255, NOT NULL)
- `author` (VARCHAR 255, NOT NULL)
- `isbn` (VARCHAR 20, UNIQUE)
- `published_year` (INTEGER)
- `genre` (VARCHAR 100)
- `description` (TEXT)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

## Features

### Web Interface
- Responsive design with Bootstrap 5
- Form validation with real-time feedback
- Confirmation modals for delete operations
- Success/error message notifications
- Auto-hiding alerts

### API Interface
- RESTful JSON API
- Proper HTTP status codes
- Error handling with descriptive messages
- CORS enabled for cross-origin requests

## Scripts

- `npm start` - Start production server
- `npm run dev` - Start development server with nodemon
- `npm test` - Run tests (placeholder)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

ISC License - see package.json for details
# expressDkAc
