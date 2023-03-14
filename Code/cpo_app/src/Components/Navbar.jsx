import React, {useContext} from 'react';
import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import CssBaseline from '@mui/material/CssBaseline';
import Toolbar from '@mui/material/Toolbar';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import { Icon } from "@mui/material";
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import Select from '@mui/material/Select';
import FancyAvatar from './FancyAvatar';
import Typography from '@mui/material/Typography';
import Stack from '@mui/material/Stack';
import { useNavigate } from "react-router-dom";
import Tooltip from '@mui/material/Tooltip';
import IconButton from '@mui/material/IconButton';
import Menu from '@mui/material/Menu';
import { API_BASE_URL } from "../Config.js";
import axios from 'axios';
import AuthContext from "../Contexts/AuthContext.jsx";
import {DataContext} from '../Contexts/DataContext.jsx';
import {SocketContext} from '../Contexts/SocketContext.jsx';

import home from '../Images/home.png';
import chargingStation from '../Images/chargingStation.png';
import dso from '../Images/dso.png';
import user from '../Images/user.png';
import battery from '../Images/battery.png';
import logo from '../Images/logoWhite.png';
import hdso from '../Images/hdso.png';
import huser from '../Images/huser.png';
import hbattery from '../Images/hbattery.png';
import hhome from '../Images/hhome.png';
import hchargingStation from '../Images/hchargingStation.png';

const drawerWidth = 80;

