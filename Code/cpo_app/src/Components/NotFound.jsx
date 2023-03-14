import { useEffect } from 'react';
import { Link } from "react-router-dom";
import NotFoundLogo from '../Images/NotFoundLogo.png';
import bg from "../Images/NotFoundBg.png";

import Button from '@mui/material/Button';

/**
 * The 404 not found page
 * it is displayed when the user
 * inserts a wrong address.
 */
export default function NotFound() {
    useEffect(() => {
        document.body.style.backgroundImage = `url('${bg}')`;
    }, []);

    return (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '90vh', }}>
            <div style={{backgroundColor: 'white', borderRadius: '50px', padding:'50px'}}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center'}}> 
                    <img src={NotFoundLogo} alt="404 Not Found" />
                </div>
                <Link to="/Login">
                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  sx={{ mt: 3, mb: 2 }}
                  style={{backgroundColor: '#c239eb', color: 'white'}}>
                    Take me home!</Button>
                </Link>
            </div>
        </div>
    )
}