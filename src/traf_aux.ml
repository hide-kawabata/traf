(*
 * Copyright (C) 2016 - 2018 Yuta Tanaka and Hideyuki Kawabata
 *
 * This file is part of "traf".
 *)


(* used in input.ml --------------------------------------- *)

let search_string_pos source search =
  try
    Str.search_forward (Str.regexp search) source 0
  with
  | Not_found -> -100


(* Search "\n  " in the given string (source) and return the starting position.
   If the next character of "\n  " is ' ', then the next occurrence of "\n  " 
   will be searched. If not found, return None.
 *)
let search_1asmpt_end_pos source =
  let rec f source p =
    let pos = search_string_pos source "\n  " in
    match pos > 0 with
    | false -> None
    | _     ->
       if (String.length source) > pos
       then
         match String.get source (pos+3) with
         | ' ' -> f (String.sub source (pos+3) ((String.length source)-(pos+3)))
                    (p+pos+3)
         | _   -> Some (pos+p)
       else
         None
  in
  f source 0

    
(* [mold_assumption] extracts assumptions from a given string like:
"  P : Prop
  Q : Prop
  H : P /\ Q
  J : 1 + nat_of_bin n'' + nat_of_bin n'' + 1 =
      forall X Y : Prop, X /\ Y -> Y /\ X
      forall S T : Prop, S /\ T
  ============================
   Q /\ P

"
   and returns a list of pairs of id and type, 
   such as [("P", "Prop"); ("Q", "Prop"); ("H", "P /\ Q"); ...].

   This function should be optimized.
*)
let mold_assumption s =
  let rec m_s s l =
    if (String.get s 0 = ' ')
    then
      m_s (String.sub s 1 ((String.length s)-1)) l
    else
      let split_start_position =
	search_string_pos s "============================"
      in
      if (String.index s '\n') < split_start_position
      then
	match String.contains s ':' with
	| false -> []
	| _     ->
	   (* len: position of the end point of an assumption *)
           let len = (* search "\n  " which is not followed by a space ' ' *)
             match search_1asmpt_end_pos s with
             | None   -> -10000 (* no assumption in s *)
             | Some p -> p
           in
           let one_assumption = String.sub s 0 len in
           (* e.g. one_assumption = "P : Prop" *)
           let o_a_len = String.index one_assumption ':' in
           let one_aspt_tag = String.sub one_assumption 0 (o_a_len-1) in
           (* e.g. one_aspt_tag = "P" *)
           let one_aspt =
	     let one_aspt' =
	       String.sub one_assumption (o_a_len+2) (len-(o_a_len+2)) in
             one_aspt'
           in
           (* e.g. one_aspt = "Prop" *)
           (* if one_aspt_tag contains "Case", the assumption is ignored *)
	   match (search_string_pos one_aspt_tag "Case") < 0 with
	   | true -> m_s (String.sub s (len+3) ((String.length s)-(len+3)))
	                ((one_aspt_tag, one_aspt)::l)
	   | _    -> m_s (String.sub s (len+3) ((String.length s)-(len+3)))
	               l
      else
	List.rev l
  in
  let split_start_position =
    search_string_pos s "============================"
  in
  if (split_start_position > 0)
     && (String.length s >= (split_start_position + 30)) then begin
      print_string (String.sub s 0 (split_start_position + 30));
      m_s (String.sub s 0 (split_start_position + 30)) []
    end
  else
    []
  

      
(* [mold_subgoal] takes a string like:
 "  Case := \"n = DP n''\" : String.string
  n'' : bin
  IHn'' : nat_of_bin (increment_bin n'') = nat_of_bin n'' + 1
  ============================
   nat_of_bin (increment_bin n'') + (nat_of_bin (increment_bin n'') + 0) =
   nat_of_bin n'' + (nat_of_bin n'' + 0) + 1 + 1

"
and extract subgoal text.
 *)
