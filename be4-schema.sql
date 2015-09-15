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
  type_id SMALLINT UNSIGNED NOT NULL        COMMENT 'object type id',
  status TINYINT NOT NULL default 0         COMMENT 'object status: on, draft, off',
  uname VARCHAR(255) NOT NULL               COMMENT 'unique and url friendly resource name (slug)',
  created DATETIME NOT NULL                 COMMENT 'creation date',
  modified DATETIME NOT NULL                COMMENT 'last modification date',
  published DATETIME NOT NULL               COMMENT 'publication date, status set to ON',
  title TEXT NOT NULL,
  description MEDIUMTEXT NULL,
  body MEDIUMTEXT NULL,
  extra MEDIUMTEXT NULL                     COMMENT 'object data extensions (JSON format)',
  lang CHAR(3) NOT NULL                     COMMENT 'language used, ISO 639-3 code',
  user_created INTEGER UNSIGNED NOT NULL    COMMENT 'user who created object',
  user_modified INTEGER UNSIGNED NOT NULL   COMMENT 'last user to modify object',
  publish_start DATETIME NULL               COMMENT 'publish from this date on',
  publish_end DATETIME NULL                 COMMENT 'publish until this date',

  PRIMARY KEY (id),
  UNIQUE KEY (uname),
  INDEX (type_id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'base table for all objects';


CREATE TABLE media (

  id INT UNSIGNED NOT NULL,
  uri TEXT NOT NULL                 COMMENT 'media uri: relative path on local filesystem or remote URL',
  name TEXT NULL                    COMMENT 'file name',
  mime_type TINYTEXT NOT NULL       COMMENT 'resource mime type',
  file_size INT(11) UNSIGNED NULL   COMMENT 'file size in bytes (if local)',
  hash_file VARCHAR(255) NULL       COMMENT 'md5 hash of local file',
  original_name TEXT NULL           COMMENT 'original name for uploaded file',
  width MEDIUMINT(6) UNSIGNED NULL  COMMENT '(image) width',
  height MEDIUMINT(6) UNSIGNED NULL COMMENT '(image) height',
  provider  TINYTEXT NULL           COMMENT 'external provider/service name',
  media_uid VARCHAR(255) NULL       COMMENT 'uid, used for remote videos',
  thumbnail TINYTEXT NULL           COMMENT 'remote media thumbnail URL',

  PRIMARY KEY(id),
  INDEX (hash_file),

  FOREIGN KEY(id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'media objects like images, audio, videos, files';


CREATE TABLE relations (

  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  left_id INT UNSIGNED NOT NULL         COMMENT 'left part of the relation object id',
  name VARCHAR(255) NOT NULL            COMMENT 'relation name',
  right_id INT UNSIGNED NOT NULL        COMMENT 'right part of the relation object id',
  inv_name VARCHAR(255) NOT NULL        COMMENT 'inverse relation name',
  params MEDIUMTEXT NULL                COMMENT 'relation parameters (JSON format)',

  PRIMARY KEY (id),
  UNIQUE KEY left_name_right (left_id, name, right_id),
  INDEX (left_id),
  INDEX (right_id),

  FOREIGN KEY(left_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(right_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'relations between objects';
