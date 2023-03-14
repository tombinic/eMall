-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Feb 05, 2023 alle 23:42
-- Versione del server: 10.4.22-MariaDB
-- Versione PHP: 8.1.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `emall`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `booking`
--

CREATE TABLE `booking` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `enduser_id` varchar(256) NOT NULL,
  `chargingsocket_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `booking`
--

INSERT INTO `booking` (`id`, `date`, `start`, `end`, `enduser_id`, `chargingsocket_id`) VALUES
(33, '2023-02-06', '22:00:00', '23:00:00', 'balestrieriNiccolò', 43),
(34, '2023-02-06', '23:00:00', '00:00:00', 'nico00', 43);

-- --------------------------------------------------------

--
-- Struttura della tabella `chargingsocket`
--

CREATE TABLE `chargingsocket` (
  `id` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `type` varchar(30) NOT NULL,
  `status` varchar(15) NOT NULL,
  `price` float NOT NULL,
  `chargingstation_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `chargingsocket`
--

INSERT INTO `chargingsocket` (`id`, `number`, `type`, `status`, `price`, `chargingstation_id`) VALUES
(39, 1, 'Fast charge', 'free', 0.22, 35),
(40, 2, 'Rapid charge', 'free', 0.22, 35),
(41, 3, 'Slow charge', 'free', 0.22, 35),
(43, 1, 'Fast charge', 'free', 0.45, 37),
(44, 2, 'Slow charge', 'free', 0.45, 37),
(45, 3, 'Rapid charge', 'free', 0.45, 37),
(59, 1, 'Fast charge', 'free', 0.33, 43),
(60, 2, 'Slow charge', 'free', 0.33, 43),
(61, 3, 'Fast charge', 'free', 0.33, 43),
(67, 1, 'Fast charge', 'free', 0.55, 45),
(68, 2, 'Slow charge', 'free', 0.55, 45),
(69, 3, 'Rapid charge', 'free', 0.55, 45),
(70, 1, 'Fast Charge', 'free', 0.55, 46),
(71, 2, 'Rapid charge', 'free', 0.55, 46),
(72, 1, 'Fast charge', 'free', 0.5, 47),
(73, 50, 'Slow charge', 'free', 0.45, 47);

-- --------------------------------------------------------

--
-- Struttura della tabella `chargingstation`
--

