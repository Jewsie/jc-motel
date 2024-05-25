-- Dumping structure for table s80_zombie.jc_motels
CREATE TABLE IF NOT EXISTS `jc_motels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `motel` varchar(200) DEFAULT NULL,
  `room` varchar(200) DEFAULT NULL,
  `uniqueid` varchar(200) DEFAULT NULL,
  `renter` varchar(200) DEFAULT NULL,
  `renterName` varchar(50) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Dumping structure for table s80_zombie.jc_ownedmotels
CREATE TABLE IF NOT EXISTS `jc_ownedmotels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(200) DEFAULT NULL,
  `funds` bigint(20) DEFAULT 0,
  `data` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;