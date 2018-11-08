--alter table to add preparation fees to asset types
ALTER TABLE LibraryProject.AssetTypes
ADD PreperationFees MONEY NOT NULL
DEFAULT $0.99;


 --add new asset type stored proc.
CREATE OR ALTER PROCEDURE LibraryProject.spCreateNewAssetType
	@AssetType VARCHAR(50)
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset Type Already Exists'
	SELECT
		@DoYouExist = COUNT(LPAT.AssetTypeKey)

	FROM
		LibraryProject.AssetTypes LPAT

	WHERE
		UPPER(LPAT.AssetType) = UPPER(@AssetType)
	IF (@DoYouExist = 0)
	BEGIN
		INSERT INTO LibraryProject.AssetTypes
		(
			AssetType
		)
		VALUES (@AssetType)
	END
	ELSE
	BEGIN
	PRINT @ErrorStatement
	END
END;


--update asset prep fees, because the asset prep fees default to $0.99 add ability to change it
CREATE OR ALTER PROCEDURE LibraryProject.spUpdateAssetPrepFees
	@AssetTypeKey INT,
	@PrepFee MONEY
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset Type Does not exist'
	SELECT
		@DoYouExist = COUNT(LPAT.AssetTypeKey)

	FROM
		LibraryProject.AssetTypes LPAT

	WHERE
		LPAT.AssetTypeKey = @AssetTypeKey
	IF (@DoYouExist > 0)
		BEGIN
			UPDATE 
			LibraryProject.AssetTypes 
			SET 
				PreperationFees = @PrepFee 
			WHERE 
				AssetTypeKey = @AssetTypeKey
		END
	ELSE
		BEGIN
			PRINT @ErrorStatement
		END
	 
END;


--create new asset stored proc.
CREATE OR ALTER PROCEDURE LibraryProject.spCreateAsset
		@Asset VARCHAR(50),
		@AssetDescription VARCHAR(50),
		@AssetTypeKey INT,
		@ReplacementCost MONEY,
		@Restricted BIT
AS
BEGIN
	INSERT INTO LibraryProject.Assets
	(
		Asset ,
		AssetDescription,
		AssetTypeKey,
		ReplacementCost,
		Restricted
	)
	VALUES	(@Asset,@AssetDescription,@AssetTypeKey,@ReplacementCost,@Restricted)
END;

--update asset stored proc
CREATE OR ALTER PROCEDURE LibraryProject.spUpdateAsset
		@AssetKey INT,
		@Asset VARCHAR(50),
		@AssetDescription VARCHAR(50),
		@AssetTypeKey INT,
		@ReplacementCost MONEY,
		@Restricted BIT
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset Does Not Exist'
	SELECT
		@DoYouExist = COUNT(LPUA.AssetKey)

	FROM
		LibraryProject.Assets LPUA

	WHERE
		LPUA.AssetKey = @AssetKey
	IF (@DoYouExist > 0)
		BEGIN
			UPDATE 
				LibraryProject.Assets
			SET	
				Asset = @Asset,
				AssetDescription = @AssetDescription, 
				AssetTypeKey = @AssetTypeKey,
				ReplacementCost = @ReplacementCost,
				Restricted = @Restricted
			WHERE 
				AssetKey = @AssetKey
		END
	ELSE
		BEGIN
			PRINT @ErrorStatement
		END
	
END

--deactivate asset that is in use
CREATE OR ALTER PROCEDURE LibraryProject.spDeactivateAsset
		@AssetKey INT
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset Does Not Exist'
	SELECT
		@DoYouExist = COUNT(LPUA.AssetKey)

	FROM
		LibraryProject.Assets LPUA

	WHERE
		LPUA.AssetTypeKey = @AssetKey
	IF (@DoYouExist > 0)
	BEGIN
		UPDATE LibraryProject.Assets
		SET DeactivatedOn = GetDate()
		WHERE AssetKey = @AssetKey
	END
	ELSE
	BEGIN
		PRINT @ErrorStatement
	END
END


