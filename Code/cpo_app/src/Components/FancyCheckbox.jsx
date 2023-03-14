import React from 'react'
import FormControlLabel from '@mui/material/FormControlLabel';
import Checkbox from '@mui/material/Checkbox';

/**
 * The checkbox that we can find in the login
 * @param {*} props some props as the changeHandler and the default status
 */
export default function FancyCheckbox(props) {
    return (
        <FormControlLabel style={{
            color: '#00000099'
        }} control={<Checkbox checked={props.isChecked} onChange={props.onChange}  sx={{
            color: "#00000099",'&.Mui-checked': {color: "#c239eb"},
        }} />} label={props.label} />
    );
}
