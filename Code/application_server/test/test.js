var chai = require('chai');
const expect = require('chai').expect;
var chaiHttp = require('chai-http');

const app = require("../index");
chai.use(chaiHttp);
const should = chai.should();

describe('POST create new payment method', function(){
  it('should create payment method', function(done) {
    chai.request(app)
        .post('/api/insertpaymentmethod')
        .send({
          card_number: "10",
          cvv: "388",
          expired_date: "12/29",
          username: "balestrieriNiccolò"
        })
        .end(function(err, res) {
          res.should.have.status(200);
          done();
          
    });
  });

  it('it should return a 404 status code for unsuccessful insert', function(done) {
    chai.request(app)
        .post('/api/insertbooking')
        .send({
          card_number: "41",
          cvv: "377",
          expired_date: "12/28",
          username: "balestrieriNiccolò"
        })
        .end(function(err, res) {
          res.should.have.status(404||500);
          done();
    });
  });
});

describe('POST create new booking', function(){
  it('should create a booking', function(done) {
    chai.request(app)
        .post('/api/insertbooking')
        .send({
          date: new Date("2024-10-26").toISOString().split("T")[0],
          start: "20:00:00",
          end: "21:00:00",
          enduser_id: "balestrieriNiccolò",
          chargingstation_id: "1",
          chargingsocket_type: "slow"
        })
        .end(function(err, res) {
          res.should.have.status(200);
          done();
    });
  });

  it('it should return a 404 status code for unsuccessful insert', function(done) {
    chai.request(app)
        .post('/api/insertbooking')
        .send({
          date: new Date("2023-08-20").toISOString().split("T")[0],
          start: "20:00:00",
          end: "21:00:00",
          enduser_id: "balestrieriNiccolò",
          chargingstation_id: "1",
          chargingsocket_type: "slow"
        })
        .end(function(err, res) {
          res.should.have.status(404||500);
          done();
    });
  });
});

describe('POST lat & long', function(){
  it('should know lat & long of city', function(done) {
    chai.request(app)
        .post('/api/map')
        .send({
          lat: "44.73040601054814", 
          long: "10.39745452074626"
        })
        .end(function(err, res) {
          res.should.have.status(200);
          done();
    });
  });

  it('it should return a 400 status code for unsuccessful insert', function(done) {
    chai.request(app)
        .post('/api/map')
        .send({
          lat: "",
          long: ""
        })
        .end(function(err, res) {
          res.should.have.status(400);
          done();
    });
  });
});

describe('GET personal information', function(){
  it('should return personal information', function(done) {
    chai.request(app)
        .get('/api/personalinformation/balestrieriNiccolò')
        .end(function(err, res) {
          res.should.have.status(200);
          done(); 
    });
  });

  it('it should return a 400 status code ', function(done) {
    chai.request(app)
        .get('/api/personalinformation/m')
        .end(function(err, res) {
          res.should.have.status(404||500);
          done();
    });
  });
});

describe('GET booking data', function(){
  it('should return booking data', function(done) {
    chai.request(app)
        .get('/api/bookingbytype/1/slow')
        .end(function(err, res) {
          res.should.have.status(200);
          done(); 
          
    });
  });

  it('it should return a 404 or 500 status code ', function(done) {
    chai.request(app)
        .get('/api/bookingbytype/1000/slow')
        .end(function(err, res) {
          res.should.have.status(404||500);
          done();
    });
  });
});

describe('GET booking data thanks to user id', function(){
  it('should return booking data thanks to user id', function(done) {
    chai.request(app)
        .get('/api/userbooking/balestrieriNiccolò')
        .end(function(err, res) {
          res.should.have.status(200);
          done(); 
    });
  });

  it('it should return a 400 status code ', function(done) {
    chai.request(app)
        .get('/api/userbooking/b')
        .end(function(err, res) {
          res.should.have.status(404||500);
          done();
    });
  });
});
describe('DELETE booking data', function(){
  it('should return the delete booking', function(done) {
    chai.request(app)
        .del('/api/booking/63') //insert existing id
        .end(function(err, res) {
          res.should.have.status(200);
          done(); 
      });
  });

  it('it should return a 404 status code ', function(done) {
    chai.request(app)
        .del('/api/booking/100')
        .end(function(err, res) {
          res.should.have.status(404);
          done();
    });
  });
});

describe('DELETE payment method', function(){
  it('should return the delete payment method', function(done) {
    chai.request(app)
        .del('/api/paymentmethod/balestrieriNiccolò/3000963852')//insert existing id
        .end(function(err, res) {
          res.should.have.status(200);
          done();
    });
  });

  it('it should return a 404 status code ', function(done) {
    chai.request(app)
        .del('/api/paymentmethod/balestrieriNiccolò/0000 0000 0000')
        .end(function(err, res) {
          res.should.have.status(404||500);
          done();
    });
  });
});

