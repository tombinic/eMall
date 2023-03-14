import React, { useEffect, useState, useContext } from 'react';
import axios from 'axios';
import AuthContext from "../Contexts/AuthContext.jsx";
import { useNavigate } from "react-router-dom";
import Avatar from '@mui/material/Avatar';
import Button from '@mui/material/Button';
import CssBaseline from '@mui/material/CssBaseline';
import TextField from '@mui/material/TextField';
import Link from '@mui/material/Link';
import { Link as lk} from 'react-router-dom'
import Paper from '@mui/material/Paper';
import Box from '@mui/material/Box';
import Grid from '@mui/material/Grid';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';
import Typography from '@mui/material/Typography';
import { createTheme, ThemeProvider, styled } from '@mui/material/styles';
import bgImg from '../Images/background.png'
import { Stack } from '@mui/system';
import sha256 from 'crypto-js/sha256';

import { API_BASE_URL } from "../Config.js";

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

/*
  This is a React component for a registration form, where users can sign up for an account in the eMall CPMS. 
  It uses Material UI for styling, and Axios for making API calls to the server.
  The component contains various state variables for capturing the user's inputs, 
  such as first name, last name, email, password, etc. It also uses the context API 
  to set the authentication status in local storage once the user has successfully registered.
  The handleSubmit function is called when the form is submitted, it validates the user's input, 
  such as checking if the passwords match, and if the email address is in a valid format. If the inputs are valid, 
  it then makes a POST request to the server to sign up the user using the Axios library. If the signup is successful, 
  the user is redirected to the login page, otherwise, an error message is displayed to the user.
*/
const Registration = () => {
    const { setAuth } = useContext(AuthContext);
    const [fname, setFname] = useState('');
    const [lname, setLname] = useState('');
    const [username, setUsername] = useState('');
    const [ccode, setCcode] = useState('');
    const [caddress, setCaddress] = useState('');
    const [email, setEmail] = useState('');
    const [pwd, setPwd] = useState('');
    const [rPwd, setRpwd] = useState('');
    const navigate = useNavigate();
    const [isFormInvalid, setIsFormInvalid] = useState(false);

    function isVAlidEmail(input){
      if(String(input)
      .toLowerCase()
      .match(
        /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      )) return true;
      return false;
    }

    useEffect(() => {
        var prevAuth = JSON.parse(localStorage.getItem('auth'));
        if(prevAuth && prevAuth.success) {
            setAuth(prevAuth);
            navigate('/dashboard');
        }

        document.title = "eMall CPMS - Register"
    }, [setAuth, navigate])

    const handleSubmit = (e) => {
      e.preventDefault();

      let hash1 = sha256(pwd).toString();
      let hash2 = sha256(rPwd).toString();  
      
      if (hash1 !== hash2 || (pwd.length === 0 || 
        fname.length === 0 || username.length === 0 || 
        lname.length === 0 || ccode.length !== 10 || caddress.length === 0) 
        || !isVAlidEmail(email)) {
          setIsFormInvalid(true);
        return;
      }

      const json = JSON.stringify({ 
          username: username,
          name: fname,
          surname: lname,
          email: email,
          password: hash1,
          type: 'cpo',
          company_code: ccode,
          company_address: caddress
      });

      axios.post(API_BASE_URL + '/signup', json, {
        headers: { 'Content-Type': 'application/json'}
      }).then(function (response) {
        navigate('/login');
      })
      .catch(function (error) {
        if (!error?.response) {
          alert('Connection timeout!');
        } else if (error.response?.status === 404) {
            setIsFormInvalid(true);
        } else if (error.response?.status === 500) {
            alert('Server error!');
        } else {
            alert('Unknown cause (login failed)!');
        }
      });
    }

    function Copyright(props) {
      return (
        <Typography variant = "body2" color = "text.secondary" align = "center" {...props}>
          {'Copyright © '}
          <Link color="inherit" href = { "./" }>
            eMall
          </Link>{' '}
          {new Date().getFullYear()}
          {'.'}
        </Typography>
      );
    }

    const theme = createTheme({
      palette: {
        mode: 'light',
      },
    });

    return (
      <ThemeProvider theme={theme}>
        <Grid container component="main" sx={{ height: '100vh' }}>
          <CssBaseline />
          <Grid
            item
            xs={false}
            sm={4}
            md={7}
            sx={{
              backgroundImage: 'url(' + bgImg +')',
              backgroundRepeat: 'no-repeat',
              backgroundSize: 'cover',
              backgroundPosition: 'center',
            }}
          />
          <Grid style = {{backgroundColor: '#fff'}} item xs={12} sm={8} md={5} component={Paper} elevation={6} square>
            <Box
              sx={{
                my: 2,
                mx: 4,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
              }}
            >
              <Avatar sx={{ m: 1, bgcolor: '#c239eb' }}>
                <LockOutlinedIcon />
              </Avatar>
              <Typography component="h1" variant="h5">
                Sign up
              </Typography>
              <Box component="form" noValidate onSubmit={handleSubmit} sx={{ mt: 1 , width:'100%'}}>
                <Stack spacing={2}>
                <Stack sx={{display:"flex", justifyContent:"center", alignItems:"center", width:'100%'}} spacing={1} direction={'row'}>
                <VioletBorderTextField
                  required
                  fullWidth
                  value = {fname}
                  onChange={(e) => setFname(e.target.value)}
                  error = { isFormInvalid }
                  id="fname"
                  label="First name"
                />
                <VioletBorderTextField
                  required
                  fullWidth
                  value = {lname}
                  onChange={(e) => setLname(e.target.value)}
                  error = { isFormInvalid }
                  label="Last name"
                  id="lname"
                />
                </Stack>
                <VioletBorderTextField
                  required
                  fullWidth
                  value = {ccode}
                  onChange={(e) => setCcode(e.target.value)}
                  error = { isFormInvalid }
                  label="Company code"
                  id="ccode"
                />
                 <Stack sx={{display:"flex", justifyContent:"center", alignItems:"center"}} spacing={1} direction={'row'}>
                <VioletBorderTextField
                  required
                  fullWidth
                  value = {pwd}
                  onChange={(e) => setPwd(e.target.value)}
                  error = { isFormInvalid }
                  label="Password"
                  type="password"
                  id="password"
                />
                <VioletBorderTextField
                  required
                  fullWidth
                  
                  onChange={(e) => setRpwd(e.target.value)}
                  error = { isFormInvalid }
                  label="Repeat Password"
                  type="password"
                  id="rPassword"
                />
                </Stack>
                <Stack sx={{display:"flex", justifyContent:"center", alignItems:"center"}} spacing={1} direction={'row'}>
                <VioletBorderTextField
                  required
                  fullWidth
                  value = {username}
                  onChange={(e) => setUsername(e.target.value)}
                  error = { isFormInvalid }
                  label="Username"
                  id="username"
                />
                <VioletBorderTextField
                  required
                  fullWidth
                  value = {email}
                  onChange={(e) => setEmail(e.target.value)}
                  error = { isFormInvalid }
                  label="E-mail address"
                  id="email"
                />
                </Stack>
                <VioletBorderTextField
                  required
                  fullWidth
                  value = {caddress}
                  onChange={(e) => setCaddress(e.target.value)}
                  error = { isFormInvalid }
                  label="Company address"
                  id="caddress"
                  helperText={isFormInvalid && "The email must be a valid email, the company code must have 10 characters, the passwords must match, also an account may be already exist!"}
                />
                </Stack>
                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  sx={{ mt: 3, mb: 2 }}
                  style={{backgroundColor: '#c239eb', color: 'white'}}
                >
                  Sign up
                </Button>
                <Grid container>
                  <Grid item>
                    <Link component={lk} to="/login" variant="body2">
                      {"Do you have an account? Log in now"}
                    </Link>
                  </Grid>
                </Grid>
                <Copyright sx={{ mt: 5 }} />
              </Box>
            </Box>
          </Grid>
        </Grid>
      </ThemeProvider>
    );
  }

export default Registration;
