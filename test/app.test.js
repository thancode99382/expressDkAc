const request = require('supertest');
const app = require('../server');

describe('Express Books CRUD API', () => {
  let server;

  beforeAll(() => {
    // Start the server for testing
    server = app.listen(3001);
  });

  afterAll((done) => {
    // Close the server after tests
    if (server) {
      server.close(done);
    } else {
      done();
    }
  });

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
        expect(Array.isArray(response.body)).toBe(true);
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
