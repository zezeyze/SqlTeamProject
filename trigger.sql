-- Kullan�c�lar �r�n sat�n ald�ktan sonra belirlenen miktarda puan tablosuna �d�l puanlar ekleyen trigger.
IF OBJECT_ID(' dbo.trg_UrunSatinAlma') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.trg_UrunSatinAlma
		END
	GO

-- Puan tablosu eklendi.
--CREATE TABLE PuanTablosu ( KullaniciID INT, OdulPuan INT );

CREATE OR ALTER TRIGGER trg_UrunSatinAlma
ON tblKullaniciUrunSatinAlma
AFTER INSERT
AS
BEGIN
    DECLARE @KullaniciID INT, @Harcama MONEY;

    -- Eklenen verilerin bilgileri al�n�r.
    SELECT @KullaniciID = KullaniciID, @Harcama = SUM(Fiyat)
    FROM inserted
    GROUP BY KullaniciID; -- KullaniciID'ye g�re gruplan�r.
    BEGIN        
		-- Her �r�n�n fiyat�n�n %10'u kadar �d�l puan verilir.
        DECLARE @OdulPuan INT = @Harcama * 0.1; 

        -- PuanTablosu tablosuna kullan�c�ya verilen �d�l puan� eklenir.
        INSERT INTO PuanTablosu (KullaniciID, OdulPuan)
        VALUES (@KullaniciID, @OdulPuan);

        -- Kullan�c�ya yap�lan i�lem hakk�nda bilgilendirme yap�l�r.
        PRINT 'Tebrikler! Toplam harcaman�z ' + CONVERT(VARCHAR, @Harcama) +
		' �zerinde oldu�u i�in ' + CONVERT(VARCHAR, @OdulPuan) + ' puan kazand�n�z.';
    END
END;

