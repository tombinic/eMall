import React from 'react';
import socketio from "socket.io-client";
import { WEB_SOCKET_URL } from "../Config.js";

export const socket = socketio.connect(WEB_SOCKET_URL);
export const SocketContext = React.createContext();