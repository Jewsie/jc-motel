-- --------------------------------------------------------
-- Host:                         176.9.105.230
-- Server version:               10.6.21-MariaDB-0ubuntu0.22.04.2 - Ubuntu 22.04
-- Server OS:                    debian-linux-gnu
-- HeidiSQL Version:             12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table s23_newchance.jc_motels
CREATE TABLE IF NOT EXISTS `jc_motels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `motel` varchar(200) DEFAULT NULL,
  `room` varchar(200) DEFAULT NULL,
  `uniqueid` varchar(200) DEFAULT NULL,
  `renter` varchar(200) DEFAULT NULL,
  `renterName` varchar(50) DEFAULT NULL,
  `stashpassword` varchar(200) NOT NULL DEFAULT '',
  `ledger` int(11) DEFAULT 0,
  `duration` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table s23_newchance.jc_ownedmotels
CREATE TABLE IF NOT EXISTS `jc_ownedmotels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(200) DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `funds` bigint(20) DEFAULT 0,
  `data` longtext NOT NULL DEFAULT '{}',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
