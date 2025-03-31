-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : lun. 31 mars 2025 à 20:58
-- Version du serveur : 9.1.0
-- Version de PHP : 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `mediatek86`
--

-- --------------------------------------------------------

--
-- Structure de la table `abonnement`
--

DROP TABLE IF EXISTS `abonnement`;
CREATE TABLE IF NOT EXISTS `abonnement` (
  `id` varchar(5) COLLATE utf8mb4_general_ci NOT NULL,
  `dateFinAbonnement` date DEFAULT NULL,
  `idRevue` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idRevue` (`idRevue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `abonnement`
--

INSERT INTO `abonnement` (`id`, `dateFinAbonnement`, `idRevue`) VALUES
('00001', '2025-04-09', '10001'),
('00004', '2023-04-25', '10001'),
('00020', '2023-04-28', '10001'),
('00900', '2023-04-09', '10001');

--
-- Déclencheurs `abonnement`
--
DROP TRIGGER IF EXISTS `abonnement_insert_to_commande`;
DELIMITER $$
CREATE TRIGGER `abonnement_insert_to_commande` BEFORE INSERT ON `abonnement` FOR EACH ROW BEGIN
  DECLARE cnt INT;
  SELECT COUNT(*) INTO cnt
  FROM commande
  WHERE id = NEW.id;

  IF cnt = 0 THEN
    INSERT INTO commande (id) VALUES (NEW.id);
  END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `delete_abonnement_to_commande`;
DELIMITER $$
CREATE TRIGGER `delete_abonnement_to_commande` AFTER DELETE ON `abonnement` FOR EACH ROW BEGIN
   DELETE FROM commande WHERE id = OLD.id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

DROP TABLE IF EXISTS `commande`;
CREATE TABLE IF NOT EXISTS `commande` (
  `id` varchar(5) COLLATE utf8mb4_general_ci NOT NULL,
  `dateCommande` date DEFAULT NULL,
  `montant` double DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`id`, `dateCommande`, `montant`) VALUES
('00001', '2023-02-28', 25),
('00002', '2023-03-12', 150),
('00003', '2023-02-27', 30),
('00004', '2023-01-31', 23),
('00005', '2023-02-27', 20),
('00007', '2023-03-28', 80),
('00008', '2023-03-16', 30),
('00009', '2023-03-24', 90),
('00012', '2023-02-27', 30),
('00020', '2023-01-30', 23),
('00055', '2025-03-31', 30),
('00078', '2025-03-31', 100),
('00900', '2022-12-26', 30),
('25', '2024-03-21', 1555);

-- --------------------------------------------------------

--
-- Structure de la table `commandedocument`
--

DROP TABLE IF EXISTS `commandedocument`;
CREATE TABLE IF NOT EXISTS `commandedocument` (
  `id` varchar(5) COLLATE utf8mb4_general_ci NOT NULL,
  `nbExemplaire` int DEFAULT NULL,
  `idLivreDvd` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `idSuivi` char(5) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idLivreDvd` (`idLivreDvd`),
  KEY `idSuivi` (`idSuivi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `commandedocument`
--

INSERT INTO `commandedocument` (`id`, `nbExemplaire`, `idLivreDvd`, `idSuivi`) VALUES
('00001', 2, '00001', '00002'),
('00002', 5, '00001', '00003'),
('00005', 2, '00001', '00003'),
('00007', 3, '20001', '00001'),
('00008', 2, '20001', '00002'),
('00009', 2, '20001', '00004'),
('00012', 2, '20002', '00002'),
('00055', 3, '00013', '00002'),
('00078', 10, '00004', '00002'),
('25', 4, '00014', '00003');

--
-- Déclencheurs `commandedocument`
--
DROP TRIGGER IF EXISTS `creer_exemplaire_tuples_si_commandelivree`;
DELIMITER $$
CREATE TRIGGER `creer_exemplaire_tuples_si_commandelivree` AFTER UPDATE ON `commandedocument` FOR EACH ROW BEGIN
    DECLARE compteur INTEGER ;
    DECLARE dateAchatExemplaire DATE ;
    DECLARE nbExemplaire INTEGER ;
    DECLARE maxNumeroExemplaire INTEGER ;
    DECLARE newNumeroExemplaire INTEGER ;

    SET compteur = 0 ;
    SET dateAchatExemplaire = (SELECT dateCommande FROM commande JOIN commandedocument ON commande.id = commandedocument.id WHERE commandedocument.id = NEW.id) ;
    SET nbExemplaire = NEW.nbExemplaire ;
    SET maxNumeroExemplaire = (SELECT MAX(numero) FROM exemplaire WHERE id = NEW.idlivreDvd) ;

    IF (NEW.idSuivi != OLD.idSuivi AND NEW.idSuivi = "00002") THEN
        IF (maxNumeroExemplaire IS NOT NULL) THEN
            SET newNumeroExemplaire = maxNumeroExemplaire ;
        ELSE
            SET newNumeroExemplaire = 0 ;
        END IF ;

        WHILE compteur < nbExemplaire DO
            SET newNumeroExemplaire = newNumeroExemplaire + 1 ;
            INSERT INTO exemplaire (id,
                                    numero,
                                    dateAchat,
                                    photo,
                                    idEtat)
            VALUES  (NEW.idLivreDvd,
                    newNumeroExemplaire,
                    dateAchatExemplaire,
                    "",
                    "00001") ;
            SET compteur = compteur + 1 ;
        END WHILE ;
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `delete_commandedocument_to_commande`;
DELIMITER $$
CREATE TRIGGER `delete_commandedocument_to_commande` AFTER DELETE ON `commandedocument` FOR EACH ROW BEGIN
DELETE FROM commande WHERE id=OLD.id ;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `document`
--

DROP TABLE IF EXISTS `document`;
CREATE TABLE IF NOT EXISTS `document` (
  `id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `titre` varchar(60) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `image` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `idRayon` varchar(5) COLLATE utf8mb4_general_ci NOT NULL,
  `idPublic` varchar(5) COLLATE utf8mb4_general_ci NOT NULL,
  `idGenre` varchar(5) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idRayon` (`idRayon`),
  KEY `idPublic` (`idPublic`),
  KEY `idGenre` (`idGenre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `document`
--

INSERT INTO `document` (`id`, `titre`, `image`, `idRayon`, `idPublic`, `idGenre`) VALUES
('00001', 'Monsieur Seguin', '', 'LV003', '00002', '10014'),
('00002', 'Un pays à l\'aube', '', 'BD001', '00004', '10018'),
('00003', 'Test de titre', '', 'BL001', '00002', '10019'),
('00004', 'L\'armée furieuse', '', 'LV003', '00002', '10014'),
('00005', 'Les anonymes', '', 'LV001', '00002', '10014'),
('00006', 'La marque jaune', '', 'BD001', '00003', '10001'),
('00007', 'Dans les coulisses du musée', '', 'LV001', '00003', '10006'),
('00008', 'Histoire du juif errant', '', 'LV002', '00002', '10006'),
('00009', 'Pars vite et reviens tard', '', 'LV003', '00002', '10014'),
('00010', 'Le vestibule des causes perdues', '', 'LV001', '00002', '10006'),
('00011', 'L\'île des oubliés', '', 'LV002', '00003', '10006'),
('00012', 'La souris bleue', '', 'LV002', '00003', '10006'),
('00013', 'Sacré Pêre Noël', '', 'JN001', '00001', '10001'),
('00014', 'Bonne étoile', '', 'LV003', '00003', '10014'),
('00015', 'La confrérie des téméraires', '', 'JN002', '00004', '10014'),
('00016', 'Le butin du requin', '', 'JN002', '00004', '10014'),
('00018', 'Test de renom', '', 'PR001', '00003', '10018'),
('00019', 'Guide Vert - Irlande 2', '', 'PR002', '00001', '10007'),
('00021', 'Les déferlantes', '', 'LV002', '00002', '10006'),
('00022', 'Une part de Ciel', '', 'LV002', '00002', '10006'),
('00023', 'Le secret du janissaire', '', 'BD001', '00002', '10001'),
('00026', 'La planète des singes', '', 'LV002', '00003', '10002'),
('10001', 'Arts Magazine', '', 'PR002', '00002', '10016'),
('10002', 'Alternatives Economiques', '', 'PR002', '00002', '10015'),
('10003', 'Challenges', '', 'PR002', '00002', '10015'),
('10004', 'Rock and Folk', '', 'PR002', '00002', '10016'),
('10005', 'Les Echos', '', 'PR001', '00002', '10015'),
('10006', 'Le Monde', '', 'PR001', '00002', '10018'),
('10007', 'Telerama', '', 'PR002', '00002', '10016'),
('10008', 'L\'Obs', '', 'PR002', '00002', '10018'),
('10009', 'L\'Equipe', '', 'PR001', '00002', '10017'),
('10011', 'Geo', '', 'PR002', '00003', '10016'),
('10012', 'Femmes actuelles', '', 'DV003', '00002', '10016'),
('10013', 'Valeurs', '', 'PR001', '00003', '10018'),
('20001', 'Star Wars 5 L\'empire contre attaque', '', 'DF001', '00003', '10002'),
('20002', 'Le seigneur des anneaux : la communauté de l\'anneau', '', 'DF001', '00003', '10019'),
('20003', 'Jurassic Park', '', 'DF001', '00004', '10019'),
('20005', 'Le seigneur des anneaux : le retour du roi', '', 'DF001', '00003', '10019'),
('20006', 'Titre', '', 'DF001', '00002', '10009'),
('20007', 'Titre', '', 'DF001', '00002', '10009'),
('20008', 'Titre', '', 'DF001', '00002', '10009'),
('20009', 'Titre', '', 'DF001', '00002', '10009'),
('20010', 'Titre', '', 'DF001', '00002', '10009');

--
-- Déclencheurs `document`
--
DROP TRIGGER IF EXISTS `delete_document_to_livres_dvd`;
DELIMITER $$
CREATE TRIGGER `delete_document_to_livres_dvd` BEFORE DELETE ON `document` FOR EACH ROW BEGIN
  DELETE FROM livres_dvd WHERE id = OLD.id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `dvd`
--

DROP TABLE IF EXISTS `dvd`;
CREATE TABLE IF NOT EXISTS `dvd` (
  `id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `synopsis` text COLLATE utf8mb4_general_ci,
  `realisateur` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `duree` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `dvd`
--

INSERT INTO `dvd` (`id`, `synopsis`, `realisateur`, `duree`) VALUES
('20001', 'Luc est entraîné par Yoda pendant que Han et Leia tentent de se cacher dans la cité des nuages.', 'George Lucas', 124),
('20002', 'L\'anneau unique, forgé par Sauron, est porté par Fraudon qui l\'amène à Foncombe. De là, des représentants de peuples différents vont s\'unir pour aider Fraudon à amener l\'anneau à la montagne du Destin.', 'Peter Jackson', 228),
('20003', 'Un milliardaire et des généticiens créent des dinosaures à partir de clonage.', 'Steven Spielberg', 128),
('20005', 'L\'anneau unique, forgé par Sauron, est porté par Fraudon qui l\'amène à Foncombe. De là, des représentants de peuples différents vont s\'unir pour aider Fraudon à amener l\'anneau à la montagne du Destin.', 'Peter Jackson', 350);

--
-- Déclencheurs `dvd`
--
DROP TRIGGER IF EXISTS `delete_dvd_to_document`;
DELIMITER $$
CREATE TRIGGER `delete_dvd_to_document` AFTER DELETE ON `dvd` FOR EACH ROW BEGIN
    DELETE FROM livres_dvd WHERE id=OLD.id ;
    DELETE FROM document WHERE id=OLD.id ;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `insert_dvd_to_livres_dvd`;
DELIMITER $$
CREATE TRIGGER `insert_dvd_to_livres_dvd` BEFORE INSERT ON `dvd` FOR EACH ROW BEGIN
  IF NOT EXISTS (SELECT id FROM livres_dvd WHERE id = NEW.id) THEN
    INSERT INTO livres_dvd (id) VALUES (NEW.id);
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `etat`
--

DROP TABLE IF EXISTS `etat`;
CREATE TABLE IF NOT EXISTS `etat` (
  `id` char(5) COLLATE utf8mb4_general_ci NOT NULL,
  `libelle` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `etat`
--

INSERT INTO `etat` (`id`, `libelle`) VALUES
('00001', 'neuf'),
('00002', 'usagé'),
('00003', 'détérioré'),
('00004', 'inutilisable');

-- --------------------------------------------------------

--
-- Structure de la table `exemplaire`
--

DROP TABLE IF EXISTS `exemplaire`;
CREATE TABLE IF NOT EXISTS `exemplaire` (
  `id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `numero` int NOT NULL,
  `dateAchat` date DEFAULT NULL,
  `photo` varchar(500) COLLATE utf8mb4_general_ci NOT NULL,
  `idEtat` char(5) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`,`numero`),
  KEY `idEtat` (`idEtat`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `exemplaire`
--

INSERT INTO `exemplaire` (`id`, `numero`, `dateAchat`, `photo`, `idEtat`) VALUES
('00001', 7, '2024-01-07', '', '00002'),
('00001', 13, '2023-02-27', '', '00001'),
('00001', 19, '2023-02-28', '', '00001'),
('00001', 20, '2023-02-28', '', '00001'),
('00002', 1, '2023-03-07', '', '00001'),
('00004', 1, '2025-03-31', '', '00001'),
('00004', 2, '2025-03-31', '', '00001'),
('00004', 3, '2025-03-31', '', '00001'),
('00004', 4, '2025-03-31', '', '00001'),
('00004', 5, '2025-03-31', '', '00001'),
('00004', 6, '2025-03-31', '', '00001'),
('00004', 7, '2025-03-31', '', '00001'),
('00004', 8, '2025-03-31', '', '00001'),
('00004', 9, '2025-03-31', '', '00001'),
('00004', 10, '2025-03-31', '', '00001'),
('00013', 1, '2025-03-31', '', '00001'),
('00013', 2, '2025-03-31', '', '00001'),
('00013', 3, '2025-03-31', '', '00001'),
('00014', 1, '2024-03-21', '', '00001'),
('00014', 2, '2024-03-21', '', '00003'),
('00014', 3, '2024-03-21', '', '00001'),
('00014', 4, '2024-03-21', '', '00004'),
('10001', 1, '2023-03-07', '', '00002'),
('10001', 2, '2023-03-03', '', '00001'),
('10002', 418, '2021-12-01', '', '00001'),
('10003', 3, '2023-03-28', '', '00002'),
('10007', 3237, '2021-11-23', '', '00001'),
('10007', 3238, '2021-11-30', '', '00001'),
('10007', 3239, '2021-12-07', '', '00001'),
('10007', 3240, '2021-12-21', '', '00001'),
('10011', 505, '2022-10-16', '', '00001'),
('10011', 506, '2021-04-01', '', '00001'),
('10011', 507, '2021-05-03', '', '00001'),
('10011', 508, '2021-06-05', '', '00001'),
('10011', 509, '2021-07-01', '', '00001'),
('10011', 510, '2021-08-04', '', '00001'),
('10011', 511, '2021-09-01', '', '00001'),
('10011', 512, '2021-10-06', '', '00001'),
('10011', 513, '2021-11-01', '', '00001'),
('10011', 514, '2021-12-01', '', '00001'),
('20001', 1, '2023-03-22', '', '00003'),
('20001', 2, '2023-03-22', '', '00001'),
('20001', 3, '2023-03-22', '', '00003'),
('20001', 5, '2023-03-22', '', '00001'),
('20001', 6, '2023-03-24', '', '00001'),
('20001', 9, '2023-03-28', '', '00002'),
('20001', 10, '2023-03-11', '', '00001'),
('20001', 11, '2023-03-11', '', '00001'),
('20001', 12, '2023-03-16', '', '00001'),
('20001', 13, '2023-03-16', '', '00001'),
('20002', 1, '2023-02-27', '', '00001'),
('20002', 2, '2023-02-27', '', '00001');

-- --------------------------------------------------------

--
-- Structure de la table `genre`
--

DROP TABLE IF EXISTS `genre`;
CREATE TABLE IF NOT EXISTS `genre` (
  `id` varchar(5) COLLATE utf8mb4_general_ci NOT NULL,
  `libelle` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `genre`
--

INSERT INTO `genre` (`id`, `libelle`) VALUES
('10000', 'Humour'),
('10001', 'Bande dessinée'),
('10002', 'Science Fiction'),
('10003', 'Biographie'),
('10004', 'Historique'),
('10006', 'Roman'),
('10007', 'Aventures'),
('10008', 'Essai'),
('10009', 'Documentaire'),
('10010', 'Technique'),
('10011', 'Voyages'),
('10012', 'Drame'),
('10013', 'Comédie'),
('10014', 'Policier'),
('10015', 'Presse Economique'),
('10016', 'Presse Culturelle'),
('10017', 'Presse sportive'),
('10018', 'Actualités'),
('10019', 'Fantazy');

-- --------------------------------------------------------

--
-- Structure de la table `livre`
--

DROP TABLE IF EXISTS `livre`;
CREATE TABLE IF NOT EXISTS `livre` (
  `id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `ISBN` varchar(13) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `auteur` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `collection` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `livre`
--

INSERT INTO `livre` (`id`, `ISBN`, `auteur`, `collection`) VALUES
('00001', '0127485748854', 'Testeraoououou', ' '),
('00002', '1236547896541', 'Dennis Lehanne', ''),
('00003', '1468114662955', 'Auteur absent', 'aucune'),
('00004', '3214569874123', 'Fred Vargas', 'Commissaire Adamsberg'),
('00005', '3214563214563', 'RJ Ellory', ''),
('00006', '3213213211232', 'Edgar P. Jacobs', 'Blake et Mortimer'),
('00007', '6541236987541', 'Kate Atkinson', ''),
('00008', '1236987456321', 'Jean d\'Ormesson', ''),
('00009', '', 'Fred Vargas', 'Commissaire Adamsberg'),
('00010', '', 'Manon Moreau', ''),
('00011', '', 'Victoria Hislop', ''),
('00012', '', 'Kate Atkinson', ''),
('00013', '', 'Raymond Briggs', ''),
('00014', '9782951310605', 'Lumière', ' '),
('00015', '', 'Floriane Turmeau', ''),
('00016', '', 'Julian Press', ''),
('00018', '', 'test', 'Aucune'),
('00019', '000198888888', 'Hello', 'Guide Vert'),
('00021', '', 'Claudie Gallay', ''),
('00022', '', 'Claudie Gallay', ''),
('00023', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00026', '', 'Pierre Boulle', 'Julliard');

--
-- Déclencheurs `livre`
--
DROP TRIGGER IF EXISTS `delete_livre_to_document`;
DELIMITER $$
CREATE TRIGGER `delete_livre_to_document` AFTER DELETE ON `livre` FOR EACH ROW BEGIN
DELETE FROM livres_dvd WHERE id=OLD.id ;
DELETE FROM document WHERE id=OLD.id ;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `insert_livre_to_livres_dvd`;
DELIMITER $$
CREATE TRIGGER `insert_livre_to_livres_dvd` BEFORE INSERT ON `livre` FOR EACH ROW BEGIN
DECLARE cnt INT;
SELECT COUNT(*) INTO cnt
FROM livres_dvd
WHERE id = NEW.id;

IF cnt = 0 THEN
INSERT INTO livres_dvd (id) VALUES
(NEW.id);
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `livres_dvd`
--

DROP TABLE IF EXISTS `livres_dvd`;
CREATE TABLE IF NOT EXISTS `livres_dvd` (
  `id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `livres_dvd`
--

INSERT INTO `livres_dvd` (`id`) VALUES
('00001'),
('00002'),
('00003'),
('00004'),
('00005'),
('00006'),
('00007'),
('00008'),
('00009'),
('00010'),
('00011'),
('00012'),
('00013'),
('00014'),
('00015'),
('00016'),
('00018'),
('00019'),
('00021'),
('00022'),
('00023'),
('00026'),
('20001'),
('20002'),
('20003'),
('20005');

--
-- Déclencheurs `livres_dvd`
--
DROP TRIGGER IF EXISTS `insert_livres_dvd_to_document`;
DELIMITER $$
CREATE TRIGGER `insert_livres_dvd_to_document` BEFORE INSERT ON `livres_dvd` FOR EACH ROW BEGIN
DECLARE cnt INT;
SELECT COUNT(*) INTO cnt
FROM document
WHERE id = NEW.id;

IF cnt = 0 THEN
INSERT INTO document (id) VALUES
(NEW.id);
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `public`
--

DROP TABLE IF EXISTS `public`;
CREATE TABLE IF NOT EXISTS `public` (
  `id` varchar(5) COLLATE utf8mb4_general_ci NOT NULL,
  `libelle` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `public`
--

INSERT INTO `public` (`id`, `libelle`) VALUES
('00001', 'Jeunesse'),
('00002', 'Adultes'),
('00003', 'Tous publics'),
('00004', 'Ados');

-- --------------------------------------------------------

--
-- Structure de la table `rayon`
--

DROP TABLE IF EXISTS `rayon`;
CREATE TABLE IF NOT EXISTS `rayon` (
  `id` char(5) COLLATE utf8mb4_general_ci NOT NULL,
  `libelle` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `rayon`
--

INSERT INTO `rayon` (`id`, `libelle`) VALUES
('BD001', 'BD Adultes'),
('BL001', 'Beaux Livres'),
('DF001', 'DVD films'),
('DV001', 'Sciences'),
('DV002', 'Maison'),
('DV003', 'Santé'),
('DV004', 'Littérature classique'),
('DV005', 'Voyages'),
('JN001', 'Jeunesse BD'),
('JN002', 'Jeunesse romans'),
('LV001', 'Littérature étrangère'),
('LV002', 'Littérature française'),
('LV003', 'Policiers français étrangers'),
('PR001', 'Presse quotidienne'),
('PR002', 'Magazines');

-- --------------------------------------------------------

--
-- Structure de la table `revue`
--

DROP TABLE IF EXISTS `revue`;
CREATE TABLE IF NOT EXISTS `revue` (
  `id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `periodicite` varchar(2) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `delaiMiseADispo` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `revue`
--

INSERT INTO `revue` (`id`, `periodicite`, `delaiMiseADispo`) VALUES
('10001', 'MS', 52),
('10002', 'MS', 52),
('10003', 'HB', 15),
('10004', 'HB', 15),
('10005', 'QT', 5),
('10006', 'QT', 5),
('10007', 'HB', 26),
('10008', 'HB', 26),
('10009', 'QT', 5),
('10011', 'MS', 52),
('10012', 'HB', 50),
('10013', 'HB', 50);

--
-- Déclencheurs `revue`
--
DROP TRIGGER IF EXISTS `delete_revue_to_document`;
DELIMITER $$
CREATE TRIGGER `delete_revue_to_document` AFTER DELETE ON `revue` FOR EACH ROW BEGIN
    DELETE FROM document WHERE id=OLD.id ;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `insert_revue_to_document`;
DELIMITER $$
CREATE TRIGGER `insert_revue_to_document` BEFORE INSERT ON `revue` FOR EACH ROW BEGIN
  DECLARE cnt INT;
  SELECT COUNT(*) INTO cnt
  FROM document
  WHERE id = NEW.id;

  IF cnt = 0 THEN
    INSERT INTO document (id) VALUES (NEW.id);
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `service`
--

DROP TABLE IF EXISTS `service`;
CREATE TABLE IF NOT EXISTS `service` (
  `id` char(10) COLLATE utf8mb4_general_ci NOT NULL,
  `libelle` char(55) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `service`
--

INSERT INTO `service` (`id`, `libelle`) VALUES
('0', 'administrateur'),
('1', 'administratif'),
('2', 'prêts'),
('3', 'culture');

-- --------------------------------------------------------

--
-- Structure de la table `suivi`
--

DROP TABLE IF EXISTS `suivi`;
CREATE TABLE IF NOT EXISTS `suivi` (
  `id` varchar(5) COLLATE utf8mb4_general_ci NOT NULL,
  `libelle` varchar(55) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `suivi`
--

INSERT INTO `suivi` (`id`, `libelle`) VALUES
('00001', 'en cours'),
('00002', 'livrée'),
('00003', 'réglée'),
('00004', 'relancée');

-- --------------------------------------------------------

--
-- Structure de la table `utilisateur`
--

DROP TABLE IF EXISTS `utilisateur`;
CREATE TABLE IF NOT EXISTS `utilisateur` (
  `id` varchar(5) COLLATE utf8mb3_unicode_ci NOT NULL,
  `login` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `idService` varchar(5) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idService` (`idService`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `utilisateur`
--

INSERT INTO `utilisateur` (`id`, `login`, `password`, `idService`) VALUES
('00003', 'nocompte', 'f4f263e439cf40925e6a412387a9472a6773c2580212a4fb50d224d3a817de17', '3'),
('00002', 'admin', '2c0dfbea0653014e96a7fa738e8d64de74aacfc09fc64f85abf9ea7472a0e521', '1'),
('00001', 'pret', '0357513deb903a056e74a7e475247fc1ffe31d8be4c1d4a31f58dd47ae484100', '2');

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `abonnement`
--
ALTER TABLE `abonnement`
  ADD CONSTRAINT `abonnement_ibfk_1` FOREIGN KEY (`id`) REFERENCES `commande` (`id`),
  ADD CONSTRAINT `abonnement_ibfk_2` FOREIGN KEY (`idRevue`) REFERENCES `revue` (`id`);

--
-- Contraintes pour la table `commandedocument`
--
ALTER TABLE `commandedocument`
  ADD CONSTRAINT `commandedocument_ibfk_1` FOREIGN KEY (`id`) REFERENCES `commande` (`id`),
  ADD CONSTRAINT `commandedocument_ibfk_2` FOREIGN KEY (`idLivreDvd`) REFERENCES `livres_dvd` (`id`),
  ADD CONSTRAINT `commandedocument_ibfk_3` FOREIGN KEY (`idSuivi`) REFERENCES `suivi` (`id`);

--
-- Contraintes pour la table `document`
--
ALTER TABLE `document`
  ADD CONSTRAINT `document_ibfk_1` FOREIGN KEY (`idRayon`) REFERENCES `rayon` (`id`),
  ADD CONSTRAINT `document_ibfk_2` FOREIGN KEY (`idPublic`) REFERENCES `public` (`id`),
  ADD CONSTRAINT `document_ibfk_3` FOREIGN KEY (`idGenre`) REFERENCES `genre` (`id`);

--
-- Contraintes pour la table `dvd`
--
ALTER TABLE `dvd`
  ADD CONSTRAINT `dvd_ibfk_1` FOREIGN KEY (`id`) REFERENCES `livres_dvd` (`id`);

--
-- Contraintes pour la table `exemplaire`
--
ALTER TABLE `exemplaire`
  ADD CONSTRAINT `exemplaire_ibfk_2` FOREIGN KEY (`idEtat`) REFERENCES `etat` (`id`);

--
-- Contraintes pour la table `livre`
--
ALTER TABLE `livre`
  ADD CONSTRAINT `livre_ibfk_1` FOREIGN KEY (`id`) REFERENCES `livres_dvd` (`id`);

--
-- Contraintes pour la table `livres_dvd`
--
ALTER TABLE `livres_dvd`
  ADD CONSTRAINT `livres_dvd_ibfk_1` FOREIGN KEY (`id`) REFERENCES `document` (`id`);

--
-- Contraintes pour la table `revue`
--
ALTER TABLE `revue`
  ADD CONSTRAINT `revue_ibfk_1` FOREIGN KEY (`id`) REFERENCES `document` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
