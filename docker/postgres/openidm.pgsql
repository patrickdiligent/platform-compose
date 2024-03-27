DROP SCHEMA IF EXISTS openidm CASCADE;
CREATE SCHEMA openidm AUTHORIZATION openidm;

-- -----------------------------------------------------
-- Table openidm.objecttypes
-- -----------------------------------------------------

CREATE TABLE openidm.objecttypes (
  id BIGSERIAL NOT NULL,
  objecttype VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT idx_objecttypes_objecttype UNIQUE (objecttype)
);



-- -----------------------------------------------------
-- Table openidm.genericobjects
-- -----------------------------------------------------

CREATE TABLE openidm.genericobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_genericobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES openidm.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT idx_genericobjects_object UNIQUE (objecttypes_id, objectid)
);
CREATE INDEX idx_genericobjects_reconid on openidm.genericobjects (jsonb_extract_path_text(fullobject, 'reconId'), objecttypes_id);


-- -----------------------------------------------------
-- Table openidm.managedobjects
-- -----------------------------------------------------

CREATE TABLE openidm.managedobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_managedobjects_objectypes FOREIGN KEY (objecttypes_id) REFERENCES openidm.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX idx_managedobjects_object ON openidm.managedobjects (objecttypes_id,objectid);
CREATE INDEX idx_managedobjects_objecttypes ON openidm.managedobjects (objecttypes_id);
-- Note that the next two indices apply only to role objects, as only role objects have a condition or temporalConstraints
CREATE INDEX idx_json_managedobjects_roleCondition ON openidm.managedobjects
    ( jsonb_extract_path_text(fullobject, 'condition') );
CREATE INDEX idx_json_managedobjects_roleTemporalConstraints ON openidm.managedobjects
    ( jsonb_extract_path_text(fullobject, 'temporalConstraints') );


-- -----------------------------------------------------
-- Table openidm.configobjects
-- -----------------------------------------------------

CREATE TABLE openidm.configobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_configobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES openidm.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX idx_configobjects_object ON openidm.configobjects (objecttypes_id,objectid);
CREATE INDEX fk_configobjects_objecttypes ON openidm.configobjects (objecttypes_id);


-- -----------------------------------------------------
-- Table openidm.notificationobjects
-- -----------------------------------------------------

CREATE TABLE openidm.notificationobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_notificationobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES openidm.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX idx_notificationobjects_object ON openidm.notificationobjects (objecttypes_id,objectid);
CREATE INDEX fk_notificationobjects_objecttypes ON openidm.notificationobjects (objecttypes_id);


-- -----------------------------------------------------
-- Table openidm.relationships
-- -----------------------------------------------------

CREATE TABLE openidm.relationships (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  firstresourcecollection VARCHAR(255),
  firstresourceid VARCHAR(56),
  firstpropertyname VARCHAR(100),
  secondresourcecollection VARCHAR(255),
  secondresourceid VARCHAR(56),
  secondpropertyname VARCHAR(100),
  PRIMARY KEY (id),
  CONSTRAINT fk_relationships_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES openidm.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT idx_relationships_object UNIQUE (objectid)
);
CREATE INDEX idx_relationships_first_object ON openidm.relationships ( firstresourcecollection, firstresourceid, firstpropertyname );
CREATE INDEX idx_relationships_second_object ON openidm.relationships ( secondresourcecollection, secondresourceid, secondpropertyname );
CREATE INDEX idx_relationships_originfirst ON openidm.relationships (firstresourceid , firstresourcecollection , firstpropertyname , secondresourceid , secondresourcecollection );
CREATE INDEX idx_relationships_originsecond ON openidm.relationships (secondresourceid , secondresourcecollection , secondpropertyname , firstresourceid , firstresourcecollection );

-- -----------------------------------------------------
-- Table openidm.links
-- -----------------------------------------------------

CREATE TABLE openidm.links (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  linktype VARCHAR(255) NOT NULL,
  linkqualifier VARCHAR(50) NOT NULL,
  firstid VARCHAR(255) NOT NULL,
  secondid VARCHAR(255) NOT NULL,
  PRIMARY KEY (objectid)
);

CREATE UNIQUE INDEX idx_links_first ON openidm.links (linktype, linkqualifier, firstid);
CREATE UNIQUE INDEX idx_links_second ON openidm.links (linktype, linkqualifier, secondid);
CREATE INDEX idx_links_firstid ON openidm.links (firstid);
CREATE INDEX idx_links_secondid ON openidm.links (secondid);

-- -----------------------------------------------------
-- Table openidm.internaluser
-- -----------------------------------------------------