let mold_subgoal s =
  let splitbar = "============================" in
  let take_subgoal_out_of_sequent_text s =
    let split_start_position =
      try 
        Str.search_forward (Str.regexp splitbar) s 0
      with
      | Not_found -> -1 (* error *)
    in 
   let split_end_position = split_start_position + (String.length splitbar)
   in
   let len = (String.length s) - split_end_position
   in
   String.sub s split_end_position len
  in
  let rec mold_subgoal' s =
    if (String.get s 0 = ' ') || (String.get s 0 = '\n')
    then
      mold_subgoal' (String.sub s 1 ((String.length s)-1))
    else
      let subgoal_text_len =
	let rec f position =
	  (* subgoal part in sequent_text is in multiple lines of text:
             search for "\n\n" *)
	  let return_position =
	    position +
	      (String.index
		 (String.sub s position ((String.length s)- position - 1)) '\n')
	  in
	  match String.get s (return_position+1) with
	    '\n' -> return_position
	  |  _   -> f (return_position+1)
	in
	f 0
      in
      String.sub s 0 subgoal_text_len
  in
  (* text might contain '\n' *)
  let text = mold_subgoal' (take_subgoal_out_of_sequent_text s)
  in
  text


(** This function checks if the received info should be ignored or not
    depending on the command string.
 *)
(*
let ignored_commands cmd_str =
  if (Str.string_match (Str.regexp ("^Show")) cmd_str 0)
     && not (Str.string_match (Str.regexp (".*as a replacement of Proof"))
               cmd_str 0)
  then
    true
  else
    false
 *)
let ignored_commands _ = false


(* used in proof_window.ml and draw_tree.ml ---------------- *)

let show_current_only_flag = ref false;;

(** Rewrites ascii symbols using fancy fonts.
 *)
let rewrite_symbols text = 
  let text = Str.global_replace (Str.regexp "forall") "∀" text in
  let text = Str.global_replace (Str.regexp "exists") "∃" text in
  let text = Str.global_replace 
               (Str.regexp "\\([A-Za-z0-9 \t]+\\|^\\)->\\([A-Za-z0-9 \t]+\\|$\\)")
               "\\1→\\2"
               text in
  let text = Str.global_replace
               (Str.regexp "\\([A-Za-z0-9 \t]+\\|^\\)->\\([A-Za-z0-9 \t]+\\|$\\)")
               "\\1→\\2"
               text in (* again *)
  let text = Str.global_replace
               (Str.regexp "\\([A-Za-z0-9 \t]+\\|^\\)<-\\([A-Za-z0-9 \t]+\\|$\\)")
               "\\1←\\2" 
               text in
  let text = Str.global_replace 
               (Str.regexp "\\([A-Za-z0-9 \t]+\\|^\\)<-\\([A-Za-z0-9 \t]+\\|$\\)")
               "\\1←\\2" 
               text in (* again *)
  let text = Str.global_replace (Str.regexp "~") "¬" text in
  let text = Str.global_replace (Str.regexp "<>") "≠" text in
  text


(* used in draw_tree.ml ---------------------------------- *)

let print_current_assumptions assumption_list =
  let rec gen_str lst = match lst with
    | [] -> ""
    | (key, content)::[] -> key ^ " : " ^ content
    | (key, content)::rest -> key ^ " : " ^ content ^ "\n" ^ gen_str rest
  in
    gen_str assumption_list


(* used in proof_tree.ml ---------------------------------- *)

let search_assumption_by_tag tag assumption_list =
  let tag_included key tag =
    let sl' = Str.split (Str.regexp ",[ \t]+") key in List.mem tag sl'
  in
  try 
    let (_, content) =
      List.find (fun (key, _) -> tag_included key tag) assumption_list
    in Some content
  with
  | Not_found -> None

let search_assumption_by_entity entity assumption_list =
  try let pair = List.find (fun (_, c) -> c = entity) assumption_list
      in Some pair
  with
  | Not_found -> None



