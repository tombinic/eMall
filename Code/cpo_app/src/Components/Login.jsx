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
import FancyCheckbox from './FancyCheckbox.jsx';
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

const Login = () => {
    const { setAuth } = useContext(AuthContext);
    const [user, setUser] = useState('')
    const [pwd, setPwd] = useState('');
    const navigate = useNavigate();
    const [isFormInvalid, setIsFormInvalid] = useState(false);
    const [checked, setChecked] = useState(false);

    useEffect(() => {
        document.body.style.backgroundImage = 'None';
        var prevAuth = JSON.parse(localStorage.getItem('auth'));
        if(prevAuth && prevAuth.success) {
            setAuth(prevAuth);
            navigate('/dashboard');
        }

        document.title = "eMall CPMS - Login"
    }, [setAuth, navigate])

    const handleSubmit = (e) => {
      e.preventDefault();
      let hash = sha256(pwd).toString();

      const json = JSON.stringify({ 
        username: user,
        password: hash,
        type: 'cpo'
      });

      axios.post(API_BASE_URL + '/login', json, {
        headers: { 'Content-Type': 'application/json'}
        }).then(function (response) {
          setAuth({
            success: true,
            data: response.data.data[0]
        });

        if(checked){
            localStorage.setItem('auth', JSON.stringify({ success: true,
            data: response.data.data[0],
          }));
        }

        navigate('/dashboard');
      }).catch(function (error) {
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

    const handleCheckOnClick = (e) => {
        const checked = e.target.checked;
        if (checked) {
            setChecked(true);
        } else {
            setChecked(false);
        }
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

    /**
     * This is a functional React component that implements a login form. 
     * It uses Material-UI components such as Grid, Paper, Avatar, Typography, 
     * Box, and Button to render the form. The form consists of two text fields 
     * for username and password and a checkbox for remembering the user's 
     * login information. The form data is managed using state variables - 
     * user and pwd. The form submission is handled using handleSubmit 
     * function. The background image is set using inline styles. 
     * The component also includes a link to the registration page.
     */
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
                my: 8,
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
                CPO Log in
              </Typography>
              <Box component="form" noValidate onSubmit={handleSubmit} sx={{ mt: 1 }}>
                <VioletBorderTextField
                  margin="normal"
                  required
                  fullWidth
                  value = {user}
                  onChange={(e) => setUser(e.target.value)}
                  error = { isFormInvalid }
                  id="username"
                  label="Username"
                  name="username"
                  autoComplete="username"
                  autoFocus                
                  variant="outlined"
                />
                <VioletBorderTextField
                  margin="normal"
                  required
                  fullWidth
                  value = {pwd}
                  onChange={(e) => setPwd(e.target.value)}
                  error = { isFormInvalid }
                  helperText={isFormInvalid && "Wrong username or password!"}
                  name="password"
                  label="Password"
                  type="password"
                  id="password"
                  autoComplete="current-password"
                  variant="outlined"
                />
                <FancyCheckbox label = 'Remember me' onChange = {handleCheckOnClick} />
                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  sx={{ mt: 3, mb: 2 }}
                  style={{backgroundColor: '#c239eb', color: 'white'}}
                >
                  Log In
                </Button>
                <Grid container>
                  <Grid item>
                    <Link component={lk} to="/registration" variant="body2">
                      {"Don't have an account? Register now"}
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

export default Login;