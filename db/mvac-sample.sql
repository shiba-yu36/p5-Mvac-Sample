DROP TABLE if EXISTS `products`;
CREATE TABLE `products` (
       `id` int(11) unsigned auto_increment NOT NULL,
       `title` tinytext,
       `description` text,
       `type` varbinary(20),
       `order_num` smallint,
       `small_image_url` text,
       `large_image_url` text,
       `created_at` timestamp NOT NULL default '0000-00-00 00:00:00',
       `updated_at` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
       PRIMARY KEY (`id`)
);