import request from 'supertest';
import app from '../server.js';
import { expect } from 'chai';

describe("GET /v1/healthz", () => {
  it("It should respond 200", async () => { 
    const response = await request(app).get("/v1/healthz");
    expect(response.statusCode).equal(200);
  }).timeout(60000);
});