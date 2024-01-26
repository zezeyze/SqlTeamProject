-- Baþarýmlardan kaç tanesi bu oyuna sahiptir ve 
-- kullanýcýlar tarafýndan açýlmýþ mý sorularýný kontrol eden fonksiyon.
IF OBJECT_ID(' dbo.fncBasarimYuzdesi') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.fncBasarimYuzdesi
		END
	GO

CREATE OR ALTER FUNCTION dbo.fncBasarimYuzdesi(@oyunID INT)
RETURNS FLOAT
AS
	BEGIN
        DECLARE @BasarimYuzdesi FLOAT
		
		SELECT @BasarimYuzdesi = AVG(CONVERT(FLOAT,acilan_basarim_saiyisi)) 
		FROM
		( -- Belirli oyuna sahip olan kullanýcýlarýn baþarým sayýsý count ifadesiyle saydýrýlýr.
			SELECT kba.KullaniciID, COUNT(kba.ID) as acilan_basarim_saiyisi
			FROM tblKullaniciBasarimAcma kba
			INNER JOIN tblBasarim B ON kba.BasarimID = B.ID
			INNER JOIN tblUrun U ON U.ID = B.UrunID
		    WHERE U.ID = @oyunID 
		    GROUP BY kba.KullaniciID -- Kullanýcýlarýn toplam baþarý sayýlarýna göre gruplar.
		) basarimyuzdesi

    RETURN @BasarimYuzdesi
	END
GO

-- ID'si 2 olan oyun icin basarim yüzdesi sorgulanýr.
SELECT dbo.fncBasarimYuzdesi('2') AS BASARIM_YUZDESI
GO
