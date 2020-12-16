-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Database : Create Empty Table
-------------------------------------------------------------------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-------------------------------------------------------------------------------------------------------------------
-- SQL Table : characters.character_classless
CREATE TABLE IF NOT EXISTS `character_classless` (
  `guid` int(10) unsigned NOT NULL COMMENT 'Player GUID (Low)',
  `spells` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Array of known Spell IDs',
  `talents` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Array of known Talent IDs',
  `glyphs` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Array of known Glyph IDs',
  `reset_counter` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Number of Abilities reset',
  PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ClassLess System by Shikifuyin';

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
