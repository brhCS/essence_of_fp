module Main where
-- Interpreter for lambda calculus

-- Three functions for working with generic monads.
-- unitM coerces a value into the computation monad,
-- bindM lifts a value from one monad into another,
-- and showM gets us out of the monad to see just the value
unitM :: a -> M a
bindM :: M a -> (a -> M b) -> M b
showM :: M Value -> String

-- The code for the interpreter. Plugging different monads
-- into the same generic base gives greatly varying behavior
type Name = String
data Term = Var Name
          | Con Int
          | Add Term Term
          | Lam Name Term
          | App Term Term

data Value = Wrong
           | Num Int
           | Fun (Value -> M Value)

type Environment = [(Name, Value)]

showval :: Value -> String
showval Wrong = "<wrong>"
showval (Num i) = show i
showval (Fun f) = "<function>"

interp :: Term -> Environment -> M Value
interp (Var x) e = Main.lookup x e
interp (Con i) e = unitM (Num i)
interp (Add u v) e = interp u e `bindM` (\a ->
                     interp v e `bindM` (\b ->
                     add a b))
interp (Lam x v) e = unitM (Fun (\a -> interp v ((x,a):e)))
interp (App t u) e = interp t e `bindM` (\f ->
                     interp u e `bindM` (\a ->
                     apply f a))

lookup :: Name -> Environment -> M Value
lookup x [] = unitM Wrong
lookup x ((y,b):e) = if x == y then unitM b else Main.lookup x e

add :: Value -> Value -> M Value
add (Num i) (Num j) = unitM (Num (i+j))
add a b = unitM Wrong

apply :: Value -> Value -> M Value
apply (Fun k) a = k a
apply f a = unitM Wrong

test :: Term -> String
test t = showM (interp t [])


-----------------------
-- 0) Standard Interpreter
-- When we provide the identity monad, we get
-- the standard metacircular interpeter for lambda
-- calculus
type I a = a
unitI a = a
a `bindI` k = k a
showI = showval

type M a = I a
unitM = unitI
bindM = bindI
showM = showI

----------------------
-- To be used as a test:
-- ((\x.x + x) (10 + 11)) => 42
term0 = App (Lam "x" (Add (Var "x") (Var "x")))
            (Add (Con 10) (Con 11))

main = putStrLn . test $ term0