export default function Navbar(props) {
  const [anchorElUser, setAnchorElUser] = React.useState(null);
  const [cs, setCs] = React.useState('');
  const stationSelect = React.useRef();
  let navigate = useNavigate();
  const { auth } = useContext(AuthContext);
  const [stations, setStations] = React.useState([]);
  const [dimensions, setDimensions] = React.useState({
    height: window.innerHeight,
    width: window.innerWidth
  })
  const {selectedStation, setSelectedStation} = useContext(DataContext);
  const socket = useContext(SocketContext);

  React.useEffect(() => {
    axios.get(API_BASE_URL + "/chargingstations/" + auth.data.company_code).then(res => {
      setStations(res.data.data);
    });
  }, [auth]);

  const handleOpenUserMenu = (event) => {
    setAnchorElUser(event.currentTarget);
  };

  const handleCloseUserMenu = (page) => {
    if(page === 'logout'){
      setSelectedStation({});
      localStorage.clear();
      navigate("/");
    }
    setAnchorElUser(null);
  };
  
  React.useEffect(() => {
    function handleResize() {
      setDimensions({
        height: window.innerHeight,
        width: window.innerWidth
      })
    }
    window.addEventListener('resize', handleResize);
    if(stations[0]) {
      if(!selectedStation.chargingstation_id){
        setSelectedStation(stations[0]);
        setCs(stations[0].chargingstation_id);
      }else{
        let newst = {};
        Object.assign(newst, selectedStation);
        setSelectedStation(newst);
        setCs(selectedStation.chargingstation_id);
      }
    }
  }, [stations])
  
  const handleChange = (event) => {
   for(let i = 0; i < stations.length; i++){
      if(stations[i].chargingstation_id === selectedStation.chargingstation_id){ 
          const json = JSON.stringify({ 
            percentage: selectedStation.battery_percentage
          });
          axios.post(API_BASE_URL + '/battery/' + selectedStation.chargingstation_id, json, {
            headers: { 'Content-Type': 'application/json'}
          }).then(function (response) {
            axios.get(API_BASE_URL + "/chargingstations/" + auth.data.company_code).then(res => {
              setStations(res.data.data);
            });
          }).catch(function (error) {
            alert('Something went wrong with your request!');
          });
      }
    }

    axios.get(API_BASE_URL + "/chargingstations/" + auth.data.company_code).then(res => {
      setStations(res.data.data);
      setCs(event.target.value);
      if(props.focus == "/battery"){
        socket.emit('leave', {station_id: selectedStation.chargingstation_id, entity: "cpms"});
      }
      stations.forEach(element => {
        if(element.chargingstation_id === event.target.value){
          setSelectedStation(element);
          if(props.focus == "/battery"){
            socket.emit('join', {station_id: element.chargingstation_id, entity: "cpms"});
            props.connsocks([]);
          }
        }
      });
    });
  };

  function handleMenuClick(uri, e){
    e.preventDefault();
    axios.get(API_BASE_URL + "/chargingstations/" + auth.data.company_code).then(res => {
      navigate('/dashboard' + uri, { replace: true });
    }).catch(function (error) {
      alert("You must add a new charging station before start!");
      navigate('/dashboard/stations');
      return;
    });
  }

  /**
   * This component renders the top navbar, is a dynamical component
   * keeps the selected station from the dropdown menu synced globally
   * in this way we can use all the info in various menu.
   * 
   * This component allows a custom content, in the application, in facts
   * all the menu are children of this component and are rendered inside.
   */
  return (
    <Box sx={{ display: 'flex'}}>
      <CssBaseline />
      <Drawer
        variant="permanent"
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: { width: drawerWidth, boxSizing: 'border-box' },
        }}
      >
        <Toolbar style={{backgroundColor: '#c239eb'}}>
          <Icon sx={{width:'30px', height:'30px'}}>
              <img src={logo} height={'30px'} width={'30px'} alt={'index'}/>
          </Icon>
        </Toolbar>
        <Box sx={{ overflow: 'hidden',overflowY: "scroll", backgroundColor:'#eee', height:'100%', borderRight: '1px solid #ccc'}}>
          <List>
            {[[[home,hhome],'/home'], [[chargingStation,hchargingStation],'/stations'], [[dso,hdso],'/dso'], [[user,huser],'/user'], [[battery,hbattery],'/battery']].map((value, index) => (
                <ListItem key={index} disablePadding >
                <ListItemButton onClick={(e) => handleMenuClick(value[1], e)} value={index} sx={{justifyContent: 'center', width:'100%'}} >
                  <ListItemIcon value={index} sx={{justifyContent: 'center', width:'100%', height:'40px', paddingTop:'5px', paddingBottom:'5px'}}>
                      {
                        value[1] === props.focus ? 
                        <Icon sx={{width:'30px', height:'30px'}}>
                            <img src={value[0][1]} height={'30px'} width={'30px'} alt={'index'}/>
                        </Icon>: 
                        <Icon sx={{width:'30px', height:'30px'}}>
                            <img src={value[0][0]} height={'30px'} width={'30px'} alt={'index'}/>
                        </Icon>
                      }
                  </ListItemIcon>
                </ListItemButton>
              </ListItem>
            ))}
          </List>
        </Box>
      </Drawer>
      <Box component="main" sx={{height:'10vh', flexGrow: 1, top:'0', padding:'0'}}>
        <Toolbar sx={{top:'0', borderBottom: '1px solid #ccc', justifyContent: 'space-between'}}>
        {
          props.drphide ? <Box></Box>
          :<FormControl sx={{width: '15%'}}size='small'>
            <InputLabel id="cs-label">Charging station</InputLabel>
            <Select
              labelId="cs-label"
              id="cs-select"
              value={cs}
              label="Charging station"
              onChange={handleChange}
              ref={stationSelect}
            >
              {stations.map((cs, index) => {
                  return <MenuItem key={index} value={cs.chargingstation_id}>{cs.name + ' - ' + cs.address}</MenuItem>
              })}
            </Select>
          </FormControl>
          }
          
          <Box sx={{alignItems:'right'}}>
            <Stack direction='row' spacing={2}>
              <Box sx={{ display: 'flex', alignItems: 'center'}}>
                <Typography variant="overline">{props.username}</Typography>
              </Box>

              <Tooltip title="View actions">
              <IconButton onClick={handleOpenUserMenu} sx={{ p: 0 }}>
                 <FancyAvatar name={props.fullname}/>
              </IconButton>
            </Tooltip>
            <Menu
              sx={{ mt: '45px' }}
              id="menu-appbar"
              anchorEl={anchorElUser}
              anchorOrigin={{
                vertical: 'top',
                horizontal: 'right',
              }}
              keepMounted
              transformOrigin={{
                vertical: 'top',
                horizontal: 'right',
              }}
              open={Boolean(anchorElUser)}
              onClose={handleCloseUserMenu}
            >
            <MenuItem onClick={() => handleCloseUserMenu('logout')}>
              <Typography textAlign="center">Log out</Typography>
            </MenuItem>
            </Menu>
            </Stack>
          </Box>
        </Toolbar>
        <Box display="flex"
              justifyContent="center"
              alignItems="center"
              marginTop='10px'>
          <Box sx={{width: (dimensions.width - drawerWidth - 50)}}>
          {props.children}
          </Box>
        </Box>
      </Box>
    </Box>
  );
}