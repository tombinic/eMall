import React, {useContext} from 'react'
import Navabar from './Navbar.jsx'
import { Box } from '@mui/system';
import {CircularProgressbar, buildStyles } from "react-circular-progressbar";
import "react-circular-progressbar/dist/styles.css";
import Table from '@mui/material/Table';
import TableCell from '@mui/material/TableCell';
import TableBody from '@mui/material/TableBody';
import TableContainer from '@mui/material/TableContainer';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import { Stack } from '@mui/system';
import Divider from '@mui/material/Divider';
import Typography from '@mui/material/Typography';
import AuthContext from "../Contexts/AuthContext.jsx";
import {SocketContext} from '../Contexts/SocketContext.jsx';
import {DataContext} from '../Contexts/DataContext.jsx';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import axios from 'axios';
import { API_BASE_URL } from "../Config.js";

function createData(head, val) {
  return { head, val};
}

function rowsConverter(raw ,connsock){
  let rowsData = []
  rowsData.push(createData("Mode", raw.mode));
  rowsData.push(createData("Percentage", raw.battery_percentage));
  rowsData.push(createData("kW/h tot.", raw.battery_capacity));
  rowsData.push(createData("kW/h remaining.",(raw.battery_capacity * raw.battery_percentage)/100));
  rowsData.push(createData("Connected sockets", connsock + "/" + raw.sockets.length));
  return rowsData;
}

function isBusy(sock, connsock){
  for(let i = 0; i < connsock.length; i++){
    if(parseInt(connsock[i].number) === parseInt(sock)){
      return true;
    }
  }
  return false;
}

/**
 * Is the menu where a CPO can view the battery status, the connected sockets in real time
 * in facts this component is integrated with websockets events, which enables to receive 
 * rel time events from the server, for example, a new user is connected etc... avoiding http polling
 */
