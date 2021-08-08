{-# LANGUAGE OverloadedRecordDot, OverloadedRecordUpdate, DuplicateRecordFields #-}
----------------------------------------------------------------------
data Point = Point { x :: Double, y :: Double, distance :: Point -> Double }

instance Show Point where
    show p = "Point { x = " ++ show p.x ++ ", y = " ++ show p.y ++ " }"

point_distance :: Point -> Point -> Double
point_distance a b = sqrt ((b.x - a.x)^2 + (b.y - a.y)^2)
----------------------------------------------------------------------
make_point x y =
    let
        base = Point x y (\p -> 0.0)
    in
        Point base.x base.y (\other -> point_distance base other)
----------------------------------------------------------------------
a = make_point 0.0 0.0
b = make_point 1.0 1.0
c = make_point 3.0 3.0

ab = a.distance b

ac = a.distance c

bc = b.distance c

result_distance = (make_point 1.0 1.0).distance (make_point 10.0 10.0)