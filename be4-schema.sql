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

-- -------------
--   OBJECTS
-- -------------

CREATE TABLE object_types (

  id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name TINYTEXT NOT NULL                COMMENT 'object type name',
  module_name VARCHAR(100)              COMMENT 'default module for object type',

  PRIMARY KEY (id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'obect types definition';


CREATE TABLE objects (

  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  type_id SMALLINT UNSIGNED NOT NULL        COMMENT 'object type id',
  status ENUM('on', 'off', 'draft', 'deleted') NOT NULL default 'draft'  COMMENT 'object status: on, draft, off, deleted',
  uname VARCHAR(255) NOT NULL               COMMENT 'unique and url friendly resource name (slug)',
  locked BOOLEAN NOT NULL default 0         COMMENT 'locked flag: some fields (status, uname,...) cannot be changed',
  created DATETIME NOT NULL                 COMMENT 'creation date',
  modified DATETIME NOT NULL                COMMENT 'last modification date',
  published DATETIME NOT NULL               COMMENT 'publication date, status set to ON',
  title TEXT NULL,
  description MEDIUMTEXT NULL,
  body MEDIUMTEXT NULL,
  extra MEDIUMTEXT NULL                     COMMENT 'object data extensions (JSON format)',
  lang CHAR(3) NOT NULL                     COMMENT 'language used, ISO 639-3 code',
  created_by INTEGER UNSIGNED NOT NULL      COMMENT 'user who created object',
  modified_by INTEGER UNSIGNED NOT NULL     COMMENT 'last user to modify object',
  publish_start DATETIME NULL               COMMENT 'publish from this date on',
  publish_end DATETIME NULL                 COMMENT 'publish until this date',

  PRIMARY KEY (id),
  UNIQUE KEY (uname),
  INDEX (type_id),

  FOREIGN KEY(type_id)
    REFERENCES object_types(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

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


-- -------------
--   RELATIONS
-- -------------

CREATE TABLE relation_definitions (

  name VARCHAR(255) NOT NULL            COMMENT 'relation name',
  label TEXT NOT NULL                   COMMENT 'relation label',
  inverse_name VARCHAR(255) NOT NULL    COMMENT 'inverse relation name',
  inverse_label TEXT NOT NULL           COMMENT 'inverse relation label',
  params MEDIUMTEXT NULL                COMMENT 'relation parameters definitions (JSON format)',

  PRIMARY KEY (name),
  UNIQUE KEY (inverse_name)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'object relations definitions';

-- Types in a relation
CREATE TABLE relation_types (

  name VARCHAR(255) NOT NULL                COMMENT 'relation name',
  type_id SMALLINT UNSIGNED NOT NULL        COMMENT 'object type id',
  position ENUM ('left', 'right') NOT NULL  COMMENT 'type position in relation',

  PRIMARY KEY name_type_position (name, type_id, position),
  
  FOREIGN KEY(name)
    REFERENCES relation_definitions(name)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(type_id)
    REFERENCES object_types(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'type constraints in object relations';


CREATE TABLE relations (

  left_id INT UNSIGNED NOT NULL         COMMENT 'left part of the relation object id',
  name VARCHAR(255) NOT NULL            COMMENT 'relation name',
  right_id INT UNSIGNED NOT NULL        COMMENT 'right part of the relation object id',
  inv_name VARCHAR(255) NOT NULL        COMMENT 'inverse relation name',
  priority INT UNSIGNED NOT NULL        COMMENT 'priority order in relation',
  inv_priority INT UNSIGNED NOT NULL    COMMENT 'priority order in inverse relation',
  params MEDIUMTEXT NULL                COMMENT 'relation parameters (JSON format)',

  PRIMARY KEY left_name_right (left_id, name, right_id),
  INDEX (left_id),
  INDEX (right_id),

  FOREIGN KEY(left_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(right_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(name)
    REFERENCES relation_definitions(name)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'relations between objects';


-- -------------
--   TREE
-- -------------

CREATE TABLE trees (

  object_id INT UNSIGNED NOT NULL       COMMENT 'object id',
  parent_id INT UNSIGNED NULL           COMMENT 'parent object id',
  root_id INT UNSIGNED NOT NULL         COMMENT 'root id (for tree scoping)',
  tree_left INT NOT NULL                COMMENT 'left counter (for nested set model)',
  tree_right INT NOT NULL               COMMENT 'right counter (for nested set model)',
  depth INT UNSIGNED NOT NULL           COMMENT 'depth',
  menu INT UNSIGNED NOT NULL DEFAULT 1  COMMENT 'menu on/off',

  PRIMARY KEY(parent_id, object_id),
  INDEX object_parent (object_id, parent_id),
  INDEX root_left (root_id, tree_left),
  INDEX root_right (root_id, tree_right),
  INDEX (menu),

  FOREIGN KEY(object_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(parent_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(root_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'tree structure';
