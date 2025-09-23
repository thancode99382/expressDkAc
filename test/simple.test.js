const request = require('supertest');

describe('Simple Test', () => {
  test('Basic test', async () => {
    process.env.NODE_ENV = 'test';
    const app = require('../server');
    
    const response = await request(app)
      .get('/health')
      .expect(200);
    
    expect(response.body).toHaveProperty('status', 'OK');
    console.log('✅ Health check test passed!');
  });
});
