import * as React from 'react';
import Avatar from '@mui/material/Avatar';

function stringToColor(string) {
  let hash = 0;
  let i;

  for (i = 0; i < string.length; i += 1) {
    hash = string.charCodeAt(i) + ((hash << 5) - hash);
  }

  let color = '#';

  for (i = 0; i < 3; i += 1) {
    const value = (hash >> (i * 8)) & 0xff;
    color += `00${value.toString(16)}`.slice(-2);
  }

  return color;
}

function stringAvatar(name) {
  return {
    sx: {
      bgcolor: stringToColor(name),
    },
    children: `${name.split(' ')[0][0]}${name.split(' ')[1][0]}`,
  };
}

/**
 * This component is the upper right avatar icon, which is clickable
 * and allows to logout.
 * @param {*} props Some propersties, as the username of the logged user
 */
export default function FancyAvatar(props) {
  return (
      <Avatar {...stringAvatar(props.name.toUpperCase())} />
  );
}