export default function BatteryMenu() {
    const { auth } = useContext(AuthContext);
    const socket = useContext(SocketContext);
    const {selectedStation, setSelectedStation} = useContext(DataContext);
    const [connsock, setConnsock] = React.useState([]);
    
    React.useEffect(() => {
      socket.on("battery_update", (event) => {
        if(selectedStation.mode === "battery"){
          let newst = {};
          Object.assign(newst, selectedStation);
          newst.battery_percentage = selectedStation.battery_percentage - 1;

          if(newst.battery_percentage <= 0){
            newst.mode = "dso";
            newst.battery_percentage = 0;
          }

          setSelectedStation(newst);
        }
      });

      socket.on("force_battery", (event) => {
        if(selectedStation.mode === "battery"){
          let newst = {};
          Object.assign(newst, selectedStation);
          newst.battery_percentage = event.battery;
          setSelectedStation(newst);
        }
      });
    }, [selectedStation.battery_percentage, selectedStation.mode]);

    React.useEffect(() => {
      socket.on("battery_update", (event) => {
        setConnsock(event.conn_socks);
      });

      socket.on("sock_disconn", (event) => {
        let newConnsock = []
        for(let i = 0; i < connsock.length; i++){
          if(connsock[i].number !== event.number){
            newConnsock.push(connsock[i]);
          }
        }
        setConnsock(newConnsock);
      });
    }, [connsock]);

    React.useEffect(() => {
      document.title = "eMall CPMS - Dashboard";
      socket.emit('join', {station_id: selectedStation.chargingstation_id, entity: "cpms"});
      return () => {
        socket.emit('leave', {station_id: selectedStation.chargingstation_id, entity: "cpms"});
        socket.off('battery_update');
        //socket.off('force_battery');
        socket.off('sock_disconn');
        const json = JSON.stringify({ 
          percentage: selectedStation.battery_percentage
        });

        axios.post(API_BASE_URL + '/battery/' + selectedStation.chargingstation_id, json, {
          headers: { 'Content-Type': 'application/json'}
        }).then(function (response) {
        }).catch(function (error) {
          alert('Something went wrong with your request!');
        });
      };
    }, []);

    return (
        <Navabar focus='/battery' connsocks={setConnsock} selected={selectedStation} drphide={false} username={auth.data.username} fullname={auth.data.name + ' ' + auth.data.surname}>
          <Box sx={{display:"flex", justifyContent: "center", alignItems:"center", maxHeight:'80vh'}}>
            <Stack direction="row"  spacing={5} divider={<Divider orientation="vertical" flexItem />}>
            <Stack spacing={4} sx={{display:"flex", justifyContent: "center", alignItems:"center"}}>
              <Box sx={{display:"flex", justifyContent: "center", alignItems:"center"}} 
                style={{ width: '10vw', height: '10vh', marginBottom:'5%'}}>
            <CircularProgressbar
              value={selectedStation.battery_percentage}
              text={`${selectedStation.battery_percentage}%`}
              styles={buildStyles({
                strokeLinecap: 'round',
                textSize: '25px',
                pathTransitionDuration: 0.5,
                pathColor: `rgba(194, 57, 235)`,
                textColor: '#000',
                trailColor: '#d6d6d6',
                backgroundColor: '#c239eb',
              })}
            />
            </Box>  
            <TableContainer component={Paper}>
                <Table sx={{ minWidth: '50vw' }} aria-label="simple table">
                  <TableBody>
                      {rowsConverter(selectedStation, connsock.length).map((row, index) => (
                        <TableRow key={index} sx={{ '&:last-child td, &:last-child th': { border: 0 } }}>
                          <TableCell variant="head">
                            <Typography style={{ fontWeight: 600 }}>
                              {row.head}
                            </Typography>
                          </TableCell>
                          <TableCell align='center'>{row.val}</TableCell>
                        </TableRow> 
                      ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </Stack>
            <Box style={{ height: "80vh", overflowY: "auto", display: "flex", flexDirection:"column"}}>
                {selectedStation.sockets.map((val, index) => {
                    return <Card key = {index} sx={{minHeight: '50%',  margin:'2%', boxShadow: 3, border: '1px solid #ccc'}}>
                              <CardContent>
                              <Stack sx={{display:"flex", justifyContent:"center", alignItems:"center"}}>
                                <Typography variant="h6" gutterBottom>
                                {"Socket number: " + val.number}
                                </Typography>
                                <Typography variant="subtitle">
                                {val.type.charAt(0).toUpperCase() + val.type.slice(1)}
                                </Typography>
                                </Stack>
                                <Stack spacing={1} sx={{display:"flex", justifyContent:"center", alignItems:"center", mt:2}}>
                                { isBusy(val.number, connsock) ? 
                                  <Typography variant="subtitle">
                                    {
                                    connsock.map((s,i) => {
                                      if(parseInt(s.number) === val.number){
                                        return <Typography key={i} variant="subtitle">
                                        {"Connected user: " + s.username}
                                      </Typography>
                                      }
                                    })
                                    }
                                    </Typography>
                                    :<></>
                                }
                                { !isBusy(val.number, connsock) ? (
                                <Box style={{width: "40%", height: "40%"}}>
                                  <CircularProgressbar
                                    value={0}
                                    text={`${"Free"}`}
                                    styles={buildStyles({
                                      strokeLinecap: 'round',
                                      textSize: '25px',
                                      pathTransitionDuration: 0.5,
                                      pathColor: `rgba(194, 57, 235)`,
                                      textColor: '#000',
                                      trailColor: '#d6d6d6',
                                      backgroundColor: '#c239eb',
                                    })}
                                  />
                                  </Box>)
                                  :(<Box style={{width: "40%", height: "40%"}}>
                                    {
                                      connsock.map((s,i) => {
                                        if(parseInt(s.number) === val.number){
                                          return <CircularProgressbar
                                          key={i}
                                          value={s.battery}
                                          text={`${s.battery}%`}
                                          styles={buildStyles({
                                            strokeLinecap: 'round',
                                            textSize: '25px',
                                            pathTransitionDuration: 0.5,
                                            pathColor: `rgba(194, 57, 235)`,
                                            textColor: '#000',
                                            trailColor: '#d6d6d6',
                                            backgroundColor: '#c239eb',
                                          })}
                                        />
                                        }
                                      })
                                    }
                                  </Box>)
                                }
                                </Stack>
                              </CardContent>
                            </Card>
                })}
            </Box>
            </Stack>
          </Box>
        </Navabar>
    );
}