CREATE OR ALTER PROCEDURE LibraryProject.spAddUser
		
		@LastName VARCHAR(50),
		@FirstName VARCHAR(50),
		@Email VARCHAR(50),
		@Address1 VARCHAR(50),
		@Address2 VARCHAR(30),
		@City VARCHAR(30),
		@StateAbb CHAR(2),--StateAbbreviation
		@Bdate DATE,--Birthdate
		@RespibilityKey INT--ResponsibleUserKey
		
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorMesAllreadyExists varchar(100) = 'User already exists'

		SELECT
			@DoYouExist = COUNT(LPUU.UserKey)

		FROM
			LibraryProject.Users LPUU

		WHERE
			UPPER(LPUU.LastName) = UPPER(@LastName)
			AND
			UPPER(LPUU.FirstName) = UPPER(@FirstName)
			AND
			UPPER(LPUU.Address1) = UPPER(@Address1)
			AND
			UPPER(LPUU.City) = UPPER(@City)
			AND 
			UPPER(LPUU.StateAbbreviation) = UPPER(@StateAbb)
			AND
			LPUU.Birthdate = @Bdate
			AND
			UPPER(LPUU.Email) = UPPER(@Email)

		IF(@DoYouExist = 0)
		BEGIN
			INSERT INTO LibraryProject.Users
			(
				LastName,
				FirstName,
				Email,
				Address1,
				Address2,
				City,
				StateAbbreviation,
				BirthDate,
				ResponsibleUserKey
			)
			VALUES	(@LastName,@FirstName,@Email,@Address1,@Address2,@City,@StateAbb,@Bdate,@RespibilityKey)
		END
		ELSE
		BEGIN
			PRINT @ErrorMesAllreadyExists
		END

END

CREATE OR ALTER PROCEDURE LibraryProject.spUpdateUser
	@UserKeyId INT,
	@LastName VARCHAR(50),
	@FirstName VARCHAR(50),
	@Email VARCHAR(50),
	@Address1 VARCHAR(50),
	@Address2 VARCHAR(30),
	@City VARCHAR(30),
	@StateAbb CHAR(2),--StateAbbreviation
	@Bdate DATE,--Birthdate
	@RespibilityKey INT--ResponsibleUserKey
AS
BEGIN
DECLARE @DoYouExist int = 0	
DECLARE @ErrorMesDoesntExist varchar(100) = 'This User Does Not Exist'
	SELECT
		@DoYouExist = COUNT(LPUU.UserKey)

	FROM
		LibraryProject.Users LPUU

	WHERE
		LPUU.UserKey = @UserKeyId

		IF(@DoYouExist > 0)
		BEGIN
			UPDATE 
				LibraryProject.Users
			SET	
				LastName = @LastName,
				FirstName = @FirstName,
				Email = @Email,
				Address1 = @Address1,
				Address2 = @Address2,
				City = @City,
				StateAbbreviation = @StateAbb,
				Birthdate = @Bdate,
				ResponsibleUserKey = @RespibilityKey
			WHERE 
				UserKey = @UserKeyId
		END
		ELSE
		BEGIN
			PRINT @ErrorMesDoesntExist
		END
END

--DEACTIVATE USER CARD
CREATE OR ALTER PROCEDURE LibraryProject.spDeactivateCard
	@CardKey INT,
	@UserKey INT
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Card Does Not Exist'
	SELECT
		@DoYouExist = COUNT(CD.UserKey),
		@CardKey = CD.CardKey

	FROM
		LibraryProject.Cards CD

	WHERE
		CD.UserKey = @UserKey
	GROUP BY
		CD.CardKey
	IF(@DoYouExist > 0)
	BEGIN
		UPDATE LibraryProject.Cards
		SET DeactivatedOn = GETDATE()
		WHERE CardKey = @CardKey
	END
END;


CREATE OR ALTER PROCEDURE LibraryProject.spIssueCard
	@CardNum VARCHAR(11),
	@UserKey INT,
	@CardType INT
AS
BEGIN
	DECLARE @DoYouExist int = 0
	SELECT
		@DoYouExist = COUNT(CD.UserKey)

	FROM
		LibraryProject.Cards CD

	WHERE
		CD.UserKey = @UserKey
	IF(@DoYouExist = 0)
	BEGIN
	INSERT INTO LibraryProject.Cards
	(
		CardNumber,
		UserKey,
		CardTypeKey
	)
	VALUES (@CardNum,@UserKey,@CardType)
	END
	ELSE
	BEGIN
		EXEC LibraryProject.spDeactivateCard @UserKey
	END
END;


