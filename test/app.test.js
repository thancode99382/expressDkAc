const request = require('supertest');
const app = require('../server');

describe('Express Books CRUD API', () => {
  // Use supertest without starting a separate server
  // supertest will handle the server lifecycle automatically

  describe('Health Check', () => {
    test('GET /health should return 200', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);
      
      expect(response.body).toHaveProperty('status', 'OK');
      expect(response.body).toHaveProperty('timestamp');
    });
  });

  describe('Home Route', () => {
    test('GET / should return 200', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);
      
      expect(response.text).toContain('Books CRUD Application');
    });
  });

  describe('Books Routes', () => {
    test('GET /books should return books page (even with DB errors)', async () => {
      const response = await request(app)
        .get('/books');
      
      // Should return 200 even if database has issues (graceful error handling)
      expect(response.status).toBe(200);
      expect(response.text).toContain('Books');
    });

    test('GET /books/new should return new book form', async () => {
      const response = await request(app)
        .get('/books/new')
        .expect(200);
      
      expect(response.text).toContain('Add New Book');
    });
  });

  describe('API Routes (may fail without DB)', () => {
    test('GET /api/books should respond (may return error without DB)', async () => {
      const response = await request(app)
        .get('/api/books');
      
      // Accept either 200 (with DB) or 500 (without DB)
      expect([200, 500]).toContain(response.status);
      
      if (response.status === 200) {
        expect(response.body).toBeDefined();
        // Check if it's an array or has expected structure
        expect(
          Array.isArray(response.body) || 
          (typeof response.body === 'object' && response.body !== null)
        ).toBe(true);
      } else {
        expect(response.body).toHaveProperty('success', false);
      }
    });
  });

  describe('Error Handling', () => {
    test('GET /nonexistent should return 404', async () => {
      const response = await request(app)
        .get('/nonexistent')
        .expect(404);
      
      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('message', 'Route not found');
    });
  });
});
