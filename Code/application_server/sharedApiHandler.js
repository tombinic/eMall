module.exports = function(app, connection, obj){
    app.post('/api/login', function(req, res) {
        var username = req.body.username;
        var password = req.body.password;
        var type = req.body.type;

        if (username && password && type == "enduser") {
            connection.query('SELECT * FROM enduser WHERE username = ? AND password = ?', [username, password], function(error, results, fields) {
                if (error){
                    res.status(500);
                    res.send("Server error!");
                    return;
                }

                if (results.length > 0) {
                    obj.data.push({"username": results[0].username});
                    res.status(200);
                    res.send(JSON.stringify(obj));
                    obj.data = [];
                } else{
                    res.status(404);
                    res.send("Unsuccess User's Login");
                }			
                res.end();
            });
        }
    
        if (username && password && type == "cpo") {
            connection.query('SELECT * FROM cpo WHERE username = ? AND password = ?', [username, password], function(error, results, fields) {
                if (error){
                    res.status(500);
                    res.send("Server error!");
                    return;
                }
                
                if (results.length > 0) {
                    obj.data.push({"company_code": results[0].company_code, "username": results[0].username,"name": results[0].name, "surname": results[0].surname, "email": results[0].email, "company_address": results[0].company_address});
                    res.status(200);
                    res.send(JSON.stringify(obj));
                    obj.data = [];
                } else {
                    res.status(404);
                    res.send("Unsuccess CPO's Login");
                }			
                res.end();
            });
        }
    })
    
    app.post('/api/signup', function(req, res) {
        var username = req.body.username;
        var name = req.body.name;
        var surname = req.body.surname;
        var email = req.body.email;
        var password = req.body.password;
        var type = req.body.type;
        var company_code = req.body.company_code;
        var company_address =req.body.company_address;
        
        if (username && name && surname && email && password && type=="enduser") {
           connection.query('INSERT INTO enduser (username, name, surname, email, password) VALUES (?, ?, ?, ?, ?)', [username, name, surname, email, password], function(error, results, fields) {
                if(error) {
                    res.status(500);
                    res.send("Server error!");
                    return;
                } else  {
                    obj.data.push({"username": username,"name": name, "surname": surname, "email": email});
                    res.status(200);
                    res.send(JSON.stringify(obj));
                    obj.data = [];
                } 
            });
        }
        
        if (company_code && username && name && surname && email && password && company_address && type=="cpo") {
           connection.query('INSERT INTO cpo (company_code, username, name, surname, email, password, company_address) VALUES (?, ?, ?, ?, ?, ?, ?)', [company_code, username, name, surname, email, password, company_address], function(error, results, fields) {
                if (error) {
                    res.status(500);
                    res.send("Server error!");
                    return;
                }
                else {
                    obj.data.push({"company_code": company_code, "username": username,"name": name, "surname": surname, "email": email, "company_address": company_address});
                    res.status(200);
                    res.send(JSON.stringify(obj));
                    obj.data = [];
                }
            });
        }
    })

    app.get('/api/bookings', (req, res) => {
        var query = 'SELECT * FROM booking INNER JOIN enduser ON booking.enduser_id = enduser.username INNER JOIN chargingsocket ON chargingsocket.id = booking.chargingsocket_id';

        connection.query(query, function(error, results, fields) {
            if (error){
                res.status(500);
                res.send("Internal server error");
                return;
            }

            if (results.length > 0) {
                results.forEach(b => {
                    obj.data.push({
                        id: b.id,
                        date: b.date,
                        start: b.start,
                        end: b.end,
                        eu_name: b.name,
                        eu_lname: b.surname,
                        chargingstation_id: b.chargingstation_id,
                        sock_num: b.number
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
}