--Loan Assets
CREATE OR ALTER PROCEDURE LibraryProject.spLoanAsset
	@AssetKey INT,
	@UserKey INT
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(50) = 'Asset Is already checked out'
	DECLARE @LostItem DATE
	DECLARE @LoanKey INT
	DECLARE @LostStatement varchar(50)
	SELECT
		@DoYouExist = COUNT(AL.AssetKey),
		@LoanKey = AL.AssetLoanKey,
		@LostItem = AL.LostOn

	FROM
		LibraryProject.AssetLoans AL

	WHERE
		AL.ReturnedOn IS NULL
		AND
		AL.AssetKey = @AssetKey
	GROUP BY
		AL.LostOn,
		AL.AssetLoanKey
	IF(@DoYouExist = 0)
	BEGIN
		INSERT INTO LibraryProject.AssetLoans
		(
			AssetKey,
			UserKey,
			LoanedOn
		)
		VALUES	(@AssetKey,@UserKey,GETDATE())
	END
	ELSE IF (@LostItem IS NOT NULL)
	BEGIN
		SET @LostStatement = CONCAT('Item was reported lost on ', @LostItem)
		PRINT @LostStatement
	END
	ELSE
	BEGIN
		PRINT @ErrorStatement
	END
END;


CREATE OR ALTER PROCEDURE LibraryProject.spLoanReturnAsset
	@AssetLoanKey INT
	
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset has not been Loaned'
	DECLARE @LostError DATE
	DECLARE @LostStatement varchar(50)
	SELECT
		@DoYouExist = COUNT(AL.AssetKey),
		@LostError = AL.LostOn

	FROM
		LibraryProject.AssetLoans AL

	WHERE
		AL.AssetLoanKey = @AssetLoanKey
		AND
		AL.ReturnedOn IS NULL
	GROUP BY
		AL.LostOn
	IF(@DoYouExist > 0)
	BEGIN
		IF(@LostError IS NULL)
		BEGIN
		UPDATE LibraryProject.AssetLoans
		SET ReturnedOn = GETDATE()
		WHERE AssetLoanKey = @AssetLoanKey
		END
		ELSE
		BEGIN
		SET @LostStatement = CONCAT('Item was reported lost on ', @LostError)
		PRINT @LostStatement
		END
	END
	ELSE
	BEGIN
		PRINT @ErrorStatement
	END
END;


CREATE OR ALTER PROCEDURE LibraryProject.spAssetLost
	@AssetLoanKey INT
	
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset loan does not exist'
	SELECT
		@DoYouExist = COUNT(AL.AssetKey)

	FROM
		LibraryProject.AssetLoans AL

	WHERE
		AL.AssetLoanKey = @AssetLoanKey
		AND
		AL.LoanedOn IS NOT NULL
		AND
		AL.ReturnedOn IS NULL

	IF(@DoYouExist > 0)
	BEGIN
		UPDATE LibraryProject.AssetLoans
		SET LostOn = GETDATE()
		WHERE AssetLoanKey = @AssetLoanKey
	END
	ELSE
	BEGIN
		PRINT @ErrorStatement
	END

END;



CREATE OR ALTER PROCEDURE LibraryProject.spPayFee
	@FeeKey INT
AS
BEGIN
	UPDATE LibraryProject.Fees
	SET Paid = 1, Amount = 0
	WHERE FeeKey = @FeeKey
END;

CREATE OR ALTER TRIGGER LibraryProject.VerifyUser
ON LibraryProject.AssetLoans
AFTER INSERT
AS
BEGIN
	DECLARE @UserCardType INT
	DECLARE @AssetLoanKeyID INT
	DECLARE @NotOldEnough varchar(50) = 'You are not old enough'
	SELECT
		@UserCardType = CD.CardTypeKey,
		@AssetLoanKeyID = i.AssetLoanKey 
	FROM 
		inserted i 
		INNER JOIN LibraryProject.AssetLoans AL ON i.AssetLoanKey = AL.AssetLoanKey
		INNER JOIN LibraryProject.Cards CD ON i.UserKey = CD.UserKey
	
	IF(@UserCardType <> 1)
	BEGIN
		DELETE FROM LibraryProject.AssetLoans WHERE AssetLoanKey = @AssetLoanKeyID
		PRINT @NotOldEnough
	END

END;

