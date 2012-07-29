{-# OPTIONS_GHC -fno-warn-unused-binds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}

{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE EmptyDataDecls #-}
module SumTypeTest (specs) where

import Test.Hspec.Monadic
import Test.Hspec.HUnit ()
import Test.HUnit
import Database.Persist.Sqlite
import Database.Persist.TH
#ifndef WITH_MONGODB
import qualified Data.Conduit as C
import qualified Data.Conduit.List as CL
import Database.Persist.EntityDef
import Database.Persist.GenericSql.Raw
import qualified Data.Map as Map
#endif
#if WITH_POSTGRESQL
import Database.Persist.Postgresql
#endif
import qualified Data.Text as T

import Init

#if WITH_MONGODB
mkPersist persistSettings [persistUpperCase|
#else
share [mkPersist sqlSettings, mkMigrate "sumTypeMigrate"] [persistLowerCase|
#endif
Bicycle
    make T.Text
    deriving Show Eq
Car
    make T.Text
    model T.Text
    deriving Show Eq
+Vehicle
    bicycle BicycleId
    car CarId
    deriving Show Eq
+Transport
    bicycle Bicycle
    car Car
    deriving Show Eq
|]

specs :: Spec
specs = describe "sum types" $ do
    it "sum models" $ asIO $ runConn $ do
#ifndef WITH_MONGODB
        _ <- liftIO $ runMigrationSilent sumTypeMigrate
#endif
        car1 <- insert $ Car "Ford" "Thunderbird"
        car2 <- insert $ Car "Kia" "Rio"
        bike1 <- insert $ Bicycle "Shwinn"

        return ()
{-
        vc1 <- insert $ TransportCarSum car1
        vc2 <- insert $ TransportCarSum car2
        vb1 <- insert $ TransportBicycleSum bike1

        x1 <- get vc1
        liftIO $ x1 @?= Just (TransportCarSum car1)

        x2 <- get vc2
        liftIO $ x2 @?= Just (TransportCarSum car2)

        x3 <- get vb1
        liftIO $ x3 @?= Just (TransportBicycleSum bike1)
        -}

    it "sum ids" $ asIO $ runConn $ do
        car1 <- insert $ Car "Ford" "Thunderbird"
        car2 <- insert $ Car "Kia" "Rio"
        bike1 <- insert $ Bicycle "Shwinn"

        vc1 <- insert $ VehicleCarSum car1
        vc2 <- insert $ VehicleCarSum car2
        vb1 <- insert $ VehicleBicycleSum bike1

        x1 <- get vc1
        liftIO $ x1 @?= Just (VehicleCarSum car1)

        x2 <- get vc2
        liftIO $ x2 @?= Just (VehicleCarSum car2)

        x3 <- get vb1
        liftIO $ x3 @?= Just (VehicleBicycleSum bike1)

asIO :: IO a -> IO a
asIO = id
