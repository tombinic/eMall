const mysql = require('mysql');
const express = require('express');
const bodyParser = require('body-parser');
const openGeocoder = require('node-open-geocoder');
const geolib = require('geolib');
const request = require('request-promise');

/*BEGIN HTTP SERVER INIT*/
const connection = mysql.createConnection({
	host     : 'localhost',
	user     : 'root',
	password : '',
	database : 'eMall',
    timezone: 'utc'
});

var obj = {
    "data": []
}

const currentDate = new Date();
const timestamp = currentDate.toISOString();
const app = express()
const port = 5000;

app.use(bodyParser.urlencoded({extended: false }));
app.use(bodyParser.json());

app.use(function(req, res, next) {
    res.header("Content-Type", 'application/json');
    res.setHeader('content-type', 'text/plain');
    res.header("Access-Control-Allow-Origin", "*");
	res.header("Access-Control-Allow-Headers", "*");
    next();
});

if(!module.parent){
    var server = app.listen(port, () => {
        console.log(`Example app listening on port ${port}`)
    })
}
/*END HTTP SERVER INIT*/

/*BEGIN HTTP API HANDLER IMPORT*/
require('./cpmsApiHandler.js')(app, connection, obj);
require('./emspApiHandler.js')(app, connection, obj, openGeocoder, geolib, request);
require('./sharedApiHandler.js')(app,connection, obj);
/*END HTTP API HANDLER IMPORT*/

/*BEGIN OF SOCKET.IO HANDLER IMPORT*/
const io = require('socket.io')(server, {
    cors: {
      origin: '*',
    }
});

module.exports = app;

require('./webSocketHandler.js')(app, connection, obj,io);
/*END OF SOCKET.IO HANDLER IMPORT*/