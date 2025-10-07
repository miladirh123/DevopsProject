const request = require('supertest');
const app = require('../server');

describe('GET /', () => {
  it('responds 200 and Hello World', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.text).toBe('Hello World!');
  });
});
