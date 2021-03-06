module Definitions where

{-# LANGUAGE  QuasiQuotes #-}
{-# LANGUAGE  TemplateHaskell #-}
-- {-# OPTIONS_GHC -dth-dec-file #-}
{-======================================================
Porting TIP problems from  
https://github.com/tip-org/benchmarks/blob/master/original/isaplanner/Properties.hs
To improve verification time, run this file in LH by pieces (leave uncommented only the proof you want to check)
======================================================-}
import Language.Haskell.Liquid.ProofCombinators
import Language.Haskell.Liquid.ProofGenerator
import Lib.Definitions
import Prelude hiding (take, drop,
(++),
(+),(-), (<=), (<), min, max,
length, elem, not, dropWhile,takeWhile,last,zip,
const, null
                      )
{-@ LIQUID "--reflection" @-}
{-@ LIQUID "--ple-local" @-}
{-@ LIQUID "--max-rw-ordering-constraints=0" @-}
-- lemma right identity on append
[lhp|genProp|inline|ple|induction|caseExpand
rightIdApp :: Eq a => [a] -> Bool
rightIdApp xs = xs ++ [] == xs
|]
--------------------------------------------------
{-
{-======================================================
                        prop_01
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:2
prop_01 :: Eq a => NAT  -> [a] -> Bool
prop_01 n xs = (take n xs ++ drop n xs == xs)
|]
{-======================================================
                        prop_02
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:2
prop_02 :: NAT -> [NAT] -> [NAT] -> Bool
prop_02  n xs ys = (count n xs + count n ys == count n (xs ++ ys))
|]
{-======================================================
                   prop_03 (hint: lemma) (cvc4-ok, non-simp-ind)
=======================================================-}
{-@ rewriteWith prop_03_proof [lemma_count_proof] @-}
[lhp|genProp|reflect|ple
prop_03 :: NAT -> [NAT] -> [NAT] -> Bool
prop_03 n xs ys
  = count n xs <= count n (xs ++ ys)
    -- ? lemma_count_proof n xs ys
    ? lemma_diseq_proof (count n xs) (count n ys)
|]
[lhp|genProp|inline|admit
lemma_count :: NAT -> [NAT] -> [NAT] -> Bool
lemma_count n xs ys = count n (xs ++ ys) == (count n xs) + (count n ys)
|]
[lhp|genProp|reflect|admit
lemma_diseq :: NAT -> NAT -> Bool
lemma_diseq n m = n <= n+m
|]
{-======================================================
                  prop_04
=======================================================-}
[lhp|genProp|reflect|ple
prop_04 :: NAT -> [NAT] -> Bool
prop_04 n xs
  = (S (count n xs) == count n (n : xs))
|]
{-======================================================
                        prop_05
=======================================================-}
[lhp|genProp|reflect
prop_05 :: NAT -> NAT -> [NAT] -> Bool
prop_05 n x xs
  = (n == x) ==> (S (count n xs) == count n (x : xs))
|]
{-======================================================
                        prop_06
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:1
prop_06 :: NAT -> NAT -> Bool
prop_06 n m = (n - (n + m) == Z)
|]
{-======================================================
                        prop_07
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:1
prop_07 :: NAT -> NAT -> Bool
prop_07 n m = ((n + m) - n == m)
|]
{-======================================================
                        prop_08
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:1
prop_08 :: NAT -> NAT -> NAT -> Bool
prop_08 k m n = ((k + m) - (k + n) == m - n)
|]
{-======================================================
                        prop_09
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:2
prop_09 :: NAT -> NAT -> NAT -> Bool
prop_09 i j k
  = ((i - j) - k == i - (j + k))
|]
{-======================================================
                        prop_10
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_10 ::  NAT -> Bool
prop_10  m
  = (m - m == Z)
|]
{-======================================================
                        prop_11
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_11 ::  Eq a => [a] -> Bool
prop_11 xs
  = (drop Z xs == xs)
|]
{-======================================================
                        prop_13
=======================================================-}
[lhp|genProp|reflect|ple
prop_13 ::  NAT -> NAT -> [NAT] -> Bool
prop_13 n x xs
  = (drop (S n) (x : xs) == drop n xs)
|]
{-======================================================
                   prop_15 (hint: lemma) (cvc4-ok, non-simp-ind)
=======================================================-}
-- {-@ rewriteWith prop_15_proof [lemma_insert_proof] @-}
[lhp|genProp|reflect|ple
prop_15 ::  NAT -> [NAT] -> Bool
prop_15 n (x:xs) 
  | n<<x = trivial
  | otherwise = () ? prop_15_lemma_proof n x xs
-- the property:
prop_15 n ls = (length (insert n ls) == S (length ls))
|]
[lhp|genProp|inline|ple
prop_15_lemma :: NAT -> NAT -> [NAT] -> Bool
prop_15_lemma n x lls@(l:ls) 
          | n<<l = trivial
          | otherwise = () ? prop_15_lemma_proof n l ls
prop_15_lemma n x ls = length (insert n ls) == length (x:ls)
|]
{-======================================================
                 prop_16
=======================================================-}
[lhp|genProp|reflect
prop_16 :: NAT -> [NAT] -> Bool
prop_16 x xs
  = (xs == [] ) ==> (last (x:xs) == x)
|]
{-======================================================
                   prop_17
=======================================================-}
[lhp|genProp|reflect|ple
prop_17 ::  NAT -> Bool
prop_17 n = ((n <<= Z) == (n == Z))
|]
{-======================================================
                   prop_18
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:1
prop_18 ::  NAT -> NAT -> Bool
prop_18 i m
  = (i << S (i + m))
|]
{-======================================================
                        prop_19
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_19 ::  NAT -> [NAT] -> Bool
prop_19 n xs
  = (length (drop n xs) == length xs - n)
|]
{-======================================================
                     prop_20 (hint: lemma, induction) (cvc4-ok, non-simp-ind)
=======================================================-}
-- {-@ rewriteWith prop_20_proof [prop_20_lemma_proof] @-}
[lhp|genProp|inline|ple|caseExpand
prop_20 ::  [NAT] -> Bool
prop_20 ls@(x : xs)
  = ()
    ? prop_20_lemma_proof x xs
    ? prop_20_proof xs
-- property
prop_20 xs = (length (sort xs) == length xs)
|]
[lhp|genProp|inline|ple|admit
prop_20_lemma :: NAT -> [NAT] -> Bool
prop_20_lemma x xs = length (insort x (sort xs)) == S (length (sort xs))
|]
-- {-@ reflect prop_20 @-}
-- prop_20 :: [NAT] -> Bool
-- prop_20 xs = ((length (sort xs)) == length xs)
-- {-@ ple prop_20_proof @-}
-- {-@ rewriteWith prop_20_proof [prop_20_lemma_proof] @-}
-- {-@ prop_20_proof :: ns:[NAT] -> { prop_20 ns } @-}
-- prop_20_proof :: [NAT] -> Proof
-- prop_20_proof xs@[] = trivial
-- prop_20_proof ls@(x : xs)
--   = length (sort ls) == length ls 
--     ? prop_20_lemma_proof x xs
--     ? prop_20_proof xs
--   -- ?(length (sort ls)
--   -- === length (insort x (sort xs))
--   --   ? prop_20_lemma_proof x xs
--   -- === S (length (sort xs))
--   --   ? prop_20_proof xs
--   -- === S (length xs)
--   -- === length ls
--   -- )
--   *** QED
{-======================================================
                   prop_21
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:1
prop_21 ::  NAT -> NAT -> Bool
prop_21 n m
  = (n <<= (n + m))
|]
{-======================================================
                     prop_22
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_22 ::  NAT -> NAT -> NAT -> Bool
prop_22 a b c
  = (max (max a b) c == max a (max b c))
|]
{-======================================================
                     prop_23
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_23 ::  NAT -> NAT -> Bool
prop_23 a b
  = (max a b == max b a)
|]
{-======================================================
                     prop_24
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_24 ::  NAT -> NAT -> Bool
prop_24 a b
  = ((max a b) == a) == (b <<= a)
|]
{-======================================================
                     prop_25
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_25 ::  NAT -> NAT -> Bool
prop_25 a b
  = ((max a b) == b) == (a <<= b)
|]
{-======================================================
                     prop_26
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:2
prop_26 ::  NAT -> [NAT] -> [NAT] -> Bool
prop_26 x xs ys
  = (x `elem` xs) ==> (x `elem` (xs ++ ys))
|]
{-======================================================
                   prop_27
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:2
prop_27 ::  NAT -> [NAT] -> [NAT] -> Bool
prop_27 x xs ys
  = (x `elem` ys) ==> (x `elem` (xs ++ ys))
|]
{-======================================================
                        prop_28
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_28 ::  NAT -> [NAT] -> Bool
prop_28 x xs
  = (x `elem` (xs ++ [x]))
|]
{-======================================================
                     prop_29 (hint: induction) (cvc4-ok, non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple
prop_29 ::  NAT -> [NAT] -> Bool
prop_29 n ls@(x : xs)
  | n == x = trivial
  | otherwise = (n `elem` (ins1 n ls))
                    ? prop_29_proof n xs
  
-- the property:
prop_29 x xs
  = (x `elem` ins1 x xs)
|]
{-======================================================
                     prop_30 (hint: caseExpand) (non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple
prop_30 ::  NAT -> [NAT] -> Bool
prop_30 n ls@(x:xs) 
  | n<<x = trivial
  | n==x = trivial
  | otherwise = ()
                ? prop_30_proof n xs
-- the property:
prop_30 x xs
  = (x `elem` (insert x xs))
|]
{-======================================================
                        prop_31
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_31 ::  NAT -> NAT -> NAT -> Bool
prop_31 a b c
  = (min (min a b) c == min a (min b c))
|]
{-======================================================
                        prop_32
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_32 ::  NAT -> NAT -> Bool
prop_32 a b
  = (min a b == min b a)
|]
{-======================================================
                     prop_33
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_33 ::  NAT -> NAT -> Bool
prop_33 a b
  = (min a b == a) == (a <<= b)
|]
{-======================================================
                     prop_34
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_34 ::  NAT -> NAT -> Bool
prop_34 a b
  = (min a b == b) == (b <<= a)
|]
{-======================================================
                     prop_35
=======================================================-}
[lhp|genProp|reflect|ple|caseExpand
prop_35 ::  [NAT] -> Bool
prop_35 xs
  = dropWhile (const False) xs == xs
|]
{-======================================================
                     prop_36
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_36 ::  [NAT] -> Bool
prop_36 xs
  = takeWhile (const True) xs == xs
|]
{-======================================================
                     prop_37 (hint: caseExpand) (cvc4-ok, non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple
prop_37 ::  NAT -> [NAT] -> Bool
prop_37 n ls@(x:xs)
  | n == x = () ? prop_37_proof n xs
  | otherwise = () ? prop_37_proof n xs
  
prop_37 x xs
  = not (x `elem` (delete x xs))
|]
{-======================================================
                        prop_38
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_38 ::  NAT -> [NAT] -> Bool
prop_38 n xs
  = count n (xs ++ [n]) == S (count n xs)
|]
{-======================================================
                        prop_39
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:2
prop_39 ::  NAT -> NAT -> [NAT] -> Bool
prop_39 n x xs
  = count n [x] + count n xs == count n (x:xs)
|]
{-======================================================
                        prop_40
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_40 ::  [NAT] -> Bool
prop_40 xs
  = (take Z xs == [])
|]
{-======================================================
                        prop_42
=======================================================-}
[lhp|genProp|reflect
prop_42 ::  NAT -> NAT -> [NAT] -> Bool
prop_42 n x xs
  = (take (S n) (x:xs) == x : (take n xs))
|]
{-======================================================
                        prop_44
=======================================================-}
[lhp|genProp|reflect
prop_44 ::  NAT -> [NAT] -> [NAT] -> Bool
prop_44 x xs ys
  = (zip (x:xs) ys == zipConcat x xs ys)
|]
{-======================================================
                        prop_45
=======================================================-}
[lhp|genProp|reflect
prop_45 ::  NAT -> NAT -> [NAT] -> [NAT] -> Bool
prop_45 x y xs ys
  = (zip (x:xs) (y:ys) == (x, y) : zip xs ys)
|]
{-======================================================
                        prop_46
=======================================================-}
[lhp|genProp|reflect
prop_46 :: [NAT] -> Bool
prop_46 xs
  = (zip ([]::[NAT]) xs == [])
|]
-}
{-======================================================
                     prop_47 (hint: lemma)
=======================================================-}
{-@ rewriteWith prop_47_proof [prop_47_lemma_proof]  @-}
[lhp|genProp|reflect|ple
prop_47 ::  Tree a -> Bool
prop_47 a@(Node l x r)
  = ()
      -- ? prop_47_lemma_proof (height (mirror r)) (height (mirror l))
      ? prop_47_proof l
      ? prop_47_proof r
prop_47 a
  = (height (mirror a) == height a)
|]
[lhp|genProp|inline|ple|admit
prop_47_lemma :: NAT -> NAT -> Bool
prop_47_lemma n m = max n m == max m n
|]
{-
{-======================================================
                     prop_48 (hint: caseExpand) (cvc4-ok, non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple
prop_48 ::  [NAT] -> Bool
prop_48 ls@(x:xs@(y:ys)) 
  = ()
  --   (not (null ls) ==> (butlast ls ++ [last ls] == ls))
  -- ===   (null ls || (butlast ls ++ [last ls] == ls))
  -- ===  (butlast ls ++ [last ls] == ls)
  -- ===  (x:(butlast xs) ++ [last xs] == ls)
  -- === (butlast xs ++ [last xs] == xs)
    ? prop_48_proof xs
  -- === True
  
prop_48 xs
  = not (null xs) ==> (butlast xs ++ [last xs] == xs)
|]
{-======================================================
                   prop_49 (hint: caseExpand,lemma)
=======================================================-}
[lhp|genProp|reflect|ple|caseExpand
prop_49 ::  [NAT] -> [NAT] -> Bool 
prop_49 ls@(x : xs) rs@[]
  =  () ? rightIdApp_proof ls
prop_49 ls@(x1:x2: xs) rs@(y : ys)
  = () ? prop_49_proof (x2:xs) rs
prop_49 xs ys
  = (butlast (xs ++ ys) == butlastConcat xs ys)
|]
[lhp|genProp|reflect|ple|induction|caseExpand
rightIdApp :: Eq a => [a] -> Bool
rightIdApp xs = xs ++ [] == xs
|]
-- {-@ reflect prop_49 @-}
-- prop_49 :: [NAT] -> [NAT] -> Bool
-- prop_49 xs ys = ((butlast (xs ++ ys)) == (butlastConcat xs) ys)
-- {-@ ple prop_49_proof @-}
-- {-@ prop_49_proof :: xs:[NAT] -> ys:[NAT] -> { prop_49 xs ys } @-}
-- prop_49_proof :: [NAT] -> [NAT] -> Proof
-- prop_49_proof xs@[] ys@[]
--   = trivial
-- prop_49_proof xs@[] ys@(p427 : p428)
--   = trivial
-- prop_49_proof ls@([x]) rs@(y : ys)
--   = trivial
-- prop_49_proof ls@(x : xs) rs@[]
--   =  () ? rightIdApp_proof ls
-- prop_49_proof ls@(x1:x2: xs) rs@(y : ys)
--   = () ? prop_49_proof (x2:xs) rs
{-======================================================
                  prop_50 (hint: caseExpand, induction) (non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple|caseExpand
prop_50 ::  [NAT] -> Bool
prop_50 ls@(x1:x2:xs)
  = () ? prop_50_proof (x2:xs)
prop_50 xs
  = (butlast xs == take (length xs - S Z) xs)
|]
{-======================================================
                        prop_51
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:1
prop_51 ::  [NAT] -> NAT -> Bool
prop_51 xs x
  = (butlast (xs ++ [x]) == xs)
|]
{-======================================================
                   prop_52 (hint: lemma)
=======================================================-}
[lhp|genProp|reflect|ple
prop_52 ::  NAT -> [NAT] -> Bool
prop_52 n ls@(x:xs) = ()
            ? prop_52_proof n xs
            ? prop_52_lemma_proof n (rev xs) [x]
prop_52 n xs
  = (count n xs == count n (rev xs))
|]
[lhp|genProp|reflect|ple|admit
prop_52_lemma :: NAT -> [NAT] -> [NAT] -> Bool
prop_52_lemma n xs ys = count n (xs ++ ys) == count n (ys ++ xs)
|]
{-======================================================
                     prop_53 (hint: lemma)
=======================================================-}
[lhp|genProp|reflect|ple
prop_53 ::  NAT -> [NAT] -> Bool
prop_53 n ls@(x:xs) = ()
                      ? prop_53_lemma_proof n x (sort xs)
                      ? prop_53_proof n xs
-- the property 
prop_53 n xs
  = (count n xs == count n (sort xs))
|]
-- lemmas
[lhp|genProp|inline|ple
prop_53_lemma ::  NAT -> NAT -> [NAT] -> Bool
prop_53_lemma n x ls@(y:ys) 
        | x <<= y = trivial
        | otherwise = ()
                  --           (count n (insort x ls) == count n (x:ls))
                  -- === (count n (y : (insort x ys)) == count n (x:ls))
                  ? prop_53_lemma_count_proof n [x] ls
                  ? prop_53_lemma_count_proof n ys [x]
                  ? prop_53_lemma_proof n x ys
                  -- === (count n (insort x ys) == count n (ys ++ [x]))
-- the property:
prop_53_lemma n x xs = count n (insort x xs) == count n (x:xs)
|]
-- same as prop_52_lemma
[lhp|genProp|reflect|ple|admit
prop_53_lemma_count :: NAT -> [NAT] -> [NAT] -> Bool
prop_53_lemma_count n xs ys = count n (xs ++ ys) == count n (ys ++ xs)
|]
-}
{-======================================================
                     prop_54 (hint: lemma)
=======================================================-}
-- {-@ rewriteWith prop_54 [prop_54_lemma_dist_proof] @-}  rechecked
[lhp|genProp|reflect|ple
prop_54 ::  NAT -> NAT -> Bool
prop_54 n@(S sn) m@(Z) = ()
    ? prop_54_proof sn m
prop_54 n@(S sn) m@(S sm) = ()
    ? prop_54_proof sn sm
    ? prop_54_lemma_proof sm n
    ? prop_54_lemma_dist_proof (sm + sn) sn
prop_54 n m
  = ((m + n) - n == m)
|]
[lhp|genProp|reflect|ple|admit
prop_54_lemma :: NAT -> NAT -> Bool
prop_54_lemma n m = case m of
                      Z -> True
                      S sm -> (n + m) == S (n + sm)
|]  
[lhp|genProp|inline|ple|admit
prop_54_lemma_dist :: NAT -> NAT -> Bool
prop_54_lemma_dist n m = S (n - m) == S n - m
|]  
-- {-@ reflect prop_54 @-}
-- prop_54 :: NAT -> NAT -> Bool
-- prop_54 n m = ((m + n) - n== m)
-- {-@ ple prop_54_proof @-}
-- {-@ prop_54_proof :: n:NAT -> m:NAT -> {prop_54 n m} @-}
-- prop_54_proof :: NAT -> NAT -> Proof
-- prop_54_proof n@(S sn) m@(Z)
--   = prop_54 n m
--   === ((m + n)-n== m)
--   === (n - n == m)
--   === (sn - sn == m)
--   === ((m + sn) - sn == m)
--     ? prop_54_proof sn m
--   *** QED
-- prop_54_proof n@(S sn) m@(S sm)
--   = prop_54 n m
--   === ((m + n)-n== m)
--   === (S(sm + n) - n == m)
--   === ((sm + n) - sn == m)
--     ? prop_54_lemma_proof sm n
--   === (S (sm + sn) - sn == m)
--         ? prop_54_lemma_dist_proof (sm + sn) sn
--   === (S ((sm + sn) - sn) == m)
--     ? prop_54_proof sn sm
--   *** QED
-- prop_54_proof n m = (((m + n) - n == m)) *** QED
{-
{-======================================================
                        prop_55
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:2
prop_55 ::  NAT -> [NAT] -> [NAT] -> Bool
prop_55 n xs ys
  = (drop n (xs ++ ys) == drop n xs ++ drop (n - length xs) ys)
|]
{-======================================================
                     prop_56 (hint: lemma)
=======================================================-}
[lhp|genProp|reflect|ple
prop_56 ::  NAT -> NAT -> [NAT] -> Bool
prop_56
  n@(S sn)
  m@(S sm)
  ls@( x: xs)
  = ()
  --   ( (((drop n) ((drop m) ls)) == (drop (n + m)) ls) )
  -- === ((((drop n) ((drop sm) xs)) == (drop (n + m)) ls))
      ? prop_56_lemma_proof n m
  -- === (((drop n) ((drop m) ls)) == (drop (S(n + sm)) ls))
  -- === (((drop n) ((drop sm) xs)) == (drop (n + sm) xs))
        ? prop_56_proof n sm xs
  *** QED
-- property:
prop_56 n m xs
  = (drop n (drop m xs) == drop (n + m) xs)
|]
-- same as prop_54_lemma
[lhp|genProp|reflect|ple|admit
prop_56_lemma :: NAT -> NAT -> Bool
prop_56_lemma n m = case m of
                      Z -> True
                      S sm -> (n + m) == S (n + sm)
|]  
{-======================================================
                        prop_57
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_57 ::  NAT -> NAT ->  [NAT] -> Bool
prop_57 n m xs
  = (drop n (take m xs) == take (m - n) (drop n xs))
|]
{-======================================================
                        prop_58
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_58 ::  NAT -> [NAT] -> [NAT] -> Bool
prop_58 n xs ys
  = (drop n (zip xs ys) == zip (drop n xs) (drop n ys))
|]
{-======================================================
                     prop_59 (hint: lemma) (cvc4-ok, non-simp-ind)
=======================================================-}
-- {-@ rewriteWith prop_59_proof [rightIdApp_proof] @-} -- rewrite doesn't replace the call ?
[lhp|genProp|reflect|ple
prop_59 ::  [NAT] -> [NAT] -> Bool
prop_59 xs ys
  = (((ys == []) ==> (last (xs ++ ys) == last xs)))
  ? rightIdApp_proof xs
|]
[lhp|genProp|inline|ple|induction|caseExpand
rightIdApp :: Eq a => [a] -> Bool
rightIdApp xs = xs ++ [] == xs
|]
{-======================================================
                       prop_60 (hint:caseExpand,induction) (non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple
prop_60 ::  [NAT] -> [NAT] -> Bool
prop_60 ls@(x1:x2:xs) rs@(y : ys)
  = ((not (null rs)) ==> ((last (ls ++ rs)) == last rs)) 
  === ((last (ls ++ rs)) == last rs)
  === (last ((x2:xs ++ rs)) == last rs)
    ? prop_60_proof (x2:xs) rs
prop_60 xs ys
  = not (null ys) ==> (last (xs ++ ys) == last ys)
|]
{-======================================================
                     prop_61 (hint: lemma)
=======================================================-}
[lhp|genProp|reflect|ple|caseExpand
prop_61 ::  [NAT] -> [NAT] -> Bool
prop_61 ls@(x1 : x2 : xs) rs@[]
  = () ? rightIdApp_proof ls
prop_61 ls@(x1 : x2 : xs) rs
  = ()? prop_61_proof (x2:xs) rs
  
-- the property
prop_61 xs ys
  = (last (xs ++ ys) == lastOfTwo xs ys)
|]
{-======================================================
                     prop_62 (hint: induction) (cvc4-ok, non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple
prop_62 ::  [NAT] -> NAT -> Bool
prop_62 ls@(y1:y2:ys) x
  = () ? prop_62_proof (y2:ys) x
prop_62 xs x
  = not (null xs) ==> (last (x:xs) == last xs)
|]
{-======================================================
                     prop_63 (hint: induction) (non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple|caseExpand
prop_63 ::  NAT -> [NAT] -> Bool
prop_63 n@(S sn) ls@(x1:x2:xs) = () ? prop_63_proof sn (x2:xs)
prop_63 n xs
  = (n << length xs) ==> (last (drop n xs) == last xs)
|]
{-======================================================
                     prop_64 (hint: induction) (non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple
prop_64 ::  NAT -> [NAT] -> Bool
prop_64 n ls@(x1:x2:xs)
  = () ? prop_64_proof n (x2:xs)
  
prop_64 x xs
  = (last (xs ++ [x]) == x)
|]
{-======================================================
                        prop_65 (hint: lemma)
=======================================================-}
{-@ rewriteWith prop_65_proof [prop_T01_comm_proof] @-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_65 ::  NAT -> NAT -> Bool
prop_65 i m = i << S (m + i)
|]
{-======================================================
                     prop_67 (hint: induction) (non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple
prop_67 ::  [NAT] -> Bool
prop_67 ls@(x1:x2:xs)
  = () ? prop_67_proof (x2:xs)
prop_67 xs
  = (length (butlast xs) == length xs - S Z)
|]
{-======================================================
                     prop_68 (hint: lemma)
=======================================================-}
[lhp|genProp|reflect|ple
prop_68 ::  NAT -> [NAT] -> Bool
prop_68 n ls@(x:xs) 
    | n==x = ()
            ? prop_68_proof n xs
            ? prop_68_lemma_trans_proof (length (delete n xs)) (length xs) (S (length xs))
    | otherwise = ()
            ? prop_68_proof n xs
            ? prop_68_lemma_trans_proof (length (delete n xs)) (length xs) (S (length xs))
prop_68 n xs
  = length (delete n xs) <<= length xs
|]
[lhp|genProp|reflect|ple|admit
prop_68_lemma_trans :: NAT -> NAT -> NAT -> Bool
prop_68_lemma_trans n m d = (n<<=m) ==> (n<<=d)
|]
{-======================================================
                   prop_69  (hint: lemma)
=======================================================-}
{-@ rewriteWith prop_69_proof [prop_69_pluscommutative_proof] @-} -- here rewriting helps!
[lhp|genProp|reflect|ple|induction|caseExpand
prop_69 ::  NAT -> NAT -> Bool
-- prop_69 n@(S sn) m@(S sm)
--   = () -- without rewriting:
--     -- n <<= (m + n) 
--   -- ? prop_69_pluscommutative_proof m n
--   -- === sn <<= (sn + m)
--   -- ? prop_69_pluscommutative_proof sn m
--   ? prop_69_proof sn m
--   -- ***QED
-- the property:
prop_69 n m
  = n <<= (m + n)
|]
[lhp|genProp|inline|ple|admit
prop_69_pluscommutative :: NAT -> NAT -> Bool
prop_69_pluscommutative n m = n + m == m + n
|]
{-======================================================
                     prop_70
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_70 ::  NAT -> NAT -> Bool
prop_70 m n
  = m <<= n ==> (m <<= S n)
|]
{-======================================================
                     prop_71 (hint: caseExpand, lemma) (cvc4-ok, non-simp-ind)
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_71 ::  NAT ->  NAT -> [NAT] -> Bool
prop_71 n y ls@(x:xs) 
  | not(n == y) && not (y << x) 
              = (((n == y) == False) ==> (elem n (insert y ls) == elem n ls))
                -- === (elem n (insert y ls) == elem n ls)
                -- === (elem n (x : (insert y xs)) == elem n (x:xs))
                    ? prop_71_lemma2_proof n (insert y xs)
                    ? prop_71_lemma2_proof n ls
                -- === ((n==x || (elem n (insert y xs)) == (n==x || elem n xs)))
                -- === (n==x || ((elem n (insert y xs)) == (elem n xs)))
                    ? (prop_71_proof n y xs)
                -- ***QED
  | not(n == y) && (y << x) = trivial
  | otherwise = () ***QED
prop_71 x y xs
  = ((x == y) == False) ==> (elem x (insert y xs) == elem x xs)
|]
[lhp|genProp|reflect|ple|caseExpandP:1
prop_71_lemma2 :: NAT -> [NAT] -> Bool
prop_71_lemma2 n ls = case ls of
                        (x:xs) -> elem n ls == (n==x || elem n xs)
                        _     -> True
|]
{-======================================================
                     prop_72 (hint: lemma)
=======================================================-}
-- {-@ rewriteWith prop_72_proof [prop_72_lemma_rev_proof, prop_72_lemma_proof] @-} rechecked
[lhp|genProp|reflect|ple
prop_72 ::  NAT -> [NAT] -> Bool
prop_72 i@(Z) ls@(x:xs)
  = 
    (rev (drop i ls) == take (length ls - i) (rev ls))
  -- === (rev ls == take (length ls) (rev ls))
  -- === (rev xs ++ [x] == take (S (length xs)) (rev xs ++ [x]))
  -- === (rev (drop i xs) ++ [x] == take (S (length xs)) (rev xs ++ [x]))
        ? prop_72_proof i xs
  -- === ((take (length xs) (rev xs)) ++ [x] == take (S (length xs)) (rev xs ++ [x]))
      ? prop_72_lemma_rev_proof xs
      ? prop_72_lemma_proof (rev xs) [x]
  === (take (length [x] + length (rev xs)) (rev xs ++ [x]) == take (S (length xs)) (rev xs ++ [x]))
      ? ((length [x] + length (rev xs) )
      === (S Z + length (rev xs) )
      === (S (Z + length (rev xs)) )
      === (S (length (rev xs)))
      )
  === (take (S (length (rev xs)) ) (rev xs ++ [x]) == take (S (length xs)) (rev xs ++ [x]))
  ***QED
prop_72 i@(S sn) ls@(x:xs)
   = (rev (drop i ls) == take (length ls - i) (rev ls))
  -- === (rev (drop sn xs) == take (length xs - sn) (rev xs ++ [x]))
        ? prop_72_proof sn xs
  -- === (take (length xs - sn) (rev xs) == take (length xs - sn) (rev xs ++ [x]))
      ? prop_72_lemma1_proof (length xs) sn
      ? prop_72_lemma2_proof (length xs - sn) (rev xs) [x]
      ? prop_72_lemma_rev_proof xs
  -- === (take (length xs - sn) (rev xs) == take (length xs - sn) (rev xs ++ [x]))
  ***QED
prop_72 i xs
  = (rev (drop i xs) == take (length xs - i) (rev xs))
|]
[lhp|genProp|inline|ple|induction|caseExpand|admit
prop_72_lemma_rev :: [NAT] -> Bool
prop_72_lemma_rev ls = length (rev ls) == length ls
|]
[lhp|genProp|inline|ple|induction|caseExpand|admit
prop_72_lemma :: [NAT] -> [NAT] -> Bool
prop_72_lemma ls rs = (take (length ls) ls) ++ rs == take (length rs + length ls ) (ls ++ rs)
|]
[lhp|genProp|reflect|ple|induction|caseExpand|admit
prop_72_lemma1 :: NAT -> NAT -> Bool
prop_72_lemma1 m n =  (m - n) <<= m
|]
[lhp|genProp|reflect|ple|induction|caseExpand|admit
prop_72_lemma2 :: NAT -> [NAT] -> [NAT] -> Bool
prop_72_lemma2 n ls rs  = (n <<= length ls) ==> take n ls == take n (ls ++ rs)
|]
{-======================================================
                     prop_75
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_75 ::  NAT -> NAT -> [NAT] -> Bool
prop_75 n m xs
  = (count n xs + count n [m] == count n (m : xs))
|]
{-======================================================
                        prop_76
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:3
prop_76 ::  NAT ->  NAT -> [NAT] -> Bool
prop_76 n m xs
  = ((n == m) == False) ==> (count n (xs ++ [m]) == count n xs)
|]
{-======================================================
                     prop_77 (hint: lemma, caseExpand)
=======================================================-}
[lhp|genProp|reflect|ple
prop_77 ::  NAT -> [NAT] -> Bool
prop_77 n ls@([x]) 
  | sorted ls && not(n<<=x) =
       sorted (insort n ls)
      === sorted ([x,n])
      === x <<= n
        ? prop_77_theorem1_proof n x
      
  | otherwise = trivial 
     
prop_77 n ls@(x1:x2:xs)
  | sorted ls && not(n<<=x1) && not(n<<=x2) = 
      (sorted ls ==> sorted (insort n ls))
      -- === sorted (insort n ls)
      -- === sorted (x1:insort n (x2:xs))
      -- === sorted (x1:x2:insort n xs)
      -- === ((x1<<=x2) && sorted (x2:insort n xs))
      -- === sorted (x2:insort n xs)
      -- === sorted (insort n (x2:xs))
          ? prop_77_proof n (x2:xs)
          ? prop_77_lemma1_proof (x2:xs)
  | sorted ls && not(n<<=x1) && (n<<=x2) = 
     (sorted ls ==> sorted (insort n ls))
      -- === sorted (insort n ls)
      -- === sorted (x1:insort n (x2:xs))
      -- === sorted (x1:n:x2:xs)
      -- ===  ((x1 <<= n) && sorted (x2:xs))
          ? prop_77_lemma1_proof ls
      -- === (x1 <<= n)
          ? prop_77_theorem1_proof n x1
  | sorted ls && (n<<=x1) = trivial
  | otherwise = trivial
-- the property:
prop_77 x xs
  = sorted xs ==> sorted (insort x xs)
|]
[lhp|genProp|reflect|ple|admit
prop_77_lemma1 :: [NAT] -> Bool
prop_77_lemma1 ls = case ls of
                        (x:xs) -> sorted ls ==> sorted xs
                        _      -> True
|]
[lhp|genProp|reflect|ple|admit
prop_77_theorem1 :: NAT -> NAT -> Bool
prop_77_theorem1 n m = not(n <<= m) ==> m << n && m <<= n
|]
{-======================================================
                   prop_78 (hint: lemma)
=======================================================-}
[lhp|genProp|reflect|ple
prop_78 ::  [NAT] -> Bool
prop_78 ls@(x:xs)
  = (sorted (sort ls))
  -- === (sorted (insort x (sort xs)))
      ? prop_78_lemma_proof x (sort xs)
  -- === (sorted (sort xs))
    ? prop_78_proof xs
prop_78 xs
  = (sorted (sort xs))
|]
[lhp|genProp|reflect|ple|admit
prop_78_lemma :: NAT -> [NAT] -> Bool
prop_78_lemma n ls = sorted (insort n ls) == sorted ls
|]
{-======================================================
                        prop_79
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:2
prop_79 ::  NAT ->  NAT -> NAT -> Bool
prop_79 m n k
  = ((S m - n) - S k == (m - n) - k)
|]
{-======================================================
                        prop_80
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:2
prop_80 ::  NAT ->  [NAT] -> [NAT] -> Bool
prop_80 n xs ys
  = (take n (xs ++ ys) == take n xs ++ take (n - length xs) ys)
|]
{-======================================================
                 prop_81 (hint: lemma)
=======================================================-}
[lhp|genProp|reflect|ple
prop_81 ::  NAT ->  NAT -> [NAT] -> Bool
prop_81 n@Z m@(S sm) ls@(x:xs)
  = prop_81_proof n sm xs
prop_81 n@(S sn) m@(S sm) ls@(x:xs)
  = (take n (drop m ls) == drop m (take (n + m) ls))
  -- === (take n (drop sm xs) == drop sm (take (n + sm ) xs))
      ? prop_81_theorem_comm_proof m n
      ? prop_81_theorem_comm_proof sm n
      ? prop_81_proof n sm xs
prop_81 n m xs 
  = (take n (drop m xs) == drop m (take (n + m) xs))
|]
[lhp|genProp|reflect|ple|induction|caseExpand
prop_81_theorem_comm :: NAT -> NAT -> Bool
prop_81_theorem_comm n m = n+m == m+n
|]
{-======================================================
                        prop_82
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_82 ::  NAT ->  [NAT] -> [NAT] -> Bool
prop_82 n xs ys
  = (take n (zip xs ys) == zip (take n xs) (take n ys))
|]
{-======================================================
                        prop_83
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpand
prop_83 :: [NAT] -> [NAT] -> [NAT]-> Bool
prop_83 xs ys zs
  = (zip (xs ++ ys) zs == zip xs (take (length xs) zs) ++ zip ys (drop (length xs) zs))
|]
{-======================================================
                        prop_84
=======================================================-}
[lhp|genProp|reflect|ple|induction|caseExpandP:2
prop_84 :: [NAT] -> [NAT] -> [NAT] -> Bool
prop_84 xs ys zs
  = (zip xs (ys ++ zs) == zip (take (length ys) xs) ys ++ zip (drop (length ys) xs) zs)
|]
{-======================================================
                   prop_85 (hint: lemma)
=======================================================-}
-- {-@ rewriteWith prop_85_proof [prop_85_lemma_proof] @-} rechecked
[lhp|genProp|reflect|ple
prop_85 :: [NAT] -> [NAT] -> Bool
prop_85 ls@(x:xs) rs@(y:ys) =
    (zip (rev ls) (rev rs) == rev (zip ls rs))
  -- === (zip (rev ls) (rev rs) == rev ((x, y) : (zip xs ys)))
  -- === (zip (rev ls) (rev rs) == rev (zip xs ys) ++ [(x,y)])
      ? prop_85_proof xs ys
  -- === (zip (rev ls) (rev rs) == zip (rev xs) (rev ys) ++ [(x,y)])
  -- === (zip (rev xs ++ [x]) (rev ys ++ [y]) == zip (rev xs) (rev ys) ++ [(x,y)])
    ? prop_85_lemma_proof (rev xs) (rev ys) [x] [y]
prop_85 xs ys
  = (length xs == length ys) ==> (zip (rev xs) (rev ys) == rev (zip xs ys))
|]
[lhp|genProp|inline|ple|admit
prop_85_lemma :: [NAT] -> [NAT] -> [NAT] -> [NAT] ->Bool
prop_85_lemma ls rs xs ys = zip (ls ++ xs) (rs ++ ys) == zip ls rs ++ zip xs ys
|]
{-======================================================
                     prop_86 (hint: caseExpand, lemma)
=======================================================-}
[lhp|genProp|reflect|ple
prop_86 :: NAT -> NAT -> [NAT] -> Bool
prop_86 n y ls@[]
  = () ? prop_86_theorem_proof n y
prop_86 n y ls@(x:xs)
  | y<<x = () ? prop_86_theorem_proof n y
  
  | n==x = trivial
 | otherwise = (elem n (insert y ls) == elem n ls)
            === (elem n (x: insert y xs) == elem n ls)
            === (elem n (insert y xs) == elem n xs)
              ? prop_86_proof n y xs
prop_86 x y xs
  = x << y ==> (elem x (insert y xs) == elem x xs)
|]
[lhp|genProp|reflect|ple|admit
prop_86_theorem :: NAT -> NAT -> Bool
prop_86_theorem n m = n << m ==> n <<= m && not (n == m)
|]
{-======================================================
-- THEOREMS
-- https://github.com/tip-org/benchmarks/blob/master/original/prod/Properties.hs
=======================================================-}
{-======================================================
                        prop_T01 (hint: lemma)
=======================================================-}
{-@ rewriteWith  prop_T01_proof [prop_T01_comm_proof] @-}
[lhp|genProp|inline|ple|induction|caseExpand
prop_T01 :: NAT -> Bool
prop_T01 x = double x == x + x
|]
[lhp|genProp|inline|ple|induction|caseExpand
prop_T01_comm :: NAT -> NAT -> Bool
prop_T01_comm n m = n+m == m+n
|]
{-======================================================
                      prop_T02
=======================================================-}
[lhp|genProp|inline|ple|induction|caseExpand
prop_T02 :: [a] -> [a] -> Bool
prop_T02 x y = length (x ++ y) == length (y ++ x)
|]
{-======================================================
                    prop_T03
=======================================================-}
[lhp|genProp|inline|ple|induction|caseExpand
prop_T03 :: [a] -> [a] -> Bool
prop_T03 x y = length (x ++ y ) == length (y) + length x
|]
{-======================================================
                    prop_T04 (hint: lemma)
=======================================================-}
{-@ rewriteWith prop_T04_proof [prop_T03_proof, prop_T02_proof, prop_T01_proof] @-}
[lhp|genProp|reflect|ple
prop_T04 :: [a] -> Bool
prop_T04 x = length (x ++ x) == double (length x)
|]
{-======================================================
                    prop_T05 (hint: lemma)
=======================================================-}
{-@ rewriteWith  prop_T05_proof [prop_T03_proof] @-}
[lhp|genProp|inline|ple
prop_T05 :: [a] -> Bool
prop_T05 ls@(x:xs) = (length (rev ls) == length ls)
              === (length [x] + length (rev xs)  == S (length xs))
              === (S (Z  + length (rev xs)) == S (length xs))
                  ? prop_T05_proof xs
prop_T05 x = length (rev x) == length x
|]
{-======================================================
                    prop_T06 (hint: lemma)
=======================================================-}
{-@ rewriteWith  prop_T06_proof [prop_T03_proof,prop_T05_proof,prop_T01_comm_proof] @-}
[lhp|genProp|inline|ple
prop_T06 :: [a] -> [a] -> Bool
prop_T06 x y = length (rev (x ++ y )) == length x + length y
                -- ? prop_T05_proof (x++y)
                -- ? prop_T03_proof x y
                -- ? prop_T01_comm_proof (length x) (length y)
|]
{-======================================================
                    prop_T07 (hint: lemma)
=======================================================-}
-- {-@ rewriteWith prop_T07 [prop_T01_comm_proof,prop_T07_lemma_proof]  @-} rechecked
[lhp|genProp|reflect|ple
prop_T07 :: [a] -> [a] -> Bool
prop_T07 ls@(x:xs) y = (length (qrev ls y) == length ls + length y)
                  -- === (length (qrev xs (x:y)) == length ls + length y  )
                      ? prop_T07_proof xs (x:y)
                  -- === (length xs + length (x:y) == length ls + length y  )
                        ? prop_T01_comm_proof (length xs) (length (x:y))
                  -- === (length (x:y) + length xs == length ls + length y  )
                  -- === ((S (length y)) + length xs == length ls + length y  )
                      ? prop_T07_lemma_proof (length y) (length xs)
                  -- === (length y + S( length xs )== length ls + length y  )
                  -- === (length y + length (x:xs) == length ls + length y  )
                      ? prop_T01_comm_proof  (length y) (length ls)
                
prop_T07 x y = length (qrev x y) == length x + length y
|]
[lhp|genProp|inline|ple|induction|caseExpand
prop_T07_lemma :: NAT -> NAT -> Bool
prop_T07_lemma n m = S n + m == n + S m
|]
-}