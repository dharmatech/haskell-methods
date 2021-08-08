# Methods in Haskell

One of the things I really miss from C# when using Haskell is the dot-syntax for properties and methods. I like dot-syntax for methods for a few reasons

- Explorability of the language. You type `xyz.` and the IDE shows you what operations are available on `xyz` via IntelliSense.
- Namespace management
  - You can have a method `move` on one class and another (unrelated) method `move` on another class and there's no name clash.
  - Haskell folks will point to type classes for this sort of thing. However, that only makes sense if the `move` is semantically the same for both classes.
  - When all you have is Haskell modules for namespace management, you end up in `import qualified` land which gets messy fast.

Well, the good news is, GHC is getting [dot-syntax for records](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0282-record-dot-syntax.rst).

So, can we abuse this new feature to get something like dot-syntax for methods?

# Example using Point

Let's define a `Point` record which has a `distance` "method" on it:

    data Point = Point { x :: Double, y :: Double, distance :: Point -> Double }
 
And a way to show it: 
 
    instance Show Point where
        show p = "Point { x = " ++ show p.x ++ ", y = " ++ show p.y ++ " }"
        
Now let's define a function to get the distance between two points:

    point_distance :: Point -> Point -> Double
    point_distance a b = sqrt ((b.x - a.x)^2 + (b.y - a.y)^2)

And finally a constructor for points which takes care of setting up the `distance` method:

    make_point x y =
        let
            base = Point x y (\p -> 0.0)
        in
            Point base.x base.y (\other -> point_distance base other)

OK, now to see it in action. Let's define three points:

    a = make_point 0.0 0.0
    b = make_point 1.0 1.0
    c = make_point 3.0 3.0

Find the distance betweeen `a` and `b`:

    ab = a.distance b

Similar for `a` and `c`:

    ac = a.distance c

And `b` and `c`:

    bc = b.distance c
