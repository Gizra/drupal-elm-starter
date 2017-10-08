module Pusher.Utils
    exposing
        ( getClusterName
        )

import Pusher.Model exposing (Cluster(ApSouthEast1, EuWest1, UsEast1))


getClusterName : Cluster -> String
getClusterName cluster =
    case cluster of
        ApSouthEast1 ->
            "ap1"

        EuWest1 ->
            "eu"

        UsEast1 ->
            "mt1"
