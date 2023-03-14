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
import AuthContext from "../Contexts/AuthContext.jsx";
import axios from 'axios';
import { API_BASE_URL } from "../Config.js";
import {DataContext} from '../Contexts/DataContext.jsx';
import { useNavigate } from "react-router-dom";

const columns = [
  { id: 'name', label: 'Name', minWidth: 170 },
  { id: 'BookingDate', label: 'Booking\u00a0Date', minWidth: 100 },
  {
    id: 'sock',
    label: 'Socket\u00a0Number',
    minWidth: 170,
    align: 'right'
  },
  {
    id: 'expired',
    label: 'Expired',
    minWidth: 170,
    align: 'right'
  }
];

function createData(name, BookingDate, sock, expired) {
  return { name, BookingDate, sock, expired};
}

function getFormattedRows(vec, selected_id){
  let formattedBookings = []
  vec.forEach(booking => {
    if(booking.chargingstation_id === selected_id){
    var dateParts = booking.date.split("-");
    var jsDate = new Date(dateParts[0], dateParts[1] - 1, dateParts[2].substr(0,2));
    let pureDate = new Date(dateParts[0], dateParts[1] - 1, dateParts[2].substr(0,2));
    jsDate.setHours(booking.end.slice(0, 2));
    formattedBookings.push(createData(
      booking.eu_name + ' ' + booking.eu_lname,
      pureDate.toDateString() + " (" + booking.start + " - " +booking.end + ")",
      booking.sock_num,
      (jsDate < new Date()) ? "YES" : "NO"
    ));
    }
  });
  return formattedBookings;
}

/*
  This React functional component represents the home menu. 
  It displays a table of booking information including the 
  customer name, booking date, socket number, and expired status. The booking 
  information is fetched from an API endpoint when the component is mounted and 
  stored in state. The data is then transformed and filtered to display only 
  the bookings for the selected charging station. The table has pagination 
  functionality and allows for the number of rows per page to be changed.
*/
export default function HomeMenu() {
  const {selectedStation} = useContext(DataContext);
  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(10);
  const { auth } = useContext(AuthContext);
  const [rows, setRows] = React.useState([]);
  const [rawRows, setRawRows] = React.useState([]);
  const navigate = useNavigate();

  React.useEffect(() => {
    axios.get(API_BASE_URL + "/chargingstations/" + auth.data.company_code).then(res => {
      document.title = "eMall CPMS - Dashboard";
      axios.get(API_BASE_URL + "/bookings").then(res => {
      setRawRows(res.data.data);
      setRows(getFormattedRows(res.data.data, selectedStation.station_id));
    });   
    }).catch(function (error) {
      navigate('/dashboard/stations');
      return;
    });
  }, [auth]);

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(+event.target.value);
    setPage(0);
  };
  
  return (
      <Navabar focus='/home' drphide={false} username={auth.data.username} fullname={auth.data.name + ' ' + auth.data.surname}>
        <Paper sx={{ width: '100%', overflow: 'hidden' }}>
              <TableContainer sx={{ maxHeight: '80vh' }}>
                <Table stickyHeader aria-label="sticky table">
                  <TableHead>
                    <TableRow>
                      {columns.map((column, index) => (
                        <TableCell
                          key={index}
                          align={column.align}
                          style={{ minWidth: column.minWidth, backgroundColor: '#eee'}}
                        >
                          {column.label}
                        </TableCell>
                      ))}
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {getFormattedRows(rawRows, selectedStation.chargingstation_id).slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                      .map((row, index) => {
                        return (
                          <TableRow hover role="checkbox" tabIndex={-1} key={index}>
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
                rowsPerPageOptions={[10, 20, 100]}
                component="div"
                count={rawRows.length}
                rowsPerPage={rowsPerPage}
                page={page}
                onPageChange={handleChangePage}
                onRowsPerPageChange={handleChangeRowsPerPage}
              />
            </Paper>
      </Navabar>
  );
}
