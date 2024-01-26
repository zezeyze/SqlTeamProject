IF DB_ID ('gamedb') IS NOT NULL
	BEGIN 
		ALTER DATABASE [gamedb] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
		USE master
		DROP DATABASE gamedb
	END
GO

CREATE DATABASE gamedb
	ON PRIMARY (
					NAME = 'gamedb',
					FILENAME = 'c:\Database\game_db.mdf',
					SIZE = 5MB,
                    MAXSIZE = 100MB,
                 	FILEGROWTH = 5MB
               )
    LOG ON	   (
				    NAME = 'gamedb_log',
					FILENAME = 'c:\Database\game_log.ldf',
					SIZE = 2MB,
                    MAXSIZE = 50MB,
                 	FILEGROWTH = 1MB
			   )
GO

USE gamedb

--Bu tabloda �lkeye ait bilgiler bulunur.
CREATE TABLE tblUlke
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Ad VARCHAR(50) UNIQUE NOT NULL
)
GO

--Bu tabloda kullan�c�ya ait bilgiler bulunur.
CREATE TABLE tblKullanici
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   KullaniciAdi VARCHAR(50) UNIQUE NOT NULL,
   Sifre VARCHAR(25) NOT NULL,
   Durum SMALLINT DEFAULT 1 NOT NULL ,  --�yelik kapan�rsa (0) olur
   Cuzdan MONEY  DEFAULT 0 NOT NULL,
   DogumTarihi DATE NOT NULL,
   Yas AS DATEDIFF (yy,DogumTarihi,GETDATE()),
   Mail VARCHAR(50)
           CONSTRAINT uniqueMail UNIQUE
           CONSTRAINT notNullMail NOT NULL
           CONSTRAINT chkMail CHECK (Mail LIKE '%@%.com'),
   SonGirisTarihi DATETIME NOT NULL,
   KayitTarihi DATE DEFAULT GETDATE() NOT NULL,
   UlkeID INT FOREIGN KEY REFERENCES tblUlke(ID) NOT NULL
)
GO

--Bu tabloda kullan�c�-kullan�c�(arkada� ekleme)  ili�kisine ait bilgiler bulunur.
CREATE TABLE tblKullaniciArkadasEkleme
(
   ID INT IDENTITY(1,1) PRIMARY KEY, 
   Durum SMALLINT DEFAULT 0 NOT NULL ,  --arkada� iste�i kabul edilirse bir (1) olur 
   EklemeTarihi DATE DEFAULT GETDATE()  NOT NULL,  
   EkleyenKullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   EklenenKullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL
)
GO

--Bu tabloda gruba ait bilgiler bulunur.
CREATE TABLE tblGrup
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   Ad VARCHAR(30) NOT NULL,
   Aciklama VARCHAR(1000),
   OlusturulmaTarihi DATE DEFAULT GETDATE() NOT NULL,
   KurucuID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL
)
GO

--Bu tabloda kullan�c�-grup �ye olma ili�kisine ait bilgiler bulunur.
CREATE TABLE tblKullaniciGrupUyeOlma
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   UyeOlusTarihi DATE DEFAULT GETDATE() NOT NULL,
   UyeAyrilisTarihi DATE DEFAULT NULL,
   KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   GrupID INT FOREIGN KEY REFERENCES tblGrup(ID) NOT NULL
)
GO

--Bu tabloda �zelli�e ait bilgiler bulunur.
CREATE TABLE tblOzellik
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   Ad VARCHAR(100) NOT NULL
)
GO

--Bu tabloda t�re ait bilgiler bulunur.
CREATE TABLE tblTur
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   Ad VARCHAR(100) NOT NULL
)
GO

--Bu tabloda firmaya ait bilgiler bulunur.
CREATE TABLE tblFirma
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   KurulusTarihi DATE,
   Ad VARCHAR(30) NOT NULL,
   WebSayfasi VARCHAR(100) 
)
GO

--Bu tabloda �r�ne ait bilgiler bulunur.
CREATE TABLE tblUrun
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   Ad  VARCHAR(100) NOT NULL,
   OnerilenSistemGereksinimleri VARCHAR(500) NOT NULL,
   MinSistemGereksinimleri VARCHAR(500) NOT NULL,
   CikisTarihi DATE NOT NULL,
   YasSiniri SMALLINT DEFAULT 0 NOT NULL, --yas sinir varsa 1
   TurID INT FOREIGN KEY REFERENCES tblTur(ID) NOT NULL,
   GelistirenFirmaID INT FOREIGN KEY REFERENCES tblFirma(ID) NOT NULL,
   YayimlayanFirmaID INT FOREIGN KEY REFERENCES tblFirma(ID) NOT NULL 
)
GO

--Bu tabloda �r�n-�lkede bulunma ili�kisine ait bilgiler bulunur.
CREATE TABLE tblUlkedeUrunBulunma
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   Fiyat MONEY  DEFAULT 0 NOT NULL,
   UrunID INT FOREIGN KEY REFERENCES tblUrun(ID) NOT NULL,
   UlkeID INT FOREIGN KEY REFERENCES tblUlke(ID) NOT NULL,
		  CONSTRAINT uq_UrunID_UlkeID UNIQUE (UrunID, UlkeID)
)
GO

--Bu tabloda �r�n-�zellik ili�kisine ait bilgiler bulunur.
CREATE TABLE tblUrununVard�rOzellik
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   OzellikID INT FOREIGN KEY REFERENCES tblOzellik(ID) NOT NULL,
   UrunID INT FOREIGN KEY REFERENCES tblUrun(ID) NOT NULL,
          CONSTRAINT pktblUlkedeVard�rOzellik UNIQUE (UrunID, OzellikID)
)
GO

