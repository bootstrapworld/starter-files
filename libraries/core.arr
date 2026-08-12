use context starter2024

# Note: types sourced from the sub-libraries below (Posn, DecisionTree, etc.)
# are NOT re-listed here -- unlike same-file data/type declarations, a type
# that only becomes available via a later `provide from X: ...` statement
# must be exposed through that statement itself; listing it here too, before
# the import that brings it into scope, is a compile error ("unbound name").
provide:
  *,
  module Eth,
  module Err,
  module Sets,
  module T,
  module SD,
  module R,
  module L,
  module Stats,
  module Math
end

# export every symbol from starter2024 except for those we override
import starter2024 as Starter
provide from Starter:
    * hiding(translate, filter, range, sort, sin, cos, tan)
end

import image as I
provide from I:
    * hiding(translate),
  type *,
  data *
end

import lists as L
provide from L: * hiding(filter, range, sort), type *, data * end

import color as C
import constants as Consts
provide from Consts: PI, E end
import reactors as R

import either as Eth
import error as Err
import sets as Sets
import tables as T
import string-dict as SD
import statistics as Stats
import math as Math

import gdrive-sheets as G
provide from G:
    * hiding(load-spreadsheet),
  type *,
  data *
end

####################################################################
# core.arr assembles everything a Bootstrap starter file needs from
# four sub-libraries (each is its own file, fetched once and
# re-exported here) so this remains the single file starter files
# reference. See foundations.arr / ds-tools.arr / algebra-tools.arr /
# ai-tools.arr for the actual implementations.
####################################################################

import url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/refactor/libraries/", "foundations.arr") as Foundations
provide from Foundations:
  *,
  type Posn, type ShrinkResult, type TaggedFunction
end

import url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/refactor/libraries/", "ds-tools.arr") as DSTools
provide from DSTools: * end

import url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/refactor/libraries/", "algebra-tools.arr") as AlgebraTools
provide from AlgebraTools: * end

import url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/refactor/libraries/", "ai-tools.arr") as AITools
provide from AITools:
  *,
  type DecisionTree
end
