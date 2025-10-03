const pool = require('./database');

const createBooksTable = async () => {
  const createTableQuery = `
    CREATE TABLE IF NOT EXISTS books (
      id SERIAL PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      author VARCHAR(255) NOT NULL,
      isbn VARCHAR(20) UNIQUE,
      publication_year INTEGER,
      genre VARCHAR(100),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  try {
    await pool.query(createTableQuery);
    console.log('✅ Books table created successfully');
    
    // Insert sample data if table is empty
    const checkData = await pool.query('SELECT COUNT(*) FROM books');
    const count = parseInt(checkData.rows[0].count);
    
    if (count === 0) {
      const sampleData = `
        INSERT INTO books (title, author, isbn, publication_year, genre)
        VALUES 
          ('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', 1925, 'Fiction'),
          ('To Kill a Mockingbird', 'Harper Lee', '9780061120084', 1960, 'Fiction'),
          ('1984', 'George Orwell', '9780451524935', 1949, 'Dystopian Fiction'),
          ('Pride and Prejudice', 'Jane Austen', '9780141439518', 1813, 'Romance')
        ON CONFLICT (isbn) DO NOTHING;
      `;
      
      await pool.query(sampleData);
      console.log('✅ Sample data inserted');
    } else {
      console.log('📚 Books table already contains data');
    }
  } catch (error) {
    console.error('❌ Error initializing database:', error);
    throw error;
  }
};

module.exports = { createBooksTable };