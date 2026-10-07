-- Data fiktif "Kota Sentosa" untuk walkthrough GIS (PostGIS). Koordinat di sekitar 106.80–106.84 BT,
-- 6.20–6.24 LS (EPSG:4326). Nama, NIK, dan telepon dikarang.
CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS warga_rentan, puskesmas, zona_banjir, kelurahan;

CREATE TABLE kelurahan (
  kode varchar(10) PRIMARY KEY,
  nama varchar(100) NOT NULL,
  jumlah_penduduk integer NOT NULL,
  area geometry(Polygon, 4326) NOT NULL
);
INSERT INTO kelurahan VALUES
 ('KL-01', 'Sentosa Utara',   18250, ST_GeomFromText('POLYGON((106.80 -6.20, 106.82 -6.20, 106.82 -6.22, 106.80 -6.22, 106.80 -6.20))', 4326)),
 ('KL-02', 'Sentosa Timur',   22410, ST_GeomFromText('POLYGON((106.82 -6.20, 106.84 -6.20, 106.84 -6.22, 106.82 -6.22, 106.82 -6.20))', 4326)),
 ('KL-03', 'Sentosa Barat',   15780, ST_GeomFromText('POLYGON((106.80 -6.22, 106.82 -6.22, 106.82 -6.24, 106.80 -6.24, 106.80 -6.22))', 4326)),
 ('KL-04', 'Sentosa Selatan', 19960, ST_GeomFromText('POLYGON((106.82 -6.22, 106.84 -6.22, 106.84 -6.24, 106.82 -6.24, 106.82 -6.22))', 4326));

CREATE TABLE zona_banjir (
  id serial PRIMARY KEY,
  tingkat varchar(10) NOT NULL CHECK (tingkat IN ('tinggi', 'sedang')),
  keterangan varchar(200),
  area geometry(Polygon, 4326) NOT NULL
);
INSERT INTO zona_banjir (tingkat, keterangan, area) VALUES
 ('tinggi', 'Bantaran Kali Sentosa', ST_GeomFromText('POLYGON((106.810 -6.205, 106.830 -6.205, 106.830 -6.215, 106.810 -6.215, 106.810 -6.205))', 4326)),
 ('sedang', 'Cekungan Pasar Lama',   ST_GeomFromText('POLYGON((106.825 -6.225, 106.838 -6.225, 106.838 -6.236, 106.825 -6.236, 106.825 -6.225))', 4326));

CREATE TABLE puskesmas (
  id serial PRIMARY KEY,
  nama varchar(100) NOT NULL,
  kapasitas_pengungsi integer NOT NULL,
  lokasi geography(Point, 4326) NOT NULL
);
INSERT INTO puskesmas (nama, kapasitas_pengungsi, lokasi) VALUES
 ('Puskesmas Sentosa Utara', 120, ST_GeogFromText('POINT(106.805 -6.203)')),
 ('Puskesmas Sentosa Timur', 150, ST_GeogFromText('POINT(106.836 -6.212)')),
 ('Puskesmas Sentosa Barat',  90, ST_GeogFromText('POINT(106.806 -6.232)')),
 ('Puskesmas Sentosa Selatan',110, ST_GeogFromText('POINT(106.833 -6.238)'));

CREATE TABLE warga_rentan (
  nik varchar(16) PRIMARY KEY,
  nama varchar(100) NOT NULL,
  kategori varchar(20) NOT NULL CHECK (kategori IN ('lansia', 'disabilitas', 'ibu hamil', 'balita')),
  telepon varchar(20),
  lokasi geometry(Point, 4326) NOT NULL
);
INSERT INTO warga_rentan VALUES
 ('3171010101500001', 'Siti Aminah',     'lansia',      '0812-1111-0001', ST_GeomFromText('POINT(106.815 -6.208)', 4326)),
 ('3171010101500002', 'Budi Hartono',    'disabilitas', '0812-1111-0002', ST_GeomFromText('POINT(106.822 -6.210)', 4326)),
 ('3171010101500003', 'Rina Wulandari',  'ibu hamil',   '0812-1111-0003', ST_GeomFromText('POINT(106.828 -6.212)', 4326)),
 ('3171010101500004', 'Ahmad Fauzi',     'lansia',      '0812-1111-0004', ST_GeomFromText('POINT(106.803 -6.214)', 4326)),
 ('3171010101500005', 'Dewi Lestari',    'balita',      '0812-1111-0005', ST_GeomFromText('POINT(106.836 -6.204)', 4326)),
 ('3171010101500006', 'Joko Susilo',     'lansia',      '0812-1111-0006', ST_GeomFromText('POINT(106.830 -6.230)', 4326)),
 ('3171010101500007', 'Maria Ulfa',      'disabilitas', '0812-1111-0007', ST_GeomFromText('POINT(106.834 -6.233)', 4326)),
 ('3171010101500008', 'Hendra Gunawan',  'balita',      '0812-1111-0008', ST_GeomFromText('POINT(106.812 -6.228)', 4326)),
 ('3171010101500009', 'Lina Marlina',    'ibu hamil',   '0812-1111-0009', ST_GeomFromText('POINT(106.818 -6.236)', 4326)),
 ('3171010101500010', 'Yusuf Maulana',   'lansia',      '0812-1111-0010', ST_GeomFromText('POINT(106.826 -6.206)', 4326)),
 ('3171010101500011', 'Sri Rahayu',      'lansia',      '0812-1111-0011', ST_GeomFromText('POINT(106.839 -6.221)', 4326)),
 ('3171010101500012', 'Agus Salim',      'disabilitas', '0812-1111-0012', ST_GeomFromText('POINT(106.828 -6.228)', 4326));