CREATE OR ALTER TRIGGER LibraryProject.CheckLimitOfAssets
ON LibraryProject.AssetLoans
AFTER INSERT
AS
BEGIN
	DECLARE @UserKey INT
	DECLARE @UserCardType INT
	DECLARE @ItemsLoaned INT
	DECLARE @AssetLoanInsKey INT
	DECLARE @ErrorMsg varchar(50) = CONCAT(CONCAT('You have exceded the asset loan limit of ', @ItemsLoaned), ' Items.')

	SELECT
		@AssetLoanInsKey = AssetLoanKey
	FROM
		inserted

	SELECT 
		@ItemsLoaned = COUNT(AL.AssetLoanKey), 
		@UserKey = CD.UserKey,
		@UserCardType =  CD.CardTypeKey
	FROM 
		LibraryProject.Cards CD
		INNER JOIN LibraryProject.AssetLoans AL ON CD.UserKey = AL.UserKey
	WHERE 
		AL.ReturnedOn IS NULL 
		AND AL.LostOn IS NULL
	GROUP BY
		CD.UserKey,
		CD.CardTypeKey
	
	IF(@UserCardType = 1 AND @ItemsLoaned > 6) --ADULTS
	BEGIN
		DELETE FROM LibraryProject.AssetLoans WHERE AssetLoanKey = @AssetLoanInsKey
	END
	ELSE IF(@UserCardType = 2 AND @ItemsLoaned > 4) --TEENS
	BEGIN
		DELETE FROM LibraryProject.AssetLoans WHERE AssetLoanKey = @AssetLoanInsKey
	END
	ELSE IF(@UserCardType = 3 AND @ItemsLoaned > 2) --CHILDREN
	BEGIN
		DELETE FROM LibraryProject.AssetLoans WHERE AssetLoanKey = @AssetLoanInsKey
	END
END

UPDATE LibraryProject.AssetLoans
SET LostOn = GETDATE()
WHERE AssetKey = 1 AND UserKey = 6

CREATE OR ALTER FUNCTION  LibraryProject.CalculatePrepFees(@assetKey AS INT)
RETURNS MONEY
AS
BEGIN
	DECLARE @PrepFee MONEY = 0
	SELECT @PrepFee = ATAT.PreperationFees FROM LibraryProject.Assets AST
	INNER JOIN LibraryProject.AssetTypes ATAT ON AST.AssetTypeKey = ATAT.AssetTypeKey
	RETURN @PrepFee
END


--Fee Function
CREATE OR ALTER FUNCTION LibraryProject.CalculateFees(@assetLoanKey AS INT)
RETURNS MONEY
AS
BEGIN
	DECLARE @ReturnedOn DATE = NULL
	DECLARE @LoanedOn DATE = NULL
	DECLARE @LostOn DATE = NULL
	DECLARE @KeyOfAsset INT = 0
	Declare @Cost MONEY = 0
	Declare @Days INT = 0
	SELECT 
		@LoanedOn = AL.LoanedOn,
		@ReturnedOn = AL.ReturnedOn,
		@LostOn = AL.LostOn,
		@KeyOfAsset = AL.AssetKey
	FROM 
		LibraryProject.AssetLoans AL 
	WHERE 
		AL.AssetKey = @assetLoanKey
	DECLARE @ERROR_MESSAGE1 varchar(50) = 'This asset has not been returned or reported lost'
	
	IF (@ReturnedOn IS NOT NULL)
	BEGIN
	SET @Days = DATEDIFF(day, @LoanedOn,@ReturnedOn)
		IF (@Days < 25)
		BEGIN
			SET @Cost = 0
		END
		ELSE IF(@Days > 24 AND @Days < 29)
		BEGIN
			SET @Cost = 1.00
		END
		ELSE IF(@Days > 28 AND @Days < 36)
		BEGIN
			SET @Cost = 2.00
		END
		ELSE
		BEGIN
			SET @Cost = 3.00
		END
	END
	ELSE IF(@LostOn IS NOT NULL)
	BEGIN
		DECLARE @AssetPrice MONEY = 0
		DECLARE @PreperationFee MONEY = 0
		SET @PreperationFee = LibraryProject.CalculatePrepFees(@KeyOfAsset)
		
		SELECT
			@AssetPrice = AST.ReplacementCost
		FROM
			LibraryProject.Assets AST
		WHERE 
			AST.AssetKey = @KeyOfAsset
		IF(@AssetPrice + @PreperationFee < 29.99)
		BEGIN
			SET @Cost = @AssetPrice + @PreperationFee
		END
		ELSE
		BEGIN
			SET @Cost = 29.99
		END
	END
	RETURN (@Cost)
END;


EXEC LibraryProject.spCreateNewAssetType 'Audio Book';
EXEC LibraryProject.spCreateNewAssetType 'Digital Book';

EXEC LibraryProject.spUpdateAssetPrepFees 4, 1.99;
EXEC LibraryProject.spUpdateAssetPrepFees 4, 1.69;
EXEC LibraryProject.spUpdateAssetPrepFees 3, 2.99;

