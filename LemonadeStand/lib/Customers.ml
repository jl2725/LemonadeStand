open Random
open Recipe

(* Let's say a perfect cup of lemonade needs 4 tsp of sugar, 4 tsp of squeezed
   lemon and 1 cup of water for each cup of lemonade. Player's selected
   ingredient will be divided by the above values to create a ratio.

   Prep Phase (Range):

   (Lemon): 0 tsp - 5 tsp

   (Sugar): 0 tsp - 5 tsp

   (Water): 0.5 cup - 2 cups

   (Cost): $0.05 - $10.00 **)

type ratio = {
  sour : float;
  sweet : float;
  water : float;
  cost : float;
}

let set_lemon = 4.
let set_sugar = 4.
let set_water = 1.
let set_cost = 3.

let response_ratio =
  {
    sour = Recipe.get_lemon_input /. set_lemon;
    sweet = Recipe.get_sugar_input /. set_sugar;
    water = Recipe.get_water_input /. set_water;
    cost = Recipe.get_cost_input /. set_cost;
  }

type responses =
  | Sour
  | Bland
  | JustRight
  | Expensive
  | Cheap
  | JustAlright

(* Textfile containing names, inspired by StackOverflow
   (https://stackoverflow.com/questions/5774934/how-do-i-read-in-lines-from-a-text-file-in-ocaml) *)
let read_lines filename =
  let rand_count = Random.int 999 in
  let f = open_in filename in
  let rec loop () count =
    try
      let next = input_line f in
      if count = 0 then (
        close_in f;
        next)
      else loop () (count - 1)
    with End_of_file ->
      close_in f;
      ""
  in
  loop () rand_count

(* Let's say each lemon yields 3 tsp of lemon juice *)
(* Sour: greater than 20% of the perfect amount of squeezed lemon and the ratio
   of squeezed lemon is 20% greater than that of sugar *)
(* Bland: The ratio of squeezed lemon and sugar to water amount is less than 5*)
(* JustRight: The ratio of squeezed lemon and suga to water is betwee n 7.5 and
   8.5 *)
(* Expensive: The ratio of squeezed lemon and sugar to cost is less than 1.75 *)
(* Cheap: If the cost is less than $1.50 *)
(* JustAlright: To catch all the cases*)

let customer_respoonses s lst =
  let sour =
    if s.sour > 1.2 || s.sour /. s.sweet > 1.2 then Sour :: lst else lst
  in
  let bland =
    if (s.sour +. s.sweet) /. s.water < 5. then Bland :: sour else sour
  in
  let justright =
    if
      (s.sour +. s.sweet) /. s.water > 7.5
      && (s.sour +. s.sweet) /. s.water < 8.5
    then JustRight :: bland
    else bland
  in
  let expensive =
    if (s.sour +. s.sweet) /. s.cost < 1.75 then Expensive :: justright
    else justright
  in
  let cheap = if s.cost < 1.5 then Cheap :: expensive else expensive in
  JustAlright :: cheap

(* Accumulator: Number of responses generated Max: Number of people who
   purchased lemonade less than 10 else 10 *)
let rec generate lst acc =
  let names = read_lines "./CustomerNames" in
  match (List.nth lst (Random.int (List.length lst) - 1), acc) with
  | _, 0 -> []
  | Sour, acc ->
      (names ^ "thinks the lemonade is too sour") :: generate lst (acc - 1)
  | Bland, acc ->
      (names ^ "thinks the lemonade is bland") :: generate lst (acc - 1)
  | JustRight, acc ->
      (names ^ "thinks the lemonade is just right") :: generate lst (acc - 1)
  | Expensive, acc ->
      (names ^ "thinks the lemonade is too expensive") :: generate lst (acc - 1)
  | Cheap, acc ->
      (names ^ "thinks the lemonade is at a good price")
      :: generate lst (acc - 1)
  | JustAlright, acc ->
      (names ^ "thinks the lemonade is just alright") :: generate lst (acc - 1)

(* Future: create more varaible responses for each customer feeback *)