CREATE TABLE openidm.internaluser (
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  pwd VARCHAR(510) DEFAULT NULL,
  PRIMARY KEY (objectid)
);


-- -----------------------------------------------------
-- Table openidm.internalrole
-- -----------------------------------------------------

CREATE TABLE openidm.internalrole (
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  name VARCHAR(64) DEFAULT NULL,
  description VARCHAR(510) DEFAULT NULL,
  temporalConstraints VARCHAR(1024) DEFAULT NULL,
  condition VARCHAR(1024) DEFAULT NULL,
  privs TEXT DEFAULT NULL,
  PRIMARY KEY (objectid)
);


-- -----------------------------------------------------
-- Table openidm.schedulerobjects
-- -----------------------------------------------------
CREATE TABLE openidm.schedulerobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_schedulerobjects_objectypes FOREIGN KEY (objecttypes_id) REFERENCES openidm.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX idx_schedulerobjects_object ON openidm.schedulerobjects (objecttypes_id,objectid);
CREATE INDEX fk_schedulerobjects_objectypes ON openidm.schedulerobjects (objecttypes_id);


-- -----------------------------------------------------
-- Table openidm.uinotification
-- -----------------------------------------------------
CREATE TABLE openidm.uinotification (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  notificationType VARCHAR(255) NOT NULL,
  createDate VARCHAR(38) NOT NULL,
  message TEXT NOT NULL,
  requester VARCHAR(255) NULL,
  receiverId VARCHAR(255) NOT NULL,
  requesterId VARCHAR(255) NULL,
  notificationSubtype VARCHAR(255) NULL,
  PRIMARY KEY (objectid)
);
CREATE INDEX idx_uinotification_receiverId ON openidm.uinotification (receiverId);


-- -----------------------------------------------------
-- Table openidm.clusterobjects
-- -----------------------------------------------------
CREATE TABLE openidm.clusterobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_clusterobjects_objectypes FOREIGN KEY (objecttypes_id) REFERENCES openidm.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX idx_clusterobjects_object ON openidm.clusterobjects (objecttypes_id,objectid);
CREATE INDEX fk_clusterobjects_objectypes ON openidm.clusterobjects (objecttypes_id);

CREATE INDEX idx_jsonb_clusterobjects_timestamp ON openidm.clusterobjects ( jsonb_extract_path_text(fullobject, 'timestamp') );
CREATE INDEX idx_jsonb_clusterobjects_state ON openidm.clusterobjects ( jsonb_extract_path_text(fullobject, 'state') );
CREATE INDEX idx_jsonb_clusterobjects_event_instanceid ON openidm.clusterobjects ( jsonb_extract_path_text(fullobject, 'type'), jsonb_extract_path_text(fullobject, 'instanceId') );

-- -----------------------------------------------------
-- Table openidm.clusteredrecontargetids
-- -----------------------------------------------------

CREATE TABLE openidm.clusteredrecontargetids (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  reconid VARCHAR(255) NOT NULL,
  targetids JSONB NOT NULL,
  PRIMARY KEY (objectid)
);

CREATE INDEX idx_clusteredrecontargetids_reconid ON openidm.clusteredrecontargetids (reconid);

-- -----------------------------------------------------
-- Table openidm.updateobjects
-- -----------------------------------------------------

CREATE TABLE openidm.updateobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_updateobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES openidm.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT idx_updateobjects_object UNIQUE (objecttypes_id, objectid)
);


-- -----------------------------------------------------
-- Table openidm.importobjects
-- -----------------------------------------------------

CREATE TABLE openidm.importobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_importobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES openidm.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT idx_importobjects_object UNIQUE (objecttypes_id, objectid)
);


-- -----------------------------------------------------
-- Table openidm.syncqueue
-- -----------------------------------------------------
CREATE TABLE openidm.syncqueue (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  syncAction VARCHAR(38) NOT NULL,
  resourceCollection VARCHAR(38) NOT NULL,
  resourceId VARCHAR(255) NOT NULL,
  mapping VARCHAR(255) NOT NULL,
  objectRev VARCHAR(38) DEFAULT NULL,
  oldObject JSONB,
  newObject JSONB,
  context JSONB,
  state VARCHAR(38) NOT NULL,
  nodeId VARCHAR(255) DEFAULT NULL,
  createDate VARCHAR(255) NOT NULL,
  PRIMARY KEY (objectid)
);
CREATE INDEX indx_syncqueue_mapping_state_createdate ON openidm.syncqueue (mapping, state, createDate);


