--�r�n sat�n al�rken, �r�n�n fiyat� ve c�zdandaki bakiye kontrol� yapan procedure.
IF OBJECT_ID(' dbo.sp_UrunSatisi') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.sp_UrunSatisi
		END
	GO
-- Puan tablosu eklendi.
--CREATE TABLE PuanTablosu ( KullaniciID INT, OdulPuan INT );

CREATE OR ALTER PROCEDURE  dbo.sp_UrunSatisi (@KullaniciID INT, @UrunID INT)
AS 
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

	DECLARE @UrununFiyati MONEY;
	SELECT @UrununFiyati=Fiyat
	FROM tblKullaniciUrunSatinAlma
	WHERE @UrunID=UrunID;

	DECLARE @MevcutBakiye MONEY;
	SELECT @MevcutBakiye=Cuzdan
	FROM tblKullanici
	WHERE @KullaniciID=ID;

	--E�er �r�n�n fiyat�, kullan�c�n�n bakiyesinden y�ksekse ERROR verilir.
	IF @UrununFiyati>@MevcutBakiye
		BEGIN
			RAISERROR('Yetersiz bakiye. Sat�� tamamlanamad�.',16,1);	
		END

	-- �r�n�n fiyat�na bakiyesi yetiyorsa, �r�n�n ve kullan�c�n�n bilgileri tblKullaniciUrunSatinAlma tablosuna eklenir.
	-- Kullan�c�n�n c�zdan�nda da gerekli de�i�iklikler yap�l�r.
    ELSE 
		BEGIN
			-- Her �r�n�n SeriNumarasi i�in i�in unique ID'ler verilir.
			DECLARE @SeriNumarasi VARCHAR(25) = CONVERT(VARCHAR(MAX), NEWID());
			INSERT INTO tblKullaniciUrunSatinAlma VALUES(@SeriNumarasi, GETDATE(), @UrununFiyati, @KullaniciID,@UrunID);
			PRINT 'Sat�� i�lemi ger�ekle�tirildi';

			-- Kullan�c�n�n c�zdan�, sat�n alma i�leminden sonra g�ncellenir.
			UPDATE tblKullanici
			SET Cuzdan = Cuzdan - @UrununFiyati
			WHERE ID = @KullaniciID;
		END
	END TRY
	-- If blogundaki ERROR'u yazd�r�r.
	BEGIN CATCH
		PRINT 'Hata Olu�tu: ' + ERROR_MESSAGE();
	END CATCH
	COMMIT TRANSACTION
	END
	
--KullaniciID'si 1 olan UrunID'si 2 olan �r�n sat��� ger�ekle�ir.
EXEC dbo.sp_UrunSatisi 1,2 -- Oyun hi� sat�n almam�� ve c�zdan�nda para bulunan bir kullan�c�
EXEC dbo.sp_UrunSatisi 440,1 -- Oyun daha �nce sat�n alm�� bir kullan�c�
EXEC dbo.sp_UrunSatisi 500,1 -- Oyun daha �nce sat�n almam�� ama c�zdan�nda para bulunmayan bir kullan�c�

	