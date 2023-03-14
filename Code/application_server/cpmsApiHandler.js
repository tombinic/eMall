
module.exports = function(app, connection, obj){
    /*
        This is an Express.js route handling method that listens for an HTTP GET request with a /api/chargingstations/:cpo endpoint. It takes a 
        single URL parameter cpo from the request and uses it as a parameter in an SQL query to select all charging station and charging socket
        data from the database where cpo_id matches the cpo parameter. The query results are processed and organized into an object format that
        is returned as a JSON string in the response. If there is an error in the query, a 500 Internal Server Error status is returned. If the
        query returns no results, a 404 Not Found status is returned with an empty data object. If the query is successful, the resulting data 
        is returned with a 200 OK status.
    */
    app.get('/api/chargingstations/:cpo', (req, res) => {
        var cpo = req.params.cpo;
        var query = 'SELECT * FROM chargingstation ' + 
        'INNER JOIN chargingsocket ON chargingstation.id = chargingsocket.chargingstation_id ' +
        'WHERE cpo_id = ?';

        connection.query(query,[cpo], function(error, results, fields) {
            if (error){
                res.status(500);
                res.send("Internal server error");
            }
            
            if (results.length > 0) {
                stations = [];
                results.forEach(function(row) {
                    alreadyIn = false;
                    for(let i = 0; i < stations.length; i++){
                        if(stations[i].chargingstation_id == row.chargingstation_id) {
                            alreadyIn = true;
                            break;
                        }
                    }

                    if(!alreadyIn){
                        let sockets = [];
                        results.forEach(function(i) {
                            if(row.chargingstation_id == i.chargingstation_id) {
                                sockets.push({
                                    chargingsocket_id: i.chargingsocket_id,
                                    number: i.number,
                                    type: i.type,
                                    status: i.status,
                                    price: i.price
                                });
                            }
                        });

                        stations.push({
                            chargingstation_id: row.chargingstation_id,
                            name: row.name,
                            address: row.address,
                            battery_percentage: row.battery_percentage,
                            battery_capacity: row.battery_capacity,
                            cpo_id: row.cpo_id,
                            mode: row.mode,
                            dso_id: row.dso_id,
                            sockets: sockets
                        });
                    }
                });
                obj.data = stations;
                res.status(200);
                res.send(JSON.stringify(obj));
                obj.data = [];
            } else{
                res.status(404);
                obj.data = [];
                res.send(JSON.stringify(obj));
            }			
        });
    })
    /*
        This method handles an HTTP GET request to the '/api/dso' endpoint. The method queries the 'dso' table and retrieves all of its records
        . If the query execution is successful and there are results, the method processes the results by extracting the name and energy price 
        of each DSO and adding this information to an object called 'obj'. The method then sets the status code of the response to 200 (OK) and
        sends the 'obj' object as a JSON string in the response body. If there was an error in executing the query, the method sets the status 
        code to 500 (Internal Server Error) and sends an error message. If there were no results, the method sets the status code to 404 (Not F
        ound) and sends an empty JSON string in the response body.
    */
    app.get('/api/dso', (req, res) => {
        var query = 'SELECT * FROM dso ';

        connection.query(query, function(error, results, fields) {
            if (error){
                res.status(500);
                res.send("Server error");
            }if (results.length > 0) {
                results.forEach(element => {
                    obj.data.push({
                        dso: element.name,
                        price: element.energy_price
                    });
                });

                res.status(200);
                res.send(JSON.stringify(obj));
                obj.data = [];
            } else{
                res.status(404);
                obj.data = [];
                res.send(JSON.stringify(obj));
            }			
        });
    })
    /*
        This method is a POST route "/api/updatecpo". It takes in data from the client-side, including "name", "surname", "email", "password", 
        "company_code", and "company_address". The data is then used to update the corresponding fields in a "cpo" table in a database. The qu
        ery to update the table will vary based on whether the "password" field is equal to "nothashed". If it is equal to "nothashed", the pa
        ssword field will not be updated. After executing the query, the method will send a JSON object with the updated information to the cl
        ient-side, with a status code of either 200 or 500 (for success or server error respectively).
    */
    app.post('/api/updatecpo', function(req, res) {
        var name = req.body.name;
        var surname = req.body.surname;
        var email = req.body.email;
        var password = req.body.password;
        var company_code = req.body.company_code;
        var company_address =req.body.company_address;

        if(password != 'nothashed'){
        connection.query('UPDATE cpo SET name = ?, surname = ?, email = ?, password = ?, company_address = ?  WHERE company_code = ? ', [name, surname, email, password, company_address, company_code], function(error, results, fields) {
            if(error) {
                res.status(500);
                res.send("Server error");
            } else  {
                obj.data.push({"name": name, "surname": surname, "email": email, "company_address": company_address});
                res.status(200);
                res.send(JSON.stringify(obj));
                obj.data = [];
            }
        });
        }else{
            connection.query('UPDATE cpo SET name = ?, surname = ?, email = ?, company_address = ?  WHERE company_code = ? ', [name, surname, email, company_address, company_code], function(error, results, fields) {
                if(error) {
                    res.status(500);
                    res.send("Server error");
                } else  {
                    obj.data.push({"name": name, "surname": surname, "email": email, "company_address": company_address});
                    res.status(200);
                    res.send(JSON.stringify(obj));
                    obj.data = [];
                }
            });
        }
    })
    /*
        This is an Express.js endpoint that handles a POST request to the path "/api/chargingstations/:cpo". It receives information about a c
        harging station in the request body, including its name, address, battery capacity, and the charging sockets it has. The endpoint firs
        t inserts the charging station information into the "chargingstation" table in a database, and then inserts the information about each
        charging socket into the "chargingsocket" table. If there are errors in the database queries, a 500 status code with the message "Serv
        er error!" is sent as the response. If the insertion is successful, a 200 status code with the message "Inserted successfully!" is sen
        t as the response.
    */
    app.post('/api/chargingstations/:cpo', function(req, res) {
        var cpo = req.params.cpo;
        var name = req.body.name;
        var address = req.body.address;
        var battery = req.body.battery_capacity;
        var sockets = req.body.sockets;
        var query = "INSERT INTO chargingstation (name, address, battery_percentage, battery_capacity, cpo_id, mode) " + 
                    "VALUES (?, ?, 100, ?, ?, 'auto');";
        
        connection.query(query, [name, address, battery, cpo], function(error, firstres, fields) {
            if(error) {
                res.status(500);
                res.send("Server error!");
                return;
            } else {
                query = "INSERT INTO chargingsocket (number, type, status, price, chargingstation_id) VALUES ";
                sockets.forEach(s => {
                    query += "(" + s.number + ",'" + s.type + "','free'," + s.price + "," + firstres.insertId + "),"
                });

                query = query.replace(/.$/,";");

                connection.query(query, function(error, results, fields) {
                    if(error) {
                        res.status(500);
                        res.send("Server error!");
                    } else{
                        res.status(200);
                        res.setHeader('content-type', 'text/plain');
                        res.send("Inserted successfully!");
                    }
                });
            }
        });
    })
    /*
        This is a simple POST endpoint for updating a charging station's DSO contract. The endpoint takes the ID of the charging station as a 
        parameter (in the URL), and the ID of the DSO as a request body parameter. The endpoint updates the chargingstation table in the data
        base, setting the dso_id to the value of the provided DSO ID, using the given station ID as a filter. If the update is successful, th
        e endpoint sends a "Updated successfully!" message with a 200 status code. If an error occurs, it sends a "Server error!" message wit
        h a 500 status code.
    */
    app.post('/api/dsocontract/:cs', function(req, res) {
        var station = req.params.cs;
        var dso = req.body.dso;
        var query = "UPDATE chargingstation SET dso_id = ? WHERE id = ?;";

        connection.query(query, [dso, station], function(error, firstres, fields) {
            if(error) {
                res.status(500);
                res.send("Server error!");
                return;
            } else {
                res.status(200);
                res.setHeader('content-type', 'text/plain');
                res.send("Updated successfully!");
            }
        });
    })
    /*
        This is a simple API endpoint for updating the mode of a charging station. The endpoint takes in the ID of the charging station throu
        gh a parameter in the URL ('/api/chargingmode/:cs'), as well as the new mode from the body of the request. A SQL query is then execut
        ed to update the "mode" field in the "chargingstation" table, with the new mode and the charging station ID as parameters. If the upd
        ate is successful, a 200 status and a success message are returned, otherwise a 500 status and a server error message are sent.
    */
    app.post('/api/chargingmode/:cs', function(req, res) {
        var station = req.params.cs;
        var mode = req.body.mode;
        var query = "UPDATE chargingstation SET mode = ? WHERE id = ?;";
        
        connection.query(query, [mode, station], function(error, firstres, fields) {
            if(error) {
                res.status(500);
                res.send("Update error!");
                return;
            } else {
                res.status(200);
                res.setHeader('content-type', 'text/plain');
                res.send("Updated successfully!");
            }
        });
    })
    /*
        This method updates the battery percentage of a charging station. It listens to a POST request on the '/api/battery/:cs' endpoint and
        takes two parameters in the request body, the charging station ID and the new battery percentage. It then performs a SQL query to upd
        ate the battery_percentage field in the chargingstation table with the new value. If the update is successful, it returns a response 
        with a status code of 200 and the message "Updated successfully!" If there is an error, it returns a response with a status code of 5
        00 and the message "Server error!".
    */
    app.post('/api/battery/:cs', function(req, res) {
        var station = req.params.cs;
        var percentage = req.body.percentage;
        var query = "UPDATE chargingstation SET battery_percentage = ? WHERE id = ?;";
        
        connection.query(query, [percentage, station], function(error, firstres, fields) {
            if(error) {
                res.status(500);
                res.send("Server error!");
                return;
            } else {
                res.status(200);
                res.setHeader('content-type', 'text/plain');
                res.send("Updated successfully!");
            }
        });
    })
}