import * as React from 'react';
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
import Avatar from '@mui/material/Avatar';
import Typography from '@mui/material/Typography';
import Stack from '@mui/material/Stack';

import home from '../Images/home.png';
import chargingStation from '../Images/chargingStation.png';
import dso from '../Images/dso.png';
import user from '../Images/user.png';
import battery from '../Images/battery.png';
import logo from '../Images/logoWhite.png';

const drawerWidth = 80;

/**
 * The Left side menu components it allows to navigate through
 * the applications pages
 */
export default function ClippedDrawer() {
  const [cs, setCs] = React.useState('');
  const [menu, setMenu] = React.useState('home');

  const handleChange = (event) => {
    setCs(event.target.value);
  };

  const handleMenuNav = (event) => {
    alert(event.target.key)
    setMenu(event.target.value)
  };

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
        <Box sx={{ overflow: 'auto', backgroundColor:'#eee', height:'100%', borderRight: '1px solid #ccc'}}>
          <List>
            {[home, chargingStation, dso, user, battery].map((icon, index) => (
                <ListItem key={index} disablePadding onClick={handleMenuNav}>
                <ListItemButton value={index} sx={{justifyContent: 'center', width:'100%'}} >
                  <ListItemIcon value={index} sx={{justifyContent: 'center', width:'100%', height:'40px', paddingTop:'5px', paddingBottom:'5px'}}>
                    <Icon sx={{width:'30px', height:'30px'}}>
                        <img src={icon} height={'30px'} width={'30px'} alt={'index'}/>
                    </Icon>
                  </ListItemIcon>
                </ListItemButton>
              </ListItem>
            ))}
          </List>
        </Box>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, top:'0', padding:'0'}}>
        <Toolbar sx={{top:'0', borderBottom: '1px solid #ccc', justifyContent: 'space-between'}}>
          <FormControl sx={{width: '15%'}}size='small'>
            <InputLabel id="cs-label">Charging station</InputLabel>
            <Select
              labelId="cs-label"
              id="cs-select"
              value={cs}
              label="Charging station"
              onChange={handleChange}
            >
              {['Via venezia, 14, PR', 'Via parigi, 3, MI', 'Pz.za, garibaldi, 2, PC', 'Via Mantova, 32, PR'].map((text, index) => {
                  return <MenuItem key={index} value={index}>{text}</MenuItem>
              })}
            </Select>
          </FormControl>
          <Box sx={{alignItems:'right'}}>
            <Stack direction='row' spacing={2}>
              <Box sx={{ display: 'flex', alignItems: 'center'}}>
                <Typography variant="overline">Username</Typography>
              </Box>
              <Avatar alt='Username' src='Username qui' />
            </Stack>
          </Box>
        </Toolbar>
        {menu}
      </Box>
    </Box>
  );
}