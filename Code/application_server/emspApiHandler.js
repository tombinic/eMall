const { query } = require("express");

module.exports = function(app, connection, obj, openGeocoder, geolib, request){
        /*
            This function is a geocoder location function that returns a Promise. It uses a SQL query to select all data from the 'chargingstatio
            n' table. If there is an error in the query, the Promise will be rejected with the error. Otherwise, the Promise will be resolved wit
            h the results of the query.
        */
        function geocoderLocation(){
          return new Promise((resolve, reject) => {
            connection.query('SELECT * FROM chargingstation', function(error, results, fields){
              if(error) {
                reject(error);
              }
              resolve(results)
            });
          })
        }
        /*
           This is an asynchronous function that filters nearby addresses based on a given latitude and longitude. It takes an array of address r
           esults and a callback function as inputs. The function first maps the addresses to geocoded responses using the "openGeocoder().geocod
           e" method, and stores the resulting URLs. It then makes parallel API requests to the stored URLs using the "request" function, and sto
           res the responses. Next, the function runs a SQL query to find all charging stations that are completely occupied, and stores the resu
           lts in "not_available_stations". Finally, the function iterates through the API responses and checks if the distance to each address i
           s less than 10,000 meters. If it is, the function adds the address information, including the status ("available" or "Not available") 
           to an array "transformed". The function returns the transformed array.
        */
        async function filterNearbyAddresses(lat, long, results, callback){
          const promises = results.map(i => openGeocoder().geocode(i.address));
          const response = await Promise.all(promises);
          let urls = [];
          let transormed = []
            
        for(const geo of response) {
            urls.push("http://" + geo.httpOptions.hostname + geo.httpOptions.path);
        }
        
          const reqPromises = urls.map(url => request(url).catch(() => JSON.stringify({lat: -1})));
          APIResponses = await Promise.all(reqPromises);
       
          var query = 'SELECT chargingstation.* FROM chargingstation JOIN chargingsocket ON ' +
                          'chargingstation.id = chargingsocket.chargingstation_id GROUP BY chargingstation.id ' +
                           'HAVING COUNT(CASE WHEN chargingsocket.status = "busy" ' +
                           'THEN 1 ELSE NULL END) = COUNT(*) AND COUNT(*) = (SELECT COUNT(*) FROM chargingsocket '+
                           'WHERE chargingsocket.chargingstation_id = chargingstation.id);';
            
            let not_available_stations = await new Promise((resolve, reject) => {
                connection.query(query, function(err, rslt, fields) {
                    if(err) { reject(err);}
                    resolve(rslt);
                });
            });

          for (let i = 0; i < APIResponses.length; i++){
            let stat = "available"
            let poi = JSON.parse(APIResponses[i])[0];

            if(poi == undefined || poi.lat === -1) continue;

            var dst = geolib.getDistance(
              { latitude: lat, longitude: long},
              { latitude: poi.lat, longitude: poi.lon }
            );

            if(dst < 10000) {
                for(let k = 0; k < not_available_stations.length; k++){
                    if(results[i].id == not_available_stations[k].id){
                        stat = "Not available";
                        break;
                    }
                }
                console.log(results[i].address + " (" + poi.lat + "," + poi.lon + ")");
                transormed.push({
                    "id": results[i].id, 
                    "name": results[i].name, 
                    "address": results[i].address, 
                    "lat": poi.lat, 
                    "long": poi.lon,
                    "status": stat
                });
          }
        }
        return transormed;
    }

    /*
        This is a POST route for the "/api/map" endpoint in an Express.js application. The route takes two parameters from the request body, "lat
        " and "long", representing a latitude and longitude. If both values are present, the function calls the "geocoderLocation" function and w
        aits for the result. Once the result is obtained, the function calls the "filterNearbyAddresses" function and passes in the latitude, lon
        gitude, and results. The filtered data is then stored in the "obj.data" array. If the "lat" and "long" parameters are not present in the 
        request body, the function returns a 400 Bad Request response with an error message. Finally, the function sends the "obj" object with a 
        status code of 200 to the client.
    */
    app.post('/api/map', function(req, res) {
        var lat = req.body.lat;
        var long = req.body.long;
    
        if (lat && long) {
            geocoderLocation().then( async function (results) {
                    obj.data = await filterNearbyAddresses(lat, long, results);
                    res.status(200);
                    res.send(JSON.stringify(obj));
                    obj.data = [];
            });
        }
        else{
            res.status(400);
            res.send("Bad request: Error on input data");
            obj.data = [];
        }
    })
    /*
        This is a node.js Express app method that implements a POST endpoint for the "insertbooking" API. The method receives the booking data, s
        uch as the booking date, start time, end time, enduser_id, chargingstation_id and chargingsocket_type, from the HTTP request body. The me
        thod first checks the availability of a charging socket that matches the specified date, time and socket type by querying the database us
        ing a SELECT statement. If an available socket is found, an INSERT statement is executed to insert the booking data into the "booking" ta
        ble. If the insert operation is successful, the method returns the newly inserted booking data along with information about the selected 
        charging station. If no available socket is found, the method returns a 404 status code with a message "No booking slots found!". In cas
        e of any errors during the database operations, the method returns a 500 status code with a message "Server error".
    */
    app.post('/api/insertbooking', function(req, res) {
        var booking_date = req.body.date;
        var start = req.body.start;
        var end = req.body.end;
        var enduser_id = req.body.enduser_id;
        var chargingstation_id = req.body.chargingstation_id;
        var chargingsocket_type = req.body.chargingsocket_type;

        let insert_query = "INSERT INTO booking (date, start, end, enduser_id, chargingsocket_id) VALUES (?, ?, ?, ?, ?)";
        let check_query = "SELECT chargingsocket.id AS sktid, number, chargingstation.id AS csid, name, address FROM chargingsocket " +
                          "INNER JOIN chargingstation ON chargingstation.id = chargingsocket.chargingstation_id " +
                          "WHERE chargingsocket.id NOT IN (SELECT chargingsocket_id FROM booking WHERE " + 
                          "date = ? AND start = ? AND end = ?) AND type = ? AND chargingstation_id = ?;"

        connection.query(check_query, [booking_date, start, end, chargingsocket_type, chargingstation_id], function(error, available_sockets, fields) {
            if(error) {
                res.status(500);
                res.send("Server error");
                return;
            } if(available_sockets.length > 0)  {
                connection.query(insert_query, [booking_date, start, end, enduser_id, available_sockets[0].sktid] , function(error, results, fields) {
                    if(error) {
                        res.status(500);
                        res.send("Server error!");
                        return;
                    } else{
                        obj.data.push({
                            "id": results.insertId,
                            "date": booking_date,
                            "start": start,
                            "end": end,
                            "enduser_id": enduser_id,
                            "chargingsocket_number": available_sockets[0].number,
                            "charging_station": {
                                "id": available_sockets[0].csid + "",
                                "name": available_sockets[0].name,
                                "address": available_sockets[0].address
                            }
                        });  
                        res.status(200);
                        res.send(JSON.stringify(obj));
                        obj.data = [];
                    }
                });
            }else {
                res.status(404);
                res.send("No booking slots found!");
            }
        });
        
    });
    
    /*
        This is a GET endpoint '/api/personalinformation/:usr' in an Express app. It retrieves the personal information and payment method of a u
        ser. The endpoint accepts a URL parameter 'usr' which represents the username of the user. The query is constructed to select the user in
        formation from multiple tables 'creditcardownership', 'enduser', and 'paymentmethod' using the 'username' value. In the callback function
        of the query, the code checks for any error and returns a server error (status 500) if any error occurs. If the results are obtained succ
        essfully, it iterates through the results and pushes the payment method information into an array. Finally, the user information and paym
        ent method array are added to the object 'obj.data' and returned in JSON format with a status code of 200. If the query results are empty,
        the endpoint returns a 404 status code with an error message.
    */
    app.get('/api/personalinformation/:usr', function(req, res) {
        var username = req.params.usr;
        var payment_method = [];
        let query = 'SELECT * FROM creditcardownership JOIN enduser ON enduser_id = username JOIN paymentmethod ON paymentmethod_id = card_number WHERE username = ?'

        connection.query(query, [username], function(error, results_user, fields) {
            if(error) {
                res.status(500);
                res.send("Server error!");
                return;
            }

            if(results_user.length > 0) {
                    results_user.forEach(element => {
                        payment_method.push({
                            card_number: element.card_number,
                            cvv: element.cvv,
                            expired_date: element.expired_date,
                        });
                    });
                    obj.data.push({
                        username: results_user[0].username,
                        name: results_user[0].name,
                        surname: results_user[0].surname,
                        email: results_user[0].email,
                        payment_method: payment_method
                    })
                    res.status(200);
                    res.send(JSON.stringify(obj));
                    obj.data = [];
            } else {
                connection.query('SELECT * FROM enduser WHERE username = ?;', [username], function(error, results, fields) {
                    if(error) {
                        res.status(500);
                        res.send("Server error!");
                        return;
                    }
        
                    if(results.length > 0) {
                        obj.data.push({
                            username: results[0].username,
                            name: results[0].name,
                            surname: results[0].surname,
                            email: results[0].email,
                            payment_method: []
                        })
                        res.status(200);
                        res.send(JSON.stringify(obj));
                        obj.data = [];
                    } else {
                        res.status(404);
                        res.send("Not found, can't find any info related to " + username);
                    }
                });
            }
        });
        
    });

    /*
        This method implements a PUT request to the '/api/personalinfo' endpoint. It updates the name and surname of a user with the specified use
        rname in the request body. It first runs an update query to update the enduser table. If the update is successful, it then runs a select q
        uery to retrieve the updated personal information, including the payment methods, of the user. If the select query is successful, the resp
        onse will include a JSON string containing the updated personal information. If there is an error or the update is not successful, the res
        ponse will contain a server error or a message indicating that the user with the specified username cannot be found.
    */
    app.put('/api/personalinfo', function(req, res) {
        var username = req.body.username;
        var name = req.body.name;
        var surname = req.body.surname;
        var payment_method = [];
        let select_query = 'SELECT * FROM creditcardownership JOIN enduser ON enduser_id = username JOIN paymentmethod ON paymentmethod_id = card_number WHERE username = ?';
       
        connection.query('UPDATE enduser SET name = ?, surname = ? WHERE username = ?', [name, surname, username], function(update_error, results_update, fields) {
            if(update_error) {
                res.status(500);
                res.send("Server error!");
                return;
            } if(results_update.affectedRows > 0){
                connection.query(select_query, [username], function(user_error, results_user, fields) {
                    if(user_error) {
                        res.status(500);
                        res.send("Server error!");
                        return;
                    } if (results_user.length > 0) {
                            results_user.forEach(element => {
                                payment_method.push({
                                    card_number: element.card_number,
                                    cvv: element.cvv,
                                    expired_date: element.expired_date,
                                });
                            });
                            obj.data.push({
                                username: results_user[0].username,
                                name: results_user[0].name,
                                surname: results_user[0].surname,
                                email: results_user[0].email,
                                payment_method: payment_method
                            })
                            res.status(200);
                            res.send(JSON.stringify(obj));
                            obj.data = [];
                        }
                    });
                } else {
                    res.status(404);
                    res.send("Not found: cannot update " + username);
                }  
        });
    });

    /*
        This method implements an endpoint for the PUT method for the "/api/email" route. It updates the email of an end user in the database and 
        retrieves their updated information, including their payment methods. If there's an error during the update process or if the specified e
        nd user is not found, the appropriate HTTP status code and error message is sent to the client. If the update is successful, the updated 
        information, including the payment methods, is sent to the client as a JSON string with a 200 HTTP status code.
    */
    app.put('/api/email', function(req, res) {
        var username = req.body.username;
        var email = req.body.email;
        var payment_method = [];
        let select_query = 'SELECT * FROM creditcardownership JOIN enduser ON enduser_id = username JOIN paymentmethod ON paymentmethod_id = card_number WHERE username = ?';
        
        connection.query('UPDATE enduser SET email = ? WHERE username = ? ', [email, username], function(update_error, results_update, fields) {
            if(update_error) {
                res.status(500);
                res.send("Server error!");
                return;
            } if(results_update.affectedRows > 0){
                connection.query(select_query, [username], function(user_error, results_user, fields) {
                    if(user_error) {
                        res.status(500);
                        res.send("Server error!");
                        return;
                    } if (results_user.length > 0) {
                            results_user.forEach(element => {
                                payment_method.push({
                                    card_number: element.card_number,
                                    cvv: element.cvv,
                                    expired_date: element.expired_date,
                                });
                            });
                            obj.data.push({
                                username: results_user[0].username,
                                name: results_user[0].name,
                                surname: results_user[0].surname,
                                email: results_user[0].email,
                                payment_method: payment_method
                            })
                            res.status(200);
                            res.send(JSON.stringify(obj));
                            obj.data = [];
                        }
                    });
            } else {
                res.status(404);
                res.send("Not found: cannot update " + username);
            }  
        });
    });

    /*
        This is a PUT API method for updating a user's password. The method takes in the "username", "old_password", and "new_password" parameter
        s from the request body. The method first queries the database to retrieve the current password for the user and checks if it matches the
        "old_password" parameter. If the passwords match, the method updates the password in the database and returns a JSON response containing 
        the updated user information including the "username", "name", "surname", "email", and payment methods. If the passwords don't match or t
        he user doesn't exist, a 400 status code is returned with a "Passwords don't match or user doesn't exist" message. If there's a server er
        ror, a 500 status code is returned with a "Server error" message.
    */
    app.put('/api/password', function(req, res) {
        var username = req.body.username;
        var old_password = req.body.old_password;
        var new_password = req.body.new_password;
        var payment_method = [];
        let select_query = 'SELECT * FROM creditcardownership JOIN enduser ON enduser_id = username JOIN paymentmethod ON paymentmethod_id = card_number WHERE username = ?';

        connection.query('SELECT password FROM enduser WHERE username = ?', [username], function(error_enduser, results_enduser, flds) {
            if(error_enduser) {
                res.status(500);
                res.send("Server error!");
                return;
            }

            if(results_enduser.length > 0 && results_enduser[0].password == old_password){
                connection.query('UPDATE enduser SET password = ? WHERE username = ? ', [new_password, username], function(update_error, results_update, fields) {
                    if(update_error) {
                        res.status(500);
                        res.send("Server error!");
                        return;
                    } if(results_update.affectedRows > 0){
                        connection.query(select_query, [username], function(user_error, results_user, fields) {
                            if(user_error) {
                                res.status(500);
                                res.send("Server error!");
                                return;
                            } if (results_user.length > 0) {
                                    results_user.forEach(element => {
                                        payment_method.push({
                                            card_number: element.card_number,
                                            cvv: element.cvv,
                                            expired_date: element.expired_date,
                                        });
                                    });
                                    obj.data.push({
                                        username: results_user[0].username,
                                        name: results_user[0].name,
                                        surname: results_user[0].surname,
                                        email: results_user[0].email,
                                        payment_method: payment_method
                                    })
                                    res.status(200);
                                    res.send(JSON.stringify(obj));
                                    obj.data = [];
                                }
                            });
                    } else {
                        res.status(404);
                        res.send("Not found: cannot update " + username);
                    }  
                });
            }else{
                res.status(400);
                res.send("Passwords don't match or user doesn't exist!");
            } 
        });
    });

    /*
        This method handles a DELETE request to the URL path /api/paymentmethod/:usr/:crdnb. It deletes a payment method identified by card_numbe
        r from the database. The username and the card_number are obtained from the request parameters req.params. The method performs a query to
        delete the payment method with the specified card_number. If the deletion is successful, it returns a JSON string containing the updated 
        user information (including the remaining payment methods). If the deletion fails (e.g. due to a server error), an error message is retur
        ned.
    */
    app.delete('/api/paymentmethod/:usr/:crdnb', function(req, res) {
        var username = req.params.usr;
        var card_number = req.params.crdnb;
        var payment_method = [];
        let select_query = 'SELECT * FROM creditcardownership JOIN enduser ON enduser_id = username JOIN paymentmethod ON paymentmethod_id = card_number WHERE username = ?';
        
        connection.query('DELETE FROM paymentmethod WHERE card_number = ?', [card_number], function(error_delete, results_delete, fields) {
            if(error_delete) {
                res.status(500);
                res.send("Server error!");
                return;
            } if(results_delete.affectedRows > 0){
                connection.query(select_query, [username], function(user_error, results_user, fields) {
                    if(user_error) {
                        res.status(500);
                        res.send("Server error!");
                        return;
                    } if (results_user.length > 0) {
                            results_user.forEach(element => {
                                payment_method.push({
                                    card_number: element.card_number,
                                    cvv: element.cvv,
                                    expired_date: element.expired_date,
                                });
                            });
                            obj.data.push({
                                username: results_user[0].username,
                                name: results_user[0].name,
                                surname: results_user[0].surname,
                                email: results_user[0].email,
                                payment_method: payment_method
                            })
                            res.status(200);
                            res.send(JSON.stringify(obj));
                            obj.data = [];
                        }
                    });
            } else {
                res.status(404);
                res.send("Not found: cannot update " + username);
            }  
        }); 
    });

    /*
        This is a method in a Node.js Express app that deletes a booking based on a booking ID. The ID is taken from the URL parameters and passe
        d to the method as "req.params.bkid". The method uses a DELETE SQL query to delete the booking from the database, with the ID as the filt
        er. The method checks for errors from the query and if the deletion is successful, it returns a 200 HTTP status code with a message indic
        ating that the booking has been deleted. If an error occurs or the booking doesn't exist, it returns a 404 HTTP status code with an appro
        priate error message.
    */
    app.delete('/api/booking/:bkid', function(req, res) {
        var booking_id = req.params.bkid;

        connection.query('DELETE FROM booking WHERE id = ?', [booking_id], function(error, results, fields) {
            if(error) {
                res.status(500);
                res.send("Server error!");
            } 
            
            if(results.affectedRows > 0) {
                    res.status(200);
                    res.send("Booking " + booking_id + " deleted!");
            }else {
                res.status(404);
                res.send("Not found: booking" + booking_id + " doesn't exists!"); 
            }
        });
    });

    /*
        This is a routing function for an API that fetches booking data based on a charging station ID and socket type. The charging station ID a
        nd socket type are passed as parameters in the URL and retrieved through the req.params object. The function then forms a SQL query to re
        trieve data from the "booking" and related tables using an inner join. The query is executed using the connection.query method, with the 
        parameters being passed as an array. If there is an error executing the query, a status of 500 and an error message are sent as the respon
        se. If the query returns results, the data is processed and pushed into an object, which is then stringified and sent as the response with
        a status of 200. If the query does not return results, a status of 404 and a "Not found!" message are sent as the response.
    */
    app.get('/api/bookingbytype/:csid/:type', (req, res) => {
        var chargingstation_id = req.params.csid;
        var socket_type = req.params.type;
        var query = 'SELECT * FROM booking INNER JOIN chargingsocket ON booking.chargingsocket_id = chargingsocket.id ' +
                    'INNER JOIN chargingstation ON chargingsocket.chargingstation_id = chargingstation.id ' + 
                    'WHERE chargingsocket.chargingstation_id = ? AND chargingsocket.type = ?';
        
        connection.query(query, [chargingstation_id, socket_type], function(error, results, fields) {
            if (error){
                res.status(500);
                res.send("Server error!");
            }

            if (results.length > 0) {
                results.forEach(b => {
                    obj.data.push({
                        id: b.id,
                        date: b.date.toISOString().split("T")[0],
                        start: b.start,
                        end: b.end
                    });
                });
                res.status(200);
                res.send(JSON.stringify(obj));
                obj.data = [];
            } else{
                res.status(404);
                res.send("");
            }			
        });
    })
    
    /*
        This is a routing function for an API that inserts a new payment method and retrieves the related user information. The payment method dat
        a (card number, CVV, and expired date) is retrieved from the request body through the req.body object. The function then inserts the payme
        nt method data into the "paymentmethod" table using a SQL query executed through the connection.query method. If there is an error, a stat
        us of 500 and an error message are sent as the response. If the insert is successful, the function inserts data into the "creditcardowners
        hip" table to associate the payment method with a user. If there is an error, a status of 500 and an error message are sent as the respons
        e. If the insert is successful, the function retrieves data from the "enduser" and "paymentmethod" tables by executing a SQL query that jo
        ins the tables based on the username and card number. If the query returns results, the data is processed and pushed into an object, which
        is then stringified and sent as the response with a status of 200. If the query does not return results, a status of 404 and a "Not found!"
        message are sent as the response.
    */
    app.post('/api/insertpaymentmethod', function (req, res) {
        var card_number = req.body.card_number;
        var cvv = req.body.cvv;
        var expired_date = req.body.expired_date;
        var username = req.body.username;
        var payment_method = [];

        connection.query('INSERT INTO paymentmethod (card_number, cvv, expired_date) VALUES (?, ?, ?)', [card_number, cvv, expired_date], function(error, results, fields) {
            if(error) {
                res.status(500);
                res.send("The payment method data that are trying to be entered are incorrect");
                return;
            } else {
                connection.query('INSERT INTO creditcardownership (enduser_id, paymentmethod_id) VALUES (?, ?)', [username, card_number], function(error, results1, fields) {
                    if(error) {
                        res.status(500);
                        res.send("Invalid credit card ownership data");
                        return;
                    } else  {
                        connection.query('SELECT * FROM creditcardownership JOIN enduser ON enduser_id = username JOIN paymentmethod ON paymentmethod_id = card_number WHERE username = ?', [username], function(slct_user_error, results_user, fields) {
                            if(slct_user_error) {
                                res.status(500);
                                res.send("Server error!");
                                return;
                            }
                            
                            if (results_user.length > 0) {
                                    results_user.forEach(element => {
                                        payment_method.push({
                                            card_number: element.card_number,
                                            cvv: element.cvv,
                                            expired_date: element.expired_date,
                                        });
                                    });
                                    obj.data.push({
                                        username: results_user[0].username,
                                        name: results_user[0].name,
                                        surname: results_user[0].surname,
                                        email: results_user[0].email,
                                        payment_method: payment_method
                                    })
                                    res.status(200);
                                    res.send(JSON.stringify(obj));
                                    obj.data = [];
                                } else {
                                    res.status(404);
                                    res.send("Not found!");   
                                }
                        });
                    } 
                });
            } 
        });
    })

    /*
        This is a GET method for the endpoint "/api/userbooking/:edid" in a Node.js Express app. It retrieves information about the bookings of a 
        specific user with the id passed in the URL (":edid"). The query is constructed to join data from three tables: "booking", "chargingsocke
        t", and "chargingstation". The query is executed with the user id passed as a parameter and the resulting bookings are processed and push
        ed into a JSON object. Finally, the object is sent back to the client as a response with the appropriate HTTP status code (200 for succes
        s, 404 for not found, and 500 for server error).
    */
    app.get('/api/userbooking/:edid', (req, res) => {
        var enduser_id = req.params.edid;
        var query = 'SELECT booking.id AS bid, booking.date, booking.start, booking.end, booking.enduser_id, ' + 
                    'booking.chargingsocket_id, chargingstation.id, chargingstation.name, chargingstation.address, chargingsocket.number FROM booking ' + 
                    'INNER JOIN chargingsocket ON booking.chargingsocket_id = chargingsocket.id ' +
                    'INNER JOIN chargingstation ON chargingsocket.chargingstation_id = chargingstation.id ' +
                    'WHERE booking.enduser_id = ?';
        
        connection.query(query, [enduser_id], function(error, results, fields) {
            if (error){
                res.status(500);
                res.send("Server error");
            }

            if (results.length > 0) {
                results.forEach(b => {
                    obj.data.push({
                        id: b.bid,
                        date: b.date.toISOString().split("T")[0],
                        start: b.start,
                        end: b.end,
                        enduser_id: b.enduser_id,
                        chargingsocket_id: b.chargingsocket_id,
                        chargingsocket_number: b.number,
                        charging_station: {
                            id: b.id + "",
                            name: b.name,
                            address: b.address
                        }
                    });
                });
                res.status(200);
                res.send(JSON.stringify(obj));
                obj.data = [];
            } else{
                res.status(404);
                res.send("");
            }			
        });
    })


    /*
        This method is a REST API endpoint for retrieving the prices of chargers in a charging station. It takes in the charging station ID from 
        the URL parameters and uses it in a SQL query to fetch the types and prices of chargers available in that station. If the query is succe
        ssful and there are results, it sends a JSON object with the fetched information to the client. If there is an error during the query, i
        t sends a "Internal server error" status code with a message. If the query returns no results, it sends a "The charging station id doesn
        't exist or has no socket" status code with a message.
    */
    app.get('/api/socketprice/:csid', (req, res) => {
        var chargingstation_id = req.params.csid;
        var query = 'SELECT DISTINCT type, price FROM chargingsocket JOIN chargingstation ' +
                    'ON chargingstation.id = chargingsocket.chargingstation_id WHERE chargingstation.id = ?';

        connection.query(query, [chargingstation_id], function(error, results, fields) {
            if (error){
                res.status(500);
                res.send("Internal server error");
            }
            
            if (results.length > 0) {
                results.forEach(b => {
                    obj.data.push({
                        type: b.type,
                        price: b.price,
                    });
                });
                res.status(200);
                res.send(JSON.stringify(obj));
                obj.data = [];
            } else{
                res.status(404);
                res.send("The charging station id doesn't exist or has no socket"); 
            }			
        });
    })    
}


