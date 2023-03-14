import React, {useContext} from 'react'
import Navabar from './Navbar.jsx'
import GenericCard from './GenericCard.jsx';
import Box from '@mui/material/Box';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import SupplyIcon from '../Images/EnergySupply.png';
import { Stack } from '@mui/system';
import Divider from '@mui/material/Divider';
import Card from '@mui/material/Card';
import CardActions from '@mui/material/CardActions';
import CardContent from '@mui/material/CardContent';
import FancySwitch from './FancySwitch.jsx';
import { Typography } from '@mui/material';
import chargingStation from '../Images/chargingStation.png';
import battery from '../Images/battery.png';
import auto from '../Images/auto.png';
import AuthContext from "../Contexts/AuthContext.jsx";
import { API_BASE_URL } from "../Config.js";
import axios from 'axios';
import {DataContext} from '../Contexts/DataContext.jsx';
import BoltIcon from '@mui/icons-material/Bolt';
import { useNavigate } from "react-router-dom";

/**
 * Is the component in which the CPO can set all the energy source an management
 * option, it allows to select the dso, and the charging station management mode
 */
export default function DsoMenu() {
    const [dsoState, setDSOState] = React.useState([]);
    const { auth } = useContext(AuthContext);
    const {selectedStation, setSelectedStation} = useContext(DataContext);

    const handleChange = (newMode, e) => {
      const json = JSON.stringify({ 
        mode: newMode
      });

      axios.post(API_BASE_URL + '/chargingmode/' + selectedStation.chargingstation_id, json, {
        headers: { 'Content-Type': 'application/json'}
      }).then(function (response) {
          let newst = {};
          Object.assign(newst, selectedStation);
          newst.mode = newMode;
          setSelectedStation(newst);
          
      }).catch(function (error) {
        alert('Something went wrong with your request!');
        return;
      });
    };

    function handleCardClick(name, e){
      const json = JSON.stringify({ 
        dso: name
      });
  
      axios.post(API_BASE_URL + '/dsocontract/' + selectedStation.chargingstation_id, json, {
        headers: { 'Content-Type': 'application/json'}
      }).then(function (response) {
          selectedStation.dso_id = name;
          updateGUI();
      }).catch(function (error) {
        alert('Something went wrong with your request!');
      });
    }

    function updateGUI(){
      let dsoList = []
      axios.get(API_BASE_URL + "/dso/").then(res => {
        res.data.data.forEach(element => {
          dsoList.push({
            name: element.dso,
            price: element.price
          });
        });
        setDSOState(dsoList);
      });
    }

    React.useEffect(() => {
      document.title = "eMall CPMS - Dashboard";
      updateGUI();
    }, []);

    return (
        <Navabar focus='/dso' drphide={false} username={auth.data.username} fullname={auth.data.name + ' ' + auth.data.surname}>
          <Stack direction='column' sx={{maxWidth:'100vw'}} spacing={2} divider={<Divider orientation="horizontal" flexItem />}>
            <Box style={{ width: "100%", overflowX: "auto", display: "flex"}}>
                  {dsoState.map((val, index) => {
                      { return (selectedStation.dso_id === val.name) 
                        ? <GenericCard
                                  key = {index}
                                  title = {val.name}
                                  subtitle = {val.price + '€ per kW/h'}
                                  buttonIcon = {<BoltIcon/>}
                                  buttonText = {'CURRENT PROVIDER'}
                                  icon={SupplyIcon}
                                  disabled
                        />
                        : <GenericCard
                                key = {index}
                                title = {val.name}
                                subtitle = {val.price + '€ per kW/h'}
                                onButtonPress = {(e) => handleCardClick(val.name, e)}
                                buttonIcon = {<ShoppingCartIcon/>}
                                buttonText = {'BUY'}
                                icon={SupplyIcon}
                              />
                      }
                  })}
            </Box>
            <Box style={{ width: "100%", display: "flex", justifyContent:"center", alignItems:"center"}}>
              <Card sx={{ minWidth: '20%', margin:'2%', boxShadow: 3, border: '1px solid #ccc'}}>
              <Stack sx={{display:"flex", justifyContent:"center", alignItems:"center"}}>
                <CardContent>
                    <Typography variant="h6" gutterBottom>
                      Battery-mode
                    </Typography>
                    <Box sx={{maxHeight: '70px', display:"flex", justifyContent:"center", alignItems:"center"}}>
                      <img src={battery} height={'70px'} alt="Batteries" />
                    </Box>
                </CardContent>
                <CardActions>
                  <Box sx={{marginLeft:'15%'}}>
                    <FancySwitch checked={selectedStation.mode === "battery"}  changeAction={(e) => handleChange("battery", e)}/>
                  </Box>
                </CardActions>
                </Stack>
              </Card>
              <Card sx={{ minWidth: '20%', margin:'2%', boxShadow: 3, border: '1px solid #ccc'}}>
              <Stack sx={{display:"flex", justifyContent:"center", alignItems:"center"}}>
                <CardContent>
                    <Typography variant="h6" gutterBottom>
                      DSO-mode
                    </Typography>
                    <Box sx={{maxHeight: '70px', display:"flex", justifyContent:"center", alignItems:"center"}}>
                      <img src={chargingStation} height={'70px'} alt="Sockets" />
                    </Box>
                </CardContent>
                <CardActions>
                  <Box sx={{marginLeft:'15%'}}>
                    <FancySwitch checked={selectedStation.mode === "dso"}  changeAction={(e) => handleChange("dso", e)}/>
                  </Box>
                </CardActions>
                </Stack>
              </Card>
              <Card sx={{ minWidth: '20%', margin:'2%', boxShadow: 3, border: '1px solid #ccc'}}>
              <Stack sx={{display:"flex", justifyContent:"center", alignItems:"center"}}>
                <CardContent>
                    <Typography variant="h6" gutterBottom>
                      Auto-mode
                    </Typography>
                    <Box sx={{maxHeight: '70px', display:"flex", justifyContent:"center", alignItems:"center"}}>
                      <img src={auto} height={'70px'} alt="Auto" />
                    </Box>
                </CardContent>
                <CardActions>
                  <Box sx={{marginLeft:'15%'}}>
                    <FancySwitch checked={selectedStation.mode === "auto"}  changeAction={(e) => handleChange("auto", e)}/>
                  </Box>
                </CardActions>
                </Stack>
              </Card>
            </Box>
          </Stack>
        </Navabar>
    );
}
