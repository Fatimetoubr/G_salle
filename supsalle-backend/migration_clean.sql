-- ============================================================
-- MIGRATION : Supprimer OTP, is_verified, reset_password
-- Exécuter dans phpMyAdmin ou MySQL Workbench
-- ============================================================

USE supsalle_bd;

-- 1. Supprimer les colonnes OTP et is_verified
ALTER TABLE users
    DROP COLUMN IF EXISTS otp_code,
    DROP COLUMN IF EXISTS otp_expiration,
    DROP COLUMN IF EXISTS is_verified;

-- 2. Vérifier la structure finale
DESCRIBE users;

-- Structure attendue :
-- id          | int           | NO  | PRI | NULL    | auto_increment
-- fullname    | varchar(100)  | YES |     | NULL    |
-- email       | varchar(100)  | YES | UNI | NULL    |
-- password    | varchar(255)  | YES |     | NULL    |
-- role        | enum(...)     | YES |     | user    |
-- is_active   | tinyint(1)    | YES |     | 1       |
