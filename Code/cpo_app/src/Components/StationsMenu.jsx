import React, {useContext} from 'react'
import Navabar from './Navbar.jsx'
import Paper from '@mui/material/Paper';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TablePagination from '@mui/material/TablePagination';
import TableRow from '@mui/material/TableRow';
import Button from '@mui/material/Button';
import { Stack } from '@mui/system';
import Box from '@mui/material/Box';
import GenericModal from './GenericModal.jsx';
import Grid from '@mui/material/Grid';
import {styled } from '@mui/material/styles';
import TextField from '@mui/material/TextField';
import GenericCard from './GenericCard.jsx';
import Divider from '@mui/material/Divider';
import DeleteIcon from '@mui/icons-material/Delete';
import Thunder from '../Images/sockicon.png';
import AddCircleRoundedIcon from '@mui/icons-material/AddCircleRounded';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import Select from '@mui/material/Select';
import AuthContext from "../Contexts/AuthContext.jsx";
import axios from 'axios';
import { API_BASE_URL } from "../Config.js";
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Typography from '@mui/material/Typography';
import CardMedia from '@mui/material/CardMedia';

const VioletBorderTextField = styled(TextField)`
  & label.Mui-focused {
    color: #c239eb;
  }
  & .MuiOutlinedInput-root {
    &.Mui-focused fieldset {
      border-color: #c239eb;
    }
  }
`;

const sockets = [
]

const columns = [
  { id: 'code', label: 'Code', minWidth: 170 },
  { id: 'name', label: 'Name', minWidth: 100 },
  {
    id: 'address',
    label: 'Address',
    minWidth: 170,
    align: 'right'
  },
  {
    id: 'details',
    label: 'View',
    minWidth: 170,
    align: 'right'
  }
];

function createData(code, name, address, details) {
  return { code, name, address, details};
}

function isPositiveInteger(str) {
  if (typeof str !== 'string') return false;
  const num = Number(str);
  if (Number.isInteger(num) && num > 0) return true;
  return false;
}

