// Jest setup file
// This file runs before each test suite

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.DB_HOST = 'localhost';
process.env.DB_PORT = 5432;
process.env.DB_NAME = 'books_db_test';
process.env.DB_USER = 'postgres';
process.env.DB_PASSWORD = 'admin123';

// Don't set PORT here - let supertest handle it dynamically

// Increase test timeout for database operations
jest.setTimeout(10000);

// Mock console.log in tests to reduce noise
global.console = {
  ...console,
  log: jest.fn(),
  error: console.error,
  warn: console.warn,
  info: console.info,
  debug: console.debug,
};

// Handle server cleanup
afterAll(async () => {
  // Give time for any async operations to complete
  await new Promise(resolve => setTimeout(resolve, 100));
});