--Bu tabloda istek listesine ait bilgiler bulunur.
CREATE TABLE tbIstekListesiUrunleri
( 
   ID INT IDENTITY(1,1) PRIMARY KEY,
   EklemeTarihi DATE NOT NULL,
   Siralamasi INT NOT NULL,
   KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   UrunID INT FOREIGN KEY REFERENCES tblUrun(ID) NOT NULL,
  	CONSTRAINT pktblIstekListesiUrunleri UNIQUE (KullaniciID, UrunID)
)
GO

--Bu tabloda ba�ar�ma ait bilgiler bulunur.
CREATE TABLE tblBasarim
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   Ad VARCHAR(50) NOT NULL,
   UrunID INT FOREIGN KEY REFERENCES tblUrun(ID) NOT NULL
)
GO

--Bu tabloda kullan�c�-ba�ar�m a�ma ili�kisine ait bilgiler bulunur.
CREATE TABLE tblKullaniciBasarimAcma
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   AcmaTarihi DATE NOT NULL,
   KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   BasarimID INT FOREIGN KEY REFERENCES tblBasarim(ID) NOT NULL,
          CONSTRAINT pktblKullaniciBasarimAcma UNIQUE (KullaniciID, BasarimID)
)
GO

--Bu tabloda kullan�c�-�r�n sat�n alma ili�kisine ait bilgiler bulunur.
CREATE TABLE tblKullaniciUrunSatinAlma
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   SeriNumaras� VARCHAR(25) NOT NULL,
   Tarihi DATE NOT NULL,
   Fiyat MONEY  DEFAULT 0 NOT NULL,
   KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   UrunID INT FOREIGN KEY REFERENCES tblUrun(ID) NOT NULL
          CONSTRAINT pktblKullaniciUrunSatinAlma UNIQUE (KullaniciID, UrunID)
)
GO

--Bu tabloda kullan�c�-�r�n sepete ekleme ili�kisine ait bilgiler bulunur.
CREATE TABLE tblKullaniciUrunSepeteEkleme
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   SepeteEklemeTarihi DATE NOT NULL,
   KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   UrunID INT FOREIGN KEY REFERENCES tblUrun(ID) NOT NULL,
          CONSTRAINT pktblKullaniciUrunSepeteEkleme UNIQUE (KullaniciID, UrunID)
)
GO

--Bu tabloda itema ait bilgiler bulunur.
CREATE TABLE tblItem
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   Ad VARCHAR(50) NOT NULL,
   NormalEnderEsya SMALLINT  
        CONSTRAINT EnderChck CHECK (NormalEnderEsya BETWEEN 0 AND 5)-- 1-5 aras� ender olma �zelli�i 
        CONSTRAINT notNullEnder NOT NULL,
   UrunID INT FOREIGN KEY REFERENCES tblUrun(ID) NOT NULL
)
GO

--Bu tabloda kullan�c�-item sat�n alma ili�kisine ait bilgiler bulunur.
CREATE TABLE tblKullaniciItemSatinAlma
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   Fiyat MONEY  DEFAULT 0 NOT NULL,
   SatinAlmaTarihi DATE NOT NULL,
   KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   ItemID INT FOREIGN KEY REFERENCES tblItem(ID) NOT NULL,
)
GO

--Bu tabloda envanter ait bilgiler bulunur.
CREATE TABLE tblEnvanter
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   IstenilenFiyat MONEY  DEFAULT 0 NULL,
   AlisTarih DATE NOT NULL,
   SatisTarih DATE,
   SatisFiyati DATE,
   AlisFiyati MONEY  DEFAULT 0 NOT NULL,
   KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   ItemID INT FOREIGN KEY REFERENCES tblItem(ID) NOT NULL,
)
GO

--Bu tabloda kullan�c�-envanter teklif verme ili�kisine ait bilgiler bulunur.
CREATE TABLE tblKullaniciEnvanterTeklifVerme
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   Tutar MONEY  DEFAULT 0 NOT NULL,
   Durum SMALLINT DEFAULT(0)  NOT NULL ,  --kabul edilirse bir(1) olur
   TeklifVermeTarihi DATE NOT NULL,
   KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   EnvanterID INT FOREIGN KEY REFERENCES tblEnvanter(ID) NOT NULL
)
GO

--Bu tabloda de�erlendirmeye ait bilgiler bulunur.
CREATE TABLE tblDegerlendirme
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   Durum SMALLINT DEFAULT (0) NOT NULL,  --yorum varsa 1 olur
   Tarihi DATE NOT NULL,
   YorumMetni VARCHAR(1000),
   Puan SMALLINT 
		CONSTRAINT PuanChck CHECK (Puan BETWEEN 0 AND 5), -- 1-5 aras� de�erlendirme derecesi
   KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   UrunID INT FOREIGN KEY REFERENCES tblUrun(ID) NOT NULL
)
GO

--Bu tabloda kullan�c�-de�erlendirme be�enme ili�kisine ait bilgiler bulunur.
CREATE TABLE tblKullaniciDegerledirmeBegenme
(
   ID INT IDENTITY(1,1) PRIMARY KEY,
   KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
   DegerlendirmeID INT FOREIGN KEY REFERENCES tblDegerlendirme(ID) NOT NULL
) 
GO












