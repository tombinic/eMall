import * as React from 'react';
import Box from '@mui/material/Box';
import Modal from '@mui/material/Modal';
import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';

const style = {
  position: 'absolute',
  top: '50%',
  left: '50%',
  transform: 'translate(-50%, -50%)',
  width: '60%',
  height: '90%',
  bgcolor: 'background.paper',
  border: '1px solid #ccc',
  borderRadius: '20px',
  boxShadow: 24,
  p: 4,
  pt:1,
};


/**
 * This component models the modal which pops up, and hovers the main pages
 * is used in the charging station menu, it allows custom content so it is a generic component.
 * @param {*} props The custom content (props.chilren) and some handlers
 */
export default function GenericModal(props) {
  return (
    <div>
      <Modal
        open={props.open}
        onClose={props.handleClose}
        aria-labelledby="modal-modal-title"
        aria-describedby="modal-modal-description"
      >
        <Box sx={style}>
        <Toolbar sx={{top:'0', justifyContent: 'space-between',  borderBottom: '1px solid #ccc'}}>
            <Typography variant="h6" gutterBottom>
              {props.title}
            </Typography>
            <IconButton aria-label="close" onClick={props.handleClose}>
              <CloseIcon />
            </IconButton>
          </Toolbar>
          <Box sx={{  display:"flex", justifyContent:"center", alignItems:"center"}}>
          {props.children}
          </Box>
        </Box>
      </Modal>
    </div>
  );
}