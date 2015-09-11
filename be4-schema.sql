-- max num characters
-- TINYTEXT     256
-- TEXT         65536
-- MEDIUMTEXT   16777216
-- LONGTEXT     4294967296

-- unsigned max values
-- TINYINT      255
-- SMALLINT     65535
-- MEDIUMINT    16777215
-- INT          4294967295
-- BIGINT       18446744073709551615


CREATE TABLE objects (

  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  type_id SMALLINT UNSIGNED NOT NULL,
  status TINYINT NOT NULL default 0,
  created DATETIME NOT NULL,
  modified DATETIME NOT NULL,
  title TEXT NOT NULL,
  uname TEXT NOT NULL,
  lang CHAR(3) NOT NULL,
  user_created INTEGER UNSIGNED NOT NULL,
  user_modified INTEGER UNSIGNED NOT NULL,
  params MEDIUMTEXT NULL,
  start_date DATETIME NULL ,
  end_date DATETIME NULL,
  description MEDIUMTEXT NULL,
  body MEDIUMTEXT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY (uname),
  INDEX (type_id),
-- TODO: index, 

) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE media (

  id INT UNSIGNED NOT NULL,
  uri TEXT NOT NULL                 COMMENT 'media uri: relative path on local filesystem or remote URL',
  name TEXT NULL                    COMMENT 'file name',
  mime_type TINYTEXT NOT NULL       COMMENT 'resource mime type',
  file_size INT UNSIGNED NULL       COMMENT 'file size in bytes (if local)',
  hash_file VARCHAR(255) NULL       COMMENT 'md5 hash of local file',
  original_name TEXT NULL           COMMENT 'original name for uploaded file',
  width MEDIUMINT(6) UNSIGNED NULL  COMMENT '(image) width',
  height MEDIUMINT(6) UNSIGNED NULL COMMENT '(image) height',

  provider VARCHAR(100) NULL        COMMENT 'external provider/service name',
  media_uid VARCHAR(128) NULL       COMMENT 'uid, used for remote videos',
  thumbnail VARCHAR(255) NULL       COMMENT 'remote media thumbnail URL',

  PRIMARY KEY(id),
  INDEX hash_file_index(hash_file),

  FOREIGN KEY(id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'media objects like images, audio, videos, files';


CREATE TABLE relations (

  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  left_id INT UNSIGNED NOT NULL,
  name TINYTEXT NOT NULL,
  right_id INT UNSIGNED NOT NULL,
  params MEDIUMTEXT NULL,
  inv_name TINYTEXT NOT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY (left_id, name, right_id),
  INDEX (left_id),
  INDEX (right_id)

  FOREIGN KEY(left_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(right_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

);

-- CREATE TABLE trees ();

-- CREATE TABLE categories ();

-- CREATE TABLE dates ();
-- CREATE TABLE labels ();
-- CREATE TABLE locations ();
-- CREATE TABLE codes ();

-- CREATE TABLE groups (
-- CREATE TABLE groups_users (

-- CREATE TABLE hash_jobs ()

-- CREATE TABLE history (

-- CREATE TABLE images (

-- CREATE TABLE links ()

-- CREATE TABLE mail_jobs (
-- CREATE TABLE mail_logs (

-- CREATE TABLE modules (

-- CREATE TABLE object_categories (

-- CREATE TABLE object_editors (
-- CREATE TABLE object_properties (
-- CREATE TABLE object_relations (
-- CREATE TABLE object_types (

-- CREATE TABLE object_users (

-- CREATE TABLE permissions (
-- CREATE TABLE `permission_modules` (
-- CREATE TABLE properties (
-- CREATE TABLE property_options (
-- CREATE TABLE `search_texts` (

-- CREATE TABLE streams (
-- CREATE TABLE user_properties (
-- CREATE TABLE users (
-- CREATE TABLE versions (
-- CREATE TABLE videos (

