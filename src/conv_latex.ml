(*
   This file includes the implementation of the functionality of LaTeX
   code generation.
   - class conv_latex
   - related functions
*)

open Draw_tree

class conv_latex
  (conv_latex : GText.view)
  (root : proof_tree_element option)
  =
object (self)

  (* turnstile *)
  method translate node = 
    let kind = node#node_kind in
    match kind with
    | Proof_command -> assert false
    | Turnstile -> let children = node#children in
                   match children with
                   | [] -> "\\prftree[noline]{"
                           ^ self#rewrite_str node#displayed_content Turnstile ^ "}\n"
                   | c::[] -> "\\prftree[r]{"
                              ^ self#rewrite_str c#displayed_content Proof_command ^ "}"
                              ^ (self#translate_children c) ^ "\n"
                              ^ "{"
                              ^ self#rewrite_str node#displayed_content Turnstile ^ "}\n"
                   | _ -> assert false

  (* command *)
  method translate_children node = 
    let kind = node#node_kind in
    match kind with
    | Proof_command -> let children = node#children in
                       List.fold_left (fun str n -> str ^ "{" ^ self#translate n ^ "}") "" children
    | Turnstile -> assert false

  method rewrite_str str com =
    let str = match com with
      | Proof_command -> self#check_str str com
      | Turnstile -> Str.global_replace (Str.regexp "mathrmLPAR") "\\mathrm{" 
                       (Str.global_replace (Str.regexp "mathrmRPAR") "}" 
                          (self#check_str (self#check_id_of_sequent str) com))
    in
    Str.global_replace (Str.regexp " +") "~" str

  (* for sequent text (turnstile) *)
  method check_id_of_sequent sequent =
    let find_id_pair = [("\\([a-zA-Z')_][a-zA-Z')_0-9]+\\)", "mathrmLPAR"^"\\1"^"mathrmRPAR "); (* id *)
			("\\([a-zA-Z'][a-zA-Z')_0-9]+\\),", "mathrmLPAR"^"\\1"^"mathrmRPAR, "); (* id *)
			("[|\\([a-zA-Z'_][a-zA-Z')_0-9]+\\])","[|mathrmLPAR"^"\\1"^"mathrmRPAR]"); (* [|id... ?? *)
		        ("\\([a-zA-Z'][a-zA-Z')_0-9]+\\)$","\\mathrm{"^"\\1"^"}"); (* id$ *)
		       ]
    in
    let rec replace_ids seq replace_pair=
      match replace_pair with
      | [] -> seq
      | (beforestr, replacestr)::rest ->
         let afterstr= Str.global_replace (Str.regexp beforestr) (replacestr) seq in
         replace_ids afterstr rest    
    in replace_ids sequent find_id_pair


  method check_str str seq_or_com=
    let symbols =[
                  ("\\", "BACKSLASH");
                  ("{", "\\{");
                  ("}", "\\}");
                  ("⊢","VDASH");
                  ("forall", "FORALL");
                  ("∀",
                   "FORALL");
                  ("exists", "EXISTS");
                  ("∃"
                  ,"EXISTS");
		  ("/\\", "WEDGE");
                  ("\\\\/", "VEE");
		  ("_", "\\_");
		  ("|", "MID");
		  ("●",
                   "VDOTS");
                  ("'", "PRIME");
(*
                  ("->", "RIGHTARROW");
                  ("<-", "LEFTARROW");
 *)
                  ("\\([A-Za-z0-9 \t]+\\|^\\)->\\([A-Za-z0-9 \t]+\\|$\\)"
                  , "\\1 RIGHTARROW \\2");
                  ("\\([A-Za-z0-9 \t]+\\|^\\)->\\([A-Za-z0-9 \t]+\\|$\\)"
                  , "\\1 RIGHTARROW \\2"); (* 2nd time *)
                  ("\\([A-Za-z0-9 \t]+\\|^\\)<-\\([A-Za-z0-9 \t]+\\|$\\)"
                  , "\\1 LEFTARROW \\2");
                  ("\\([A-Za-z0-9 \t]+\\|^\\)<-\\([A-Za-z0-9 \t]+\\|$\\)"
                  , "\\1 LEFTARROW \\2"); (* 2nd time *)
		 ] 
    in
    let latex_commands = [("VDASH", "\\vdash"); ("FORALL", "\\forall"); ("EXISTS", "\\exists");
                          ("WEDGE", "\\wedge"); ("VEE", "\\vee"); ("BACKSLASH", "\\backslash");
                          ("MID", "\\mid"); ("VDOTS", "\\vdots"); ("PRIME", "^{\\prime}");
                          ("RIGHTARROW", "\\rightarrow"); ("LEFTARROW", "\\leftarrow")]
    in
    let str = List.fold_left (fun s pat ->
                  Str.global_replace (Str.regexp (fst pat)) (snd pat) s) str symbols
    in
      match seq_or_com with
      | Turnstile -> List.fold_left
                       (fun s pat -> Str.global_replace (Str.regexp (fst pat))
                                         (snd pat) s) str latex_commands
      | Proof_command -> List.fold_left
                       (fun s pat -> Str.global_replace (Str.regexp (fst pat))
                                         ("$" ^ (snd pat) ^ "$") s) str latex_commands

  method update_view =
    conv_latex#buffer#set_text
      (match root with
	 None ->
	 "Proof is finished or Proof is not started."
       | Some node ->
	  "%[PTCL]\n"
          ^ "%\\documentclass[a4j,landscape,papersize]{jsarticle}\n"
          ^ "%\\usepackage{prftree}\n"
          ^ "%\\begin{document}\n"
          ^ self#translate node
          ^ "%\\end{document}\n"
      );

  initializer      
    self#update_view

end

(* used while saving files *)
let default_ d = function
  | None -> d
  | Some v -> v

let all_files () =
  let f = GFile.filter ~name:"All" () in
  f#add_pattern "*" ;
  f

let ask_for_file parent latexcode=
  let dialog = GWindow.file_chooser_dialog 
      ~action:`SAVE
      ~title:"Save File"
      ~parent () in
  dialog#set_do_overwrite_confirmation true;
  dialog#add_button_stock `CANCEL `CANCEL ;
  dialog#add_select_button_stock `SAVE `SAVE ;
  dialog#add_filter (all_files ()) ;
  begin match dialog#run () with
  | `SAVE ->
     let str_out = open_out (default_ "<none>" dialog#filename) in
     Printf.fprintf str_out "%s\n" latexcode;
     flush str_out;
     close_out str_out
  | `DELETE_EVENT | `CANCEL -> ()
  end ;
  dialog#destroy ()



(** Create LaTeX window *)
let show_conv_window_new (root : proof_tree_element option)
  =
  let conv_win =
    GWindow.window 
      ~title:"Convert LaTeX Code"
      ~border_width:10
      ~width:400 ~height:200
      ~resizable:true
      ()
  in
  let vpack1=GPack.vbox ~spacing:3 ~width:100 ~height:100
                        ~packing:conv_win#add () in
  
  let base_frame = GBin.frame ~label:"LaTeX Code" ~packing:(vpack1#pack ~expand:true) () in
  let scrolling = GBin.scrolled_window 
                    ~hpolicy:`AUTOMATIC ~vpolicy:`AUTOMATIC 
                    ~packing:base_frame#add () 
  in
  let string_window = GText.view ~editable:false ~cursor_visible:true
                                 ~border_width:5
                                 ~height:400
                                 ~packing:scrolling#add ()
  in  
  let _ = new conv_latex
                 string_window root in
  
  (* bottom button line*)
  let button_box_align = GBin.alignment
                           ~padding:(1,1,3,3)			(* (top, bottom, left, right)*)
                           ~packing:(vpack1#pack) () in
  let button_h_box = GPack.hbox
                       ~packing:button_box_align#add () in
  let dismiss_button = 
    GButton.button ~label:"Dismiss" ~packing:button_h_box#pack ()
  in
  let save_button = 
    GButton.button ~label:"Save_this_code" ~packing:button_h_box#pack ()
  in
  let copy_button = 
    GButton.button ~label:"copy_this_code" ~packing:button_h_box#pack ()
  in
  ignore(dismiss_button#connect#clicked 
	   ~callback:(fun () -> conv_win#destroy()));
  ignore(save_button#connect#clicked 
	   ~callback:(fun () -> 
	     Printf.fprintf (Util.debugc()) "Save_Button_was_clicked.\n%!";
	     ask_for_file conv_win (string_window#buffer#get_text ());
	     Printf.fprintf (Util.debugc()) "Save_was_ended.\n%!"
	   )
        );

  let clipboard = GData.clipboard Gdk.Atom.clipboard in
  ignore(copy_button#connect#clicked 
	   ~callback:(fun () -> 
	     clipboard#set_text (string_window#buffer#get_text ())
	   )
        );

  Printf.fprintf (Util.debugc()) "[LaTeX Code Begin]\n%s\n[LaTeX Code End]\n%!" (string_window#buffer#get_text ());

  ignore(conv_win#connect#destroy ~callback:(fun () -> conv_win#destroy()));
  conv_win#show ()






