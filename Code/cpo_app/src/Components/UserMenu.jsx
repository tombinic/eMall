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
import { Stack } from '@mui/system';
import Divider from '@mui/material/Divider';
import Grid from '@mui/material/Grid';
import {styled } from '@mui/material/styles';
import TextField from '@mui/material/TextField';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import AuthContext from "../Contexts/AuthContext.jsx";
import axios from 'axios';
import { API_BASE_URL } from "../Config.js";
import sha256 from 'crypto-js/sha256';

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

const columns = [
  { id: 'code', label: 'Code', minWidth: 170 },
  { id: 'name', label: 'Name', minWidth: 100 },
  {
    id: 'address',
    label: 'Address',
    minWidth: 170,
    align: 'right'
  }
];

function createData(code, name, address) {
  return { code, name, address};
}

function isVAlidEmail(input){
  if(String(input)
  .toLowerCase()
  .match(
    /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  )) return true;
  return false;
}

/*
  This is a React functional component named UserMenu. It manages a form for a user to 
  update their information. 
  It uses React Hooks (useState and useContext) to manage its state, 
  and Axios to make HTTP requests to a server.
  It uses React.useEffect to fetch charging station data from the server and set the rows state with the returned data.
  Handles pagination and number of rows per page changes.
  Handles changes to the form fields.
  Handles the submission of the form. When the user confirms the changes, it sends a POST request to the server 
  to update the user's information.
  Renders a Navbar component, with a form inside to display the user's information and allow them to update it
*/
export default function UserMenu() {
    const [page, setPage] = React.useState(0);
    const { auth, setAuth } = useContext(AuthContext);
    const [fields, setFields] = React.useState({
        user:  auth.data.username,
        ccode: auth.data.company_code,
        email: auth.data.email,
        fname: auth.data.name,
        lname: auth.data.surname,
        caddress: auth.data.company_address,
        password: 'password_solo_per_init'
      });
    const [rowsPerPage, setRowsPerPage] = React.useState(10);
    const [rows, setRows] = React.useState([]);

    React.useEffect(() => {
      document.title = "eMall CPMS - Dashboard";
      axios.get(API_BASE_URL + "/chargingstations/" + auth.data.company_code).then(res => {
        var stations = [];
        res.data.data.forEach(element => {
          stations.push(createData(
            element.chargingstation_id,
            element.name,
            element.address,
          ))
        });
        setRows(stations);
      });
    }, [auth]);

    const handleChangePage = (event, newPage) => {
      setPage(newPage);
    };

    const handleChangeRowsPerPage = (event) => {
      setRowsPerPage(+event.target.value);
      setPage(0);
    };

    const handleFieldsChange = (key,value) => {
      const updated = {};
      Object.assign(updated, fields);
      updated[key] = value;
      setFields(updated);
    }

    function handleConfirmClick(e){
      e.preventDefault();

      if(!isVAlidEmail(fields.email)){
        alert("invalid email!");
        return;
      }

      let hash = 'nothashed';
      if(fields.password !== 'password_solo_per_init'){
          hash = sha256(fields.password).toString();
      }

      const json = JSON.stringify({ 
          name: fields.fname,
          surname: fields.lname,
          email: fields.email,
          password: hash,
          company_code: fields.ccode,
          company_address: fields.caddress
      });

      axios.post(API_BASE_URL + '/updatecpo', json, {
        headers: { 'Content-Type': 'application/json'}
        }).then(function (response) {
          response.data.data[0].company_code = fields.ccode;
          response.data.data[0].username = fields.user;
          setAuth({
            success: true,
            data: response.data.data[0]
          });
        }).catch(function (error) {
          alert('Update error!');
        });
    }

    return (
        <Navabar focus='/user' drphide='true' username={auth.data.username} fullname={auth.data.name + ' ' + auth.data.surname}>
          <Stack direction={'row'} spacing={2} divider={<Divider orientation="horizontal" flexItem />}>
          <Box sx={{ width: '100%', marginTop:'1%'}}>
              <Grid container direction="row" rowSpacing={4} columnSpacing={2} justifyContent="center" alignItems="center">
                <Grid item xs={12}>
                  <VioletBorderTextField id='user' disabled={true} label='Username' value={fields.user} fullWidth onChange={(e) => handleFieldsChange('user',e.target.value)}/>
                </Grid>
                <Grid item xs={12}>
                  <VioletBorderTextField id='email' label='E-mail address' value={fields.email} fullWidth onChange={(e) => handleFieldsChange('email',e.target.value)}/>
                </Grid>
                <Grid item xs={12}>
                  <VioletBorderTextField id='ccode' label='Company code' disabled={true} value={fields.ccode} fullWidth onChange={(e) => handleFieldsChange('ccode',e.target.value)}/>
                </Grid>
                <Grid item xs={6}> 
                  <VioletBorderTextField id='fname' label='First name' value={fields.fname} fullWidth onChange={(e) => handleFieldsChange('fname',e.target.value)}/>
                </Grid>
                <Grid item xs={6}>
                  <VioletBorderTextField id='lname' label='Last name' value={fields.lname} fullWidth onChange={(e) => handleFieldsChange('lname',e.target.value)}/>
                </Grid>
                <Grid item xs={12}>
                  <VioletBorderTextField type={'password'} id='psw' label='Password' value={fields.password} fullWidth onChange={(e) => handleFieldsChange('password',e.target.value)}/>
                </Grid>
                <Grid item xs={12}>
                  <VioletBorderTextField id='caddress' label='Company address' value={fields.caddress} fullWidth onChange={(e) => handleFieldsChange('caddress',e.target.value)}/>
                </Grid>
                <Grid item xs={12}>
                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  style={{backgroundColor: '#c239eb', color: 'white'}}
                  onClick={(e) => handleConfirmClick(e)}
                >
                  Update data
                </Button>
                </Grid>
              </Grid>
            </Box>
            <Paper sx={{overflow: 'hidden', width:'100%'}}>
              <TableContainer sx={{ maxHeight: '75vh' }}>
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
                rowsPerPageOptions={[10, 25, 100]}
                component="div"
                count={rows.length}
                rowsPerPage={rowsPerPage}
                page={page}
                onPageChange={handleChangePage}
                onRowsPerPageChange={handleChangeRowsPerPage}
              />
            </Paper>
          </Stack>
        </Navabar>
    );
}
