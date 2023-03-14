import React  from 'react'
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import PrivateRoute from './Components/PrivateRoute.jsx'
import Login from './Components/Login.jsx'
import Registration from './Components/Registration.jsx';
import HomeMenu from './Components/HomeMenu.jsx'
import StationsMenu from './Components/StationsMenu.jsx'
import BatteryMenu from './Components/BatteryMenu.jsx'
import UserMenu from './Components/UserMenu.jsx'
import DsoMenu from './Components/DsoMenu.jsx'
import NotFound from './Components/NotFound.jsx'
import {SocketContext, socket} from './Contexts/SocketContext.jsx';
import {DataContext, selectedStation, setSelectedStation} from './Contexts/DataContext.jsx';

/*
  The main app component, routes are used to address a navigator
  around the pages, some are private, this meeans that the visitor needs to be autenticated
  also it initialize the various global contexts.
*/
function App() {
  const [selectedStation, setSelectedStation] = React.useState({});
  return (
    <BrowserRouter>
    <DataContext.Provider value={{selectedStation, setSelectedStation}}> 
        <Routes>
            <Route exact path="/login" element={ <Login/> }></Route>
            <Route exact path="dashboard" element={ <PrivateRoute> <HomeMenu/> </PrivateRoute> }/>
            <Route exact path="dashboard/home" element={ <PrivateRoute> <HomeMenu/> </PrivateRoute> }/>
            <Route exact path="dashboard/dso" element={ <PrivateRoute> <DsoMenu/> </PrivateRoute> }/>
            <Route exact path="dashboard/battery" element={ 
              <PrivateRoute> 
                  <SocketContext.Provider value={socket}> 
                      <BatteryMenu/> 
                  </SocketContext.Provider>
              </PrivateRoute> }/>
            <Route exact path="dashboard/user" element={ <PrivateRoute> <UserMenu/> </PrivateRoute> }/>
            <Route exact path="dashboard/stations" element={ <PrivateRoute> <StationsMenu/> </PrivateRoute> }/>
            <Route exact path="/" element={ <Login/> }/>
            <Route exact path="/registration" element={ <Registration/> }></Route>
            <Route path='*' element={<NotFound/>}/>
        </Routes>
      </DataContext.Provider>
    </BrowserRouter>
  );
}

export default App;
