create table `character`
(
	name varchar(50) not null
		primary key,
	level tinyint null,
	constellation tinyint null,
	canHandle enum('Sword', 'Claymore', 'Polearm', 'Catalyst', 'Bow') null,
	check (`level` between 1 and 90),
	check (`constellation` between 0 and 6)
);

create table artifact
(
	id int auto_increment
		primary key,
	`set` varchar(50) null,
	level tinyint null,
	rarity tinyint null,
	slot enum('Flower', 'Plume', 'Sands', 'Goblet', 'Circlet') null,
	mainStatType enum('HP', 'HP%', 'ATK', 'ATK%', 'DEF%', 'EM', 'ER%', 'PHYSICAL_DMG%', 'PYRO_DMG%', 'HYDRO_DMG%', 'ELECTRO_DMG%', 'CRYO_DMG%', 'DENDRO_DMG%', 'GEO_DMG%', 'ANEMO_DMG%', 'CRIT_RATE%', 'CRIT_DMG%', 'HEALING_BONUS%') null,
	mainStatValue decimal(6,2) null,
	equippedBy varchar(50) null,
	constraint artifact_ibfk_1
		foreign key (equippedBy) references `character` (name)
			on delete set null,
	check (`level` between 0 and 20),
	check (`rarity` between 4 and 5),
	check (`mainStatValue` > 0)
);

create index equippedBy
	on artifact (equippedBy);

create definer = root@localhost trigger canInsertArtifact
	before insert
	on artifact
	for each row
	BEGIN
        CALL validateArtifact(NEW.slot, NEW.mainStatType);
        IF NEW.rarity = 4 AND NEW.level > 16 THEN
            SIGNAL SQLSTATE '45009' SET MESSAGE_TEXT = 'ERROR: Cannot insert artifact. Cause: 4* artifacts can level up to level 16';
        END IF;
        IF NEW.equippedBy IS NOT NULL THEN
            CALL canBeEquippedCheck(NEW.equippedBy, NEW.id);
        END IF;
    END;

create definer = root@localhost trigger canUpdateArtifact
	before update
	on artifact
	for each row
	BEGIN
        IF NEW.mainStatType <> OLD.mainStatType THEN
            SIGNAL SQLSTATE '45008' SET MESSAGE_TEXT = 'ERROR: Cannot update artifact. Cause: Cannot modify Main Stat Type of an existing artifact';
        END IF;
        IF NEW.rarity = 4 AND NEW.level > 16 THEN
            SIGNAL SQLSTATE '45010' SET MESSAGE_TEXT = 'ERROR: Cannot update artifact. Cause: 4* artifacts can level up to level 16';
        END IF;
        IF NEW.equippedBy IS NOT NULL AND (OLD.equippedBy IS NULL OR NEW.equippedBy <> OLD.equippedBy) THEN
            CALL canBeEquippedCheck(NEW.equippedBy, NEW.id);
        END IF;
    END;

create table artifactsubstat
(
	id int not null,
	substatType enum('HP', 'HP%', 'ATK', 'ATK%', 'DEF', 'DEF%', 'EM', 'ER%', 'CRIT_RATE%', 'CRIT_DMG%') not null,
	substatValue decimal(5,2) null,
	primary key (id, substatType),
	constraint artifactsubstat_ibfk_1
		foreign key (id) references artifact (id)
			on delete cascade,
	check (`substatValue` > 0)
);

create definer = root@localhost trigger addSubstatI
	before insert
	on artifactsubstat
	for each row
	BEGIN
        call validateSubstat(NEW.id, NEW.substatType);
    END;

create definer = root@localhost trigger updateSubstat
	before update
	on artifactsubstat
	for each row
	BEGIN
        call validateSubstat(NEW.id, NEW.substatType);
    END;

