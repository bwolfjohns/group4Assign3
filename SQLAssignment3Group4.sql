ALTER TABLE LibraryProject.AssetTypes
ADD PreperationFees MONEY NOT NULL
DEFAULT $0.99;


UPDATE LibraryProject.AssetTypes ATS SET ATS.PreperationFees = $1.99 WHERE ATS.AssetTypeKey = 2


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


CREATE OR ALTER PROCEDURE LibraryProject.spUpdateAsset
		@AssetKey INT,
		@Asset VARCHAR(50),
		@AssetDescription VARCHAR(50),
		@AssetTypeKey INT,
		@ReplacementCost MONEY,
		@Restricted BIT
AS
BEGIN
	Update LibraryProject.Assets
	SET Asset = @Asset,AssetDescription = @AssetDescription, AssetTypeKey = @AssetTypeKey,ReplacementCost = @ReplacementCost,Restricted = @Restricted
	WHERE AssetKey = @AssetKey
END


CREATE OR ALTER PROCEDURE LibraryProject.spDeactivateAsset
		@AssetKey INT
AS
BEGIN
	UPDATE LibraryProject.Assets
	SET DeactivatedOn = GetDate()
	WHERE AssetKey = @AssetKey
END


CREATE OR ALTER PROCEDURE LibraryProject.spAddOrUpdateUser
		@Add_Update VARCHAR(6),
		@UserKey INT,
		@LastName VARCHAR(50),
		@FirstName VARCHAR(50),
		@Email VARCHAR(50),
		@Address1 VARCHAR(50),
		@Address2 VARCHAR(30),
		@City VARCHAR(30),
		@StateAbb CHAR(2),--StateAbbreviation
		@Bdate DATE,--Birthdate
		@Ruk INT--ResponsibleUserKey
AS
BEGIN
	IF (@Add_Update = 'add' OR @Add_Update = 'Add')
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
		VALUES	(@LastName,@FirstName,@Email,@Address1,@Address2,@City,@StateAbb,@Bdate,@Ruk)
	END
	IF (@Add_Update = 'update' OR @Add_Update = 'Update')
	BEGIN
		UPDATE LibraryProject.Users
		SET LastName = @LastName,FirstName = @FirstName,Email = @Email,Address1 = @Address1,Address2 = @Address2,City = @City,StateAbbreviation = @StateAbb,Birthdate = @Bdate,ResponsibleUserKey = @Ruk
		WHERE UserKey = @UserKey
	END
END

CREATE OR ALTER PROCEDURE LibraryProject.spIssueCard
	@CardNum VARCHAR(11),
	@UserKey INT,
	@CardType INT
AS
BEGIN
	INSERT INTO LibraryProject.Cards
	(
		CardNumber,
		UserKey,
		CardTypeKey
	)
	VALUES (@CardNum,@UserKey,@CardType)
END;


CREATE OR ALTER PROCEDURE LibraryProject.spDeactivateCard
	@CardKey INT
AS
BEGIN
	UPDATE LibraryProject.Cards
	SET DeactivatedOn = GETDATE()
	WHERE CardKey = @CardKey
END;

--Loan Assets
CREATE OR ALTER PROCEDURE LibraryProject.spLoanAsset
	@AssetKey
	@
AS
BEGIN
	UPDATE LibraryProject.Cards
	SET DeactivatedOn = GETDATE()
	WHERE CardKey = @CardKey
END;
/*Testing purposes
EXEC LibraryProject.spCreateNewAssetType 'Audio Book';

EXEC LibraryProject.spUpdateAssetPrepFees 4, 2.99;

EXEC LibraryProject.spCreateAsset 'a book','none','1','20','1';

EXEC LibraryProject.spUpdateAsset  '9', 'a dvd','none', 2, 20, 1;

EXEC LibraryProject.spDeactivateAsset '9';

EXEC LibraryProject.spAddOrUpdateUser 'add', '7', 'Adams', 'Joe', 'somthing@mail.com','123N 456S',Null, 'the big city','UT','1-Jul-30' , 1

EXEC LibraryProject.spAddOrUpdateUser 'update', '7', 'Hughes', 'John','somthing@mail.com','123N 456S', 'Null', 'the big city', 'UT', '1-Jul-30','1'

EXEC LibraryProject.spIssueCard 'C9079-647-9065','7','1'

EXEC LibraryProject.spDeactivateCard '8'

select *from LibraryProject.AssetTypes
select *from LibraryProject.Assets
select *from LibraryProject.Users
select * from LibraryProject.Cards



select * from LibraryProject.AssetLoans
select * from LibraryProject.Assets
select * from LibraryProject.AssetTypes
select * from LibraryProject.Cards
select * from LibraryProject.CardTypes
select * from LibraryProject.Fees
select * from LibraryProject.Users

*/