-- -----------------------------------------------------
-- Table openidm.locks
-- -----------------------------------------------------

CREATE TABLE openidm.locks (
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  nodeid VARCHAR(255),
  PRIMARY KEY (objectid)
);

CREATE INDEX idx_locks_nodeid ON openidm.locks (nodeid);


-- -----------------------------------------------------
-- Table openidm.files
-- -----------------------------------------------------

CREATE TABLE openidm.files (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  content TEXT,
  PRIMARY KEY (objectid)
);


-- -----------------------------------------------------
-- Table openidm.metaobjects
-- -----------------------------------------------------

CREATE TABLE openidm.metaobjects (
  id BIGSERIAL NOT NULL,
  objecttypes_id BIGINT NOT NULL,
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  fullobject JSONB,
  PRIMARY KEY (id),
  CONSTRAINT fk_metaobjects_objecttypes FOREIGN KEY (objecttypes_id) REFERENCES openidm.objecttypes (id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT idx_metaobjects_object UNIQUE (objecttypes_id, objectid)
);
CREATE INDEX idx_metaobjects_reconid on openidm.metaobjects (jsonb_extract_path_text(fullobject, 'reconId'), objecttypes_id);

-- -----------------------------------------------------
-- Table openidm.reconassoc
-- -----------------------------------------------------

CREATE TABLE openidm.reconassoc (
  objectid VARCHAR(255) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  mapping VARCHAR(255) NOT NULL,
  sourceResourceCollection VARCHAR(255) NOT NULL,
  targetResourceCollection VARCHAR(255) NOT NULL,
  isAnalysis VARCHAR(5) NOT NULL,
  finishTime VARCHAR(38) NULL,
  PRIMARY KEY (objectid)
);
CREATE INDEX idx_reconassoc_mapping ON openidm.reconassoc (mapping);
CREATE INDEX idx_reconassoc_reconId ON openidm.reconassoc (objectid);

-- -----------------------------------------------------
-- Table openidm.reconassocentry
-- -----------------------------------------------------

CREATE TABLE openidm.reconassocentry (
  objectid VARCHAR(38) NOT NULL,
  rev VARCHAR(38) NOT NULL,
  reconId VARCHAR(255) NOT NULL,
  situation VARCHAR(38) NULL,
  action VARCHAR(38) NULL,
  phase VARCHAR(38) NULL,
  linkQualifier VARCHAR(38) NOT NULL,
  sourceObjectId VARCHAR(255) NULL,
  targetObjectId VARCHAR(255) NULL,
  status VARCHAR(38) NOT NULL,
  exception TEXT NULL,
  message TEXT NULL,
  messagedetail TEXT NULL,
  ambiguousTargetObjectIds TEXT NULL,
  PRIMARY KEY (objectid),
  CONSTRAINT fk_reconassocentry_reconassoc_id FOREIGN KEY (reconId) REFERENCES openidm.reconassoc (objectid) ON DELETE CASCADE ON UPDATE NO ACTION
);
CREATE INDEX idx_reconassocentry_situation ON openidm.reconassocentry (situation);

-- -----------------------------------------------------
-- View openidm.reconassocentryview
-- -----------------------------------------------------
CREATE VIEW openidm.reconassocentryview AS
  SELECT
    assoc.objectid as reconId,
    assoc.mapping as mapping,
    assoc.sourceResourceCollection as sourceResourceCollection,
    assoc.targetResourceCollection as targetResourceCollection,
    entry.objectid AS objectid,
    entry.rev AS rev,
    entry.action AS action,
    entry.situation AS situation,
    entry.linkQualifier as linkQualifier,
    entry.sourceObjectId as sourceObjectId,
    entry.targetObjectId as targetObjectId,
    entry.status as status,
    entry.exception as exception,
    entry.message as message,
    entry.messagedetail as messagedetail,
    entry.ambiguousTargetObjectIds as ambiguousTargetObjectIds
  FROM openidm.reconassocentry entry, openidm.reconassoc assoc
  WHERE assoc.objectid = entry.reconid;

-- -----------------------------------------------------
-- Table openidm.relationshipresources
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS openidm.relationshipresources (
  id VARCHAR(255) NOT NULL,
  originresourcecollection VARCHAR(255) NOT NULL,
  originproperty VARCHAR(100) NOT NULL,
  refresourcecollection VARCHAR(255) NOT NULL,
  originfirst BOOL NOT NULL,
  reverseproperty VARCHAR(100),
  PRIMARY KEY ( originresourcecollection, originproperty, refresourcecollection, originfirst ));