create table weapon
(
	id int auto_increment
		primary key,
	name varchar(50) null,
	rarity tinyint null,
	refined tinyint null,
	level tinyint null,
	type enum('SWORD', 'CLAYMORE', 'POLEARM', 'CATALYST', 'BOW') null,
	statType enum('HP%', 'ATK%', 'DEF%', 'EM', 'ER%', 'PHYSICAL_DMG%', 'CRIT_RATE%', 'CRIT_DMG%') null,
	statValue decimal(5,2) null,
	equippedBy varchar(50) null,
	constraint weapon_ibfk_1
		foreign key (equippedBy) references `character` (name)
			on delete set null,
	check (`rarity` between 1 and 5),
	check (`refined` between 1 and 5),
	check (`statValue` > 0),
	check (`level` between 0 and 90)
);

create index equippedBy
	on weapon (equippedBy);

create definer = root@localhost trigger canEquipWeaponInsert
	before insert
	on weapon
	for each row
	BEGIN
        IF new.equippedBy IS NOT NULL THEN
            CALL weaponHandleChecker(NEW.equippedBy, NEW.type);
        END IF;
        IF (SELECT count(*) FROM weapon WHERE equippedBy = NEW.equippedBy) >= 1 THEN
            SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'ERROR: Character cannot equip this weapon. Cause Character already has a weapon equipped.';
        END IF;
    END;

create definer = root@localhost trigger canEquipWeaponUpdate
	before update
	on weapon
	for each row
	BEGIN
        IF NEW.equippedBy IS NOT NULL AND (OLD.equippedBy IS NULL OR NEW.equippedBy <> OLD.equippedBy) THEN
                CALL weaponHandleChecker(NEW.equippedBy, NEW.type);
            END IF;
        IF (SELECT count(*) FROM weapon WHERE NEW.equippedBy = equippedBy AND id <> NEW.id) >= 1 THEN
            SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'ERROR: Character cannot equip this weapon. Cause Character already has a weapon equipped.';
        END IF;
    END;

create definer = root@localhost view artifactjewels as
	select `genshindb`.`artifact`.`id`                  AS `id`,
       `genshindb`.`artifact`.`set`                 AS `set`,
       `genshindb`.`artifact`.`slot`                AS `slot`,
       `genshindb`.`artifact`.`mainStatType`        AS `mainStatType`,
       `getArtifactCV`(`genshindb`.`artifact`.`id`) AS `critValue`,
       `genshindb`.`artifact`.`equippedBy`          AS `equippedBy`
from `genshindb`.`artifact`
where (`getArtifactCV`(`genshindb`.`artifact`.`id`) >= 35)
order by `getArtifactCV`(`genshindb`.`artifact`.`id`) desc;

create definer = root@localhost procedure canBeEquippedCheck(IN equippingToCharacter varchar(50), IN artifactToEquip int)
BEGIN
        DECLARE artifactSlot varchar(20);
        SELECT slot INTO artifactSlot FROM artifact
            WHERE artifactToEquip =  id;
        IF (SELECT count(*) FROM artifact WHERE slot =  artifactSlot AND equippedBy = equippingToCharacter AND id <> artifactToEquip) >= 1 THEN
            SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'ERROR: Character already has an artifact equipped in this slot.';
        END IF;
    END;

create definer = root@localhost procedure equipArtifactToCharacter(IN idToEquip int, IN characterToEquip varchar(20))
BEGIN
        DECLARE slotToEquip varchar(10);
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                ROLLBACK;
                RESIGNAL;
            END;
        START TRANSACTION;
            SELECT slot INTO slotToEquip FROM artifact WHERE id = idToEquip;
            UPDATE artifact SET equippedBy = NULL WHERE slot = slotToEquip AND equippedBy = characterToEquip;
            UPDATE artifact SET equippedBy = characterToEquip WHERE id = idToEquip;
        COMMIT;
    END;

create definer = root@localhost procedure equipWeaponToCharacter(IN weaponId int, IN characterName varchar(50))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;
    START TRANSACTION;
        UPDATE weapon SET equippedBy = null WHERE equippedBy = characterName;
        UPDATE weapon SET equippedBy = characterName WHERE id = weaponId;
    COMMIT;
