-- ============================================================
--  DATABASE: lab_peminjaman
--  Aplikasi Peminjaman Barang & Ruangan Lab Jaringan
--  Compatible: MySQL 5.7+ / MariaDB (Laragon)
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+07:00";
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- Buat dan pilih database
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `lab_peminjaman`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `lab_peminjaman`;

-- ============================================================
--  DROP TABLE (urutan: child dulu, baru parent)
-- ============================================================
DROP TABLE IF EXISTS `form_pengaduanMasalah`;
DROP TABLE IF EXISTS `form_peminjamanRuangan`;
DROP TABLE IF EXISTS `form_peminjamanBarang`;
DROP TABLE IF EXISTS `Barang`;
DROP TABLE IF EXISTS `TypeBarang`;
DROP TABLE IF EXISTS `ruangan`;
DROP TABLE IF EXISTS `users`;

-- ============================================================
--  1. TABEL: users
-- ============================================================
CREATE TABLE `users` (
  `id`               INT(11)      NOT NULL AUTO_INCREMENT,
  `nama`             TEXT         NOT NULL,
  `jenis_identitas`  TEXT         NOT NULL COMMENT 'NIM / NIP / NIK',
  `nomor_identitas`  VARCHAR(50)  NOT NULL UNIQUE,
  `password`         VARCHAR(255) DEFAULT NULL COMMENT 'NULL untuk role peminjam',
  `role`             ENUM('kaprodi','admin','peminjam') NOT NULL DEFAULT 'peminjam',
  `created_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (`nama`, `jenis_identitas`, `nomor_identitas`, `password`, `role`) VALUES
('Dr. Budi Santoso',    'NIP', '198501012010011001', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'kaprodi'),
('Rina Asisten',        'NIP', '199203152015012002', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('Ahmad Mahasiswa',     'NIM', '20210001',            NULL, 'peminjam'),
('Siti Dosen',          'NIP', '198709102012012003',  NULL, 'peminjam'),
('Rizky Mahasiswa',     'NIM', '20210002',            NULL, 'peminjam'),
('Dewi Mahasiswa',      'NIM', '20210003',            NULL, 'peminjam'),
('Prof. Hendra',        'NIP', '197804052005011002',  NULL, 'peminjam');
-- password dummy = 'password' (bcrypt hash)

-- ============================================================
--  2. TABEL: TypeBarang
-- ============================================================
CREATE TABLE `TypeBarang` (
  `id`   INT(11) NOT NULL AUTO_INCREMENT,
  `nama` TEXT    NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `TypeBarang` (`nama`) VALUES
('Elektronik'),
('Jaringan'),
('Furnitur'),
('Kabel & Aksesoris'),
('Alat Ukur');

-- ============================================================
--  3. TABEL: Barang
-- ============================================================
CREATE TABLE `Barang` (
  `id`            INT(11)      NOT NULL AUTO_INCREMENT,
  `namaBarang`    TEXT         NOT NULL,
  `SN`            VARCHAR(100) NOT NULL UNIQUE COMMENT 'Serial Number',
  `gambar`        VARCHAR(255) DEFAULT NULL,
  `id_type`       INT(11)      DEFAULT NULL,
  `qty`           INT(11)      NOT NULL DEFAULT 1,
  `status_barang` ENUM('Tersedia','Dipakai','Rusak') NOT NULL DEFAULT 'Tersedia',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_barang_type` FOREIGN KEY (`id_type`)
    REFERENCES `TypeBarang`(`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `Barang` (`namaBarang`, `SN`, `gambar`, `id_type`, `qty`, `status_barang`) VALUES
('Proyektor Epson EB-X41',  'SN-PRY-001', NULL, 1, 3,  'Tersedia'),
('Laptop Lenovo ThinkPad',  'SN-LPT-001', NULL, 1, 5,  'Tersedia'),
('Switch Cisco 24 Port',    'SN-SWT-001', NULL, 2, 2,  'Tersedia'),
('Router MikroTik RB951',   'SN-RTR-001', NULL, 2, 3,  'Tersedia'),
('Kabel UTP Cat6 (10m)',    'SN-KBL-001', NULL, 4, 10, 'Tersedia'),
('Multimeter Digital',      'SN-MMT-001', NULL, 5, 2,  'Tersedia'),
('Access Point TP-Link',    'SN-ACP-001', NULL, 2, 4,  'Tersedia'),
('HDMI Splitter',           'SN-HDM-001', NULL, 4, 3,  'Tersedia');

-- ============================================================
--  4. TABEL: ruangan
-- ============================================================
CREATE TABLE `ruangan` (
  `id`             INT(11)      NOT NULL AUTO_INCREMENT,
  `namaRuangan`    TEXT         NOT NULL,
  `SN`             INT(11)      NOT NULL UNIQUE COMMENT 'Nomor/Kode Ruangan',
  `gambar`         VARCHAR(255) DEFAULT NULL,
  `status_ruangan` ENUM('Tersedia','Dipakai','Rusak') NOT NULL DEFAULT 'Tersedia',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ruangan` (`namaRuangan`, `SN`, `gambar`, `status_ruangan`) VALUES
('Lab Jaringan A',    101, NULL, 'Tersedia'),
('Lab Jaringan B',    102, NULL, 'Tersedia'),
('Ruang Praktikum 1', 201, NULL, 'Tersedia'),
('Ruang Praktikum 2', 202, NULL, 'Tersedia'),
('Ruang Server',      301, NULL, 'Tersedia');

-- ============================================================
--  5. TABEL: form_peminjamanBarang
-- ============================================================
CREATE TABLE `form_peminjamanBarang` (
  `id`                     INT(11)      NOT NULL AUTO_INCREMENT,
  `id_user`                INT(11)      NOT NULL,
  `id_barang`              INT(11)      NOT NULL,
  `nama`                   TEXT         NOT NULL,
  `jenis_identitas`        TEXT         NOT NULL,
  `nomor_identitas`        VARCHAR(50)  NOT NULL,
  `phone`                  VARCHAR(20)  NOT NULL,
  `tgl_pinjam`             DATE         NOT NULL,
  `tgl_kembali`            DATE         NOT NULL,
  `tgl_fix`                DATE         DEFAULT NULL,
  `keterangan`             TEXT         NOT NULL,
  `buktiFoto`              VARCHAR(255) DEFAULT NULL,
  `status_approval`        ENUM('Waiting','Approved','Deny') NOT NULL DEFAULT 'Waiting',
  `qty`                    INT(11)      NOT NULL DEFAULT 1,
  `keterangan_serahterima` TEXT         DEFAULT NULL,
  `foto_serahterima`       VARCHAR(255) DEFAULT NULL,
  `status_kondisi`         ENUM('Baik','Rusak Ringan','Rusak Berat') DEFAULT NULL,
  `tgl_serahterima`        DATE         DEFAULT NULL,
  `created_at`             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_fpb_user`   FOREIGN KEY (`id_user`)   REFERENCES `users`(`id`)  ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_fpb_barang` FOREIGN KEY (`id_barang`) REFERENCES `Barang`(`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `form_peminjamanBarang`
  (`id_user`,`id_barang`,`nama`,`jenis_identitas`,`nomor_identitas`,`phone`,`tgl_pinjam`,`tgl_kembali`,`keterangan`,`status_approval`,`qty`) VALUES
(3, 1, 'Ahmad Mahasiswa', 'NIM', '20210001',            '08111000001', '2026-06-10', '2026-06-12', 'Keperluan presentasi tugas akhir',  'Waiting',  1),
(5, 3, 'Rizky Mahasiswa', 'NIM', '20210002',            '08111000002', '2026-06-11', '2026-06-13', 'Praktikum konfigurasi switch',       'Approved', 1),
(4, 2, 'Siti Dosen',      'NIP', '198709102012012003', '08111000003', '2026-06-09', '2026-06-09', 'Kegiatan mengajar',                  'Approved', 1),
(6, 5, 'Dewi Mahasiswa',  'NIM', '20210003',            '08111000004', '2026-06-12', '2026-06-14', 'Praktikum jaringan kabel',           'Waiting',  2),
(7, 4, 'Prof. Hendra',    'NIP', '197804052005011002', '08111000005', '2026-06-08', '2026-06-08', 'Konfigurasi router lab',             'Deny',     1);

-- ============================================================
--  6. TABEL: form_peminjamanRuangan
-- ============================================================
CREATE TABLE `form_peminjamanRuangan` (
  `id`                     INT(11)      NOT NULL AUTO_INCREMENT,
  `id_user`                INT(11)      NOT NULL,
  `id_ruangan`             INT(11)      NOT NULL,
  `nama`                   TEXT         NOT NULL,
  `jenis_identitas`        TEXT         NOT NULL,
  `nomor_identitas`        VARCHAR(50)  NOT NULL,
  `phone`                  VARCHAR(20)  NOT NULL,
  `wkt_pinjam`             DATETIME     NOT NULL,
  `wkt_kembali`            DATETIME     NOT NULL,
  `keterangan`             TEXT         NOT NULL,
  `buktiFoto`              VARCHAR(255) DEFAULT NULL,
  `status_approval`        ENUM('Waiting','Approved','Deny') NOT NULL DEFAULT 'Waiting',
  `keterangan_serahterima` TEXT         DEFAULT NULL,
  `foto_serahterima`       VARCHAR(255) DEFAULT NULL,
  `status_kondisi`         ENUM('Baik','Kotor','Ada Kerusakan') DEFAULT NULL,
  `tgl_serahterima`        DATE         DEFAULT NULL,
  `created_at`             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_fpr_user`    FOREIGN KEY (`id_user`)    REFERENCES `users`(`id`)    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_fpr_ruangan` FOREIGN KEY (`id_ruangan`) REFERENCES `ruangan`(`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `form_peminjamanRuangan`
  (`id_user`,`id_ruangan`,`nama`,`jenis_identitas`,`nomor_identitas`,`phone`,`wkt_pinjam`,`wkt_kembali`,`keterangan`,`status_approval`) VALUES
(3, 1, 'Ahmad Mahasiswa', 'NIM', '20210001',            '08111000001', '2026-06-10 08:00:00', '2026-06-10 12:00:00', 'Praktikum Jaringan Komputer',    'Waiting'),
(5, 2, 'Rizky Mahasiswa', 'NIM', '20210002',            '08111000002', '2026-06-11 13:00:00', '2026-06-11 17:00:00', 'Ujian Praktikum Semester',       'Approved'),
(4, 3, 'Siti Dosen',      'NIP', '198709102012012003', '08111000003', '2026-06-09 07:00:00', '2026-06-09 10:00:00', 'Kegiatan mengajar praktikum',   'Approved'),
(6, 1, 'Dewi Mahasiswa',  'NIM', '20210003',            '08111000004', '2026-06-12 09:00:00', '2026-06-12 11:00:00', 'Tugas kelompok jaringan',        'Deny'),
(7, 4, 'Prof. Hendra',    'NIP', '197804052005011002', '08111000005', '2026-06-08 08:00:00', '2026-06-08 16:00:00', 'Seminar jaringan komputer',     'Approved');

-- ============================================================
--  7. TABEL: form_pengaduanMasalah
-- ============================================================
CREATE TABLE `form_pengaduanMasalah` (
  `id`                        INT(11)      NOT NULL AUTO_INCREMENT,
  `id_user`                   INT(11)      NOT NULL,
  `tipe_peminjaman`           ENUM('Barang','Ruangan') NOT NULL,
  `id_form_peminjamanBarang`  INT(11)      DEFAULT NULL,
  `id_form_peminjamanRuangan` INT(11)      DEFAULT NULL,
  `deskripsi_masalah`         TEXT         NOT NULL,
  `tingkat_prioritas`         INT(11)      NOT NULL DEFAULT 1 COMMENT '1=Rendah 2=Sedang 3=Tinggi',
  `status_pengaduan`          ENUM('Waiting','Approved','Deny') NOT NULL DEFAULT 'Waiting',
  `tgl_pengaduan`             DATE         NOT NULL,
  `foto_pengaduan`            VARCHAR(255) NOT NULL,
  `deskripsi_resolusi`        TEXT         DEFAULT NULL,
  `created_at`                DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`                DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_fpm_user`    FOREIGN KEY (`id_user`)                   REFERENCES `users`(`id`)                  ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_fpm_barang`  FOREIGN KEY (`id_form_peminjamanBarang`)  REFERENCES `form_peminjamanBarang`(`id`)  ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_fpm_ruangan` FOREIGN KEY (`id_form_peminjamanRuangan`) REFERENCES `form_peminjamanRuangan`(`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `form_pengaduanMasalah`
  (`id_user`,`tipe_peminjaman`,`id_form_peminjamanBarang`,`id_form_peminjamanRuangan`,`deskripsi_masalah`,`tingkat_prioritas`,`status_pengaduan`,`tgl_pengaduan`,`foto_pengaduan`) VALUES
(5, 'Barang',  2, NULL, 'Switch tidak dapat menyala saat diterima, lampu indikator mati',  3, 'Waiting',  '2026-06-11', 'foto_pengaduan_001.jpg'),
(3, 'Ruangan', NULL, 1, 'AC ruangan tidak berfungsi sehingga suhu panas saat praktikum',   2, 'Waiting',  '2026-06-10', 'foto_pengaduan_002.jpg'),
(4, 'Barang',  3, NULL, 'Laptop layarnya retak, kemungkinan sudah retak sebelum dipinjam', 3, 'Approved', '2026-06-09', 'foto_pengaduan_003.jpg'),
(7, 'Ruangan', NULL, 5, 'Proyektor di ruang praktikum 2 tidak bisa connect ke laptop',      1, 'Waiting',  '2026-06-08', 'foto_pengaduan_004.jpg');

SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
