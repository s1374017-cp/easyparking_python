CREATE TABLE `bookings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `spot_id` int NOT NULL,
  `driver_id` int NOT NULL,
  `owner_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `status` enum('pending','accepted','in_use','completed','cancelled') DEFAULT 'pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `spot_id` (`spot_id`),
  KEY `driver_id` (`driver_id`),
  KEY `owner_id` (`owner_id`),
  CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`spot_id`) REFERENCES `parking_spots` (`id`),
  CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci


CREATE TABLE `car_park_basic_info` (
  `park_id` varchar(20) NOT NULL,
  `name_en` varchar(200) DEFAULT NULL,
  `name_tc` varchar(200) DEFAULT NULL,
  `name_sc` varchar(200) DEFAULT NULL,
  `displayaddress_en` varchar(200) DEFAULT NULL,
  `displayaddress_tc` varchar(200) DEFAULT NULL,
  `displayaddress_sc` varchar(200) DEFAULT NULL,
  `latitude` double(13,10) DEFAULT NULL,
  `longitude` double(13,10) DEFAULT NULL,
  `district_en` varchar(40) DEFAULT NULL,
  `district_tc` varchar(40) DEFAULT NULL,
  `district_sc` varchar(40) DEFAULT NULL,
  `contactNo` varchar(500) DEFAULT NULL,
  `opening_status` varchar(5) DEFAULT NULL,
  `height` double(3,1) DEFAULT NULL,
  `remark_en` varchar(4000) DEFAULT NULL,
  `remark_tc` varchar(4000) DEFAULT NULL,
  `remark_sc` varchar(4000) DEFAULT NULL,
  `website_en` varchar(100) DEFAULT NULL,
  `website_tc` varchar(100) DEFAULT NULL,
  `website_sc` varchar(100) DEFAULT NULL,
  `carpark_photo` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`park_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci


CREATE TABLE `car_park_current_status` (
  `park_id` varchar(20) NOT NULL,
  `lastupdate` datetime DEFAULT NULL,
  `vacancy` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`park_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci

CREATE TABLE `car_park_historical_info` (
  `park_id` varchar(50) NOT NULL,
  `lastupdate` datetime NOT NULL,
  `vehicle_type` varchar(50) NOT NULL,
  `service_category` varchar(50) NOT NULL,
  `vacancy_type` varchar(50) NOT NULL,
  `vacancy` int NOT NULL,
  PRIMARY KEY (`park_id`,`lastupdate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci

CREATE TABLE `car_park_vacancy_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `park_id` varchar(20) NOT NULL,
  `lastupdate` datetime NOT NULL,
  `vehicle_type` char(3) NOT NULL,
  `service_category` varchar(30) NOT NULL,
  `vacancy_type` char(3) NOT NULL,
  `vacancy` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `park_id` (`park_id`),
  CONSTRAINT `car_park_vacancy_info_ibfk_1` FOREIGN KEY (`park_id`) REFERENCES `car_park_basic_info` (`park_id`)
) ENGINE=InnoDB AUTO_INCREMENT=150026 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci

CREATE TABLE `car_park_vacancy_probability` (
  `park_id` varchar(20) NOT NULL,
  `slot` tinyint NOT NULL,
  `p_availability` float DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`park_id`,`slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci

CREATE TABLE `owner_parking_bookings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `driver_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '司机用户ID',
  `parking_id` int NOT NULL,
  `time_slot_id` int NOT NULL COMMENT '关联的时间段ID',
  `start_time` datetime NOT NULL COMMENT '预约开始时间',
  `end_time` datetime NOT NULL COMMENT '预约结束时间',
  `status` enum('pending','confirmed','cancelled','completed') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `total_price` decimal(10,2) DEFAULT NULL COMMENT '总费用',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_driver` (`driver_id`),
  KEY `idx_parking` (`parking_id`),
  KEY `idx_time_slot` (`time_slot_id`),
  KEY `idx_booking_time` (`start_time`,`end_time`),
  CONSTRAINT `owner_parking_bookings_ibfk_1` FOREIGN KEY (`parking_id`) REFERENCES `owner_parking_info` (`parking_id`) ON DELETE CASCADE,
  CONSTRAINT `owner_parking_bookings_ibfk_2` FOREIGN KEY (`time_slot_id`) REFERENCES `owner_parking_time_slots` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci

CREATE TABLE `owner_parking_info` (
  `parking_id` int NOT NULL AUTO_INCREMENT,
  `owner_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '车主用户ID',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '停车位位置描述',
  `description` text COLLATE utf8mb4_unicode_ci,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `price` decimal(10,2) DEFAULT NULL COMMENT '每小时价格',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否激活',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`parking_id`),
  KEY `idx_owner` (`owner_id`),
  KEY `idx_location` (`latitude`,`longitude`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci

CREATE TABLE `owner_parking_time_slots` (
  `id` int NOT NULL AUTO_INCREMENT,
  `parking_id` int NOT NULL,
  `start_time` datetime NOT NULL COMMENT '可用开始时间',
  `end_time` datetime NOT NULL COMMENT '可用结束时间',
  `is_available` tinyint(1) DEFAULT '1' COMMENT '是否可用',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_parking_id` (`parking_id`),
  KEY `idx_time_range` (`start_time`,`end_time`),
  CONSTRAINT `owner_parking_time_slots_ibfk_1` FOREIGN KEY (`parking_id`) REFERENCES `owner_parking_info` (`parking_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci

CREATE TABLE `parking_records` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户ID',
  `latitude` decimal(10,6) NOT NULL COMMENT '停车点纬度',
  `longitude` decimal(10,6) NOT NULL COMMENT '停车点经度',
  `parking_time` datetime NOT NULL COMMENT '停车时间（入场时间）',
  `area` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '停车区域名称或行政区',
  `is_shared` tinyint(1) DEFAULT '0' COMMENT '是否为共享车位（TRUE为共享）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='停车记录数据表'

CREATE TABLE `parking_spots` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owner_id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `address` varchar(200) NOT NULL,
  `latitude` double NOT NULL,
  `longitude` double NOT NULL,
  `description` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `owner_id` (`owner_id`),
  CONSTRAINT `parking_spots_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci

CREATE TABLE `spot_availabilities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `spot_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `spot_id` (`spot_id`),
  CONSTRAINT `spot_availabilities_ibfk_1` FOREIGN KEY (`spot_id`) REFERENCES `parking_spots` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci


CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(128) NOT NULL,
  `password_hash` varchar(128) NOT NULL,
  `user_type` enum('owner','driver') NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=1003 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci