exports = module.exports = function(app, connection, obj, io){
    let first_conn = false;
    let cpos = [];
    let users = {};
    let unmonitored_stations = {};
    let to_advise = [];
    const BATTERY_SIMULATION_SPEED = 1000;

    /*
        Handles a new (generic connection)
    */
    io.on('connection', (socket) => {
        if(!first_conn){  //If is the first connection, initialize the battery simulator / server status monitor
            setInterval(function(){
                console.log("----------------------------- ROOMS STATUS -----------------------------");
                console.log("ROOM\t\t\tCPMSs\t\tEMSPs\t\tMonitored");
                io.sockets.adapter.rooms.forEach((value, key) => { //iterate over stations room
                    if(/^battery_status_\d+$/.test(key)){
                        const clients = Array.from(io.sockets.adapter.rooms.get(key));  //all clients connected to a station
                        const connected_cpos = clients.filter(value => cpos.includes(value)); //users only
                        const connected_users = clients.filter(value => Object.keys(users).includes(value));  //cpos only
                        
                        connected_users.forEach(u => { //simulate the battery charging process for the users (also if the station is not monitored)
                            users[u]["battery"]++;
                            if(unmonitored_stations[key.split('_')[2]] !== undefined){
                                unmonitored_stations[key.split('_')[2]]--;

                                if(unmonitored_stations[key.split('_')[2]] !== undefined && unmonitored_stations[key.split('_')[2]] === 0){
                                    var query = "UPDATE chargingstation SET battery_percentage = ?, mode = 'dso' WHERE id = ?;";
                                    connection.query(query, [0, key.split('_')[2]], function(error) {
                                        if(error) console.log("Mode sync error!");
                                    });
                
                                    delete unmonitored_stations[key.split('_')[2]];
                                }
                            }
                        });

                        cs_state = (unmonitored_stations[key.split('_')[2]] === undefined) ? "Yes or DSO mode" : "No";

                        console.log(key + "\t" + connected_cpos.length + "\t\t" + (connected_users.length) + "\t\t" + cs_state);
                        if(connected_users.length > 0){ //send the update status event
                            let conn_socks = [];
                            connected_users.forEach(u => conn_socks.push(users[u]));
                            socket.to(key).emit('battery_update',{conn_socks: conn_socks});
                        }
                    }
                });
                for(let i = 0; i < to_advise.length; i++){
                    socket.to(to_advise[i].csid).emit('force_battery',{battery: to_advise[i].perc});
                    to_advise.splice(i, 1);
                }
                console.log("------------------------------------------------------------------------");
            }, BATTERY_SIMULATION_SPEED);
            first_conn = true;
        }

        /*
            This event fires when a user or a cpo joins the room corresposnding to a station
            it manage also the room status update (monitored/unmonitored) 
            monitored -> at least one cpo is connected
            unmonitored -> no cpo are connected
        */
        socket.on('join', function (data) {  
			if(data.entity === "cpms"){
				socket.join("battery_status_" + data.station_id);
				console.log("\x1b[33m \n[CPMS]: " + data.station_id + " joined room battery_status_" + data.station_id + "!\n \x1b[0m");
                cpos.push(socket.id);

                if(unmonitored_stations[data.station_id] !== undefined){
                    var query = "UPDATE chargingstation SET battery_percentage = ? WHERE id = ?;";
                    connection.query(query, [unmonitored_stations[data.station_id], data.station_id], function(error) {
                        if(error) console.log("Battery sync error!")
                    });
                    to_advise.push({csid: "battery_status_" + data.station_id, perc: unmonitored_stations[data.station_id]});
                    delete unmonitored_stations[data.station_id];
                }

			}else if(data.entity === "emsp"){
                if(data.target === "booking_check"){
                    socket.join("booking_" + data.booking_id);
                    console.log("\x1b[33m \n[EMSP]: " + data.username + " joined room booking_" + data.booking_id + "!\n \x1b[0m");
                }else if(data.target === "battery_status"){
                    socket.join("battery_status_" + data.station_id);
                    console.log("\x1b[33m \n[EMSP]: " + data.username + " joined room battery_status_" + data.station_id + "!\n \x1b[0m");
                    users[socket.id] = {number: data.sock_num, username: data.username, battery: data.battery, cs: data.station_id};

                    if(Array.from(io.sockets.adapter.rooms.get("battery_status_" + data.station_id)).filter(value => cpos.includes(value)).length == 0){
                        var query = "SELECT battery_percentage FROM chargingstation WHERE id = ? AND mode = 'battery';";
                        connection.query(query, [data.station_id], function(error, results, fields) {
                            if (results.length > 0) {
                                unmonitored_stations[data.station_id] = results[0].battery_percentage;
                            }
                        });
                    }

                    var query = "UPDATE chargingsocket SET status = 'busy' WHERE chargingstation_id = ? AND number = ?;";
                    connection.query(query, [data.station_id, data.sock_num], function(error) {
                        if(error) console.log("Socket status sync error!");
                    });
                }
			}
        });

        /*
            This event fires when a user or a cpo leaves the room corresposnding to a station
            it manage also the room status update (monitored/unmonitored) 
            monitored -> at least one cpo is connected
            unmonitored -> no cpo are connected
        */
        socket.on('leave', function (data) { //users or cpo leave the room
			if(data.entity === "cpms"){
                const index = cpos.indexOf(socket.id);
                if (index > -1) {
                    cpos.splice(index, 1);
                }

                if(io.sockets.adapter.rooms.get("battery_status_" + data.station_id) !== undefined && Array.from(io.sockets.adapter.rooms.get("battery_status_" + data.station_id)).filter(value => cpos.includes(value)).length == 0){
                    var query = "SELECT battery_percentage FROM chargingstation WHERE id = ? AND mode = 'battery';";
                    connection.query(query, [data.station_id], function(error, results, fields) {
                        if(error || results.length <= 0) console.log("Battery sync problem!");
                        if (results.length > 0) {
                            unmonitored_stations[data.station_id] = results[0].battery_percentage;
                        }
                    });
                }

                socket.leave("battery_status_" + data.station_id);
                console.log("\x1b[33m \n[CPMS]: " + data.station_id + " left room battery_status_" + data.station_id + "!\n \x1b[0m");
			}else if(data.entity === "emsp"){
                if(data.target === "booking_check"){
                    socket.leave("booking_" + data.booking_id);
                    console.log("\x1b[33m \n[EMSP]: " + data.username + " left room booking_" + data.booking_id + "!\n \x1b[0m");
                }else if(data.target === "battery_status"){
                    delete users[socket.id];
                    const clients = Array.from(io.sockets.adapter.rooms.get("battery_status_" + data.station_id));
                    const connected_users = clients.filter(value => Object.keys(users).includes(value));
                    
                    if(unmonitored_stations[data.station_id] !== undefined && connected_users.length === 0){
                        var query = "UPDATE chargingstation SET battery_percentage = ? WHERE id = ?;";
                        connection.query(query, [unmonitored_stations[data.station_id], data.station_id], function(error) {
                            if(error) console.log("Battery sync error!");
                        });
    
                        delete unmonitored_stations[data.station_id];
                    }

                    socket.leave("battery_status_" + data.station_id);
                    console.log("\x1b[33m \n[EMSP]: " + data.username + " left room battery_status_" + data.station_id + "!\n \x1b[0m");
                    
                    var query = "UPDATE chargingsocket SET status = 'free' WHERE chargingstation_id = ? AND number = ?;";
                    connection.query(query, [data.station_id, data.sock_num], function(error) {
                        if(error) console.log("Socket status sync error!");
                    });
                    socket.to("battery_status_" + data.station_id).emit('sock_disconn',{number: data.sock_num});
                }
			}
        });

        /*
           Handles a disconnection (also if a user/cpo suddenly disconnects)
           so to keep the server running
         */
        socket.on('disconnect', function() {
            if (users.hasOwnProperty(socket.id)) {
                const clients = io.sockets.adapter.rooms.get("battery_status_" + users[socket.id].cs);

                if(unmonitored_stations[users[socket.id].cs] !== undefined && clients == undefined){
                    var query = "UPDATE chargingstation SET battery_percentage = ? WHERE id = ?;";
                        connection.query(query, [unmonitored_stations[users[socket.id].cs],users[socket.id].cs], function(error) {
                        if(error) console.log("Battery sync error!");
                    });
                }


                var query = "UPDATE chargingsocket SET status = 'free' WHERE chargingstation_id = ? AND number = ?;";
                connection.query(query, [users[socket.id].cs, users[socket.id].number], function(error) {
                    if(error) console.log("Socket status sync error!");
                });
                socket.to("battery_status_" + users[socket.id].cs).emit('sock_disconn',{number: users[socket.id].number});

                delete users[socket.id];
            }

            let index = cpos.indexOf(socket.id);
            if (index > -1) {
                cpos.splice(index, 1);
                io.sockets.adapter.rooms.forEach((value, key) => {
                    if(Array.from(io.sockets.adapter.rooms.get(key)).filter(value => cpos.includes(value)).length == 0 && 
                       unmonitored_stations[key.split('_')[2]] === undefined){
                        var query = "SELECT battery_percentage FROM chargingstation WHERE id = ? AND mode = 'battery';";
                        connection.query(query, [key.split('_')[2]], function(error, results, fields) {
                            if(error || results.length <= 0) console.log("Battery sync problem!");
                            if (results.length > 0) {
                                unmonitored_stations[key.split('_')[2]] = results[0].battery_percentage;
                            }
                        });
                    }
                });
            }
        });
		
        /*
            This event is triggered when a user phisically scans the qr code on the ChargingSocket app
            is the event which connects the ChargingSocket and the server and also the users
        */
		socket.on('booking_check', function (data) {  //booking qr code scan event
            console.log("[SCAN EVT]: " + JSON.stringify(data));
            let query = "SELECT * FROM booking INNER JOIN chargingsocket ON booking.chargingsocket_id = chargingsocket.id WHERE booking.id = ?;"
                connection.query(query,[data.qrdata], function(error, results, fields) {
                    if (error || results.length <= 0){
                        socket.to("booking_" + data.qrdata).emit('booking_check_outcome',JSON.stringify({
                            allowed: false
                        }));
                    }else{
                        let booking = results[0];
                        booking.number += "";
                        booking.chargingstation_id += "";

                        const startDate = new Date(booking.date);
                        startDate.setHours(booking.start.split(':')[0])
                        startDate.setMinutes(0);
                        startDate.setSeconds(0);

                        const endDate = new Date(booking.date);
                        endDate.setHours(booking.end.split(':')[0])
                        endDate.setMinutes(0);
                        endDate.setSeconds(0);

                        let now = new Date();
                        if(booking.number === data.sock_num && booking.chargingstation_id === data.station_id && (now >= startDate && now <= endDate)){
                            socket.to("booking_" + data.qrdata).emit('booking_check_outcome',"true");
                        }else{
                            socket.to("booking_" + data.qrdata).emit('booking_check_outcome',"false");
                        }
                    }		
                });
        });
    });
}