end;

create definer = root@localhost function getArtifactCV(artifactID int) returns decimal(5,2) deterministic
BEGIN
        DECLARE critDamage decimal(5,2) default 0.00;
        DECLARE critRate decimal(5,2) default 0.00;
        SELECT IFNULL(substatValue, 0) INTO critDamage FROM artifactsubstat   /* Posso non mettere IFNULL */
            WHERE substatType = 'CRIT_DMG%' AND id = artifactID;
        SELECT IFNULL(substatValue, 0) INTO critRate FROM artifactsubstat
            WHERE substatType = 'CRIT_RATE%' AND id = artifactID;
        RETURN critRate*2 + critDamage;
    END;

create definer = root@localhost procedure getBestArtifactInSlot(IN aSlot varchar(10), IN aMainStat varchar(20), IN s1Type varchar(10), IN s2Type varchar(10), OUT aId int, OUT s1Value decimal(5,2), OUT s2Value decimal(5,2))
BEGIN
        SELECT t.artifactId, t.value1, t.value2 INTO aId, s1Value, s2Value FROM (
            SELECT
                a.id                                                                 AS artifactId,
                SUM(IF(s.substatType = s1Type, s.substatValue, 0))                   AS value1,
                SUM(IF(s.substatType = s2Type, s.substatValue, 0)) AS value2
            FROM artifact a INNER JOIN artifactsubstat s ON a.id = s.id
            WHERE a.slot = aSlot AND a.mainStatType = aMainStat
            GROUP BY a.id
            ) as t
        ORDER BY t.value1 DESC, t.value2 DESC
        LIMIT 1;
    END;

create definer = root@localhost procedure insertArtifact(IN aSet varchar(50), IN aLevel tinyint, IN aRarity tinyint, IN aSlot varchar(10), IN aMainType varchar(20), IN aMainValue decimal(6,2), IN aEquippedBy varchar(50), IN s1Type varchar(10), IN s1Value decimal(5,2), IN s2Type varchar(10), IN s2Value decimal(5,2), IN s3Type varchar(10), IN s3Value decimal(5,2), IN s4Type varchar(10), IN s4Value decimal(5,2))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;
    START TRANSACTION;
        INSERT INTO artifact (`set`, level, rarity, slot, mainStatType, mainStatValue, equippedBy)
            VALUES (aSet,aLevel,aRarity,aSlot,aMainType,aMainValue, aEquippedBy);
        SET @newId = LAST_INSERT_ID();
        INSERT INTO artifactsubstat (id, substatType, substatValue) VALUES (@newId, s1Type, s1Value);
        INSERT INTO artifactsubstat (id, substatType, substatValue) VALUES (@newId, s2Type, s2Value);

        IF s3Type IS NOT NULL AND s3Value IS NOT NULL THEN
            INSERT INTO artifactsubstat (id, substatType, substatValue) VALUES (@newId, s3Type, s3Value);
        END IF;
        IF s4Type IS NOT NULL AND s4Value IS NOT NULL THEN
            INSERT INTO artifactsubstat (id, substatType, substatValue) VALUES (@newId, s4Type, s4Value);
        END IF;
    COMMIT;
END;

create definer = root@localhost procedure insertCharacter(IN nameToInsert varchar(50), IN levelToInsert tinyint, IN constellationToInsert tinyint, IN canHandleToInsert varchar(10))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;
    START TRANSACTION;
        INSERT INTO `character` (name, level, constellation, canHandle) VALUES (nameToInsert, levelToInsert, constellationToInsert, canHandleToInsert);
    COMMIT;
END;

