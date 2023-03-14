import * as React from 'react';
import Card from '@mui/material/Card';
import CardActions from '@mui/material/CardActions';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Button from '@mui/material/Button';
import Typography from '@mui/material/Typography';
import { Stack } from '@mui/system';

/**
 * This component represent a generic card used in various menu as
 * the charging station (add function) menu, the dso menu etc...
 * it allows to build a dynamic generic Card, so we can pass as parameter a custom content.
 * also the card can work in some differents configuration expoliting the React conditional rendering.
 * @param {*} props The custom content (props.children) and some customization elements (title, icon etc...)
 */
export default function GenericCard(props) {
  return (
    <Card sx={{ minWidth: '20%', margin:'1%', boxShadow: 3, border: '1px solid #ccc'}}>
      <CardContent>
        <Stack sx={{display:"flex", justifyContent:"center", alignItems:"center"}}>
          <Typography variant="h6" gutterBottom>
            {props.title}
          </Typography>
          <Typography variant="subtitle" gutterBottom sx={{color:'#c239eb'}}>
            {props.subtitle}
          </Typography>
          {props.number !== undefined ?
          <Typography variant="subtitle">
            {"Number: " + props.number}
          </Typography>
          :<div></div> 
          }
        </Stack>
        {props.children}
      </CardContent>
      {!props.children ?
        <CardMedia
          component="img"
          alt="img_not_found"
          height='100vh'
          sx={{ padding: "1", objectFit: "contain" }}
          image={props.icon}
        />
      : <div></div>}
      <CardActions>
        <Button onClick={props.onButtonPress} fullWidth
                type="submit" variant="contained" startIcon={props.buttonIcon} 
                style={{backgroundColor: '#c239eb', color: 'white'}}>
          {props.buttonText}
        </Button>
      </CardActions>
    </Card>
  );
}