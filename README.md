# Methods in Haskell

One of the things I really miss from C# when using Haskell is the dot-syntax for properties and methods. I like dot-syntax for methods for a few reasons:

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

# Trying it out

The new `RecordDotSyntax` feature is available in [GHC 9.2.1-alpha2](https://www.haskell.org/ghc/blog/20210422-ghc-9.2.1-alpha2-relased.html).

See the file [point.hs](point.hs) for the full example shown above. It can be loaded into ghc-9.2.1-alpha2 via:

    $ ghci point.hs

# Other approaches

Feel free to comment in the issues if you have suggestions for other approaches to implementing this sort of thing.

# Feedback

See this [r/haskell thread](https://www.reddit.com/r/haskell/comments/p0pclw/haskell_methods/) for some discussion.

# Update

User *friedbrice* made some suggestions in [this thread](https://www.reddit.com/r/haskell/comments/p0pclw/haskell_methods/h89atjy?utm_source=share&utm_medium=web2x&context=3).

Here's an implementation based on his suggestions which implements methods for `distance`, `length`, `div_n`, and `norm`:

```haskell
{-# LANGUAGE OverloadedRecordDot, OverloadedRecordUpdate, DuplicateRecordFields #-}
{-# LANGUAGE RecordWildCards #-}

data Point = Point { 
    x :: Double, 
    y :: Double, 
    distance :: Point -> Double, 
    length :: Double,
    div_n :: Double -> Point,
    norm :: Point
}

instance Show Point where
    show p = "Point { x = " ++ show p.x ++ ", y = " ++ show p.y ++ " }"

make_point :: Double -> Double -> Point
make_point x y =
  let
    distance b = sqrt ((b.x - x)^2 + (b.y - y)^2)
    length = sqrt (x^2 + y^2)
    div_n n = make_point (x/n) (y/n)
    norm = div_n length
    this = Point {..}
  in
    this
```

# Update - `HasField`

User *Dark_Ethereal* [suggested a completely different approach](https://www.reddit.com/r/haskell/comments/p0pclw/haskell_methods/h89gmkg?utm_source=share&utm_medium=web2x&context=3) based on `HasField`.

Here's an implementation based on his suggestions:

```haskell
{-# LANGUAGE OverloadedRecordDot, OverloadedRecordUpdate, DuplicateRecordFields #-}
{-# LANGUAGE DataKinds #-}

import GHC.Records

data Point = Point { x :: Double, y :: Double }

instance Show Point where
    show p = "Point { x = " ++ show p.x ++ ", y = " ++ show p.y ++ " }"

instance HasField "distance" Point (Point -> Double) where
  getField a b = sqrt ((b.x - a.x)^2 + (b.y - a.y)^2)

instance HasField "length" Point (Double) where
  getField a = sqrt (a.x^2 + a.y^2)

instance HasField "div_n" Point (Double -> Point) where
  getField a n = Point (a.x / n) (a.y / n)

instance HasField "norm" Point (Point) where
  getField a = a.div_n a.length
```

## Past discussion

This approach has been explored in the post [Stealing Impl from Rust](https://www.parsonsmatt.org/2021/07/29/stealing_impl_from_rust.html). [Reddit discussion](https://www.reddit.com/r/haskell/comments/ousrpy/stealing_impl_from_rust/).

See also: https://github.com/ElderEphemera/instance-impl

