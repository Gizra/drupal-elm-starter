module Pusher.Utils exposing (getClusterName)

import Pusher.Model exposing (Cluster(..))


getClusterName : Cluster -> String
getClusterName cluster =
    case cluster of
        ApSouthEast1 ->
            "ap1"

        EuWest1 ->
            "eu"

        UsEast1 ->
            "mt1"