create definer = root@localhost procedure insertWeapon(IN nameToInsert varchar(50), IN rarityToInsert tinyint, IN refinedToInsert tinyint, IN levelToInsert tinyint, IN typeToInsert varchar(10), IN statToInsert varchar(10), IN statValueToInsert decimal(5,2), IN equippedByOptional varchar(50))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;
    START TRANSACTION;
        INSERT INTO weapon (name, rarity, refined, level, type, statType, statValue, equippedBy) VALUES (nameToInsert, rarityToInsert, refinedToInsert, levelToInsert ,typeToInsert, statToInsert,statValueToInsert, NULLIF(equippedByOptional, ''));
    COMMIT;
END;

create definer = root@localhost procedure validateArtifact(IN artifactSlot varchar(20), IN slotType varchar(20))
BEGIN
        DECLARE allowedSands varchar(50) DEFAULT 'HP%,ATK%,DEF%,EM,ER%';
        DECLARE allowedGoblet varchar(150) DEFAULT 'HP%,ATK%,DEF%,EM,PHYSICAL_DMG%,PYRO_DMG%,HYDRO_DMG%,ELECTRO_DMG%,CRYO_DMG%,DENDRO_DMG%,GEO_DMG%,ANEMO_DMG%';
        DECLARE allowedCirclet varchar(100) DEFAULT 'HP%,ATK%,DEF%,EM,CRIT_RATE%,CRIT_DMG%,HEALING_BONUS%';
        CASE
            WHEN artifactSlot = 'Flower' THEN
                IF slotType <> 'HP' THEN
                    SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'ERROR: Cannot insert/update artifact. Cause: Invalid main stat type';
                END IF;
            WHEN artifactSlot = 'Plume' THEN
                IF slotType <> 'ATK' THEN
                    SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'ERROR: Cannot insert/update artifact. Cause: Invalid main stat type';
                END IF;
            WHEN artifactSlot = 'Sands' THEN
                IF FIND_IN_SET(slotType, allowedSands) = 0 THEN
                    SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'ERROR: Cannot insert/update artifact. Cause: Invalid main stat type';
                END IF;
            WHEN artifactSlot = 'Goblet' THEN
                IF FIND_IN_SET(slotType, allowedGoblet) = 0 THEN
                    SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'ERROR: Cannot insert/update artifact. Cause: Invalid main stat type';
                END IF;
            WHEN artifactSlot = 'Circlet' THEN
                IF FIND_IN_SET(slotType, allowedCirclet) = 0 THEN
                    SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'ERROR: Cannot insert/update artifact. Cause: Invalid main stat type';
                END IF;
        END CASE;
    END;

create definer = root@localhost procedure validateSubstat(IN toArtifact int, IN substatToAdd varchar(20))
BEGIN
        DECLARE mainStat varchar(20);
        IF (SELECT count(*) FROM artifactsubstat WHERE id = toArtifact) >= 4 THEN
            SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'ERROR: Cannot add/update substat. Cause: Artifact already has 4 substats.';
        END IF;
        SELECT mainStatType INTO mainStat FROM artifact WHERE id = toArtifact;
        IF mainStat = substatToAdd THEN
            SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'ERROR: Cannot add/update substat. Cause: Artifact cannot have a Substat Type equal to its Main Stat Type.';
        END IF;
        IF  (substatToAdd IN (SELECT substatType FROM artifactsubstat WHERE id = toArtifact)) THEN
            SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'ERROR: Cannot add/update substat. Cause: Artifact cannot have multiple substats of the same type.';
        END IF;
    END;

create definer = root@localhost procedure weaponHandleChecker(IN equippingToCharacter varchar(50), IN weaponTypeToEquip varchar(20))
BEGIN
        DECLARE allowedWeapon varchar(10);
           IF equippingToCharacter IS NOT NULL THEN
               SELECT canHandle INTO allowedWeapon FROM `character`
                   WHERE name = equippingToCharacter;
           END IF;
           IF weaponTypeToEquip <> allowedWeapon THEN
               SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'ERROR: Character cannot equip this weapon. Cause Invalid Weapon Type.';
           END IF;
    END;