export default function StationsMenu() {
  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(5);
  const [modalOpen, setModalOpen] = React.useState(false);
  const [modalDetailsOpen, setModalDetailsOpen] = React.useState(false);
  const [newSockType, setNewSockType] = React.useState('Slow charge');
  const [newSockPrice, setNewSockPrice] = React.useState('');
  const handleModalOpen = () => setModalOpen(true);
  const handleModalClose = () => {setAddrInput('');setSnInput('');setNameInput('');setBatteryInput(''); setSockState([]); setModalOpen(false);}
  const handleModalDetailsClose = () => setModalDetailsOpen(false);
  const [sockState, setSockState] = React.useState(sockets);
  const { auth } = useContext(AuthContext);
  const [rows, setRows] = React.useState([]);
  const [detailedClicked, setDetailedClicked] = React.useState({sockets: []});
  const [addrInput, setAddrInput] = React.useState("");
  const [snInput, setSnInput] = React.useState("");
  const [nameInput, setNameInput] = React.useState("");
  const [batteryInput, setBatteryInput] = React.useState("");
  const [cityInput, setCityInput] = React.useState("");

  React.useEffect(() => {
    document.title = "eMall CPMS - Dashboard";
    axios.get(API_BASE_URL + "/chargingstations/" + auth.data.company_code).then(res => {
      var stations = [];
      res.data.data.forEach(element => {
        stations.push(createData(
          element.chargingstation_id,
          element.name,
          element.address,
          <Button type="submit" variant="contained" onClick={(e) => handleModalDetailsOpen(element, e)} style={{backgroundColor: '#c239eb', color: 'white'}}>Details</Button>
        ))
      });
      setRows(stations);
    });
  }, [auth]);

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleModalDetailsOpen = (station, e) => {
    e.preventDefault();
    setDetailedClicked(station);
    setModalDetailsOpen(true);
  }

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(+event.target.value);
    setPage(0);
  };

  function handleCardClick(index, e){
    sockState.splice(index,1);
    const temp = structuredClone(sockState);
    setSockState(temp)
  }

  function handleAddClick(e){
    if(newSockPrice === ""){
      alert("Invalid price");
      return;
    }
    sockState.push({type: newSockType, price: newSockPrice, number: sockState.length + 1})
    const temp = structuredClone(sockState);
    setSockState(temp);
  }

  function handleConfirmClick(e){
    if(nameInput === '' || addrInput==='' || batteryInput==='' || snInput==='' || cityInput===''){
      alert('You must fill all the input fields to add a new station!');
      return;
    }

    if(sockState.length === 0){
      alert('You must add at least one socket!');
      return;
    }

    if(!isPositiveInteger(snInput)){
      alert("Street number must be an integer!");
      return;
    }

    if(!isPositiveInteger(batteryInput)){
      alert("The battery capacity number must be an integer!");
      return;
    }

    const json = JSON.stringify({ 
      name: nameInput,
      address: addrInput + ', ' + snInput + ', ' + cityInput,
      battery_capacity: batteryInput,
      sockets: sockState
    });


    axios.post(API_BASE_URL + '/chargingstations/' + auth.data.company_code, json, {
      headers: { 'Content-Type': 'application/json'}
    }).then(function (response) {
      axios.get(API_BASE_URL + "/chargingstations/" + auth.data.company_code).then(res => {
        var stations = [];
        res.data.data.forEach(element => {
          stations.push(createData(
            element.chargingstation_id,
            element.name,
            element.address,
            <Button type="submit" variant="contained" onClick={(e) => handleModalDetailsOpen(element, e)} style={{backgroundColor: '#c239eb', color: 'white'}}>Details</Button>
          ))
        });
        setRows(stations);
      });
    }).catch(function (error) {
      alert('Something went wrong with your request!');
    });

    handleModalClose();
  }

  const handleChange = (event) => {
    setNewSockType(event.target.value);
  };

  /**
    This React component that renders a navigation bar and a modal for creating a new charging station. 
    The modal contains form inputs for entering the address, street number, city, station name, 
    battery capacity, and socket information. The socket information is displayed as cards that 
    display the type and price, with the ability to add new sockets or delete existing ones. 
    The modal also has a confirm button that submits the entered information. Another modal for 
    displaying charging station details is also present, but not shown in this code snippet.
   */
  return (
      <Navabar focus='/stations' drphide={true} username={auth.data.username} fullname={auth.data.name + ' ' + auth.data.surname}>
        <GenericModal direction='row' open={modalOpen} handleClose={handleModalClose} title={'New charging station'}>
          <Stack direction='column' sx={{maxWidth:'100%'}} spacing={2} divider={<Divider orientation="horizontal" flexItem />}>
            <Box sx={{ width: '100%', marginTop:'1%'}}>
              <Grid container direction="row" rowSpacing={4} columnSpacing={2} justifyContent="center" alignItems="center">
                <Grid item xs={6}>
                  <VioletBorderTextField id='address' label='Address' onChange={(e) => setAddrInput(e.target.value)} fullWidth />
                </Grid>
                <Grid item xs={2}>
                  <VioletBorderTextField id='sn' label='Street number' onChange={(e) => setSnInput(e.target.value)} fullWidth/>
                </Grid>
                <Grid item xs={4}>
                  <VioletBorderTextField id='city' label='City' onChange={(e) => setCityInput(e.target.value)} fullWidth/>
                </Grid>
                <Grid item xs={4}>
                  <VioletBorderTextField id='name' label='Name' onChange={(e) => setNameInput(e.target.value)} fullWidth/>
                </Grid>
                <Grid item xs={4}> 
                  <VioletBorderTextField id='capacity' label='Battery capacity (kW/h)' onChange={(e) => setBatteryInput(e.target.value)} fullWidth/>
                </Grid>
                <Grid item xs={4}>
                  <Box  display="flex"
                        justifyContent="center"
                        alignItems="center">
                    N° Socket: {sockState.length}
                  </Box>
                </Grid>
              </Grid>
            </Box>
              <Box style={{ width: "100%", overflowX: "auto", display: "flex"}}>
                {sockState.map((val, index) => {
                    return <GenericCard
                              key = {index}
                              title = {val.type}
                              subtitle = {val.price + '€ per kW/h'}
                              number = {index + 1}
                              onButtonPress = {(e) => handleCardClick(index, e)}
                              buttonIcon = {<DeleteIcon/>}
                              buttonText = {'Delete'}
                              icon={Thunder}
                            />
                })}
                <GenericCard
                  title = {'New socket'}
                  subtitle = {''}
                  onButtonPress = {(e) => handleAddClick(e)}
                  buttonIcon = {<AddCircleRoundedIcon/>}
                  buttonText = {'Add socket'}
                  number = {sockState.length + 1}
                  icon={Thunder}
                >
                  <Stack spacing={2} sx={{mt:3}}>
                    <FormControl fullWidth size='small'>
                      <InputLabel id="newsocktype">Socket type</InputLabel>
                      <Select
                        labelId="newsocktype"
                        id="newsocktype"
                        value={newSockType}
                        label="Socket type"
                        onChange={handleChange}
                      >
                        <MenuItem value={'Slow charge'}>Slow charge</MenuItem>
                        <MenuItem value={'Fast charge'}>Fast charge</MenuItem>
                        <MenuItem value={'Rapid charge'}>Rapid charge</MenuItem>
                      </Select>
                    </FormControl>
                    <TextField
                      label="€ per kW/h"
                      id="inprice"
                      size="small"
                      value = {newSockPrice}
                      onChange={(e) => setNewSockPrice(e.target.value)}
                    />
                </Stack>
                </GenericCard>
            </Box>
            <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  style={{backgroundColor: '#c239eb', color: 'white'}}
                  onClick={(e) => handleConfirmClick(e)}
                >
                  Confirm
                </Button>
          </Stack>
        </GenericModal>
        <GenericModal direction='row' open={modalDetailsOpen} handleClose={handleModalDetailsClose} title={'Charging station details'}>
          <Stack direction='column' sx={{maxWidth:'100%', mt:5}} spacing={2} divider={<Divider orientation="horizontal" flexItem />}>
            <Box sx={{ width: '100%', marginTop:'1%'}}>
              <Grid container direction="row" rowSpacing={4} columnSpacing={2} justifyContent="center" alignItems="center">
                <Grid item xs={12}>
                  <VioletBorderTextField value={detailedClicked.address} id='address' label='Address' fullWidth InputProps={{readOnly: true}}/>
                </Grid>
                <Grid item xs={4}>
                  <VioletBorderTextField value={detailedClicked.name} id='name' label='Name' fullWidth InputProps={{readOnly: true}}/>
                </Grid>
                <Grid item xs={4}> 
                  <VioletBorderTextField value={detailedClicked.battery_capacity} id='capacity' label='Battery capacity (kW/h)' fullWidth InputProps={{readOnly: true}}/>
                </Grid>
                <Grid item xs={4}>
                  <Box  display="flex"
                        justifyContent="center"
                        alignItems="center">
                    N° Socket: {detailedClicked.sockets.length}
                  </Box>
                </Grid>
              </Grid>
            </Box>
              <Box style={{ width: "100%", overflowX: "auto", display: "flex"}}>
                {detailedClicked.sockets.map((val, index) => {
                    return <Card key = {index} sx={{ minWidth: '20%', margin:'2%', boxShadow: 3, border: '1px solid #ccc'}}>
                              <CardContent>
                              <Stack sx={{display:"flex", justifyContent:"center", alignItems:"center"}}>
                                <Typography variant="h6" gutterBottom>
                                  {val.type.charAt(0).toUpperCase() + val.type.slice(1)}
                                </Typography>
                                <Typography variant="subtitle" gutterBottom sx={{color:'#c239eb'}}>
                                  {val.price + '€ per kW/h'}
                                </Typography>
                                <Typography variant="subtitle">
                                  {"Number: " + val.number}
                                </Typography>
                              </Stack>
                              </CardContent>
                              <CardMedia
                                component="img"
                                alt="img_not_found"
                                height='100vh'
                                sx={{ padding: "1", objectFit: "contain", mb:2}}
                                image={Thunder}
                              />
                            </Card>
                })}
            </Box>
          </Stack>
        </GenericModal>
        <Box sx={{width: '100%'}}>
        <Stack spacing={2}>
        <Paper sx={{overflow: 'hidden' }}>
            <TableContainer sx={{ maxHeight: '60vh' }}>
              <Table stickyHeader aria-label="sticky table">
                <TableHead>
                  <TableRow>
                    {columns.map((column) => (
                      <TableCell
                        key={column.id}
                        align={column.align}
                        style={{ minWidth: column.minWidth, backgroundColor: '#eee'}}
                      >
                        {column.label}
                      </TableCell>
                    ))}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {rows
                    .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                    .map((row) => {
                      return (
                        <TableRow hover role="checkbox" tabIndex={-1} key={row.code}>
                          {columns.map((column) => {
                            const value = row[column.id];
                            return (
                              <TableCell key={column.id} align={column.align}>
                                {column.format && typeof value === 'number'
                                  ? column.format(value)
                                  : value}
                              </TableCell>
                            );
                          })}
                        </TableRow>
                      );
                    })}
                </TableBody>
              </Table>
            </TableContainer>
            <TablePagination
              rowsPerPageOptions={[5, 20, 50]}
              component="div"
              count={rows.length}
              rowsPerPage={rowsPerPage}
              page={page}
              onPageChange={handleChangePage}
              onRowsPerPageChange={handleChangeRowsPerPage}
            />
          </Paper>
          <Box sx={{display:"flex", justifyContent:"center", alignItems:"center"}}>
            <Box sx={{width: '50%'}}>
              <Button
                      type="submit"
                      fullWidth
                      variant="contained"
                      sx={{ mt: 3, mb: 2 }}
                      style={{backgroundColor: '#c239eb', color: 'white'}}
                      onClick={handleModalOpen}
                    >
                      Add a new station
                </Button>
              </Box>
          </Box>
          </Stack>
          </Box>
      </Navabar>
  );
}