--insert 10 assets
EXEC LibraryProject.spCreateAsset 'OathBringer','Book 3 of the Stormlight Archives by BrandonSanderson',4,24.19,0
EXEC LibraryProject.spCreateAsset 'Mistborn','First book in the Mistborn trilogy by Brandon Sanderson',4,9.89,0
EXEC LibraryProject.spCreateAsset 'Fight Club','R rated movie staring Brad Pitt and Edward Norton',1,14.99,1
EXEC LibraryProject.spCreateAsset 'The Shining','A Horror thriller by Stephen King',3,6.29,1
EXEC LibraryProject.spCreateAsset 'Misery','A Horror thriller by Stephen King',3,7.55,1
EXEC LibraryProject.spCreateAsset 'Misery','R rated thriller movie starring James Cann and Kathy Bates',1,10.99,1
EXEC LibraryProject.spCreateAsset 'Despicable Me','PG rated childrens movie starring Steve Carell',1,15.99,0
EXEC LibraryProject.spCreateAsset 'The Nightmare Before Christmas','PG rated stop motion musical featuring the music of Danny Elfman',1,20.05,0
EXEC LibraryProject.spCreateAsset 'Wackey Wednesday','A Childrens book by Dr. Suess',4,19.25,0
EXEC LibraryProject.spCreateAsset 'Singing in the Rain','A musical movie starring Debbie Reynolds and Gene Kelley',1,5.69,0

--insert 3 users

EXEC LibraryProject.spAddOrUpdateUser 'add',NULL,'Joe','Adams','joeadams@fakemail.com','123 N 456 S',NULL,'Ogden','UT','7/1/1930',0
EXEC LibraryProject.spAddOrUpdateUser 'add',NULL,'Joe','Smith','js@fake.com','123 Fake St',NULL,'Ogden','UT','12/23/1805',0
EXEC LibraryProject.spAddOrUpdateUser 'add',NULL,'Abraham','Lincoln','honestabe@president.gov','1600 Pennsylvania Ave NW',NULL,'Washington','DC','2/12/1809',0

/*Testing purposes
EXEC LibraryProject.spCreateNewAssetType 'Audio Book';

EXEC LibraryProject.spUpdateAssetPrepFees 2, 1.99;

EXEC LibraryProject.spCreateAsset 'a book','none','1','20','1';

EXEC LibraryProject.spUpdateAsset  '9', 'a dvd','none', 2, 20, 1;

EXEC LibraryProject.spDeactivateAsset '9';

EXEC LibraryProject.spAddOrUpdateUser 'add', '7', 'Adams', 'Joe', 'somthing@mail.com','123N 456S',Null, 'the big city','UT','1-Jul-30' , 1

EXEC LibraryProject.spAddOrUpdateUser 'update', '7', 'Hughes', 'John','somthing@mail.com','123N 456S', 'Null', 'the big city', 'UT', '1-Jul-30','1'

EXEC LibraryProject.spIssueCard 'C9079-647-9065','7','1'

EXEC LibraryProject.spDeactivateCard '8'

EXEC LibraryProject.spLoanAsset '11', '6'

EXEC LibraryProject.spAssetLost '12'

EXEC LibraryProject.spLoanReturnAsset '9'

select *from LibraryProject.AssetTypes
select *from LibraryProject.Assets
select *from LibraryProject.Users
select * from LibraryProject.Cards



select * from LibraryProject.AssetLoans
select * from LibraryProject.Cards
select * from LibraryProject.AssetLoans
select * from LibraryProject.Assets
select * from LibraryProject.CardTypes
select * from LibraryProject.Fees
select * from LibraryProject.Users

*/

INSERT INTO LibraryProject.AssetLoans VALUES(7, 3, '9/15/2018', '10/26/2018', NULL)

DELETE FROM LibraryProject.AssetLoans WHERE AssetLoanKey = '6'

SELECT
		CD.CardTypeKey,
		AL.AssetLoanKey 
	FROM 
		LibraryProject.AssetLoans AL INNER JOIN LibraryProject.Cards CD ON AL.UserKey = CD.UserKey

SELECT
		COUNT(AL.AssetKey),
		AL.AssetLoanKey,
		AL.LostOn

	FROM
		LibraryProject.AssetLoans AL
	WHERE
		AL.ReturnedOn IS NULL
	GROUP BY
		AL.AssetLoanKey,
		AL.LostOn



		--testing

		DECLARE @LoanedOn DATE = '6-nov-2018'
		SELECT DATEDIFF(day,@LoanedOn,GETDATE())