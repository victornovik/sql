/*DROP TABLE [dbo].[Names];

CREATE TABLE [dbo].[Names](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[firstName] [nvarchar](max) NOT NULL,
	[lastName] [nvarchar](max) NOT NULL,
CONSTRAINT [PK_Names] PRIMARY KEY CLUSTERED ([id] ASC));

INSERT INTO [dbo].[Names] (firstName, lastName)
VALUES ('Victor', 'Novik'), ('John', 'Smith')*/

-- Swap values between two rows
UPDATE Names
SET 
    firstName = CASE id
        WHEN 1 THEN (SELECT firstName FROM Names WHERE id = 2)
        WHEN 2 THEN (SELECT firstName FROM Names WHERE id = 1)
    END,
    lastName = CASE id
        WHEN 1 THEN (SELECT lastName FROM Names WHERE id = 2)
        WHEN 2 THEN (SELECT lastName FROM Names WHERE id = 1)
    END
WHERE id IN (1, 2);