describe('PUT end user password', function(){
  it('should return the update data (password)', function(done) {
    chai.request(app)
        .put('/api/password')
        .send({
          username: "balestrieriNiccolò",
          old_password: "saròpro", //insert correct old password
          new_password: "sonobot1A"
        })
        .end(function(err, res) {
          res.should.have.status(200);
          done();
    });
  });

  it('it should return a 400 status code ', function(done) {
    chai.request(app)
        .put('/api/password')
        .send({
          username: "n",
          old_password: "saròpro", //insert incorrect old password
          new_password: "sonobot1A"
        })
        .end(function(err, res) {
          res.should.have.status(400);
          done();
    });
  });
});

describe('PUT end user email', function(){
  it('should return the update data (email)', function(done) {
    chai.request(app)
        .put('/api/email')
        .send({
          username: "balestrieriNiccolò",
          email: "nicobale@gmail.com"
        })
        .end(function(err, res) {
          res.should.have.status(200);
          done();
    });
  });

  it('it should return a 404 or 500 status code ', function(done) {
    chai.request(app)
        .put('/api/email')
        .send({
          username: "s",
          email: "nicobale@gmail.com"
        })
        .end(function(err, res) {
          res.should.have.status(404||500);
          done();
    });
  });
});

describe('PUT end user name and surname', function(){
  it('should return the update data (email)', function(done) {
    chai.request(app)
        .put('/api/personalinfo')
        .send({
          username: "balestrieriNiccolò",
          name: "Nicolò",
          surname: "Tombini"
        })
        .end(function(err, res) {
          res.should.have.status(200);
          done();
    });
  });

  it('it should return a 404 or 500 status code ', function(done) {
    chai.request(app)
        .put('/api/personalinfo')
        .send({
          username: "ncg",
          name: "Nicolò",
          surname: "Tombini"
        })
        .end(function(err, res) {
          res.should.have.status(404||500);
          done();
    });
  });
});

describe('GET charging station data thanks to cpo id', function(){
  it('should return charging station data thanks to cpo id', function(done) {
    chai.request(app)
        .get('/api/chargingstations/0521052111')
        .end(function(err, res) {
          res.should.have.status(200);
          done(); 
    });
  });

  it('it should return a 404 or 500 status code ', function(done) {
    chai.request(app)
        .get('/api/chargingstations/0521052')
        .end(function(err, res) {
          res.should.have.status(404||500);
          done();
    });
  });
});

describe('GET dso data', function(){
  it('should return dso data', function(done) {
    chai.request(app)
        .get('/api/dso')
        .end(function(err, res) {
          res.should.have.status(200);
          done(); 
    });
  });
});

describe('POST update cpo data', function(){
  it('should update cpo data', function(done) {
    chai.request(app)
        .post('/api/updatecpo')
        .send({
          name: "Niccolò",
          surname: "Balestrieri",
          email: "nb@gmail.com",
          password: "ciaoo",
          company_code: "0521052111",
          company_address: "NP"
        })
        .end(function(err, res) {
          res.should.have.status(200);
          done(); 
    });
  });
});

describe('POST Insert charging station', function() {
  it('should insert charging station', function(done) {
    const cpo = '0521052111';
    const name = 'Enel Y';
    const address = 'CASERTA';
    const battery = '100';
    const sockets = [
        { number: 1, type: 'fast', status: 'free', price: 1.0 },
        { number: 2, type: 'rapid', status: 'free', price: 2.0 }
    ];

    chai.request(app)
        .post(`/api/chargingstations/${cpo}`)
        .send({ name, address, battery_capacity: battery, sockets })
        .end(function(err, res) {
          res.should.have.status(200);
          done(); 
      });
  });

  it('it should return a 500 status code ', function(done) {
    const cpo = '0521052113';
    const name = 'Enel Y';
    const address = 'CASERTA';
    const battery = '100';
    const sockets = [
        { number: 1, type: 'fast', status: 'free', price: 1.0 },
        { number: 2, type: 'rapid', status: 'free', price: 2.0 }
    ];

    chai.request(app)
        .post(`/api/chargingstations/${cpo}`)
        .send({ name, address, battery_capacity: battery, sockets })
        .end(function(err, res) {
          res.should.have.status(500);
          done(); 
      });
  });
});

describe('POST update dso contract', function(){
  it('should update dso contract', function(done) {
    const station = '1';
    const dso = 'ENI-E';
    chai.request(app)
        .post(`/api/dsocontract/${station}`)
        .send({dso})
        .end(function(err, res) {
          res.should.have.status(200);
          done(); 
    });
  });
});

describe('POST update charging mode', function(){
  it('it should update the charging mode', (done) => {
      const station = '963';
      const mode = 'fast';
      chai.request(app)
          .post(`/api/chargingmode/${station}`)
          .send({mode})
          .end((err, res) => {
            if (!err && res) {
            expect(res).to.have.status(200);
            expect(res.text).to.equal("Updated successfully!");
            }
            else{
              console.log("Error on data");
            }
            done();
          });
  });
});

describe("POST update battery percentage", () => {
  it("should update the battery percentage", (done) => {
    chai
      .request(app)
      .post("/api/battery/1")
      .send({ percentage: 85 })
      .end((err, res) => {
        if (!err && res) {
          expect(res).to.have.status(200);
          expect(res.text).to.equal("Updated successfully!");
        }
        else{
          console.log("Error on data");
        }
        done();
      });
  });
});