CREATE TABLE `chargingstation` (
  `id` int(11) NOT NULL,
  `name` varchar(256) NOT NULL,
  `address` varchar(256) NOT NULL,
  `battery_percentage` float NOT NULL,
  `battery_capacity` float NOT NULL,
  `cpo_id` varchar(10) NOT NULL,
  `mode` varchar(10) NOT NULL,
  `dso_id` varchar(256) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `chargingstation`
--

INSERT INTO `chargingstation` (`id`, `name`, `address`, `battery_percentage`, `battery_capacity`, `cpo_id`, `mode`, `dso_id`) VALUES
(35, 'Enel X', 'Via Buca, 12, Neviano degli Arduini', 100, 1234, '0521052105', 'auto', 'AGIP-Energy SPA'),
(37, 'Tesla', 'Strada Cartiera, Vigatto, 3, Parma', 100, 3456, '0521052105', 'auto', 'AGIP-Energy SPA'),
(43, 'BeCharge', 'Via Edoardo Bassini, 12, Milano', 100, 1234, '0521052105', 'auto', 'AGIP-Energy SPA'),
(45, 'Enel X', 'Via Camillo Golgi, 12, Milano', 100, 2345, '0521052105', 'auto', 'ENI-E'),
(46, 'Enel X', 'Via Giacomo Leopardi, 5, Cernusco sul Naviglio', 100, 345, '0521052105', 'auto', 'AGIP-Energy SPA'),
(47, 'BeCharge', 'Via Milano, 3, Colorno', 100, 123, '0521052105', 'battery', 'Texaco-Mobility');

-- --------------------------------------------------------

--
-- Struttura della tabella `cpo`
--

CREATE TABLE `cpo` (
  `company_code` varchar(10) NOT NULL,
  `username` varchar(256) NOT NULL,
  `name` varchar(256) NOT NULL,
  `surname` varchar(256) NOT NULL,
  `email` varchar(256) NOT NULL,
  `password` varchar(256) NOT NULL,
  `company_address` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `cpo`
--

INSERT INTO `cpo` (`company_code`, `username`, `name`, `surname`, `email`, `password`, `company_address`) VALUES
('0521052105', 'A.Bertogalli', 'Andrea', 'Bertogalli', 'andrea.bertogalli@mail.polimi.it', '2d711642b726b04401627ca9fbac32f5c8530fb1903cc4db02258717921a4881', 'Via Giacomo Leopardi, 3/5, Cernusco sul Naviglio');

-- --------------------------------------------------------

--
-- Struttura della tabella `creditcardownership`
--

CREATE TABLE `creditcardownership` (
  `enduser_id` varchar(256) NOT NULL,
  `paymentmethod_id` varchar(19) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `creditcardownership`
--

INSERT INTO `creditcardownership` (`enduser_id`, `paymentmethod_id`) VALUES
('balestrieriNiccolò', '4444 4444 4444 4444'),
('balestrieriNiccolò', '5555 5555 5555 5555'),
('balestrieriNiccolò', '2222 2222 2222 2222'),
('balestrieriNiccolò', '1111 1111 1111 1111'),
('berto', '1234 5888 8449 4444');

-- --------------------------------------------------------

--
-- Struttura della tabella `dso`
--

CREATE TABLE `dso` (
  `name` varchar(256) NOT NULL,
  `energy_price` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `dso`
--

INSERT INTO `dso` (`name`, `energy_price`) VALUES
('AGIP-Energy SPA', 0.34),
('ENI-E', 0.55),
('Q8-Energy', 0.23),
('Tamoil-Energy', 0.12),
('Texaco-Mobility', 0.23);

-- --------------------------------------------------------

--
-- Struttura della tabella `enduser`
--

CREATE TABLE `enduser` (
  `username` varchar(256) NOT NULL,
  `name` varchar(256) NOT NULL,
  `surname` varchar(256) NOT NULL,
  `email` varchar(256) NOT NULL,
  `password` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `enduser`
--

INSERT INTO `enduser` (`username`, `name`, `surname`, `email`, `password`) VALUES
('balestrieriNiccolò', 'nicolo', 'tombini', 'berto@outlook.it', '4e200535b4d24af06e23f1b233526ca6a34b55154ccfe703e60613d27ac958c1'),
('berto', 'Andrea', 'Bertogalli', 'andrea.bertogalli@mail.polimi.it', '6e8231a30cabc809267d879decf5495a3baf4b95700791dfd99879c0426b8e19'),
('nico00', 'Niccolo', 'Balestrieri', 'Niccolo.balestrieri@gmail.com', '6e8231a30cabc809267d879decf5495a3baf4b95700791dfd99879c0426b8e19');

-- --------------------------------------------------------

--
-- Struttura della tabella `paymentmethod`
--

CREATE TABLE `paymentmethod` (
  `card_number` varchar(19) NOT NULL,
  `cvv` varchar(3) NOT NULL,
  `expired_date` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `paymentmethod`
--

INSERT INTO `paymentmethod` (`card_number`, `cvv`, `expired_date`) VALUES
('1111 1111 1111 1111', '111', '11/24'),
('1234 5888 8449 4444', '333', '05/29'),
('2222 2222 2222 2222', '123', '11/24'),
('4444 4444 4444 4444', '123', '12/32'),
('5555 5555 5555 5555', '234', '12/23');

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_enduser_booking` (`enduser_id`),
  ADD KEY `fk_charginstation_chargingsocket` (`chargingsocket_id`);

--
-- Indici per le tabelle `chargingsocket`
--
ALTER TABLE `chargingsocket`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_installation` (`chargingstation_id`);

--
-- Indici per le tabelle `chargingstation`
--
ALTER TABLE `chargingstation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_cpo_cs` (`cpo_id`),
  ADD KEY `fk_dso_cs` (`dso_id`);

--
-- Indici per le tabelle `cpo`
--
ALTER TABLE `cpo`
  ADD PRIMARY KEY (`company_code`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indici per le tabelle `creditcardownership`
--
ALTER TABLE `creditcardownership`
  ADD KEY `fk_enduser_cc` (`enduser_id`),
  ADD KEY `fk_paymentmethod_cc` (`paymentmethod_id`);

--
-- Indici per le tabelle `dso`
--
ALTER TABLE `dso`
  ADD PRIMARY KEY (`name`);

--
-- Indici per le tabelle `enduser`
--
ALTER TABLE `enduser`
  ADD PRIMARY KEY (`username`);

--
-- Indici per le tabelle `paymentmethod`
--
ALTER TABLE `paymentmethod`
  ADD PRIMARY KEY (`card_number`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `booking`
--
ALTER TABLE `booking`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT per la tabella `chargingsocket`
--
ALTER TABLE `chargingsocket`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;

--
-- AUTO_INCREMENT per la tabella `chargingstation`
--
ALTER TABLE `chargingstation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `fk_charginstation_chargingsocket` FOREIGN KEY (`chargingsocket_id`) REFERENCES `chargingsocket` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_enduser_booking` FOREIGN KEY (`enduser_id`) REFERENCES `enduser` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `chargingsocket`
--
ALTER TABLE `chargingsocket`
  ADD CONSTRAINT `fk_installation` FOREIGN KEY (`chargingstation_id`) REFERENCES `chargingstation` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `chargingstation`
--
ALTER TABLE `chargingstation`
  ADD CONSTRAINT `fk_cpo_cs` FOREIGN KEY (`cpo_id`) REFERENCES `cpo` (`company_code`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_dso_cs` FOREIGN KEY (`dso_id`) REFERENCES `dso` (`name`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limiti per la tabella `creditcardownership`
--
ALTER TABLE `creditcardownership`
  ADD CONSTRAINT `fk_enduser_cc` FOREIGN KEY (`enduser_id`) REFERENCES `enduser` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_paymentmethod_cc` FOREIGN KEY (`paymentmethod_id`) REFERENCES `paymentmethod` (`card_number`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
