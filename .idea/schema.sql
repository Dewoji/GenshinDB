create table `character`
(
    name          varchar(50)                                              not null
        primary key,
    level         tinyint                                                  null,
    constellation tinyint                                                  null,
    canHandle     enum ('Sword', 'Claymore', 'Polearm', 'Catalyst', 'Bow') null,
    check (`level` between 1 and 90),
    check (`constellation` between 0 and 6)
);

create table artifact
(
    id            int auto_increment
        primary key,
    `set`         varchar(50)                                                                                                                                                                                                           null,
    level         tinyint                                                                                                                                                                                                               null,
    rarity        tinyint                                                                                                                                                                                                               null,
    slot          enum ('Flower', 'Plume', 'Sands', 'Goblet', 'Circlet')                                                                                                                                                                null,
    mainStatType  enum ('HP', 'HP%', 'ATK', 'ATK%', 'DEF%', 'EM', 'ER%', 'PHYSICAL_DMG%', 'PYRO_DMG%', 'HYDRO_DMG%', 'ELECTRO_DMG%', 'CRYO_DMG%', 'DENDRO_DMG%', 'GEO_DMG%', 'ANEMO_DMG%', 'CRIT_RATE%', 'CRIT_DMG%', 'HEALING_BONUS%') null,
    mainStatValue decimal(6, 2)                                                                                                                                                                                                         null,
    equippedBy    varchar(50)                                                                                                                                                                                                           null,
    constraint artifact_ibfk_1
        foreign key (equippedBy) references `character` (name)
            on delete set null,
    check (`level` between 0 and 20),
    check (`rarity` between 4 and 5),
    check (`mainStatValue` > 0)
);

create index equippedBy
    on artifact (equippedBy);

create table artifactsubstat
(
    id           int                                                                                      not null,
    substatType  enum ('HP', 'HP%', 'ATK', 'ATK%', 'DEF', 'DEF%', 'EM', 'ER%', 'CRIT_RATE%', 'CRIT_DMG%') not null,
    substatValue decimal(5, 2)                                                                            null,
    primary key (id, substatType),
    constraint artifactsubstat_ibfk_1
        foreign key (id) references artifact (id)
            on delete cascade,
    check (`substatValue` > 0)
);

create table weapon
(
    id         int auto_increment
        primary key,
    name       varchar(50)                                                                           null,
    rarity     tinyint                                                                               null,
    refined    tinyint                                                                               null,
    type       enum ('Sword', 'Claymore', 'Polearm', 'Catalyst', 'Bow')                              null,
    statType   enum ('HP%', 'ATK%', 'DEF%', 'EM', 'ER%', 'PHYSICAL_DMG%', 'CRIT_RATE%', 'CRIT_DMG%') null,
    statValue  decimal(5, 2)                                                                         null,
    equippedBy varchar(50)                                                                           null,
    constraint weapon_ibfk_1
        foreign key (equippedBy) references `character` (name)
            on delete set null,
    check (`rarity` between 1 and 5),
    check (`refined` between 1 and 5),
    check (`statValue` > 0)
);

create index equippedBy
    on weapon (equippedBy);

create
    definer = root@localhost procedure canBeEquippedCheck(IN equippingToCharacter varchar(50), IN artifactToEquip int)
BEGIN
        DECLARE artifactSlot varchar(20);
        SELECT slot INTO artifactSlot FROM artifact
            WHERE artifactToEquip =  id;
        IF (SELECT count(*) FROM artifact WHERE slot =  artifactSlot AND equippedBy = equippingToCharacter AND id <> artifactToEquip) >= 1 THEN
            SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'ERROR: Character already has an artifact equipped in this slot.';
        END IF;
    END;

create
    definer = root@localhost function getArtifactCV(artifactID int) returns decimal(5, 2) deterministic
BEGIN
        DECLARE critDamage decimal(5,2) default 0.00;
        DECLARE critRate decimal(5,2) default 0.00;
        SELECT IFNULL(substatValue, 0) INTO critDamage FROM artifactsubstat   /* Posso non mettere IFNULL */
            WHERE substatType = 'CRIT_DMG%' AND id = artifactID;
        SELECT IFNULL(substatValue, 0) INTO critRate FROM artifactsubstat
            WHERE substatType = 'CRIT_RATE%' AND id = artifactID;
        RETURN critRate*2 + critDamage;
    END;

create
    definer = root@localhost procedure validateArtifact(IN artifactSlot varchar(20), IN slotType varchar(20))
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

create
    definer = root@localhost procedure validateSubstat(IN toArtifact int, IN substatToAdd varchar(20))
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

create
    definer = root@localhost procedure weaponHandleChecker(IN equippingToCharacter varchar(50),
                                                           IN weaponTypeToEquip varchar(20))
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

