
USE DATABASE `arxiv`;

--DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) DEFAULT NULL,
  `email` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `url` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(256) DEFAULT NULL,
  `res_header` text DEFAULT NULL,
  `res_body` text DEFAULT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `content` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `res_header` text DEFAULT NULL,
  `res_body` text DEFAULT NULL,
  `created_on` timestamp NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `url_content` (
  `url_id` int(10) unsigned NOT NULL,
);
