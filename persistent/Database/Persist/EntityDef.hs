module Database.Persist.EntityDef
    ( -- * Helper types
      HaskellName (..)
    , DBName (..)
    , Attr
      -- * Defs
    , EntityDef (..)
    , SumImplementation (..)
    , FieldDef (..)
    , FieldType (..)
    , UniqueDef (..)
    , ExtraLine
      -- * Utils
    , stripId
    ) where

import Data.Text (Text, stripSuffix, pack)
import Data.Map (Map)

data SumImplementation = UseForeignKeys | UseEntityFields
                         deriving (Show, Eq, Read, Ord)

data EntityDef = EntityDef
    { entityHaskell :: HaskellName
    , entityDB      :: DBName
    , entityID      :: DBName
    , entityAttrs   :: [Attr]
    , entityFields  :: [FieldDef]
    , entityUniques :: [UniqueDef]
    , entityDerives :: [Text]
    , entityExtra   :: Map Text [ExtraLine]
    , entitySum     :: Maybe SumImplementation
    }
    deriving (Show, Eq, Read, Ord)

type ExtraLine = [Text]

newtype HaskellName = HaskellName { unHaskellName :: Text }
    deriving (Show, Eq, Read, Ord)
newtype DBName = DBName { unDBName :: Text }
    deriving (Show, Eq, Read, Ord)

type Attr = Text

data FieldType
    = FTTypeCon (Maybe Text) Text -- ^ optional module, name
    | FTApp FieldType FieldType
    | FTList FieldType
  deriving (Show, Eq, Read, Ord)

data FieldDef = FieldDef
    { fieldHaskell :: HaskellName
    , fieldDB      :: DBName
    , fieldType    :: FieldType
    , fieldAttrs   :: [Attr]
    }
    deriving (Show, Eq, Read, Ord)

data UniqueDef = UniqueDef
    { uniqueHaskell :: HaskellName
    , uniqueDBName  :: DBName
    , uniqueFields  :: [(HaskellName, DBName)]
    }
    deriving (Show, Eq, Read, Ord)

stripId :: FieldType -> Maybe Text
stripId (FTTypeCon Nothing t) = stripSuffix (pack "Id") t
stripId _ = Nothing
